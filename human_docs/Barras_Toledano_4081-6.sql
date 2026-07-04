select * from p_Stockb where ruta = '4081-6' and fecha = '20240904'
and codigo = '0052' and status = 'A'
and barra in (select barra from D_STOCKB_DEV )

select * from D_STOCKB_DEV where ruta = '4081-6' and fecha = '20240904'
and codigo = '0052' 

select * from D_STOCKB_DEV where barra in (select barra from p_Stockb where ruta = '4081-6' and fecha = '20240904'
and codigo = '0052' and status = 'A') and ruta <>'4081-6'

select * from D_STOCKB_DEV where barra in (select barra from p_Stockb where ruta = '4081-6' and fecha = '20240904'
and codigo = '0052' and status = 'A') and ruta <>'4081-6'

select barra, replace(barra,'1-','') 
from D_STOCKB_DEV
where SUBSTRING(barra,1,2) = '1-'

select * from p_Stockb where ruta = '4011-6' and fecha = '20240902'
and codigo = '0052' 

select * from D_FACTURA where corel = '4011-6_240902135533'

select * from p_Stockb where barra in (select barra from D_STOCKB_DEV where barra in (select barra from p_Stockb where ruta = '4081-6' and fecha = '20240904'
and codigo = '0052' and status = 'A') and ruta <>'4081-6') and ruta = '4601-6'

select * from p_Stockb where ruta = '4601-6' and fecha = '20240904'
and codigo = '0052' and status = 'A'

select * from P_STOCKB where codigoliquidacion = 326612 and codigo = '0052'