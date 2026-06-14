# PERLA1 Project Map

Last updated: 2026-06-14
Current runtime build observed in `index.html`: `PERLA1_V278_MODERN_INTEGRATED_ROOF_CAP_SAFE_LOCAL`

This file is the fast technical map for agents. Use it to orient before touching runtime code, and update it when structure, entrypoints, validation workflow, dependencies, or major renderer contracts change.

## Entry Points

| Purpose | Path / Symbol | Notes |
| --- | --- | --- |
| Playable runtime | `01_GIOCO_PRONTO_LOCAL_TEST/index.html` | Single-file HTML/CSS/JS game runtime. This is the active source of truth. |
| User launcher | `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat` | Correct user-facing launch path. Calls the PowerShell server. |
| Local server | `AVVIA_GIOCO_SERVER_POWERSHELL.ps1` | Serves `01_GIOCO_PRONTO_LOCAL_TEST/` on `http://127.0.0.1:8000/`. V278 launcher tries to bind first, then performs bounded old-server cleanup only if the port is actually occupied. |
| Codex headless server | `AVVIA_GIOCO_CODEX_HEADLESS.ps1` | Deterministic agent validation server. Internal `-Serve` mode does not open a browser, writes log/PID/ready files, and is used by `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher`. |
| Assets | `01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/` | PNG sprite/wall/sky assets loaded through `ASSET_MANIFEST`. |
| Reports/history | `report/` | Diagnostics, extracted inline scripts, smoke tests, historical reports. Not runtime source. |
| Current failure report | `PERLA1_REPORT_FALLIMENTI_OTTIMIZZAZIONE_TETTO_V271_2026-06-13.txt` | Root-level failure analysis report from the roof optimization work. |
| Block map | `PERLA1_BLOCK_MAP.md` | Functional block ownership map for the monolithic runtime and cross-block risks. |
| Context budget | `PERLA1_CONTEXT_BUDGET.md` | Rules for inspecting the monolithic runtime without flooding the Team Leader context. Limits handoff volume, not useful code inspection. |
| Symbol index | `PERLA1_SYMBOL_INDEX.md` | Current high-value symbol orientation map. Verify with `rg` before patching. |
| Task intake protocol | `PERLA1_TASK_INTAKE_PROTOCOL.md` | Required startup gate for selecting `CALL`/`CONSIDER`/`SKIP` agents and forcing guard/consistency/watchdog/skeptic/refactor consideration. |
| Runtime test runbook | `PERLA1_RUNTIME_TEST_RUNBOOK.md`, `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` | Practical Windows validation path: Codex headless startup with `-StartLauncher`, then screenshot through system Chrome/Edge. |
| Static structure analyzer | `tools/perla_runtime_analyzer.mjs` | Extracts inline JS, parse-checks it, maps functions/globals, classifies blocks, and emits a conservative dependency graph without external npm installs. |
| Local structural CI | `tools/perla_local_ci.ps1`, `tests/perla_regression_suite.json` | Runs parser/structure/regression-symbol checks and can optionally run runtime screenshot smoke poses. |
| Modularization plan | `PERLA1_MODULARIZATION_PLAN.md`, `01_GIOCO_PRONTO_LOCAL_TEST/src/module-boundaries.json`, `01_GIOCO_PRONTO_LOCAL_TEST/src/README.md` | Controlled exit plan from the monolith. The runtime source of truth remains `index.html`; `src/` is scaffold-only until a scoped extraction is validated. |
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
    AVVIA_GIOCO_CODEX_HEADLESS.ps1
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
- `tools/perla_runtime_analyzer.mjs` is the recurring static structure layer for function maps, global counts, block classification, and focused dependency graphs. It complements `rg`; it does not replace targeted code reads before patching.
- `PERLA1_TASK_INTAKE_PROTOCOL.md` must be used before meaningful edits, runtime validation, multi-agent work, or refactor planning. It forces `CALL`/`CONSIDER`/`SKIP` selection for all relevant project agents.
- Handoffs should report files read, block ids, symbols, line hints, read scope, evidence, unknowns, and validation needed.
- Use `workflow-guard` when repeated searches, tool failures, context pressure, silent waits, or missing heartbeat checkpoints start creating a loop.

## Runtime Architecture

| Subsystem | Key Symbols | Location Hint | Role |
| --- | --- | --- | --- |
| Build metadata | `PERLA_BUILD_ID` | around line `195` | Public build id; verify in browser after edits. |
| Asset loading | `ASSET_BASE`, `ASSET_MANIFEST`, `loadAssets`, `getTex` | around lines `5865-5910` | Loads grouped texture frames from `assets/raycast/`. |
| Main loop | `gameLoop` | around line `26179` | Updates environment/player, calls `drawWorld`, minimap, perf stats. |
| World renderer | `drawWorld` | around line `25225` | Main frame renderer: backdrop, floor/ceiling, wallcasting, roof, canopy, sprites, rain. |
| Floor/ceiling pass | floor loop inside `drawWorld` | start of `drawWorld` | Floor rows, ceiling rows, ceiling depth buffer, real ceiling clone. |
| Wallcasting | wall loop inside `drawWorld` | after floor/ceiling pass | Raycasts walls, fills `ZBuffer`, `WallTopBuffer`, `WallBottomBuffer`, `WallOwnerBuffer`. |
| Roof layer | `drawRoofLayer2_5D` | around line `12457` | Orchestrates sloped roof planes/gable caps. V278 keeps failed V266-V275 visual replacement paths runtime-off and adds a modern wall-anchored integrated roof cap for owner 1/2 when visible support columns exist. |
| Roof planes | `drawSlopedRoofLayer2_5D` | around line `12266` | Sloped sector roof casting with budgets/watchdogs. V278 conditionally skips modern owner 1/2 sloped/gable visuals only when the integrated support-column cap is active for that owner. |
| Roof gables | `drawSlopedRoofGableCaps2_5D` | around line `11831` | Vertical roof cap rendering. |
| Geometric eave edge | `perlaRealRoofGeometricEaveEdgePassV274` | around line `2633` | Retained for diagnostics but runtime-off in V276 after visual failure. |
| Real eave handoff | `perlaRealEaveHandoffQueueFallbackV275`, `perlaRealEaveHandoffFlushV275` | around lines `2409` and `2490` | Retained for diagnostics but runtime-off in V276 after visual failure. |
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
| V265 | active fallback authority through V278 | Last user-verified good roof reference from `PERLA1_V265_COVERAGE_ULTRA_BUDGET_EDGE_RAIL_SAFE_LOCAL.zip`: sloped roof fill, V264 watchdog, and V265 edge rail/ultra budget. |
| V266/V267 | runtime off in V276-V278 | Roof silhouette/mask/wall-clip path. V267 skipped original fill and contributed to broken replacement stack. |
| V270 | runtime off in V276-V278 | External real ceiling clone eave path. Internal ceiling rendering remains in `drawModernCoverCeilingSegment`. |
| V271 | runtime off in V276-V278 | Side-aware external clone continuity. Disabled with V270 in V276 rollback. |
| V272 | runtime off rollback | Real roof underside/eave near geometry pass. Produced slab/cost risk; do not turn on casually. |
| V273 | runtime off in V276-V278 | External ceiling clone eave anchor/strip path. Disabled after strip/clone handoff failures. |
| V274 | runtime off in V276-V278 | Geometric eave edge path. Retained for diagnostics, no longer primary after user-visible failure. |
| V275 | runtime off in V276-V278 | Real eave handoff fallback. Retained for diagnostics, no longer active after user-visible failure. |
| V276 | active base contract | Rollback visual authority to V265 while preserving internal ceiling, rain cover, tower roof, and diagnostics. |
| V277 | active support | Local budgeted continuity fill inside the V265/V276 sloped roof path, plus sparse-run guard for the V265 edge rail. It remains available but is not the final authority for modern wall-visible roof views. |
| V278 | current contract | Modern owner 1/2 wall-anchored integrated roof cap inspired by the tower V136 principle. It uses `ModernSupport*BufferV236` columns, conditionally replaces old sloped/gable visuals only when same-owner support columns are visible, and falls back to the V265/V277 roof path when no support exists. |

## V278 Modern Integrated Roof Cap Contract

Current expected behavior for modern reception/bath roof/eave work:

- `PERLA_BUILD_ID` is `PERLA1_V278_MODERN_INTEGRATED_ROOF_CAP_SAFE_LOCAL`.
- V278 adds `drawModernIntegratedRoofCapV278` as the primary modern exterior roof authority when owner `1`/`2` wall support columns are visible in `ModernSupport*BufferV236`.
- In those support-visible views, V278 conditionally skips the old modern sloped roof/gable visuals for that owner to prevent the V265/V277 sampled roof from reintroducing dotted fragments over the integrated cap.
- When no same-owner modern support columns are visible, V278 does not replace the old roof segment path; this preserves distant/unsupported roof visibility instead of making the roof disappear.
- V277 continuity fill and V265 edge rail remain support/diagnostic paths, but V278 is the current authority for wall-anchored modern exterior roof views.
- V267 must not skip the original/sloped roof fill in normal runtime.
- V266 silhouette, V270/V271 external ceiling clone, V273 external strip/anchor, V274 geometric eave edge, and V275 handoff are runtime-off.
- Internal ceiling/soffit stays in `drawModernCoverCeilingSegment`; do not delete or disable it as part of roof visual rollback.
- Tower roof remains separate and must not be changed to solve reception/bath roof regressions.

Expected counters in affected V278 roof views:

- `roofV276 === true`
- `roofV277 === true`
- `roofV278 === true`
- `v277RoofContinuityFillLocalSafe === true`
- `v278ModernIntegratedRoofCapSafe === true`
- `v278RoofVisualAuthority === "wall_anchored_integrated_cap"`
- `v278UsesModernSupportBuffersV236 === true`
- `modernIntegratedRoofCapPixelsV278 > 0` in wall-support-visible modern roof poses
- `modernIntegratedRoofCapBudgetHitV278 === false`
- `modernIntegratedRoofCapPixelsV278 <= 5000`
- `modernIntegratedRoofCapFillRectsV278 <= 1400`
- `modernIntegratedRoofSkippedSlopedSegmentsV278 > 0` only when same-owner modern support columns are visible
- `roofV266 === false`, `roofV267 === false`, `roofV273 === false`, `roofV274 === false`, `roofV275 === false`
- `roofSilhouetteMainOriginalRoofFillSkippedV267` absent/zero
- `realRoofGeometricEavePixelsV274` absent/zero
- `realEaveHandoffPixelsV275` absent/zero
- `realRoofUndersideEaveEnabledV272 === false`

## Known Critical Failure Modes

| Failure | Root Cause | Avoidance |
| --- | --- | --- |
| Dotted/broken external roof border | Using floorcasting/ceiling-clone samples as visible border in grazing views. | Use projected `roofSegments` geometry for visible eaves. |
| External edge vanishes after clone suppression | V273 strip visual is bypassed, but V274/V275 draws zero or only partial columns from that angle. | In V276 do not use the clone/geometric/handoff stack as runtime authority; keep V265 visual path active. |
| Huge red roof slabs | Re-enabling or approximating full underside/near geometry without tight visibility/budget. | Keep V272 off unless explicitly measured and redesigned. |
| Edge disappears behind same building wall | Too strict same-owner wall/roof occlusion or screen-space strip drawn before wallcasting. | Do not reintroduce screen-space strips as primary; validate sloped roof sampling and wall buffers together. |
| Draw count rises for no visible gain | Queuing/deduping/bridging many screen-space strips. | Prefer small geometry-derived passes and verify counters. |
| Testing stale or wrong build | Opening `file://` or cached page. | Use server URL with cache-busting query and verify `PERLA_BUILD_ID`. |
| Editing historical snapshot | Modifying extracted scripts in `report/`. | Patch only active runtime unless explicitly instructed. |

## Standard Validation

For rendered runtime changes:

1. Run the local static checks: `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\tools\perla_local_ci.ps1`.
2. Parse inline JS from `01_GIOCO_PRONTO_LOCAL_TEST/index.html`. The local CI wrapper does this through `tools/perla_runtime_analyzer.mjs`.
3. For Codex/agent validation, run `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher`, which starts `AVVIA_GIOCO_CODEX_HEADLESS.ps1 -Serve` when no server is responding. For manual play, use `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`.
4. Prefer `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher` for automated screenshot/counter validation on this Windows setup.
5. Load `http://127.0.0.1:8000/` with a cache-busting query, for example `http://127.0.0.1:8000/?v=<build>_<timestamp>`.
6. Confirm page title and `window.PERLA_BUILD_ID`.
7. Check console/page errors.
8. Use `window.__PERLA_DEBUG__.setPlayerForDebug(...)` for deterministic poses.
9. Capture `#screen` screenshots.
10. Inspect screenshots visually for the exact regression class.
11. Read `window.__PERLA_DEBUG__.perlaLastDrawStats()` and relevant public summaries.

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
- `AVVIA_GIOCO_CODEX_HEADLESS.ps1` for deterministic Codex server startup without opening a browser.
- Bundled Node.js from Codex workspace dependencies for JS parse checks and Playwright/Chrome validation.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher ...` for the known reliable runtime screenshot method.
- System Chrome/Edge headless through Playwright. The bundled Playwright browser may be missing, so use installed Chrome/Edge.
- `tools/perla_runtime_analyzer.mjs` for recurring static structure analysis and dependency graph generation.
- `tools/perla_local_ci.ps1` for local static CI, with `-RuntimeScreenshots` when screenshot smoke validation is needed.
- `tools/perla_codex_workflow_check.ps1` for deterministic workflow-policy checks with JSON output, used by CI-style runs and root Codex hooks.
- `tests/perla_regression_suite.json` for required build/symbol/function checks and standard smoke poses.
- `PERLA1_MODULARIZATION_PLAN.md`, `01_GIOCO_PRONTO_LOCAL_TEST/src/module-boundaries.json`, and `01_GIOCO_PRONTO_LOCAL_TEST/src/README.md` for controlled modularization planning. `src/` is not active runtime code yet.

Project-scoped Codex agents:

| Agent | Sandbox | Purpose |
| --- | --- | --- |
| `code-mapper` | `read-only` | Maps real project structure, runtime flow, entry points, symbols, and unknowns before planning work. |
| `regression-auditor` | `read-only` | Audits concrete behavioral regressions and anti-regression invariants, especially roof/ceiling/rain/sprite/render-order risks. |
| `performance-auditor` | `read-only` | Audits draw/fps/cache/hotspot counters and expected measurements without editing code. |
| `workflow-guard` | `read-only` | Circuit breaker for rule/method conflicts, repeated failure loops, known tool failures, unsafe workflow drift; reports `PROCEED` or `STOP`. |
| `workflow-consistency-auditor` | `read-only` | Audits workflow docs, TOML agents, gate membership, hierarchy, permissions, source-of-truth, and structural rule holes. |
| `plan-integrity-auditor` | `read-only` | Audits implementation plans before execution for objective fit, scope, dependencies, validation, success/stop/fallback criteria, and workflow coherence. |
| `task-watchdog` | `read-only` | Governs long tasks, checkpoint ids, progressive failures, restart decisions, failure briefs, and `STOP_FOR_USER` conditions. |
| `skeptic-auditor` | `read-only` | Challenges current plan, identifies weak assumptions, compares evidence, and proposes grounded plan B/C alternatives. |
| `refactor-surgeon` | `workspace-write` | Emergency refactor agent for documented blockage. Plan-only by default; applies only approved minimum sufficient reversible scope. |
| `renderer-block-auditor` | `read-only` | Audits `drawWorld` render order, depth buffers, and cross-block renderer risks. |
| `visual-qa-auditor` | `read-only` | Defines and inspects screenshot-based validation, deterministic poses, build id, console health, and counters. |
| `asset-integrity-auditor` | `read-only` | Checks asset manifest entries, file presence, relative paths, and stale cache risks. |
| `launcher-sync-auditor` | `read-only` | Checks launcher/server/sync scripts for correct route, labels, and path-relative portability. |
| `safe-fixer` | `workspace-write` | Performs narrow approved runtime patches after diagnosis is clear. Write scope must be explicit. |
| `map-maintainer` | `workspace-write` | Updates `PERLA1_PROJECT_MAP.md`, `PERLA1_BLOCK_MAP.md`, `PERLA1_CONTEXT_BUDGET.md`, `PERLA1_SYMBOL_INDEX.md`, and `PERLA1_TASK_INTAKE_PROTOCOL.md` only when factual maintenance is needed. |

Configured subagent limits: `max_threads = 12`, `max_depth = 1`, `job_max_runtime_seconds = 1500`.

Multi-agent orchestration notes:

- Read `.codex/ORCHESTRATION.md` before using multiple agents on PERLA1.
- Use `PERLA1_BLOCK_MAP.md` to name impacted blocks before touching the monolithic runtime.
- Use `PERLA1_CONTEXT_BUDGET.md` and `PERLA1_SYMBOL_INDEX.md` so subagents can inspect enough real code while returning compact, decision-grade evidence.
- Use `PERLA1_TASK_INTAKE_PROTOCOL.md` to force relevant agent selection. `workflow-consistency-auditor` is always `CALL` for explicit gates; `workflow-guard`, `plan-integrity-auditor`, `task-watchdog`, `skeptic-auditor`, and `refactor-surgeon` are always at least considered.
- If Codex exposes only generic `explorer`/`worker` tools, use the Agent Tool Adapter rule: a generic subagent satisfies a named `CALL` agent only when assigned that exact role, pointed to the matching TOML/source docs, given matching read/write scope, and recorded in `agent_tool_mapping`.
- TOML `name` and `description` define PERLA1 role identity and instructions, not guaranteed Codex UI display name, generated nickname, icon, or direct callability.
- Root `.codex/hooks.json` runs `tools/perla_codex_workflow_check.ps1` on `Stop`, `SubagentStart`, and `SubagentStop` after Codex hook trust review. Hooks enforce lifecycle checks; they do not make subagents persistent background daemons.
- `tools/perla_codex_workflow_check.ps1` emits schema `perla.workflow.check.v1` with `-Json` or `-Jsonl`. P0/P1 failures are blocking and return exit code `1`.
- For Codex scripting or CI review, pair the deterministic workflow check with `codex exec --json` only when a model audit is needed and JSONL events should be captured.
- Use `hook_trust_check` before relying on hooks as enforcement evidence. If trust is unknown, hooks are configured but not proven active; use manual workflow checker output plus required guard/audit evidence.
- Keep `checker_semantic_limit` explicit: deterministic checks catch mechanically inspectable drift, not rendered behavior, full plan semantics, user intent, or agent reasoning quality.
- Use a full `workflow-consistency-auditor` audit after workflow-policy `.md`/TOML/agent changes and before sync when those policy files changed meaningfully.
- Extra temporary agents are read-only by default and must have a concrete bounded task.
- A write agent cannot validate its own patch as complete; validation must be reviewed separately.
- Use `workflow-guard` as a circuit breaker when the same method fails twice, when a known deterministic tool failure appears, or when the next step would not produce new evidence.
- Use workflow heartbeat checkpoints per operation/logical step: 12 minutes without evidence for simple comparisons/small audits, 21 minutes for complex runtime/workflow/subagent/browser work. These are not whole-task limits. At checkpoint, call `task-watchdog`; call `workflow-guard` too if the next action repeats a method, waits on an unknown state, or cannot produce new evidence.
- Whole-task wall-clock safety cap: one `task_id` may run for at most 5h unless the user grants a new budget. At 4h30m call `task-watchdog` to prepare handoff; at 5h stop at the last completed checkpoint with `STOP_FOR_USER`.
- Before retry after timeout or deterministic tool failure, record checkpoint evidence: task/operation/logical ids, elapsed time, method tried, evidence gained, next proof target, retry count, allowed next action, and forbidden next action.
- Broad `rg`, diff, or search output from the monolith must be narrowed to target symbols/functions/blocks before it is treated as evidence.
- Use the Complex Task Accelerator Protocol for complex, high-risk, delicate, multi-agent, runtime, workflow, refactor, failed-patch recovery, or long work. Required planning fields are `accelerator_brief`, `cheapest_discriminating_test`, `critical_path`, `sidecar_tasks`, `serial_constraints`, `validation_ladder`, `checkpoint_ledger`, and `subagent_task_packet`. This protocol reduces wasted waits and searches; it does not weaken required `CALL` agents, validation, heartbeat, write-scope, or approval rules.
- Use the Sidecar Result Integration Protocol when parallel agent/tool evidence returns: record `sidecar_result_integration`, `result_status`, `affects_critical_path`, `dependency_on_critical_path`, `accepted_into_plan`, `integration_decision`, `validation_impact`, `write_scope_impact`, `approval_impact`, `heartbeat_checkpoint`, `stop_condition_triggered`, `discard_or_defer_reason`, and `ledger_update`. Sidecar results are evidence inputs, not approvals, and cannot block `critical_path` without an explicit dependency.
- Use the User Intake Relay Protocol when user messages arrive during active/long/delicate work: record `user_message_intake`, `message_class`, `must_interrupt`, `must_report_to_team_leader`, `checkpoint_required`, `user_intent_summary`, `conflicts_current_plan`, `changes_scope`, `changes_validation`, `changes_write_scope`, `approval_impact`, `agent_gate_impact`, `agent_tool_mapping_impact`, `critical_path_impact`, `sidecar_integration_impact`, `decision`, `ledger_update`, `relay_note`, `next_action`, `forbidden_next_action`, and `response_due`. User-intake relay is not persistent background monitoring and cannot grant approval or bypass the Team Leader.
- Track `subagent_task_lifecycle` for delegated work. Close subagents at Team Leader task completion, or earlier only when the assigned packet is fully integrated, obsolete, stale, aborted, or unsafe; do not close a useful subagent just because one internal step ended.
- Before final delivery, staging, sync, or readiness claims, use `scoped_finalization` and `finalization_gate` to separate approved scope, dirty out-of-scope files, generated/disposable outputs, untracked workflow tooling, validation evidence, subagent lifecycle, selective staging, and residual risk.
- `workflow_tooling_manifest` classifies source tooling such as `tools/perla_codex_workflow_check.ps1`, `tools/perla_local_ci.ps1`, `tools/perla_runtime_analyzer.mjs`, `.codex/`, `tests/perla_regression_suite.json`, and modularization scaffold files separately from disposable reports/logs/screenshots.
- `max_threads` is a concurrency cap only. The Agent Selection Gate decides which agents are necessary; if 7 or more agents are required, use the required agents and batch only when the active tool surface imposes a hard limit. Optional `CONSIDER` work is serialized before required `CALL` work is downgraded.
- Use `task-watchdog` for long-running work. It tracks `task_id`, `operation_id`, and `logical_step_id`; three progressive failures on one logical step force a checkpoint, and a second long failure on the same operation/logical step requires user approval.
- Failure briefs should be assigned to the most relevant read-only specialist and must produce a best checkpoint plus two or three real continuation plans.
- Use `refactor-surgeon` only after documented blockage. It must first produce `REFACTOR_PLAN_ONLY`; `APPLY_APPROVED_REFACTOR` requires explicit approved scope. It may propose controlled derogations, but strong/ambiguous conflicts require user approval.

Browser validation notes:

- Browser validation requires the PERLA1 local server first. For Codex/agents, the normal startup entry point is `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher`, backed by `AVVIA_GIOCO_CODEX_HEADLESS.ps1`. For manual user play, use `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`.
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
- local CI, static analyzer, dependency graph, or modularization staging changes,
- repository sync workflow or parent scripts change,
- block ownership or orchestration rules change,
- context-budget or symbol-index rules change,
- task-intake protocol changes,
- hook trust, checker semantic limit, scoped finalization, workflow tooling manifest, finalization gate, or subagent task lifecycle changes,
- long-task watchdog/checkpoint policy changes,
- emergency refactor policy changes,
- a new recurring failure mode is discovered.

Do not update this file for tiny cosmetic edits that do not change structure, contracts, validation, or known risks.


