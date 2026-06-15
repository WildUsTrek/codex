# PERLA1 Runtime Test Runbook

Last updated: 2026-06-14

This is the practical runtime validation path that worked on the Windows Codex desktop setup after repeated failed attempts. Use this before trying slower or less reliable browser paths.

## Correct Test Path

For rendered runtime validation, the reliable sequence is:

1. Run local static CI when code changed: `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\tools\perla_local_ci.ps1`.
2. Start or confirm the PERLA1 server.
3. Load the URL printed by `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` with its cache-busting query string. It is normally `http://127.0.0.1:8000/`, but may be a fallback port when `8000` is blocked.
4. Use the debug API to set deterministic player poses.
5. Capture the `#screen` canvas.
6. Inspect the screenshot visually and read relevant counters.

The runtime is not validly tested through `file://` or by opening `index.html` directly.

## Backup Commands

Use the backup tool from the repository root or from any PERLA1-aware shell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\tools\perla_project_backup.ps1 -Kind User
powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\tools\perla_project_backup.ps1 -Kind Automatic
```

The tool backs up the full synchronized repository folder:

```text
C:\Users\ASUS\Documents\GitHub\codex
```

It excludes only:

```text
C:\Users\ASUS\Documents\GitHub\codex\PERLA1\01_GIOCO_PRONTO_LOCAL_TEST\assets\rtp
```

Output is a timestamped zip file. User backups go to `C:\Users\ASUS\Documents\GitHub\backup\utente` and are never automatically deleted. Automatic task backups go to `C:\Users\ASUS\Documents\GitHub\backup\automatici`; before writing a new automatic backup, retention may delete only files older than 2 days and only if that folder already contains more than 10 files. It never deletes backup folders.

## Server Startup

Codex/agent startup entry point:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher -X 44.5 -Y 74.5 -Dx 0 -Dy 1
```

`-StartLauncher` starts:

```text
AVVIA_GIOCO_CODEX_HEADLESS.ps1
```

in internal `-Serve` mode. It does not open a browser window, writes `AVVIO_GIOCO_CODEX_HEADLESS_LOG.txt`, `AVVIO_GIOCO_CODEX_HEADLESS_PID.txt`, and `AVVIO_GIOCO_CODEX_HEADLESS_READY.txt`, and the validator stops the PID it created after validation.

The validator has the Codex fast path built in. It first tries port `8000`; if that port does not respond or cannot be bound, it automatically tries `8787`, `8081`, `5179`, `9001`, and `43210`. Do not repeat manual port probing or ad hoc Python `http.server` attempts before using this command. With `-StartLauncher`, the validator may reuse an already responding server only on the requested port; already-running fallback-port servers are skipped so stale fallback sessions are not silently used as fresh proof.

Server cleanup rule: `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher` stops and verifies the PID it created before exiting. It does not kill a pre-existing manual/user server or an already-running requested-port server, because that process may belong to the user. At finalization, if no manual PERLA1 play session should remain open, check the known PERLA ports and close only recognized PERLA/Codex server processes.

Manual user startup entry point:

```text
AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat
```

This launcher calls:

```text
AVVIA_GIOCO_SERVER_POWERSHELL.ps1
```

and serves:

```text
http://127.0.0.1:8000/
```

Before browser validation, confirm the server:

```powershell
Invoke-WebRequest -Uri 'http://127.0.0.1:8000/?health_codex=1' -UseBasicParsing -TimeoutSec 2
```

If the server is not responding and the agent cannot launch the Codex headless path with `-StartLauncher`, stop and hand off: ask the user to run `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat` for manual validation.

Agents should not launch the user `.bat` hidden for automated validation. Use `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher` first. Use the user `.bat` only for manual handoff or when the headless launcher fails.

## Known Reliable Screenshot Method

Use the helper script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -X 44.5 -Y 74.5 -Dx 0 -Dy 1
```

If no server is already responding, add `-StartLauncher`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher -X 44.5 -Y 74.5 -Dx 0 -Dy 1
```

If a specific port is needed, pass it explicitly. The fallback list still applies after the requested port:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher -Port 43210 -X 44.5 -Y 74.5 -Dx 0 -Dy 1
```

Default output goes to:

```text
%TEMP%\perla_runtime_screenshot.png
```

Example for the south beach:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -X 44.5 -Y 74.5 -Dx 0 -Dy 1 -OutputPath "$env:TEMP\perla_south_beach.png"
```

Run it from the `PERLA1/` directory, or pass the script path from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -X 44.5 -Y 74.5 -Dx 0 -Dy 1 -OutputPath "$env:TEMP\perla_south_beach.png"
```

Do not run the `.ps1` directly with `.\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` on locked-down Windows sessions. It can fail with:

```text
L'esecuzione di script è disabilitata nel sistema in uso.
```

Use `powershell -NoProfile -ExecutionPolicy Bypass -File ...`, matching the launcher style.

This method uses:

- the PERLA1 Codex headless launcher/server on `127.0.0.1:8000` when `-StartLauncher` is used,
- automatic fallback to `127.0.0.1:8787`, `8081`, `5179`, `9001`, or `43210` when `8000` is blocked,
- bundled Codex Node.js,
- bundled Playwright packages with explicit `NODE_PATH`,
- installed system Chrome at `C:\Program Files\Google\Chrome\Application\chrome.exe`, with Edge fallback.

Why this method exists:

- raw `require('playwright')` from the repository can fail with `Cannot find module 'playwright'`;
- bundled Playwright can fail to launch its own browser if `ms-playwright\chromium_headless_shell-*` is missing;
- using system Chrome through Playwright avoids the missing bundled browser download;
- screenshots are written outside Git by default.

## Known-Failing Or Secondary Methods

Do not spend repeated attempts on these before using the reliable method above:

| Method | Status / Failure |
| --- | --- |
| Opening `index.html` directly | Invalid for final validation; bypasses the launcher/server route. |
| `file://` | Invalid for final validation and can hide server/cache/runtime issues. |
| Browser before server startup | Fails before testing the game. Start or confirm the launcher/server first. |
| Launching the user `.bat` hidden from Codex | Fragile: it is interactive and may open a browser or block before useful logs. Use `AVVIA_GIOCO_CODEX_HEADLESS.ps1` through `-StartLauncher`. |
| Codex in-app Browser on this Windows setup | Known failure: `CreateProcessAsUserW failed: 5`. Treat as tooling failure, not runtime failure. |
| Playwright without explicit `NODE_PATH` | Can fail with `Cannot find module 'playwright'`. |
| Playwright bundled browser without system Chrome | Can fail because the Playwright browser executable is not installed. |
| Running the helper `.ps1` directly | Can fail under Windows execution policy. Use `powershell -NoProfile -ExecutionPolicy Bypass -File ...`. |
| Manual port probing before the headless validator | Obsolete for Codex validation. The validator already has the known fallback ports. |

These methods may be retried only as secondary options if the reliable method stops working or if the user specifically asks to test that browser path.

## Loop Breaker Rule

If the same validation method fails twice without new evidence, stop and consult `workflow-guard`. If validation becomes a long task with repeated no-evidence cycles, also consult `task-watchdog`.

Stop immediately instead of retrying when the failure is already known and deterministic:

- `CreateProcessAsUserW failed: 5` from Codex in-app Browser;
- `Cannot find module 'playwright'` without changing `NODE_PATH`;
- missing `chromium_headless_shell` without switching to system Chrome/Edge;
- Windows execution policy blocking direct `.ps1` execution;
- the selected validation URL is not responding because the launcher/server is not running.

The next attempt must materially change the method: use `-StartLauncher`, start the Codex headless server, fix `NODE_PATH`, switch browser executable, use `ExecutionPolicy Bypass`, or hand off manual validation. Do not keep retrying the same command.

## Required Evidence

For a rendered fix to be called validated, collect:

- exact URL with cache-busting query string,
- `window.PERLA_BUILD_ID`,
- pose used via `window.__PERLA_DEBUG__.setPlayerForDebug(...)`,
- `coordinate_offset_check` when there is certainty or legitimate doubt that the validation target is PERLA1 and the conclusion depends on a pose, map location, or coordinate-derived screenshot,
- screenshot of `#screen`,
- `hud_contamination_check` for any screenshot used as visual evidence,
- console/page errors,
- `window.__PERLA_DEBUG__.perlaLastDrawStats()` or the relevant debug summary,
- `visual_pose_matrix_check` when the result depends on roof/eave/wall occlusion, camera angle, distance, visibility, or another rotation-sensitive visual behavior,
- visual inspection result.

Do not claim full rendered validation from a successful page load alone.

## HUD Contamination Check

Use `hud_contamination_check` for every screenshot used as rendered PERLA1 evidence.

Record:

```text
hud_contamination_check:
  screenshot_path:
  viewport:
  target_visual_area:
  hud_visible: yes/no
  hud_elements: clock/minimap/controls/status_text/debug_overlay/other
  hud_overlaps_target: yes/no
  contamination_level: none/low/medium/high
  action: accept/crop/retry_different_viewport/report_ui_layout_risk/reject_as_visual_proof
  notes:
```

Rules:

- HUD, clock, minimap, touch controls, debug overlays, browser UI, and status text must not be mistaken for renderer geometry.
- If HUD elements cover the roof/wall/rain/sprite/minimap area being judged, the screenshot is degraded evidence. Crop, retry with a different viewport/pose, or report `report_ui_layout_risk`.
- If HUD overlap happens only on smartphone or a specific browser/viewport, classify it as a UI/viewport validation risk, not as proof that the renderer itself is broken.
- A screenshot may still be useful when HUD is visible but outside the target visual area. Record that explicitly.

## Coordinate Offset Check

Use `coordinate_offset_check` whenever there is certainty or legitimate doubt that the target is PERLA1 and the conclusion depends on coordinates, deterministic poses, debug placement, map cells, or screenshot location.

Record:

```text
coordinate_offset_check:
  target_project: PERLA1/unknown/other
  trigger: certain_perla1/legitimate_doubt_perla1/coordinate_dependent_validation
  requested_pose:
    x:
    y:
    dx:
    dy:
    direction_requested:
  effective_pose:
    x:
    y:
    dx:
    dy:
    direction_effective:
  expected_zone:
  observed_zone:
  expected_tile_or_owner:
  observed_tile_or_owner:
  known_offset_applied:
  offset_delta:
  coordinate_source: user/debug_api/test_suite/manual/inferred
  coordinate_confidence: high/medium/low
  suspicious_coordinates: yes/no
  false_coordinate_suspicion: yes/no
  action: accept/adjust_and_retry/inspect_map_or_debug_api/reject_pose_as_proof
```

Rules:

- Do not assume a screenshot proves the intended location until requested pose, effective pose, direction, and observed zone are coherent.
- If the scene does not match the expected map/owner/zone, mark `suspicious_coordinates: yes` and inspect the map/debug API or retry with adjusted coordinates before drawing visual conclusions.
- The check is not required for unrelated non-PERLA work. It is required when the agent is certainly working on PERLA1, or when there is legitimate doubt that the evidence might be PERLA1 and coordinate/pose correctness affects the conclusion.
- If an offset is known or suspected, state whether it was applied and what evidence supports it.

## Visual Pose Matrix Check

Use `visual_pose_matrix_check` for PERLA1 rendered bugs where a single good screenshot can hide failure at the same coordinate under another rotation. It is mandatory for roof/eave/wall-occlusion/visibility validation.

For roof/eave work, also run `roof_visual_matrix_hard_gate`. The gate is not optional and must be declared before patching as `roof_matrix_declared_before_patch`. It exists because roof failures have repeatedly passed from a long-distance screenshot while failing from the same coordinate under another rotation, from close distance, from east/west lateral angles, or from the interior/portal view.

Record:

```text
visual_pose_matrix_check:
  target_visual_system:
  reception_roof_real_objective_gate:
  objective_match_verdict: pass/fail/degraded
  objective_mismatch_notes:
  coordinate_selection_method: debug_api/map_scan/roofSegments/user_pose/other
  accepted_base_coordinates:
  rejected_coordinates:
  fixed_coordinate_groups:
    - base_pose:
      expected_zone:
      expected_tile_or_owner:
      rotations:
        - direction_name:
          dx:
          dy:
          screenshot_path:
          hud_contamination_check_ref:
          coordinate_offset_check_ref:
          counters:
          visual_result: pass/fail/degraded/reject
  same_coordinate_rotation_consistency: pass/fail
  required_specialist: visual-qa-auditor
  specialist_result_ref:
  roof_visual_matrix_hard_gate:
    roof_matrix_declared_before_patch: yes/no
    same_coordinate_distance_rotation_grid: pass/fail
    runtime_internal_coordinate_source:
    hud_display_coordinate_recorded: yes/no
    roof_owner_envelope:
    required_groups_completed:
    contact_sheet_path:
    matrix_failed_replan_not_ready: yes/no
    visual_qa_auditor_required: yes/no
    user_review_pause_required: yes/no
    user_review_package:
  action: accept/retry_matrix/replan/stop
```

Rules:

- Establish accepted base coordinates before taking screenshots. Use debug API, map/owner checks, `roofSegments`, and `collectPerlaDebugSnapshot()`; reject poses where `wallType`, target owner, zone, or foreground occluders make the screenshot non-diagnostic. For roof work, record both the runtime/internal coordinate (`posXActual` when exposed) and the HUD/display coordinate; never validate from HUD X alone.
- For each accepted base coordinate, rotate from the exact same `x/y`. Do not replace a failed close rotation with a different coordinate and call it equivalent.
- Minimum roof/eave matrix: a declared `same_coordinate_distance_rotation_grid` with far/mid frontal exterior, close exterior or portal threshold, west lateral, east lateral, and every user-reported repro coordinate. Add interior/inside-looking-out when ceiling, rain cover, portal underside, or roof-inside behavior changed. Add very-close near-plane when the user reports disappearance while approaching. If the bath is in scope, run the same owner-specific grid for bath; if bath is explicitly out of scope, record it as deferred and do not claim bath readiness.
- For each base group, use same-coordinate rotations: center, left-oblique, right-oblique at minimum. For roof fixes, prefer five rotations where diagnostic: center, NNE/NNW or equivalent left/right, and east/west graze for lateral/portal groups. Interior ceiling groups should include north, south, east, west, and diagonal checks when the ceiling can change with camera direction.
- Capture canvas-only `#screen` images or prove HUD/minimap/clock do not overlap the target visual area. A screenshot contaminated by the clock, minimap, status text, browser chrome, or controls over the target roof/ceiling/portal area is `reject_as_visual_proof`, not a pass.
- Produce a contact sheet or matrix index before a readiness claim. Every tile must label group id, requested pose, effective internal pose, HUD/display X, direction, target owner/envelope, key counters, and visual result. Single screenshots or unlabelled piles of images are automatic partial evidence only.
- Put counters next to every screenshot. For V281 roof work, record `modernStableRoofPrimitiveFacesDrawnV281`, `modernStableRoofPrimitivePixelsV281`, `modernStableRoofPrimitiveBudgetHitV281`, `modernStableRoofPrimitiveWarnPixelsV281`, `modernStableRoofPrimitiveSkippedTopFacesNearDoorV281`, `modernStableRoofPrimitiveRejectedNearFacesV281`, `modernStableRoofPrimitiveSuppressedTopEdgeLinesV281`, `modernStableRoofPrimitiveSameOwnerWallBodyRejectedV281`, `modernIntegratedRoofCapPixelsV278`, and `modernStableRoofPrimitiveHybridViolationV281`.
- For V282 reception portal/ceiling work, also record portal and slab counters when present: `modernInteriorRoofPortalUndersidePixelsV282`, `modernInteriorRoofPortalUndersideFacesV282`, `modernInteriorRoofSlabPixelsV282`, `modernInteriorRoofSlabOwner1CellsV282`, and any same-owner wall/body rejection counters used by the changed path.
- If one rotation from the same coordinate loses roof volume, front gable, ridge/colmo, top faces, or interior slab; hits budget while another does not; changes face count without a geometry reason; shows a dotted/broken border; draws a forced black seam line; paints through a wall/door/opening; or depends on a skipped top-face path, mark the matrix `fail` and replan before claiming readiness.
- `plan-integrity-auditor` must reject roof plans that do not declare this matrix before the first patch. `visual-qa-auditor` must reject readiness if the matrix is missing, partial, contaminated, or evaluated only by the Team Leader. `workflow-guard` must stop after repeated roof visual failures when the next attempt does not change the validation matrix or the rendering hypothesis.

Roof readiness wording:

- Say `validated` only when all required matrix groups pass, the contact sheet/index exists, counters agree with the screenshots, legacy/fallback masking is off, and the visual QA result is accepted.
- Say `not fully validated` when any group is missing, deferred, degraded, or failed. Do not soften a missing same-coordinate rotation into a warning.
- Say `matrix_failed_replan_not_ready` when the same coordinate changes roof volume, colmo/ridge visibility, ceiling authority, or budget state across rotations.

Reception roof real objective wording:

- For reception owner `1`, say `validated` only when `reception_roof_real_objective_gate` passes. Coordinate checks, HUD checks, counters, and contact sheets only make evidence admissible; they do not prove the roof is correct.
- Say `reception_roof_objective_failed` when the roof is present but still does not read as a high pointed exterior roof, loses or flattens front colmo/gable/top faces under rotation, shows exterior roof/gable geometry inside the portal where flat monocolor ceiling/underside is expected, or uses fake seams/bands/color-family switches.
- Say `partial_visual_improvement_only` when one symptom is fixed, such as a black line removed or a single rotation stabilized, while any real objective bullet remains wrong.
- Before a near-success or success claim, stop for user review with `user_review_pause_required: yes` and provide the contact sheet, 3-6 full-size decisive screenshots, coordinate mapping, degraded-shot notes, and a per-objective self-verdict. Do not continue to broad iteration or readiness until the user has had a chance to reject the visual result.

## Local Static CI

Before screenshot validation after meaningful runtime edits, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\tools\perla_local_ci.ps1
```

This performs inline JavaScript parse validation, required build/symbol/function checks, static block classification, and focused dependency graph generation through `tools/perla_runtime_analyzer.mjs`.

To include the smoke poses declared in `tests/perla_regression_suite.json`, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\tools\perla_local_ci.ps1 -RuntimeScreenshots
```

Static CI is not a substitute for rendered visual proof when the renderer, roof, rain, sprites, minimap, launcher, or performance-sensitive paths change.
