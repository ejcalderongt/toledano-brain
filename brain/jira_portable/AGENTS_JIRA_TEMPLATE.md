# Integracion Codex -> Jira (Portable)

Usa este bloque en `AGENTS.md` del repo donde quieras operar Jira.

## Variables de entorno requeridas

```text
JIRA_URL
JIRA_EMAIL
JIRA_TOKEN
JIRA_ACCOUNT_ID
```

## Config por proyecto

- Archivo: `jira_portable/project.jira.config.yml`
- Nunca guardar tokens o passwords en el repo.

## Flujo operativo

1. Verificar si existe issue.
2. Crear issue si no existe.
3. Asignar epica si aplica.
4. Mover al sprint activo.
5. Comentar avance tecnico.
6. Transicionar al estado final cuando corresponda.

## Criterio de trazabilidad minima

Cada update en Jira debe incluir:
- cambio implementado,
- archivos/modulos impactados,
- pruebas ejecutadas,
- riesgo residual.

## Comandos base (script portable)

```bash
python jira_portable/scripts/jira_portable.py --config jira_portable/project.jira.config.yml list-epics
python jira_portable/scripts/jira_portable.py --config jira_portable/project.jira.config.yml active-sprint
python jira_portable/scripts/jira_portable.py --config jira_portable/project.jira.config.yml create-issue --summary "Resumen" --description "Detalle" --type-id 10017 --epic-key ROAD-XX
python jira_portable/scripts/jira_portable.py --config jira_portable/project.jira.config.yml comment --issue-key ROAD-1 --text "Avance tecnico..."
python jira_portable/scripts/jira_portable.py --config jira_portable/project.jira.config.yml transition --issue-key ROAD-1 --status-id 10012
```
