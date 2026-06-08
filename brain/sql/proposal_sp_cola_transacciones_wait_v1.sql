/*
#EJC20260608 mejora(liquidacion-bof): SPs para reducir roundtrips de espera en cola de transacciones.
Objetivo:
1) Resolver espera recursiva en BOF con operaciones atomicas en BD.
2) Consolidar lectura + procesamiento de turnos en 1 viaje.
3) Agregar TVP para liberaciones en lote.

Notas:
- Script no reemplaza tablas existentes.
- Compatible con P_COLA_TRANSACCIONES actual (CODIGO manual).
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   1) TVP: liberacion masiva de turnos
   ========================================================= */
IF TYPE_ID('dbo.tvp_COLA_TRANSACCIONES_CODIGO_v1') IS NULL
    CREATE TYPE dbo.tvp_COLA_TRANSACCIONES_CODIGO_v1 AS TABLE
    (
        CODIGO INT NOT NULL PRIMARY KEY
    );
GO

/* =========================================================
   2) Lectura consolidada de bloqueo activo por tipo
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_COLA_TRANSACCIONES_ReadActive_v1
    @TIPO_TRANS INT,
    @CODIGO_USUARIO VARCHAR(50) = NULL,
    @CODIGO_LIQUIDACION INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        C.CODIGO,
        C.CODIGO_LIQUIDACION,
        C.CODIGO_USUARIO,
        C.FECHA_INICIO,
        C.FECHA_FIN,
        C.TIPO_TRANS,
        C.PROCESADO
    FROM dbo.P_COLA_TRANSACCIONES AS C WITH (READPAST)
    WHERE C.PROCESADO = 0
      AND C.TIPO_TRANS = @TIPO_TRANS
      AND (@CODIGO_USUARIO IS NULL OR C.CODIGO_USUARIO <> @CODIGO_USUARIO)
      AND (@CODIGO_LIQUIDACION IS NULL OR C.CODIGO_LIQUIDACION = @CODIGO_LIQUIDACION)
    ORDER BY C.FECHA_INICIO, C.CODIGO;
END;
GO

/* =========================================================
   3) Toma de turno atomica (leer + procesar en 1 roundtrip)
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_COLA_TRANSACCIONES_TryAcquire_v1
    @TIPO_TRANS INT,
    @CODIGO_LIQUIDACION INT,
    @CODIGO_USUARIO VARCHAR(50),
    @FORCE_STALE_SECONDS INT = 60
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    DECLARE @BloqCodigo INT = NULL,
            @BloqLiquidacion INT = NULL,
            @BloqUsuario VARCHAR(50) = NULL,
            @BloqInicio DATETIME = NULL,
            @CodigoTurno INT = NULL;

    BEGIN TRY
        BEGIN TRAN;

        -- Liberar residuos viejos para no quedarse en espera infinita.
        UPDATE C
           SET C.PROCESADO = 1,
               C.FECHA_FIN = GETDATE()
        FROM dbo.P_COLA_TRANSACCIONES AS C WITH (UPDLOCK, HOLDLOCK)
        WHERE C.PROCESADO = 0
          AND C.TIPO_TRANS = @TIPO_TRANS
          AND DATEDIFF(SECOND, C.FECHA_INICIO, GETDATE()) > @FORCE_STALE_SECONDS;

        -- Buscar bloqueo actual de otro usuario para el mismo tipo/ruta.
        SELECT TOP (1)
            @BloqCodigo = C.CODIGO,
            @BloqLiquidacion = C.CODIGO_LIQUIDACION,
            @BloqUsuario = C.CODIGO_USUARIO,
            @BloqInicio = C.FECHA_INICIO
        FROM dbo.P_COLA_TRANSACCIONES AS C WITH (UPDLOCK, HOLDLOCK)
        WHERE C.PROCESADO = 0
          AND C.TIPO_TRANS = @TIPO_TRANS
          AND C.CODIGO_USUARIO <> @CODIGO_USUARIO
          AND C.CODIGO_LIQUIDACION = @CODIGO_LIQUIDACION
        ORDER BY C.FECHA_INICIO, C.CODIGO;

        IF @BloqCodigo IS NULL
        BEGIN
            -- Reusar fila activa del mismo usuario, si ya existe.
            SELECT TOP (1)
                @CodigoTurno = C.CODIGO
            FROM dbo.P_COLA_TRANSACCIONES AS C WITH (UPDLOCK, HOLDLOCK)
            WHERE C.PROCESADO = 0
              AND C.TIPO_TRANS = @TIPO_TRANS
              AND C.CODIGO_USUARIO = @CODIGO_USUARIO
              AND C.CODIGO_LIQUIDACION = @CODIGO_LIQUIDACION
            ORDER BY C.CODIGO DESC;

            IF @CodigoTurno IS NULL
            BEGIN
                SELECT @CodigoTurno = ISNULL(MAX(C.CODIGO), 0) + 1
                FROM dbo.P_COLA_TRANSACCIONES AS C WITH (UPDLOCK, HOLDLOCK);

                INSERT INTO dbo.P_COLA_TRANSACCIONES
                (
                    CODIGO,
                    CODIGO_LIQUIDACION,
                    CODIGO_USUARIO,
                    FECHA_INICIO,
                    FECHA_FIN,
                    TIPO_TRANS,
                    PROCESADO
                )
                VALUES
                (
                    @CodigoTurno,
                    @CODIGO_LIQUIDACION,
                    @CODIGO_USUARIO,
                    GETDATE(),
                    GETDATE(),
                    @TIPO_TRANS,
                    0
                );
            END;

            SELECT
                CAST(1 AS BIT) AS ACQUIRED,
                @CodigoTurno AS CODIGO_TURNO,
                CAST(NULL AS INT) AS BLOQUEO_CODIGO,
                CAST(NULL AS INT) AS BLOQUEO_LIQUIDACION,
                CAST(NULL AS VARCHAR(50)) AS BLOQUEO_USUARIO,
                CAST(NULL AS DATETIME) AS BLOQUEO_FECHA_INICIO;
        END
        ELSE
        BEGIN
            SELECT
                CAST(0 AS BIT) AS ACQUIRED,
                CAST(NULL AS INT) AS CODIGO_TURNO,
                @BloqCodigo AS BLOQUEO_CODIGO,
                @BloqLiquidacion AS BLOQUEO_LIQUIDACION,
                @BloqUsuario AS BLOQUEO_USUARIO,
                @BloqInicio AS BLOQUEO_FECHA_INICIO;
        END;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   4) Liberar turno por usuario/tipo/ruta
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_COLA_TRANSACCIONES_ReleaseByUserType_v1
    @CODIGO_USUARIO VARCHAR(50),
    @TIPO_TRANS INT,
    @CODIGO_LIQUIDACION INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE C
       SET C.PROCESADO = 1,
           C.FECHA_FIN = GETDATE()
    FROM dbo.P_COLA_TRANSACCIONES AS C
    WHERE C.PROCESADO = 0
      AND C.CODIGO_USUARIO = @CODIGO_USUARIO
      AND C.TIPO_TRANS = @TIPO_TRANS
      AND (@CODIGO_LIQUIDACION IS NULL OR C.CODIGO_LIQUIDACION = @CODIGO_LIQUIDACION);
END;
GO

/* =========================================================
   5) Liberar turnos por lote (TVP)
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_COLA_TRANSACCIONES_ReleaseBatch_v1
    @TURNOS dbo.tvp_COLA_TRANSACCIONES_CODIGO_v1 READONLY
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE C
       SET C.PROCESADO = 1,
           C.FECHA_FIN = GETDATE()
    FROM dbo.P_COLA_TRANSACCIONES AS C
    INNER JOIN @TURNOS AS T
        ON T.CODIGO = C.CODIGO
    WHERE C.PROCESADO = 0;
END;
GO

/* =========================================================
   6) Indices recomendados para concurrencia
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_P_COLA_TRANSACCIONES_TIPO_PROC_LIQ_USR' AND object_id = OBJECT_ID('dbo.P_COLA_TRANSACCIONES'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_P_COLA_TRANSACCIONES_TIPO_PROC_LIQ_USR
    ON dbo.P_COLA_TRANSACCIONES (TIPO_TRANS, PROCESADO, CODIGO_LIQUIDACION, CODIGO_USUARIO)
    INCLUDE (FECHA_INICIO, FECHA_FIN);
END;
GO
