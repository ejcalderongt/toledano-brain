# toledano-brain

Repositorio de recuperación de contexto operativo del proyecto ROAD Toledano.

## Contenido

- `INTEGRACION_SAP_ROAD_WEBAPI.md`: guía técnica publicable para integración SAP ABAP/PI.
- `CONTEXT_ROAD_WEBAPI.md`: endpoint QAS actual.
- `brain/`: contexto, backlog, mapeos, playbooks y trazabilidad del proyecto.
- `skills/ejc-skill-toledano/`: skill local del agente con referencias y configuración.
- `webapi_payloads/`: índice versionado de payloads JSON por release para pruebas de descuentos/recargos/combos.
- `brain/sql/`: diagnósticos, scripts de alter y notas de traza/persistencia para el flujo SAP -> ROAD.

## Fuente

Sincronizado desde entornos locales de trabajo ROAD_TOLEDANO a fecha 2026-07-01.

## Actualizacion de conocimiento

- `A910` quedó confirmado como `Tipologia = Ramo 3`.
- `RegCond` ahora se usa como ancla de trazabilidad y persistencia para distinguir envíos SAP repetidos.
- La respuesta del WebAPI expone `PersistenceAction` y `PersistenceDecision` para diferenciar alta, actualización y reemplazo.
- Se documentó el fix TDS001/TDS002 para evitar que códigos repetidos de SAP colapsen condiciones distintas.
