# Fix Splash + Bulk Mapping (2026-06-09)

## Contexto
En generación automática de DL se observaron dos fallos en productivo:
1. `Object reference not set...` al usar `SplashScreenManager.Default.SetWaitFormCaption`.
2. Falla de bulk (`ColumnMapping`) en merma, provocando fallback y riesgo de error encadenado (incluyendo FK en ejecución posterior).

## Cambios aplicados
- BOF `frmLiqVend`:
  - Se agregaron wrappers defensivos:
    - `Safe_Splash_Show`
    - `Safe_Splash_SetCaption`
    - `Safe_Splash_SetDescription`
    - `Safe_Splash_Close`
  - Se reemplazaron llamadas directas de splash en flujo `Generar_DLS_Automaticos`.
  - Se eliminó dependencia de `IsSplashFormVisible` (no disponible en esta versión de DevExpress).
- Bulk insert defensivo:
  - `BulkInsert_Notas_Recalculo` ahora inspecciona esquema destino (`SELECT TOP 0 *`) y mapea solo columnas existentes.
  - Evita error de `ColumnMapping` por diferencias de esquema entre ambientes.

## Resultado esperado
- No más null reference por splash durante generación DL.
- Menor tasa de fallback por bulk en merma.
- Flujo de generación más estable y sin ruptura funcional.

## Archivo principal
- `Formas/Procesos/frmLiqVend.vb`
