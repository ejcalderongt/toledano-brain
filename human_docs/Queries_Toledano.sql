update P_STOCKB set COREL_D_MOV = '00110304250927164533', ENVIADO = 1 where documento = '0801222412'

select * from P_COREL

select * from p_liquidacion where ruta = '8016-1' and fecha = '20250927'

select * from P_STOCKb where ruta = '8053-1' and fecha >= '20251001'
update P_COREL set CORELULT = 4125 where serie = '247'

select max(Corel) from D_NOTACRED where corel like '247%' and TIPO_DOCUMENTO  = 'NC'
select max(Corel) from D_NOTACRED where corel like '247%' and TIPO_DOCUMENTO  = 'ND'
select max(Corel) from D_CXC where corel like '247%'

select * from P_CORREL_OTROS where SERIE = '247'



exec DEVOLUCION_HU_PDA '20250927','20250927','8016-1'
select * from P_DEVOLUCIONES_SAP where ruta = '8016-1' and fecha = '20250927'
update P_STOCKB set fecha = '20250927' where documento = '0801211420'

update P_STOCKB set fecha = '20250927' where documento = '0801222412'
update P_DEVOLUCIONES_SAP set FECHA = '20250927' where ruta = '8016-1' and fecha = '20251006'

update P_DEVOLUCIONES_SAP set fecha = '20251010' where documento = '0801211420'