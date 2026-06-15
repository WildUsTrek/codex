# PERLA1 Symbol Index

Last updated: 2026-06-15

Derived from the current `01_GIOCO_PRONTO_LOCAL_TEST/index.html` build observed as `PERLA1_V281X_BATH_FLUSH_JOIN_FOREGROUND_CLEANUP_LOCAL`.

This index is for orientation only. It is not the source of truth. Before patching, verify symbols and line numbers with `rg` against the current runtime file.

## Runtime Symbol Map

| Block ID | Symbol / Area | Current Hint | Notes |
| --- | --- | --- | --- |
| `boot-shell` | `PERLA_BUILD_ID` | around line `195` | Public build id used for cache/build validation. |
| `boot-shell` | `PERLA1_V281X_BATH_FLUSH_JOIN_FOREGROUND_CLEANUP_LOCAL` | around line `195` | V281X current contract build id for reception plus bath full-surface owner2 flush wall join and foreground-top cleanup validation. |
| `sprites` | `getSpriteRenderCandidates` | around line `663` | Sprite candidate selection entry point. |
| `roof-system` | V278 constants | around lines `498-514` | Modern wall-anchored integrated roof cap tuning, unchanged 5000 pixel / 1400 fill-rect budget, and support-visible replacement flag. |
| `roof-system` | V279 constants | around lines `515-533` | Modern cap profile/support-span tuning retained as the V280 base; local-bay profile is disabled in current runtime. |
| `roof-system` | V280 constants | around lines `534-553` | Geometry-primary modern roof contract, real-door bridge limits, and small support-cap seam profile for reception/baths. |
| `roof-system` | V281 constants | around lines `554-575` | Single-authority modern owner 1/2 primitive flags, owner1/owner2 full-surface budgets, and V278 cap-disable switch. |
| `world-data` | `mapW`, `mapH` | around line `5861` | World dimensions. |
| `world-data` | `SEA_Y` | around line `5864` | Sea/beach boundary reference. |
| `asset-loading` | `ASSET_BASE`, `ASSET_MANIFEST` | around lines `5865-5910` | Runtime asset path and manifest definitions. |
| `world-data` | `zoneMask`, `map`, `fMap`, `cMap`, `ceilingOwnerMap` | around lines `7990-8050` | Main world arrays and ownership data; verify exact symbol before changes. |
| `roof-system` | `perlaRealEaveHandoffLastSummaryV275` | around line `2148` | V275 handoff summary state. |
| `roof-system` | `perlaRealEaveHandoffQueueFallbackV275` | around line `2409` | Queues V275 uncovered-column fallback. |
| `roof-system` | `perlaRealEaveHandoffFlushV275` | around line `2490` | Flushes V275 handoff after roof depth is known. |
| `roof-system` | `perlaRealEaveHandoffDownloadV275` | around line `2606` | V275 diagnostic export/download helper. |
| `roof-system` | `perlaRealRoofGeometricEaveEdgePassV274` | around line `2633` | Retained for diagnostics; runtime-off/no longer primary under V280. |
| `roof-system` | `perlaRoofContinuityFillLocalV277` | around line `1377` | V277 local budgeted continuity fill inside the V265/V276 roof path. |
| `roof-system` | `perlaModernIntegratedRoofEnabledV278` | around line `11238` | Integrated roof cap gate for modern owner 1/2; in V280 the cap is seam/door support, not the main roof silhouette. |
| `roof-system` | `perlaModernSupportSpanPxV279`, `perlaModernSupportMinSpanPxV279`, `perlaModernIntegratedCapMaxHeightV280` | around lines `11246-11273` | Support-span helpers and V280 small cap height helper used for validation/fallback counters. |
| `roof-system` | `perlaModernRoofNearDoorSuppressTopPlanesV280` | around line `11279` | V280 near-door/eave guard that suppresses only top sloped planes when the camera is under a real roof door/eave. |
| `roof-system` | `projectModernRoofDoorSpanV280`, `perlaModernRoofDoorBridgeSpansV280`, `perlaModernSupportSampleV280` | around lines `11309-11391` | V280 real-door bridge projection and virtual support sampling for cleared doorway cells. |
| `roof-system` | `drawModernIntegratedRoofCapV278` | around line `11330` | V278/V279/V280 wall-anchored integrated cap renderer. Under V281 it is explicitly skipped in normal owner 1/2 runtime to avoid a hybrid slab overlay. |
| `roof-system` | `perlaStableModernRoofPrimitiveReplacesSegmentV281` | around line `11920` | Central predicate for owner 1/2 primitive eligibility and exclusive legacy skip/fallback. |
| `roof-system` | `drawStableModernOwnerRoofPrimitiveV281` | around line `12030` | Budgeted world-space roof primitive authority for reception/baths; draws `collectModernRoofFaces` with depth and counters. |
| `roof-system` | `perlaStableModernRoofPrimitiveFullSurfaceOwnerV281` | around line `12275` | V281U/V281V owner1/owner2 full-surface gate used to keep reception/bath roof faces whole instead of near-plane clipping or legacy fallback. |
| `roof-system` | `perlaStableModernRoofPrimitiveOwner1BackGableClosureNeededV281` | around line `12178` | V281S narrow owner 1 `back_y0` keep predicate for posterior/far closure and reception portal band; prevents rotation-dependent back colmo disappearance without enabling V278 cap or legacy fallback. |
| `roof-system` | `perlaStableModernRoofPrimitiveOwner2DoorGableFacesCameraV281` | around line `12190` | V281T owner 2 door-derived `back_x0` keep predicate for bath portal gable stability; uses `roof.doors`, not hardcoded coordinates. |
| `roof-system` | `perlaStableModernRoofPrimitiveOwner2OppositeGableClosureNeededV281` | around line `12200` | V281T owner 2 opposite `front_x1` keep predicate for far closure from the bath west door context. |
| `roof-system` | `perlaStableModernRoofPrimitiveSuppressOwner2ExteriorFasciaV281` | around line `12256` | V281W suppresses owner2 full-surface exterior fascia/gronda faces, matching reception behavior so the bath roof does not show a thick dark strip between wall and roof. |
| `roof-system` | `perlaStableModernRoofPrimitiveSuppressOwner2ExteriorDecorativeEdgesV281` | around line `12260` | V281V suppresses owner2 full-surface exterior decorative edge/ridge/eave lines so the bath roof reads as clean filled geometry, matching the reception cleanup principle. |
| `roof-system` | `perlaStableModernRoofPrimitiveOwner2ExteriorFlushWallJoinV281` | around line `12280` | V281X extends the reception-style flush wall join to owner2 full-surface exterior roofs, removing residual discontinuous warm wall/top pixels without drawing a seam. |
| `roof-system` | `perlaStableModernRoofPrimitiveForeignForegroundTopRejectV281` | around line `12425` | V281X rejects owner2 near-eave pixels only at unrelated foreground hedge/wall tops after fast-span fallback, avoiding legacy V232 fake clipping. |
| `roof-system` | V281 primitive counters | around lines `12140-12170` | `roofV281`, primitive authority, candidates, fallback, pixels, rects, budget/warn, skipped/suppressed/rejected faces, same-owner wall rejection, wall-top join, cap/fallback skip, and hybrid violation counters. Required in `visual_pose_matrix_check`. |
| `roof-system` | `drawSlopedRoofGableCaps2_5D` | around line `12540` | Sloped roof gable cap renderer; V281 skips eligible modern owner 1/2 gables so they do not hybridize with the primitive authority. |
| `roof-system` | `drawSlopedRoofLayer2_5D` | around line `12620` | Sloped roof plane renderer and V277 hook before V265 edge rail; V281 uses this as fallback/generic path outside primitive-owned owner 1/2 roofs. |
| `roof-system` | `drawRoofLayer2_5D` | around line `12820` | Roof layer orchestration and V276/V277/V278/V279/V280/V281 debug counters. |
| `weather-rain` | `drawWorldRainParticlesV222` | around line `24505` | Rain particle renderer. |
| `renderer` | `drawWorld` | around line `25691` | Main world render pipeline. |
| `minimap` | `drawMiniMap` | around line `26291` | Minimap rendering and mobile frame skipping. |
| `renderer` | `gameLoop` | around line `26646` | Main update/render loop. |
| `debug-api` | `window.__PERLA_DEBUG__` | around line `26831` | Public debug API container. |
| `debug-api` | `perlaLastDrawStats`, `setPlayerForDebug` | near `window.__PERLA_DEBUG__` | Main validation counters and deterministic pose setter. |
| `debug-api` | `window.perlaRealEaveHandoffSummaryV275` | around line `26806` | V275 public summary export. |

## Validation Helpers

| Purpose | Path / Symbol | Notes |
| --- | --- | --- |
| Runtime validation runbook | `PERLA1_RUNTIME_TEST_RUNBOOK.md` | Read before browser or screenshot validation. |
| Task intake protocol | `PERLA1_TASK_INTAKE_PROTOCOL.md` | Read before meaningful edits, runtime validation, multi-agent work, or refactor planning. |
| Headless screenshot helper | `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` | Reliable Windows path after launcher/server is running. |
| Required server route | `http://127.0.0.1:8000/` | Use cache-busting query and verify `PERLA_BUILD_ID`. |
| Deterministic pose setter | `window.__PERLA_DEBUG__.setPlayerForDebug(...)` | Use with `coordinate_offset_check`; compare requested/effective pose and direction before accepting coordinate-dependent proof. |
| Debug camera snapshot | `window.__PERLA_DEBUG__.collectPerlaDebugSnapshot().camera` | Preferred current-camera evidence for effective pose, direction, zone, and `offset_delta` checks when available. |
| Player zone helper | `window.__PERLA_DEBUG__.zoneAtPlayer` / debug snapshot zone | Use to compare expected/observed zone and detect `false_coordinate_suspicion`. Verify exact exported shape in current runtime before relying on it. |
| Runtime draw stats | `window.__PERLA_DEBUG__.perlaLastDrawStats()` / `perlaLastDrawStats` | Read relevant counters after screenshot capture. |
| Screenshot hygiene | `hud_contamination_check` | Classifies HUD/clock/minimap/controls/status/debug/browser UI overlap before accepting screenshots as world/render proof. |
| Coordinate hygiene | `coordinate_offset_check` | Required when PERLA1 is certain or legitimately suspected and pose/location affects the conclusion. |
| Rotation matrix hygiene | `visual_pose_matrix_check`, `roof_visual_matrix_hard_gate` | Required for roof/eave/wall-occlusion/visibility work; use accepted runtime/internal base coordinates, HUD/display X recorded separately, `roof_matrix_declared_before_patch`, `same_coordinate_distance_rotation_grid`, same-coordinate rotations, contact sheet or indexed matrix, counters, visual pass/fail decisions, and `matrix_failed_replan_not_ready` when required roof groups fail or are missing. |
| Static structure analyzer | `tools/perla_runtime_analyzer.mjs` | Produces parse check, function/global counts, block classification, top large functions, and focused dependency graphs. |
| Local static CI | `tools/perla_local_ci.ps1` | Runs analyzer checks against `tests/perla_regression_suite.json`; optional `-RuntimeScreenshots` invokes smoke poses. |

## Use Rules

- Use this file to choose the first symbols to inspect, not to justify a patch without code reads.
- If line hints drift, update this index after verifying with `rg`.
- If a new stable subsystem, debug hook, or Vxxx contract appears, update this index with the project and block maps.
