# jira_portable.py

Helper de Jira portable para cualquier proyecto con Codex.

## Dependencias

```bash
pip install requests pyyaml
```

## Variables de entorno requeridas

```powershell
$env:JIRA_URL        = "https://tu-org.atlassian.net"
$env:JIRA_EMAIL      = "tu-correo"
$env:JIRA_TOKEN      = "<token>"
$env:JIRA_ACCOUNT_ID = "<account-id>"
```

No guardar estos valores en archivos versionados.

## Config

1. Copiar `../project.jira.config.example.yml` como `../project.jira.config.yml`.
2. Ajustar proyecto, board, issue types y estados.

## Ejemplos de uso

```bash
python jira_portable.py --config ..\project.jira.config.yml list-epics
python jira_portable.py --config ..\project.jira.config.yml active-sprint
python jira_portable.py --config ..\project.jira.config.yml create-issue --summary "Ajuste API promo" --description "Se ajusta validacion de vigencia" --type-id 10017 --epic-key ROAD-58
python jira_portable.py --config ..\project.jira.config.yml create-issue --summary "Ajuste API promo" --description "Se ajusta validacion de vigencia" --type-id 10017 --epic-key ROAD-58 --assignee erik
python jira_portable.py --config ..\project.jira.config.yml comment --issue-key ROAD-101 --text "Se implemento validacion en endpoint y pruebas unitarias."
python jira_portable.py --config ..\project.jira.config.yml transition --issue-key ROAD-101 --status-id 10012
python jira_portable.py --config ..\project.jira.config.yml move-to-sprint --issue-keys ROAD-101,ROAD-102 --sprint-id 3577
python jira_portable.py --config ..\project.jira.config.yml assign-issue --issue-key ROAD-101 --assignee erik
python jira_portable.py --config ..\project.jira.config.yml update-issue --issue-key ROAD-101 --start-date 2026-06-01 --due-date 2026-06-01 --story-points 5 --description "Problema, causa raiz y fix aplicado."
python jira_portable.py --config ..\project.jira.config.yml log-work --issue-key ROAD-101 --time-spent "8h" --comment "Codex: implementacion + validacion"
python jira_portable.py --config ..\project.jira.config.yml update-full --issue-key ROAD-101 --start-date 2026-06-01 --due-date 2026-06-01 --story-points 5 --description "Detalle tecnico" --time-spent "8h" --work-comment "Codex: cierre tecnico"
```

## Campos complementarios recomendados (post-creacion)

Despues de crear un issue, completar:

1. `Start date` (`customfield_10015`)
2. `Due date` (`duedate`)
3. `Story points` (`customfield_10016`)
4. `Descripcion tecnica detallada` (ADF)
5. `Worklog` con horas utilizadas

Esta secuencia deja trazabilidad estandar para seguimiento tecnico y auditoria.

## Asignacion correcta (Jira Cloud)

- NO usar `name` ni `displayName` para assignee.
- Usar siempre `accountId`.
- Este script acepta alias humanos (`erik`, `dts`, `axel`) y resuelve a `accountId`.
- Si no encuentra alias local, usa fallback con `GET /rest/api/3/user/search`.
