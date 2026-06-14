# PERLA1 Report Agent Guide

Scope: this file applies to `report/`.

## Purpose

- This folder is diagnostic memory: reports, extracted inline scripts, smoke tests, asset checks, and historical evidence.
- Use these files to understand why a previous patch failed or what a build contained.
- Do not treat extracted scripts here as the active runtime. The active runtime is `../01_GIOCO_PRONTO_LOCAL_TEST/index.html`.

## Reading Rules

- Prefer concise targeted reads with `rg` before opening huge extracted scripts.
- When comparing versions, identify the exact build ids and file names involved.
- If a report conflicts with the current runtime, verify against the runtime code before acting.
- Use reports to explain history, not to justify skipping current visual validation.

## Writing Rules

- Do not create new report artifacts unless the user asks or the report is needed to preserve a complex diagnosis.
- Exception: ignored/generated local CI structure reports from `tools/perla_local_ci.ps1` or `tools/perla_runtime_analyzer.mjs` may be written as disposable local evidence. Prefer `-ReportPath` outside the repo for routine validation. Do not treat generated structure reports as promoted documentation unless the user explicitly asks.
- If creating a report, include:
  - build id and date,
  - files changed,
  - root cause,
  - exact runtime URL used,
  - validation commands or browser method,
  - screenshot paths,
  - relevant draw/roof counters,
  - remaining risks.
- Keep reports compact and structured. Do not duplicate large extracted scripts or full logs unless explicitly requested.

## Safety

- Never patch the game by editing an extracted script in this folder.
- Never delete historical diagnostics unless the user explicitly asks.
- Never stage disposable generated local CI reports unless the user explicitly asks to promote that report.
- Avoid report churn for ordinary small code fixes; summarize validation in the chat instead.
