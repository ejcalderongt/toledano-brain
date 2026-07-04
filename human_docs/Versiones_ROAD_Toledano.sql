select NumVersion, count(Codigo)
from p_ruta
WHere codigo in (select codigo from rutas_activas)
Group by NumVersion

select distinct ruta
from d_pedido
where fecha >='20250216'
and ruta in (select codigo from p_ruta where numversion in ('9.9.67 / ','9.9.73 / ','9.9.92 / ','9.9.93 / ','10.0.01 / ') )

select Codigo Código, Nombre, NumVersion as Versión
from p_ruta
WHere numversion <>'' and activo = 'S'
order by numversion

