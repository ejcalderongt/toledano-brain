select * from P_RUTA where codigo = 'P806-1'

select Ruta, corel Pedido, convert(date,concat('20',SUBSTRING(corel,8,6))) Fecha_Dispositivo, 
fecha Fecha_ROAD, FECHAENTR Fecha_Entrega, 
DATEDIFF(day, fecha_sistema,convert(date,concat('20',SUBSTRING(corel,8,6)))) Diferencia
from d_pedido where fecha>='20250101'
--and ruta = 'P806-1'-- and fecha>='20250301'
and 
DATEDIFF(day, fecha_sistema,convert(date,concat('20',SUBSTRING(corel,8,6))))<>0
