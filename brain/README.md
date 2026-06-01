# ROAD Toledano - Setup YAML + Jira Portable

Este paquete contiene dos capas:

1. Contexto funcional SAP -> ROAD para promociones (YAML).
2. Instrumentacion portable para trabajo de agentes con Jira (plantillas + script + guia).

La idea es reutilizar exactamente la misma estructura en otros proyectos, cambiando solo una configuracion.

## Contexto funcional existente

- `project_context.yml`: contexto funcional, alcance, reglas confirmadas y puntos abiertos.
- `integration_mapping.yml`: mapeo SAP -> ROAD, tipos de condicion, combinaciones A903/A907/A906 y A908-A912.
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
