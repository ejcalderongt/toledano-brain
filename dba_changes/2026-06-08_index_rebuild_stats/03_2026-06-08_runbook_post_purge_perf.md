# Runbook - Post Purge Performance Recovery (QAS + PRD)

Fecha: 2026-06-08

## Objetivo
Proceso repetible para diagnosticar y recuperar rendimiento después de eliminación masiva de datos históricos.

## Hipótesis técnica
- La purga reduce filas pero puede degradar planes por:
  - estadísticas desalineadas,
  - fragmentación/page density inestable,
  - planes de ejecución “anclados” al patrón anterior.

## Pasos (siempre en este orden)
1. Ejecutar diagnóstico base:
   - `2026-06-08_diag_fragmentacion_stats_v1.sql`
2. Ejecutar mantenimiento controlado:
   - `2026-06-08_maintenance_rebuild_stats_v1.sql`
3. Ejecutar diagnóstico posterior:
   - `2026-06-08_diag_fragmentacion_stats_v1.sql`
4. Ejecutar health check SQL:
   - `tools/sql_perf_diagnose.py`
5. Comparar resultados y documentar en `execution_logs/<timestamp>/`.

## Criterios de éxito
- Menor costo promedio en top queries de liquidación.
- Reducción de waits de lock e I/O (LCK*, PAGEIOLATCH*, WRITELOG).
- Mejora observable en tiempos de `Buscar_Registro` y `Cargar_Datos_Grid`.

## Nota operativa
- Aplicar primero en QAS.
- Pasar a PRD solo con evidencia de no-regresión y mejora.

