# Catalogo de Escenarios - SAP Descuentos/Recargos

Este archivo documenta cada payload para facilitar pruebas, soporte y trazabilidad.

## 01_zk94_simple_a903.json

- Tipo SAP: `ZK94`
- AccessSequence: `A903`
- Caso: Descuento simple por cliente + producto
- Campos clave:
  - `cliente`: codigo cliente ROAD
  - `producto`: producto vendible QAS
  - `coddesc`: identificador de referencia ROAD
- Resultado esperado:
  - `200 OK`
  - Inserta 1 fila en `P_DESCUENTO`
  - `PTIPO=0`, `DESCTIPO='S'`, `ES_RECARGO=0`

## 02_zk95_simple_a907.json

- Tipo SAP: `ZK95`
- AccessSequence: `A907`
- Caso: Descuento porcentual por ruta + producto
- Campos clave:
  - `ruta`: ruta activa QAS
  - `producto`: producto vendible QAS
  - `importe`: porcentaje
- Resultado esperado:
  - `200 OK`
  - Inserta 1 fila en `P_DESCUENTO`
  - `CTIPO=11`, `PORPORCENTAJE='S'`

## 03_zk97_escalas_a906.json

- Tipo SAP: `ZK97`
- AccessSequence: `A906`
- Caso: Escalas por tipo cliente + producto
- Campos clave:
  - `grClientes`: tipo cliente ROAD (P_TIPOCLI)
  - `escalas[]`: rangos y valor por tramo
  - `coddesc`: misma referencia para todas las escalas
- Resultado esperado:
  - `200 OK`
  - Inserta N filas en `P_DESCUENTO` (una por escala)
  - `CTIPO=3`, `DESCTIPO='S'`

## 04_zr95_recargo_a903.json

- Tipo SAP: `ZR95`
- AccessSequence: `A903`
- Caso: Recargo porcentual por cliente + producto
- Campos clave:
  - `cliente`
  - `producto`
  - `importe`: porcentaje recargo
- Resultado esperado:
  - `200 OK`
  - Inserta 1 fila en `P_DESCUENTO`
  - `ES_RECARGO=1`, `PORPORCENTAJE='S'`

## 05_zk96_combo_a908.json

- Tipo SAP: `ZK96`
- AccessSequence: `A908`
- Caso: Combo por cliente
- Campos clave:
  - `coddesc`: id de cabecera combo
  - `grupoCombo`: nombre funcional
  - `comboItems[]`: detalle productos/cantidades
- Resultado esperado:
  - `200 OK`
  - Inserta cabecera en `P_DESCUENTO` (`PTIPO=6`, `DESCTIPO='C'`)
  - Inserta detalle en `P_DESCUENTO_COMBO_DET`

## 06_zk96_combo_a909.json

- Tipo SAP: `ZK96`
- AccessSequence: `A909`
- Caso: Combo por priorizacion (ABC)
- Campos clave:
  - `priorizacion`: clasificacion ABC
  - `centro`: informativo de integración
  - `comboItems[]`
- Resultado esperado:
  - `200 OK`
  - `CTIPO=13`
  - Cabecera + detalle combo

## 07_zk96_combo_a910.json

- Tipo SAP: `ZK96`
- AccessSequence: `A910`
- Caso: Combo por tipologia (ramo 3)
- Campos clave:
  - `tipologia`
  - `comboItems[]`
- Resultado esperado:
  - `200 OK`
  - `CTIPO=12`
  - Cabecera + detalle combo

## 08_zr96_combo_a912.json

- Tipo SAP: `ZR96`
- AccessSequence: `A912`
- Caso: Recargo combo por ruta
- Campos clave:
  - `ruta`
  - `comboItems[]`
  - `importe`: recargo combo
- Resultado esperado:
  - `200 OK`
  - `CTIPO=11`, `PTIPO=6`, `ES_RECARGO=1`
  - Cabecera + detalle combo

## Errores esperados comunes

- `400 REQ_INVALID`: faltan campos obligatorios o producto no existe/no vendible.
- `409 DUP_KEY` o `DUP_COMBO_HEADER`: ya existe una condición con la misma llave.
- `409 DUP_COMBO_CODDESC`: `coddesc` ya utilizado por otro combo.
- `401 API_KEY_REQUIRED/API_KEY_INVALID`: falta o no coincide `X-API-KEY`.
