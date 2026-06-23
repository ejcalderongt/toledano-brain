# Ejemplo documentado - descuento simple A903

## Payload

- Archivo: `09_documentado_descuento_a903.json`
- Escenario: descuento simple por `A903`

## Lectura funcional

Este payload representa una condición simple con estas claves principales:

- `accessSequence = A903`
- `cliente = 000100265`
- `producto = 0484`
- `coddescSap = ZK94`

## Cómo lo interpreta el WebAPI

1. `A903` indica que la clave comercial es `Cliente + Producto`.
2. `ZK94` lo clasifica como condición de descuento simple, no combo.
3. `coddesc = 1111111` se usa como identificador funcional ROAD si viene informado.
4. `reemplazarExistente = true` indica que el servicio puede borrar primero la condición previa de la misma llave antes de insertar la nueva versión.
5. Como `escalas` está vacío, el mapeo no entra a escenario por rangos.
6. El tipo de cálculo `DESCTIPO` se resuelve por prioridad del mapper:
   - `TipoDescuento`, si viene en el payload
   - `IndEscala`, si viene informado
   - fallback por contenido de `escalas`

## Resultado esperado

- Se persiste una condición simple en `P_DESCUENTO`.
- La respuesta debe devolver el `TraceId` y el estado de persistencia.
- Si el payload es válido y no hay conflicto de llave, la respuesta debe ser `200`.

## Referencia técnica

- Mapper de descuentos: `ROADWedAPI/SAP/Descuentos/SapDescuentoMapper.cs`
- Controller de integración: `ROADWedAPI/Controllers/SapDescuentoController.cs`
