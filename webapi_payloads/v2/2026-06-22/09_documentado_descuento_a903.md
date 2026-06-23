# Ejemplo documentado - descuento simple A903

## 1) JSON enviado

```json
{
  "regCond": "0001583303",
  "promo": "NO APLICA",
  "coddescSap": "ZK94",
  "coddesc": 1111111,
  "reemplazarExistente": true,
  "orgVent": "3000",
  "canDist": "10",
  "sector": "10",
  "indJerarq": 1,
  "cliente": "000100265",
  "accessSequence": "A903",
  "producto": "0484",
  "fechaini": "2026-06-19T00:00:00Z",
  "fechafin": "9999-12-31T00:00:00Z",
  "importe": 5.0,
  "unidadCondition": "PAB",
  "cantidadBase": 1.0,
  "unidadMedidaCondicion": "UN",
  "monedaCondicion": "PAB",
  "escalas": [],
  "comboItems": []
}
```

## 2) Descripción narrativa del escenario

Este caso representa un descuento simple por cliente y producto.

La secuencia `A903` indica que la llave comercial se resuelve con `Cliente + Producto`.
El tipo SAP `ZK94` se interpreta como condición simple de descuento, no como combo.

El payload ya trae `coddesc`, por lo que ROAD puede conservar ese identificador funcional.
La marca `reemplazarExistente=true` indica que, si existe una condición previa con la misma llave o `CODDESC`, el servicio puede reemplazarla antes de guardar la nueva versión.

No hay escalas ni detalle de combo, así que el flujo debe terminar en una sola fila de `P_DESCUENTO`.

## 3) Resultado del procesamiento

Resultado esperado funcional:

- `HTTP 200` si el guardado fue correcto.
- `TraceId` devuelto en la respuesta.
- `PersistenceAction` indicando `CREATED`, `UPDATED` o `REPLACED` según corresponda.
- `CODDESC` persistido en la tabla de trazas y en la condición ROAD.

Interpretación esperada del mapeo:

- `DESCTIPO` se resuelve con prioridad:
  - `TipoDescuento` si existe
  - `IndEscala` si viene informado
  - fallback por `Escalas`
- En este caso, al no venir escalas, normalmente queda como descuento simple.

## 4) Tablas afectadas en ROAD

Tablas principales:

- `P_DESCUENTO`
- `P_TRAZA_INTEGRACION_SAP`

## 5) Queries de validación

### Validar traza del caso

```sql
SELECT TOP (20)
    TRACEID,
    OPERACION,
    ENDPOINT,
    HTTP_STATUS,
    SUCCESS,
    ESTADO,
    PERSISTENCE_ACTION,
    CODDESC,
    ACCESS_SEQUENCE,
    FEC_AGR,
    HOSTNAME,
    USUARIO_APP
FROM P_TRAZA_INTEGRACION_SAP
WHERE HOSTNAME = 'PTSVR2012'
ORDER BY FEC_AGR DESC;
```

### Validar condición persistida

```sql
SELECT TOP (20)
    CODDESC,
    CLIENTE,
    CTIPO,
    PRODUCTO,
    PTIPO,
    TIPORUTA,
    RANGOINI,
    RANGOFIN,
    DESCTIPO,
    VALOR,
    GLOBDESC,
    FECHAINI,
    FECHAFIN,
    NOMBRE
FROM P_DESCUENTO
WHERE CODDESC = 1111111
ORDER BY FECHAINI DESC;
```

### Validar por llave comercial

```sql
SELECT TOP (20)
    CODDESC,
    CLIENTE,
    CTIPO,
    PRODUCTO,
    PTIPO,
    TIPORUTA,
    RANGOINI,
    RANGOFIN,
    DESCTIPO,
    VALOR
FROM P_DESCUENTO
WHERE CLIENTE = '000100265'
  AND PRODUCTO = '0484'
  AND TIPORUTA = 0
ORDER BY FECHAINI DESC;
```

## 6) Referencia técnica

- Mapper de descuentos: `ROADWedAPI/SAP/Descuentos/SapDescuentoMapper.cs`
- Controller de integración: `ROADWedAPI/Controllers/SapDescuentoController.cs`
