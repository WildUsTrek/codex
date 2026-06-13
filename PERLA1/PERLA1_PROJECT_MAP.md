# PERLA1 Project Map

Last updated: 2026-06-14
Current runtime build observed in `index.html`: `PERLA1_V275_REAL_EAVE_HANDOFF_SAFE_LOCAL`

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
| Block map | `PERLA1_BLOCK_MAP.md` | Functional block ownership map for the monolithic runtime and cross-block risks. |
| Context budget | `PERLA1_CONTEXT_BUDGET.md` | Rules for inspecting the monolithic runtime without flooding the Team Leader context. Limits handoff volume, not useful code inspection. |
| Symbol index | `PERLA1_SYMBOL_INDEX.md` | Current high-value symbol orientation map. Verify with `rg` before patching. |
| Task intake protocol | `PERLA1_TASK_INTAKE_PROTOCOL.md` | Required startup gate for selecting `CALL`/`CONSIDER`/`SKIP` agents and forcing guard/consistency/watchdog/skeptic/refactor consideration. |
| Runtime test runbook | `PERLA1_RUNTIME_TEST_RUNBOOK.md`, `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` | Practical Windows validation path: launcher/server first, then headless screenshot through system Chrome/Edge. |
| Codex orchestration | `.codex/ORCHESTRATION.md` | Team Leader workflow, subagent usage policy, extra-agent rules, and anti-paradox constraints. |
| Codex subagents | `.codex/config.toml`, `.codex/agents/*.toml` | Project-scoped Codex subagent configuration. Mostly read-only auditors, one runtime fixer, and one map-only maintainer. |
| Repository sync | `../00_APRI_PERLA1.bat`, `../01_AGGIORNA_PROGETTO_PRIMA_DI_LAVORARE.bat`, `../02_SALVA_PROGETTO_SU_GITHUB.bat`, `../00_NUOVO_PC_LEGGIMI.txt` | Parent `codex/` scripts for opening, pulling, pushing, and cloning PERLA1 across PCs. |


## Repository Sync

PERLA1 is now intended to be worked from the synchronized GitHub repository layout:

```text
codex/
  00_APRI_PERLA1.bat
  01_AGGIORNA_PROGETTO_PRIMA_DI_LAVORARE.bat
  02_SALVA_PROGETTO_SU_GITHUB.bat
  00_NUOVO_PC_LEGGIMI.txt
  PERLA1/
    AGENTS.md
    PERLA1_PROJECT_MAP.md
    PERLA1_BLOCK_MAP.md
    PERLA1_CONTEXT_BUDGET.md
    PERLA1_SYMBOL_INDEX.md
    PERLA1_TASK_INTAKE_PROTOCOL.md
    PERLA1_RUNTIME_TEST_RUNBOOK.md
    VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1
    .codex/ORCHESTRATION.md
    AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat
    01_GIOCO_PRONTO_LOCAL_TEST/
```

Operational rules:

- `PERLA1/` inside the GitHub repository is the active source of truth.
- Older standalone folders under `Documents/` are historical copies unless explicitly requested for comparison.
- The sync scripts are parent-level and path-relative, so they survive different usernames or clone locations on another PC.
- Normal user flow: run `01_AGGIORNA_PROGETTO_PRIMA_DI_LAVORARE.bat` before work, `00_APRI_PERLA1.bat` to launch, and `02_SALVA_PROGETTO_SU_GITHUB.bat` after work.
- On Windows, do not assume `git` exists in PATH. The sync scripts first try `where git`, then use GitHub Desktop's bundled Git under `%LOCALAPPDATA%\GitHubDesktop\app-*\resources\app\git\cmd\git.exe`.
- The robust fallback uses PowerShell to enumerate `app-*`; a plain `dir /b /s` quoted wildcard fallback caused false "Git not found" failures.
- If this map, AGENTS rules, runtime, launcher, assets, reports, or Codex agents change meaningfully, the GitHub copy should be committed and pushed.

## Context And Symbol Budget

PERLA1 is monolithic enough that agents must avoid copying broad file dumps into the main context. The project policy is:

- `PERLA1_CONTEXT_BUDGET.md` controls reporting volume, not repository inspection depth.
- Agents may read deeper into `index.html` when there is a concrete hypothesis, cross-block dependency, unclear contract, or Team Leader request.
- `PERLA1_SYMBOL_INDEX.md` is the first orientation layer for current high-value symbols, but current code verified by `rg` remains the proof before patching.
- `PERLA1_TASK_INTAKE_PROTOCOL.md` must be used before meaningful edits, runtime validation, multi-agent work, or refactor planning. It forces `CALL`/`CONSIDER`/`SKIP` selection for all relevant project agents.
- Handoffs should report files read, block ids, symbols, line hints, read scope, evidence, unknowns, and validation needed.
- Use `workflow-guard` when repeated searches, tool failures, or context pressure start creating a loop.

## Runtime Architecture

| Subsystem | Key Symbols | Location Hint | Role |
| --- | --- | --- | --- |
| Build metadata | `PERLA_BUILD_ID` | around line `195` | Public build id; verify in browser after edits. |
| Asset loading | `ASSET_BASE`, `ASSET_MANIFEST`, `loadAssets`, `getTex` | around lines `5865-5910` | Loads grouped texture frames from `assets/raycast/`. |
| Main loop | `gameLoop` | around line `26179` | Updates environment/player, calls `drawWorld`, minimap, perf stats. |
| World renderer | `drawWorld` | around line `25225` | Main frame renderer: backdrop, floor/ceiling, wallcasting, roof, canopy, sprites, rain. |
| Floor/ceiling pass | floor loop inside `drawWorld` | start of `drawWorld` | Floor rows, ceiling rows, ceiling depth buffer, real ceiling clone. |
| Wallcasting | wall loop inside `drawWorld` | after floor/ceiling pass | Raycasts walls, fills `ZBuffer`, `WallTopBuffer`, `WallBottomBuffer`, `WallOwnerBuffer`. |
| Roof layer | `drawRoofLayer2_5D` | around line `12090` | Orchestrates sloped roof planes, gable caps, V274 edge, V275 handoff flush, V272 off pass, tower fascia. |
| Roof planes | `drawSlopedRoofLayer2_5D` | around line `11905` | Sloped sector roof casting with budgets/watchdogs. |
| Roof gables | `drawSlopedRoofGableCaps2_5D` | around line `11831` | Vertical roof cap rendering. |
| Geometric eave edge | `perlaRealRoofGeometricEaveEdgePassV274` | around line `2633` | Primary visible external eave/border path for modern reception/bath roofs. |
| Real eave handoff | `perlaRealEaveHandoffQueueFallbackV275`, `perlaRealEaveHandoffFlushV275` | around lines `2409` and `2490` | V275 fallback that fills only columns not covered by V274 when V273 external clone visual is bypassed. |
| Sprites | `getSpriteRenderCandidates`, sprite loop in `drawWorld` | around lines `608`, after roof/canopy | Candidate selection, shadows, stripe rendering, occlusion. |
| Rain/weather | `drawWorldRainParticlesV222`, weather V246-V257 symbols | around line `23746` | World rain and later stabilizers. |
| Minimap | `drawMiniMap` | around line `25500` | Desktop or frame-skipped mobile minimap. |
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
| V274 | primary visible eave contract | Real roof geometric eave edge. Visible external roof border comes from projected `roofSegments`, not floorcasting/clone samples. |
| V275 | active handoff safety | Keeps V274 as primary, but queues a thin depth-aware fallback for uncovered external clone columns after roof rendering. Prevents the V273-bypassed/V274-empty visual gap. |

## V275 Roof Edge Contract

Current expected behavior for modern reception/bath roof/eave work:

- Primary visible external border/eave is drawn by `perlaRealRoofGeometricEaveEdgePassV274`.
- V275 may add a thin fallback with `perlaRealEaveHandoffFlushV275` only for screen columns not already covered by V274.
- Geometry source is `roofSegments`, filtered to modern owner `1` and `2`.
- V274 runs from `drawRoofLayer2_5D` after sloped roof planes and gable caps.
- V275 queues during floor/ceiling clone handling and flushes after `drawRoofLayer2_5D`, so wall/ceiling/roof depth buffers are known.
- V273 external clone remains useful for continuity/depth anchoring, but V273 strip visual stays bypassed when V274/V275 own the visible edge.
- V272 remains runtime-off.
- V265 edge rail is not the primary eave replacement.

Expected counters in affected V275 roof views:

- `realCeilingCloneEaveStripQueuedV273 === 0`
- `realCeilingCloneEaveStripDrawnV273 === 0`
- `realCeilingCloneEaveStripPixelsV273 === 0`
- `realRoofGeometricEavePixelsV274 > 0` or `realEaveHandoffPixelsV275 > 0` when a modern eave is visible
- `realEaveHandoffPixelBudgetHitV275 !== true`
- `realRoofUndersideEaveEnabledV272 === false`
- `realCeilingCloneExternalVisualHandledV274 > 0` when external clone cells are present

## Known Critical Failure Modes

| Failure | Root Cause | Avoidance |
| --- | --- | --- |
| Dotted/broken external roof border | Using floorcasting/ceiling-clone samples as visible border in grazing views. | Use projected `roofSegments` geometry for visible eaves. |
| External edge vanishes after clone suppression | V273 strip visual is bypassed, but V274 draws zero or only partial columns from that angle. | Keep V274 primary and use V275 column-level handoff for uncovered external clone columns. |
| Huge red roof slabs | Re-enabling or approximating full underside/near geometry without tight visibility/budget. | Keep V272 off unless explicitly measured and redesigned. |
| Edge disappears behind same building wall | Too strict same-owner wall/roof occlusion or screen-space strip drawn before wallcasting. | Draw real roof edge in roof layer and allow same-owner top joint carefully. |
| Draw count rises for no visible gain | Queuing/deduping/bridging many screen-space strips. | Prefer small geometry-derived passes and verify counters. |
| Testing stale or wrong build | Opening `file://` or cached page. | Use server URL with cache-busting query and verify `PERLA_BUILD_ID`. |
| Editing historical snapshot | Modifying extracted scripts in `report/`. | Patch only active runtime unless explicitly instructed. |

## Standard Validation

For rendered runtime changes:

1. Parse inline JS from `01_GIOCO_PRONTO_LOCAL_TEST/index.html`.
2. Start `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`, or explicitly confirm an existing PERLA1 launcher-started server is already responding on `http://127.0.0.1:8000/`.
3. Prefer `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` for automated screenshot/counter validation on this Windows setup.
4. Load `http://127.0.0.1:8000/` with a cache-busting query, for example `http://127.0.0.1:8000/?v=<build>_<timestamp>`.
5. Confirm page title and `window.PERLA_BUILD_ID`.
6. Check console/page errors.
7. Use `window.__PERLA_DEBUG__.setPlayerForDebug(...)` for deterministic poses.
8. Capture `#screen` screenshots.
9. Inspect screenshots visually for the exact regression class.
10. Read `window.__PERLA_DEBUG__.perlaLastDrawStats()` and relevant public summaries.

Preferred roof/eave QA poses:

| Scenario | Debug Pose |
| --- | --- |
| Critical reception west/south edge, east view | `setPlayerForDebug(64.99, 8.44, 1, 0)` |
| Critical reception diagonal north-east | `setPlayerForDebug(64.99, 8.44, .7071, -.7071)` |
| Critical reception diagonal south-east | `setPlayerForDebug(64.99, 8.44, .7071, .7071)` |
| Reception outside south overhang | `setPlayerForDebug(64.99, 9.60, 1, 0)` |
| Bath owner 2 south side | `setPlayerForDebug(99, 71, 0, -1)` |
| Bath owner 2 east side | `setPlayerForDebug(106.5, 65, -1, 0)` |
| Bath owner 2 west side | `setPlayerForDebug(88, 65, 1, 0)` |

## Local Tooling And Dependencies

There is no package build step for the game runtime. It is served as static files.

Known useful local tools:

- PowerShell for launcher/server and file inspection.
- `rg` for source search.
- `PERLA1_SYMBOL_INDEX.md` for initial symbol orientation before targeted `rg` verification.
- `PERLA1_CONTEXT_BUDGET.md` for monolithic-code context discipline.
- `PERLA1_TASK_INTAKE_PROTOCOL.md` for mandatory agent selection before meaningful work.
- Bundled Node.js from Codex workspace dependencies for JS parse checks and Playwright/Chrome validation.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 ...` for the known reliable runtime screenshot method.
- System Chrome/Edge headless through Playwright. The bundled Playwright browser may be missing, so use installed Chrome/Edge.

Project-scoped Codex agents:

| Agent | Sandbox | Purpose |
| --- | --- | --- |
| `code-mapper` | `read-only` | Maps real project structure, runtime flow, entry points, symbols, and unknowns before planning work. |
| `regression-auditor` | `read-only` | Audits concrete behavioral regressions and anti-regression invariants, especially roof/ceiling/rain/sprite/render-order risks. |
| `performance-auditor` | `read-only` | Audits draw/fps/cache/hotspot counters and expected measurements without editing code. |
| `workflow-guard` | `read-only` | Circuit breaker for rule/method conflicts, repeated failure loops, known tool failures, unsafe workflow drift; reports `PROCEED` or `STOP`. |
| `workflow-consistency-auditor` | `read-only` | Audits workflow docs, TOML agents, gate membership, hierarchy, permissions, source-of-truth, and structural rule holes. |
| `task-watchdog` | `read-only` | Governs long tasks, checkpoint ids, progressive failures, restart decisions, failure briefs, and `STOP_FOR_USER` conditions. |
| `skeptic-auditor` | `read-only` | Challenges current plan, identifies weak assumptions, compares evidence, and proposes grounded plan B/C alternatives. |
| `refactor-surgeon` | `workspace-write` | Emergency refactor agent for documented blockage. Plan-only by default; applies only approved minimum sufficient reversible scope. |
| `renderer-block-auditor` | `read-only` | Audits `drawWorld` render order, depth buffers, and cross-block renderer risks. |
| `visual-qa-auditor` | `read-only` | Defines and inspects screenshot-based validation, deterministic poses, build id, console health, and counters. |
| `asset-integrity-auditor` | `read-only` | Checks asset manifest entries, file presence, relative paths, and stale cache risks. |
| `launcher-sync-auditor` | `read-only` | Checks launcher/server/sync scripts for correct route, labels, and path-relative portability. |
| `safe-fixer` | `workspace-write` | Performs narrow approved runtime patches after diagnosis is clear. Write scope must be explicit. |
| `map-maintainer` | `workspace-write` | Updates `PERLA1_PROJECT_MAP.md`, `PERLA1_BLOCK_MAP.md`, `PERLA1_CONTEXT_BUDGET.md`, `PERLA1_SYMBOL_INDEX.md`, and `PERLA1_TASK_INTAKE_PROTOCOL.md` only when factual maintenance is needed. |

Configured subagent limits: `max_threads = 4`, `max_depth = 1`, `job_max_runtime_seconds = 2400`.

Multi-agent orchestration notes:

- Read `.codex/ORCHESTRATION.md` before using multiple agents on PERLA1.
- Use `PERLA1_BLOCK_MAP.md` to name impacted blocks before touching the monolithic runtime.
- Use `PERLA1_CONTEXT_BUDGET.md` and `PERLA1_SYMBOL_INDEX.md` so subagents can inspect enough real code while returning compact, decision-grade evidence.
- Use `PERLA1_TASK_INTAKE_PROTOCOL.md` to force relevant agent selection. `workflow-consistency-auditor` is always `CALL` for explicit gates; `workflow-guard`, `task-watchdog`, `skeptic-auditor`, and `refactor-surgeon` are always at least considered.
- Use a full `workflow-consistency-auditor` audit after workflow-policy `.md`/TOML/agent changes and before sync when those policy files changed meaningfully.
- Extra temporary agents are read-only by default and must have a concrete bounded task.
- A write agent cannot validate its own patch as complete; validation must be reviewed separately.
- Use `workflow-guard` as a circuit breaker when the same method fails twice, when a known deterministic tool failure appears, or when the next step would not produce new evidence.
- Use `task-watchdog` for long-running work. It tracks `task_id`, `operation_id`, and `logical_step_id`; three progressive failures on one logical step force a checkpoint, and a second long failure on the same operation/logical step requires user approval.
- Failure briefs should be assigned to the most relevant read-only specialist and must produce a best checkpoint plus two or three real continuation plans.
- Use `refactor-surgeon` only after documented blockage. It must first produce `REFACTOR_PLAN_ONLY`; `APPLY_APPROVED_REFACTOR` requires explicit approved scope. It may propose controlled derogations, but strong/ambiguous conflicts require user approval.

Browser validation notes:

- Browser validation requires the PERLA1 local server first. The normal startup entry point is `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`.
- On this Windows setup, the proven method is `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1`: Playwright packages from Codex runtime plus installed system Chrome/Edge.
- Treat the in-app Browser as secondary unless the user specifically asks for it or the headless method stops working.
- If Browser fails due sandbox/Windows permission issues, use the runbook method and keep the target URL identical.
- Known Browser tooling failure: `CreateProcessAsUserW failed: 5`. Treat it as a Codex Browser/Windows sandbox launch failure, not as evidence that the PERLA1 runtime failed.
- If the runbook/headless validation fails, hand off manual validation with exact URL, expected build id, debug poses, screenshot targets, console checks, and counters/API calls.
- Do not claim full rendered validation unless screenshots and relevant counters were actually inspected.
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
- repository sync workflow or parent scripts change,
- block ownership or orchestration rules change,
- context-budget or symbol-index rules change,
- task-intake protocol changes,
- long-task watchdog/checkpoint policy changes,
- emergency refactor policy changes,
- a new recurring failure mode is discovered.

Do not update this file for tiny cosmetic edits that do not change structure, contracts, validation, or known risks.


