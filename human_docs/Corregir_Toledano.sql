use roadsap
--select * FROM D_STOCKB_DEV WHERE COREL IN (SELECT COREL FROM D_FACTURA WHERE ANULADO = 'S')
select numversion, count(numversion) cant from p_ruta where codigo = '8021-1' group by numversion

select * from P_LIQUIDACION where ruta  = '0065-1' and fecha = '20241220'
select * from D_FACTURA where ruta  = '3007-1' and fecha = '20241216' --and CORELATIVO = 12376
select * from D_FACTURA where CORELATIVO = 12376
select * from D_STOCKB_DEV where  corel = '3007-1_241216070659'

select * from P_STOCKB where barra in ('002110160412019052','002110200440434098')

select  PRODUCTO, SUM(CANT)CANT,COREL, sum(peso)
from D_FACTURAD WHERE COREL IN 
(SELECT DISTINCT COREL 
 FROM D_STOCKB_DEV 
 WHERE COREL IN (SELECT COREL FROM D_FACTURA WHERE ruta = '3002-1'  and fecha ='20250215' ))
 and producto in (select codigo from p_producto where es_prod_barra = 1)
--AND PRODUCTO in('0107')
 GROUP BY  PRODUCTO,COREL
 order by COREL
 --0052	5
 SELECT CODIGO, COUNT(BARRA)CANT,COREL, sum(peso)
 FROM D_STOCKB_DEV 
 WHERE COREL IN (SELECT COREL FROM D_FACTURA WHERE ruta = '3002-1' and fecha = '20250215')
--AND CODIGO in('0107')
 and codigo in (select codigo from p_producto where es_prod_barra = 1)
 GROUP BY  CODIGO,COREL
  order by COREL

select * from p_liquidacion where ruta = '8026-1' and fecha = '20250207'
select *  from D_STOCKB_DEV WHERE corel = '0005-1_241220115752' and CODIGO = '0052'

select * from D_MOV where ruta = '1002-3' and fecha = '20250203'
select * from D_MOVDB where corel = '1002-3_250203182949' and PRODUCTO = '0211'

select * from D_MOVDB  where corel = '0065-1_241230184003' and PRODUCTO = '0728'
--update p_Stockb set enviado = 0, corel_d_mov = '' where ruta = '0065-1' and fecha = '20241130' and codigo = '0728'
--and barra not in (select barra from D_STOCKB_DEV)
select * from p_Stockb where ruta = '8042-1' and fecha = '20250124' and codigo in('0021', '0052') and STATUS = 'A'
and barra not in (select barra from D_STOCKB_DEV) and codigo IN ('0021','0220')
and BARRA in (select barra from D_MOVDB  where corel = '0065-1_241230184003' and PRODUCTO = '0728')

select * from D_STOCKB_DEV where ruta = '8042-1' and fecha = '20250124' and codigo in('0021', '0052')
select * from D_STOCKB_DEV where barra in (select BARRA from p_Stockb where ruta = '8042-1' and fecha = '20250124' and codigo in('0021', '0052') and STATUS = 'A')

select * from P_STOCKB where barra = '000520070440633056'
0211	4	4051-6_241212074656
0777	1	4051-6_241212083009
  select * from D_STOCKB_DEV where barra in (select barra from p_stockb where codigo = '0052'  and ruta = '0005-1' and fecha = '20241220' and status ='A')
    --select * from D_FACTURA where serie = '132' and corelativo = 2951 
	order by BARRA

select * from p_stockb where codigo = '0728'  and ruta = '8039-1' and fecha = '20250129' and status ='A'
and BARRA not in (SELECT BARRA FROM D_STOCKB_DEV where ruta = '8039-1' and fecha = '20250129')
and barra not in (select barra from p_stockb where codigo = '0004'  and ruta = '8038-1' 
and fecha = '20250129' and status <>'A')
order by BARRA

--update p_stockb set ENVIADO =0, COREL_D_MOV = '' where codigo = '0728'  and ruta = '8039-1' and fecha = '20250129' and status ='A'
--and BARRA not in (SELECT BARRA FROM D_STOCKB_DEV where ruta = '8039-1' and fecha = '20250129')

select * from p_stockb where codigo = '0041'  and ruta = '8039-1' and fecha = '20250102' and status='A'
and BARRA not in (SELECT BARRA FROM D_STOCKB_DEV where ruta = '8039-1' and fecha = '20250102')
and barra not in (select barra from p_stockb where codigo = '0041'  and ruta = '8039-1' and fecha = '20250102' and status <>'A')
order by BARRA

 --and STATUS = 'A' AND FECHA = '20241128' and BARRA NOT in (SELECT BARRA FROM D_STOCKB_DEV)
 select * from D_STOCKB_DEV where barra = '000520080436901758'
 select * from p_stockb where barra = '000520080436901758'
 select 6.65 +7.01+7.53+6.98+6.92+6.91,41.9-42.0

--UPDATE P_STOCKB SET ENVIADO =0, COREL_D_MOV = '' WHERE ruta = '8060-1' and fecha = '20241213' and STATUS = 'A'

SELECT * FROM p_Stockb WHERE DOCUMENTO = '0800898300' and STATUS = 'A'

SELECT * FROM P_INVENTARIO_BARRAS_RUTA WHERE  ruta = '8023-1' and producto = '0056' and fecha = '20241130'
SELECT * FROM p_Stockb WHERE ruta = '6036-5' and fecha = '20250208' and STATUS = 'A'
and barra not in (select barra from D_STOCKB_DEV)
and barra not in(select barra from p_Stockb WHERE ruta = '8082-1' and fecha = '20241213' and STATUS <> 'A')
SELECT * FROM D_FACTURA WHERE ruta = '8082-1' and fecha = '20241213'
SELECT * FROM D_MOV WHERE ruta = '8082-1' and fecha = '20241213'
SELECT * FROM P_LIQUIDACION WHERE ruta = '8082-1' and fecha = '20241213'

select * from P_LIQUIDACION where ruta = '8028-1' and fecha = '20241223'
select * 
--drop table mi3_Sap337323
from MI3_SAP where codigoliquidacion = 337323 --132

--Update MI3_SAP set estatus = 'T' where codigoliquidacion = 337323 --132

select * from p_stockb where DOCUMENTO like '%0800833373'
select * from p_stock where DOCUMENTO like '%0800833373'
--update p_stock set ENVIADO = 0, COREL_D_MOV = '', CODIGOLIQUIDACION = 0 where DOCUMENTO like '%0800833373'

--delete from d_stockb_dev where corel = '3002-1_250215081748' and CODIGO IN( '0107')
0107	1	3002-1_250215081748

select * from P_DEVOLUCIONES_SAP where COREL = '8026-1_250208132734' and PRODUCTO = '0071'
select * from P_STOCKB where ruta = '8026-1' and fecha = '20250208' and STATUS = 'A' and CODIGO = '0071'

--update P_STOCKB set ENVIADO = 0, COREL_D_MOV = '' 
--where barra IN( '000710040442108678','000710040442108679','000710040442108680','000710110442141855','000710170441902892')
--and ruta = '8026-1' 
--and fecha = '20250208' and STATUS = 'A' and CODIGO = '0071'

select * from DS_PEDIDOD where corel = '0021343447'

select numversion, * from P_RUTA where codigo like '0065%' 

select * from d_factura WHERE  (RUTA = '0067-1') AND (FECHA = '20241221')
select * from d_facturad WHERE  (COREL = '8042-1_250124150928')
select * from d_factura WHERE  (COREL = '8042-1_250124150928')

select * from d_mov WHERE  (RUTA = '8042-1') AND (FECHA = '20250124')
select * from D_MOVDB where corel ='8042-1_250124184710' and PRODUCTO in ('0021','0052')
select * from P_DEVOLUCIONES_SAP where corel ='8042-1_250124184710' and PRODUCTO in ('0021','0052')
select * from P_DEVOLUCIONES_SAP where (RUTA = '8044-1') AND (FECHA = '20250123')
exec [dbo].[DEVOLUCION_HU_PDA] '20250123','20250123','8044-1'

select * from D_FACTURA where CUFE = 'FE0120000000894-57-103790-6739052025012500000079149990110724976924'
select * from D_CxC where COREL = '1002423'
select * from tmp_liquidacion where(RUTA = '8042-1') AND (FECHA = '20250124')
--update p_Stockb set unidadmedida = 'CA' WHERE  (RUTA = '8082-1') AND (FECHA = '20241130') and status = 'D'
select * from p_Stock WHERE  (RUTA = '8082-1') AND (FECHA = '20241130') and status <> 'A'

select * from d_notacred WHERE  (RUTA = '8082-1') AND (FECHA = '20241130') 
select * from d_notacredd WHERE  corel in (select corel from d_notacred WHERE  (RUTA = '8082-1') AND (FECHA = '20241130'))
and producto = '0053'

select * from d_factura where corel = '8023-1_241130081243'
select * from d_facturad where corel = '8023-1_241130081243'

--update p_corel set corelult = 7583 where ruta = '8045-1'
select * from p_corel where ruta = '8045-1'4

--update p_Stockb set ENVIADO = 0,COREL_D_MOV = '' where codigo = '0041'  and ruta = '8039-1' and fecha = '20250102' and status='A'
--and BARRA not in (SELECT BARRA FROM D_STOCKB_DEV where ruta = '8039-1' and fecha = '20250102')
--and barra not in (select barra from p_stockb where codigo = '0041'  and ruta = '8039-1' and fecha = '20250102' and status <>'A')

--SELECT * FROM p_Stockb WHERE ruta = '8210-1' and fecha = '20241206' and STATUS = 'A'
and barra not in (select barra from D_STOCKB_DEV)
and barra not in (SELECT barra FROM p_Stockb WHERE ruta = '8210-1' and fecha = '20241206' and STATUS <> 'A')

--update P_STOCKB set UNIDADMEDIDA = 'BOL' where ruta = '4504-6' and fecha = '20241204' and UNIDADMEDIDA = '' 
--AND CODIGO IN ('0052','0021')

--select  distinct CODIGO, UNIDADMEDIDA from P_STOCKB where codigo	in (select distinct CODIGO from P_STOCKB where ruta = '4504-6' and fecha = '20241204' and UNIDADMEDIDA = ''
--) and UNIDADMEDIDA <> ''

select  * from p_stockb where ruta = '8105-1' and fecha = '20250103' --and codigo = '0103'
and barra not in (select barra from D_STOCKB_DEV) and codigo IN ('0103')
and barra not in (select barra from P_STOCKB where STATUS <>'A' and ruta = '8105-1' and fecha = '20250103'
and codigo IN ('0103'))


select numversion, * from p_ruta where CODIGO = '8041-1'

--update p_stockb set ENVIADO =0, COREL_D_MOV = '' where ruta = '8105-1' and fecha = '20250103' --and codigo = '0103'
--and barra not in (select barra from D_STOCKB_DEV) and codigo IN ('0103')
--and barra not in (select barra from P_STOCKB where STATUS <>'A' and ruta = '8105-1' and fecha = '20250103'
--and codigo IN ('0103'))


select * from d_factura where ruta = '8021-1' and fecha = '20250113'

select * from P_STOCKB where ruta = '8007-1' and fecha = '20250110' and CODIGO = '0846'