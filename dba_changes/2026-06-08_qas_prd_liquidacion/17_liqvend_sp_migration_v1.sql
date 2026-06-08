/*
Objetivo:
- Reducir roundtrips y SQL inline en frmLiqVend.
- Mantener compatibilidad (objetos nuevos versionados, sin romper legacy).
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_LiqVend_GetRutaDisponible_v1
    @Vendedor VARCHAR(20),
    @Empresa VARCHAR(10),
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH CTE_RUTA AS
    (
        SELECT TOP (1) RUTA, CAST('FACTURA' AS VARCHAR(20)) AS ORIGEN, 1 AS PRIORIDAD
        FROM D_FACTURA WITH (READUNCOMMITTED)
        WHERE VENDEDOR = @Vendedor
          AND EMPRESA = @Empresa
          AND FECHA >= @Fecha
          AND FECHA < DATEADD(DAY, 1, @Fecha)
          AND CODIGOLIQUIDACION = 0
          AND ANULADO = 'N'
        UNION ALL
        SELECT TOP (1) RUTA, CAST('COBRO' AS VARCHAR(20)) AS ORIGEN, 2 AS PRIORIDAD
        FROM D_COBRO WITH (READUNCOMMITTED)
        WHERE VENDEDOR = @Vendedor
          AND EMPRESA = @Empresa
          AND FECHA >= @Fecha
          AND FECHA < DATEADD(DAY, 1, @Fecha)
          AND CODIGOLIQUIDACION = 0
          AND ANULADO = 'N'
        UNION ALL
        SELECT TOP (1) RUTA, CAST('NOTA_CREDITO' AS VARCHAR(20)) AS ORIGEN, 3 AS PRIORIDAD
        FROM D_NOTACRED WITH (READUNCOMMITTED)
        WHERE VENDEDOR = @Vendedor
          AND FECHA >= @Fecha
          AND FECHA < DATEADD(DAY, 1, @Fecha)
          AND CODIGOLIQUIDACION = 0
          AND ANULADO = 'N'
    )
    SELECT TOP (1) RUTA, ORIGEN
    FROM CTE_RUTA
    ORDER BY PRIORIDAD ASC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LiqVend_TieneCorelDmov_v1
    @Ruta VARCHAR(25),
    @Usuario VARCHAR(20) = NULL,
    @Fecha DATE,
    @SoloNoCerradas BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) D.COREL
    FROM D_MOV D WITH (READUNCOMMITTED)
    WHERE D.RUTA = @Ruta
      AND (@Usuario IS NULL OR D.USUARIO = @Usuario)
      AND D.FECHA >= @Fecha
      AND D.FECHA < DATEADD(DAY, 1, @Fecha)
      AND D.TIPO = 'D'
      AND D.ANULADO = 'N'
      AND NOT EXISTS
      (
          SELECT 1
          FROM P_LIQUIDACION L WITH (READUNCOMMITTED)
          WHERE L.CORELDMOV = D.COREL
            AND (@SoloNoCerradas = 0 OR L.ESTADO = 'CERRADA')
      );
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LiqVend_RutaLiquidando_v1
    @Ruta VARCHAR(25),
    @Fecha DATE,
    @Sucursal VARCHAR(10),
    @CorelDmov VARCHAR(25) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) L.CODIGO
    FROM P_LIQUIDACION L WITH (READUNCOMMITTED)
    WHERE L.RUTA = @Ruta
      AND L.FECHA >= @Fecha
      AND L.FECHA < DATEADD(DAY, 1, @Fecha)
      AND L.ESTADO <> 'CERRADA'
      AND L.SUCURSAL = @Sucursal
      AND (@CorelDmov IS NULL OR @CorelDmov = '' OR L.CORELDMOV = @CorelDmov)
    ORDER BY L.CODIGO DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LiqVend_RutaTieneHH_v1
    @Vendedor VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
           CAST(CASE WHEN R.SEMANA = 0 THEN 0 ELSE 1 END AS BIT) AS TIENE_HH
    FROM VENDEDORES V WITH (READUNCOMMITTED)
    INNER JOIN P_RUTA R WITH (READUNCOMMITTED) ON V.RUTA = R.CODIGO
    WHERE V.CODIGO = @Vendedor;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LiqVend_RutaFacturoManual_v1
    @Ruta VARCHAR(25),
    @CodigoVendedor VARCHAR(20),
    @FechaLiquidacion DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1) 1 AS EXISTE
    FROM P_RUTAS_FM WITH (READUNCOMMITTED)
    WHERE RUTA = @Ruta
      AND CODIGOVENDEDOR = @CodigoVendedor
      AND FECHALIQUIDACION >= @FechaLiquidacion
      AND FECHALIQUIDACION < DATEADD(DAY, 1, @FechaLiquidacion)
      AND CODIGOLIQUIDACION = 0;
END
GO

