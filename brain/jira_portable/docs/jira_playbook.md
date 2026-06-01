# Jira Playbook Portable (Codex)

Este playbook estandariza como reportar trabajo tecnico en Jira desde Codex, sin acoplarse a un proyecto unico.

## Objetivo

- Mantener trazabilidad tecnica consistente.
- Reducir friccion al mover el agente entre repos.
- Reusar la misma estructura cambiando solo `project.jira.config.yml`.

## Flujo recomendado por tarea

1. Verificar si ya existe issue relacionado.
2. Si no existe, crear issue con tipo correcto.
3. Asociar a epica objetivo si aplica.
4. Mover al sprint activo cuando corresponda.
5. Comentar progreso con evidencia tecnica.
6. Transicionar a finalizada al cerrar trabajo.

## Regla para decidir crear vs comentar

- Crear issue:
  - Trabajo nuevo sin ticket previo.
  - Cambio de alcance que amerita trazabilidad separada.
- Comentar issue existente:
  - Avance de una tarea ya abierta.
  - Ajustes o hotfixes dentro del alcance actual.

## Estructura de comentario recomendada

Usar plantilla de `templates/jira-update-progress.md` o `templates/jira-update-done.md`.

Campos minimos:
- Contexto del cambio.
- Archivos tocados.
- Riesgo/impacto.
- Pruebas ejecutadas.
- Siguiente paso.

## Integracion con AGENTS.md

Agregar el bloque de `AGENTS_JIRA_TEMPLATE.md` en el AGENTS del repo destino.
Ese bloque define:
- variables requeridas,
- convenciones de reporte,
- flujo de actualizacion en Jira.

## Actualizacion de campos complementarios

Para issues ya creados, aplicar este orden:

1. `PUT /rest/api/3/issue/{key}` con:
   - `description` (ADF)
   - `customfield_10015` (Start date)
   - `duedate` (fecha de vencimiento)
   - `customfield_10016` (story points)
2. `POST /rest/api/3/issue/{key}/worklog` para horas utilizadas.
3. Transicion de estado cuando corresponda (`En curso` o `Finalizada`).

Formato recomendado de descripcion:
- Problema
- Que arruinaba / impacto
- Causa raiz
- Fix aplicado
- Archivos/commits de trazabilidad

Nota: `Horas_Utilizadas` es acumulativo por worklogs, no se setea directo por `PUT`.

## Portabilidad a otro proyecto

1. Copiar carpeta `jira_portable/`.
2. Duplicar config de ejemplo y completar ids reales.
3. Ajustar keyword scope para epica por defecto.
4. Probar `list-epics` y `active-sprint`.
5. Ejecutar una creacion de issue de prueba.
