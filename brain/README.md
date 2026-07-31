# ROAD Toledano - Setup YAML + Jira Portable

Este paquete contiene dos capas:

1. Contexto funcional SAP -> ROAD para promociones (YAML).
2. Instrumentacion portable para trabajo de agentes con Jira (plantillas + script + guia).

La idea es reutilizar exactamente la misma estructura en otros proyectos, cambiando solo una configuracion.

## Regla de separacion de repositorios

Los archivos de contexto, analisis, graph-path, decisiones y scripts documentales del Brain
viven exclusivamente en este repositorio `toledano-brain`, bajo `brain/` o `dba_changes/`.
No deben crearse ni mantenerse dentro del repositorio de codigo fuente `ROAD_TOLEDANO`.
El repositorio de codigo conserva solamente implementacion y artefactos tecnicos necesarios
para compilar o ejecutar el producto.

## Contexto funcional existente

- `knowledge_manifest_2026-07-31.yml`: manifiesto canonico vigente y aislamiento de proyectos.
- `project_identity_and_repo_guardrails_2026-07-31.yml`: firmas de ROAD y exclusion de TOMWMS/TOMHH2025.
- `hh_runtime_handoff_2026-07-31.yml`: snapshot de `road_2028`, cambios desde TC0011 y caso Rosti 0629.
- `hh_promotion_observability_contract_2026-07-31.yml`: eventos y reason codes para explicar promociones no aplicadas.

- `project_context.yml`: contexto funcional, alcance, reglas confirmadas y puntos abiertos.
- `hh_android_fm_ncnd_port_contract_2026-07-21.yml`: contrato canónico para portar a HH Android/Java el cálculo extendido SAP, idempotencia, combos y decisiones NC/ND de Facturación Manual.
- `hh_android_discounts_deep_scan_and_fix_proposal_2026-07-21.md`: estado del arte de HH y lista quirúrgica tageada para aprobación del equipo.
- `knowledge_manifest_2026-07-24.yml`: manifiesto canónico, commits verificados, contratos y etiquetas de recuperación.
- `codex_carol_restore_2026-07-24.md`: procedimiento portable para instalar el skill y reconstruir vectores en Codex.
- `bof_combo_priority_fm_ncnd_hh_contract_2026-07-23.yml`: prioridad documental de combos y contrato de reproducción HH.
- `integration_mapping.yml`: mapeo SAP -> ROAD, tipos de condicion, combinaciones A903/A907/A906 y A908-A912, con notas A909/A910 y trazabilidad RegCond.
- `change_log_bitacora.yml`: bitacora cronologica de correos, acuerdos, demoras, cambios y trazabilidad.
- `codex_setup.yml`: setup recomendado para Codex, rutas sugeridas, secuencia de implementacion y prompt base.
- `implementation_tasks.yml`: backlog tecnico por base de datos, API, logica de negocio, pruebas y codigos de error.
- `code_tagging_conventions.yml`: estandar de tags en codigo/commit para trazabilidad tecnica y Jira.

## Nueva capa portable para Jira

Ruta: `jira_portable/`

- `jira_portable/scripts/jira_portable.py`: helper reusable para crear/comentar/transicionar issues, epicas y sprint.
- `jira_portable/project.jira.config.example.yml`: ejemplo de configuracion por proyecto.
- `jira_portable/AGENTS_JIRA_TEMPLATE.md`: bloque portable para AGENTS.md / prompt de sistema.
- `jira_portable/docs/jira_playbook.md`: proceso operativo recomendado para usar Jira con Codex.
- `jira_portable/templates/*.md`: formatos listos para updates de progreso, bloqueos y cierre.

## Como integrarlo en otro proyecto (copy/paste)

1. Copiar la carpeta `jira_portable/` al nuevo repo.
2. Duplicar `project.jira.config.example.yml` como `project.jira.config.yml`.
3. Ajustar al nuevo proyecto:
   - `project.key`, `project.board_id`
   - `project.issue_types`, `project.statuses`
   - `project.epic_default_key`
4. Exportar variables de entorno (`JIRA_URL`, `JIRA_EMAIL`, `JIRA_TOKEN`, `JIRA_ACCOUNT_ID`).
5. Usar el bloque de `AGENTS_JIRA_TEMPLATE.md` en el `AGENTS.md` del repo destino.
6. Ejecutar el script helper para operar Jira desde terminal o desde el agente.

## Nota de contexto (ROBO / ROAD)

Se incorporo el contexto que compartiste en `pasted-text.txt` (board ROAD, tipos/estados, sprint activo y epica principal) como base de esta instrumentacion, pero en formato parametrizable para no quedar amarrado a un solo proyecto.

## Actualizacion 2026-07-01

- Se agrego la semantica de persistencia para descuentos: `PersistenceAction` + `PersistenceDecision`.
- Se incorporo `RegCond` como llave de trazabilidad para distinguir solicitudes SAP repetidas.
- Se ratifico `A910 -> Tipologia = Ramo 3`.
- Se dejo documentado el fix TDS001/TDS002 para evitar colision de condiciones por `CODDESC` repetido.
