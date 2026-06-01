# SAP -> ROAD Field Mapping (Fase 1.2)

Documento operativo para responder: "este campo SAP, ¿dónde se guarda en ROAD?".

## Regla base
- Si un campo afecta cálculo comercial, debe mapearse a `P_DESCUENTO` / `P_DESCUENTO_COMBO_DET`.
- Si un campo es de trazabilidad/integración, puede quedar en DTO o en columnas de integración propuestas.

## Mapeo principal

| Campo SAP | Significado | Estado actual | Destino ROAD actual | Destino recomendado Fase 1.2 |
|---|---|---|---|---|
| `KSCHL` (`ZK..`/`ZR..`) | Tipo de condición | Parcial | No columna dedicada (se infiere por `ES_RECARGO`/`PORPORCENTAJE` y se concatena en `NOMBRE`) | `P_DESCUENTO.TIPO_CONDICION_EXTERNA` |
| `KNUMH` (`RegCond`) | Id condición SAP | Parcial | No columna dedicada (se concatena en `NOMBRE`) | `P_DESCUENTO.ID_CONDICION_EXTERNA` |
| `KNUMA_AG` (`Promo`) | Id promoción SAP | Parcial | No columna dedicada (se concatena en `NOMBRE`) | `P_DESCUENTO.ID_PROMOCION_EXTERNA` |
| `VKORG` (`OrgVent`) | Organización venta | No operativo | DTO | DTO / (opcional log) |
| `VTWEG` (`CanDist`) | Canal distribución | No operativo | DTO | DTO / (opcional log) |
| `SPART` (`Sector`) | Sector | No operativo | DTO | DTO / (opcional log) |
| `KUNNR` (`Cliente`) | Cliente | Sí | `P_DESCUENTO.CLIENTE` cuando `CTIPO=1` | Igual |
| `ROUTE` (`Ruta`) | Ruta | Sí | `P_DESCUENTO.CLIENTE` cuando `CTIPO=11` o equivalente de regla | Igual (alinear hardcode CTIPO) |
| `KDGRP` (`GrClientes`) | Gr.Cliente SAP (tipo cliente) | Sí | `P_DESCUENTO.CLIENTE` cuando `CTIPO=3` | Igual (usar tipo cliente ROAD / P_TIPOCLI) |
| `Cod ramo 3` | Segmento cliente SAP | Confirmado | No columna nueva | `P_CLIENTE.TIPOLOGIA` |
| `Clasificación ABC` | Priorización cliente SAP | Confirmado | No columna nueva | `P_CLIENTE.PRIORIZACION` |
| `Cod ramo 4` | Segmento cliente SAP | Pendiente | No existe hoy | Backlog definición futura |
| `Ind.Jerarq` | Selección de clave comercial | Parcial | Se traduce a `CTIPO` | Alinear catálogo hardcodeado `CTIPO 0..14` |
| `MATNR` (`Producto`) | Material | Sí | `P_DESCUENTO.PRODUCTO` | Igual; para todos los productos usar `*` |
| `PTIPO` (ROAD) | Tipo de producto | Parcial | 0..5 legado | Agregar `6 = combo` |
| `DATAB` / `DATBI` | Vigencia inicio/fin | Sí | `FECHAINI` / `FECHAFIN` | Igual |
| `KBETR` (`Importe`) | Valor condición | Sí | `VALOR` (abs) | Igual |
| `KONWA` | Unidad condición (%/moneda) | Parcial | No columna dedicada | Inferencia + (opcional trazabilidad) |
| `KPEIN` | Cantidad base | Parcial | Regla de cálculo / rangos | Regla de transformación |
| `KMEIN` | Unidad medida condición | Sí | `UMVENTA`/`UMSTOCK` | Igual |
| `KONMS` (`UM Escala`) | Unidad escala | Sí | `UMVENTA`/`UMSTOCK` en escalas | Igual |
| `KLFN1` | No línea escala | Sí | Regla de ordenamiento | Igual |
| `KSTBM` | Cantidad escala | Sí | `RANGOINI` (+ cálculo de `RANGOFIN`) | Igual |
| `ES_RECARGO` (ROAD) | Es recargo | Sí | `P_DESCUENTO.ES_RECARGO` | Igual |
| `PORPORCENTAJE` (ROAD) | Valor %/monto | Sí | `P_DESCUENTO.PORPORCENTAJE` | Igual |
| `PRIORIDAD` (ROAD) | Prioridad evaluación | Sí | `P_DESCUENTO.PRIORIDAD` | Igual |
| Combo detalle | Productos combo | Sí | `P_DESCUENTO_COMBO_DET` | Igual + aclarar rol `D/B` |

## Puntos donde hoy hay ambigüedad (y se corrige con ALTER propuesto)
1. `KSCHL` (`ZK..`/`ZR..`) no tiene columna clara actual.
2. `RegCond` y `Promo` no tienen columna clara actual.
3. Traza técnica (`traceId`) no tiene columna clara actual.

Columnas propuestas para cerrar eso:
- `TIPO_CONDICION_EXTERNA`
- `ID_CONDICION_EXTERNA`
- `ID_PROMOCION_EXTERNA`
- `ID_TRAZA_INTEGRACION`

## Regla ROAD confirmada
- `GLOBDESC='S'`: aplica al total factura (totalización).
- `GLOBDESC='N'`: aplica por producto (línea).
- `PRODUCTO='*'`: aplica a todos los productos.
