# Diagnostico PRD ROADSAP - Cuellos, Concurrencia e Indices

Fecha: 2026-06-08
Servidor: 172.16.10.9 (PTSVR2009N)
BD: ROADSAP
Login diagnostico: roadprod

## Importante de contexto
- SQL Server reinicio reciente: `2026-06-08 13:57:58`.
- Esto implica que `dm_os_wait_stats`, `dm_exec_query_stats` e `index_usage_stats` reflejan ventana corta y no historico completo.

## Herramientas usadas
1. `sqlcmd` + DMVs (no invasivo, solo lectura).
2. Script Python reusable:
   - `road_toledano_agent_setup/tools/sql_perf_diagnose.py`
   - Salidas:
     - `road_toledano_agent_setup/sql/diagnostico_prd_roadsap_2026-06-08.md`
     - `road_toledano_agent_setup/sql/diagnostico_prd_roadsap_2026-06-08.json`

## Hallazgos clave
1. Cuello principal en resets por `CODIGOLIQUIDACION`:
   - `UPDATE P_INVENTARIO_RUTA SET CODIGOLIQUIDACION = 0 WHERE CODIGOLIQUIDACION=@...`
     - `avg_elapsed_ms ~ 543.87`
   - `UPDATE P_INVENTARIO_BARRAS_RUTA ...`
     - `avg_reads ~ 4503.5`, `avg_cpu_ms ~ 296.4`, `avg_elapsed_ms ~ 317.78`

2. Cobertura de indices por `CODIGOLIQUIDACION` incompleta:
   - Sin indice clave en:
     - `P_INVENTARIO_BARRAS_RUTA`
     - `D_DEPOS`
   - `P_INVENTARIO_RUTA` tiene indices con `CODIGOLIQUIDACION` no liderando como primera columna para el patron `WHERE CODIGOLIQUIDACION=@x`.

3. Demanda/volumen relevante:
   - `P_STOCKB`: ~2,099,854 filas
   - `P_COLA_TRANSACCIONES`: ~688,040 filas
   - `P_STOCK`: ~448,135 filas
   - `P_INVENTARIO_BARRAS_RUTA`: ~344,426 filas

4. Concurrencia en ventana observada:
   - Sin bloqueos activos en snapshots.
   - Esperas observadas de negocio (no sleep): `PAGEIOLATCH_SH`, `LCK_M_U`, `LCK_M_X`, `WRITELOG`, `ASYNC_NETWORK_IO`.
   - Muestra de 30s: baja actividad (promedio ~0.1 requests activos).

5. Cola de transacciones:
   - `P_COLA_TRANSACCIONES` con alto volumen historico.
   - Ya existe indice nuevo `IX_P_COLA_TRANSACCIONES_TIPO_PROC_LIQ_USR` (desplegado hoy).
   - Missing index sugiere adicional por `CODIGO_USUARIO` para updates por usuario.

## Diagnostico de causa probable
El proceso de liquidacion mejora set-based ya aplicada sigue pegando fuerte cuando limpia `CODIGOLIQUIDACION` en tablas grandes sin llave adecuada por esa columna. Resultado: scans/costo alto, CPU y latencia por lote, y potencial de lock/page contention cuando sube concurrencia de liquidadores.

## Propuesta tecnica (no aplicada aun)
Script generado:
- `road_toledano_agent_setup/sql/proposal_index_tuning_liquidacion_prd_qas_v1.sql`

Incluye:
1. `IX_P_INVENTARIO_BARRAS_RUTA_CODLIQ_NZ` (filtrado `CODIGOLIQUIDACION <> 0`)
2. `IX_P_INVENTARIO_RUTA_CODLIQ`
3. `IX_D_DEPOS_CODLIQ`
4. `IX_P_COLA_TRANSACCIONES_USR_PROC`

## Recomendacion de rollout
1. Aplicar primero en QAS.
2. Ejecutar prueba de carga concurrente (5-10 liquidadores).
3. Medir delta contra baseline:
   - avg elapsed de updates por `CODIGOLIQUIDACION`
   - lock waits LCK_* por minuto
   - tiempo total de cierre de liquidacion
4. Si mejora >= 30% y sin regresion funcional, promover a PRD en ventana controlada.
