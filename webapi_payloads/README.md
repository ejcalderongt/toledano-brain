# Payloads de prueba SAP -> ROAD (QAS Ready)

## Endpoint

- `POST /api/SapDescuento`
- `POST /api/sap/descuentos` (ruta contractual)
- `DELETE /api/sap/descuentos` (borrado seguro por codigo o llave)

## Headers

- `Content-Type: application/json`
- `X-API-KEY: <valor configurado en Security:ApiKeySap>` (si aplica)

## Convenciones de estos payloads

- Están preparados con datos reales de QAS para validación funcional.
- Incluyen `coddesc` para trazabilidad HH/BOF y evitar `CODDESC` nulo.
- Incluyen `reemplazarExistente=true` para que WebAPI elimine registros ROAD previos del mismo `CODDESC`/llave antes de insertar la nueva versión.
- En combos no se usa semántica funcional `A/B`; el detalle solo define productos/cantidades.

## Escenarios

- `01_zk94_simple_a903.json`
- `02_zk95_simple_a907.json`
- `03_zk97_escalas_a906.json`
- `04_zr95_recargo_a903.json`
- `05_zk96_combo_a908.json`
- `06_zk96_combo_a909.json`
- `07_zk96_combo_a910.json`
- `08_zr96_combo_a912.json`
- `09_delete_por_coddesc.json`
- `10_delete_por_llave_a903.json`

## Guía de lectura

- Ver catálogo funcional y técnico en `CATALOGO_ESCENARIOS.md`.
- Si se re-ejecutan payloads con misma llave, pueden devolver `409` por duplicidad (esperado).
