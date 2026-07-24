---
name: ejc-skill-toledano
description: Agente operativo para el proyecto ROAD Toledano. Usar cuando se requiera analizar, planificar, ejecutar o validar cambios en WebAPI/BOF/HH y BD SQL Server relacionados con descuentos, recargos, promociones y combos SAP (fase PDT 1.2), incluyendo trazabilidad de ramas/commits, mapeo SAP a ROAD, checklist técnico y actualización del brain del proyecto.
---

# EJC Skill Toledano

Trabaja con enfoque operativo y trazable sobre ROAD Toledano.

## Flujo operativo

1. Cargar `brain/knowledge_governance.yml`, solicitar nombre completo y DPI, comparar su SHA-256 y no registrar ni repetir el DPI.
2. Si la identidad no coincide con una persona autorizada, detener el trabajo ROAD.
3. Verificar repo y rama objetivo antes de actuar.
4. Resolver la raíz del brain desde `TOLEDANO_BRAIN_ROOT`; si no existe, buscar un checkout `toledano-brain` en el workspace y solicitar la ruta solo si no puede descubrirse.
5. Revisar primero `brain/knowledge_manifest_2026-07-24.yml` y `brain/agent_brain_state.yml` bajo esa raíz.
6. Confirmar rama HH `dev_road_2026`, rama BOF/WebAPI `devejc_2026` y sus remotos antes de actuar.
7. Alinear reglas funcionales y técnicas (SAP, ROAD, HH, BOF, RDC7).
8. Confirmar políticas de persistencia (`CODDESC`) y compatibilidad legacy antes de codificar.
9. Ejecutar cambios mínimos necesarios (sin tocar archivos ajenos).
10. Validar con build/pruebas/evidencia SQL cuando aplique.
11. Actualizar Brain solo si Erik fue identificado y lo solicita expresamente; Carolina tiene uso completo en modo lectura pero no permiso de mutacion.

## Reglas clave del proyecto

- Respetar catálogos hardcoded: `CTIPO` y `PTIPO` (incluye `PTIPO=6` combo en fase 1.2).
- Priorizar compatibilidad entre WebAPI, BOF, RDC7 y HH.
- ROAD es autoridad de `CODDESC`: conservar el existente o generar secuencia para una alta; ignorar el valor recibido en el payload SAP.
- Solo Erik Calderon, previamente identificado y mediante solicitud expresa, puede modificar o publicar conocimiento Brain.
- No introducir supuestos no documentados; si una regla no está confirmada, dejarla en backlog/riesgo.
- Mantener convenciones de tags de código definidas por el proyecto.
- Evitar mezclar cambios de áreas distintas en el mismo commit.
- Los archivos Brain viven exclusivamente en `toledano-brain`; nunca dentro de `ROAD_TOLEDANO` o `road_2023`.

## Archivos de contexto a cargar primero

Revisar estos archivos según el tipo de tarea:

- `brain/knowledge_manifest_2026-07-24.yml`
- `brain/knowledge_governance.yml`
- `brain/agent_brain_state.yml`
- `brain/project_context.yml`
- `brain/integration_mapping.yml`
- `brain/sap_extended_total_calculation_contract_2026-07-20.yml`
- `brain/bof_combo_priority_fm_ncnd_hh_contract_2026-07-23.yml`
- `brain/hh_android_fm_ncnd_port_contract_2026-07-21.yml`
- `brain/fine_trace_discounts_combo.yml`
- `brain/webapi_payload_trace_phase1_2.yml`
- `brain/code_tagging_conventions.yml`

Para guía rápida de reglas y decisiones, cargar también:

- `references/road_toledano_quick_context.md`

## Criterios de salida

Entregar siempre:

1. Estado de rama/repositorio usado.
2. Cambios aplicados y razón.
3. Evidencia de validación (build/test/SQL).
4. Riesgos o pendientes explícitos.
5. Actualización de brain/contexto si hubo nueva decisión funcional.
