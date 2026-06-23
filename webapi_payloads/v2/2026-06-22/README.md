# WebAPI Payloads v2 - 2026-06-22

Release documental actualizado para validación SAP -> ROAD con foco en trazabilidad y cobertura funcional.

## Objetivo del release

Documentar un set más claro de payloads para pruebas repetibles, con separación explícita de:

- casos válidos
- casos inválidos
- notas de trazabilidad
- fecha de creación del set

## Casos válidos

- [01_valid_simple_con_coddesc.json](01_valid_simple_con_coddesc.json)
- [02_valid_simple_sin_coddesc.json](02_valid_simple_sin_coddesc.json)
- [03_valid_combo_con_coddesc.json](03_valid_combo_con_coddesc.json)
- [04_valid_combo_sin_coddesc.json](04_valid_combo_sin_coddesc.json)
- [09_documentado_descuento_a903.json](09_documentado_descuento_a903.json)
- [09_documentado_descuento_a903.md](09_documentado_descuento_a903.md)

## Casos inválidos

- [05_invalid_missing_producto.json](05_invalid_missing_producto.json)
- [06_invalid_accesssequence.json](06_invalid_accesssequence.json)
- [07_invalid_combo_sin_detalle.json](07_invalid_combo_sin_detalle.json)
- [08_invalid_fechafin_menor_fechaini.json](08_invalid_fechafin_menor_fechaini.json)

## Qué cambia frente a v1

- Nombres de archivo alineados con el resultado esperado.
- Mejor separación de validos/invalidos.
- Estructura lista para crecer por fecha sin perder el historial.
- Documentación enfocada en contrato y trazabilidad, no solo en lista de archivos.

## Fechas

- Creación del release: `2026-06-22`
- Base histórica: `2026-06-01`

## Observaciones de uso

- Si un payload se reutiliza para otro escenario, no sobrescribir el archivo original.
- Para cambios de contrato o criterios de validación, crear una nueva carpeta `vN/AAAA-MM-DD/`.
- Para clasificación de trazas por hostname y tipo funcional, usar:
  - [Test Toledano - Analisis 2026-06-22](../../test_toledano_analisis_20260622/README.md)
