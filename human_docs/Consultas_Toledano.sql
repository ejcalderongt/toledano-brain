select * from MI3_SAP where CODIGOLIQUIDACION = 245699 and CODIGOOPERACION = 24

select * from D_FACTURA where CODIGOLIQUIDACION = 245699

select * from P_NOTACD where CODIGOLIQUIDACION = 245699
select * from P_RAZON_NCD
select * from D_NOTACRED where CODIGOLIQUIDACION = 245699

select * from D_CxC where CODIGOLIQUIDACION = 245699

select distinct ruta from p_cliruta where CLIENTE = '0001000230'
select * from DS_PEDIDO where ruta = '0050-1' and fecha = '20230302'

--update DS_PEDIDO set FECHA = '20230305', FECHAENTR = '20230305', BANDERA = 'N', STATCOM = 'N' where ruta = '0050-1' and fecha = '20230305'
--update P_STOCK set FECHA = '20230302' where ruta = '0050-1' and fecha = '20230305' and CODIGOLIQUIDACION = 245698
--update P_STOCKB set FECHA = '20230302' where ruta = '0050-1' and fecha = '20230305'  and CODIGOLIQUIDACION = 245698

select * from P_STOCK  where ruta = '0050-1' and fecha = '20230305'

--update P_STOCK set CODIGOLIQUIDACION = -1 where ruta = '0050-1' and fecha = '20230305' 
--update P_STOCKB set CODIGOLIQUIDACION = -1 where ruta = '0050-1' and fecha = '20230305' 





select * from DS_PEDIDOD where corel in(
select COREL from DS_PEDIDO where ruta = '0050-1' and fecha = '20230302')

select * from p_cliente where CODIGO in (select cliente  from D_FACTURA where CERTIFICADA_DGI = 1 and fecha >='20230301') and MEDIAPAGO = 4

select * from D_FACTURA_CONTROL_CONTINGENCIA where CODIGOLIQUIDACION = 245699

select * from P_SUCURSAL 
select * from P_EMPRESA
select * from P_CIUDAD 

ALTER TABLE P_SUCURSAL ADD SITIO_WEB NVARCHAR(500) NULL
ALTER TABLE P_SUCURSAL ALTER COLUMN NOMBRE NVARCHAR(200) NULL

--update P_SUCURSAL set NOMBRE = 'FE generada en ambiente de pruebas - sin valor comercial ni fiscal'
--update P_SUCURSAL set sitio_web = 'http://www.toledano.com'

"FE generada en ambiente de pruebas - sin valor comercial ni fiscal"

--update p_Stock set FECHA = '20230305' where ruta = '1002-3' and FECHA >= '20230301'

--update p_corel set CORELULT  =400 where RUTA = '1002-3' 

