# Correlacion Trazas vs SQL Health Check (PRD)

Fecha: 2026-06-08

## Objetivo
Correlacionar los nuevos logs de `frmLiqVend` (apertura/consulta de liquidacion existente) contra el health check SQL para confirmar cuellos reales y priorizar la fase V2.

## Fuentes evaluadas
- Trazas BOF:
  - `C:\Users\yejc2\source\repos\ROAD_TOLEDANO\bin\x86\Debug\trace_liquidacion\20260608`
- Diagnostico SQL PRD:
  - `diagnostico_prd_roadsap_2026-06-08_refresh.md`
  - `diagnostico_prd_roadsap_2026-06-08_refresh.json`

## Hallazgos de traza (nuevo corte)
Casos observados en apertura/consulta:

1. Caso alto:
   - `Buscar_Registro END`: 103232 ms
   - `CARGA_GRID_EDITABLE`: 101241 ms
   - `POST_RECALCULA_FACTURAS`: 63533 ms
   - `POST_CALCULA_INVENTARIO_RUTA`: 34204 ms
2. Caso medio-alto:
   - `Buscar_Registro END`: 86428 ms
   - `POST_RECALCULA_FACTURAS`: 52427 ms
   - `POST_CALCULA_INVENTARIO_RUTA`: 29230 ms
3. Caso medio:
   - `Buscar_Registro END`: 46379 ms
   - `POST_CALCULA_INVENTARIO_RUTA`: 24665 ms
   - `POST_RECALCULA_FACTURAS`: 17017 ms
4. Caso bajo:
   - `Buscar_Registro END`: 13007 ms
   - `POST_CALCULA_INVENTARIO_RUTA`: 5895 ms
   - `POST_RECALCULA_FACTURAS`: 1083 ms

## Hallazgos SQL health (PRD)
- Query de mayor costo promedio sigue en ruta de reset por liquidacion:
  - `UPDATE P_INVENTARIO_BARRAS_RUTA SET CODIGOLIQUIDACION = 0 WHERE CODIGOLIQUIDACION=@...`
  - Alto `reads` promedio y CPU acumulado.
- Waits relevantes durante periodos de carga:
  - `LCK_M_U`, `LCK_M_S`, `LCK_M_X`
  - `PAGEIOLATCH_SH`
  - `WRITELOG`
  - `ASYNC_NETWORK_IO`
- Volumen en tablas sensibles:
  - `P_STOCKB`: ~2.1M
  - `P_COLA_TRANSACCIONES`: ~688k
  - `P_INVENTARIO_BARRAS_RUTA`: ~346k

## Correlacion tecnica
1. El tiempo total de apertura crece casi linealmente con la carga de `POST_RECALCULA_FACTURAS`.
2. `POST_CALCULA_INVENTARIO_RUTA` se mantiene como segundo cuello y dispara costo cuando hay mayor cardinalidad por ruta.
3. Los waits de lock e I/O respaldan los picos vistos en traza (no es solo UI, hay contencion real en BD).
4. Los indices nuevos ayudaron a contener degradacion, pero no eliminan el costo estructural por procesamiento iterativo y updates por lote no consolidado.

## Conclusiones
- Si el objetivo es bajar a segundos en escenarios de varios liquidadores concurrentes, los quick wins ya no alcanzan.
- El siguiente salto de rendimiento requiere mover la logica dominante a procesamiento batch en SQL con TVP:
  - V2 `RecalculaFactura`: entrada por TVP, procesamiento set-based, salida de resumen.
  - V2 `InventarioRuta`: agregacion consolidada por ruta/liquidacion evitando lecturas repetidas.
- Mantener trazas activas para medir antes/despues por etapa (`POST_*`) y no perder visibilidad de regresiones.

## Prioridad recomendada
1. Implementar SP batch V2 para `RecalculaFactura` con fallback a flujo actual.
2. Implementar SP de agregacion para inventario por ruta/liquidacion.
3. Medir en QAS con concurrencia controlada (3/5/8 liquidadores) y luego promover a PRD.
