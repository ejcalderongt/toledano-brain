# ROAD Toledano - Executive DBA Report Hub
## Optimizacion de Liquidacion (QAS + PRD)

Este archivo centraliza el contexto ejecutivo del release y evita duplicidad de reportes.

## Estado actual
- Se ejecutaron mejoras de rendimiento en BD y BOF para `frmLiqVend`.
- Los cambios fueron aplicados de forma incremental con evidencia en QAS y PRD.
- Se mantuvo estrategia de fallback para no romper flujos operativos.

## Fuente oficial por tema
### Release principal (epico, narrativo y con arbol de entregables)
- [2026-06-08_qas_prd_liquidacion/README.md](./2026-06-08_qas_prd_liquidacion/README.md)

### Cambios aplicados en PRD (DBA)
1. Precheck de DL automatico:
- [2026-06-08_qas_prd_liquidacion/proposal_sp_liquidacion_batch_v1.sql](./2026-06-08_qas_prd_liquidacion/proposal_sp_liquidacion_batch_v1.sql)
- [2026-06-08_qas_prd_liquidacion/proposal_sp_cola_transacciones_wait_v1.sql](./2026-06-08_qas_prd_liquidacion/proposal_sp_cola_transacciones_wait_v1.sql)
2. Inventario batch set-based / TVP:
- [2026-06-08_qas_prd_liquidacion/17_liqvend_sp_migration_v1.sql](./2026-06-08_qas_prd_liquidacion/17_liqvend_sp_migration_v1.sql)
3. Ajustes de indices:
- [2026-06-08_qas_prd_liquidacion/18_liqvend_index_tuning_v2.sql](./2026-06-08_qas_prd_liquidacion/18_liqvend_index_tuning_v2.sql)
4. Lista de liquidaciones:
- [2026-06-08_qas_prd_liquidacion/19_liqlist_sp_migration_v1.sql](./2026-06-08_qas_prd_liquidacion/19_liqlist_sp_migration_v1.sql)

### Mejoras en aplicacion (ya implementadas en release)
1. Reduccion de N+1 en `Calcula_Inventario_Ruta` y `Generar_DL_Merma`.
2. Batch/bulk para detalle de notas y diferencias.
3. Indicadores operativos en UI (`T.S.` / `T.DL.`).
4. Trazas finas por etapa para correlacion SQL/BOF.
5. Hardening de estabilidad UI (`SplashScreen` defensivo).

## Evidencia de ejecucion
- [2026-06-08_qas_prd_liquidacion/execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md](./2026-06-08_qas_prd_liquidacion/execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md)
- [2026-06-08_qas_prd_liquidacion/execution_logs/20260608_160247/EXECUTION_REPORT_2026-06-08_reapply_v2.md](./2026-06-08_qas_prd_liquidacion/execution_logs/20260608_160247/EXECUTION_REPORT_2026-06-08_reapply_v2.md)
- [2026-06-08_qas_prd_liquidacion/execution_logs/20260608_160509/EXECUTION_REPORT_2026-06-08_liqlist_sp.md](./2026-06-08_qas_prd_liquidacion/execution_logs/20260608_160509/EXECUTION_REPORT_2026-06-08_liqlist_sp.md)

## Diagnostico de duplicidad (resumen)
- El reporte epico se mantuvo en `2026-06-08_qas_prd_liquidacion/README.md`.
- Se agrego luego un README raiz mas corto (`dba_changes/README.md`) con parte del mismo contexto.
- Eso dio percepcion de "versiones duplicadas" del mismo estado.

## Regla de orden documental (aplicada)
- `dba_changes/README.md`: portal ejecutivo unico (hub).
- `dba_changes/<release>/README.md`: narrativa completa del release.
- `execution_logs/*`: evidencia tecnica inmutable.
