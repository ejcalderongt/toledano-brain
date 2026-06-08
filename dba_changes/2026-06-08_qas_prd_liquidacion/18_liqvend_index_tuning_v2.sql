/*
Objetivo:
- Cubrir patrones detectados en DMVs para frmLiqVend/liq concurrente.
- Evitar cambios destructivos: solo CREATE IF NOT EXISTS.
*/

SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* 1) P_STOCKB por FECHA + include de columnas de salida */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.P_STOCKB')
      AND name = 'IX_P_STOCKB_FECHA_INC_ENV_LIQ_DOC_v2'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_P_STOCKB_FECHA_INC_ENV_LIQ_DOC_v2
    ON dbo.P_STOCKB (FECHA)
    INCLUDE (ENVIADO, CODIGOLIQUIDACION, DOC_ENTREGA);
END
GO

/* 2) P_STOCK por FECHA + include de columnas de salida */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.P_STOCK')
      AND name = 'IX_P_STOCK_FECHA_INC_ENV_LIQ_DOC_v2'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_P_STOCK_FECHA_INC_ENV_LIQ_DOC_v2
    ON dbo.P_STOCK (FECHA)
    INCLUDE (ENVIADO, CODIGOLIQUIDACION, DOC_ENTREGA);
END
GO

/* 3) Cola por estado procesado/usuario para polling concurrente */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.P_COLA_TRANSACCIONES')
      AND name = 'IX_P_COLA_TRANS_PROCESADO_USR_v2'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_P_COLA_TRANS_PROCESADO_USR_v2
    ON dbo.P_COLA_TRANSACCIONES (PROCESADO, CODIGO_USUARIO)
    INCLUDE (CODIGO_LIQUIDACION, FECHA_INICIO, FECHA_FIN, TIPO_TRANS);
END
GO

/* 4) Inventario barras por ruta+barra (búsquedas por ruta/documento) */
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.P_INVENTARIO_BARRAS_RUTA')
      AND name = 'IX_P_INV_BARRAS_RUTA_BARRA_v2'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_P_INV_BARRAS_RUTA_BARRA_v2
    ON dbo.P_INVENTARIO_BARRAS_RUTA (RUTA, BARRA);
END
GO

/*
5) D_FACTURA sugerido por DMV:
   (ANULADO, EMPRESA, VENDEDOR, CODIGOLIQUIDACION)
   -> NO aplicar automático aquí por alta densidad de índices en D_FACTURA.
   -> Validar consolidación primero en QAS con plan cache/uso real.
*/

