# DBA Changes - 2026-06-08 (QAS + PRD)

Este paquete concentra cambios de base de datos orientados a mejorar el rendimiento del proceso de liquidacion, especialmente en escenarios con multiples liquidadores trabajando en paralelo.

## Navegacion rapida
- [Objetivo](#objetivo)
- [Ambientes](#ambientes)
- [Problema que resuelve](#problema-que-resuelve)
- [Scripts incluidos](#scripts-incluidos)
- [Orden recomendado de ejecucion](#orden-recomendado-de-ejecucion)
- [Validacion post-deploy](#validacion-post-deploy)
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

## Orden recomendado de ejecucion
1. Ejecutar [proposal_index_tuning_liquidacion_prd_qas_v1.sql](./proposal_index_tuning_liquidacion_prd_qas_v1.sql) en ventana controlada.
2. Ejecutar [proposal_sp_cola_transacciones_wait_v1.sql](./proposal_sp_cola_transacciones_wait_v1.sql).
3. Ejecutar [proposal_sp_liquidacion_batch_v1.sql](./proposal_sp_liquidacion_batch_v1.sql).
4. Ejecutar [04_queries_validacion_postdeploy_2026-06-08.sql](./04_queries_validacion_postdeploy_2026-06-08.sql).

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
