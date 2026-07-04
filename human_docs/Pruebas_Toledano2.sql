declare
	@FechaInicial date= '20220602', 
	@FechaFinal date= '20220630'
select 'P_DIFLIQ' Tabla, datepart(year, fecha) año, datepart(month, fecha) mes, datepart(day, fecha) dia, count(CODIGO) Cant_Reg, 0 Cant_Reg_Hist
	from P_DIFLIQ
	where  fecha between @FechaInicial and @FechaFinal
	group by  datepart(year, fecha), datepart(month, fecha), datepart(day, fecha)
	UNION
	select 'P_DIFLIQ' Tabla,datepart(year, fecha) año, datepart(month, fecha) mes, datepart(day, fecha) dia, 0 Cant_Reg,count(CODIGO) Cant_Reg_Hist
	from ROADSAP_HIST_4.dbo.P_DIFLIQ
	where  fecha between @FechaInicial and @FechaFinal
	group by  datepart(year, fecha), datepart(month, fecha), datepart(day, fecha)
	UNION
	select 'P_DIFLIQ_DET' Tabla, datepart(year, E.fecha) año, datepart(month, E.fecha) mes, datepart(day, E.fecha) dia, count(D.CODIGO) Cant_Reg, 0 Cant_Reg_Hist
	from P_DIFLIQ_DET D INNER JOIN P_DIFLIQ E ON D.CODIGO = E.CODIGO  AND E.CODIGO_LIQUIDACION = D.CODIGOLIQUIDACION
	where  fecha between @FechaInicial and @FechaFinal
	group by  datepart(year, E.fecha), datepart(month, E.fecha), datepart(day, E.fecha)
	UNION
	select 'P_DIFLIQ_DET' Tabla, datepart(year, E.fecha) año, datepart(month, E.fecha) mes, datepart(day, E.fecha) dia, 0 Cant_Reg, count(D.CODIGO) Cant_Reg_Hist
	from ROADSAP_HIST_4.dbo.P_DIFLIQ_DET D INNER JOIN ROADSAP_HIST_4.dbo.P_DIFLIQ E ON D.CODIGO = E.CODIGO  AND E.CODIGO_LIQUIDACION = D.CODIGOLIQUIDACION
	where  fecha between @FechaInicial and @FechaFinal
	group by  datepart(year, E.fecha), datepart(month, E.fecha), datepart(day, E.fecha)

	
    SELECT FECHA, COUNT(documento) CANT
	from ROADSAP_HIST_4.dbo.p_stock
	where  FECHA  between '20220801' and '20220831'
	GROUP BY FECHA

	    SELECT FECHA, COUNT(documento) CANT
	from ROADSAP_HIST_4.dbo.p_stock_PV
	where  FECHA  between '20220801' and '20220831'
	GROUP BY FECHA

		    SELECT FECHA, COUNT(documento) CANT
	from ROADSAP_HIST_4.dbo.p_stockb
	where  FECHA  between '20220801' and '20220831'
	GROUP BY FECHA

	SELECT FECHA, COUNT(documento) CANT
	from p_stock
	where  FECHA  between '20220801' and '20220831'
	GROUP BY FECHA

	    SELECT FECHA, COUNT(documento) CANT
	from p_stock_PV
	where  FECHA  between '20220801' and '20220831'
	GROUP BY FECHA

	SELECT FECHA, COUNT(documento) CANT
	from p_stockb 
	where  FECHA  between '20220801' and '20220831'
	GROUP BY FECHA


 --   DELETE from ROADSAP_HIST_4.dbo.D_PEDIDO
	--where  COREL IN (select COREL from ROADSAP_HIST_4.dbo.P_DIFLIQ
	--where  fecha between '20220530' and '20220601')

	--DELETE from ROADSAP_HIST_4.dbo.P_DIFLIQ_DET
	--where  CODIGOLIQUIDACION IN 
	--(SELECT CODIGO_LIQUIDACION FROM ROADSAP_HIST_4.dbo.P_DIFLIQ WHERE FECHA  between '20220512' and '20220512')
	
	--DELETE  from ROADSAP_HIST_4.dbo.P_DIFLIQ
	--WHERE FECHA  between '20220512' and '20220512'
	
	--UPDATE CONF_INTERFASE SET PROCESADA = 1 WHERE Exp_Imp = 1 and (TABLA = 'MI3_SAP')  and procesada =1
	--UPDATE CONF_INTERFASE SET PROCESADA = 1 WHERE Exp_Imp = 1 and (TABLA = 'P_STOCKB')  and procesada =1
	--UPDATE CONF_INTERFASE SET PROCESADA = 1 WHERE Exp_Imp = 1 and (TABLA = 'P_STOCK')  and procesada =1
	--UPDATE CONF_INTERFASE SET PROCESADA = 1 WHERE Exp_Imp = 1 and (TABLA = 'P_STOCK_PV')  and procesada =1
	--UPDATE CONF_INTERFASE SET PROCESADA = 0 WHERE Exp_Imp = 1 and (TABLA = 'D_COBRO')  and procesada =1
	--UPDATE CONF_INTERFASE SET PROCESADA = 0 WHERE Exp_Imp = 1 and (TABLA = 'D_ATENCION')  and procesada =1
	--UPDATE CONF_INTERFASE SET PROCESADA = 0 WHERE Exp_Imp = 1 and (TABLA = 'D_CLINUEVOT')  and procesada =1
	--UPDATE CONF_INTERFASE SET PROCESADA = 0 WHERE Exp_Imp = 1 and (TABLA = 'D_CLINUEVO')  and procesada =1
	--UPDATE CONF_INTERFASE SET PROCESADA = 0 WHERE Exp_Imp = 1 and (TABLA = 'D_DEPOS')  and procesada =1


SELECT CODIGOLIQUIDACION, CODIGO, COUNT(CODIGO) CANT
FROM P_DIFLIQ_DET WHERE CODIGOLIQUIDACION IN (
SELECT  CODIGO_LIQUIDACION FROM P_DIFLIQ WHERE fecha between '20220530' and '20220901')
GROUP BY CODIGOLIQUIDACION, CODIGO
ORDER BY CODIGO

SELECT * FROM D_DEPOS WHERE FECHA BETWEEN '20220523' AND '20220523' AND CUENTA IS NULL


	--delete	from ROADSAP_HIST_4.dbo.d_cobro
	--where  FECHA  between '20220801' and '20220801'


	declare
	@FechaInicial date= '20220512', 
	@FechaFinal date= '20220831',
	@registros int
	exec SP_COMPARATIVO_HISTORICO @FechaInicial, @FechaFinal, @registros

	select * from P_COMPARATIVO_HISTORICO where tabla like 'P_DIFLIQ%' 
	order by dia, mes, tabla

	UPDATE CONF_INTERFASE SET PROCESADA = 0 WHERE Exp_Imp = 1 and (TABLA = 'P_DIFLIQ')
