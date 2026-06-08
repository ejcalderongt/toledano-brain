# Informe Ejecutivo - Optimizacion Liquidacion ROAD (QAS + PRD)

Fecha de corte: 2026-06-08  
Paquete: `dba_changes/2026-06-08_qas_prd_liquidacion`

## Resumen
Se ejecutó un plan incremental de optimización para el proceso de liquidación (`frmLiqVend` y flujos relacionados), enfocado en:
- Reducir roundtrips y carga iterativa.
- Mejorar concurrencia con múltiples liquidadores.
- Mantener compatibilidad con fallback legacy para no romper flujos.

Los cambios fueron aplicados y validados en **QAS** y **PRD** con evidencia versionada.

## Motivo y Razon
1. Tiempos altos en apertura/consulta de liquidaciones existentes, con casos en rango de decenas de segundos.
2. Cuellos recurrentes en etapas `POST_RECALCULA_FACTURAS` y `POST_CALCULA_INVENTARIO_RUTA`.
3. Correlación directa con consumo SQL en updates por `CODIGOLIQUIDACION` sobre tablas voluminosas.
4. Necesidad operativa de estabilidad bajo alta concurrencia (múltiples liquidadores, distintas rutas, mismo horario).

## Ambientes Validados
- **QAS**: `172.16.10.27` / `ROADSAP_QAS`
- **PRD**: `172.16.10.9` / `ROADSAP`

## Arbol De Entregables (Ultima Ejecucion + Historico Del Dia)
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
    ├── 20260608_155251/
    │   ├── EXECUTION_REPORT_2026-06-08.md
    │   ├── qas_01_index.log
    │   ├── qas_02_sp_cola.log
    │   ├── qas_03_sp_batch.log
    │   ├── qas_04_validacion.log
    │   ├── prd_01_index.log
    │   ├── prd_02_sp_cola.log
    │   ├── prd_03_sp_batch.log
    │   └── prd_04_validacion.log
    ├── 20260608_160247/
    │   └── EXECUTION_REPORT_2026-06-08_reapply_v2.md
    └── 20260608_160509/
        └── EXECUTION_REPORT_2026-06-08_liqlist_sp.md
```

## Scripts Ejecutados y Validados
1. [proposal_index_tuning_liquidacion_prd_qas_v1.sql](./proposal_index_tuning_liquidacion_prd_qas_v1.sql)
2. [proposal_sp_cola_transacciones_wait_v1.sql](./proposal_sp_cola_transacciones_wait_v1.sql)
3. [proposal_sp_liquidacion_batch_v1.sql](./proposal_sp_liquidacion_batch_v1.sql)
4. [04_queries_validacion_postdeploy_2026-06-08.sql](./04_queries_validacion_postdeploy_2026-06-08.sql)
5. [17_liqvend_sp_migration_v1.sql](./17_liqvend_sp_migration_v1.sql)
6. [18_liqvend_index_tuning_v2.sql](./18_liqvend_index_tuning_v2.sql)
7. [19_liqlist_sp_migration_v1.sql](./19_liqlist_sp_migration_v1.sql)

## Evidencia De Ejecucion
- Primera ejecución QAS/PRD: [execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md](./execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md)
- Reapply idempotente V2 QAS/PRD: [execution_logs/20260608_160247/EXECUTION_REPORT_2026-06-08_reapply_v2.md](./execution_logs/20260608_160247/EXECUTION_REPORT_2026-06-08_reapply_v2.md)
- Ejecución SPs de LiquidacionesList en QAS/PRD: [execution_logs/20260608_160509/EXECUTION_REPORT_2026-06-08_liqlist_sp.md](./execution_logs/20260608_160509/EXECUTION_REPORT_2026-06-08_liqlist_sp.md)

## Diagnostico Narrativo (Con Ejemplos)
1. Apertura de liquidación no se degrada por una sola consulta, sino por acumulación de etapas `POST_*`.
   Ejemplo: al subir facturas recalculadas (26 vs 20), el total del flujo crece de forma marcada.
2. El motor SQL confirma el mismo patrón: el mayor costo promedio persiste en updates de inventario por liquidación.
   Ejemplo: `UPDATE P_INVENTARIO_BARRAS_RUTA SET CODIGOLIQUIDACION = 0 WHERE CODIGOLIQUIDACION=@...` aparece como sentencia dominante en costo.
3. Índices y SPs mejoran estabilidad y reducen presión por roundtrip, pero los casos más pesados aún requieren fase V2 set-based completa para bajar a segundos.

## Cambios De Valor Aplicados
- Migración de validaciones/rutas críticas de BOF a SP versionados (`v1`) con fallback legacy.
- Índices V2 aplicados para patrones frecuentes de fecha, cola y barras.
- Trazabilidad operativa completa por ambiente y por corrida.

## Riesgos y Control
- `D_FACTURA` tiene alta densidad de índices superpuestos; se priorizó no sobre-indexar sin consolidación previa.
- Se mantuvo estrategia non-breaking: cuando SP no está disponible, el BOF conserva el camino SQL legacy.

## Recomendacion Siguiente
1. Completar fase V2 batch/set-based de recalculo de facturas por TVP.
2. Consolidar agregación de inventario por ruta/liquidación en SP dedicado.
3. Ejecutar benchmark controlado (3/5/8 liquidadores) y comparar contra esta línea base documentada.
