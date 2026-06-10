SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF TYPE_ID(N'dbo.tvp_LiqVendInvItems_v1') IS NULL
BEGIN
    CREATE TYPE dbo.tvp_LiqVendInvItems_v1 AS TABLE
    (
        PRODUCTO VARCHAR(25) NOT NULL,
        LOTE VARCHAR(30) NOT NULL,
        ES_CANASTA BIT NOT NULL,
        PRIMARY KEY (PRODUCTO, LOTE)
    );
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LiqVend_InventarioRuta_Detalle_v1
    @Fecha DATE,
    @Ruta VARCHAR(20),
    @Vendedor VARCHAR(20),
    @CodigoLiquidacion INT,
    @Items dbo.tvp_LiqVendInvItems_v1 READONLY
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH It AS
    (
        SELECT PRODUCTO, LOTE, ES_CANASTA
        FROM @Items
    ),
    VentasFactSinLote AS
    (
        SELECT I.PRODUCTO,
               I.LOTE,
               FD.UMVENTA AS UM,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(FD.CANT,0))) AS CANTIDAD_VENDIDA,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(FD.PESO,0))) AS PESO_VENDIDO
        FROM It I
        INNER JOIN D_FACTURAD FD ON FD.PRODUCTO = I.PRODUCTO
        INNER JOIN D_FACTURA F ON F.COREL = FD.COREL
        WHERE I.LOTE = ''
          AND I.ES_CANASTA = 0
          AND F.FECHA = @Fecha
          AND F.VENDEDOR = @Vendedor
          AND F.RUTA = @Ruta
          AND F.ANULADO = 'N'
          AND F.CODIGOLIQUIDACION = @CodigoLiquidacion
        GROUP BY I.PRODUCTO, I.LOTE, FD.UMVENTA
    ),
    VentasBonifSinLote AS
    (
        SELECT I.PRODUCTO,
               I.LOTE,
               B.UMVENTA AS UM,
               COUNT(BB.BARRA) AS CANTIDAD_VENDIDA,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(BB.PESO,0))) AS PESO_VENDIDO
        FROM It I
        INNER JOIN D_BONIF B ON B.PRODUCTO = I.PRODUCTO AND B.RUTA = @Ruta AND B.FECHA = @Fecha AND B.ANULADO = 'N'
        INNER JOIN D_BONIF_BARRA BB ON BB.COREL = B.COREL AND BB.PRODUCTO = B.PRODUCTO
        WHERE I.LOTE = ''
          AND I.ES_CANASTA = 0
          AND EXISTS
          (
              SELECT 1
              FROM D_FACTURA F
              WHERE F.COREL = B.COREL
                AND F.FECHA = @Fecha
                AND F.VENDEDOR = @Vendedor
                AND F.RUTA = @Ruta
                AND F.ANULADO = 'N'
                AND F.CODIGOLIQUIDACION = @CodigoLiquidacion
          )
        GROUP BY I.PRODUCTO, I.LOTE, B.UMVENTA
    ),
    VentasFactLote AS
    (
        SELECT I.PRODUCTO,
               I.LOTE,
               FD.UMVENTA AS UM,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(FL.CANTIDAD,0))) AS CANTIDAD_VENDIDA,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(FL.PESO,0))) AS PESO_VENDIDO
        FROM It I
        INNER JOIN D_FACTURAD FD ON FD.PRODUCTO = I.PRODUCTO
        INNER JOIN D_FACTURAD_LOTES FL ON FL.COREL = FD.COREL AND FL.PRODUCTO = FD.PRODUCTO AND FL.LOTE = I.LOTE
        INNER JOIN D_FACTURA F ON F.COREL = FD.COREL
        WHERE I.LOTE <> ''
          AND I.ES_CANASTA = 0
          AND F.FECHA = @Fecha
          AND F.VENDEDOR = @Vendedor
          AND F.RUTA = @Ruta
          AND F.ANULADO = 'N'
          AND F.CODIGOLIQUIDACION = @CodigoLiquidacion
        GROUP BY I.PRODUCTO, I.LOTE, FD.UMVENTA
    ),
    VentasBonifLote AS
    (
        SELECT I.PRODUCTO,
               I.LOTE,
               BL.UMVENTA AS UM,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(BL.CANT,0))) AS CANTIDAD_VENDIDA,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(BL.PESO,0))) AS PESO_VENDIDO
        FROM It I
        INNER JOIN D_BONIF B ON B.PRODUCTO = I.PRODUCTO AND B.RUTA = @Ruta AND B.FECHA = @Fecha AND B.ANULADO = 'N'
        INNER JOIN D_BONIF_LOTES BL ON BL.COREL = B.COREL AND BL.PRODUCTO = B.PRODUCTO
        WHERE I.LOTE <> ''
          AND I.ES_CANASTA = 0
          AND EXISTS
          (
              SELECT 1
              FROM D_FACTURA F
              WHERE F.COREL = B.COREL
                AND F.FECHA = @Fecha
                AND F.VENDEDOR = @Vendedor
                AND F.RUTA = @Ruta
                AND F.ANULADO = 'N'
                AND F.CODIGOLIQUIDACION = @CodigoLiquidacion
          )
        GROUP BY I.PRODUCTO, I.LOTE, BL.UMVENTA
    ),
    VentasCanasta AS
    (
        SELECT I.PRODUCTO,
               I.LOTE,
               C.UNIDBAS AS UM,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(C.CANTENTR,0))) AS CANTIDAD_VENDIDA,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(C.PESOENTR,0))) AS PESO_VENDIDO
        FROM It I
        INNER JOIN D_CANASTA C ON C.PRODUCTO = I.PRODUCTO
        WHERE I.ES_CANASTA = 1
          AND C.ANULADO = 0
          AND C.CODIGOLIQUIDACION = @CodigoLiquidacion
          AND C.RUTA = @Ruta
          AND CONVERT(DATE, C.FECHA) = @Fecha
        GROUP BY I.PRODUCTO, I.LOTE, C.UNIDBAS
    ),
    VentasAll AS
    (
        SELECT * FROM VentasFactSinLote
        UNION ALL
        SELECT * FROM VentasBonifSinLote
        UNION ALL
        SELECT * FROM VentasFactLote
        UNION ALL
        SELECT * FROM VentasBonifLote
        UNION ALL
        SELECT * FROM VentasCanasta
    ),
    DevStock AS
    (
        SELECT I.PRODUCTO,
               I.LOTE,
               S.UNIDADMEDIDA AS UM,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(S.CANT,0))) AS CANTIDAD_DEVUELTA,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(S.PESO,0))) AS PESO_DEVUELTO
        FROM It I
        INNER JOIN P_STOCK S ON S.CODIGO = I.PRODUCTO
        WHERE S.ANULADO = 0
          AND S.RUTA = @Ruta
          AND DATEDIFF(DAY, S.FECHA, @Fecha) = 0
          AND S.STATUS IN ('B','C')
          AND S.CODIGOLIQUIDACION = @CodigoLiquidacion
          AND S.LOTE = I.LOTE
        GROUP BY I.PRODUCTO, I.LOTE, S.UNIDADMEDIDA
    ),
    DevPalletLote AS
    (
        SELECT I.PRODUCTO,
               I.LOTE,
               P.UNIDADMEDIDA AS UM,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(P.CANT,0))) AS CANTIDAD_DEVUELTA,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(P.PESO,0))) AS PESO_DEVUELTO
        FROM It I
        INNER JOIN P_STOCK_PALLET P ON P.CODIGO = I.PRODUCTO
        WHERE P.ANULADO = 0
          AND P.RUTA = @Ruta
          AND DATEDIFF(DAY, P.FECHA, @Fecha) = 0
          AND P.STATUS IN ('B','C')
          AND P.CODIGOLIQUIDACION = @CodigoLiquidacion
          AND P.LOTEPRODUCTO = I.LOTE
          AND P.LOTEPRODUCTO <> ''
        GROUP BY I.PRODUCTO, I.LOTE, P.UNIDADMEDIDA
    ),
    DevStockB AS
    (
        SELECT I.PRODUCTO,
               I.LOTE,
               B.UNIDADMEDIDA AS UM,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(B.CANT,0))) AS CANTIDAD_DEVUELTA,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(B.PESO,0))) AS PESO_DEVUELTO
        FROM It I
        INNER JOIN P_STOCKB B ON B.CODIGO = I.PRODUCTO
        WHERE B.ANULADO = 0
          AND B.RUTA = @Ruta
          AND DATEDIFF(DAY, B.FECHA, @Fecha) = 0
          AND B.STATUS IN ('B','C')
          AND B.CODIGOLIQUIDACION = @CodigoLiquidacion
        GROUP BY I.PRODUCTO, I.LOTE, B.UNIDADMEDIDA
    ),
    DevPalletSinLote AS
    (
        SELECT I.PRODUCTO,
               I.LOTE,
               P.UNIDADMEDIDA AS UM,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(P.CANT,0))) AS CANTIDAD_DEVUELTA,
               SUM(CONVERT(DECIMAL(18,6), ISNULL(P.PESO,0))) AS PESO_DEVUELTO
        FROM It I
        INNER JOIN P_STOCK_PALLET P ON P.CODIGO = I.PRODUCTO
        WHERE P.ANULADO = 0
          AND P.RUTA = @Ruta
          AND DATEDIFF(DAY, P.FECHA, @Fecha) = 0
          AND P.STATUS IN ('B','C')
          AND P.CODIGOLIQUIDACION = @CodigoLiquidacion
          AND P.LOTEPRODUCTO = ''
          AND P.BARRAPRODUCTO <> ''
        GROUP BY I.PRODUCTO, I.LOTE, P.UNIDADMEDIDA
    ),
    DevolAll AS
    (
        SELECT * FROM DevStock
        UNION ALL
        SELECT * FROM DevPalletLote
        UNION ALL
        SELECT * FROM DevStockB
        UNION ALL
        SELECT * FROM DevPalletSinLote
    )
    SELECT PRODUCTO,
           LOTE,
           UM,
           SUM(CANTIDAD_VENDIDA) AS CANTIDAD_VENDIDA,
           SUM(PESO_VENDIDO) AS PESO_VENDIDO
    FROM VentasAll
    GROUP BY PRODUCTO, LOTE, UM;

    SELECT PRODUCTO,
           LOTE,
           UM,
           SUM(CANTIDAD_DEVUELTA) AS CANTIDAD_DEVUELTA,
           SUM(PESO_DEVUELTO) AS PESO_DEVUELTO
    FROM DevolAll
    GROUP BY PRODUCTO, LOTE, UM;
END
GO

