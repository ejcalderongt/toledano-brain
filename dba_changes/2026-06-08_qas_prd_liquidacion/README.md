# ROAD Toledano - DBA Release Notes
## Liquidacion y concurrencia (QAS + PRD) - 2026-06-08

<p>
  <img alt="Release" src="https://img.shields.io/badge/Release-2026--06--08-0A66C2" />
  <img alt="QAS" src="https://img.shields.io/badge/QAS-Aplicado-2EA043" />
  <img alt="PRD" src="https://img.shields.io/badge/PRD-Aplicado-2EA043" />
  <img alt="Riesgo" src="https://img.shields.io/badge/Riesgo-Controlado-F2CC60" />
</p>

## Resumen ejecutivo
Se ejecuto un plan incremental de optimizacion para el proceso de liquidacion (`frmLiqVend` y flujos relacionados), enfocado en:
- Reducir roundtrips y carga iterativa.
- Mejorar concurrencia con multiples liquidadores.
- Mantener compatibilidad con fallback legacy para no romper flujos.

Los cambios fueron aplicados y validados en **QAS** y **PRD** con evidencia versionada.

## Motivo y razon
1. Tiempos altos en apertura/consulta de liquidaciones existentes, con casos en rango de decenas de segundos.
2. Cuellos recurrentes en etapas `POST_RECALCULA_FACTURAS` y `POST_CALCULA_INVENTARIO_RUTA`.
3. Correlacion directa con consumo SQL en updates por `CODIGOLIQUIDACION` sobre tablas voluminosas.
4. Necesidad operativa de estabilidad bajo alta concurrencia (multiples liquidadores, distintas rutas, mismo horario).

## En base a que lo ejecutamos
La decision se baso en evidencia tecnica:
- Trazas de liquidacion por etapa (inicio/fin y tiempos por bloque).
- Correlacion con salud SQL (fragmentacion, stats, consumo por query).
- Analisis de concurrencia en escenarios con varias rutas/liquidadores.
- Validaciones funcionales para no romper flujo de apertura/consulta/cierre.

## Ambientes validados
- **QAS**: `172.16.10.27` - `ROADSAP_QAS`
- **PRD**: `172.16.10.9` - `ROADSAP`

## Que ejecutamos
1. [proposal_sp_liquidacion_batch_v1.sql](./proposal_sp_liquidacion_batch_v1.sql)
- SP orientado a procesamiento por lote y menor ida/vuelta BOF-BD.

2. [proposal_sp_cola_transacciones_wait_v1.sql](./proposal_sp_cola_transacciones_wait_v1.sql)
- SP para coordinar espera/turnos en cola de transacciones sin recursion pesada en cliente.

3. [proposal_index_tuning_liquidacion_prd_qas_v1.sql](./proposal_index_tuning_liquidacion_prd_qas_v1.sql)
- Ajuste de indices para consultas y updates sensibles de liquidacion.

4. [04_queries_validacion_postdeploy_2026-06-08.sql](./04_queries_validacion_postdeploy_2026-06-08.sql)
- Queries de validacion funcional y tecnica post-despliegue.

5. [17_liqvend_sp_migration_v1.sql](./17_liqvend_sp_migration_v1.sql)
- Migracion controlada de consultas inline criticas de BOF a SP.

6. [18_liqvend_index_tuning_v2.sql](./18_liqvend_index_tuning_v2.sql)
- Refuerzo de indices para patrones de liquidacion y concurrencia.

7. [19_liqlist_sp_migration_v1.sql](./19_liqlist_sp_migration_v1.sql)
- Optimizacion de lista de liquidaciones (pantalla relacionada).

## Arbol de entregables
```text
dba_changes/2026-06-08_qas_prd_liquidacion/
├── README.md
├── proposal_sp_liquidacion_batch_v1.sql
├── proposal_sp_cola_transacciones_wait_v1.sql
├── proposal_index_tuning_liquidacion_prd_qas_v1.sql
├── 04_queries_validacion_postdeploy_2026-06-08.sql
├── 14_traza_debug_runtime_liquidacion_20260608.md
├── 15_plan_n1_liquidacion_v2_2026-06-08.md
├── 16_correlacion_traza_sqlhealth_2026-06-08.md
├── 17_liqvend_sp_migration_v1.sql
├── 18_liqvend_index_tuning_v2.sql
├── 19_liqlist_sp_migration_v1.sql
└── execution_logs/
```

## Evidencia de ejecucion
- Primera ejecucion QAS/PRD: [execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md](./execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md)
- Reapply idempotente V2 QAS/PRD: [execution_logs/20260608_160247/EXECUTION_REPORT_2026-06-08_reapply_v2.md](./execution_logs/20260608_160247/EXECUTION_REPORT_2026-06-08_reapply_v2.md)
- Ejecucion SPs de LiquidacionesList QAS/PRD: [execution_logs/20260608_160509/EXECUTION_REPORT_2026-06-08_liqlist_sp.md](./execution_logs/20260608_160509/EXECUTION_REPORT_2026-06-08_liqlist_sp.md)

## Diagnostico narrativo (ejemplos)
1. La apertura de liquidacion no se degrada por una sola consulta, sino por acumulacion de etapas `POST_*`.
2. En SQL, el mayor costo promedio se mantuvo en updates de inventario por liquidacion (`CODIGOLIQUIDACION`).
3. Indices y SPs reducen presion por roundtrip y mejoran estabilidad; los casos mas pesados requieren completar fase V2 set-based con TVP.

## Resultado esperado de negocio
- Menor tiempo de espera al abrir/consultar liquidaciones existentes.
- Mejor throughput cuando varios usuarios liquidan simultaneamente.
- Menor probabilidad de picos por bloqueos y esperas innecesarias.
- Base preparada para siguientes fases (TVP, set-based adicional y consolidacion de queries inline a SPs).

## Riesgos y control
- Riesgo principal: cambios de plan de ejecucion por indices/SP.
- Mitigacion: despliegue incremental, validacion postdeploy y seguimiento en traza.
- Estado: controlado con monitoreo activo.

## Recomendacion siguiente
1. Completar fase V2 batch/set-based de recalculo de facturas por TVP.
2. Consolidar agregacion de inventario por ruta/liquidacion en SP dedicado.
3. Ejecutar benchmark controlado (3/5/8 liquidadores) y comparar contra esta linea base documentada.

## Notas operativas
- Credenciales y secretos no se incluyen en este repositorio.
- Evidencia tecnica detallada se mantiene en logs/versionado del flujo operativo.