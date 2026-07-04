declare
	@FechaInicial date= '20220527', 
	@FechaFinal date= '20220601'

	select *
	from ROADSAP_HIST_4.dbo.P_stockB --D INNER JOIN ROADSAP_HIST_4.dbo.P_DIFLIQ E ON D.CODIGO = E.CODIGO  AND E.CODIGO_LIQUIDACION = D.CODIGOLIQUIDACION
	where  fecha between @FechaInicial and @FechaFinal
	--order by e.CODIGO_LIQUIDACION, e.codigo
