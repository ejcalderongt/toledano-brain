select distinct cliente, FECHA
from D_PEDIDO 
where  fecha >= '20250801'
and anulado = 'S'

--select * from P_CLIENTE where codigo = '0001001917'

select distinct Ruta, Cliente, Fecha, Total, Anulado, Total_Monto_Minimo
from D_PEDIDO E
where  fecha >= '20250601'
and CLIENTE IN (
SELECT CLIENTE FROM D_PEDIDO WHERE anulado = 'S')
AND EXISTS (select distinct ruta, cliente, FECHA, TOTAL, ANULADO
from D_PEDIDO D WHERE D.CLIENTE = E.CLIENTE AND D.FECHA = E.FECHA AND E.ANULADO<>D.ANULADO )
ORDER BY FECHA, RUTA, CLIENTE