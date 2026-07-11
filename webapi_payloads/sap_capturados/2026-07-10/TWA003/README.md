# TWA003 — Combo ZK96 A912 por ruta

## Origen

- Fuente: payload real generado por SAP.
- Fecha de captura y prueba: 2026-07-10.
- Endpoint: `POST /api/SapDescuento`.
- Rama validada: `devejc-combos-sofos`.

`request_original_sap.json` conserva el contenido funcional recibido, incluyendo los espacios finales de `regCond` y los tipos JSON enviados por SAP.

## Regla confirmada

- `AccessSequence=A912` resuelve la condición comercial por `Ruta`.
- En ROAD corresponde a `CTIPO=11`.
- `Tipologia` sólo es obligatoria para `A910`; no debe exigirse para `A912`.

## Comparación

- `response_antes_fix.json`: reproduce el defecto `#TWA003`; la API reportaba erróneamente que A912 debía enviar Tipología de A910.
- `response_despues_fix.json`: confirma que A912 avanzó por Ruta y alcanzó la validación posterior del detalle.

## Estado del payload

El payload original todavía no persiste la condición porque envía `UMVENTA=KI`, unidad que la validación vigente de ROAD no homologa. Esa regla no fue modificada por `#TWA003`.

No usar la respuesta posterior como evidencia de alta exitosa; sirve para demostrar que la selección A912/A910 fue corregida.
