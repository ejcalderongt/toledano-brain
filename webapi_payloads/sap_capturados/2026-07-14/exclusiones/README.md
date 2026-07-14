# Exclusiones cliente-producto SAP — evidencia QAS

Endpoint: `POST /api/sap/exclusiones-descuento`

1. `create.json`: HTTP 200, `CREATED`, `CODCLIPRODEXC=1`, traza 1335.
2. Reenvío: HTTP 200, `NO_CHANGE`, traza 1336.
3. `deactivate.json`: HTTP 200, `DEACTIVATED`, traza 1337.

La fila `0001000265 + 0220` quedó con `ACTIVO=0`. La API key no se conserva.
