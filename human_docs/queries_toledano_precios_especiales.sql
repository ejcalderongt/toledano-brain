select valor from P_PRECESPEC where fecha = '20250909' and PRODUCTO = '0234' and PRECIO = 1.93


select e.RUTA, e.FECHA, e.CORELFACTURA, d.PRODUCTO,d.PRECIO
from P_NOTACDD d inner join P_NOTACD e on e.CODIGONCD = d.CODIGONCD
where d.PRODUCTO = '0234' and e.fecha = '20250909'  and d.PRECIO = 1.88

select e.RUTA, e.FECHA, e.COREL CORELFACTURA, d.PRODUCTO,d.PRECIO
from D_FACTURAD d inner join d_factura e ON e.corel = d.corel
where d.PRODUCTO = '0234' and d.PRECIO = 1.88 and e.fecha = '20250909' and 
e.cliente in (select valor from P_PRECESPEC where fecha = '20250909' and PRODUCTO = '0234' and PRECIO = 1.93)

select distinct e.RUTA
from P_NOTACDD d inner join P_NOTACD e on e.CODIGONCD = d.CODIGONCD
where d.PRODUCTO = '0234' and e.fecha = '20250909'  and d.PRECIO = 1.88

select distinct e.RUTA
from D_FACTURAD d inner join d_factura e ON e.corel = d.corel
where d.PRODUCTO = '0234' and d.PRECIO = 1.88 and e.fecha = '20250909' and 
e.cliente in (select valor from P_PRECESPEC where fecha = '20250909' and PRODUCTO = '0234' and PRECIO = 1.93)

select RUTA, FECHA_SISTEMA
from P_LIQUIDACION where ruta in (select distinct e.RUTA
from D_FACTURAD d inner join d_factura e ON e.corel = d.corel
where d.PRODUCTO = '0234' and d.PRECIO = 1.88 and e.fecha = '20250909' and 
e.cliente in (select valor from P_PRECESPEC where fecha = '20250909' and PRODUCTO = '0234' and PRECIO = 1.93))
AND FECHA = '20250909' ORDER BY FECHA_SISTEMA ASC
