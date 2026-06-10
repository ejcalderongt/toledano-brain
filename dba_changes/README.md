# Informe Ejecutivo de Rendimiento (Release)

Fecha: 2026-06-09  
Alcance: proceso de liquidación `frmLiqVend` (consulta/edición y generación automática de DL).

## 1) Cambios aplicados en PRD (impacto directo en rendimiento)

### Precheck de generación automática de DL
- Se aplicó en PRD el SP `dbo.usp_LiqVend_DLAuto_Precheck_v1`.
- Objetivo: evitar ejecutar etapas completas de DL/DC cuando no hay candidatos.
- Resultado esperado: menos trabajo innecesario y menor tiempo total del botón de generación automática.

### Batch set-based para inventario de ruta
- Se aplicó en PRD la versión set-based por lote para inventario (`TVP`).
- Objetivo: reducir roundtrips y eliminar consultas N+1 en cálculo de inventario.
- Resultado esperado: menor latencia en `POST_CALCULA_INVENTARIO_RUTA` y menor presión por concurrencia.

### Consolidación transaccional de cabecera merma
- Se aplicó en PRD `dbo.usp_LiqVend_DL_Merma_Finaliza_v1`.
- Objetivo: unificar updates repetidos de cabecera (`P_LIQUIDACION` + `TEMP_P_DIFLIQ`) en un paso transaccional.
- Resultado esperado: menos viajes a BD y menor riesgo de inconsistencias intermedias.

## 2) Mejoras en la aplicación (release actual)

### Eliminación de N+1 en merma (DLMP/DLMNP)
- Se incorporó cache local por proceso para `% merma`, UM y precio por llave de negocio.
- Beneficio: disminución de consultas repetidas por producto durante generación de DL de merma.

### Inserción masiva de detalle (bulk con fallback)
- Se migró el detalle de merma a inserción masiva para:
  - `TEMP_P_DIFLIQ_DET`
  - `TEMP_P_NOTACDD`
- En caso de fallo, el sistema vuelve a modo fila-a-fila (fallback seguro).

### Estabilidad de UI en procesos largos
- Se añadió manejo defensivo del splash (`Safe_Splash_*`) para evitar fallos por referencia nula.

## 3) Evidencias, scripts y documentación relacionada

- [Precheck DL automático](./2026-06-08_dlauto_precheck/README.md)
- [Script PRD/QAS: `usp_LiqVend_DLAuto_Precheck_v1`](./2026-06-08_dlauto_precheck/01_2026-06-08_dlauto_precheck_v1.sql)
- [Script batch inventario set-based](./2026-06-08_dlauto_precheck/02_2026-06-08_liqvend_inventario_batch_v2_setbased.sql)
- [Merma bulk + SP cabecera](./2026-06-08_merma_bulk_headsp/README.md)
- [Script PRD/QAS: `usp_LiqVend_DL_Merma_Finaliza_v1`](./2026-06-08_merma_bulk_headsp/01_2026-06-08_usp_LiqVend_DL_Merma_Finaliza_v1.sql)
- [Ejecución QAS/PRD merma bulk](./2026-06-08_merma_bulk_headsp/02_execution_qas_prd_2026-06-08.md)
- [Fix estabilidad Splash + bulk mapping](./2026-06-09_fix_splash_bulk/README.md)

## Resumen de valor del release
- Menos roundtrips a SQL Server.
- Menor costo por ejecución en rutas con alta concurrencia.
- Mayor resiliencia del flujo de generación automática de DL.
- Mejor observabilidad para detectar cuellos de botella reales en producción.
