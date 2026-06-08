# Diagnostico debug runtime - frmLiqVend (2026-06-08)

## Fuente
- Carpeta analizada:
  - `C:\Users\yejc2\source\repos\ROAD_TOLEDANO\bin\x86\Debug\trace_liquidacion\20260608`
- Archivos: `2`
- Eventos: `50`
- Flujos:
  - `Cargar_Datos_Grid`: `38`
  - `Buscar_Registro`: `12`

## Resultado principal
El tiempo de apertura/consulta de liquidacion se concentra en dos sub-etapas dentro de `Cargar_Datos_Grid`:

1. `POST_CALCULA_INVENTARIO_RUTA`
- max delta: `22361 ms`
- avg delta: `14128 ms`

2. `POST_RECALCULA_FACTURAS`
- max delta: `19216 ms`
- avg delta: `10149.5 ms`

Estas dos fases explican la mayor parte del tiempo total en los casos lentos.

## Evidencia puntual
Archivo `liq_384578_8010-1_cfuentes_20260608_152542_753.csv`:
- `Buscar_Registro END`: `45729 ms`
- `POST_CALCULA_INVENTARIO_RUTA`: `delta_ms=22361`
- `POST_RECALCULA_FACTURAS`: `delta_ms=19216`
- `POST_RECALCULA_FACTURAS`: `recalculadas=20|revisadas=20`

Archivo `liq_384559_0007-1_cfuentes_20260608_152452_574.csv`:
- `Buscar_Registro END`: `13007 ms` aprox. (por secuencia de eventos)
- `POST_CALCULA_INVENTARIO_RUTA`: `delta_ms=5895`
- `POST_RECALCULA_FACTURAS`: `delta_ms=1083`
- `POST_RECALCULA_FACTURAS`: `recalculadas=2|revisadas=2`

## Traza a codigo (causa tecnica)
### 1) `Calcula_Inventario_Ruta` (N+1 por producto/lote)
- Ubicacion: `Formas/Procesos/frmLiqVend.vb`
- Referencia: `Private Sub Calcula_Inventario_Ruta(...)`
- Patron observado:
  - Obtiene inventario base.
  - Recorre producto por producto.
  - En cada iteracion realiza consultas adicionales (ventas, conversiones UM, factores, etc.).
  - Uso frecuente de `DoEvents` y actualizacion de UI por item.

### 2) `RecalculaFactura` (N+1 por factura y por producto)
- Ubicacion: `Formas/Procesos/frmLiqVend.vb`
- Referencia: `Private Sub RecalculaFactura(...)`
- Patron observado:
  - Loop por detalle de factura.
  - Por cada item dispara:
    - `Get_Nivel_Precio`
    - `Get_Precio_Producto`
    - `Tiene_Nota`
    - lecturas de correlativo para notas (`MAX(CODIGONCD)` en temp/final)
    - inserts individuales en `TEMP_P_NOTACD` y `TEMP_P_NOTACDD`
  - UI refresh dentro del loop (`Application.DoEvents`).

## Propuesta de optimizacion (sin romper flujo)
## Fase 1 (quick wins, bajo riesgo)
1. Reducir repintado UI durante carga:
- encapsular `DgridVenta/gvProducto` en `BeginUpdate/EndUpdate`.
- actualizar labels de progreso por lote (cada N items) en lugar de por item.

2. Reducir llamadas repetidas por item:
- cache en memoria por corrida para:
  - `Get_Nivel_Precio(cliente)`
  - factores UM por `producto+UM`
  - `Es_Prod_Barra`, `Es_Canasta`, `Venta_Por_Peso`.

3. Evitar consulta repetida de correlativos de nota:
- resolver rango base una sola vez por corrida de `RecalculaFactura`.

## Fase 2 (DB-first, mayor impacto)
1. SP de carga agregada de inventario de ruta:
- `dbo.SP_ROAD_LIQ_INVENTARIO_RUTA_AGR_V1`
- Entrada: `@Fecha`, `@Ruta`, `@Vendedor`, `@CorelDMov`, `@CodigoLiquidacion`, `@Modo`.
- Salida: dataset agregado listo para `InvRutaList` (evitar consultas por producto).

2. SP batch para recalc de facturas:
- `dbo.SP_ROAD_LIQ_RECALC_FACTURAS_BATCH_V1`
- Entrada: `@Fecha`, `@Ruta`, `@Vendedor`, `@CodigoLiquidacion`, TVP de facturas.
- Resolver precios/notas de forma set-based en BD.
- Devolver:
  - resumen por factura (`recalculadas`, `sin_cambios`, `errores`)
  - detalle de notas a insertar.

3. TVP para insercion de notas temporales:
- `dbo.tvp_ROAD_NOTA_TEMP_DET_V1`
- insertar `TEMP_P_NOTACD/TEMP_P_NOTACDD` en lote.

## Riesgo funcional y control
- Mantener bandera de fallback:
  - si SP falla, usar logica legacy actual.
- Prueba A/B en QAS:
  - comparar totales, notas generadas, inventario final y estado de liquidacion.
- Activacion gradual por parametro (`P_EMPRESA` o flag local).

## KPI objetivo
- Abrir/consultar liquidacion:
  - bajar de `45s` a `<10s` en casos equivalentes.
- Reducir roundtrips en `Cargar_Datos_Grid`:
  - de decenas/centenas a <10 operaciones mayores por carga.
