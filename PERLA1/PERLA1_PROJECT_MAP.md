# PERLA1 Project Map

Last updated: 2026-06-13
Current runtime build observed in `index.html`: `PERLA1_V274_REAL_ROOF_GEOMETRIC_EAVE_EDGE_SAFE_LOCAL`

This file is the fast technical map for agents. Use it to orient before touching runtime code, and update it when structure, entrypoints, validation workflow, dependencies, or major renderer contracts change.

## Entry Points

| Purpose | Path / Symbol | Notes |
| --- | --- | --- |
| Playable runtime | `01_GIOCO_PRONTO_LOCAL_TEST/index.html` | Single-file HTML/CSS/JS game runtime. This is the active source of truth. |
| User launcher | `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat` | Correct user-facing launch path. Calls the PowerShell server. |
| Local server | `AVVIA_GIOCO_SERVER_POWERSHELL.ps1` | Serves `01_GIOCO_PRONTO_LOCAL_TEST/` on `http://127.0.0.1:8000/`. |
| Assets | `01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/` | PNG sprite/wall/sky assets loaded through `ASSET_MANIFEST`. |
| Reports/history | `report/` | Diagnostics, extracted inline scripts, smoke tests, historical reports. Not runtime source. |
| Current failure report | `PERLA1_REPORT_FALLIMENTI_OTTIMIZZAZIONE_TETTO_V271_2026-06-13.txt` | Root-level failure analysis report from the roof optimization work. |
| Codex subagents | `.codex/config.toml`, `.codex/agents/*.toml` | Project-scoped Codex subagent configuration. Read-only auditors plus one narrow workspace-write fixer. |

## Runtime Architecture

| Subsystem | Key Symbols | Location Hint | Role |
| --- | --- | --- | --- |
| Build metadata | `PERLA_BUILD_ID` | around line `195` | Public build id; verify in browser after edits. |
| Asset loading | `ASSET_BASE`, `ASSET_MANIFEST`, `loadAssets`, `getTex` | around lines `5865-5910` | Loads grouped texture frames from `assets/raycast/`. |
| Main loop | `gameLoop` | around line `25845` | Updates environment/player, calls `drawWorld`, minimap, perf stats. |
| World renderer | `drawWorld` | around line `24895` | Main frame renderer: backdrop, floor/ceiling, wallcasting, roof, canopy, sprites, rain. |
| Floor/ceiling pass | floor loop inside `drawWorld` | start of `drawWorld` | Floor rows, ceiling rows, ceiling depth buffer, real ceiling clone. |
| Wallcasting | wall loop inside `drawWorld` | after floor/ceiling pass | Raycasts walls, fills `ZBuffer`, `WallTopBuffer`, `WallBottomBuffer`, `WallOwnerBuffer`. |
| Roof layer | `drawRoofLayer2_5D` | around line `11762` | Orchestrates sloped roof planes, gable caps, V274 edge, V272 off pass, tower fascia. |
| Roof planes | `drawSlopedRoofLayer2_5D` | around line `11577` | Sloped sector roof casting with budgets/watchdogs. |
| Roof gables | `drawSlopedRoofGableCaps2_5D` | around line `11503` | Vertical roof cap rendering. |
| Geometric eave edge | `perlaRealRoofGeometricEaveEdgePassV274` | around line `2316` | Current visible external eave/border path for modern reception/bath roofs. |
| Sprites | `getSpriteRenderCandidates`, sprite loop in `drawWorld` | around lines `596`, after roof/canopy | Candidate selection, shadows, stripe rendering, occlusion. |
| Rain/weather | `drawWorldRainParticlesV222`, weather V246-V257 symbols | around line `23746` | World rain and later stabilizers. |
| Minimap | `drawMiniMap` | around line `25490` | Desktop or frame-skipped mobile minimap. |
| Debug API | `window.__PERLA_DEBUG__`, `perlaLastDrawStats`, `setPlayerForDebug` | near file end | Runtime inspection and deterministic QA poses. |

## Data Model And Owners

| Data | Meaning |
| --- | --- |
| `map` | Wall/collision texture ids. |
| `fMap` | Floor type ids. |
| `cMap` | Ceiling/cover type ids. |
| `ceilingOwnerMap` | Owner id for ceiling/cover cells. |
| `sprites` | Sprite/object instances. |
| `roofSegments` | Authoritative roof geometry list. Use this for roof visual geometry. |
| `ZBuffer` | Wall/sprite depth reference by screen column. |
| `CeilingDepthBuffer`, `CeilingOwnerBuffer`, `CeilingColumnHasDepth` | Technical ceiling/cover depth and ownership. |
| `WallTopBuffer`, `WallBottomBuffer`, `WallOwnerBuffer` | Wall top/bottom/owner per screen column. |
| Owner `1` | Reception modern building/roof. |
| Owner `2` | Bath modern building/roof. |
| Tower owner | Lifeguard tower path, separate from modern reception/bath roof logic. |

## Roof And Ceiling Patch Stack

| Version | Status | Contract |
| --- | --- | --- |
| V259 | active support | Roof hotspot/budget path. |
| V261/V262 | active support | Coverage/pergola/roof stable budget and emergency cap logic. |
| V263 | active support | Branch lock for owner 1/2 roof cost paths. |
| V264 | active support | Roof cost watchdog. |
| V265 | active support, not primary eave | Edge rail/ultra budget support. Must not become the primary reception/bath eave border under V274. |
| V266/V267 | active support | Roof silhouette/mask/wall-clip path used when original fill is skipped. |
| V270 | active support | Real ceiling clone eave path. No fake perimeter bands. |
| V271 | active support | Side-aware continuity for the real ceiling clone. |
| V272 | runtime off rollback | Real roof underside/eave near geometry pass. Produced slab/cost risk; do not turn on casually. |
| V273 | active depth/anchor, visual bypassed by V274 | External ceiling clone eave anchor. Its strip visual is not the final visible external border when V274 handles the edge. |
| V274 | current visible eave contract | Real roof geometric eave edge. Visible external roof border comes from projected `roofSegments`, not floorcasting/clone samples. |

## V274 Roof Edge Contract

Current expected behavior for modern reception/bath roof/eave work:

- Visible external border/eave is drawn by `perlaRealRoofGeometricEaveEdgePassV274`.
- Geometry source is `roofSegments`, filtered to modern owner `1` and `2`.
- The pass runs from `drawRoofLayer2_5D` after sloped roof planes and gable caps.
- V273 external clone remains useful for continuity/depth anchoring, but V273 strip visual must be bypassed where V274 handles the visible edge.
- V272 remains runtime-off.
- V265 edge rail is not the primary eave replacement.

Expected counters in affected V274 roof views:

- `realCeilingCloneEaveStripQueuedV273 === 0`
- `realCeilingCloneEaveStripDrawnV273 === 0`
- `realCeilingCloneEaveStripPixelsV273 === 0`
- `realRoofGeometricEavePixelsV274 > 0` when a modern eave is visible
- `realCeilingCloneExternalVisualHandledV274 > 0` when external clone cells are present

## Known Critical Failure Modes

| Failure | Root Cause | Avoidance |
| --- | --- | --- |
| Dotted/broken external roof border | Using floorcasting/ceiling-clone samples as visible border in grazing views. | Use projected `roofSegments` geometry for visible eaves. |
| Huge red roof slabs | Re-enabling or approximating full underside/near geometry without tight visibility/budget. | Keep V272 off unless explicitly measured and redesigned. |
| Edge disappears behind same building wall | Too strict same-owner wall/roof occlusion or screen-space strip drawn before wallcasting. | Draw real roof edge in roof layer and allow same-owner top joint carefully. |
| Draw count rises for no visible gain | Queuing/deduping/bridging many screen-space strips. | Prefer small geometry-derived passes and verify counters. |
| Testing stale or wrong build | Opening `file://` or cached page. | Use server URL with cache-busting query and verify `PERLA_BUILD_ID`. |
| Editing historical snapshot | Modifying extracted scripts in `report/`. | Patch only active runtime unless explicitly instructed. |

## Standard Validation

For rendered runtime changes:

1. Parse inline JS from `01_GIOCO_PRONTO_LOCAL_TEST/index.html`.
2. Launch or reuse `http://127.0.0.1:8000/` through the project server path.
3. Load with a cache-busting query, for example `http://127.0.0.1:8000/?v=<build>_<timestamp>`.
4. Confirm page title and `window.PERLA_BUILD_ID`.
5. Check console/page errors.
6. Use `window.__PERLA_DEBUG__.setPlayerForDebug(...)` for deterministic poses.
7. Capture `#screen` screenshots.
8. Inspect screenshots visually for the exact regression class.
9. Read `window.__PERLA_DEBUG__.perlaLastDrawStats()` and relevant public summaries.

Preferred roof/eave QA poses:

| Scenario | Debug Pose |
| --- | --- |
| Reception side | `setPlayerForDebug(62, 10, .8, -.45)` |
| Reception close grazing | `setPlayerForDebug(70, 9, -1, 0)` |
| Reception close side | `setPlayerForDebug(64, 10, .7, -.55)` |
| Bath side | `setPlayerForDebug(88.8, 65, 1, 0)` |

## Local Tooling And Dependencies

There is no package build step for the game runtime. It is served as static files.

Known useful local tools:

- PowerShell for launcher/server and file inspection.
- `rg` for source search.
- Bundled Node.js from Codex workspace dependencies for JS parse checks and Playwright/Chrome validation.
- Chrome headless fallback when the in-app Browser plugin cannot connect.

Project-scoped Codex agents:

| Agent | Sandbox | Purpose |
| --- | --- | --- |
| `code-mapper` | `read-only` | Maps real project structure, runtime flow, entry points, symbols, and unknowns before planning work. |
| `regression-auditor` | `read-only` | Audits concrete behavioral regressions and anti-regression invariants, especially roof/ceiling/rain/sprite/render-order risks. |
| `performance-auditor` | `read-only` | Audits draw/fps/cache/hotspot counters and expected measurements without editing code. |
| `workflow-guard` | `read-only` | Detects rule/method conflicts, repeated failure loops, and unsafe workflow drift; reports `PROCEED` or `STOP`. |
| `safe-fixer` | `workspace-write` | Performs narrow approved patches after diagnosis is clear. It is the only local custom agent with write permission. |

Configured subagent limits: `max_threads = 4`, `max_depth = 1`, `job_max_runtime_seconds = 2400`.

Browser validation notes:

- Prefer the in-app Browser when available.
- If Browser fails due sandbox/Windows permission issues, use Playwright/Chrome headless but keep the target URL identical.
- Do not install dependencies unless explicitly needed and approved.

## Reports And Snapshots

Use `report/` to understand historical context:

- `REPORT_V270...`, `REPORT_V271...`, `REPORT_V272...`, `REPORT_V273...` document roof/ceiling progression.
- `EXTRACTED_INDEX_INLINE_SCRIPT_V*.js` files are snapshots only.
- `NODE_SMOKE_V*.js` and outputs are historical smoke checks.
- `STATUS_PROGETTO_E_DIP...` and master reports may contain dependency/status context, but verify against current runtime code.

## Update Policy For This Map

Update this file when:

- the runtime entrypoint changes,
- launcher/server behavior changes,
- major renderer order changes,
- roof/ceiling/sprite/rain/minimap ownership or contracts change,
- a new Vxxx patch supersedes an old contract,
- validation procedure changes,
- dependencies/tooling change,
- a new recurring failure mode is discovered.

Do not update this file for tiny cosmetic edits that do not change structure, contracts, validation, or known risks.
