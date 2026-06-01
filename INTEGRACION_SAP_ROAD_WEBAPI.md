# Integración SAP -> ROAD WebAPI (Descuentos, Recargos y Combos)

> Documento técnico publicable para equipos SAP ABAP/PI y ROAD.
> Fecha: 2026-06-01
> Ambiente QAS publicado: `http://172.16.10.12:8084/swagger/index.html`
> Versión funcional publicada (WebAPI/Swagger): `1.2`

## Tabla de contenido

1. [Objetivo](#objetivo)
2. [Alcance](#alcance)
3. [Endpoint y autenticación](#endpoint-y-autenticación)
4. [Contrato de entrada (request)](#contrato-de-entrada-request)
5. [Reglas de negocio ROAD (canon)](#reglas-de-negocio-road-canon)
6. [Escenarios soportados](#escenarios-soportados)
7. [Ejemplos JSON por escenario](#ejemplos-json-por-escenario)
8. [Contrato de salida (response)](#contrato-de-salida-response)
9. [Códigos de estado y errores](#códigos-de-estado-y-errores)
10. [Compatibilidad BOF/RDC7/HH](#compatibilidad-bofrdc7hh)
11. [Convenciones y trazabilidad](#convenciones-y-trazabilidad)
12. [Checklist para implementador SAP ABAP/PI](#checklist-para-implementador-sap-abappi)
13. [Notas importantes SAP](#notas-importantes-sap)

---

## Objetivo

Definir un contrato de integración claro entre SAP y ROAD para recibir condiciones de:

- Descuentos
- Recargos
- Combos

La WebAPI de ROAD **digiere un formato de entrada SAP/ROAD semi-homologado** y lo transforma al modelo operativo ROAD para consumo BOF/HH.

---

## Alcance

Este documento cubre:

- Seguridad de consumo WebAPI
- Contrato de request/response
- Reglas de mapeo SAP -> ROAD
- Escenarios de descuentos/recargos/combos
- Convenciones de trazabilidad

Fuera de alcance (fase actual):

- Exclusiones cliente-producto específicas
- Ramo 4 en ROAD (backlog funcional)

---

## Endpoint y autenticación

## Endpoint principal

- `POST /api/sap/descuentos`

## Swagger (QAS)

- `http://172.16.10.12:8084/swagger/index.html`

## Autenticación

Se utiliza autenticación por API Key (header). Convención recomendada:

```http
X-API-KEY: <api-key-asignada>
Content-Type: application/json
```

Comportamiento esperado:

- Sin API Key o inválida: `401 Unauthorized`
- Payload inválido: `400 Bad Request`
- Procesamiento correcto: `200 OK`

> Nota: El nombre exacto del header puede configurarse por entorno. Validar en el despliegue objetivo.

---

## Contrato de entrada (request)

## Estructura base sugerida

```json
{
  "regCond": "9101001",
  "promo": "7101001",
  "coddescSap": "ZK94",
  "coddesc": 7101001,
  "tipoDescuento": "M",
  "orgVent": "1000",
  "canDist": "10",
  "sector": "00",
  "indJerarq": "A903",
  "cliente": "0001000095",
  "producto": "0220",
  "valor": 2.5,
  "porPorcentaje": "S",
  "esRecargo": false,
  "fechaIni": "2026-06-01T00:00:00",
  "fechaFin": "2026-06-30T23:59:59"
}
```

## Campos clave

- `coddescSap`: tipo de condición SAP (`ZK94`, `ZR95`, `ZK96`, etc.)
- `indJerarq`: secuencia/combinación SAP (`A903`, `A906`, `A908`, etc.)
- `coddesc`: identificador de condición ROAD (debe persistirse cuando venga)
- `tipoDescuento`: método de cálculo SAP/ROAD (`R`=Rangos, `M`=Múltiplos)
- `regCond` / `promo`: referencias externas SAP

---

## Reglas de negocio ROAD (canon)

## Catálogos fijos (hardcoded)

`CTIPO` (tipo de cliente) catálogo fijo:

- `0`: Todos clientes
- `1`: Código cliente
- `2`: Tipo de negocio
- `3`: Tipo cliente
- `4`: Subtipo cliente
- `5`: Canal
- `6`: Subcanal
- `7`: Región
- `8`: Sucursal
- `9`: Nivel de precio
- `10`: Grupo clientes
- `11`: Ruta
- `12`: Tipología (Ramo 3)
- `13`: Priorización (ABC)
- `14`: Ramo 4 (pendiente definición)

`PTIPO` (tipo de producto):

- Valores legacy: `0..5`
- Fase 1.2 agrega: `6 = Combo`

## Reglas funcionales

- `GLOBDESC = 'S'`: descuento global al total de factura
- `GLOBDESC = 'N'`: descuento por línea/producto
- `CLIENTE = '*'`: aplica a todos los clientes (según `CTIPO`)
- `PRODUCTO = '*'`: aplica a todos los productos
- `A906/KDGRP` -> `CTIPO = 3` (tipo cliente ROAD)
- Combos: `PTIPO = 6` + detalle en `P_DESCUENTO_COMBO_DET`
- `DESCTIPO` en ROAD:
  - `R` cuando la condición es por rangos/escalas.
  - `M` cuando la condición es por múltiplos (ej. 10+1) o no-rango.
- La clasificación combo/no-combo NO depende de `DESCTIPO`; depende de `PTIPO` (`6`=combo).
- `CODDESC`: usar como identificador funcional ROAD también en simples/escalas si viene en payload

---

## Escenarios soportados

## No combo

- `ZK94`: descuento fijo
- `ZK95`: descuento porcentual
- `ZK97`: descuento escalado
- `ZR94`: recargo fijo
- `ZR95`: recargo porcentual
- `ZR97`: recargo escalado

Combinaciones frecuentes:

- `A903`
- `A906`
- `A907`

## Combo

- `ZK96`: descuento combo
- `ZR96`: recargo combo

Combinaciones fase 1.2:

- `A908`
- `A909`
- `A910`
- `A912`

Backlog:

- `A911` (Ramo 4)

---

## Ejemplos JSON por escenario

> Repositorio de payloads reales QAS:
> `ROADWedAPI/payloads/sap_descuentos/`

## 1) ZK94 simple A903

```json
{
  "regCond": "9101001",
  "promo": "7101001",
  "coddescSap": "ZK94",
  "coddesc": 7101001,
  "tipoDescuento": "M",
  "indJerarq": "A903",
  "cliente": "0001000095",
  "producto": "0220",
  "valor": 2.5,
  "porPorcentaje": "N",
  "esRecargo": false,
  "fechaIni": "2026-06-01T00:00:00",
  "fechaFin": "2026-06-30T23:59:59"
}
```

## 2) ZK95 simple A907

```json
{
  "regCond": "9101002",
  "promo": "7101002",
  "coddescSap": "ZK95",
  "coddesc": 7101002,
  "tipoDescuento": "M",
  "indJerarq": "A907",
  "cliente": "8809-1",
  "producto": "0686",
  "valor": 7.5,
  "porPorcentaje": "S",
  "esRecargo": false,
  "fechaIni": "2026-06-01T00:00:00",
  "fechaFin": "2026-06-30T23:59:59"
}
```

## 3) ZK97 escalas A906

```json
{
  "regCond": "9101003",
  "promo": "7101003",
  "coddescSap": "ZK97",
  "coddesc": 7101003,
  "tipoDescuento": "R",
  "indJerarq": "A906",
  "tipoCliente": "05",
  "producto": "0892",
  "porPorcentaje": "S",
  "esRecargo": false,
  "escalas": [
    { "rangoIni": 1, "rangoFin": 5, "valor": 2.0 },
    { "rangoIni": 6, "rangoFin": 11, "valor": 3.0 }
  ],
  "fechaIni": "2026-06-01T00:00:00",
  "fechaFin": "2026-06-30T23:59:59"
}
```

## 4) ZR95 recargo A903

```json
{
  "regCond": "9101004",
  "promo": "7101004",
  "coddescSap": "ZR95",
  "coddesc": 7101004,
  "tipoDescuento": "M",
  "indJerarq": "A903",
  "cliente": "0001000573",
  "producto": "0834",
  "valor": 5.0,
  "porPorcentaje": "S",
  "esRecargo": true,
  "fechaIni": "2026-06-01T00:00:00",
  "fechaFin": "2026-06-30T23:59:59"
}
```

## 5) ZK96 combo A908

```json
{
  "regCond": "9102001",
  "promo": "7202001",
  "coddescSap": "ZK96",
  "coddesc": 7202001,
  "tipoDescuento": "M",
  "indJerarq": "A908",
  "cliente": "0001000095",
  "grupoComision": "G01",
  "valor": 10.0,
  "porPorcentaje": "N",
  "esRecargo": false,
  "detalleCombo": [
    { "secuencia": 1, "grupo": "A", "producto": "0220", "cantidad": 1, "obligatorio": true },
    { "secuencia": 2, "grupo": "B", "producto": "0892", "cantidad": 1, "obligatorio": true }
  ],
  "fechaIni": "2026-06-01T00:00:00",
  "fechaFin": "2026-06-30T23:59:59"
}
```

---

## Contrato de salida (response)

## Respuesta exitosa (recomendada)

```json
{
  "success": true,
  "statusCode": "OK",
  "message": "Condicion procesada correctamente",
  "traceId": "ROAD-20260601-000001",
  "timestamp": "2026-06-01T14:21:00Z",
  "result": {
    "coddescRoad": 7101001,
    "coddescSap": "ZK94",
    "regCond": "9101001",
    "promo": "7101001",
    "tipoOperacion": "DESCUENTO",
    "tipoRegistro": "SIMPLE",
    "targetTable": "P_DESCUENTO",
    "recordsAffected": 1
  },
  "warnings": [],
  "errors": []
}
```

## Respuesta con error funcional

```json
{
  "success": false,
  "statusCode": "VALIDATION_ERROR",
  "message": "El payload contiene errores de validacion",
  "traceId": "ROAD-20260601-000002",
  "timestamp": "2026-06-01T14:22:00Z",
  "result": null,
  "warnings": [],
  "errors": [
    {
      "code": "ERR_REQUIRED_FIELD",
      "field": "escalas",
      "message": "El campo escalas es obligatorio para condiciones escaladas"
    }
  ]
}
```

---

## Códigos de estado y errores

Status de negocio sugeridos:

- `OK`
- `VALIDATION_ERROR`
- `UNAUTHORIZED`
- `INTEGRATION_ERROR`
- `INTERNAL_ERROR`

HTTP sugerido:

- `200`: éxito
- `400`: request inválido
- `401`: autenticación inválida
- `409`: conflicto funcional (si aplica)
- `500`: error no controlado

---

## Compatibilidad BOF/RDC7/HH

- Históricamente: `CODDESC NULL` fue interpretado como simple/escalado
- Combos: `CODDESC con valor + PTIPO=6` y detalle en `P_DESCUENTO_COMBO_DET`
- Decisión de integración fase 1.2: persistir `CODDESC` cuando venga desde SAP para trazabilidad funcional
- Rama HH de referencia: `dev_road_2024_bak3`

---

## Convenciones y trazabilidad

- Convención de tags técnicos inline: `#EJCYYYYMMDD-FEATURE` / `#EJCYYYYMMDD-FIX`
- Mantener `traceId` en respuesta para correlación operativa
- Documentar payload de entrada y resultado esperado en pruebas QAS

---

## Checklist para implementador SAP ABAP/PI

1. Confirmar endpoint y autenticación por ambiente.
2. Enviar `coddescSap`, `indJerarq`, `regCond`, `promo` y `coddesc` cuando exista.
3. Respetar vigencias (`fechaIni`, `fechaFin`).
4. Para escalas, enviar arreglo `escalas` completo.
5. Para combos, enviar cabecera + `detalleCombo`.
6. Validar `success/statusCode/errors` de la respuesta, no solo HTTP.
7. Persistir `traceId` en bitácora de integración SAP para soporte.

---

## Notas importantes SAP

Los campos SAP mostrados en esta guía son de **referencia sugerida** para homologación.

- Pueden variar por entorno SAP, customizing, secuencia de acceso o diseño de interfaz local.
- La responsabilidad del integrador ABAP/PI es mapear su estructura SAP real hacia el contrato de entrada ROAD.
- Si cambia el origen SAP, el contrato ROAD debe mantenerse estable o versionarse explícitamente.

---

## Referencias internas del proyecto

- `ROADWedAPI/payloads/sap_descuentos/README.md`
- `ROADWedAPI/payloads/sap_descuentos/CATALOGO_ESCENARIOS.md`
- `road_toledano_agent_setup/project_context.yml`
- `road_toledano_agent_setup/agent_brain_state.yml`
