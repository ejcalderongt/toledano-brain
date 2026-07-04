Ruta 6045-5, fecha 17. # de documento 4946346183

Ruta 2036-5, fecha 18. # de documento 4946324061

Ruta 2027-5, fecha 18. # de documento 4946346570.

select * from p_Stock where documento = '4946346183'
select * from p_Stock where documento = '4946324061'
select * from p_Stock where documento = '4946346570'

insert into P_STOCKB
select [RUTA], [BARRA], [CODIGO], [CANT], [COREL], [PRECIO], [PESO], '4946346183' [DOCUMENTO], [FECHA], [ANULADO], [CENTRO],
'B' [STATUS], 0 [ENVIADO],0 [CODIGOLIQUIDACION],'' [COREL_D_MOV], [FECHA_SISTEMA], [UNIDADMEDIDA],'0083646154' [DOC_ENTREGA]
from P_STOCKB where ruta = '6045-5' and fecha = '20230217' and CODIGO = '0214' and barra not in (select barra from D_STOCKB_DEV)
select * from P_STOCKB where ruta = '6045-5' and fecha = '20230217' and CODIGO = '0214'

insert into P_STOCKB
select [RUTA], [BARRA], [CODIGO], [CANT], [COREL], [PRECIO], [PESO], '4946324061' [DOCUMENTO], [FECHA], [ANULADO], [CENTRO],
'B' [STATUS], 0 [ENVIADO],0 [CODIGOLIQUIDACION],'' [COREL_D_MOV], [FECHA_SISTEMA], [UNIDADMEDIDA],'0083647583' [DOC_ENTREGA]
from P_STOCKB
where ruta = '2036-5' and fecha = '20230218' and CODIGO = '0214' and barra not in (select barra from D_STOCKB_DEV)

select * from P_STOCKB where ruta = '2036-5' and fecha = '20230218' and CODIGO = '0214' and barra not in (select barra from D_STOCKB_DEV)

insert into P_STOCKB
select [RUTA], [BARRA], [CODIGO], [CANT], [COREL], [PRECIO], [PESO], '4946391283' [DOCUMENTO], [FECHA], [ANULADO], [CENTRO],
'B' [STATUS], 0 [ENVIADO],0 [CODIGOLIQUIDACION],'' [COREL_D_MOV], [FECHA_SISTEMA], [UNIDADMEDIDA],'0083647875' [DOC_ENTREGA]
from P_STOCKB
where ruta = '6045-5' and fecha = '20230218' and CODIGO = '0214' and barra not in (select barra from D_STOCKB_DEV)

Ruta 6045-5, fecha 18. # de documento 4946391283

select * from P_STOCKB where ruta = '6045-5' and fecha = '20230218' and CODIGO = '0214' and barra not in (select barra from D_STOCKB_DEV)