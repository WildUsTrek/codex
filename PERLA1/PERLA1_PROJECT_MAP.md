# PERLA1 Project Map

Last updated: 2026-06-15
Current runtime build observed in `index.html`: `PERLA1_V299_ROOF_ALWAYS_BUDGET_SAFE_LOCAL`

This file is the fast technical map for agents. Use it to orient before touching runtime code, and update it when structure, entrypoints, validation workflow, dependencies, or major renderer contracts change.

## Entry Points

| Purpose | Path / Symbol | Notes |
| --- | --- | --- |
| Playable runtime | `01_GIOCO_PRONTO_LOCAL_TEST/index.html` | Single-file HTML/CSS/JS game runtime. This is the active source of truth. |
| User launcher | `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat` | Correct user-facing launch path. Calls the PowerShell server. |
| Local server | `AVVIA_GIOCO_SERVER_POWERSHELL.ps1` | Serves `01_GIOCO_PRONTO_LOCAL_TEST/` on `http://127.0.0.1:8000/`. V278 launcher tries to bind first, then performs bounded old-server cleanup only if the port is actually occupied. |
| Codex headless server | `AVVIA_GIOCO_CODEX_HEADLESS.ps1` | Deterministic agent validation server. Internal `-Serve` mode does not open a browser, writes log/PID/ready files, and is used by `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher`. |
| Legacy raycaster assets | `01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/` | PNG sprite/wall/sky assets loaded through `ASSET_MANIFEST`. |
| Optimized RTP asset package and scenario mapping protocol | `01_GIOCO_PRONTO_LOCAL_TEST/assets/rtp/`, `01_GIOCO_PRONTO_LOCAL_TEST/assets/rtp/manifest/rtp.characters.json`, `01_GIOCO_PRONTO_LOCAL_TEST/assets/rtp/SCENARIO_EVENT_MAPPING_PROTOCOL.md`, `tools/perla_rtp_asset_importer.py` | Optimized WebP package and required future mapping protocol for RTP/personaggi/NPC/animali/eventi/dialoghi/sceneggiatura/gameplay work: 9 main portraits, 198 standard 8-frame sprite animations plus 4 special ambient source assets, 211 WebP files, 5,632,616 bytes. Runtime animation IDs are normalized; left animations are derived by mirror, not stored. Dormant until runtime code explicitly loads the manifest and future placement/event manifests. |
| Scenario/gameplay mapping draft | `report/SCENEGGIATURA_GAMEPLAY_MAPPING_DRAFT_2026-06-14.md` | Preparatory mapping from the supplied sceneggiatura TXT, GDD PDF, and intro storyboard image into atmosphere, entities, placements, schedules, behaviors, dialogue/event roles, battle placeholders, and validation risks. Not runtime source. |
| Reports/history | `report/` | Diagnostics, extracted inline scripts, smoke tests, historical reports. Not runtime source. |
| Current failure report | `PERLA1_REPORT_FALLIMENTI_OTTIMIZZAZIONE_TETTO_V271_2026-06-13.txt` | Root-level failure analysis report from the roof optimization work. |
| Block map | `PERLA1_BLOCK_MAP.md` | Functional block ownership map for the monolithic runtime and cross-block risks. |
| Context budget | `PERLA1_CONTEXT_BUDGET.md` | Rules for inspecting the monolithic runtime without flooding the Team Leader context. Limits handoff volume, not useful code inspection. |
| Symbol index | `PERLA1_SYMBOL_INDEX.md` | Current high-value symbol orientation map. Verify with `rg` before patching. |
| Task intake protocol | `PERLA1_TASK_INTAKE_PROTOCOL.md` | Required startup gate for selecting `CALL`/`CONSIDER`/`SKIP` agents and forcing guard/consistency/watchdog/skeptic/refactor consideration. |
| Runtime test runbook | `PERLA1_RUNTIME_TEST_RUNBOOK.md`, `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` | Practical Windows validation path: Codex headless startup with `-StartLauncher`, automatic fallback ports when `8000` is blocked, then screenshot through system Chrome/Edge. |
| Static structure analyzer | `tools/perla_runtime_analyzer.mjs` | Extracts inline JS, parse-checks it, maps functions/globals, classifies blocks, and emits a conservative dependency graph without external npm installs. |
| Local structural CI | `tools/perla_local_ci.ps1`, `tests/perla_regression_suite.json` | Runs parser/structure/regression-symbol checks and can optionally run runtime screenshot smoke poses. |
| Runtime performance matrix | `tools/perla_runtime_perf_matrix.ps1` | Tooling-only Playwright matrix runner for gameplay-first performance/draw evidence across clear/storm and desktop/mobile touch contexts. It starts or reuses the PERLA1 server safely, verifies `PERLA_BUILD_ID`, uses public debug APIs, writes JSON/Markdown/screenshots outside Git by default, and does not change runtime behavior. |
| Project backup tool | `tools/perla_project_backup.ps1` | Creates timestamped zip backups of the full synchronized repository folder `C:\Users\ASUS\Documents\GitHub\codex`, excluding only `PERLA1\01_GIOCO_PRONTO_LOCAL_TEST\assets\rtp`. User backups go to `C:\Users\ASUS\Documents\GitHub\backup\utente`; automatic task backups go to `C:\Users\ASUS\Documents\GitHub\backup\automatici`. Automatic retention deletes only files older than 2 days and only when `automatici` already contains more than 10 files. |
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
- `project_backup_gate` backup flow: when the user explicitly asks for a safety backup, record `backup_user_requested` and run `tools/perla_project_backup.ps1 -Kind User` before the next protected step. At the end of each meaningful task, record `automatic_task_backup` and run `tools/perla_project_backup.ps1 -Kind Automatic` before final delivery when filesystem permissions allow it. Backups are zip archives outside Git, not staged files.
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
| Asset loading | `ASSET_BASE`, `ASSET_MANIFEST`, `loadAssets`, `getTex` | around lines `5865-5910` | Loads grouped texture frames from `assets/raycast/`. Does not load dormant RTP references yet. |
| Main loop | `gameLoop` | around line `26609` | Updates environment/player, calls `drawWorld`, minimap, perf stats. |
| World renderer | `drawWorld` | around line `25654` | Main frame renderer: backdrop, floor/ceiling, wallcasting, roof, canopy, sprites, rain. |
| Floor/ceiling pass | floor loop inside `drawWorld` | start of `drawWorld` | Floor rows, ceiling rows, ceiling depth buffer, real ceiling clone. |
| Wallcasting | wall loop inside `drawWorld` | after floor/ceiling pass | Raycasts walls, fills `ZBuffer`, `WallTopBuffer`, `WallBottomBuffer`, `WallOwnerBuffer`. |
| Roof layer | `drawRoofLayer2_5D` | around line `12820` | Orchestrates legacy/tower/generic roof passes. V281 filters reception/bath owner 1/2 out of sloped/gable/eave fallback when the primitive preflight accepts the roof. |
| Modern roof primitive | `drawStableModernOwnerRoofPrimitiveV281` | around line `12030` | Single world-space primitive authority for reception/baths. Uses `collectModernRoofFaces`, depth-aware visibility, roof self-depth writes, deterministic budgets, and geometry edge lines. |
| Roof planes | `drawSlopedRoofLayer2_5D` | around line `12620` | Sloped sector roof casting with budgets/watchdogs. Under V281 it is fallback/generic only for owner 1/2 when primitive preflight rejects the roof. |
| Roof gables | `drawSlopedRoofGableCaps2_5D` | around line `12540` | Vertical roof cap rendering. Under V281 it is skipped for eligible reception/bath roofs so it does not hybridize with the primitive authority. |
| Geometric eave edge | `perlaRealRoofGeometricEaveEdgePassV274` | around line `2633` | Retained for diagnostics but runtime-off in V276 after visual failure. |
| Real eave handoff | `perlaRealEaveHandoffQueueFallbackV275`, `perlaRealEaveHandoffFlushV275` | around lines `2409` and `2490` | Retained for diagnostics but runtime-off in V276 after visual failure. |
| Sprites | `getSpriteRenderCandidates`, sprite loop in `drawWorld` | around line `663`, after roof/canopy | Candidate selection, shadows, stripe rendering, occlusion. |
| Rain/weather | `drawWorldRainParticlesV222`, weather V246-V257 symbols | around line `24505` | World rain and later stabilizers. |
| Minimap | `drawMiniMap` | around line `26254` | Desktop or frame-skipped mobile minimap. |
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
| V265 | active fallback outside V281 owner 1/2 authority | Last user-verified good roof reference from `PERLA1_V265_COVERAGE_ULTRA_BUDGET_EDGE_RAIL_SAFE_LOCAL.zip`: sloped roof fill, V264 watchdog, and V265 edge rail/ultra budget. |
| V266/V267 | runtime off in V276-V281 | Roof silhouette/mask/wall-clip path. V267 skipped original fill and contributed to broken replacement stack. |
| V270 | runtime off in V276-V281 | External real ceiling clone eave path. Internal ceiling rendering remains in `drawModernCoverCeilingSegment`. |
| V271 | runtime off in V276-V281 | Side-aware external clone continuity. Disabled with V270 in V276 rollback. |
| V272 | runtime off rollback | Real roof underside/eave near geometry pass. Produced slab/cost risk; do not turn on casually. |
| V273 | runtime off in V276-V281 | External ceiling clone eave anchor/strip path. Disabled after strip/clone handoff failures. |
| V274 | runtime off in V276-V281 | Geometric eave edge path. Retained for diagnostics, no longer primary after user-visible failure. |
| V275 | runtime off in V276-V281 | Real eave handoff fallback. Retained for diagnostics, no longer active after user-visible failure. |
| V276 | active base contract | Rollback visual authority to V265 while preserving internal ceiling, rain cover, tower roof, and diagnostics. |
| V277 | active fallback support | Local budgeted continuity fill inside the V265/V276 sloped roof path, plus sparse-run guard for the V265 edge rail. Under V281 it does not receive owner 1/2 primitive-owned planes. |
| V278 | disabled in normal V281 roof path | Wall-anchored integrated cap remains as historical helper code and explicit skip counter, but `PERLA_V281_DISABLE_V278_CAP_WHEN_ENABLED` prevents the slab-like hybrid overlay. |
| V279/V280 | retained support helpers | Support-span, door-span, and near-door guard helpers remain available; the visual authority moved to V281. |
| V281/V281S/V281T/V281U/V281V/V281W/V281X | current modern roof contract | Reception/bath roof single authority: world-space primitive faces from `roofSegments`, exclusive fallback to V265/V277 only when primitive ownership is not active, no V278 cap overlay. V281S stabilizes owner 1 far/portal gables, V281T adds owner 2 door/opposite gable keeps, V281U promotes owner2 to the same full-surface authority class as reception, V281V suppresses owner2 exterior decorative edge lines, V281W suppresses owner2 exterior fascia/gronda faces, and V281X applies owner2 flush wall join plus V281-local foreground-top rejection for unrelated hedge/wall tops. |
| V282 | dormant/off in current V281 contract | Reception/bath portal/slab experiments retained for diagnostics but runtime-off after visual regressions. Do not claim V282 portal/ceiling readiness from this base. |
| V283 | active contract (open canopy + replay gate) | Local fix for legacy/open canopy owner `0` rendering: `drawDeferredCanopySegmentsV121` clips against V227 foreground wall/hedge ranges so foreground wins, while `ceilingSpriteClipY` preserves sprites that are clearly closer than canopy ceiling depth. V221 open-canopy replay rects are foreground-clipped if a legacy replay path is active, and V222 world-particles modes disable that legacy replay by prefix (`world_particles*`). Does not re-enable V266/V267 and does not touch V281 owner 1/2 roof authority. |
| V284 | active diagnostic contract (wall-layer/sprite occlusion proof) | Adds an opt-in visual/debug diagnostic for the V227 wall-layer sprite occlusion stack. Default mode is `off`; `perlaWallLayerDebugModeV284Set('direct'|'extra'|'sprite'|'seal'|'all')` overlays direct wall ranges, extra wall ranges, sprite-hidden spans, and ground-seal bands separately. It records direct-vs-extra counters without changing wall, roof, canopy, rain, map, collision, or occlusion decisions. |
| V285 | active sprite occlusion baseline | Fixes the V233 rollback mismatch where undrawn V227 extra wall layers still hid sprites. Sprite occlusion now follows drawn wall authority: direct wall ranges still occlude sprites, but `v227_extra_wall_layer` ranges are skipped for sprite clipping while V233 keeps the far-wall extra draw disabled. Canopy/rain consumers keep their existing V227 range semantics. |
| V287 | active targeted reception wall sprite occlusion contract | The far west reception wall remains visually drawn by the normal wallcast and keeps normal wall buffers, but it is removed from the V227 sprite-clipping range list only for the long bar/north-field east-facing repro where that wall was incorrectly masking tamarisk/tree sprites. Scope: reception wood wall tex `2`, vertical west/east reception boundary cells from gameplay X `36..44`, Y `2..8`, camera in the north/bar corridor, long-distance east view. V286-style visual wall suppression is not present in the runtime. |
| V288/V289 | active reception direct/foreground tree sprite occlusion contracts | Narrow sprite-occlusion follow-ups for direct reception wall/tree/tamarisk masking. They preserve wall pixels, map/collision, and primary wallcast buffers while restricting invalid sprite clipping authority. |
| V290/V291 | retained inactive diagnostics | V291 pre-wall restore is intentionally disabled after visual QA showed it could hide the real replay-order bug by copying pre-wall pixels. Do not use positive V291 restore counters as proof for the tamarisk/reception wall issue. |
| V292 | active functional contract | Fixes the accepted cause directly: `drawV220LocalWallsAfterV216Cover` is gated to active rain/V216 replay context, and `game_room_column` canopy sprites are hidden only when an owner-1 reception wall is in front of them, using either a direct V227 wall layer or the already captured `wallColumnV218` rects as sprite occlusion authority. |
| V293 | debug/telemetry only | Additive unified telemetry/debug facade. It does not change renderer, draw order, maps, assets, roof/canopy/sprite/rain predicates, overlay defaults, or occlusion behavior. It exposes `collectPerlaUnifiedTelemetryV293`, `perlaTelemetryHealthV293`, `perlaTelemetryBranchInventoryV293`, and `perlaTelemetryDeletionReadinessV293` while preserving historical V258/V258A, V281, V283, V284/V285, and V292 commands/counters. |
| V294 | preserved compatibility contract (V237 tombstone cleanup only) | Removes the dead V237 safe-emerging-wall draw integration and converts V237 implementation bodies to no-op/tombstone shims. It preserves V237/V238 constants, `getV238CleanStatus`, `getV237EmergingLayerStats`, V293 telemetry APIs, and all current visual authorities. It does not change roof, canopy, rain, wall/replay, map/collision, asset, sky/backdrop, or overlay behavior. |
| V295 | preserved debug/cleanup contract | Adds the modern read-only debug hub `window.perlaDebugV295`, `collectPerlaModernDebugV295`, health/branch/deletion readiness aliases, and absorbs legacy high-wall diagnostics into a non-mutating status surface. It blocks V245 one-shot activation and tombstones public mode/toggle activation for failed roof branches V266/V267/V270/V271/V272 while preserving compatibility shims and counters. It does not change active V281 roof authority, V283 canopy foreground guard, V222/V292 rain/wall behavior, V185 horizon, maps, assets, or overlay defaults. |
| V296 | active base contract (physical tombstone prune) | Physically removes proved-dead heavy implementation bodies for V239-V241C high-wall diagnostics and failed V266/V267/V270/V271/V272/V273/V274/V275 roof/eave attempts, while preserving public compatibility shims, status/toggle/download names, V293/V295 debug APIs, and `safeDeleteNow: []` for public APIs. It does not change active V281 roof authority, V283 canopy foreground guard, V222/V292 rain/wall behavior, V185 horizon, maps, assets, overlay defaults, or rain output. |
| V297 | pergola draw budget | Reduces `drawIvyPergolaLayerV79` cost with screen-row footprint culling, negative-only fast visibility rejection, cached/batched fog overlay rectangles, and a light adaptive step increase capped at +1/+1 only in clear large-area cases. It preserves exact `isInsideIvyPergolaV79` sampling, final `slopedRoofPixelVisible` authority, map/assets/rain output, and roof/canopy/wall contracts. |
| V298 | roof storm budget | Adds a storm/rain pressure-only full-surface roof step budget inside the active V281 primitive renderer. It applies only to `face.kind === 'roof'` for owner 1/2 full-surface modern roofs while preserving edge lines, gable outlines, portal underside, map/assets/rain output, and the V281/V283/V292 visual authority contracts. |
| V299 | current contract (roof always budget) | Extends the V298 roof step-budget mechanism with a light non-storm full-surface roof fill budget for owner 1/2 modern roofs, so clear weather is covered while storm/rain continues to use the V298 pressure layer. V299 still applies only to `face.kind === 'roof'` full-surface fills, preserves edge lines, gable outlines, portal underside, fallback exclusivity, map/assets/rain output, and keeps V298 as the storm/rain escalation. Current build: `PERLA1_V299_ROOF_ALWAYS_BUDGET_SAFE_LOCAL`. |

## V281 Modern Roof Primitive Authority Contract

Current expected behavior for modern reception/bath roof/eave work:

- Current `PERLA_BUILD_ID` is `PERLA1_V299_ROOF_ALWAYS_BUDGET_SAFE_LOCAL`; the V281 roof authority contract below remains active, with V299 adding a non-storm light budget to full-surface roof fills and V298 still adding extra storm/rain pressure budget where applicable.
- V281 adds `drawStableModernOwnerRoofPrimitiveV281` as the single reception/bath roof authority when preflight accepts the roof.
- Eligible owner 1/2 roofSegments are skipped in `drawSlopedRoofLayer2_5D`, `drawSlopedRoofGableCaps2_5D`, V272, V274, and the V278 integrated cap. During V281 QA, `PERLA_V281_QA_DISABLE_OWNER12_LEGACY_FALLBACK` also blocks owner 1/2 legacy fallback so visual proof cannot be masked by the old sampler.
- The primitive renderer uses real `collectModernRoofFaces` world-space faces, `roofVisibleAt`, and `roofSelfDepthWriteBudgetBlockV200`; it is not a screen overlay or fake band.
- It draws roof top, gable, and fascia as world-space geometry. Owner1/owner2 full-surface mode uses explicit full-surface budgets (`owner1`: 320000 pixels / 4200 fill rects / warn 300000; `owner2`: 260000 pixels / 3600 fill rects / warn 240000) so accepted roof faces do not disappear through near-plane clipping. Non-full-surface fallback still uses the smaller V281 primitive budget.
- Same-owner wall pixels remain authoritative inside the wall body span: V281 allows a narrow 5 px eave handoff only for fascia/gable and roof-plane pixels at `eaveZ`, while deeper roof pixels still cannot rasterize through visible wall texture, doors, or openings.
- The V281 near-door guard uses `perlaModernRoofNearDoorSuppressTopPlanesV280` as a risk detector for unstable near-plane roof tops/edge lines; fascia/gable/eave handoff remain available and V278 cap stays disabled.
- V281S keeps owner 1 `back_y0` gable closure only when it is the real far/posterior closure: original outside-front `dirY < -0.10`, or the narrow reception portal band around `roof.y3` with lateral bounds. This prevents the posterior colmo from disappearing under rotation without re-enabling broad decorative edges, V278 cap, bridge, or legacy roof fallback.
- V281T keeps owner 2 bath door-side `back_x0` gable and opposite `front_x1` closure only when derived from the real `roof.doors` west portal context.
- V281U enables owner2 full-surface primitive ownership, bypassing the V236 support-sync rejection only for owner2 full-surface pixels so bath roof faces stay stable under same-coordinate rotation without re-enabling legacy layers.
- V281V suppresses owner2 exterior decorative edge/ridge/eave lines in full-surface mode; the filled roof faces remain the authority, so thin line artifacts are not used as visual proof.
- V281W suppresses owner2 exterior fascia/gronda faces in full-surface mode, matching the reception behavior and removing the thick dark strip between wall and roof; roof top and gable faces remain active.
- V281X extends the reception flush wall join to owner2 full-surface roofs, removing the residual discontinuous warm wall/top pixels at the bath wall/roof junction without drawing a replacement seam. It also makes owner2 columns with unrelated foreground hedge/wall tops fall back from fast-span to per-pixel visibility and rejects only the near-eave/top foreground overlap, avoiding the old V232 fake roof support clip.
- V283 is not a modern roof renderer. It only guards legacy/open canopy owner `0` spans from `drawDeferredCanopySegmentsV121`: foreground walls/hedges in V227 ranges reject canopy sub-runs, and sprite foreground depth prevents `ceilingSpriteClipY` from clipping sprites clearly in front of the canopy. If the legacy V221 local replay path is active, V283 clips open-canopy replay rects against foreground walls/sprites; current V222 world-particles rain/storm modes disable legacy V216 replay by `world_particles*` prefix.
- V284 is diagnostic-only. It annotates the existing V227 wall-layer occlusion ranges with direct/extra roles, exposes the opt-in wall-layer debug overlay, and records which role hides sprite pixels. It must not be treated as the functional fix for the wall-in-front-of-sprites issue.
- V285 is the functional sprite-only baseline for the V233/V227 mismatch. It does not delete extra ranges and does not change canopy/rain consumers; it only prevents undrawn V227 extra wall layers from clipping sprite spans.
- V287 is the targeted fix for the reception wall/tamarisk repro. It does not suppress wall drawing, does not mutate map/collision, and does not alter the primary wallcast `ZBuffer`; it only prevents the identified far west reception wall range from being inserted as a sprite clipping authority in `WallOcclusionRangesV227`.
- V288/V289 are narrow reception direct/foreground tree sprite-occlusion refinements. They preserve wall drawing, map/collision, and primary wall buffers.
- V290/V291 are retained as inactive diagnostics; V291 restore must stay disabled for this bug because it hides the order problem instead of fixing the layer authority.
- V292 gates local V220 wall replay to active rain/V216 replay context and adds a sprite-span guard for `game_room_column` only when it is behind an owner-1 reception wall layer or matching captured `wallColumnV218` wall rect.
- V293 is telemetry/debug only. It inventories protected/runtime-off/compatibility branches and deletion readiness, but it must not be used as broad permission to delete code or to change visual behavior.
- V294 is the first cleanup wave and is intentionally narrow: only the V237 safe-emerging-wall prototype implementation and wallcast call-site are tombstoned.
- V295 is the preserved cleanup/debug wave: `window.perlaDebugV295` is the preferred read-only hub, V245 high-wall one-shot activation is blocked and reported as absorbed, and V266/V267/V270/V271/V272 failed roof mode/toggle activation remains forced off with tombstone shims.
- V296 remains the physical cleanup base: the proved-dead heavy implementation bodies for V239-V241C and V266-V275 are pruned behind no-op/status shims. `safeDeleteNow` remains empty for public APIs: V282, V216/V220/V221, V233, V290/V291, and any still-referenced public debug symbols are deferred until a dedicated proof patch.
- V297 is the pergola draw-budget wave: `drawIvyPergolaLayerV79` now avoids rows outside the projected pergola footprint, rejects only impossible/offscreen/covered candidates before the existing visibility test, batches equivalent fog overlay rectangles, and adds at most one clear-weather sampling step on large covered views. Rain/storm coverage extras remain governed by V261/V265 and are not made more aggressive by V297.
- V298 is the storm/rain roof pressure layer for full-surface V281 roof fills.
- V299 is the current always-covered roof draw budget: clear/non-storm owner 1/2 full-surface roof fills use the V299 light step budget, while storm/rain pressure uses the V298 counters. V299 must not step edge lines, gable outlines, portal underside, non-roof faces, storm/rain pressure paths, or fallback paths.
- Door openings are bridged from `roofSegments[].doors` projection only; generic same-owner screen gaps are not authority.
- V278 cap pixels must be zero in normal V281 runtime; `modernStableRoofPrimitiveSkippedIntegratedCapV281` proves the cap was not drawn.
- If primitive preflight rejects a roof, fallback is exclusive through the existing V265/V277 path; no cap overlay is added on top.
- V267 must not skip the original/sloped roof fill in normal runtime.
- V266 silhouette, V270/V271 external ceiling clone, V273 external strip/anchor, V274 geometric eave edge, and V275 handoff are runtime-off.
- Internal ceiling/soffit stays in `drawModernCoverCeilingSegment`; do not delete or disable it as part of roof visual rollback.
- Tower roof remains separate and must not be changed to solve reception/bath roof regressions.
- Coordinate-dependent proof must account for the west expansion display offset: HUD `X 53.64` corresponds to internal runtime `X 83.64`.
- Screenshot proof must use canvas captures or otherwise prove no HUD/clock/minimap contamination.
- Roof/eave proof must include `visual_pose_matrix_check`: accepted base coordinates, same-coordinate center/left/right rotations, `coordinate_offset_check`, `hud_contamination_check`, and counters per screenshot. Same-coordinate rotations that lose roof volume, drop faces, or hit budget inconsistently are validation failure, not a pass with warning.
- Roof/eave proof must also satisfy `roof_visual_matrix_hard_gate`: `roof_matrix_declared_before_patch`, a current runtime/internal coordinate source, HUD/display X recorded separately, the active `roofSegments` owner envelope, far/close/east/west/interior-or-portal/user-repro groups as applicable, `same_coordinate_distance_rotation_grid`, contact sheet or indexed matrix, and `visual_qa_auditor_required`. If the same accepted coordinate changes roof volume, colmo/ridge/front gable, ceiling authority, wall overdraw, or budget state across rotations, record `matrix_failed_replan_not_ready` and replan.

Expected counters in affected V281 roof views:

- `roofV276 === true`
- `roofV277 === true`
- `roofV278 === true`
- `roofV279 === true`
- `roofV280 === true`
- `roofV281 === true`
- `modernStableRoofPrimitiveV281 === true`
- `modernStableRoofPrimitiveAuthorityV281 === "owner_1_2_worldspace_primitive"`
- `modernStableRoofPrimitivePixelsV281 > 0` in primitive-owned modern roof poses
- `modernStableRoofPrimitiveBudgetHitV281 === false`
- `modernStableRoofPrimitiveWarnPixelsV281 === false` in accepted validation poses
- `modernStableRoofPrimitiveHybridViolationV281 === false`
- `modernStableRoofPrimitiveSkippedTopFacesNearDoorV281 === 0` in accepted roof-volume poses, or explicitly documented as a degraded near-plane exception by `visual-qa-auditor`
- `modernStableRoofPrimitiveWallTopRoofPlaneJoinAllowedV281` may be positive in oblique/front eave handoff poses
- `modernStableRoofPrimitiveSkippedSlopedSegmentsV281 > 0` when owner 1/2 is primitive-owned
- `modernStableRoofPrimitiveSkippedGableCapsV281 > 0` when owner 1/2 is primitive-owned
- `modernStableRoofPrimitiveSkippedIntegratedCapV281 > 0`
- `modernStableRoofPrimitiveSuppressedOwner2ExteriorDecorativeEdgesV281 > 0` in accepted exterior bath owner2 V281V poses
- `modernStableRoofPrimitiveSuppressedOwner2ExteriorFasciaV281 > 0` in accepted exterior bath owner2 V281W poses
- `modernStableRoofPrimitiveOwner2FlushWallJoinChecksV281` or `modernStableRoofPrimitiveOwner2FlushWallJoinColumnsV281` present in accepted bath owner2 V281X close/side poses
- `modernStableRoofPrimitiveOwner2ForeignForegroundFastSpanFallbackV281` and/or `modernStableRoofPrimitiveOwner2ForeignForegroundTopRejectedV281` allowed in V281X bath views with unrelated foreground hedge/wall tops
- `modernStableRoofPrimitiveV299 === true`; `modernStableRoofPrimitiveGeneralBudgetAppliedV299` and `modernStableRoofPrimitiveGeneralBudgetColumnsSavedEstimateV299` are expected in owner 1/2 full-surface roof views in clear/non-storm weather
- `modernStableRoofPrimitiveStormBudgetAppliedV298` remains storm/rain pressure-only evidence; it must not be required for clear-weather V299 improvement
- `deferredCanopyForegroundDepthV283 === true` in legacy/open canopy poses with visible canopy segments
- `deferredCanopyForegroundWallRejectedV283` may be positive in sala giochi/bar/yoga poses where canopy is behind a foreground hedge/wall
- `deferredCanopySpriteForegroundPreservedV283` may be positive when a sprite is closer than canopy ceiling depth
- `v221LocalV216OcclusionPrimaryDisabledByV222 === true` and `legacyV216ReplayPrimaryUsedV222 === false` in V222 world-particles rain/storm poses
- `deferredCanopyReplayForegroundWallRejectedV283` / `deferredCanopyReplaySpriteForegroundRejectedV283` are the expected proof counters only if a legacy V221 open-canopy replay path is active
- `wallLayerSpriteOcclusionDiagnosticV284 === true` and `wallLayerDebugEnabledV284 === false` by default
- When the V284 overlay is explicitly enabled for wall/sprite occlusion proof, compare `spriteHiddenByDirectLayerV284`, `spriteHiddenByExtraLayerV284`, `spriteGroundSealDirectPixelsV284`, and `spriteGroundSealExtraPixelsV284` before proposing any layer disablement
- Under V285, expected proof for undrawn extra wall-layer safety is `spriteHiddenByExtraLayerV284 === 0`, `spriteGroundSealExtraPixelsV284 === 0`, and positive `spriteOcclusionUndrawnExtraLayerSkippedPixelsV285`; `wallLayerExtraRangesV284` may remain positive because the diagnostic still shows skipped non-sprite ranges.
- Under V287, expected proof at display X `9.08` / Y `6.28` east and display X `14.53` / Y `5.21` east is positive `receptionFarWestWallSpriteLayerSkippedV287`, `receptionFarWestWallVisualPreservedV287 === true`, `spriteHiddenByExtraLayerV284 === 0`, and `spriteGroundSealExtraPixelsV284 === 0`; the control view at display X `16.35` / Y `5.31` east should keep `receptionFarWestWallSpriteLayerSkippedV287 === 0`.
- Under V292, expected proof at display X `9.08` / Y `6.28` east is `v220WallReplayAfterV216 === false`, `v220WallReplayRects === 0`, `v220WallReplayReason === "disabled_v292_no_active_rain_or_v216_replay"`, `tamariskWallForegroundRestorePixelsV291 === 0`, and positive `v292GameRoomColumnCapturedWallHiddenPixels` or `v292GameRoomColumnClosedWallHiddenPixels` only where the `game_room_column` sprite is behind owner-1 reception wall authority.
- `v277RoofContinuityFillLocalSafe === true`
- `v278ModernIntegratedRoofCapSafe === true`
- `v279ModernRoofCapProfileSafe === true`
- `v280CleanModernRoofCapSafe === true`
- `v280TowerLikePointProfileSafe === true`
- `v281RoofVisualAuthority === "owner_1_2_worldspace_primitive_single_authority"`
- `v278UsesModernSupportBuffersV236 === true`
- `modernIntegratedRoofCapPixelsV278 === 0` in normal V281 roof poses
- `modernIntegratedRoofCapBudgetHitV278 === false`
- `modernIntegratedRoofCapWarnPixelsV278 === false` in accepted validation poses
- `modernIntegratedRoofCapFillRectsV278 === 0`
- `modernIntegratedRoofMinSupportSpanPxV279 > 0`
- `modernIntegratedRoofSupportSpanOwner1V279` / `modernIntegratedRoofSupportSpanOwner2V279` reflect visible support span by owner
- `modernIntegratedRoofSupportGateFallbacksV279 > 0` only when cap groups are rejected for narrow support
- `modernIntegratedRoofLocalBayProfileSafeV279 === false` in V280
- `modernIntegratedRoofDoorSpanProjectedV280 > 0` when a real door-bearing roof is in view
- `modernRoofTopPlanesSuppressedNearDoorV280 > 0` only in near-door/eave poses where the top plane would fill the camera
- `roofV266 === false`, `roofV267 === false`, `roofV273 === false`, `roofV274 === false`, `roofV275 === false`
- `roofSilhouetteMainOriginalRoofFillSkippedV267` absent/zero
- `realRoofGeometricEavePixelsV274` absent/zero
- `realEaveHandoffPixelsV275` absent/zero
- `realRoofUndersideEaveEnabledV272 === false`
- `roofContinuityFillOwner2PixelsV277 === 0` in accepted owner2 V281V poses

## Known Critical Failure Modes

| Failure | Root Cause | Avoidance |
| --- | --- | --- |
| Dotted/broken external roof border | Using floorcasting/ceiling-clone samples as visible border in grazing views. | Use projected `roofSegments` geometry for visible eaves. |
| External edge vanishes after clone suppression | V273 strip visual is bypassed, but V274/V275 draws zero or only partial columns from that angle. | In V276 do not use the clone/geometric/handoff stack as runtime authority; keep V265 visual path active. |
| Huge red roof slabs | Re-enabling or approximating full underside/near geometry without tight visibility/budget. | Keep V272 off unless explicitly measured and redesigned. |
| Edge disappears behind same building wall | Too strict same-owner wall/roof occlusion or screen-space strip drawn before wallcasting. | Do not reintroduce screen-space strips as primary; validate sloped roof sampling and wall buffers together. |
| Draw count rises for no visible gain | Queuing/deduping/bridging many screen-space strips. | Prefer small geometry-derived passes and verify counters. |
| Screenshot contaminated by HUD/orologio/minimap/overlay | HUD, clock, minimap, controls, status text, debug overlay, or browser UI covers or resembles the target world/render area. | Use `hud_contamination_check`; crop/retry/report UI layout risk/reject as visual proof when it overlaps the target. Label intentional UI/HUD QA separately. |
| False coordinates or pose offset | Requested debug pose does not match effective PERLA1 camera, zone, tile, owner, or expected scene. | Use `coordinate_offset_check` when PERLA1 is certain or legitimately suspected and coordinate evidence matters; reconcile requested/effective pose, direction, zone, tile/owner, `offset_delta`, and `false_coordinate_suspicion`. |
| Testing stale or wrong build | Opening `file://` or cached page. | Use server URL with cache-busting query and verify `PERLA_BUILD_ID`. |
| Editing historical snapshot | Modifying extracted scripts in `report/`. | Patch only active runtime unless explicitly instructed. |

## Standard Validation

For rendered runtime changes:

1. Run the local static checks: `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\tools\perla_local_ci.ps1`.
2. Parse inline JS from `01_GIOCO_PRONTO_LOCAL_TEST/index.html`. The local CI wrapper does this through `tools/perla_runtime_analyzer.mjs`.
3. For Codex/agent validation, run `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher`, which starts `AVVIA_GIOCO_CODEX_HEADLESS.ps1 -Serve` when no server is responding and falls back from `8000` to the known Codex ports. For manual play, use `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`.
4. Prefer `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher` for automated screenshot/counter validation on this Windows setup.
5. Load the URL printed by `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` with a cache-busting query. It is normally `http://127.0.0.1:8000/`, but may be a fallback port when `8000` is blocked.
6. Confirm page title and `window.PERLA_BUILD_ID`.
7. Check console/page errors.
8. Use `window.__PERLA_DEBUG__.setPlayerForDebug(...)` for deterministic poses.
9. Capture `#screen` screenshots.
10. Run `coordinate_offset_check` when there is certainty or legitimate doubt that the target is PERLA1 and coordinates/poses affect the conclusion.
11. Run `hud_contamination_check` for screenshots used as world/render proof.
12. Inspect screenshots visually for the exact regression class.
13. Read `window.__PERLA_DEBUG__.perlaLastDrawStats()` and relevant public summaries.

Preferred roof/eave QA pose selection:

Do not treat the table below as permanent truth. First read the current runtime with `roofSegments`, `collectPerlaDebugSnapshot()`, and `perlaLastDrawStats()`. Choose poses from the active owner envelope and record both runtime/internal coordinates and HUD/display coordinates. The west/south expansion can make HUD X differ from internal runtime X; if `posXActual` is exposed, use it as the acceptance coordinate and store the HUD X only as display evidence.

For reception owner 1, recent runtime probes have observed an envelope near `x0=65.7 x3=75.3 y0=1.7 y3=9.3`. This is an example to verify, not a stale coordinate contract. If the runtime reports a different owner 1 envelope, derive the matrix from the current envelope:

```text
centerX = (owner.x0 + owner.x3) / 2
centerY = (owner.y0 + owner.y3) / 2
southNearY = owner.y3 + 0.35
southFarY = owner.y3 + 2.9
westNearX = owner.x0 - 0.7
eastNearX = owner.x3 + 0.7
westFarX = owner.x0 - 3.2
eastFarX = owner.x3 + 3.2
northFarY = owner.y0 - 1.5
```

Minimum `roof_visual_matrix_hard_gate` groups for reception owner 1:

| Group | Purpose | Base from envelope | Required rotations |
| --- | --- | --- | --- |
| Interior center | ceiling/slab continuity | `centerX, centerY` | N, S, E, W, NE, NW, SE, SW |
| Interior or portal threshold | door/portal/rain cover transition | `centerX, owner.y3 - 0.55` or current door line | center, left-oblique, right-oblique, reverse |
| Outside portal close | front gable/colmo visible from near entrance | `centerX, southNearY` | center, left-oblique, right-oblique, east-graze, west-graze |
| Outside frontal far | silhouette without disappearing roof | `centerX, southFarY` | center, left-oblique, right-oblique |
| West lateral near/far | west edge, wall occlusion, no dotted strips | `westNearX/westFarX, centerY` | east, NE, SE, north/south where diagnostic |
| East lateral near/far | east edge, wall occlusion, no dotted strips | `eastNearX/eastFarX, centerY` | west, NW, SW, north/south where diagnostic |
| North/back far | back roof and opposite face | `centerX, northFarY` | south, SE, SW |
| User repro | exact reported failure | accepted runtime/internal coordinate | same coordinate, at least center/left/right plus reported rotation |

Legacy debug poses such as `setPlayerForDebug(64.99, 8.44, 1, 0)` are only comparison probes. Accept them only after `coordinate_offset_check` proves they still target the active owner envelope; otherwise reject them as proof and derive new coordinates from runtime geometry.

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
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher ...` for the known reliable runtime screenshot method, including built-in fallback ports and bundled Node/Playwright resolution.
- System Chrome/Edge headless through Playwright. The bundled Playwright browser may be missing, so use installed Chrome/Edge.
- `tools/perla_runtime_analyzer.mjs` for recurring static structure analysis and dependency graph generation.
- `tools/perla_local_ci.ps1` for local static CI, with `-RuntimeScreenshots` when screenshot smoke validation is needed.
- `tools/perla_runtime_perf_matrix.ps1` for measured clear/storm desktop/mobile performance matrix evidence. Default output is `%TEMP%\PERLA1_perf_matrix_<timestamp>`; generated screenshots/reports remain disposable unless explicitly promoted.
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
| `scenario-rtp-map-auditor` | `read-only` | Audits sceneggiatura/gameplay/RTP identity mapping, source-vs-inference labels, future scenario manifests, placeholders, and no-paradox data readiness. |
| `map-placement-auditor` | `read-only` | Audits placements, coordinates, zones, schedules, walkability, visibility, route reachability, collision, sprite density, and raycaster readability. |
| `event-flow-auditor` | `read-only` | Audits event graph, prerequisites/effects, battle placeholders, success/failure branches, state loops, and no-softlock risks. |
| `dialogue-continuity-auditor` | `read-only` | Audits speaker identity, portrait policy, character-only dialogue, dialogueRefs, tone, and continuity with events/placements. |
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
- Protected PERLA1 steps require `call_agent_evidence`: every required `CALL` agent must be satisfied by `direct_invocation`, `generic_adapter`, or `tooling_blocked`. `critical_path` cannot be used as a generic bypass, and `visual_qa_required` makes `visual-qa-auditor` `CALL` for screenshot/rendered/browser validation or visible regression readiness claims.
- TOML `name` and `description` define PERLA1 role identity and instructions, not guaranteed Codex UI display name, generated nickname, icon, or direct callability.
- Root `.codex/hooks.json` runs `tools/perla_codex_workflow_check.ps1` on `Stop`, `SubagentStart`, and `SubagentStop` after Codex hook trust review. Hooks enforce lifecycle checks; they do not make subagents persistent background daemons.
- `tools/perla_codex_workflow_check.ps1` emits schema `perla.workflow.check.v1` with `-Json` or `-Jsonl`. P0/P1 failures are blocking and return exit code `1`.
- For Codex scripting or CI review, pair the deterministic workflow check with `codex exec --json` only when a model audit is needed and JSONL events should be captured.
- Use `hook_trust_check` before relying on hooks as enforcement evidence. If trust is unknown, hooks are configured but not proven active; use manual workflow checker output plus required guard/audit evidence.
- Keep `checker_semantic_limit` explicit: deterministic checks catch mechanically inspectable drift, not rendered behavior, full plan semantics, user intent, or agent reasoning quality.
- Use a full `workflow-consistency-auditor` audit after workflow-policy `.md`/TOML/agent changes and before sync when those policy files changed meaningfully.
- For RTP/scenario work, `scenario-rtp-map-auditor`, `map-placement-auditor`, `event-flow-auditor`, and `dialogue-continuity-auditor` are mandatory domain auditors when their signals match. They are read-only and do not replace asset integrity, code mapping, renderer, visual QA, workflow guard, workflow consistency, or runtime validation.
- If a task exposes a structural workflow gap, loop, authority conflict, missing schema/validator/agent, runtime boundary conflict, or source-of-truth ambiguity, use the Workflow Self-Expansion Circuit from `PERLA1_TASK_INTAKE_PROTOCOL.md`: stop the protected step, run the guard/auditor, patch the smallest owning workflow layer, add deterministic checker coverage when possible, and validate the workflow.
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
- Track `subagent_task_lifecycle` for delegated work. Run `subagent_slot_hygiene` before spawning more agents, after returned `wait_agent` results, and at finalization; close subagents at Team Leader task completion, or earlier only when the assigned packet is fully integrated, obsolete, stale, aborted, or unsafe; do not close a useful subagent just because one internal step ended.
- Before final delivery, staging, sync, or readiness claims, use `scoped_finalization` and `finalization_gate` to separate approved scope, dirty out-of-scope files, generated/disposable outputs, untracked workflow tooling, validation evidence, subagent lifecycle, selective staging, and residual risk.
- `workflow_tooling_manifest` classifies source tooling such as `tools/perla_codex_workflow_check.ps1`, `tools/perla_local_ci.ps1`, `tools/perla_runtime_analyzer.mjs`, `.codex/`, `tests/perla_regression_suite.json`, and modularization scaffold files separately from disposable reports/logs/screenshots.
- `max_threads` is a concurrency cap only. The Agent Selection Gate decides which agents are necessary; if 7 or more agents are required, use the required agents and batch only when the active tool surface imposes a hard limit. Optional `CONSIDER` work is serialized before required `CALL` work is downgraded.
- Use `task-watchdog` for long-running work. It tracks `task_id`, `operation_id`, and `logical_step_id`; three progressive failures on one logical step force a checkpoint, and a second long failure on the same operation/logical step requires user approval.
- Failure briefs should be assigned to the most relevant read-only specialist and must produce a best checkpoint plus two or three real continuation plans.
- Use `refactor-surgeon` only after documented blockage. It must first produce `REFACTOR_PLAN_ONLY`; `APPLY_APPROVED_REFACTOR` requires explicit approved scope. It may propose controlled derogations, but strong/ambiguous conflicts require user approval.

Browser validation notes:

- Browser validation requires the PERLA1 local server first. For Codex/agents, the normal startup entry point is `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher`, backed by `AVVIA_GIOCO_CODEX_HEADLESS.ps1` and automatic fallback ports. For manual user play, use `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`.
- On this Windows setup, the proven method is `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1`: Playwright packages from Codex runtime plus installed system Chrome/Edge.
- Treat the in-app Browser as secondary unless the user specifically asks for it or the headless method stops working.
- If Browser fails due sandbox/Windows permission issues, use the runbook method and keep the target URL identical to the validator-printed URL, including fallback port and cache-busting query.
- Known Browser tooling failure: `CreateProcessAsUserW failed: 5`. Treat it as a Codex Browser/Windows sandbox launch failure, not as evidence that the PERLA1 runtime failed.
- Use `browser_failure_cache` for deterministic in-app Browser launch failures within a task/session. After the first cached failure, retrying the in-app Browser bootstrap is forbidden unless the user explicitly asks, browser/tooling state changed, a new Codex session has no current failure evidence, or the Playwright/headless route fails and comparison is needed.
- If the runbook/headless validation fails, hand off manual validation with exact URL, expected build id, debug poses, screenshot targets, console checks, and counters/API calls.
- Do not claim full rendered validation unless screenshots and relevant counters were actually inspected.
- Do not claim world/render visual proof from a screenshot whose target area is obscured by HUD/clock/minimap/overlay, or from PERLA1 coordinate-dependent evidence with unresolved `false_coordinate_suspicion`.
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
- HUD contamination or coordinate offset validation rules change,
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


