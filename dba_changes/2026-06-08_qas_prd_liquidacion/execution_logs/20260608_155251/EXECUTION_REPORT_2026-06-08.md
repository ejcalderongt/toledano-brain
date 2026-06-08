# Execution Report - QAS y PRD

Fecha: 2026-06-08  
Paquete: `dba_changes/2026-06-08_qas_prd_liquidacion`

## Secuencia ejecutada
1. `proposal_index_tuning_liquidacion_prd_qas_v1.sql`
2. `proposal_sp_cola_transacciones_wait_v1.sql`
3. `proposal_sp_liquidacion_batch_v1.sql`
4. `04_queries_validacion_postdeploy_2026-06-08.sql`

## QAS
- Servidor: `172.16.10.27`
- Base: `ROADSAP_QAS`
- Resultado: OK (sin errores en ejecución)
- Logs:
  - `qas_01_index.log`
  - `qas_02_sp_cola.log`
  - `qas_03_sp_batch.log`
  - `qas_04_validacion.log`
- Validación:
  - SPs y TVPs esperados presentes.
  - Índices esperados presentes.
  - `cola_activa_total = 0`.

## PRD
- Servidor: `172.16.10.9`
- Base: `ROADSAP`
- Resultado: OK (sin errores en ejecución)
- Logs:
  - `prd_01_index.log`
  - `prd_02_sp_cola.log`
  - `prd_03_sp_batch.log`
  - `prd_04_validacion.log`
- Validación:
  - SPs y TVPs esperados presentes.
  - Índices esperados presentes.
  - `cola_activa_total = 0`.

## Observación de consumo relevante (PRD)
En el top de costo promedio aún domina:
- `UPDATE P_INVENTARIO_BARRAS_RUTA SET CODIGOLIQUIDACION = 0 WHERE CODIGOLIQUIDACION=@...`
- Referencia del corte: `avg_elapsed_ms ~ 441.75`, `avg_logical_reads ~ 4526.25`.

Conclusión: despliegue correcto y estable, sin ruptura funcional observable desde validación SQL. El cuello principal de consumo sigue siendo el update de barras por liquidación, por lo que la fase V2 batch/set-based sigue siendo prioritaria para bajar a segundos en alta concurrencia.
