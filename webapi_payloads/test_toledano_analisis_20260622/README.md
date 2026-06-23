# Test Toledano - Analisis 2026-06-22

Carpeta de análisis para documentar cada validación con esta secuencia:

1. JSON enviado.
2. Descripción narrativa del escenario.
3. Resultado del procesamiento.
4. Tablas afectadas en ROAD y queries de validación.

## Filtro base sugerido

```sql
SELECT *
FROM P_TRAZA_INTEGRACION_SAP
WHERE hostname = 'PTSVR2012'
ORDER BY fec_agr DESC;
```

## Objetivo

- Mostrar exactamente qué se envió.
- Explicar cómo lo interpreta ROAD.
- Mostrar qué se guardó o falló.
- Dejar validación SQL repetible para soporte y DBA.

## Convención de carpetas

- `zk-descuento-simple`: descuentos simples.
- `zr-recargo-simple`: recargos simples.
- `zk-combo`: combos de descuento.
- `zr-combo`: combos de recargo.
- `invalidos`: payloads o trazas que fallaron validación.
- `otros`: casos que no encajan en las familias anteriores.

## Regla de nombres

Formato recomendado:

- `ZK-descuento-por-cantidad`
- `ZR-recargo-por-ruta`
- `ZK-combo-por-cliente`
- `ZR-combo-por-ruta`

Reglas:

- corto
- fácil de identificar
- con prefijo funcional primero
- sin nombres largos

## Cómo usar esta carpeta

1. Crear una subcarpeta por fecha de análisis.
2. Guardar allí el JSON original y el README narrativo del caso.
3. Usar un nombre corto por caso.
4. Si el caso cambia de release, conservar el histórico y crear una nueva subcarpeta por fecha.

## Subcarpetas sugeridas

- [zk-descuento-simple](zk-descuento-simple/README.md)
- [zr-recargo-simple](zr-recargo-simple/README.md)
- [zk-combo](zk-combo/README.md)
- [zr-combo](zr-combo/README.md)
- [invalidos](invalidos/README.md)
- [otros](otros/README.md)

## Caso documentado de ejemplo

- [Descuento simple A903](../v2/2026-06-22/09_documentado_descuento_a903.md)
