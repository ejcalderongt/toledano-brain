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

La capa funciona en modo dual:

- `embeddings` si esta disponible `sentence-transformers`
- `local` como fallback si no hay dependencias o modelo

Tecnicas usadas:

- tokenizacion simple para fallback local
- embeddings reales cuando la libreria esta instalada
- similitud coseno
- indice local en JSON

Esto es suficiente para:

- buscar rapidamente documentos afines
- preparar el brain para embeddings reales despues
- evitar dependencia de librerias pesadas
- no bloquear uso en PCs sin paquetes instalados

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

Forzar embeddings:

```powershell
python brain/vector_search/build_index.py --mode embeddings
```

Forzar fallback local:

```powershell
python brain/vector_search/build_index.py --mode local
```

Consultar:

```powershell
python brain/vector_search/query_index.py "TDS001 CODDESC repetido"
```

Si el indice fue generado con embeddings, la consulta intenta usar el mismo modo.
Si no existe la dependencia en la PC, el build sugiere instalarla y cae a fallback local.

## Evolucion futura

Cuando haya mas contexto o una libreria disponible, esta capa puede migrar a:

- embeddings reales
- hybrid search (texto + vector)
- re-ranking por tipo de documento

## Recomendacion de instalacion

Para activar embeddings reales en otra PC:

```powershell
pip install sentence-transformers
```

Si no se instala, el brain sigue funcionando con fallback local.
