# PERLA1 Game Runtime Agent Guide

Scope: this file applies to `01_GIOCO_PRONTO_LOCAL_TEST/`.

## Runtime Source Of Truth

- `index.html` is the playable game. It contains the renderer, world data, debug APIs, and build id.
- `index.html.bak_*` files are backups only.
- Extracted scripts under `../report/` are historical snapshots, not the active runtime.

## Roof/Ceiling Invariants

- Modern roof owner `1` is reception.
- Modern roof owner `2` is bath.
- V278 current visual authority for wall-visible modern exterior roofs is the owner-aware integrated cap path: `drawModernIntegratedRoofCapV278`, anchored to `ModernSupport*BufferV236` columns. V265/V276/V277 sloped roof paths remain fallback/support when no same-owner modern support columns are visible.
- `roofSegments` remain the authoritative geometry data source, but V274/V275 are no longer the active primary renderer after the V275 visual failure.
- Do not use floorcasting/ceiling-clone samples as the primary visible source for external roof borders. In grazing views those samples become sparse and create dotted or disappearing borders.
- The V270/V271/V273 real ceiling clone path is runtime-off in V276 for external roof visuals.
- V272 real underside/eave pass is runtime-off rollback by default; do not turn it back on as a quick fix.
- Do not re-enable V266/V267 silhouette, V270/V271 external clone, V273 external strip, V274 geometric edge, or V275 handoff as a quick fix without a new explicit plan and validation.
- Preserve `drawModernCoverCeilingSegment`: this is the internal ceiling/soffit path the user wants to keep.
- Keep roof fixes geometry-aware, owner-aware, and draw-budgeted.

## Current Roof Patch Contract

For V278 and successors:

- Primary wall-visible modern exterior roof fill comes from `drawModernIntegratedRoofCapV278`.
- V278 may conditionally skip owner `1`/`2` sloped roof/gable visuals only when same-owner `ModernSupport*BufferV236` columns are visible in the current frame.
- When no same-owner support columns are visible, V278 must not suppress the old sloped roof fallback.
- V277 `perlaRoofContinuityFillLocalV277` remains a support path only; it must not become the current roof authority again without a new explicit plan.
- V267 must not skip the original/sloped roof fill in normal runtime.
- V266/V267/V270/V271/V273/V274/V275 are retained for diagnostics but runtime-off as visual authority.
- Expected V278 debug pattern in affected roof views:
  - `window.PERLA_BUILD_ID` is `PERLA1_V278_MODERN_INTEGRATED_ROOF_CAP_SAFE_LOCAL`.
  - `roofV276` is `true`.
  - `roofV277` is `true`.
  - `roofV278` is `true`.
  - `v278ModernIntegratedRoofCapSafe` is `true`.
  - `v278RoofVisualAuthority` is `wall_anchored_integrated_cap`.
  - `modernIntegratedRoofCapBudgetHitV278` is `false`.
  - `modernIntegratedRoofCapPixelsV278 <= 5000` and `modernIntegratedRoofCapFillRectsV278 <= 1400`.
  - `modernIntegratedRoofSkippedSlopedSegmentsV278 > 0` only in support-visible modern roof poses.
  - `roofV266`, `roofV267`, `roofV273`, `roofV274`, and `roofV275` are `false`.
  - `roofSilhouetteMainOriginalRoofFillSkippedV267` is absent or `0`.
  - `realRoofGeometricEavePixelsV274` and `realEaveHandoffPixelsV275` are absent or `0`.
  - `realRoofUndersideEaveEnabledV272` is `false`.

## Visual QA Poses

Use these debug poses for roof/eave work unless the user provides a newer repro:

- Critical reception west/south edge, east view: `setPlayerForDebug(64.99, 8.44, 1, 0)`
- Critical reception diagonal north-east: `setPlayerForDebug(64.99, 8.44, .7071, -.7071)`
- Critical reception diagonal south-east: `setPlayerForDebug(64.99, 8.44, .7071, .7071)`
- Reception outside south overhang: `setPlayerForDebug(64.99, 9.60, 1, 0)`
- Bath owner 2 south side: `setPlayerForDebug(99, 71, 0, -1)`
- Bath owner 2 east side: `setPlayerForDebug(106.5, 65, -1, 0)`
- Bath owner 2 west side: `setPlayerForDebug(88, 65, 1, 0)`

For each pose:

- Wait at least two animation frames after setting the pose.
- Capture the `#screen` canvas.
- Inspect for dotted vertical fragments, missing outer edge, slab fills, z-fighting, and edge/wall height mismatch.
- Verify console health and relevant draw stats.

## Render Ordering Guidance

- Floor/ceiling pass can write technical depth and continuity.
- Wallcasting owns solid wall visibility and wall buffers.
- Roof edge visuals should live in the roof layer when they represent real roof geometry.
- Do not draw decorative screen-space strips before wallcasting and then expect them to behave like roof geometry.

## Patch Discipline

- When changing runtime behavior, use a new build id suffix and clear comments naming the patch purpose.
- Preserve historical toggles and summaries when possible; bypass unsafe paths rather than deleting useful diagnostics.
- Keep new helpers close to the subsystem they extend.
- Expose a small debug summary for new rendering paths.
- After editing, run a JavaScript parse check before browser validation.
