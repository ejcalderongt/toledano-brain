# Despliegue y Validacion BD - QAS/PRD (2026-06-08)

## Alcance
Se desplegaron estructuras de optimizacion para el proceso de liquidacion/cola:

1. `road_toledano_agent_setup/sql/proposal_sp_liquidacion_batch_v1.sql`
2. `road_toledano_agent_setup/sql/proposal_sp_cola_transacciones_wait_v1.sql`

## Ambientes
- QAS: `172.16.10.27` / `ROADSAP_QAS`
- PRD: `172.16.10.9` / `ROADSAP`

## Objetos verificados
- `dbo.usp_Liquidacion_GuardarBatch_v1`
- `dbo.usp_COLA_TRANSACCIONES_ReadActive_v1`
- `dbo.usp_COLA_TRANSACCIONES_TryAcquire_v1`
- `dbo.usp_COLA_TRANSACCIONES_ReleaseByUserType_v1`
- `dbo.usp_COLA_TRANSACCIONES_ReleaseBatch_v1`
- `dbo.tvp_COLA_TRANSACCIONES_CODIGO_v1`
- `IX_P_COLA_TRANSACCIONES_TIPO_PROC_LIQ_USR` en `dbo.P_COLA_TRANSACCIONES`

## Ajuste aplicado durante validacion
Se detecto error de lock hint en `TryAcquire`:
- Causa: combinacion `READPAST` + `HOLDLOCK` en la misma lectura.
- Fix: remover `READPAST` en ese `SELECT` y forzar `READ COMMITTED` en el SP.
- Estado: redeploy exitoso en QAS y PRD.

## Pruebas ejecutadas
### QAS
- Smoke funcional de `TryAcquire` + `ReleaseByUserType` con usuario tecnico `codex_probe` y liquidacion dummy `999999`.
- Resultado: `ACQUIRED = 1`, limpieza posterior correcta (`ActivosProbe = 0`).

### PRD
- Validacion no mutante:
  - existencia de objetos
  - indice creado
  - lectura `ReadActive` sin afectar datos

## Benchmark rapido de lectura de cola (sin carga)
Nota: pruebas realizadas con `ColaActiva = 0`, por lo que sirven como baseline tecnico, no como throughput bajo carga real.

### QAS (100 iteraciones)
- `LEGACY_QUERY_X100`: `2521 ms`
- `SP_READACTIVE_X100`: `2640 ms`

### PRD (30 iteraciones)
- `PRD_LEGACY_QUERY_X30`: `1476 ms`
- `PRD_SP_READACTIVE_X30`: `1187 ms`

## Conclusiones operativas
1. Las estructuras nuevas quedaron sincronizadas en QAS y PRD.
2. El SP `TryAcquire` quedo estable tras ajuste de lock hints.
3. El beneficio principal esperado no es solo tiempo por consulta aislada, sino:
   - reducir roundtrips desde BOF
   - centralizar logica de concurrencia en BD
   - habilitar evolucion a control atomico de turnos.

## Siguiente paso recomendado
Integrar en BOF `frmLiqVend` el consumo de `usp_COLA_TRANSACCIONES_TryAcquire_v1` y `ReleaseByUserType_v1` con fallback al flujo actual si el SP no responde, para rollout controlado.

## Despliegue de indices (2026-06-08)
Script aplicado:
- `road_toledano_agent_setup/sql/proposal_index_tuning_liquidacion_prd_qas_v1.sql`

Indices aplicados en QAS y PRD:
- `IX_P_INVENTARIO_BARRAS_RUTA_CODLIQ_NZ` (filtrado `CODIGOLIQUIDACION <> 0`)
- `IX_P_INVENTARIO_RUTA_CODLIQ`
- `IX_D_DEPOS_CODLIQ`
- `IX_P_COLA_TRANSACCIONES_USR_PROC`

Detalle tecnico:
- Se detecto error inicial por opcion de sesion y se corrigio el script agregando `SET QUOTED_IDENTIFIER ON`.
- Tiempos de ejecucion:
  - QAS: `2094 ms`
  - PRD: `2831 ms`

Validacion:
- El mismo script retorna listado de los 4 indices creados por ambiente al finalizar.
