# PERLA1 Block Map

Last updated: 2026-06-13

This file is the block-level map for safe work on the PERLA1 monolithic runtime. Use it with `PERLA1_PROJECT_MAP.md` before planning or patching `01_GIOCO_PRONTO_LOCAL_TEST/index.html`.

## Purpose

PERLA1 currently uses a single-file HTML/CSS/JS runtime. Work on this kind of monolith must be scoped by functional blocks, not by file names alone.

Rules:

- Treat each block below as a separate ownership area.
- Name the impacted block before changing runtime code.
- Do not let two write agents edit the same block in parallel.
- If a task crosses blocks, the Team Leader keeps integration ownership.
- Update this map when a new stable subsystem, contract, validation hook, or recurring risk appears.

## Runtime Blocks

| Block ID | Block | Main Symbols / Areas | Ownership Notes | Required Validation |
| --- | --- | --- | --- | --- |
| `boot-shell` | HTML/CSS/runtime boot | document shell, canvas, UI overlays, `PERLA_BUILD_ID` | Small metadata and boot changes only. Runtime behavior changes must update build id when appropriate. | Page loads through local server, title/build id match. |
| `asset-loading` | Asset manifest and texture loading | `ASSET_BASE`, `ASSET_MANIFEST`, `loadAssets`, `getTex` | Keep paths relative to runtime. Do not rename assets without manifest audit. | Asset load check, console check, missing texture scan. |
| `world-data` | World maps and owners | `map`, `fMap`, `cMap`, `ceilingOwnerMap`, owner ids | Changes affect collision, ceiling cover, roofs, rain, and minimap. | Deterministic pose check near changed cells, minimap sanity. |
| `floor-ceiling` | Floor and ceiling renderer | floor loop in `drawWorld`, ceiling rows, ceiling depth buffers | May provide continuity/depth data. Must not fake visible V274 roof edges. | Visual check plus depth/counter sanity where relevant. |
| `wallcasting` | Wall renderer and wall buffers | wall loop in `drawWorld`, `ZBuffer`, `WallTopBuffer`, `WallBottomBuffer`, `WallOwnerBuffer` | Owns solid wall visibility. Changes can break sprites, roof clipping, rain cover. | Visual wall occlusion check, console check, affected debug poses. |
| `roof-system` | Roof and eave system | `roofSegments`, `drawRoofLayer2_5D`, `drawSlopedRoofLayer2_5D`, `drawSlopedRoofGableCaps2_5D`, V259-V274 helpers | Highest-risk rendering block. Preserve V274 contract unless explicitly superseded. | Required roof poses, V273/V274 counters, slab/dotted-edge inspection. |
| `sprites` | Sprite selection and drawing | `sprites`, `getSpriteRenderCandidates`, sprite loop in `drawWorld` | Depends on depth buffers and render order. Avoid broad candidate changes without performance audit. | Candidate/visible/stripe counters, occlusion screenshot. |
| `weather-rain` | Weather and rain rendering | `drawWorldRainParticlesV222`, V246-V257 rain helpers | Rain is sensitive to cover, portals, depth, and camera volume. | Indoor/outdoor transition checks, rain visibility/occlusion counters if exposed. |
| `minimap` | Minimap rendering | `drawMiniMap`, mobile frame-skipping | Keep mobile cost low. Avoid full redraw assumptions. | Desktop and mobile viewport sanity, minimap cost if changed. |
| `debug-api` | Public debug and QA hooks | `window.__PERLA_DEBUG__`, `perlaLastDrawStats`, `setPlayerForDebug` | Debug hooks are validation infrastructure. Preserve compatibility unless replacing intentionally. | Existing debug calls still work. |
| `performance-observability` | Performance counters and runtime stats | draw/fps/cache counters, `perlaLastDrawStats`, roof and sprite summaries | Provides proof for performance-sensitive work. Do not replace measured counters with visual guesses. | Before/after counters for changed hot paths. |
| `launcher-server` | Windows launcher and local server | `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`, `AVVIA_GIOCO_SERVER_POWERSHELL.ps1` | Keep path-relative and user-friendly. Do not hard-code usernames. | Launch route serves `http://127.0.0.1:8000/`. |
| `sync-docs` | Repository sync and technical docs | parent sync scripts, `AGENTS.md`, `PERLA1_PROJECT_MAP.md`, this file, `.codex/` | Rule changes must not silently weaken validation or write boundaries. | Rules remain consistent; no circular agent authority. |
| `reports-history` | Historical reports and snapshots | `report/`, extracted scripts, smoke outputs | Read for evidence only. Do not patch runtime through extracted scripts. | Current runtime verification wins over historical report assumptions. |

## Block Ownership Rules

- `safe-fixer` may patch runtime blocks only after the impacted block is named and the diagnosis is clear.
- `map-maintainer` may update `PERLA1_PROJECT_MAP.md` and `PERLA1_BLOCK_MAP.md` only. It must not edit runtime code, `.codex/config.toml`, `.codex/agents/*.toml`, `.codex/ORCHESTRATION.md`, or `AGENTS.md`.
- Read-only auditors may inspect any block but must not propose broad rewrites as the first fix.
- Extra temporary agents start read-only unless the Team Leader assigns an explicit disjoint write scope.
- A write agent cannot approve its own patch as validated. Validation must come from the Team Leader or a separate read-only auditor.

## Cross-Block Risk Map

| Source Block | Commonly Affected Blocks | Risk |
| --- | --- | --- |
| `floor-ceiling` | `roof-system`, `wallcasting`, `weather-rain` | Ceiling continuity changes can create fake visible roof edges or cover errors. |
| `wallcasting` | `roof-system`, `sprites`, `weather-rain` | Wall depth and owner buffers drive clipping and occlusion. |
| `roof-system` | `floor-ceiling`, `wallcasting`, `sprites`, `performance-observability` | Roof fixes can create slab fills, dotted borders, or draw-cost spikes. |
| `sprites` | `wallcasting`, `floor-ceiling`, `performance-observability` | Candidate expansion can overdraw or break occlusion. |
| `asset-loading` | all visual blocks | Missing or renamed assets can look like renderer failures. |
| `launcher-server` | validation workflow | Wrong route or cache can validate a stale build. |

## Minimum Block Handoff

Any agent reporting on a block must return:

- block id,
- files read,
- exact symbols or line hints,
- risk level,
- proposed next action,
- validation required,
- unknowns marked as `Da indagare`.
