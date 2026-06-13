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

## Safety

- Do not put generated zip files, temporary logs, local screenshots, or cache folders into Git unless the user explicitly asks.
- Keep project-local rules inside `PERLA1/AGENTS.md` and technical map updates inside `PERLA1/PERLA1_PROJECT_MAP.md`.
