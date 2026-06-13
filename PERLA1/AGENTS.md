# PERLA1 Agent Guide

Scope: this file applies to the whole repository. More specific `AGENTS.md` files in subfolders override or extend these rules.

## Project Shape

- The playable runtime is `01_GIOCO_PRONTO_LOCAL_TEST/index.html`.
- The Windows launcher is `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`, which calls `AVVIA_GIOCO_SERVER_POWERSHELL.ps1` on `http://127.0.0.1:8000/`.
- Files under `report/` are diagnostics, snapshots, extracted scripts, and historical evidence. They are not the runtime unless a task explicitly says otherwise.
- `PERLA1_PROJECT_MAP.md` is the compact technical map of structure, engine flow, dependencies, validation, and known critical risks.
- `PERLA1_BLOCK_MAP.md` is the block-level ownership map for the monolithic runtime.
- `.codex/ORCHESTRATION.md` defines the project-scoped multi-agent workflow and anti-paradox rules.


## GitHub Sync Workflow

- The active synchronized project path is `PERLA1/` inside the Git repository root `codex/`.
- The parent `codex/` folder contains the user-facing sync scripts: `00_APRI_PERLA1.bat`, `01_AGGIORNA_PROGETTO_PRIMA_DI_LAVORARE.bat`, and `02_SALVA_PROGETTO_SU_GITHUB.bat`.
- Prefer working in the synchronized GitHub copy, not in older standalone copies under `Documents/`.
- When providing user-facing file paths, use the synchronized GitHub copy when available.
- After meaningful work, ensure the user knows to run `02_SALVA_PROGETTO_SU_GITHUB.bat`, or handle commit/push if explicitly asked.
- Do not hard-code absolute user-specific clone paths into runtime or sync scripts; scripts should stay relative to their own location.

## Default Workflow

- Read `PERLA1_PROJECT_MAP.md` early when the task touches runtime structure, renderer order, roofs/ceilings, sprites, rain, minimap, dependencies, validation, or historical failure modes.
- Read `PERLA1_BLOCK_MAP.md` early when the task touches the monolithic runtime or crosses renderer/data/launcher blocks.
- Read the relevant code before proposing a fix.
- Prefer focused patches over broad rewrites.
- Use `apply_patch` for manual edits.
- Keep user changes; do not revert unrelated work.
- For runtime behavior changes, update the visible build id/name in `index.html` and launcher labels when appropriate.
- Do not trust `file://` for final validation. Test through the local server route used by the user.
- After meaningful work, update `PERLA1_PROJECT_MAP.md` and/or `PERLA1_BLOCK_MAP.md` if the change affects structure, engine flow, dependencies, validation, current patch contracts, block ownership, or recurring risks.

## Codebase Chunking And Multi-Agent Orchestration

- Treat `01_GIOCO_PRONTO_LOCAL_TEST/index.html` as a monolithic runtime split into functional blocks documented in `PERLA1_BLOCK_MAP.md`.
- Before patching runtime code, name the impacted block ids and avoid touching unrelated blocks.
- The Team Leader owns coordination, integration, final validation claims, and the user-facing answer.
- Read-only auditors may inspect any block but cannot approve write work as complete.
- `safe-fixer` is the only general runtime write agent and must receive a narrow approved scope.
- `map-maintainer` may update only `PERLA1_PROJECT_MAP.md` and `PERLA1_BLOCK_MAP.md`; it must not edit runtime code, `.codex/agents/*.toml`, `.codex/config.toml`, `.codex/ORCHESTRATION.md`, or `AGENTS.md`.
- Extra temporary agents are allowed only for concrete gaps not covered by configured agents. They start read-only by default and need explicit file/block ownership before any write task.
- A write agent cannot validate its own patch as complete. Final readiness requires Team Leader review or separate read-only validation.
- If two agents would write the same file or block, serialize the work instead of running them in parallel.
- If orchestration rules conflict, follow the stricter rule and use `workflow-guard` to return `STOP` before continuing.

## Required Validation For Game Changes

Before saying a rendered game fix is ready:

- Parse the inline JavaScript from `01_GIOCO_PRONTO_LOCAL_TEST/index.html`.
- Load `http://127.0.0.1:8000/` with a cache-busting query string.
- Confirm `window.PERLA_BUILD_ID` matches the edited build.
- Check browser console/page errors.
- Capture screenshots for the exact visual risk area.
- Inspect screenshots visually; metrics alone are not enough.
- Read `perlaLastDrawStats()` or the relevant public debug summary for draw/roof counters.

## Performance And Regression Rules

- Do not re-enable expensive legacy roof/fill paths unless the user explicitly asks and the cost is measured.
- If a previous path was disabled for draw cost, keep it off until a measured replacement proves safe.
- Any visual fix near roofs, ceilings, rain cover, sprites, or wall occlusion must include both visual proof and draw/counter proof.
- Avoid adding full-screen or full-roof raster passes as a quick visual patch.
- If a fix increases draw work, explain the exact source and provide before/after counters.

## Communication

- Be direct about root cause, especially after a failed visual patch.
- Distinguish diagnosis from proof.
- When the user is testing locally, give the exact file/path/URL they should use.
- If Browser automation fails, report the fallback method and keep the target URL identical.


