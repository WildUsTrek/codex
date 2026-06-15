# PERLA1 Game Runtime Agent Guide

Scope: this file applies to `01_GIOCO_PRONTO_LOCAL_TEST/`.

## Runtime Source Of Truth

- `index.html` is the playable game. It contains the renderer, world data, debug APIs, and build id.
- `index.html.bak_*` files are backups only.
- Extracted scripts under `../report/` are historical snapshots, not the active runtime.

## Roof/Ceiling Invariants

- Modern roof owner `1` is reception.
- Modern roof owner `2` is bath.
- V283 current visual contract preserves the V281 modern owner `1`/`2` world-space primitive authority: `drawStableModernOwnerRoofPrimitiveV281` owns reception/bath roof visuals when preflight accepts the roof. V281S keeps the owner `1` `back_y0` gable only in the real posterior/far-closure or reception portal band so the colmo cannot disappear under same-coordinate rotation. V281T adds an owner `2` door-derived `back_x0` portal gable keep and opposite `front_x1` closure keep for the bath roof; it must use `roof.doors`, not hardcoded coordinates. V281U promotes owner2 to the same full-surface primitive authority class as reception; V281V suppresses owner2 full-surface exterior decorative edge/ridge/eave lines; V281W suppresses owner2 full-surface exterior fascia/gronda faces so the bath roof no longer shows a thick dark strip between wall and roof. V281X applies the same flush wall join used by reception to owner2 and adds a V281-local owner2 foreground-top rejection so bath roof/eave pixels do not draw over unrelated foreground hedge/wall tops. V283 is local to legacy/open canopy owner `0` rendering: `drawDeferredCanopySegmentsV121` is clipped by V227 wall foreground ranges, `ceilingSpriteClipY` preserves sprites clearly in front of the canopy, V221 open-canopy replay rects are foreground-clipped if a legacy replay path is active, and V222 world-particles modes disable that legacy replay by prefix. Sloped/gable/V272/V274/V278 are skipped for primitive-owned owner `1`/`2` roofs; V265/V276/V277 remain exclusive fallback only when primitive ownership is not active. Failed V266-V275 replacement/clone/strip/handoff paths remain runtime-off as visual authority, and V282 portal/slab experiments are retained only as diagnostics while runtime-off in the rollback base.
- `roofSegments` remain the authoritative geometry data source, but V274/V275 are no longer the active primary renderer after the V275 visual failure.
- Do not use floorcasting/ceiling-clone samples as the primary visible source for external roof borders. In grazing views those samples become sparse and create dotted or disappearing borders.
- The V270/V271/V273 real ceiling clone path is runtime-off in V276 for external roof visuals.
- V272 real underside/eave pass is runtime-off rollback by default; do not turn it back on as a quick fix.
- Do not re-enable V266/V267 silhouette, V270/V271 external clone, V273 external strip, V274 geometric edge, or V275 handoff as a quick fix without a new explicit plan and validation.
- Preserve `drawModernCoverCeilingSegment`: this is the internal ceiling/soffit path the user wants to keep.
- Keep roof fixes geometry-aware, owner-aware, and draw-budgeted.

## Current Roof Patch Contract

For V283 and successors:

- Primary modern exterior roof profile comes from the V281 budgeted `drawStableModernOwnerRoofPrimitiveV281` world-space primitive, using `roofSegments` faces and real-door-aware near-plane handling.
- V281 wall/eave integration allows only a narrow same-owner handoff at the wall top for fascia/gable and roof-plane pixels near `eaveZ`; it must not allow roof pixels to paint through the visible wall body.
- V281 replaces modern owner `1`/`2` V265/V277 sloped/gable visuals only when primitive preflight accepts the roof.
- For V281 roof/eave validation, `visual_pose_matrix_check` and `roof_visual_matrix_hard_gate` are mandatory: choose accepted base coordinates from current debug/map/`roofSegments` evidence, record runtime/internal coordinates and HUD/display X separately, then test a `same_coordinate_distance_rotation_grid` from the same `x/y`. Required groups include far/close/east/west/interior-or-portal/user-repro as applicable, with a contact sheet or indexed matrix. If a V281-owned roof loses roof volume, colmo/ridge/front gable, interior ceiling/slab authority, drops top faces, changes face count materially, draws forced seam/black lines, or hits budget in only some rotations from the same coordinate, mark `matrix_failed_replan_not_ready` and replan.
- For the current reception owner `1` roof/portal/ceiling problem, `reception_roof_real_objective_gate` is mandatory. Clean coordinates, clean HUD, counters, and a contact sheet only make evidence admissible; they do not prove success. Success requires the actual visual objective: high pointed exterior volume, stable front colmo/gable/top faces under same-coordinate rotation, portal/interior rendered as flat monocolor ceiling/underside where expected, no exterior roof/gable fragments inside the portal, no fake seams/bands/color-family switches, and no bath owner `2` readiness claim from reception-only evidence.
- If a reception roof candidate appears solved or near-solved, stop for user review with the required package before readiness claims or further broad iteration. Removing a black seam, preventing total disappearance, or making one screenshot look better is only `partial_visual_improvement_only` unless the real objective gate passes.
- When primitive preflight rejects a roof, V281 must preserve exclusive fallback roof behavior without adding the V278 cap overlay.
- V277 `perlaRoofContinuityFillLocalV277` remains a support path only; it must not become the current roof authority again without a new explicit plan.
- V267 must not skip the original/sloped roof fill in normal runtime.
- V266/V267/V270/V271/V273/V274/V275 are retained for diagnostics but runtime-off as visual authority.
- Expected V283/V281 debug pattern in affected roof and canopy views:
  - `window.PERLA_BUILD_ID` is `PERLA1_V283_DEFERRED_CANOPY_FOREGROUND_DEPTH_SAFE_LOCAL`.
  - `roofV276` is `true`.
  - `roofV277` is `true`.
  - `roofV278` is `true`.
  - `roofV279` is `true`.
  - `roofV280` is `true`.
  - `roofV281` is `true`.
  - `modernStableRoofPrimitiveV281` is `true`.
  - `modernStableRoofPrimitiveAuthorityV281` is `owner_1_2_worldspace_primitive`.
  - `modernStableRoofPrimitivePixelsV281 > 0` in primitive-owned roof views.
  - `modernStableRoofPrimitiveBudgetHitV281` is `false`.
  - `modernStableRoofPrimitiveWarnPixelsV281` is `false` in accepted validation poses.
  - `modernStableRoofPrimitiveHybridViolationV281` is `false`.
  - `modernStableRoofPrimitiveWallTopRoofPlaneJoinAllowedV281` may be positive in valid oblique/front eave handoff views.
  - `modernStableRoofPrimitiveSkippedTopFacesNearDoorV281` must not be used as proof of a stable roof volume; if it is positive in an accepted roof matrix pose, the pose/result is degraded or failed unless the visual-qa-auditor accepts a narrowly documented near-plane exception.
  - `modernStableRoofPrimitiveBudgetHitV281` and `modernStableRoofPrimitiveWarnPixelsV281` must be consistent and false across accepted same-coordinate rotations.
  - `modernStableRoofPrimitiveSkippedSlopedSegmentsV281 > 0` and `modernStableRoofPrimitiveSkippedGableCapsV281 > 0` when V281 owns supported modern owner `1`/`2` roof views.
  - `modernStableRoofPrimitiveSkippedIntegratedCapV281 > 0`.
  - `modernStableRoofPrimitiveSuppressedOwner2ExteriorDecorativeEdgesV281 > 0` in accepted bath owner2 V281V exterior views.
  - `modernStableRoofPrimitiveSuppressedOwner2ExteriorFasciaV281 > 0` in accepted bath owner2 V281W exterior views.
  - `modernStableRoofPrimitiveOwner2FlushWallJoinChecksV281` or `modernStableRoofPrimitiveOwner2FlushWallJoinColumnsV281` is present in accepted bath owner2 V281X close/side views.
  - `modernStableRoofPrimitiveOwner2ForeignForegroundFastSpanFallbackV281` and/or `modernStableRoofPrimitiveOwner2ForeignForegroundTopRejectedV281` is allowed in V281X bath views with unrelated foreground hedge/wall tops.
  - `deferredCanopyForegroundDepthV283` is `true` when legacy/open canopy segments are rendered.
  - `deferredCanopyForegroundWallRejectedV283` may be positive when sala giochi/bar/yoga canopy is behind foreground wall/hedge ranges.
  - `deferredCanopySpriteForegroundPreservedV283` may be positive when a sprite is closer than the canopy ceiling and must not be clipped.
  - `v221LocalV216OcclusionPrimaryDisabledByV222` is `true` in V222 world-particles rain/storm poses; if a legacy V221 replay path is active, V283 replay foreground counters must prove walls/sprites can still win.
  - `v278ModernIntegratedRoofCapSafe` is `true`.
  - `v279ModernRoofCapProfileSafe` is `true`.
  - `v280CleanModernRoofCapSafe` is `true`.
  - `v280TowerLikePointProfileSafe` is `true`.
  - `modernIntegratedRoofCapBudgetHitV278` is `false`.
  - `modernIntegratedRoofCapPixelsV278` is `0` and `modernIntegratedRoofCapFillRectsV278` is `0` in normal V281 roof views.
  - `modernIntegratedRoofLocalBayProfileSafeV279` is `false`.
  - `modernIntegratedRoofDoorSpanProjectedV280 > 0` when a real door-bearing roof is in view.
  - V281 fallback counters are sane where primitive preflight rejects.
  - `roofV266`, `roofV267`, `roofV273`, `roofV274`, and `roofV275` are `false`.
  - `roofSilhouetteMainOriginalRoofFillSkippedV267` is absent or `0`.
  - `realRoofGeometricEavePixelsV274` and `realEaveHandoffPixelsV275` are absent or `0`.
  - `realRoofUndersideEaveEnabledV272` is `false`.
  - `roofContinuityFillOwner2PixelsV277` is absent or `0` in accepted owner2 V281V views.

## Visual QA Poses

Use these debug poses only as legacy comparison probes. For current roof/eave proof, first derive poses from runtime `roofSegments` and the accepted owner envelope. Accept a listed pose only after `coordinate_offset_check` proves requested/effective pose, owner, zone, and `offset_delta` are coherent. Do not use HUD/display X alone when runtime/internal X is available.

- Critical reception west/south edge, east view: `setPlayerForDebug(64.99, 8.44, 1, 0)`
- Critical reception diagonal north-east: `setPlayerForDebug(64.99, 8.44, .7071, -.7071)`
- Critical reception diagonal south-east: `setPlayerForDebug(64.99, 8.44, .7071, .7071)`
- Reception outside south overhang: `setPlayerForDebug(64.99, 9.60, 1, 0)`
- Bath owner 2 south side: `setPlayerForDebug(99, 71, 0, -1)`
- Bath owner 2 east side: `setPlayerForDebug(106.5, 65, -1, 0)`
- Bath owner 2 west side: `setPlayerForDebug(88, 65, 1, 0)`

For each pose:

- Wait at least two animation frames after setting the pose.
- Run `coordinate_offset_check` when there is certainty or legitimate doubt that the target is PERLA1 and the visual conclusion depends on coordinates: compare requested/effective pose, direction requested/effective, expected/observed zone, expected/observed tile or owner, known offset, `offset_delta`, coordinate confidence, and `false_coordinate_suspicion`.
- Capture the `#screen` canvas.
- Run `hud_contamination_check` for screenshots used as world/render proof: HUD, clock, minimap, controls, status text, debug overlays, and browser UI must not cover or be confused with the roof/eave target area. If the screenshot is intentionally UI/HUD QA, label it separately.
- Run `roof_visual_matrix_hard_gate` for roof/eave claims: `roof_matrix_declared_before_patch`, runtime/internal coordinate source, HUD/display X recorded separately, owner envelope, `same_coordinate_distance_rotation_grid`, far/close/east/west/interior-or-portal/user-repro groups as applicable, contact sheet or indexed matrix, `visual_qa_auditor_required`, and `matrix_failed_replan_not_ready` status.
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
