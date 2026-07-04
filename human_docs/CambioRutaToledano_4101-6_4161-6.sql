select * from p_stockb where DOCUMENTO = '0801044871'
select * from p_stock where DOCUMENTO = '0801044871'
exec DEVOLUCION_HU_PDA '20250523','20250523','4061-6'

--select * from P_BITACORA_LIQUIDACION where obs1 like '%0801044871%'

 
update p_stockb set ruta = '4061-6' where DOCUMENTO = '0801044871'
update p_stock set ruta = '4061-6' where DOCUMENTO = '0801044871'
update P_DEVOLUCIONES_SAP set ruta = '4061-6' where ruta = '4101-6' and fecha = '20250523'

select * from P_DEVOLUCIONES_SAP where ruta = '4101-6' and fecha = '20250523'

