# ROAD Toledano - Quick Context (actualizado 2026-08-28)

## Alcance funcional

- Integración SAP -> ROAD para descuentos/recargos y combos.
- Flujo operativo completo: WebAPI -> BOF/RDC7 -> HH -> sincronización/fin de día.

## Reglas confirmadas

- `CTIPO` es catálogo fijo hardcoded en BOF/HH (0..14).
- `PTIPO` es catálogo fijo; en fase 1.2 se incorpora `6=combo`.
- `A906/KDGRP` se interpreta como tipo cliente ROAD (`P_TIPOCLI`) y mapea a `CTIPO=3`.
- ROAD es autoridad de `CODDESC`: una condición existente conserva el suyo y una alta nueva usa `SEQ_P_DESCUENTO_CODDESC`; se ignora el valor del payload SAP.
- No se requiere identificacion para leer, analizar, modelar, probar o cambiar ROAD. Solo la mutacion/publicacion del Brain requiere Erik identificado y solicitud expresa.
- `GLOBDESC='S'` aplica a total factura; `GLOBDESC='N'` por línea producto.
- `CLIENTE='*'` aplica a todos según `CTIPO`.
- `PRODUCTO='*'` aplica a todos los productos.
- HH observado: rama `road_2028`, commit `f8e29a38`; `b3ebe72` queda como baseline historico TC0011.
- BOF observado en la estacion de Carolina: rama `devejc_hotfix_2026`, commit `84e3ce9f`, con cambios locales que deben preservarse.
- El total extendido es autoritativo y el precio unitario promocional se deriva a 6 decimales.
- Precio especial y promociones son excluyentes; sin especial se conserva `P_PRODPRECIO`.
- Combo completo reemplaza el ajuste individual cuando cantidad comprada >= requerida.
- Pueden coexistir N combos completos cuando sus productos son disjuntos; los combos que comparten producto se rechazan solo entre si.
- Un pedido HH abierto para modificar conserva la promocion persistida. Tras una mutacion, la reevaluacion debe usar la UM comercial dinamica de cada producto.
- `DevolBodCan` debe usar NC activas no anuladas y no asociadas a ND desde `D_NOTACRED/D_NOTACREDD`, con el mismo criterio hasta `D_MOVDCAN`.
- `I_SAP_VENTAS.REFERENCIA` alimenta `MI3_SAP.ORDEN_COMPRA`.
- En liquidacion, una cola correcta no evita contencion por transacciones largas, snapshot bloqueante o staging global; diagnosticar las capas por separado.
- El contrato detallado de estas reglas es `brain/recent_operational_knowledge_2026-08-28.yml`.

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
- ROAD HH se identifica por remoto `road_2023`, paquete `com.dts.roadp` y firmas `Precio.java`, `Venta.java`, `ComWS.java`.
- Nunca usar TOMHH2025, TOMWMS, TOMIMSV4 o `com.dts.tom` como evidencia ROAD.
- `PromotionTrace` escribe CSV privado; Logcat solo informa errores de escritura. Los casos sin candidatos requieren eventos negativos explicitos.

## Evidencia mínima para validar cambios

1. Build de proyecto afectado.
2. Payload/request de prueba si aplica WebAPI.
3. Resultado esperado vs real.
4. Verificación de impacto sobre datos/tablas.
