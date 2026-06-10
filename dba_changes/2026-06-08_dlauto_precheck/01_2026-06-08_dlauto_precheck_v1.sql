SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/*
#EJC20260608-DL_AUTO
SP de precheck ligero para Generacion Automatica de DL en frmLiqVend.
Objetivo: decidir de forma temprana que pasos de DL vale la pena ejecutar.
Diseno seguro: si no se tiene certeza funcional, se mantiene TRUE para no omitir reglas de negocio.
*/
CREATE OR ALTER PROCEDURE dbo.usp_LiqVend_DLAuto_Precheck_v1
    @Fecha DATE,
    @Ruta VARCHAR(20),
    @Vendedor VARCHAR(20),
    @CodigoLiquidacion INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReqDLFP BIT = 1;   -- conservador: no saltar DL de faltante de producto
    DECLARE @ReqDLFPD BIT = 1;  -- conservador: no saltar DL de faltante de producto dañado
    DECLARE @ReqDLMNP BIT = 1;  -- conservador: no saltar DL merma no permitida
    DECLARE @ReqDLMP BIT = 1;   -- conservador: no saltar DL merma permitida
    DECLARE @ReqDLFCP BIT = 0;
    DECLARE @ReqDLFCR BIT = 0;

    /*
      Canastas: aqui si hacemos precheck real de candidatos para evitar ejecutar
      procesos completos cuando no hay movimiento en la ruta/liquidacion.
    */
    IF EXISTS
    (
        SELECT 1
        FROM D_CANASTA C
        WHERE C.RUTA = @Ruta
          AND C.VENDEDOR = @Vendedor
          AND C.CODIGOLIQUIDACION = @CodigoLiquidacion
          AND CONVERT(DATE, C.FECHA) = @Fecha
          AND ISNULL(C.ANULADO, 0) = 0
          AND ISNULL(C.CANTENTR, 0) > ISNULL(C.CANTREC, 0)
    )
        SET @ReqDLFCP = 1;

    IF EXISTS
    (
        SELECT 1
        FROM D_CANASTA C
        WHERE C.RUTA = @Ruta
          AND C.VENDEDOR = @Vendedor
          AND C.CODIGOLIQUIDACION = @CodigoLiquidacion
          AND CONVERT(DATE, C.FECHA) = @Fecha
          AND ISNULL(C.ANULADO, 0) = 0
          AND ISNULL(C.CANTREC, 0) > ISNULL(C.CANTENTR, 0)
    )
        SET @ReqDLFCR = 1;

    SELECT
        CONVERT(INT, @ReqDLFP) AS REQUIERE_DLFP,
        CONVERT(INT, @ReqDLFPD) AS REQUIERE_DLFPD,
        CONVERT(INT, @ReqDLMNP) AS REQUIERE_DLMNP,
        CONVERT(INT, @ReqDLMP) AS REQUIERE_DLMP,
        CONVERT(INT, @ReqDLFCP) AS REQUIERE_DLFCP,
        CONVERT(INT, @ReqDLFCR) AS REQUIERE_DLFCR,
        CONVERT(INT, CASE WHEN @ReqDLFP = 1 OR @ReqDLFPD = 1 THEN 1 ELSE 0 END) AS REQUIERE_RECALCULO_INVENTARIO;
END
GO
