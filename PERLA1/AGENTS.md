# PERLA1 Agent Guide

Scope: this file applies to the whole repository. More specific `AGENTS.md` files in subfolders override or extend these rules.

## Project Shape

- The playable runtime is `01_GIOCO_PRONTO_LOCAL_TEST/index.html`.
- The Windows launcher is `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`, which calls `AVVIA_GIOCO_SERVER_POWERSHELL.ps1` on `http://127.0.0.1:8000/`.
- Files under `report/` are diagnostics, snapshots, extracted scripts, and historical evidence. They are not the runtime unless a task explicitly says otherwise.
- `PERLA1_PROJECT_MAP.md` is the compact technical map of structure, engine flow, dependencies, validation, and known critical risks.

## Default Workflow

- Read `PERLA1_PROJECT_MAP.md` early when the task touches runtime structure, renderer order, roofs/ceilings, sprites, rain, minimap, dependencies, validation, or historical failure modes.
- Read the relevant code before proposing a fix.
- Prefer focused patches over broad rewrites.
- Use `apply_patch` for manual edits.
- Keep user changes; do not revert unrelated work.
- For runtime behavior changes, update the visible build id/name in `index.html` and launcher labels when appropriate.
- Do not trust `file://` for final validation. Test through the local server route used by the user.
- After meaningful work, update `PERLA1_PROJECT_MAP.md` if the change affects structure, engine flow, dependencies, validation, current patch contracts, or recurring risks.

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
