# DBA Changes - DL Automatico Precheck y Hotfix de Timeout

## Objetivo
Reducir tiempo del boton `Generacion automatica DL` en `frmLiqVend` sin romper funcionalidad.
Adicional: reducir riesgo de timeout en productivo eliminando N+1 en merma y asegurando SPs batch activos en QAS/PRD.

## Causa observada
- El flujo ejecutaba varias etapas costosas aunque no siempre habia candidatos.
- Faltaba traza por etapa para identificar cuellos en cada paso.

## Cambio aplicado
1. SP `usp_LiqVend_DLAuto_Precheck_v1` para prevalidar candidatos.
2. BOF usa el SP de forma **opcional** con fallback:
- Si SP responde: se usan banderas para decidir que etapas correr.
- Si SP falla/no existe: sigue flujo legacy completo.
3. Hotfix BOF en `Generar_DL_Merma`:
- Cache local por proceso para `% merma`, `UM` y `precio` por producto.
- Evita consultas repetidas por item (N+1) cuando se generan DLMNP/DLMP.
- Nueva traza `PASO_MERMA_CACHE_STATS` con `hits/miss` para validar impacto real.
4. Redeploy de SPs batch en QAS y PRD para evitar fallback por objetos no actualizados.

## Script
- [01_2026-06-08_dlauto_precheck_v1.sql](./01_2026-06-08_dlauto_precheck_v1.sql)
- [02_2026-06-08_liqvend_inventario_batch_v2_setbased.sql](./02_2026-06-08_liqvend_inventario_batch_v2_setbased.sql)

## Trazas nuevas en BOF
- `CLICK_CMD_DL_AUTOMATICO`
- `PRECHECK_STATUS`
- `PRECHECK_SP_FALLBACK`
- `PASO_DLFP`
- `PASO_DLFPD`
- `PASO_RECALCULA_INVENTARIO`
- `PASO_DLMNP`
- `PASO_DLMP`
- `PASO_DLFCP`
- `PASO_DLFCR`
- `PASO_MERMA_CACHE_STATS`

## Variables faciles de comprender
- `usePrecheckSP`
- `precheckDLFP`, `precheckDLFPD`, `precheckDLMNP`, `precheckDLMP`, `precheckDLFCP`, `precheckDLFCR`
- `precheckRecalculaInv`
- `debeEjecutarDLFP`, `debeEjecutarDLFPD`, `debeEjecutarDLMNP`, `debeEjecutarDLMP`, `debeEjecutarDLFCP`, `debeEjecutarDLFCR`
- `debeRecalcularInventario`

## Ejecucion en ambientes (2026-06-08)
- QAS: `ROADSAP_QAS` en `172.16.10.27` ejecutado OK.
- PRD: `ROADSAP` en `172.16.10.9` ejecutado OK.

## Diagnostico narrativo
- La traza previa de Carol mostro `BATCH_SP_FALLBACK` en inventario y casi 29s en `POST_CALCULA_INVENTARIO_RUTA`.
- En trazas recientes ya se ve `BATCH_SP_STATUS ok=True` y ~14.7s en ese paso para la misma ruta base, lo que confirma mejora fuerte.
- El timeout nuevo de `Generar_DL_Merma` apunta a otro cuello: consultas repetidas por producto durante la generacion de notas automaticas.
- El hotfix actual ataca ese cuello directamente y deja medicion objetiva en traza para comparar antes/despues.
