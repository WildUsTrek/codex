# PERLA1 Game Runtime Agent Guide

Scope: this file applies to `01_GIOCO_PRONTO_LOCAL_TEST/`.

## Runtime Source Of Truth

- `index.html` is the playable game. It contains the renderer, world data, debug APIs, and build id.
- `index.html.bak_*` files are backups only.
- Extracted scripts under `../report/` are historical snapshots, not the active runtime.

## Roof/Ceiling Invariants

- Modern roof owner `1` is reception.
- Modern roof owner `2` is bath.
- `roofSegments` are the authoritative geometry source for modern roof visual edges.
- Do not use floorcasting/ceiling-clone samples as the primary visible source for external roof borders. In grazing views those samples become sparse and create dotted or disappearing borders.
- The V270/V271/V273 real ceiling clone path may be used for ceiling continuity/depth anchoring, not as the final visible external eave edge when V274 owns the edge.
- V272 real underside/eave pass is runtime-off rollback by default; do not turn it back on as a quick fix.
- V265 edge rail must not become the primary roof border replacement for reception/bath eaves.
- Keep roof fixes geometry-aware, owner-aware, and draw-budgeted.

## Current Roof Patch Contract

For V275 and successors:

- Primary visible external eave/border must come from real `roofSegments` projection through the V274 geometric eave path.
- V275 may add a thin depth-aware fallback only for external clone columns not already covered by V274.
- V273 external strip visual should stay bypassed where V274/V275 handle the visible edge.
- Expected V275 debug pattern in affected roof views:
  - `realCeilingCloneEaveStripQueuedV273` is `0`.
  - `realCeilingCloneEaveStripDrawnV273` is `0`.
  - `realCeilingCloneEaveStripPixelsV273` is `0`.
  - `realRoofGeometricEavePixelsV274` or `realEaveHandoffPixelsV275` is greater than `0` when a modern eave is visible.
  - `realEaveHandoffPixelBudgetHitV275` is not `true`.
  - `realRoofUndersideEaveEnabledV272` is `false`.
  - `realCeilingCloneExternalVisualHandledV274` is greater than `0` when external clone cells are present.

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
