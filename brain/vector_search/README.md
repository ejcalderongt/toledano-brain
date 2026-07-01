# ROAD Toledano - Semantic Search Layer

Esta carpeta agrega una primera capa de recuperacion semantica sobre el brain existente.

## Objetivo

- Convertir documentos YAML/MD/JSON del brain en vectores ligeros.
- Permitir busqueda por similitud para contextos como:
  - descuentos y recargos
  - trazas SAP
  - liquidacion frmLiqVend
  - payloads de validacion WebAPI

## Enfoque actual

No se usa un vector store externo todavia.
La capa actual funciona en puro Python con:

- tokenizacion simple
- vectorizacion tipo bolsa de palabras
- similitud coseno
- indice local en JSON

Esto es suficiente para:

- buscar rapidamente documentos afines
- preparar el brain para embeddings reales despues
- evitar dependencia de librerias pesadas

## Archivos

- `build_index.py`: construye el indice vectorial local.
- `query_index.py`: consulta el indice por texto.
- `indexes/`: salida generada del indice.
- `examples/`: ejemplos de consulta.

## Fuentes indexadas por defecto

- `brain/**/*.md`
- `brain/**/*.yml`
- `brain/**/*.yaml`
- `webapi_payloads/**/*.json`

## Uso

Construir indice:

```powershell
python brain/vector_search/build_index.py
```

Consultar:

```powershell
python brain/vector_search/query_index.py "TDS001 CODDESC repetido"
```

## Evolucion futura

Cuando haya mas contexto o una libreria disponible, esta capa puede migrar a:

- embeddings reales
- hybrid search (texto + vector)
- re-ranking por tipo de documento
