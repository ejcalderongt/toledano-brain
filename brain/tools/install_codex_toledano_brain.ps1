param(
    [Parameter(Mandatory = $true)]
    [string]$BrainRoot,
    [switch]$SkipIndex
)

$ErrorActionPreference = 'Stop'
$resolvedBrain = (Resolve-Path -LiteralPath $BrainRoot).Path
$skillSource = Join-Path $resolvedBrain 'skills\ejc-skill-toledano'
$manifest = Join-Path $resolvedBrain 'brain\knowledge_manifest_2026-07-24.yml'
$indexBuilder = Join-Path $resolvedBrain 'brain\vector_search\build_index.py'
$codexSkills = Join-Path $env:USERPROFILE '.codex\skills'
$skillTarget = Join-Path $codexSkills 'ejc-skill-toledano'

if (-not (Test-Path -LiteralPath $skillSource)) { throw "No se encontró el skill: $skillSource" }
if (-not (Test-Path -LiteralPath $manifest)) { throw "No se encontró el manifiesto: $manifest" }

New-Item -ItemType Directory -Force -Path $codexSkills | Out-Null
New-Item -ItemType Directory -Force -Path $skillTarget | Out-Null
Copy-Item -Path (Join-Path $skillSource '*') -Destination $skillTarget -Recurse -Force

[Environment]::SetEnvironmentVariable('TOLEDANO_BRAIN_ROOT', $resolvedBrain, 'User')
$env:TOLEDANO_BRAIN_ROOT = $resolvedBrain

if (-not $SkipIndex) {
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        throw 'Python no está disponible. Instálelo o ejecute nuevamente con -SkipIndex.'
    }
    & python $indexBuilder --root $resolvedBrain --mode local
    if ($LASTEXITCODE -ne 0) { throw "Falló la construcción del índice con código $LASTEXITCODE" }
}

Write-Host "Brain ROAD Toledano instalado."
Write-Host "TOLEDANO_BRAIN_ROOT=$resolvedBrain"
Write-Host "Skill=$skillTarget"
Write-Host "Reinicie Codex para recargar el skill."
