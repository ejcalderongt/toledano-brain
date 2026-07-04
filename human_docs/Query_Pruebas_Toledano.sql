select distinct ruta, fecha, DOCUMENTO from p_stockb where codigoliquidacion = -1
and ruta in (select codigo from p_ruta where codigo in (
select distinct ruta from p_stockb where codigoliquidacion = -1 and status = 'A')
and venta = 'D') and status = 'A' and ruta = '0002-1' and FECHA = '20240909'

update DS_PEDIDO set FECHA = '20250114' where ruta = '0002-1' and fecha = '20250113'
update p_stockb set FECHA = '20250114', ENVIADO = 0, COREL_D_MOV = '', CODIGOLIQUIDACION = 0 where DOCUMENTO = '0800637054'
update p_stock set FECHA = '20250114', ENVIADO = 0, COREL_D_MOV = '', CODIGOLIQUIDACION = 0 where DOCUMENTO = '0800637054'

select * from p_stockb where DOCUMENTO = '0800637054'

000100050424785941
000100050424785943
000100050424785944
000100050424785945
000100050424785946
000100050424785960