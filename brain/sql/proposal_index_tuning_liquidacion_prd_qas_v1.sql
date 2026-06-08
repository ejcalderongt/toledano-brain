/*
#EJC20260608 mejora(liquidacion-bof): propuesta de indices post-diagnostico PRD.
NO aplicar directo en horario pico sin validar en QAS.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;

/* =========================================================
   1) P_INVENTARIO_BARRAS_RUTA
   Cuello detectado: UPDATE por CODIGOLIQUIDACION con alto avg_reads/cpu.
   Nota: actualmente CODIGOLIQUIDACION suele estar en 0; el indice filtrado
   reduce mantenimiento y acelera busquedas por codigos de liquidacion activos.
   ========================================================= */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.P_INVENTARIO_BARRAS_RUTA')
      AND name = 'IX_P_INVENTARIO_BARRAS_RUTA_CODLIQ_NZ'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_P_INVENTARIO_BARRAS_RUTA_CODLIQ_NZ
    ON dbo.P_INVENTARIO_BARRAS_RUTA (CODIGOLIQUIDACION)
    WHERE CODIGOLIQUIDACION <> 0;
END;
GO

/* =========================================================
   2) P_INVENTARIO_RUTA
   Cuello detectado: avg_elapsed alto en reset por CODIGOLIQUIDACION.
   Indices actuales no inician por CODIGOLIQUIDACION.
   ========================================================= */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.P_INVENTARIO_RUTA')
      AND name = 'IX_P_INVENTARIO_RUTA_CODLIQ'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_P_INVENTARIO_RUTA_CODLIQ
    ON dbo.P_INVENTARIO_RUTA (CODIGOLIQUIDACION);
END;
GO

/* =========================================================
   3) D_DEPOS
   Missing index report sugiere CODIGOLIQUIDACION en predicados.
   ========================================================= */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.D_DEPOS')
      AND name = 'IX_D_DEPOS_CODLIQ'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_D_DEPOS_CODLIQ
    ON dbo.D_DEPOS (CODIGOLIQUIDACION);
END;
GO

/* =========================================================
   4) P_COLA_TRANSACCIONES
   Para UPDATE por usuario en Actualizar_Procesado_By_Usuario.
   ========================================================= */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.P_COLA_TRANSACCIONES')
      AND name = 'IX_P_COLA_TRANSACCIONES_USR_PROC'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_P_COLA_TRANSACCIONES_USR_PROC
    ON dbo.P_COLA_TRANSACCIONES (CODIGO_USUARIO, PROCESADO)
    INCLUDE (FECHA_FIN, TIPO_TRANS, CODIGO_LIQUIDACION);
END;
GO

/* =========================================================
   5) Validacion rapida
   ========================================================= */
SELECT
    t.name AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.filter_definition
FROM sys.tables t
INNER JOIN sys.indexes i ON i.object_id = t.object_id
WHERE t.name IN ('P_INVENTARIO_BARRAS_RUTA','P_INVENTARIO_RUTA','D_DEPOS','P_COLA_TRANSACCIONES')
  AND i.name IN (
      'IX_P_INVENTARIO_BARRAS_RUTA_CODLIQ_NZ',
      'IX_P_INVENTARIO_RUTA_CODLIQ',
      'IX_D_DEPOS_CODLIQ',
      'IX_P_COLA_TRANSACCIONES_USR_PROC'
  )
ORDER BY t.name, i.name;
GO
