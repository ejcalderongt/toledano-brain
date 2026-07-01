param(
  [switch]$ForceLocal
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

try {
  python -m pip install --upgrade pip | Out-Host
  if (-not $ForceLocal) {
    python -m pip install sentence-transformers | Out-Host
    Write-Host "[OK] sentence-transformers instalado."
    Write-Host "[OK] Generando indice con embeddings si el entorno lo permite..."
    python "$PSScriptRoot\build_index.py" --mode embeddings | Out-Host
    return
  }
} catch {
  Write-Warning "No se pudo activar embeddings reales. Se usara fallback local."
}

python "$PSScriptRoot\build_index.py" --mode local | Out-Host
