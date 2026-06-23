# Test Toledano - Analisis 2026-06-22

Carpeta de análisis para clasificar registros y payloads relacionados con `P_TRAZA_INTEGRACION_SAP`.

## Filtro base sugerido

```sql
SELECT *
FROM P_TRAZA_INTEGRACION_SAP
WHERE hostname = 'PTSVR2012'
ORDER BY fec_agr DESC;
```

## Objetivo

- Agrupar trazas por tipo funcional.
- Facilitar lectura por patrón de condición SAP.
- Dejar un orden estable para soporte, diagnóstico y release notes.

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

1. Colocar aquí el análisis de cada traza con fecha.
2. Usar un nombre corto por caso.
3. Si el caso cambia de release, conservar el histórico y crear una nueva subcarpeta por fecha.

## Subcarpetas sugeridas

- [zk-descuento-simple](zk-descuento-simple/README.md)
- [zr-recargo-simple](zr-recargo-simple/README.md)
- [zk-combo](zk-combo/README.md)
- [zr-combo](zr-combo/README.md)
- [invalidos](invalidos/README.md)
- [otros](otros/README.md)
