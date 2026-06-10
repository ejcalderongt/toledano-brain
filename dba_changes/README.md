# ROAD Toledano - Executive DBA Release Hub
## Liquidacion `frmLiqVend` (QAS + PRD)

<p>
  <img alt="Release" src="https://img.shields.io/badge/Release-2026--06--09-0A66C2" />
  <img alt="Scope" src="https://img.shields.io/badge/Scope-Liquidacion%20y%20Concurrencia-7A3E9D" />
  <img alt="QAS" src="https://img.shields.io/badge/QAS-Aplicado-2EA043" />
  <img alt="PRD" src="https://img.shields.io/badge/PRD-Aplicado-2EA043" />
  <img alt="Fallback" src="https://img.shields.io/badge/Fallback-Activo-F2CC60" />
  <img alt="Riesgo" src="https://img.shields.io/badge/Riesgo-Controlado-2EA043" />
</p>

## Proposito del release
Este hub resume, en lenguaje ejecutivo y tecnico, **que se mejoro**, **por que se mejoro**, **que impacto se espera**, y **donde esta la evidencia**.

## Seccion primaria (prioridad 1): optimizacion sin cambio de version, post-purga de datos
> Esta seccion es la principal porque representa mejora inmediata sin migrar version de ROAD.

### Por que esta seccion va primero
Cuando se eliminan años de datos, el motor puede quedar con estadisticas y distribuciones distintas al patrón anterior.  
Sin recalibrar indices/estadisticas, SQL puede sostener planes suboptimos y aumentar colisiones bajo concurrencia.

### Que se recomienda ejecutar despues de purga
1. Actualizar estadisticas de tablas criticas de liquidacion.
2. Reorganize/Rebuild de indices segun fragmentacion y volumen.
3. Validacion post-mantenimiento con trazas de etapas (`POST_*`) y tiempos.

### Indices priorizados para rendimiento (sin cambio de version)
1. `IX_P_STOCKB_FECHA_INC_ENV_LIQ_DOC_v2`
2. `IX_P_STOCK_FECHA_INC_ENV_LIQ_DOC_v2`
3. `IX_P_COLA_TRANS_PROCESADO_USR_v2`
4. `IX_P_INV_BARRAS_RUTA_BARRA_v2`
5. `IX_P_INVENTARIO_BARRAS_RUTA_CODLIQ_NZ`
6. `IX_P_INVENTARIO_RUTA_CODLIQ`
7. `IX_D_DEPOS_CODLIQ`
8. `IX_P_COLA_TRANSACCIONES_USR_PROC`
9. `IX_P_COLA_TRANSACCIONES_TIPO_PROC_LIQ_USR`

### Impacto esperado de esta seccion primaria
1. Menos scans costosos en filtros por `CODIGOLIQUIDACION`, `RUTA`, `VENDEDOR`.
2. Menor ruido SQL en horas pico.
3. Menor variabilidad de tiempos de apertura/calculo por ruta.

### Respaldo tecnico
- [18_liqvend_index_tuning_v2.sql](./2026-06-08_qas_prd_liquidacion/18_liqvend_index_tuning_v2.sql)
- [proposal_index_tuning_liquidacion_prd_qas_v1.sql](./2026-06-08_qas_prd_liquidacion/proposal_index_tuning_liquidacion_prd_qas_v1.sql)

## Diagnostico (causa y motivo)
1. Tiempos altos en apertura/consulta de liquidaciones y en `Generacion automatica DL`.
2. Roundtrips repetitivos (N+1 y operaciones fila-a-fila) en etapas criticas.
3. Escenarios de concurrencia real con multiples liquidadores ejecutando al mismo tiempo.
4. Riesgo operativo por inestabilidad de UI y fallas intermitentes en procesos largos.

## Cambios aplicados en PRD que mejoran rendimiento
1. Precheck de generacion automatica de DL.
Por que: evitar ejecutar pasos completos sin candidatos.
Impacto esperado: menor tiempo total del boton de generacion.
Scripts:
- [proposal_sp_liquidacion_batch_v1.sql](./2026-06-08_qas_prd_liquidacion/proposal_sp_liquidacion_batch_v1.sql)
- [proposal_sp_cola_transacciones_wait_v1.sql](./2026-06-08_qas_prd_liquidacion/proposal_sp_cola_transacciones_wait_v1.sql)

2. Inventario batch set-based con TVP.
Por que: remover N+1 y reducir ida/vuelta BOF-BD en `Calcula_Inventario_Ruta`.
Impacto esperado: menor latencia en `POST_CALCULA_INVENTARIO_RUTA`.
Scripts:
- [17_liqvend_sp_migration_v1.sql](./2026-06-08_qas_prd_liquidacion/17_liqvend_sp_migration_v1.sql)

3. Index tuning para liquidacion y lista.
Por que: acelerar filtros/joins frecuentes por `CODIGOLIQUIDACION`, `RUTA`, `VENDEDOR`.
Impacto esperado: mejor throughput bajo carga concurrente.
Scripts:
- [18_liqvend_index_tuning_v2.sql](./2026-06-08_qas_prd_liquidacion/18_liqvend_index_tuning_v2.sql)
- [19_liqlist_sp_migration_v1.sql](./2026-06-08_qas_prd_liquidacion/19_liqlist_sp_migration_v1.sql)

## Nueva version ROAD (plan evolutivo): mejoras contempladas para menos roundtrips y menos colisiones
> Estas mejoras describen el rumbo para futuras versiones, reutilizando lo aplicado en QAS/PRD.

1. Migracion controlada de SQL inline a Stored Procedures.
Impacto: menor roundtrip y planes de ejecucion mas estables.
Referencias:
- [17_liqvend_sp_migration_v1.sql](./2026-06-08_qas_prd_liquidacion/17_liqvend_sp_migration_v1.sql)
- [19_liqlist_sp_migration_v1.sql](./2026-06-08_qas_prd_liquidacion/19_liqlist_sp_migration_v1.sql)

2. Batch set-based con TVP para calculo de inventario por ruta.
Impacto: elimina N+1 y reduce latencia de `POST_CALCULA_INVENTARIO_RUTA`.
Referencias:
- [proposal_sp_liquidacion_batch_v1.sql](./2026-06-08_qas_prd_liquidacion/proposal_sp_liquidacion_batch_v1.sql)
- [14_traza_debug_runtime_liquidacion_20260608.md](./2026-06-08_qas_prd_liquidacion/14_traza_debug_runtime_liquidacion_20260608.md)

3. Coordinacion de concurrencia con cola transaccional en BD.
Impacto: menos colisiones entre liquidadores concurrentes y menos esperas recursivas cliente.
Referencia:
- [proposal_sp_cola_transacciones_wait_v1.sql](./2026-06-08_qas_prd_liquidacion/proposal_sp_cola_transacciones_wait_v1.sql)

4. Consolidacion de updates de cabecera por etapa transaccional.
Impacto: reduce lock churn y riesgo de inconsistencia parcial.
Referencias:
- [16_correlacion_traza_sqlhealth_2026-06-08.md](./2026-06-08_qas_prd_liquidacion/16_correlacion_traza_sqlhealth_2026-06-08.md)
- [2026-06-08_qas_prd_liquidacion/README.md](./2026-06-08_qas_prd_liquidacion/README.md)

5. Observabilidad de performance como estandar de release.
Impacto: decisiones de optimizacion con evidencia real y menos iteraciones ciegas.
Referencias:
- [14_traza_debug_runtime_liquidacion_20260608.md](./2026-06-08_qas_prd_liquidacion/14_traza_debug_runtime_liquidacion_20260608.md)
- [16_correlacion_traza_sqlhealth_2026-06-08.md](./2026-06-08_qas_prd_liquidacion/16_correlacion_traza_sqlhealth_2026-06-08.md)

## Mejoras de aplicacion identificadas por ingenieria (orientadas a release)
> Estas lineas reflejan oportunidades priorizadas por analisis tecnico. Algunas ya fueron prototipadas o validadas en pruebas controladas, y su adopcion final depende de la ventana de despliegue.

1. Reduccion de N+1 en merma.
Enfoque de software: cache local por llave de negocio (`%merma`, UM y precio) para evitar llamadas repetitivas por producto.
Impacto esperado: menor roundtrip y menor tiempo por lote en generacion de DL de merma.

2. Insercion masiva de detalle (bulk + fallback).
Enfoque de software: procesamiento masivo para `TEMP_P_DIFLIQ_DET` y `TEMP_P_NOTACDD` con mecanismo de compatibilidad.
Impacto esperado: menos viajes a BD, menor tiempo de cierre de etapa y mejor comportamiento en alto volumen.

3. Consolidacion transaccional de cabecera merma.
Enfoque de software: agrupar updates de cabecera en una operacion transaccional controlada.
Impacto esperado: menos lock churn y menor riesgo de inconsistencia intermedia.

4. Estabilidad UI durante procesos largos.
Enfoque de software: endurecimiento de `SplashScreen` y control de estado para evitar errores visuales/nulos.
Impacto esperado: mejor continuidad operativa y menos interrupciones de usuario.

5. Observabilidad operativa por etapa.
Enfoque de software: trazas `PRECHECK_STATUS`, `PASO_*`, `MERMA_BULK_*`, `TIEMPO_TOTAL_DL` e indicadores `T.S.` / `T.DL.`.
Impacto esperado: diagnostico trazable y decisiones de optimizacion basadas en evidencia.

## Evidencia y respaldo
1. Release notes completo (formato epico y arbol de entregables):
- [2026-06-08_qas_prd_liquidacion/README.md](./2026-06-08_qas_prd_liquidacion/README.md)

2. Evidencia de ejecucion QAS/PRD:
- [execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md](./2026-06-08_qas_prd_liquidacion/execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md)
- [execution_logs/20260608_160247/EXECUTION_REPORT_2026-06-08_reapply_v2.md](./2026-06-08_qas_prd_liquidacion/execution_logs/20260608_160247/EXECUTION_REPORT_2026-06-08_reapply_v2.md)
- [execution_logs/20260608_160509/EXECUTION_REPORT_2026-06-08_liqlist_sp.md](./2026-06-08_qas_prd_liquidacion/execution_logs/20260608_160509/EXECUTION_REPORT_2026-06-08_liqlist_sp.md)

### Que refleja esta evidencia y respaldo
1. Trazabilidad tecnica: que se ejecuto, en que ambiente y con que secuencia.
2. Sustento de impacto: correlacion entre cambios y comportamiento observado en tiempos/etapas.
3. Control de riesgo: verificaciones postdeploy y capacidad de rollback/fallback documentada.
4. Transferencia operativa: material reutilizable para DBA, desarrollo y soporte en futuras ventanas.

## Orden documental (para evitar duplicidad)
1. `dba_changes/README.md`: hub ejecutivo unico.
2. `dba_changes/<release>/README.md`: narrativa completa del release.
3. `execution_logs/*`: evidencia tecnica inmutable de ejecucion.

## Mensaje clave para DBA y negocio
Este release no solo agrega scripts; consolida una estrategia de performance con control de riesgo:  
menos roundtrips, mejor concurrencia, trazabilidad por etapa y fallback seguro para continuidad operativa.
