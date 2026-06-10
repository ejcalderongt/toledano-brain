# Informe Ejecutivo de Rendimiento (Cliente)

Fecha de corte: 2026-06-10  
Alcance: liquidación `frmLiqVend` (consulta/edición y generación automática de DL).

## Estado Ejecutivo (Semáforo)

| Estado | Segmento | Resultado |
|---|---|---|
| 🟢 | Aplicado en PRD | Activo y operando |
| 🔵 | Nueva versión BOF | Listo para siguiente despliegue de app |
| 🟡 | Monitoreo | Validación continua de tiempos por ruta |

---

## 🟢 Aplicado en PRD (Ya ejecutado)

### 1) Precheck de generación automática de DL
- SP aplicado: `dbo.usp_LiqVend_DLAuto_Precheck_v1`
- Impacto: evita ejecutar pasos de DL/DC cuando no hay candidatos.
- Evidencia y script:
  - [README precheck](./2026-06-08_dlauto_precheck/README.md)
  - [01_2026-06-08_dlauto_precheck_v1.sql](./2026-06-08_dlauto_precheck/01_2026-06-08_dlauto_precheck_v1.sql)

### 2) Batch set-based para inventario de ruta
- Script aplicado: versión set-based por lote con TVP.
- Impacto: reduce roundtrips y latencia en `POST_CALCULA_INVENTARIO_RUTA`.
- Evidencia y script:
  - [02_2026-06-08_liqvend_inventario_batch_v2_setbased.sql](./2026-06-08_dlauto_precheck/02_2026-06-08_liqvend_inventario_batch_v2_setbased.sql)

### 3) Merma bulk + consolidación transaccional de cabecera
- SP aplicado: `dbo.usp_LiqVend_DL_Merma_Finaliza_v1`
- Impacto: menos viajes a BD y menor riesgo de inconsistencias intermedias.
- Evidencia y scripts:
  - [README merma bulk](./2026-06-08_merma_bulk_headsp/README.md)
  - [01_2026-06-08_usp_LiqVend_DL_Merma_Finaliza_v1.sql](./2026-06-08_merma_bulk_headsp/01_2026-06-08_usp_LiqVend_DL_Merma_Finaliza_v1.sql)
  - [02_execution_qas_prd_2026-06-08.md](./2026-06-08_merma_bulk_headsp/02_execution_qas_prd_2026-06-08.md)

### 4) Regeneración de índices y estadísticas (post-purga)
- Acción: diagnóstico + rebuild/recompute para recuperar rendimiento.
- Impacto: mejora del costo promedio en operaciones de limpieza/actualización por liquidación.
- Evidencia y scripts:
  - [01_diag_fragmentacion_stats_v1.sql](./2026-06-08_index_rebuild_stats/01_2026-06-08_diag_fragmentacion_stats_v1.sql)
  - [02_maintenance_rebuild_stats_v1.sql](./2026-06-08_index_rebuild_stats/02_2026-06-08_maintenance_rebuild_stats_v1.sql)
  - [03_runbook_post_purge_perf.md](./2026-06-08_index_rebuild_stats/03_2026-06-08_runbook_post_purge_perf.md)
  - [06_diagnostico_prd_resumen_2026-06-08.md](./2026-06-08_index_rebuild_stats/06_diagnostico_prd_resumen_2026-06-08.md)

### 5) Índices adicionales por `CODIGOLIQUIDACION` (QAS/PRD)
- Objetivo: reducir scans/costo en tablas grandes de liquidación.
- Evidencia y scripts:
  - [04_proposal_index_tuning_liquidacion_prd_qas_v1.sql](./2026-06-08_index_rebuild_stats/04_proposal_index_tuning_liquidacion_prd_qas_v1.sql)
  - [05_deployment_report_qas_prd_2026-06-08.md](./2026-06-08_index_rebuild_stats/05_deployment_report_qas_prd_2026-06-08.md)

---

## 🔵 Nueva versión BOF (Siguiente despliegue de aplicación)

### 1) Estabilidad de UI (WaitForm)
- Cambio: wrappers defensivos `Safe_Splash_*`.
- Beneficio: elimina fallos por referencia nula durante procesos largos.

### 2) Bulk mapping defensivo
- Cambio: mapeo dinámico de columnas destino en bulk insert.
- Beneficio: evita errores por diferencias de esquema entre ambientes.

### 3) Blindaje de FK en merma (`TEMP_P_NOTACDD` vs `TEMP_P_NOTACD`)
- Cambio: resolución explícita de `CODIGONCD` de cabecera antes de insertar detalle.
- Beneficio: evita conflicto FK durante generación automática de DL.

### 4) Trazabilidad ampliada por etapa
- Cambio: trazas operativas para diagnóstico rápido (`PRECHECK_STATUS`, `PASO_*`, `MERMA_*`, `TIEMPO_TOTAL_DL`).
- Beneficio: identificación de cuellos reales en producción sin adivinar.

- Documento relacionado:
  - [2026-06-09_fix_splash_bulk/README.md](./2026-06-09_fix_splash_bulk/README.md)

---

## Resumen de impacto para cliente

- Menor tiempo total en generación automática de DL.
- Menor carga transaccional en SQL Server.
- Mayor estabilidad operativa en jornadas de alta concurrencia.
- Mayor capacidad de diagnóstico y control de performance.

