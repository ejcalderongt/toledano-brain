SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/*
#EJC20260608
Consolida updates de cabecera para DL de merma (permitida/no permitida)
en un solo paso transaccional.
*/
CREATE OR ALTER PROCEDURE dbo.usp_LiqVend_DL_Merma_Finaliza_v1
    @CodigoLiquidacion INT,
    @Ruta VARCHAR(20),
    @Vendedor VARCHAR(20),
    @CodigoDL INT,
    @EsNoPermitida BIT,
    @Valor DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @EsNoPermitida = 1
    BEGIN
        UPDATE P_LIQUIDACION
           SET CODIGODLMNP = @CodigoDL
         WHERE CODIGO = @CodigoLiquidacion
           AND RUTA = @Ruta
           AND VENDEDOR = @Vendedor;
    END
    ELSE
    BEGIN
        UPDATE P_LIQUIDACION
           SET CODIGODLMP = @CodigoDL
         WHERE CODIGO = @CodigoLiquidacion
           AND RUTA = @Ruta
           AND VENDEDOR = @Vendedor;
    END

    UPDATE TEMP_P_DIFLIQ
       SET VALOR = @Valor
     WHERE CODIGO = @CodigoDL
       AND CODIGO_LIQUIDACION = @CodigoLiquidacion;
END
GO
