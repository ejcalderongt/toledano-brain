# WebAPI Payloads - Índice de Pruebas

Repositorio documental de payloads JSON para validar el contrato de integración SAP -> ROAD.

## Cómo leer esta carpeta

- `v1/2026-06-01/`: set histórico inicial, conservado como referencia funcional.
- `v2/2026-06-22/`: set actualizado con trazabilidad, casos válidos e inválidos y notas de cambio.
- `sap_capturados/`: payloads reales recibidos desde SAP, preservados para regresión y comparación.

## Releases

### v1 - 2026-06-01

Base documental original de pruebas.

- [README del release v1](v1/2026-06-01/README.md)
- [Catálogo técnico v1](v1/2026-06-01/CATALOGO_ESCENARIOS.md)

### v2 - 2026-06-22

Release documental actualizado con:

- Nombres de archivo más descriptivos.
- Separación explícita entre casos válidos e inválidos.
- Trazabilidad del contrato SAP/ROAD.
- Estructura lista para agregar futuras iteraciones sin sobrescribir la anterior.

- [README del release v2](v2/2026-06-22/README.md)

### Analisis por fecha - 2026-06-22

Carpeta de trabajo para clasificar trazas y payloads de validacion por tipo funcional.

- [Indice de analisis 2026-06-22](test_toledano_analisis_20260622/README.md)

### Payloads reales capturados desde SAP

- [TWA003 — ZK96/A912 por ruta](sap_capturados/2026-07-10/TWA003/README.md)

## Convención de versionado

- `v1`: referencia histórica, no se sobrescribe.
- `v2`: nueva generación de payloads con fecha de creación.
- Releases futuros deben seguir el patrón `vN/AAAA-MM-DD/`.
- Los payloads reales de SAP deben conservarse bajo `sap_capturados/AAAA-MM-DD/CASO/` sin sobrescribir el original.

## Reglas de uso

- No mezclar payloads de distintas versiones en la misma carpeta.
- Si cambia el contrato o la validación, crear un nuevo folder de release.
- Si un caso queda obsoleto, conservarlo en su versión original y documentar la sustitución en el README del release nuevo.
