SELECT distinct 'Ventas al crédito' as Tipo,#DOC_VENTAS.fecha,corel as DOCUMENTO, cliente, ISNULL(p_cliente.nombre, 'CLIENTE NUEVO') AS NOMBRE, round( total,2) as total, 
'' as TipoNota, #DOC_VENTAS.ruta, #DOC_VENTAS.nombre, #DOC_VENTAS.referencia
from #DOC_VENTAS LEFT OUTER join p_cliente
on p_cliente.codigo =#DOC_VENTAS.cliente
where credito = 1 AND NOT #DOC_VENTAS.SERIE = '998' AND NOT #DOC_VENTAS.SERIE = 'DL' 
union
select distinct 'Ventas al contado' as Tipo,#DOC_VENTAS.fecha, corel as DOCUMENTO, cliente, ISNULL(p_cliente.nombre, 'CLIENTE NUEVO') AS NOMBRE,  round( total,2) as total, '' as TipoNota,
#DOC_VENTAS.ruta, #DOC_VENTAS.nombre,#DOC_VENTAS.referencia
from #DOC_VENTAS   LEFT OUTER join p_cliente
on p_cliente.codigo =#DOC_VENTAS.cliente
where credito = 0 

SP_REPORTE_VENTAS
                         

select * from D_FACTURA where serie = '999' and corelativo  between 2619 and 2621
select * from P_CLIENTE where codigo in ('0001013096','0001004360')
UPDATE VENDEDORES SET BODEGA = '3903' where codigo in ('00111095') AND BODEGA = '3900'
select * from VENDEDORES where codigo in ('00111095') AND BODEGA = '3900'
--select * from P_VENDEDOR where codigo in ('00111095') AND BODEGA = '3900'

select * from D_NOTACRED where 