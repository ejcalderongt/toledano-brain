# Plan N+1 Liquidacion V2 (2026-06-08)

## Objetivo
Reducir de forma significativa el tiempo de apertura/consulta de liquidacion (`frmLiqVend`) eliminando patrones N+1 en:
- `POST_CALCULA_INVENTARIO_RUTA`
- `POST_RECALCULA_FACTURAS`

## Evidencia (logs nuevos)
- Carpeta: `bin\x86\Debug\trace_liquidacion\20260608`
- Caso critico:
  - archivo: `liq_384607_8053-1_cfuentes_20260608_153831_921.csv`
  - `Buscar_Registro END = 86428 ms`
  - `CARGA_GRID_EDITABLE = 84066 ms`
  - `POST_RECALCULA_FACTURAS delta_ms = 52427` (`recalculadas=26`)
  - `POST_CALCULA_INVENTARIO_RUTA delta_ms = 29230`

## Acciones ya aplicadas (quick wins)
1. Cache de precios en `RecalculaFactura`.
2. Precarga de productos con nota para evitar `Tiene_Nota` por item.
3. Correlativo NCD obtenido una sola vez por corrida.
4. Cache de factores de conversion UM en `Calcula_Inventario_Ruta`.
5. Throttling de `DoEvents` en inventario (cada 10 items).

## Gap restante
Los quick wins reducen roundtrips repetidos, pero no eliminan el costo base de loops con consultas de negocio por item/factura. Bajo volumen alto (26 facturas) se mantiene latencia elevada.

## Plan V2 (DB-first)
## Fase A - SP batch para recalc de facturas
1. Implementar `SP_ROAD_LIQ_RECALC_FACTURAS_BATCH_V1` (base creada como propuesta).
2. Entrada:
- `@Fecha`, `@Ruta`, `@Vendedor`, `@CodigoLiquidacion`
- TVP `tvp_ROAD_LIQ_FACTURAS_V1`
3. Salida:
- diferencias de precio por factura/producto listas para insertar en temp de notas.
4. BOF:
- reemplazar loop de `RecalculaFactura` por una sola llamada batch.

## Fase B - SP agregada de inventario
1. Implementar `SP_ROAD_LIQ_INVENTARIO_RUTA_AGR_V1` (base creada como propuesta).
2. Entrada:
- `@Fecha`, `@Ruta`, `@CorelDMOV`, `@CodigoLiquidacion`, `@EstadoLiquidacion`
3. Salida:
- dataset agregado para poblar `InvRutaList` sin consultas por producto dentro del loop.
4. BOF:
- construir `InvRutaList` desde un único resultset.

## Fase C - UI orgánica sin repintado excesivo
1. `BeginUpdate/EndUpdate` en bind de grids de liquidacion.
2. Actualizar labels/progress por lote/fase y no por item.
3. Mantener trazas `POST_*` para medir impacto real.

## Riesgo / Mitigacion
- Riesgo: diferencia funcional en notas e inventario calculado.
- Mitigacion:
  - feature flag con fallback a legado.
  - validacion A/B QAS contra casos reales.
  - comparación de totales: inventario, notas, estado liquidacion, documentos asociados.

## KPI de salida
1. Apertura/consulta de liquidacion de casos pesados:
- objetivo `< 10s` (hoy p95 observado > 45s y max ~86s).
2. Delta acumulado de `POST_CALCULA_INVENTARIO_RUTA + POST_RECALCULA_FACTURAS`:
- objetivo `< 6s`.
