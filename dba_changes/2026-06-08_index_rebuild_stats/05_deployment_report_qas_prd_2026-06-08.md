# Informe Ejecutivo - Mejoras, Purgas y Diagnostico SQL (QAS/PRD)

Fecha: 2026-06-08

## Resumen Ejecutivo
Se ejecutó una ola completa de optimización para liquidación y concurrencia, y adicionalmente un proceso de recuperación de rendimiento post-purga de históricos.

Resultado global:
- Despliegues aplicados y validados en QAS y PRD.
- Estructuras V1 y V2 de rendimiento activas (SPs, TVPs e índices).
- Diagnóstico post-purga con mantenimiento de índices/estadísticas y evidencia before/after.

## Ambientes
- QAS: `172.16.10.27` / `ROADSAP_QAS`
- PRD: `172.16.10.9` / `ROADSAP`

## Casos Aplicados (con SQL y Diagnóstico)

### Caso 1: Concurrencia en cola de transacciones
Motivo:
- Reducir roundtrips y centralizar turnos concurrentes de liquidadores en BD.

SQL aplicado:
- [proposal_sp_cola_transacciones_wait_v1.sql](./proposal_sp_cola_transacciones_wait_v1.sql)

Diagnóstico / evidencia:
- [deployment_report_qas_prd_2026-06-08.md](./deployment_report_qas_prd_2026-06-08.md)
- [execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md](./execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md)

### Caso 2: Guardado batch de liquidación
Motivo:
- Disminuir costo iterativo por fila y mejorar throughput en escenarios con múltiples rutas.

SQL aplicado:
- [proposal_sp_liquidacion_batch_v1.sql](./proposal_sp_liquidacion_batch_v1.sql)

Diagnóstico / evidencia:
- [execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md](./execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md)
- [04_queries_validacion_postdeploy_2026-06-08.sql](./04_queries_validacion_postdeploy_2026-06-08.sql)

### Caso 3: Índices base de liquidación (V1)
Motivo:
- Mejorar búsquedas y updates críticos por `CODIGOLIQUIDACION`.

SQL aplicado:
- [proposal_index_tuning_liquidacion_prd_qas_v1.sql](./proposal_index_tuning_liquidacion_prd_qas_v1.sql)

Diagnóstico / evidencia:
- [execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md](./execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md)

### Caso 4: Migración BOF a SPs de rutas/validaciones (LiqVend + Lista)
Motivo:
- Reducir SQL inline en formularios, mejorar estabilidad de planes y evitar concatenación repetitiva.

SQL aplicado:
- [2026-06-08_liqvend_sp_migration_v1.sql](./2026-06-08_liqvend_sp_migration_v1.sql)
- [2026-06-08_liqlist_sp_migration_v1.sql](./2026-06-08_liqlist_sp_migration_v1.sql)

Diagnóstico / evidencia:
- [execution_logs/20260608_160247/EXECUTION_REPORT_2026-06-08_reapply_v2.md](./execution_logs/20260608_160247/EXECUTION_REPORT_2026-06-08_reapply_v2.md)
- [execution_logs/20260608_160509/EXECUTION_REPORT_2026-06-08_liqlist_sp.md](./execution_logs/20260608_160509/EXECUTION_REPORT_2026-06-08_liqlist_sp.md)

### Caso 5: V2 set-based + TVP (ataque a N+1)
Motivo:
- Atacar cuellos críticos observados en trazas (`POST_CALCULA_INVENTARIO_RUTA`, `POST_RECALCULA_FACTURAS`).

SQL aplicado:
- [2026-06-08_liqvend_v2_batch_setbased.sql](./2026-06-08_liqvend_v2_batch_setbased.sql)
- [2026-06-08_liqvend_v2_validate.sql](./2026-06-08_liqvend_v2_validate.sql)

Diagnóstico / evidencia:
- [execution_logs/20260608_161715/EXECUTION_REPORT_2026-06-08_v2_full.md](./execution_logs/20260608_161715/EXECUTION_REPORT_2026-06-08_v2_full.md)

### Caso 6: Post-purga (eliminación de históricos) y recuperación de rendimiento
Motivo:
- Tras purga masiva, se detectó degradación percibida. Se ejecutó scan sistemático y mantenimiento de índices/estadísticas.

SQL aplicado:
- [2026-06-08_diag_fragmentacion_stats_v1.sql](./2026-06-08_diag_fragmentacion_stats_v1.sql)
- [2026-06-08_maintenance_rebuild_stats_v1.sql](./2026-06-08_maintenance_rebuild_stats_v1.sql)
- [2026-06-08_runbook_post_purge_perf.md](./2026-06-08_runbook_post_purge_perf.md)

Diagnóstico / evidencia:
- [diagnostico_qas_roadsap_qas_2026-06-08_post_maint.md](./diagnostico_qas_roadsap_qas_2026-06-08_post_maint.md)
- [diagnostico_prd_roadsap_2026-06-08_post_maint.md](./diagnostico_prd_roadsap_2026-06-08_post_maint.md)
- [execution_logs/20260608_162957/EXECUTION_REPORT_2026-06-08_post_purge_scan_maintenance.md](./execution_logs/20260608_162957/EXECUTION_REPORT_2026-06-08_post_purge_scan_maintenance.md)

## Diagnostico Narrativo
1. El tiempo de apertura de liquidación no depende solo de cabecera; el costo se concentra en cálculo de inventario y recálculo de facturas.
2. La purga de históricos cambió distribución de datos y afectó selectividad/planes; por eso fue necesario mantenimiento post-purga (no solo deploy funcional).
3. El mantenimiento produjo mejora medible en PRD sobre la sentencia dominante de reset por liquidación (`P_INVENTARIO_BARRAS_RUTA`).
4. V2 deja base técnica para bajar a segundos con integración BOF total a SPs set-based/TVP.

## Estado Actual
- Cambios aplicados y validados en QAS y PRD: SI
- Evidencia versionada por ejecución: SI
- Runbook repetible para próximas purgas: SI

## Siguiente Etapa Recomendada
1. Encender consumo BOF completo de SP V2 por feature flag controlado.
2. Medir benchmark concurrente (3/5/8 liquidadores) en QAS y luego PRD.
3. Consolidar índices superpuestos en `D_FACTURA` con criterio de uso real.
