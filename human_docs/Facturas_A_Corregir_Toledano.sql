select REPLACE(CORELDFACTURA,'3011600320','311600320'),* from MI3_SAP where codigoruta = '8008-1' and fechaoperacion = '20230830'
and coreldfactura like '3011600320%'

--begin transaction

--update MI3_SAP set CORELDFACTURA=REPLACE(CORELDFACTURA,'301160','31160'),SAPNOFACTURA=REPLACE(SAPNOFACTURA,'301160','31160') where codigoruta = '8008-1' and fechaoperacion = '20230830'
--and coreldfactura like '31160%'

--select CORELDFACTURA,SAPNOFACTURA,CODIGOOPERACION, * 
--from MI3_SAP 
--where CODIGOLIQUIDACION = '292195' and CODIGOOPERACION in ('01','11')
--and len(coreldfactura)>10

--select CORELDFACTURA,SAPNOFACTURA,CODIGOOPERACION, * 
--from MI3_SAP 
--where CODIGOLIQUIDACION = '292195' and CODIGOOPERACION in ('01','11')

--commit transaction

--update MI3_SAP set ESTATUS = 'N' where CODIGOLIQUIDACION = '292195' and ESTATUS = 'T'

select CORELDFACTURA as corel,SAPNOFACTURA,CODIGOOPERACION, * 
from MI3_SAP where CODIGOLIQUIDACION = '292195' and CODIGOOPERACION in ('01','11')
and len(coreldfactura)<=10 order by CORELDFACTURA

select * from D_FACTURA where serie = '116' and corelativo = 3212