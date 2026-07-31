---
name: ejc-skill-toledano
description: Operar ROAD Toledano en BOF, WebAPI/WebService, RDC7, HH Android com.dts.roadp y SQL Server para precios, descuentos, recargos, promociones, combos SAP, pedidos, facturas y NC. Usar para analizar, diagnosticar, modelar, implementar, probar, trazar o federar conocimiento ROAD; incluye verificacion estricta para no mezclar TOMWMS/TOMHH2025.
---

# ROAD Toledano

## Inicio

1. Resolver `TOLEDANO_BRAIN_ROOT`; en esta PC usar `C:\Users\carol\OneDrive\Documentos\toledano-brain`.
2. Cargar `brain/knowledge_governance.yml`, `brain/knowledge_manifest_2026-07-31.yml`, `brain/agent_brain_state.yml` y `brain/project_context.yml`.
3. No solicitar identificacion para leer el brain ni para analizar, modelar, probar o cambiar codigo ROAD.
4. Solicitar nombre completo y DPI solo antes de mutar o publicar el brain. Comparar unicamente SHA-256 y nunca mostrar, repetir ni persistir el DPI.
5. Permitir mutacion del brain solo a Erik identificado y con solicitud expresa. Carolina opera ROAD plenamente, pero el brain permanece de solo lectura para ella.

## Barrera de proyecto

Antes de inspeccionar Android, exigir simultaneamente:

- remoto HH `https://github.com/carolinakfk/road_2023.git`;
- paquete/applicationId `com.dts.roadp`;
- archivos firma `Precio.java`, `Venta.java` y `ComWS.java` bajo `app/src/main/java/com/dts/roadp`.

Excluir siempre `TOMHH2025`, TOMWMS, TOMIMSV4 y `com.dts.tom`. No activar skills TOMWMS por coincidencias genericas como Android, HH o BOF. Consultar `brain/project_identity_and_repo_guardrails_2026-07-31.yml` si hay varias copias locales.

## Operacion

1. Confirmar repositorio, remoto, rama, upstream, commit y cambios locales antes de actuar.
2. Tratar `devejc_2026` como rama BOF/WebAPI observada y `road_2028` como rama HH activa observada al 2026-07-31; verificar siempre contra Git porque pueden cambiar.
3. Cargar el contrato del componente y la traza o escenario relacionado. Para HH actual usar `brain/hh_runtime_handoff_2026-07-31.yml` y `brain/hh_promotion_observability_contract_2026-07-31.yml`.
4. Preservar cambios locales ajenos y mantener el brain fuera de repositorios fuente.
5. Aplicar reglas confirmadas de `CODDESC`, CTIPO/PTIPO, total extendido, precio base, descuentos, recargos y combos.
6. Declarar como hipotesis cualquier regla no respaldada por evidencia.
7. Validar con build, pruebas, Logcat, CSV de promociones o SQL segun el riesgo.

## Observabilidad HH

Usar `PromotionTrace` como evidencia primaria de promociones. Una traza diagnostica debe registrar tambien resultados negativos: permisos/filtros, cero candidatos, candidato descartado y motivo, fuente/fallback de precio y resultado persistido. El CSV interno no aparece en Logcat salvo errores; extraerlo con `adb shell run-as com.dts.roadp` en builds debuggable.

## Salida

Informar identidad y modo de acceso cuando aplique, repositorio/remoto/rama/commit, entradas del brain, cambios, evidencia, riesgos y estado de federacion.
