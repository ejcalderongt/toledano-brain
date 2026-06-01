# ROAD Toledano - Quick Context

## Alcance funcional

- Integración SAP -> ROAD para descuentos/recargos y combos.
- Flujo operativo completo: WebAPI -> BOF/RDC7 -> HH -> sincronización/fin de día.

## Reglas confirmadas

- `CTIPO` es catálogo fijo hardcoded en BOF/HH (0..14).
- `PTIPO` es catálogo fijo; en fase 1.2 se incorpora `6=combo`.
- `A906/KDGRP` se interpreta como tipo cliente ROAD (`P_TIPOCLI`) y mapea a `CTIPO=3`.
- `CODDESC` debe persistirse cuando venga en payload SAP, incluyendo simples/escalas.
- `GLOBDESC='S'` aplica a total factura; `GLOBDESC='N'` por línea producto.
- `CLIENTE='*'` aplica a todos según `CTIPO`.
- `PRODUCTO='*'` aplica a todos los productos.
- Rama HH vigente para análisis funcional: `dev_road_2024_bak3`.

## Combinaciones SAP relevantes

- No combos: A903, A906, A907.
- Combos: A908, A909, A910, A911, A912.
- `A911` (ramo4) puede quedar en backlog si aún no está definido en ROAD.

## Integración WebAPI

- Controlador principal: `SapDescuentoController`.
- Alias operativo de endpoint: `/api/sap/descuentos`.
- Payloads de referencia QAS-ready: `ROADWedAPI/payloads/sap_descuentos/`.

## Convenciones

- Etiquetado inline: `#EJCYYYYMMDD tipo(area): descripcion`.
- Usar `warning` cuando haya riesgo confirmado sin resolver.
- Mantener trazabilidad en `road_toledano_agent_setup/*`.

## Evidencia mínima para validar cambios

1. Build de proyecto afectado.
2. Payload/request de prueba si aplica WebAPI.
3. Resultado esperado vs real.
4. Verificación de impacto sobre datos/tablas.
