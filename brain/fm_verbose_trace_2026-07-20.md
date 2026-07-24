# Traza verbose de Facturación Manual (FM)

Fecha: 2026-07-20
Componente: BOF `Formas/Procesos/frmFM.vb`
Tag de código: `#EJC20260720 feat(fm-trace)`

## Objetivo

Observar una sesión completa de Facturación Manual sin modificar las reglas de precio, descuento, recargo, nota o persistencia. La traza permite correlacionar la interacción del grid con el cálculo y el resultado final de la venta.

## Archivo generado

```text
CurDir()\trace_fm\yyyyMMdd\fm_{liquidacion}_{factura}_{timestamp_guid8}.csv
```

Se crea un archivo por instancia/sesión del formulario. Si liquidación o factura todavía no se han asignado al emitir el primer evento, el nombre usa `SIN_DATO`; los valores reales siguen registrándose en cada fila posterior.

Columnas, separadas por punto y coma:

```text
timestamp;session;usuario;liquidacion;ruta;factura;modo;flujo;etapa;estado;elapsed_ms;fila;producto;detalle
```

Los saltos de línea y puntos y coma del detalle se normalizan para mantener una fila física por evento. La escritura usa bloqueo compartido y cualquier error de I/O se absorbe deliberadamente: una falla de trazabilidad nunca debe impedir la facturación.

## Cobertura de eventos

| Flujo | Etapas principales | Evidencia registrada |
|---|---|---|
| `CICLO_VIDA` | `FORM_SHOWN`, `FORM_CLOSING` | Apertura, contexto listo, cierre y liberación de recursos |
| `GRID` | `CELL_VALIDATING` | Columna, valor introducido, aceptación/rechazo y snapshot de la línea |
| `TOTALES` | `RECALCULAR` | Total FM, total ROAD, diferencia, ITBMS y filas |
| `PROMOCION` | `AJUSTE_LINEA` | Condiciones candidatas, cantidad evaluada, precio base, descuento y recargo |
| `PROMOCION` | `COMBO_CANDIDATOS`, `COMBO_EVALUAR`, `COMBO_REQUISITO`, `COMBO_APLICAR` | Cabecera, detalle requerido, requisito cumplido/no cumplido y precio antes/después |
| `NOTA` | `ERROR_SUMA`, `ERROR_PRECIO`, `ERROR_EXTENSION` | Tipo NC/ND, correlativo, beneficiario y diferencias detectadas |
| `PAGO` | `INICIO`, `FIN` | Tipo de pago, monto y resultado OK/CANCEL/ERROR |
| `GUARDAR` | `INICIO`, validaciones, `PAGO`, `FIN` | Contexto previo, rechazos, duración y resultado |
| `ACTUALIZAR` | `INICIO`, `FIN` | Actualización, transacción externa, duración y resultado |
| `PERSISTENCIA` | `PROCESAR_FACTURA`, `DETALLE_PREPARADO`, `GUARDAR_MODELO` | Detalle que se envía al modelo, IDs, totales, resultado y duración |

## Lectura recomendada de un incidente

1. Identificar el archivo por fecha y sesión.
2. Filtrar por `producto` y ordenar por `timestamp`.
3. Seguir `GRID -> PROMOCION -> TOTALES -> NOTA -> PAGO -> PERSISTENCIA`.
4. Comparar `precioFM`, `precioRoad`, cantidades y totales en el campo `detalle`.
5. Revisar los estados `REJECT`, `CANCEL`, `FALSE` o `ERROR` y el evento inmediatamente anterior.

## Consideraciones operativas

- La traza contiene usuario, cliente en algunos detalles, producto, factura y valores monetarios; debe tratarse como evidencia operativa restringida.
- El nivel es intencionalmente verbose. Debe vigilarse crecimiento de `trace_fm` y definir retención antes de habilitarlo de forma permanente en producción.
- No se incluyeron credenciales ni cadenas de conexión.
- La instrumentación no altera consultas, precedencias, importes ni transacciones.

## Validación y limitaciones

- `git diff --check`: sin errores.
- Codificación UTF-8 BOM preservada para el formulario VB legado.
- La compilación alcanzó `frmFM.vb` sin errores atribuibles a la instrumentación; el build global no puede completarse en este checkout por referencias locales ausentes de Crystal Reports y DevExpress.
- Se requiere una prueba manual controlada para confirmar creación del CSV y recorrer escenarios ZK94/ZK95, ZK97, combo, NC y ND.

## Rollback quirúrgico

Retirar únicamente el bloque identificado por `#EJC20260720 feat(fm-trace)` y las llamadas a `Registrar_Traza_FM` dentro de `frmFM.vb`. No tocar la lógica circundante de negocio. La carpeta `trace_fm` es un artefacto runtime y no forma parte del repositorio.
