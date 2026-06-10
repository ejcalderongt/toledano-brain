# Informe Ejecutivo de Rendimiento (Release)

Fecha: 2026-06-09  
Alcance: proceso de liquidación `frmLiqVend` (consulta/edición y generación automática de DL).

## 1) Cambios Aplicados en PRD (impacto directo en rendimiento)

### Precheck de generación automática de DL
- Se aplicó en PRD el SP `dbo.usp_LiqVend_DLAuto_Precheck_v1`.
- Objetivo: evitar ejecutar etapas completas de DL/DC cuando no hay candidatos.
- Resultado esperado: menos trabajo innecesario y menor tiempo total del botón de generación automática.

### Batch set-based para inventario de ruta
- Se aplicó en PRD `dbo.usp_LiqVend_InventarioRuta_Detalle_v1` (versión set-based con TVP).
- Objetivo: reducir roundtrips y eliminar consultas N+1 en cálculo de inventario.
- Resultado esperado: menor latencia en `POST_CALCULA_INVENTARIO_RUTA` y menor presión por concurrencia.

### Consolidación transaccional de cabecera merma
- Se aplicó en PRD `dbo.usp_LiqVend_DL_Merma_Finaliza_v1`.
- Objetivo: unificar updates repetidos de cabecera (`P_LIQUIDACION` + `TEMP_P_DIFLIQ`) en un paso transaccional.
- Resultado esperado: menos viajes a BD y menor riesgo de inconsistencias intermedias.

### Referencias de scripts
- [dba_changes/2026-06-08_dlauto_precheck/README.md](C:/Users/yejc2/source/repos/ROAD_TOLEDANO/dba_changes/2026-06-08_dlauto_precheck/README.md)
- [dba_changes/2026-06-08_merma_bulk_headsp/README.md](C:/Users/yejc2/source/repos/ROAD_TOLEDANO/dba_changes/2026-06-08_merma_bulk_headsp/README.md)

## 2) Mejoras en la Aplicación (ya implementadas para este release)

### Eliminación de N+1 en merma (DLMP/DLMNP)
- Se incorporó cache local por proceso para `% merma`, UM y precio por llave de negocio.
- Beneficio release: disminución de consultas repetidas por producto durante generación de DL de merma.

### Inserción masiva de detalle (bulk con fallback)
- Se migró el detalle de merma a inserción masiva para:
  - `TEMP_P_DIFLIQ_DET`
  - `TEMP_P_NOTACDD`
- En caso de fallo, el sistema vuelve a modo fila-a-fila (fallback seguro).
- Beneficio release: reducción de roundtrips en lotes de detalle altos.

### Estabilidad de UI en procesos largos
- Se añadió manejo defensivo del splash:
  - `Safe_Splash_Show`
  - `Safe_Splash_SetCaption`
  - `Safe_Splash_SetDescription`
  - `Safe_Splash_Close`
- Beneficio release: evita `Object reference` durante actualizaciones de `WaitForm`.

### Indicadores y trazabilidad operativa
- Indicador visual en `lblRegsV`:
  - `T.S.` para consulta/abrir liquidación.
  - `T.DL.` para tiempo total de generación automática de DL.
- Trazas finas por etapa (`PRECHECK_STATUS`, `PASO_*`, `MERMA_BULK_*`, `TIEMPO_TOTAL_DL`).
- Beneficio release: diagnóstico más rápido y decisiones basadas en evidencia.

### Optimización de refresh durante cálculo
- Se reforzó el control de refresco de UI con enfoque orgánico y menor repintado innecesario.
- Beneficio release: mejora percepción de respuesta sin sacrificar funcionalidad.

## Resumen de valor del release
- Menos roundtrips a SQL Server.
- Menor costo por ejecución en rutas con alta concurrencia.
- Mayor resiliencia del flujo de generación automática de DL.
- Mejor observabilidad para detectar cuellos de botella reales en producción.
