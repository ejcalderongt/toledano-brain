--select * 
--into mi3_sap_1004
--from MI3_SAP where CODIGOLIQUIDACION = 284070

--update MI3_SAP set ESTATUS = 'N' where CODIGOLIQUIDACION = 284070 and ESTATUS = 'T' -- 324

select r.SUCURSAL Agencia, f.Ruta, + r.NOMBRE Nombre_Ruta, f.Fecha, f.Vendedor, v.NOMBRE Nombre_Vendedor,
      f.Cliente, c.NOMBRE Nombre_Cliente,
      f.Serie + RIGHT('000000'+ CONVERT(NVARCHAR(6), f.CORELATIVO),6) [Número de factura], f.TOTAL Monto, 
	  f.ASIGNACION [Número de nota de crédito]
from D_FACTURA f INNER JOIN P_RUTA r ON f.RUTA = r.CODIGO
     INNER JOIN P_VENDEDOR v ON f.VENDEDOR = v.CODIGO 
	 INNER JOIN P_CLIENTE c ON f.CLIENTE = c.CODIGO
where ANULADO = 'S' and fecha >='20230601' and f.COREL not in (select corel from D_FACTURAP where CODPAGO = 4)

select r.SUCURSAL Agencia, f.Fecha, f.Ruta, r.NOMBRE Nombre_Ruta, f.Vendedor, v.NOMBRE Nombre_Vendedor,
	  SUM(CASE WHEN f.ANULADO = 'N' THEN 1 ELSE 0 END) EMITIDAS,
      SUM(CASE WHEN f.ANULADO = 'S' THEN 1 ELSE 0 END) ANULADAS 
from D_FACTURA f INNER JOIN P_RUTA r ON f.RUTA = r.CODIGO
     INNER JOIN P_VENDEDOR v ON f.VENDEDOR = v.CODIGO 
	 INNER JOIN P_CLIENTE c ON f.CLIENTE = c.CODIGO
where fecha >='20230601' and f.COREL not in (select corel from D_FACTURAP where CODPAGO = 4)
group by r.SUCURSAL, f.Ruta, r.NOMBRE, f.Fecha, f.Vendedor, v.NOMBRE

select * from D_FACTURA where serie = '303' and CORELATIVO = 1116
select * from D_FACTURAD where COREL = '1004-3_230608145802'
select * from D_FACTURAP where COREL = '1004-3_230608145802'