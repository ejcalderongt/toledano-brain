# Fine Trace - Liquidacion `frmLiqVend` (ROAD_BOF)

## Contexto
- Fecha: 2026-06-08
- Repo: `C:\Users\yejc2\source\repos\ROAD_TOLEDANO`
- Rama: `devejc-combos-sofos`
- Objetivo: reducir roundtrips, mejorar concurrencia y bajar tiempos de liquidacion a segundos sin romper flujos.

## Flujo principal observado
1. Entrada de busqueda:
- `Buscar_Registro` en `Formas/Procesos/frmLiqVend.vb:821`
- `Busca_Datos_Liquidacion` en `Formas/Procesos/frmLiqVend.vb:3689`

2. Resolucion de ruta y validaciones previas:
- `Get_Ruta` en `Formas/Procesos/frmLiqVend.vb:2755`
- `Busca_Datos_Liquidacion_Sin_HH` en `Formas/Procesos/frmLiqVend.vb:3120`
- Cola de concurrencia:
- `Wait_for_Turn_Busca_Datos_Liquidacion_CT` en `Formas/Procesos/frmLiqVend.vb:3484`
- `Wait_for_Turn_Guardar_Liquidacion_CT` en `Formas/Procesos/frmLiqVend.vb:4687`

3. Carga de datos de liquidacion:
- `Cargar_Datos_Grid` en `Formas/Procesos/frmLiqVend.vb:2445`
- Subconsultas secuenciales:
- `Obtener_Facturas_Vendedor` (`:1168`)
- `Calcular_Monto_Cobros` (`:1425`)
- `Obtener_Encabezado_Cobros` (`:1507`)
- `Obtener_Cobros_Documento` (`:1594`)
- `Obtener_Cobros_FormaPago` (`:1664`)
- `Obtener_Desglose_Efectivo` (`:1719`)
- `Obtener_Notas_Credito_Devolucion` (`:1758`)
- `Obtener_Inventario_Inicial` (`:1860`)
- `Obtener_Notas_Credito_Y_Debito` (`:1337`)
- `Calcula_Montos_Totales` (`:1080`)

4. Guardado de liquidacion:
- `Guarda_Liquidacion` en `Formas/Procesos/frmLiqVend.vb:4892`
- Es el punto de mayor costo por volumen de updates y transferencias de tablas temporales.

## Pantallas relacionadas (invocadas por `frmLiqVend`)
- `frmFM` (facturacion manual): `Formas/Procesos/frmLiqVend.vb:14751, 14987`
- `frmDocumentosVendedor`
- `frmNotaCDDevol`
- `frmDevDetalle`
- `frmCobroDetalle`
- `frmTipoCobro`
- `frmUpdInvLiq`
- `frmFacturaDetalle`
- `frmHabilitarFM`
- `frmFiltrosLiquiAgencia`
- `frmVendedorList`
- `frmRazonLiquidacionPendienteList`

## Subflujo critico: Facturacion Manual
1. `Nueva_Factura_Manual` (`frmLiqVend.vb:14751`) recalcula inventario y abre `frmFM`.
2. `DgridFacturas_DoubleClick` (`frmLiqVend.vb:14987`) puede reabrir `frmFM` en modo edicion.
3. Dentro de `frmFM`:
- `Guardar_Factura` (`Formas/Procesos/frmFM.vb:1308`)
- `Procesar_Factura` (`frmFM.vb:3961`) recorre detalle y reserva inventario por barra/lote.
- Reservas:
- `Reservar_Barras` (`frmFM.vb:3440`)
- `Reservar_Barras_Bonif` (`frmFM.vb:3531`)
- `Reservar_Lotes` (`frmFM.vb:3643`)
- `Reservar_Lotes_Bonif` (`frmFM.vb:3777`)
- Recalculos de inventario previos/post:
- `DAL/Liquidador/clsInventarioLiquidacion.vb:436` (`Recalcula_Inventario_En_DLS`)
- `DAL/Liquidador/clsInventarioLiquidacion.vb:524` (`Recalcula_Inventario_En_Facturas_Manuales`)

## Hallazgos de rendimiento
1. N+1 updates en guardado de liquidacion (pre-cambio):
- `Guarda_Liquidacion` tenia ciclos por fila para `D_FACTURA`, `D_COBRO`, `D_CXC`, `D_NOTACRED`, `P_NOTACD`, `P_STOCK`, `P_STOCKB`, `D_DEPOS`.
- Esto multiplicaba roundtrips por cantidad de documentos/registros.

2. Polling recursivo para cola de concurrencia:
- `Wait_for_Turn_*_CT` usa `Sleep(1000) + recursion + DoEvents`.
- Bajo carga de multiples liquidadores puede crecer espera activa en UI y latencia acumulada.

3. Aislamiento `ReadUncommitted` en transacciones de escritura:
- ampliamente usado en procesos de guardar/actualizar; reduce bloqueos pero expone lecturas sucias y decisiones con datos no confirmados.

4. Refresh UI muy frecuente:
- `Application.DoEvents()` en muchas secciones de carga/guardado.
- Actualizaciones de labels/progress dentro de ciclos largos.

## Mejora aplicada en este turno
- Archivo: `Formas/Procesos/frmLiqVend.vb`
- Metodo: `Guarda_Liquidacion`
- Tag: `#EJC20260608 mejora(liquidacion-bof)`

Se reemplazaron updates por fila por updates set-based en:
- `D_FACTURA`
- `D_COBRO`
- `D_CXC`
- `D_NOTACRED`
- `P_NOTACD`
- `P_STOCK`
- `P_STOCKB`
- `D_DEPOS`

Efecto esperado:
- Menos roundtrips por liquidacion (especialmente en rutas con alto volumen).
- Menor tiempo de transaccion y menor probabilidad de deadlock.
- Menor bloqueo de UI durante guardado.

## Siguiente fase recomendada (DB-first)
1. Consolidar `Guarda_Liquidacion` en un SP transaccional unico:
- Header + detalle + move temp->final + updates documentos.
- Salida con metricas (`@@ROWCOUNT` por bloque, tiempo ms por fase).

2. Usar TVP para detalle de liquidacion:
- Enviar `InvRutaList` como TVP y hacer `INSERT` set-based.
- Eliminar `delete + insert fila por fila`.

3. Usar tablas staging en memoria (opcional segun licencia/infra):
- `MEMORY_OPTIMIZED` para staging de correlativos/documentos de la liquidacion.
- Alternativa si no aplica in-memory OLTP: `#temp` + indices puntuales.

4. Cambiar control de concurrencia:
- Reemplazar polling recursivo por `sp_getapplock` por clave (`Fecha+Ruta+Liquidacion`).
- Timeout controlado, sin recursion en UI.

## Marcas de mejora UI (sin sacrificar fluidez)
1. En cargas masivas:
- Suspender pintado durante bloques de bind (`BeginUpdate/EndUpdate` o equivalente grid).
- Rebind unico por seccion, no por iteracion.

2. Progreso organico:
- Actualizar label/progress por lote (cada N items o por fase), no por fila.
- Mantener indicador de fase: `Facturas`, `Cobros`, `Inventario`, `Commit`.

3. `DoEvents`:
- Limitar su uso a checkpoints de fase para evitar reentrancia y jitter.

## Riesgos residuales
1. Persisten queries dinamicos con concatenacion string en varias funciones.
2. Persisten rutas de facturacion manual con reservas por item/barra/lote (potencial N+1).
3. Persisten retries por deadlock con UX interactivo en medio de transaccion.

## Evidencia tecnica
- Compilacion OK del proyecto BOF:
- `MSBuild.exe BOF_ROAD.vbproj /t:Build /p:Configuration=Debug`
- Resultado: `0 errores` (con warnings preexistentes de referencias).

## Mejora aplicada (espera recursiva -> iterativa)
- Archivo: `Formas/Procesos/frmLiqVend.vb`
- Tag: `#EJC20260608 mejora(liquidacion-bof)`
- Funciones impactadas:
- `Wait_for_Turn_Buscar_Registro_CT`
- `Wait_for_Turn_Busca_Datos_Liquidacion_CT`
- `Wait_for_Turn_Guardar_Liquidacion_CT`

Detalle:
- Se extrae la logica comun a `Wait_for_Turn_Cola_CT` y se elimina recursion.
- Se mantiene semantica de cola actual (`P_COLA_TRANSACCIONES`) y mensajes de UI por segundo.
- Se reducen costos de stack/reentrada y se simplifica control de reintentos.

Efecto esperado:
- Menos jitter de UI bajo carga concurrente de liquidadores.
- Menor sobrecosto por llamadas recursivas en espera activa.

## SPs propuestos para leer/procesar cola (DB-first)
- Archivo: `road_toledano_agent_setup/sql/proposal_sp_cola_transacciones_wait_v1.sql`
- Contiene:
- `dbo.usp_COLA_TRANSACCIONES_ReadActive_v1` (lectura consolidada de bloqueo activo).
- `dbo.usp_COLA_TRANSACCIONES_TryAcquire_v1` (toma de turno atomica en un roundtrip).
- `dbo.usp_COLA_TRANSACCIONES_ReleaseByUserType_v1` (liberar turno por usuario/tipo/ruta).
- `dbo.usp_COLA_TRANSACCIONES_ReleaseBatch_v1` (liberacion masiva por TVP).
- `dbo.tvp_COLA_TRANSACCIONES_CODIGO_v1` (TVP de codigos).
- Indice sugerido `IX_P_COLA_TRANSACCIONES_TIPO_PROC_LIQ_USR`.
