# Codex Sync Repository Guide

Scope: this file applies to the whole `codex` Git repository.

## Repository Shape

- This repository is the synchronized GitHub workspace for Codex projects.
- PERLA1 lives in `PERLA1/`.
- The parent repository contains the user-facing sync scripts:
  - `00_APRI_PERLA1.bat` opens the current synchronized PERLA1 launcher.
  - `01_AGGIORNA_PROGETTO_PRIMA_DI_LAVORARE.bat` pulls the latest GitHub version before work.
  - `02_SALVA_PROGETTO_SU_GITHUB.bat` commits and pushes changes after work.
  - `00_NUOVO_PC_LEGGIMI.txt` explains how to clone this repository on a new PC.

## Source Of Truth

- The active PERLA1 source is `PERLA1/`, not older standalone folders under `Documents/`.
- Do not edit old historical copies such as `Documents/PERLA1_V271...` unless the user explicitly asks for forensic comparison.
- When giving the user paths, prefer paths under this GitHub repository.

## Sync Workflow

- Before meaningful work, make sure the working tree is up to date when practical.
- After meaningful work, remind the user to run `02_SALVA_PROGETTO_SU_GITHUB.bat`, or run the Git commit/push yourself when the user has asked you to handle synchronization.
- Keep sync scripts path-relative. Do not hard-code a Windows username or absolute clone path inside scripts unless there is no alternative.
- If a different PC uses a different local path, preserve the internal repository shape instead of depending on the old absolute path.

## Git Discovery On Windows

- Do not assume `git` is available in the terminal `PATH`.
- On this setup, GitHub Desktop may be installed and logged in while `where git` still fails.
- The real fallback that worked is GitHub Desktop's bundled Git under `%LOCALAPPDATA%\GitHubDesktop\app-*\resources\app\git\cmd\git.exe`.
- Sync scripts should first try `where git`, then find the bundled GitHub Desktop `git.exe` with PowerShell using `$env:LOCALAPPDATA`; do not hard-code `C:\Users\ASUS` or any other username.
- Avoid `dir /b /s "%LOCALAPPDATA%\GitHubDesktop\app-*\resources\app\git\cmd\git.exe"` as the only fallback: quoted wildcard paths in `cmd` are fragile and caused false "Git not found" failures.
- If GitHub sync fails only because Git is not found, check the GitHub Desktop bundled Git path before telling the user to reinstall Git.

## Safety

- Do not put generated zip files, temporary logs, local screenshots, or cache folders into Git unless the user explicitly asks.
- Keep project-local rules inside `PERLA1/AGENTS.md` and the coordinated PERLA1 companion docs: `PERLA1_PROJECT_MAP.md`, `PERLA1_BLOCK_MAP.md`, `PERLA1_CONTEXT_BUDGET.md`, `PERLA1_SYMBOL_INDEX.md`, `PERLA1_TASK_INTAKE_PROTOCOL.md`, and `PERLA1_RUNTIME_TEST_RUNBOOK.md`.
