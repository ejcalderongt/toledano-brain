/*
 #EJC20260608 docs(liquidacion-bof): propuesta base para delegar guardado de liquidacion a SQL Server usando TVP + operaciones set-based.
 Nota: script de diseno; revisar nombres/tipos exactos contra esquema real antes de desplegar.
*/

/* 1) TVP para detalle de liquidacion */
IF TYPE_ID('dbo.TvpLiquidacionDetalle') IS NULL
BEGIN
    CREATE TYPE dbo.TvpLiquidacionDetalle AS TABLE
    (
        CODIGO_LIQUIDACION INT NOT NULL,
        RUTA               VARCHAR(20) NOT NULL,
        VENDEDOR           VARCHAR(20) NOT NULL,
        FECHA              DATE NOT NULL,
        PRODUCTO           VARCHAR(30) NOT NULL,
        LOTE               VARCHAR(40) NOT NULL,
        ENT_CANT           DECIMAL(18, 4) NOT NULL,
        ENT_PESO           DECIMAL(18, 4) NOT NULL,
        ENT_PROM           DECIMAL(18, 4) NOT NULL,
        DEV_CANT           DECIMAL(18, 4) NOT NULL,
        DEV_PESO           DECIMAL(18, 4) NOT NULL,
        DEV_PROM           DECIMAL(18, 4) NOT NULL,
        VEND_CANT          DECIMAL(18, 4) NOT NULL,
        VEND_PESO          DECIMAL(18, 4) NOT NULL,
        VEND_PROM          DECIMAL(18, 4) NOT NULL,
        RES_CANT           DECIMAL(18, 4) NOT NULL,
        RES_PESO           DECIMAL(18, 4) NOT NULL,
        RES_MERMA          DECIMAL(18, 4) NOT NULL,
        PESO_MERMA_PERM    DECIMAL(18, 4) NOT NULL,
        PESO_MERMA_NO_PERM DECIMAL(18, 4) NOT NULL,
        PORC_MERMA_PROD    DECIMAL(18, 4) NOT NULL,
        PORC_MAX_REPESAJE  DECIMAL(18, 4) NOT NULL,
        TOTAL_PESO_MERMAS  DECIMAL(18, 4) NOT NULL,
        UNIDADMEDIDA       VARCHAR(10) NOT NULL
    );
END;
GO

/* 2) Procedimiento batch propuesto */
CREATE OR ALTER PROCEDURE dbo.usp_Liquidacion_GuardarBatch_v1
    @CodigoLiquidacion INT,
    @FechaLiquidacion  DATE,
    @Ruta              VARCHAR(20),
    @Vendedor          VARCHAR(20),
    @Sucursal          VARCHAR(10),
    @CorelDMov         VARCHAR(30),
    @TotalContado      DECIMAL(18, 4),
    @TotalCredito      DECIMAL(18, 4),
    @TotalCobros       DECIMAL(18, 4),
    @TotalNcyd         DECIMAL(18, 4),
    @TotalDevolNc      DECIMAL(18, 4),
    @MontoSlip         DECIMAL(18, 4),
    @Ref               VARCHAR(100) = '',
    @Observacion       VARCHAR(500) = '',
    @CodigoRazonPend   VARCHAR(20) = '',
    @EnviarASap        BIT = 0,
    @Det               dbo.TvpLiquidacionDetalle READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        /* Header */
        UPDATE P_LIQUIDACION
           SET TOTALCONTADO = ROUND(@TotalContado, 2),
               TOTALCREDITO = ROUND(@TotalCredito, 2),
               TOTALCOBROS = ROUND(@TotalCobros, 2),
               TOTALNCYD = ROUND(@TotalNcyd, 2),
               TOTALDEVOLNC = ROUND(@TotalDevolNc, 2),
               MONTO_SLIP = @MontoSlip,
               SUCURSAL = @Sucursal,
               REF = @Ref,
               OBSERVACION = @Observacion,
               CODIGO_RAZON_PENDIENTE = @CodigoRazonPend,
               CORELDMOV = CASE WHEN ISNULL(CORELDMOV, '') = '' THEN @CorelDMov ELSE CORELDMOV END,
               ENVIAR_A_SAP = CASE WHEN @EnviarASap = 1 THEN 1 ELSE ENVIAR_A_SAP END
         WHERE CODIGO = @CodigoLiquidacion
           AND RUTA = @Ruta
           AND VENDEDOR = @Vendedor
           AND FECHA = @FechaLiquidacion;

        /* Detalle */
        DELETE FROM P_LIQUIDACION_DET
         WHERE CODIGO = @CodigoLiquidacion;

        INSERT INTO P_LIQUIDACION_DET
        (
            CODIGO, RUTA, VENDEDOR, FECHA, PRODUCTO, LOTE,
            ENT_CANT, ENT_PESO, ENT_PROM, DEV_CANT, DEV_PESO, DEV_PROM,
            VEND_POLLOS, VEND_CANT, VEND_PESO, VEND_PROM, RES_CANT, RES_PESO,
            RES_MERMA, PESOMERMAPERMITIDA, PESOMERMANOPERMITIDA, PORCENTAJEMERMAPRODUCTO,
            PORCENTAJEMAXIMOREPESAJE, TOTALPESOMERMAS, UNIDADMEDIDA
        )
        SELECT
            CODIGO_LIQUIDACION, RUTA, VENDEDOR, FECHA, PRODUCTO, LOTE,
            ENT_CANT, ENT_PESO, ENT_PROM, DEV_CANT, DEV_PESO, DEV_PROM,
            0, VEND_CANT, VEND_PESO, VEND_PROM, RES_CANT, RES_PESO,
            RES_MERMA, PESO_MERMA_PERM, PESO_MERMA_NO_PERM, PORC_MERMA_PROD,
            PORC_MAX_REPESAJE, TOTAL_PESO_MERMAS, UNIDADMEDIDA
        FROM @Det;

        /* Documentos set-based */
        UPDATE D_FACTURA
           SET CODIGOLIQUIDACION = @CodigoLiquidacion
         WHERE FECHA = @FechaLiquidacion
           AND VENDEDOR = @Vendedor
           AND RUTA = @Ruta
           AND CODIGOLIQUIDACION = 0;

        UPDATE D_COBRO
           SET CODIGOLIQUIDACION = @CodigoLiquidacion
         WHERE FECHA = @FechaLiquidacion
           AND VENDEDOR = @Vendedor
           AND RUTA = @Ruta
           AND CODIGOLIQUIDACION = 0;

        UPDATE D_CXC
           SET CODIGOLIQUIDACION = @CodigoLiquidacion
         WHERE FECHA = @FechaLiquidacion
           AND VENDEDOR = @Vendedor
           AND RUTA = @Ruta
           AND CODIGOLIQUIDACION = 0;

        UPDATE D_NOTACRED
           SET CODIGOLIQUIDACION = @CodigoLiquidacion
         WHERE FECHA >= CAST(@FechaLiquidacion AS DATETIME)
           AND FECHA < DATEADD(DAY, 1, CAST(@FechaLiquidacion AS DATETIME))
           AND VENDEDOR = @Vendedor
           AND RUTA = @Ruta
           AND CODIGOLIQUIDACION = 0;

        UPDATE P_NOTACD
           SET CODIGOLIQUIDACION = @CodigoLiquidacion
         WHERE FECHA = @FechaLiquidacion
           AND RUTA = @Ruta
           AND CODIGOLIQUIDACION = 0;

        UPDATE D_DEPOS
           SET CODIGOLIQUIDACION = @CodigoLiquidacion
         WHERE FECHA = @FechaLiquidacion
           AND RUTA = @Ruta
           AND ANULADO = 'N'
           AND CODIGOLIQUIDACION = 0;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH;
END;
GO

/*
Indices sugeridos (validar existencia y cardinalidad real):
1) D_FACTURA(FECHA, VENDEDOR, RUTA, CODIGOLIQUIDACION)
2) D_COBRO(FECHA, VENDEDOR, RUTA, CODIGOLIQUIDACION)
3) D_CXC(FECHA, VENDEDOR, RUTA, CODIGOLIQUIDACION)
4) D_NOTACRED(FECHA, VENDEDOR, RUTA, CODIGOLIQUIDACION)
5) P_NOTACD(FECHA, RUTA, CODIGOLIQUIDACION)
6) D_DEPOS(FECHA, RUTA, CODIGOLIQUIDACION, ANULADO)
*/
