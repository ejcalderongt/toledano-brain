# Execution Report - BOF LiquidacionesList SP migration

Fecha: 2026-06-08

Script ejecutado:
- `2026-06-08_liqlist_sp_migration_v1.sql`

Ambientes:
- QAS (`ROADSAP_QAS`): OK
- PRD (`ROADSAP`): OK

Objetos validados:
- `usp_LiqList_PuedeAbrirR2SAP_v1`
- `usp_LiqList_FueProcesadaEnSAP_v1`

Notas:
- Cambio aplicado en BOF con fallback a SQL legacy para no romper flujo.

