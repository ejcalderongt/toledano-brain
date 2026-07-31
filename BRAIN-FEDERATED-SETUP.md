# Federated Brain Bootstrap (toledano-brain)

## Bootstrap portable

Defina `TOLEDANO_BRAIN_ROOT` con la ruta del clon local. Para instalar el skill y
reconstruir el índice semántico use:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:TOLEDANO_BRAIN_ROOT\brain\tools\install_codex_toledano_brain.ps1" -BrainRoot $env:TOLEDANO_BRAIN_ROOT
```

Entrada canónica: `brain/knowledge_manifest_2026-07-31.yml`.
Guía para otra PC: `brain/codex_carol_restore_2026-07-24.md`.
