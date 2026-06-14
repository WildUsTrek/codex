# PERLA1 Symbol Index

Last updated: 2026-06-14

Derived from the current `01_GIOCO_PRONTO_LOCAL_TEST/index.html` build observed as `PERLA1_V278_MODERN_INTEGRATED_ROOF_CAP_SAFE_LOCAL`.

This index is for orientation only. It is not the source of truth. Before patching, verify symbols and line numbers with `rg` against the current runtime file.

## Runtime Symbol Map

| Block ID | Symbol / Area | Current Hint | Notes |
| --- | --- | --- | --- |
| `boot-shell` | `PERLA_BUILD_ID` | around line `195` | Public build id used for cache/build validation. |
| `sprites` | `getSpriteRenderCandidates` | around line `650` | Sprite candidate selection entry point. |
| `roof-system` | V278 constants | around lines `499-514` | Modern wall-anchored integrated roof cap tuning and support-visible replacement flag. |
| `world-data` | `mapW`, `mapH` | around line `5861` | World dimensions. |
| `world-data` | `SEA_Y` | around line `5864` | Sea/beach boundary reference. |
| `asset-loading` | `ASSET_BASE`, `ASSET_MANIFEST` | around lines `5865-5910` | Runtime asset path and manifest definitions. |
| `world-data` | `zoneMask`, `map`, `fMap`, `cMap`, `ceilingOwnerMap` | around lines `7990-8050` | Main world arrays and ownership data; verify exact symbol before changes. |
| `roof-system` | `perlaRealEaveHandoffLastSummaryV275` | around line `2148` | V275 handoff summary state. |
| `roof-system` | `perlaRealEaveHandoffQueueFallbackV275` | around line `2409` | Queues V275 uncovered-column fallback. |
| `roof-system` | `perlaRealEaveHandoffFlushV275` | around line `2490` | Flushes V275 handoff after roof depth is known. |
| `roof-system` | `perlaRealEaveHandoffDownloadV275` | around line `2606` | V275 diagnostic export/download helper. |
| `roof-system` | `perlaRealRoofGeometricEaveEdgePassV274` | around line `2633` | Retained for diagnostics; runtime-off/no longer primary under V278. |
| `roof-system` | `perlaRoofContinuityFillLocalV277` | around line `1377` | V277 local budgeted continuity fill inside the V265/V276 roof path. |
| `roof-system` | `perlaModernIntegratedRoofEnabledV278` | around line `11209` | V278 support-visible integrated roof cap gate for modern owner 1/2. |
| `roof-system` | `drawModernIntegratedRoofCapV278` | around line `11274` | V278 wall-anchored integrated cap renderer using `ModernSupport*BufferV236`. |
| `roof-system` | `drawSlopedRoofGableCaps2_5D` | around line `12054` | Sloped roof gable cap renderer; V278 can skip owner 1/2 only when support cap is active. |
| `roof-system` | `drawSlopedRoofLayer2_5D` | around line `12132` | Sloped roof plane renderer and V277 hook before V265 edge rail; V278 conditionally skips support-visible modern owner segments. |
| `roof-system` | `drawRoofLayer2_5D` | around line `12457` | Roof layer orchestration and V276/V277/V278 debug counters. |
| `weather-rain` | `drawWorldRainParticlesV222` | around line `24452` | Rain particle renderer. |
| `renderer` | `drawWorld` | around line `25601` | Main world render pipeline. |
| `minimap` | `drawMiniMap` | around line `26201` | Minimap rendering and mobile frame skipping. |
| `renderer` | `gameLoop` | around line `26556` | Main update/render loop. |
| `debug-api` | `window.__PERLA_DEBUG__` | around line `26634` | Public debug API container. |
| `debug-api` | `perlaLastDrawStats`, `setPlayerForDebug` | near `window.__PERLA_DEBUG__` | Main validation counters and deterministic pose setter. |
| `debug-api` | `window.perlaRealEaveHandoffSummaryV275` | around line `26753` | V275 public summary export. |

## Validation Helpers

| Purpose | Path / Symbol | Notes |
| --- | --- | --- |
| Runtime validation runbook | `PERLA1_RUNTIME_TEST_RUNBOOK.md` | Read before browser or screenshot validation. |
| Task intake protocol | `PERLA1_TASK_INTAKE_PROTOCOL.md` | Read before meaningful edits, runtime validation, multi-agent work, or refactor planning. |
| Headless screenshot helper | `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` | Reliable Windows path after launcher/server is running. |
| Required server route | `http://127.0.0.1:8000/` | Use cache-busting query and verify `PERLA_BUILD_ID`. |
| Static structure analyzer | `tools/perla_runtime_analyzer.mjs` | Produces parse check, function/global counts, block classification, top large functions, and focused dependency graphs. |
| Local static CI | `tools/perla_local_ci.ps1` | Runs analyzer checks against `tests/perla_regression_suite.json`; optional `-RuntimeScreenshots` invokes smoke poses. |

## Use Rules

- Use this file to choose the first symbols to inspect, not to justify a patch without code reads.
- If line hints drift, update this index after verifying with `rg`.
- If a new stable subsystem, debug hook, or Vxxx contract appears, update this index with the project and block maps.
