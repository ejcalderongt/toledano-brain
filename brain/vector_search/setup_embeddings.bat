@echo off
setlocal
set ROOT=%~dp0..
python -m pip install --upgrade pip
python -m pip install sentence-transformers
if errorlevel 1 (
  echo [WARN] No se pudo instalar sentence-transformers. El brain seguira con fallback local.
  exit /b 0
)
echo [OK] sentence-transformers instalado. Puedes construir embeddings reales con:
echo python brain\vector_search\build_index.py --mode embeddings
exit /b 0
