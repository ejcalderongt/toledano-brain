# DBA Changes - 2026-06-08 (QAS + PRD)

Scripts ejecutados en base de datos de forma independiente para optimizacion de liquidacion/concurrencia.

## Ambientes
- QAS: `172.16.10.27` / `ROADSAP_QAS`
- PRD: `172.16.10.9` / `ROADSAP`

## Causa
- Alto costo de `UPDATE ... WHERE CODIGOLIQUIDACION` en tablas grandes.
- Espera recursiva en cola de transacciones y necesidad de mover coordinacion a BD.

## Scripts
1. `proposal_sp_liquidacion_batch_v1.sql`
- SHA256: `FFCE80C59AB857AD651FD7C44EC75E9C4ECBEAB9D17083CA76D99F36BC9AE6BE`

2. `proposal_sp_cola_transacciones_wait_v1.sql`
- SHA256: `10A28A8E9549CDD0E372B20D19201CB4A02D281A1CBEAFE1CBABBDAD239CB18B`

3. `proposal_index_tuning_liquidacion_prd_qas_v1.sql`
- SHA256: `A968AA2FAFB5A4F5A7CCFC96D94675913479E8D5D503479676DE8D8F47518554`

4. `04_queries_validacion_postdeploy_2026-06-08.sql`
- SHA256: `3A68DA273A955D5A153584B0CA9A3549C75586550BFF672C87EBE629D0F83438`

## Nota
- Credenciales no se incluyen en este repositorio.
- Ejecucion y evidencia detallada quedaron en `road_toledano_agent_setup/db_execution_map` del repo operativo.
