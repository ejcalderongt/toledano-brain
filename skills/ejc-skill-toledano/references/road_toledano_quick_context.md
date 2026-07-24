# ROAD Toledano - Quick Context

## Alcance funcional

- Integración SAP -> ROAD para descuentos/recargos y combos.
- Flujo operativo completo: WebAPI -> BOF/RDC7 -> HH -> sincronización/fin de día.

## Reglas confirmadas

- `CTIPO` es catálogo fijo hardcoded en BOF/HH (0..14).
- `PTIPO` es catálogo fijo; en fase 1.2 se incorpora `6=combo`.
- `A906/KDGRP` se interpreta como tipo cliente ROAD (`P_TIPOCLI`) y mapea a `CTIPO=3`.
- ROAD es autoridad de `CODDESC`: una condición existente conserva el suyo y una alta nueva usa `SEQ_P_DESCUENTO_CODDESC`; se ignora el valor del payload SAP.
- Antes de trabajar, aplicar `brain/knowledge_governance.yml`; solo Erik identificado puede autorizar cambios al Brain.
- `GLOBDESC='S'` aplica a total factura; `GLOBDESC='N'` por línea producto.
- `CLIENTE='*'` aplica a todos según `CTIPO`.
- `PRODUCTO='*'` aplica a todos los productos.
- Rama HH vigente: `dev_road_2026`; commit validado TC0011: `b3ebe72`.
- Rama BOF/WebAPI vigente: `devejc_2026`; commit validado TC0012: `a3d52989`.
- El total extendido es autoritativo y el precio unitario promocional se deriva a 6 decimales.
- Precio especial y promociones son excluyentes; sin especial se conserva `P_PRODPRECIO`.
- Combo completo reemplaza el ajuste individual cuando cantidad comprada >= requerida.

## Combinaciones SAP relevantes

- No combos: A903, A906, A907.
- Combos: A908, A909, A910, A911, A912.
- `A911` (ramo4) puede quedar en backlog si aún no está definido en ROAD.

## Integración WebAPI

- Controlador principal: `SapDescuentoController`.
- Alias operativo de endpoint: `/api/sap/descuentos`.
- Payloads de referencia QAS-ready: `ROADWedAPI/payloads/sap_descuentos/`.
- Seguimiento 2026-06-03:
  - Se documenta `DELETE /api/sap/descuentos` para baja segura por `coddesc` o `llave operativa`.
  - Requiere `confirmacion='ELIMINAR'`.
  - En combos, borrado transaccional: `P_DESCUENTO_COMBO_DET` -> `P_DESCUENTO`.
  - Si hay multiples coincidencias sin `forzarMultiples=true`, responder `MULTIPLE_MATCH`.

## Convenciones

- Etiquetado inline: `#EJCYYYYMMDD tipo(area): descripcion`.
- Usar `warning` cuando haya riesgo confirmado sin resolver.
- Mantener trazabilidad exclusivamente en el repositorio `toledano-brain/brain/*`.

## Evidencia mínima para validar cambios

1. Build de proyecto afectado.
2. Payload/request de prueba si aplica WebAPI.
3. Resultado esperado vs real.
4. Verificación de impacto sobre datos/tablas.
