# DBA Changes - 2026-06-08 (QAS + PRD)

Este paquete concentra cambios de base de datos orientados a mejorar el rendimiento del proceso de liquidacion, especialmente en escenarios con multiples liquidadores trabajando en paralelo.

## Navegacion rapida
- [Objetivo](#objetivo)
- [Ambientes](#ambientes)
- [Problema que resuelve](#problema-que-resuelve)
- [Scripts incluidos](#scripts-incluidos)
- [Orden recomendado de ejecucion](#orden-recomendado-de-ejecucion)
- [Validacion post-deploy](#validacion-post-deploy)
- [Diagnostico runtime](#diagnostico-runtime)
- [Plan N+1 v2](#plan-n1-v2)
- [Correlacion traza vs SQL health](#correlacion-traza-vs-sql-health)
- [Evidencia de ejecucion](#evidencia-de-ejecucion)
- [Impacto esperado en negocio](#impacto-esperado-en-negocio)
- [Riesgos y consideraciones](#riesgos-y-consideraciones)
- [Notas](#notas)

## Objetivo
Reducir tiempos de procesamiento en liquidacion sin romper flujos existentes, moviendo trabajo repetitivo al motor SQL y mejorando la concurrencia en cola de transacciones.

## Ambientes
- QAS: `172.16.10.27` / `ROADSAP_QAS`
- PRD: `172.16.10.9` / `ROADSAP`

## Problema que resuelve
- Alto costo de operaciones `UPDATE ... WHERE CODIGOLIQUIDACION` sobre tablas con volumen.
- Espera recursiva de turnos en cola de transacciones, con impacto en roundtrips y latencia percibida.
- Necesidad de una estrategia mas robusta para concurrencia cuando varios usuarios liquidan rutas al mismo tiempo.

## Scripts incluidos
1. [proposal_sp_liquidacion_batch_v1.sql](./proposal_sp_liquidacion_batch_v1.sql)  
   SP orientado a procesamiento en lote para reducir roundtrips y costo por fila durante liquidacion.
2. [proposal_sp_cola_transacciones_wait_v1.sql](./proposal_sp_cola_transacciones_wait_v1.sql)  
   SP para control de espera/turno en cola de transacciones con enfoque de concurrencia.
3. [proposal_index_tuning_liquidacion_prd_qas_v1.sql](./proposal_index_tuning_liquidacion_prd_qas_v1.sql)  
   Ajustes de indices para consultas y updates criticos de liquidacion.
4. [04_queries_validacion_postdeploy_2026-06-08.sql](./04_queries_validacion_postdeploy_2026-06-08.sql)  
   Queries de validacion funcional y tecnica despues del despliegue.
5. [14_traza_debug_runtime_liquidacion_20260608.md](./14_traza_debug_runtime_liquidacion_20260608.md)  
   Diagnostico de trazas runtime en debug con top cuellos por etapa (`POST_*`).
6. [15_plan_n1_liquidacion_v2_2026-06-08.md](./15_plan_n1_liquidacion_v2_2026-06-08.md)  
   Plan tecnico V2 para eliminar N+1 en apertura/consulta de liquidacion.
7. [16_correlacion_traza_sqlhealth_2026-06-08.md](./16_correlacion_traza_sqlhealth_2026-06-08.md)  
   Correlacion entre trazas nuevas de `frmLiqVend` y health check SQL en PRD.

## Orden recomendado de ejecucion
1. Ejecutar [proposal_index_tuning_liquidacion_prd_qas_v1.sql](./proposal_index_tuning_liquidacion_prd_qas_v1.sql) en ventana controlada.
2. Ejecutar [proposal_sp_cola_transacciones_wait_v1.sql](./proposal_sp_cola_transacciones_wait_v1.sql).
3. Ejecutar [proposal_sp_liquidacion_batch_v1.sql](./proposal_sp_liquidacion_batch_v1.sql).
4. Ejecutar [04_queries_validacion_postdeploy_2026-06-08.sql](./04_queries_validacion_postdeploy_2026-06-08.sql).

## Diagnostico runtime
- El mayor costo no esta en encabezado de liquidacion, sino en:
  - `POST_CALCULA_INVENTARIO_RUTA`
  - `POST_RECALCULA_FACTURAS`
- Ver detalle en [14_traza_debug_runtime_liquidacion_20260608.md](./14_traza_debug_runtime_liquidacion_20260608.md).

## Plan N+1 v2
- Quick wins ya aplicados reducen roundtrips repetitivos, pero casos pesados siguen altos.
- La siguiente etapa es mover calculo a SP batch con TVP y consolidar carga agregada de inventario.
- Ver plan en [15_plan_n1_liquidacion_v2_2026-06-08.md](./15_plan_n1_liquidacion_v2_2026-06-08.md).

## Correlacion traza vs SQL health
- Se confirmo correlacion fuerte entre cuellos `POST_RECALCULA_FACTURAS` y `POST_CALCULA_INVENTARIO_RUTA` con waits de lock/I-O en SQL.
- El costo dominante persiste en operaciones `UPDATE ... WHERE CODIGOLIQUIDACION` sobre tablas de alto volumen.
- Ver analisis detallado en [16_correlacion_traza_sqlhealth_2026-06-08.md](./16_correlacion_traza_sqlhealth_2026-06-08.md).

## Evidencia de ejecucion
- Ejecucion aplicada en `QAS` y `PRD` el `2026-06-08`.
- Reporte y logs en:
  - [execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md](./execution_logs/20260608_155251/EXECUTION_REPORT_2026-06-08.md)

## Validacion post-deploy
- Confirmar creacion/alter de objetos sin errores.
- Validar tiempos promedio de operaciones de liquidacion antes/despues.
- Verificar que no existan bloqueos anormales en escenarios de concurrencia.
- Ejecutar una liquidacion completa con datos representativos y revisar consistencia funcional.

## Impacto esperado en negocio
- Menor tiempo de espera para el liquidador durante guardar/procesar.
- Mejor estabilidad bajo concurrencia alta.
- Menor probabilidad de cuellos de botella por consultas repetitivas o updates por fila.

## Riesgos y consideraciones
- Todo cambio en indices puede alterar planes de ejecucion en otras consultas; monitorear.
- Validar en QAS con carga realista antes de PRD.
- Confirmar compatibilidad con procesos que dependen de tablas temporales y cola transaccional.

## Notas
- Este repositorio no incluye credenciales ni secretos.
- La evidencia operativa detallada de ejecucion se documenta en el repo operativo (bitacora tecnica del equipo).
