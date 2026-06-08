# Execution Report - Reapply V2 (QAS + PRD)

Fecha: 2026-06-08
Hora: 16:02 (America/Guatemala)

## Contexto
Re-ejecucion solicitada despues de crear tag de respaldo.

Tag de respaldo:
- `backup_ejc_20260608_1608_liqvend_allin`

## Scripts re-ejecutados
1. `2026-06-08_liqvend_sp_migration_v1.sql`
2. `2026-06-08_liqvend_index_tuning_v2.sql`

## Resultado por ambiente
- QAS (`ROADSAP_QAS`): OK
- PRD (`ROADSAP`): OK

## Validacion post-reapply
SPs presentes en ambos ambientes:
- `usp_LiqVend_GetRutaDisponible_v1`
- `usp_LiqVend_TieneCorelDmov_v1`
- `usp_LiqVend_RutaLiquidando_v1`
- `usp_LiqVend_RutaTieneHH_v1`
- `usp_LiqVend_RutaFacturoManual_v1`

Indices presentes en ambos ambientes:
- `IX_P_STOCKB_FECHA_INC_ENV_LIQ_DOC_v2`
- `IX_P_STOCK_FECHA_INC_ENV_LIQ_DOC_v2`
- `IX_P_COLA_TRANS_PROCESADO_USR_v2`
- `IX_P_INV_BARRAS_RUTA_BARRA_v2`

## Notas
- Reapply idempotente completado sin error.
- Queda pendiente subir refactor BOF completo por colision de paths `Formas/` vs `formas/` en Windows.

