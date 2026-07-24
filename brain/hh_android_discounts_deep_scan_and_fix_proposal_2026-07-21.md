# HH Android: estado actual y propuesta quirúrgica de homologación SAP

Fecha del scan: 2026-07-21
Repositorio: `C:/Users/yejc2/StudioProjects/road_2023`
Remote: `https://github.com/carolinakfk/road_2023.git`
Rama: `dev_road_2026`
HEAD observado: `b053866` (`#AT20260720 P_CLIENTE_PROD_EXCLUIDOS`)
Naturaleza: análisis estático; no se modificó código HH.

## Objetivo

Comprender cómo la HH selecciona, calcula, presenta y persiste descuentos/recargos y
combos, contrastarlo con el contrato SAP ya validado en Facturación Manual y proponer
fixes pequeños, tageados y aprobables por separado.

Contrato funcional de referencia:

- `brain/sap_extended_total_calculation_contract_2026-07-20.yml`
- `brain/hh_android_fm_ncnd_port_contract_2026-07-21.yml`

## Estado del arte

### Flujo de sincronización

1. `ComWS` solicita `P_DESCUENTO` y `P_DESCUENTO_COMBO_DET` al servicio ROAD.
2. Los datos se guardan en SQLite con los esquemas de `BaseDatosScript`.
3. `P_CLIENTE_PROD_EXCLUIDOS` tiene tabla y query remota, pero no aparece incorporada
   en la secuencia/caso de descarga; por tanto la funcionalidad está incompleta.
4. La descarga filtra vigencia con `GETDATE()` del servidor. Después la selección local
   vuelve a filtrar con fecha actual del dispositivo, no con fecha del documento.

Evidencia principal:

- `ComWS.java:2708-2728,3911-3935,4890-5085`
- `BaseDatosScript.java:1602-1665`

### Descuentos y recargos individuales

```text
Venta inicia cliente
  -> clsDescFiltro elimina y reconstruye T_DESC
  -> clsDescuento consulta T_DESC
  -> Precio obtiene precio de lista
  -> aplica descuento/recargo al precio unitario
  -> redondea precio unitario a 2
  -> Venta reconstruye TOTAL con precio por cantidad/peso
  -> FacturaRes copia T_VENTA a D_FACTURAD
```

Hallazgos:

- `clsDescFiltro` construye un SQL con precedencia incorrecta: los `OR` comerciales no
  están agrupados, por lo que vigencia/exclusión no aplican uniformemente.
- La exclusión referencia `D.PRODUCTO`, pero `P_DESCUENTO` no tiene alias `D`; la consulta
  puede fallar completa y el error queda reducido a estado interno.
- El segundo bloque `CTIPO=10` contiene `ES_RECARGO*`, no copia todos los campos nuevos
  a `T_DESC` y no aplica exclusiones.
- `clsDescuento.getDescuentoRecargo()` solo consulta `DESCTIPO='R'`. No considera `M`,
  aunque existen métodos legacy separados que sí conocen múltiplos.
- La condición devuelta solo conserva `valor` y `porPorcentaje`; pierde `CODDESC`, tipo,
  prioridad, rango y regla de redondeo, impidiendo trazabilidad fina.
- `Precio` calcula y redondea descuento/recargo sobre precio unitario, redondea el precio
  a dos decimales y luego reconstruye el total. Es el patrón que diverge de SAP.
- Se usa `double` para toda la aritmética monetaria.

Evidencia principal:

- `Venta.java:3674`
- `clsDescFiltro.java:41-54,82-140,145-180`
- `clsDescuento.java:52-128,196-304`
- `Precio.java:51-76,92-190`

### Combos

```text
FacturaRes.onCreate
  -> Catalogo.GetDescuentoCombo
  -> Catalogo.GetDetalleComboDescuento
  -> carga T_VENTA
  -> valida primera línea por producto
  -> modifica PRECIO/PRECIODOC/DESMON/RECARGOMONTO/TOTAL
```

Hallazgos:

- Busca `DESCTIPO='C'`, mientras el contrato vigente representa combo con `PTIPO=6` y
  conserva `DESCTIPO` como `R` o `M`.
- No filtra `PTIPO=6`, vigencia de factura, exclusión cliente-producto, rango ni producto
  beneficiario de forma completa.
- Carga solamente producto y cantidad del detalle; ignora `UMSTOCK`, `UMVENTA`,
  `OBLIGATORIO`, grupo y tipo de participación, aunque existen en SQLite.
- Valida únicamente la primera línea del producto; no agrega líneas repetidas por UM.
- Actualiza con `WHERE PRODUCTO=...`, pudiendo modificar varias líneas/UM a la vez.
- Parte de `l.precio`, que ya puede estar ajustado. Reabrir/reintentar puede reaplicar.
- Redondea ajuste y precio a dos decimales y reconstruye el total desde ese precio.
- Si existen detalles de descuento y recargo, `FacturaRes` llama dos veces al método y en
  ambas llamadas pasa descuento y recargo; ambos ajustes pueden ejecutarse dos veces.
- El recargo se calcula sobre `nuevoPrecio` después del descuento, creando composición no
  documentada.

Evidencia principal:

- `FacturaRes.java:268-283,364-390`
- `Catalogo.java:36-71,74-137,139-265`
- `BaseDatosScript.java:1638-1650,2508-2533`

### Totalización, persistencia e impresión

- `totalDescProdNuevo()` vuelve a extender `DESMON`/`RECARGOMONTO` y decide peso con el
  literal `UM='KG'`; no usa de forma general la UM de peso configurada.
- `T_VENTA.TOTAL` sí existe separado de `PRECIODOC`, lo que permite conservar total SAP
  sin reconstruirlo al persistir.
- No existe campo/estado persistente explícito para precio base inmutable, condición
  aplicada o total autoritativo. `PRECIO` y `PRECIODOC` se sobrescriben.
- `D_FACTURAD` recibe `TOTAL`, `PRECIODOC`, `DESMON` y `RECARGOMONTO` por separado.
- La factura térmica muestra precio con dos decimales y total con dos. Esto es aceptable
  solo si el precio impreso se trata como informativo y el total persistido no se deriva
  nuevamente de él.

Evidencia principal:

- `FacturaRes.java:787-918,1071-1155,1734-1770,3034-3065`
- `clsDocFactura.java:318-320,439-466`

### NC/ND

- HH sí maneja `D_NOTACRED`/`D_NOTACREDD`, NC de devolución y ND de anulación/referencia.
- El scan no encontró un motor equivalente al de FM que compare precio manual contra
  precio promocional derivado y genere automáticamente NC/ND por error de precio.
- Por ello no se debe copiar la lógica de devolución/anulación para resolver diferencia
  promocional. Si el negocio requiere ese flujo en HH, debe construirse sobre el mismo
  resultado autoritativo del calculador SAP y como caso separado.

Evidencia principal:

- `FacturaRes.java:1351-1600`
- `DevolCli.java`, `Anulacion.java`, `D_NOTACRED`, `D_NOTACREDD`

## Lista quirúrgica propuesta para aprobación

Orden recomendado: primero hacer observable y correcto el catálogo; después sustituir la
aritmética; finalmente habilitar combos y cualquier NC/ND por diferencia de precio.

### Bloque A — seguros e inmediatos

1. **HH-SAP-F01 — Corregir SQL de filtro local**
   - Tag: `#EJC20260721 fix(hh-desc-filter-query): agrupa claves comerciales y corrige alias/exclusiones`
   - Cambios: alias `P_DESCUENTO D`, agrupar todos los `OR`, aplicar vigencia/exclusión al
     conjunto completo, corregir `ES_RECARGO*` y homologar el bloque `CTIPO=10`.
   - Impacto: bajo; corrige selección sin cambiar la fórmula monetaria.
   - Aceptación: cada CTIPO respeta fecha y exclusión; una falla SQL queda trazada.

2. **HH-SAP-F02 — Completar sincronización de exclusiones**
   - Tag: `#EJC20260721 fix(hh-sync-exclusiones): incorpora P_CLIENTE_PROD_EXCLUIDOS al ciclo de descarga`
   - Cambios: agregar tabla a la secuencia real, limpiar/recargar atómicamente y registrar
     conteo recibido/persistido.
   - Impacto: bajo-medio.
   - Aceptación: después de comunicar, SQLite contiene las exclusiones activas de la ruta.

3. **HH-SAP-F03 — Trazabilidad fina no bloqueante**
   - Tag: `#EJC20260721 feat(hh-promo-trace): registra genealogía de selección y cálculo SAP`
   - Cambios: eventos de candidatos, elegido, base, política de redondeo, ajuste, total y
     persistencia; sin credenciales y sin bloquear venta si falla el log.
   - Impacto: bajo.
   - Aceptación: un caso puede reconstruirse desde sincronización hasta `D_FACTURAD`.

4. **HH-SAP-F04 — Preservar metadatos de condición**
   - Tag: `#EJC20260721 refactor(hh-desc-result): conserva CODDESC tipo prioridad rango y UM`
   - Cambios: reemplazar el resultado mínimo `{valor, porPorcentaje}` por un objeto
     inmutable con identificación y política completa.
   - Impacto: bajo-medio; habilita pruebas y trazas sin cambiar aún el resultado.
   - Aceptación: la línea identifica exactamente qué condición se aplicó.

### Bloque B — homologación monetaria SAP

5. **HH-SAP-F05 — Calculador puro con BigDecimal**
   - Tag: `#EJC20260721 feat(hh-sap-calculator): calcula ajuste sobre total extendido autoritativo`
   - Cambios: clase Java sin Android/SQLite/UI; `BigDecimal` desde `String`, pivotes
     explícitos y `RoundingMode.HALF_UP`.
   - Impacto: medio y controlado mediante pruebas espejo.
   - Aceptación: casos ZK94/ZK95/ZK97 y ZR equivalentes coinciden al centavo con BOF/SAP.

6. **HH-SAP-F06 — Homologar base peso/cantidad**
   - Tag: `#EJC20260721 fix(hh-peso-total): usa peso total ROAD sin multiplicarlo nuevamente por cantidad`
   - Cambios: resolver base una sola vez; peso total para venta por peso, cantidad para UM
     discreta; eliminar decisiones por literal `KG`.
   - Impacto: medio.
   - Aceptación: cantidad mayor a uno no duplica el peso total.

7. **HH-SAP-F07 — Selección canónica M/R**
   - Tag: `#EJC20260721 fix(hh-desc-selection): incluye M prioriza M sobre R y usa fecha de factura`
   - Cambios: `M` cumple `base>=RANGOINI` sin exigir UM de peso; `R` valida rango/UM;
     ordenar M, `PRIORIDAD_DESCUENTO` si está disponible y `PRIORIDAD`.
   - Impacto: medio.
   - Aceptación: escenario 0220 elige ZK95 M y no ZK97 R.

8. **HH-SAP-F08 — Total autoritativo y precio derivado**
   - Tag: `#EJC20260721 fix(hh-total-extendido): persiste total SAP y deriva precio promocional a 6 decimales`
   - Cambios: guardar `TOTAL` calculado directamente; derivar precio a seis decimales;
     no reconstruir total desde precio visual de dos decimales.
   - Impacto: medio.
   - Aceptación: total impreso/persistido coincide con SAP aun si el precio visible no lo
     reconstruye matemáticamente a dos decimales.

9. **HH-SAP-F09 — Idempotencia de cálculo**
   - Tag: `#EJC20260721 fix(hh-promo-idempotencia): recalcula siempre desde precio base inmutable`
   - Cambios: separar entrada base, resultado promocional y total; reintentos no toman
     `PRECIO` ya modificado.
   - Impacto: medio.
   - Aceptación: abrir resumen, cancelar pago y reintentar produce valores idénticos.

10. **HH-SAP-F10 — Totalización desde importes extendidos**
    - Tag: `#EJC20260721 fix(hh-factura-total): suma totales y ajustes autoritativos sin reextender`
    - Cambios: reemplazar `DESMON * FACTOR` y literal `KG`; sumar los importes extendidos
      producidos por el calculador.
    - Impacto: medio.
    - Aceptación: encabezado, detalle, resumen y SAP tienen el mismo total.

### Bloque C — combos

11. **HH-SAP-F11 — Identificar combo por PTIPO=6**
    - Tag: `#EJC20260721 fix(hh-combo-catalog): usa PTIPO 6 y conserva DESCTIPO R M`
    - Cambios: eliminar dependencia de `DESCTIPO='C'`; filtrar vigencia, cliente, exclusión,
      prioridad y condición conforme contrato vigente.
    - Impacto: medio-alto.
    - Aceptación: el combo sincronizado por WebAPI/RDC7 es candidato en HH.

12. **HH-SAP-F12 — Evaluación agregada y OBLIGATORIO**
    - Tag: `#EJC20260721 fix(hh-combo-requisitos): agrega producto UM y respeta obligatorio`
    - Cambios: cargar todos los campos de detalle, agregar líneas compatibles, no mezclar
      UM sin conversión, omitir opcionales ausentes y bloquear obligatorios faltantes.
    - Impacto: medio-alto.
    - Aceptación: pruebas con líneas repetidas, opcionales y obligatorios.

13. **HH-SAP-F13 — Aplicación única y por identidad de línea**
    - Tag: `#EJC20260721 fix(hh-combo-aplicacion): evita doble ajuste y updates amplios por producto`
    - Cambios: una sola evaluación/aplicación por condición; no pasar descuento y recargo
      dos veces; actualizar por PK completa de `T_VENTA`; no componer recargo sobre precio
      ya descontado sin regla aprobada.
    - Impacto: alto por tocar el cierre de factura.
    - Aceptación: cada condición aparece una vez y solo modifica las líneas participantes.

14. **HH-SAP-F14 — Bonificaciones fuera de promociones**
    - Tag: `#EJC20260721 fix(hh-promo-bonificacion): excluye bonificados de ajustes y requisitos`
    - Cambios: hacer explícita la exclusión aunque hoy las bonificaciones usen temporales
      separados; agregar prueba de regresión.
    - Impacto: medio.
    - Aceptación: bonificado no recibe ajuste ni completa combo.

### Bloque D — decisiones controladas

15. **HH-SAP-F15 — Persistencia del precio base**
    - Tag propuesto: `#EJC20260721 feat(hh-precio-base): conserva base ajuste y precio derivado`
    - Decisión requerida: ¿se permite ampliar `T_VENTA`/`D_FACTURAD`, o el precio base se
      conserva solo durante la sesión y en trazas?
    - Recomendación: primero memoria + traza; agregar columnas únicamente si reabrir o
      auditar una venta exige reconstrucción exacta offline.

16. **HH-SAP-F16 — NC/ND automática por diferencia de precio**
    - Tag propuesto: `#EJC20260721 feat(hh-ncnd-precio): genera nota contra precio promocional autoritativo`
    - Decisión requerida: ¿la HH debe generar NC/ND por precio manual, o esa corrección
      seguirá siendo exclusiva de BOF/FM?
    - Recomendación: no mezclar con NC de devolución. Implementar solo si HH permite
      modificación manual de precio y negocio confirma el mismo contrato que FM.

17. **HH-SAP-F17 — Concurrencia descuento y recargo**
    - Tag propuesto: `#EJC20260721 rule(hh-desc-recargo): aplica ambos contra la misma base`
    - Decisión requerida: ¿descuento y recargo se calculan ambos sobre el total base o el
      segundo sobre el resultado del primero?
    - Recomendación: ambos contra la misma base extendida; evitar composición accidental.

18. **HH-SAP-F18 — Política de representación impresa**
    - Tag propuesto: `#EJC20260721 fix(hh-print-precio): muestra precio efectivo sin alterar total`
    - Decisión requerida: mantener dos decimales o mostrar hasta seis en precio.
    - Recomendación: total siempre dos; precio puede mostrarse con hasta seis o marcarse
      como efectivo. La impresión nunca debe recalcular el total.

## Pruebas mínimas para aprobar implementación

1. ZK94 fijo por peso: redondeo del ajuste extendido antes de restar.
2. ZK95 porcentual M: sin redondeo intermedio.
3. ZK97 porcentual R: redondeo de ajuste conforme FM.
4. M y R simultáneos para cliente `0001002150`, producto `0220`.
5. Peso total con cantidad mayor a uno: no duplicar base.
6. Reintento/cancelación de pago: resultado idempotente.
7. Combo con línea repetida y UM compatible.
8. Detalle obligatorio ausente y opcional ausente.
9. Línea bonificada presente.
10. Descuento y recargo simultáneos.
11. Exclusión activa, futura, vencida e inactiva.
12. Igualdad `T_VENTA → D_FACTURAD → impresión → payload enviado`.

## Secuencia recomendada de entregas

- PR/commit 1: F01-F04, sin cambio de resultado monetario salvo corrección de selección.
- PR/commit 2: F05-F10 con pruebas unitarias puras y casos espejo BOF/SAP.
- PR/commit 3: F11-F14 para combos y bonificaciones.
- PR/commit 4: solamente las decisiones F15-F18 que apruebe negocio/equipo.

No mezclar cambios Gradle existentes con estos commits funcionales.

## Estado de ejecución 2026-07-21

- **Activos en código HH (`dev_road_2026`)**: F01–F14.
- **Sin efecto por decisión del usuario**: F15–F18. Se conservan únicamente como
  backlog documental y no deben inferirse, probarse como activos ni incorporarse en
  persistencia, generación NC/ND, concurrencia descuento-recargo o impresión.
- La homologación F05–F08 también cubre `PrecioTran`, ruta transaccional utilizada al
  leer barras; usa el peso ROAD como peso total, el total extendido como autoridad y el
  precio unitario derivado a seis decimales.
- Validación técnica disponible en `tools/tests/Test-HhSapPromotionCalculator.ps1` y
  `tools/tests/Test-HhPromotionIntegration.ps1`; la segunda impide activar por accidente
  los tags reservados para F15–F18.

## Resolución posterior del equipo 2026-07-21

- F01–F13 continúan aprobados; `PRIORIDAD_DESCUENTO` debe preceder a `PRIORIDAD`, igual que BOF.
- F14 fue redefinido: las bonificaciones ROAD sí cuentan para cumplir requisitos de combo.
  Permanecen en `T_BONITEM/D_BONIF`, con valor gratuito, y no se transforman en líneas cobradas.
- F15 fue aprobado: HH conserva `PRECIO_BASE`, `TOTAL_BASE`, `CODDESC_APLICADO` y
  `CODRECARGO_APLICADO` en `T_VENTA` y `D_FACTURAD`. La propagación a SQL central requiere
  ampliar primero el contrato receptor; no se altera silenciosamente el SOAP legacy.
- F16 fue rechazado para HH: la NC/ND automática por error de precio pertenece solo a BOF.
- F17 fue aprobado como concurrencia independiente sobre la misma base extendida:
  `total_final = total_base - descuento + recargo`.
- F18 fue aprobado: la factura HH muestra el precio efectivo con hasta seis decimales,
  manteniendo total de línea/documento a dos y sin reconstruirlo desde el precio impreso.
- Resultado técnico local: `HH_PROMOTION_INTEGRATION_OK checks=18 bof_only=F16` y
  compilación `compileDebugJavaWithJavac` exitosa.
