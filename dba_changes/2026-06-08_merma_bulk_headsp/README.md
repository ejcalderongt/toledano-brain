# Merma Bulk + Header SP (QAS/PRD)

## Objetivo
1. Reducir roundtrips en `Generar_DL_Merma` usando inserción masiva (`SqlBulkCopy`) en:
- `TEMP_P_DIFLIQ_DET`
- `TEMP_P_NOTACDD`

2. Consolidar updates repetidos de cabecera mediante SP:
- `dbo.usp_LiqVend_DL_Merma_Finaliza_v1`

## Script
- `01_2026-06-08_usp_LiqVend_DL_Merma_Finaliza_v1.sql`

## Fallback
- Si el SP de cabecera falla: BOF vuelve al flujo legacy de dos `UPDATE`.
- Si el bulk falla: BOF inserta fila a fila (modo compatible).
