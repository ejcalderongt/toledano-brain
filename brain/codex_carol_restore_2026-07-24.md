# Restaurar el brain ROAD Toledano en Codex - PC de Carol

## Resultado esperado

Codex podrá recuperar reglas, arquitectura, incidentes, contratos SAP y rutas de código
de BOF/WebAPI/HH sin copiar documentos del brain dentro de los repositorios fuente.

## Instalación

1. Clonar el repositorio:

```powershell
git clone https://github.com/ejcalderongt/toledano-brain.git C:\Proyectos\toledano-brain
```

2. Instalar el skill y reconstruir el índice local:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Proyectos\toledano-brain\brain\tools\install_codex_toledano_brain.ps1 -BrainRoot C:\Proyectos\toledano-brain
```

3. Reiniciar Codex para que descubra el skill `ejc-skill-toledano`.

4. Abrir en Codex el repositorio BOF o HH y solicitar explícitamente:

```text
Usa ejc-skill-toledano. Carga el brain desde C:\Proyectos\toledano-brain y confirma
agent_brain_state, knowledge_manifest y el contrato del flujo antes de modificar código.
```

## Prueba de recuperación

```powershell
python C:\Proyectos\toledano-brain\brain\vector_search\query_index.py "TC0012 combo 0108 0826 descuento individual"
python C:\Proyectos\toledano-brain\brain\vector_search\query_index.py "TC0011 precio especial TMP_PRECESPEC total cero HH"
```

Las primeras respuestas deben incluir `knowledge_manifest_2026-07-24.yml` y los contratos
BOF/HH relacionados.

## Orden de lectura del agente

1. `brain/knowledge_manifest_2026-07-24.yml`
2. `brain/agent_brain_state.yml`
3. `brain/project_context.yml`
4. Contrato específico BOF o HH.
5. Traza o escenario de aceptación correspondiente.

## Separación obligatoria

- `toledano-brain`: conocimiento, decisiones, vectores, consultas diagnósticas y guías.
- `ROAD_TOLEDANO`: código BOF/WebAPI.
- `road_2023`: código HH Android.

Nunca copiar la carpeta `brain/` dentro de los repositorios de código.

## Actualización posterior

```powershell
git -C C:\Proyectos\toledano-brain pull --ff-only
powershell -ExecutionPolicy Bypass -File C:\Proyectos\toledano-brain\brain\tools\install_codex_toledano_brain.ps1 -BrainRoot C:\Proyectos\toledano-brain
```
