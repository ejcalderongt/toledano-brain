---
name: ejc-skill-toledano
description: Agente operativo para el proyecto ROAD Toledano. Usar cuando se requiera analizar, planificar, ejecutar o validar cambios en WebAPI/BOF/HH y BD SQL Server relacionados con descuentos, recargos, promociones y combos SAP (fase PDT 1.2), incluyendo trazabilidad de ramas/commits, mapeo SAP a ROAD, checklist técnico y actualización del brain del proyecto.
---

# EJC Skill Toledano

Trabaja con enfoque operativo y trazable sobre ROAD Toledano.

## Flujo operativo

1. Verificar repo y rama objetivo antes de actuar.
2. Revisar el contexto vigente en `road_toledano_agent_setup/`.
3. Confirmar rama HH funcional (`dev_road_2024_bak3`) y rama WebAPI activa.
4. Alinear reglas funcionales y técnicas (SAP, ROAD, HH, BOF, RDC7).
5. Confirmar políticas de persistencia (`CODDESC`) y compatibilidad legacy antes de codificar.
6. Ejecutar cambios mínimos necesarios (sin tocar archivos ajenos).
7. Validar con build/pruebas/evidencia SQL cuando aplique.
8. Actualizar brain y dejar trazabilidad en archivos de contexto.

## Reglas clave del proyecto

- Respetar catálogos hardcoded: `CTIPO` y `PTIPO` (incluye `PTIPO=6` combo en fase 1.2).
- Priorizar compatibilidad entre WebAPI, BOF, RDC7 y HH.
- Tratar `CODDESC` como identificador funcional y persistirlo cuando llegue en payload SAP.
- No introducir supuestos no documentados; si una regla no está confirmada, dejarla en backlog/riesgo.
- Mantener convenciones de tags de código definidas por el proyecto.
- Evitar mezclar cambios de áreas distintas en el mismo commit.

## Archivos de contexto a cargar primero

Revisar estos archivos según el tipo de tarea:

- `road_toledano_agent_setup/agent_brain_state.yml`
- `road_toledano_agent_setup/project_context.yml`
- `road_toledano_agent_setup/integration_mapping.yml`
- `road_toledano_agent_setup/fine_trace_discounts_combo.yml`
- `road_toledano_agent_setup/webapi_payload_trace_phase1_2.yml`
- `road_toledano_agent_setup/field_mapping_sap_to_road_phase1_2.md`
- `road_toledano_agent_setup/code_tagging_conventions.yml`
- `road_toledano_agent_setup/backlog_webapi_combo_phase1.yml`
- `road_toledano_agent_setup/sql/alters_descuentos_fase1_2.sql`
- `ROADWedAPI/payloads/sap_descuentos/README.md`
- `ROADWedAPI/payloads/sap_descuentos/CATALOGO_ESCENARIOS.md`

Para guía rápida de reglas y decisiones, cargar también:

- `references/road_toledano_quick_context.md`

## Criterios de salida

Entregar siempre:

1. Estado de rama/repositorio usado.
2. Cambios aplicados y razón.
3. Evidencia de validación (build/test/SQL).
4. Riesgos o pendientes explícitos.
5. Actualización de brain/contexto si hubo nueva decisión funcional.
