# PERLA1 Agent Guide

Scope: this file applies to the whole repository. More specific `AGENTS.md` files in subfolders override or extend these rules.

## Project Shape

- The playable runtime is `01_GIOCO_PRONTO_LOCAL_TEST/index.html`.
- The Windows launcher is `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`, which calls `AVVIA_GIOCO_SERVER_POWERSHELL.ps1` on `http://127.0.0.1:8000/`.
- The Codex/headless launcher is `AVVIA_GIOCO_CODEX_HEADLESS.ps1`. Agents should use it through `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher` or direct `-Serve` startup for deterministic runtime validation without opening a browser window.
- Files under `report/` are diagnostics, snapshots, extracted scripts, and historical evidence. They are not the runtime unless a task explicitly says otherwise.
- `PERLA1_PROJECT_MAP.md` is the compact technical map of structure, engine flow, dependencies, validation, and known critical risks.
- `PERLA1_BLOCK_MAP.md` is the block-level ownership map for the monolithic runtime.
- `PERLA1_CONTEXT_BUDGET.md` defines how agents inspect the monolithic runtime without flooding the Team Leader context.
- `PERLA1_SYMBOL_INDEX.md` is a verified orientation index for current high-value runtime symbols. It is not a substitute for reading code before patching.
- `PERLA1_TASK_INTAKE_PROTOCOL.md` is the startup gate for selecting and forcing the relevant agents for meaningful tasks.
- `PERLA1_RUNTIME_TEST_RUNBOOK.md` is the practical runtime validation guide for launcher/server/browser/screenshot testing on this Windows setup.
- `.codex/ORCHESTRATION.md` defines the project-scoped multi-agent workflow and anti-paradox rules.
- `tools/perla_runtime_analyzer.mjs`, `tools/perla_local_ci.ps1`, `tests/perla_regression_suite.json`, `PERLA1_MODULARIZATION_PLAN.md`, and `01_GIOCO_PRONTO_LOCAL_TEST/src/` form the `tooling-ci` scaffold for static structure analysis and controlled modularization planning. `src/` is scaffold-only until a scoped extraction is approved and validated.
- The complete project agent registry is maintained in `.codex/ORCHESTRATION.md`, `PERLA1_PROJECT_MAP.md`, and `PERLA1_TASK_INTAKE_PROTOCOL.md`; this file defines global behavior rules and does not duplicate every agent role.


## GitHub Sync Workflow

- The active synchronized project path is `PERLA1/` inside the Git repository root `codex/`.
- The parent `codex/` folder contains the user-facing sync scripts: `00_APRI_PERLA1.bat`, `01_AGGIORNA_PROGETTO_PRIMA_DI_LAVORARE.bat`, and `02_SALVA_PROGETTO_SU_GITHUB.bat`.
- Prefer working in the synchronized GitHub copy, not in older standalone copies under `Documents/`.
- When providing user-facing file paths, use the synchronized GitHub copy when available.
- After meaningful work, ensure the user knows to run `02_SALVA_PROGETTO_SU_GITHUB.bat`, or handle commit/push if explicitly asked.
- Do not hard-code absolute user-specific clone paths into runtime or sync scripts; scripts should stay relative to their own location.

## Default Workflow

- Read `PERLA1_PROJECT_MAP.md` early when the task touches runtime structure, renderer order, roofs/ceilings, sprites, rain, minimap, dependencies, validation, or historical failure modes.
- Read `PERLA1_BLOCK_MAP.md` early when the task touches the monolithic runtime or crosses renderer/data/launcher blocks.
- Read `PERLA1_CONTEXT_BUDGET.md` and `PERLA1_SYMBOL_INDEX.md` early when working on `index.html` or when coordinating subagents on monolithic code.
- Read `PERLA1_TASK_INTAKE_PROTOCOL.md` before meaningful code edits, runtime validation, multi-agent work, or refactor planning.
- Read `PERLA1_RUNTIME_TEST_RUNBOOK.md` before attempting rendered/browser validation.
- For meaningful runtime or `tooling-ci` changes, run `tools/perla_local_ci.ps1` when practical. Use a `-ReportPath` outside the repo unless the user explicitly asks to promote the generated structure report.
- For meaningful workflow-policy, TOML, AGENTS, hook, launcher/sync, or agent-rule changes, run `tools/perla_codex_workflow_check.ps1 -Mode CI -Json` when practical. This is the deterministic local enforcement check for machine-readable workflow drift evidence.
- Use `tools/perla_project_backup.ps1` for project backups. It backs up the full synchronized repository folder `C:\Users\ASUS\Documents\GitHub\codex` as a timestamped zip, excluding only `PERLA1\01_GIOCO_PRONTO_LOCAL_TEST\assets\rtp`. When the user orders a backup, record `backup_user_requested` and run `-Kind User` before the next protected step. At the end of every meaningful task, record `automatic_task_backup` and run `-Kind Automatic` before final delivery when filesystem permissions allow it; if approval is needed and unavailable, report `backup_not_created_permission_blocked`.
- Read the relevant code before proposing a fix.
- Prefer focused patches over broad rewrites.
- Use `apply_patch` for manual edits.
- Keep user changes; do not revert unrelated work.
- For runtime behavior changes, update the visible build id/name in `index.html` and launcher labels when appropriate.
- Do not trust `file://` for final validation. Test through the local server route used by the user.
- After meaningful work, update `PERLA1_PROJECT_MAP.md` and/or `PERLA1_BLOCK_MAP.md` if the change affects structure, engine flow, dependencies, validation, current patch contracts, block ownership, or recurring risks.

## Codebase Chunking And Multi-Agent Orchestration

- Treat `01_GIOCO_PRONTO_LOCAL_TEST/index.html` as a monolithic runtime split into functional blocks documented in `PERLA1_BLOCK_MAP.md`.
- Before patching runtime code, name the impacted block ids and avoid touching unrelated blocks.
- The Team Leader owns coordination, integration, final validation claims, and the user-facing answer.
- Read-only auditors may inspect any block but cannot approve write work as complete.
- `safe-fixer` is the only general runtime write agent and may patch `tooling-ci` files only when that non-runtime scope is explicit and narrow.
- `refactor-surgeon` is an emergency write agent for documented blockage only. It may plan or apply the minimum demonstrably sufficient reversible refactor, but it must start in `REFACTOR_PLAN_ONLY` unless explicit approved scope is provided.
- `map-maintainer` may update only `PERLA1_PROJECT_MAP.md`, `PERLA1_BLOCK_MAP.md`, `PERLA1_CONTEXT_BUDGET.md`, `PERLA1_SYMBOL_INDEX.md`, and `PERLA1_TASK_INTAKE_PROTOCOL.md`; it must not edit runtime code, `.codex/agents/*.toml`, `.codex/config.toml`, `.codex/ORCHESTRATION.md`, or `AGENTS.md`.
- Extra temporary agents are allowed only for concrete gaps not covered by configured agents. They start read-only by default and need explicit file/block ownership before any write task.
- A write agent cannot validate its own patch as complete. Final readiness requires Team Leader review or separate read-only validation.
- If two agents would write the same file or block, serialize the work instead of running them in parallel.
- If orchestration rules conflict, follow the stricter rule and use `workflow-guard` to return `STOP` before continuing.
- Before operational work that touches a versioned runtime contract, check that relevant `.codex/agents/*.toml` instructions still match `PERLA1_PROJECT_MAP.md` and `PERLA1_BLOCK_MAP.md`. If a TOML preserves stale contract authority, fix it or get an explicit user-approved derogation before patching, validating, refactoring, or syncing.
- Use `workflow-guard` as a circuit breaker when a method fails twice, when a known deterministic tool failure appears, or when the next step would not produce new evidence.
- Use `workflow-consistency-auditor` for every explicit Agent Selection Gate. It can run a lightweight gate audit for ordinary tasks and must run a full audit when workflow docs, TOML agents, gate rules, orchestration, AGENTS hierarchy, or permissions change.
- Use `plan-integrity-auditor` before executing explicit multi-step plans, user-approved plans, delicate patch plans, rollback/refactor strategies, alternatives-based route choices, or plans that change validation requirements, runtime contracts, or agent/workflow rules.
- For delicate runtime, rollback, failed-patch, validation, launcher, sync, workflow-policy, AGENTS, TOML, orchestration, refactor, or user-escalated work, use the Standing Guard Set from `PERLA1_TASK_INTAKE_PROTOCOL.md` before the first operational patch, runtime validation, sync, or refactor.
- Use `task-watchdog` for long-running work, repeated no-evidence cycles, checkpoint decisions, and user stop conditions. It tracks `task_id`, `operation_id`, and `logical_step_id`.
- Enforce the whole-task safety cap: one `task_id` may run for at most 5h wall-clock time unless the user explicitly grants a new budget. At 4h30m call `task-watchdog` for handoff preparation; at 5h stop at the last completed checkpoint with `STOP_FOR_USER`.
- Maintain a workflow heartbeat per `operation_id` or `logical_step_id`: simple comparisons/small audits must checkpoint after 12 minutes without evidence; complex runtime/workflow/subagent/browser work must checkpoint after 21 minutes without evidence. This is not a cap on the whole task when checkpoints produce evidence.
- At a heartbeat checkpoint, call `task-watchdog`; also call `workflow-guard` if the next step repeats the same method, waits on an unknown state, follows a known failing path, or cannot say what new evidence it will produce.
- Do not treat `workflow-guard` as a magic background daemon. Treat it as an enforced checkpoint gate that must be called before continuing when its triggers fire.
- Before retrying after a timeout or deterministic tool failure, record checkpoint evidence: task/operation/logical ids, elapsed time, method tried, evidence gained, next proof target, retry count, allowed next action, and forbidden next action.
- At the 5h cap, do not start new operational work and do not continue merely to finish the current operation. Report last completed checkpoint, partial/unverified work, validation status, and requested new budget.
- Do not let broad `rg`, diff, or search output from `index.html` consume the Team Leader turn. Narrow to target symbols/functions/blocks and report actionable evidence only.
- For complex, high-risk, delicate, multi-agent, runtime, workflow, refactor, failed-patch recovery, or long tasks, use the Complex Task Accelerator Protocol in `PERLA1_TASK_INTAKE_PROTOCOL.md`: define `accelerator_brief`, `cheapest_discriminating_test`, `critical_path`, `sidecar_tasks`, `serial_constraints`, `validation_ladder`, `checkpoint_ledger`, and `subagent_task_packet` before expensive work. This accelerates by reducing wasted work; it does not skip `CALL` agents, heartbeat checkpoints, validation, write boundaries, or user approvals.
- When a sidecar agent or parallel tool returns, use the Sidecar Result Integration Protocol before changing the active plan: record `sidecar_result_integration`, `result_status`, `affects_critical_path`, `dependency_on_critical_path`, `accepted_into_plan`, `integration_decision`, `validation_impact`, `write_scope_impact`, `approval_impact`, `heartbeat_checkpoint`, `stop_condition_triggered`, `discard_or_defer_reason`, and `ledger_update`. Sidecar results are evidence inputs, not approvals; they cannot authorize writes, lower validation, satisfy missing `CALL` agents, or block the `critical_path` without an explicit dependency.
- When the user sends a message during active/long/delicate work, use the User Intake Relay Protocol before the next protected step: record `user_message_intake`, `user_message_id`, `message_class`, `must_interrupt`, `must_report_to_team_leader`, `checkpoint_required`, `user_intent_summary`, `conflicts_current_plan`, `changes_scope`, `changes_validation`, `changes_write_scope`, `approval_impact`, `agent_gate_impact`, `agent_tool_mapping_impact`, `critical_path_impact`, `sidecar_integration_impact`, `decision`, `ledger_update`, `relay_note`, `next_action`, `forbidden_next_action`, and `response_due`. This is classification and relay evidence only, not a persistent background listener and not approval authority.
- For any delegated work, track `subagent_task_lifecycle`. Close subagents at Team Leader task completion, or earlier only when the assigned packet is fully integrated, obsolete, stale, aborted, or unsafe. Do not close a useful subagent merely because one internal step finished. Before closing, integrate/defer/discard its latest useful evidence through `sidecar_result_integration`.
- Before final delivery, staging, sync, or readiness claims, use `scoped_finalization`, `finalization_gate`, and `workflow_tooling_manifest`: list approved scope, in-scope changes, out-of-scope dirty worktree changes, generated/disposable artifacts, untracked workflow tooling, validation run, subagents to keep open/close, staging plan, `selective_staging_only`, `no_global_stage`, `sync_safe`, and residual risk.
- `finalization_gate` must include `project_backup_gate`: `backup_user_requested` status, `automatic_task_backup` status, backup path, excluded RTP path, and automatic retention result. Automatic backups are zip files under `C:\Users\ASUS\Documents\GitHub\backup\automatici`; retention may delete only files older than 2 days when the folder already contains more than 10 files. Never delete anything in `backup\utente` unless the user explicitly orders that deletion.
- A first long failure in the same operation or logical step may restart from the best checkpoint with a materially different plan. A second long failure in the same operation or logical step must stop for user approval.
- After three progressive failures or no-evidence cycles on the same `logical_step_id`, require a checkpoint and a failure brief before continuing.
- Use `skeptic-auditor` for complex, high-risk, uncertain, long-running, repeated, or refactor-adjacent work. It challenges the current plan and proposes grounded plan B/C alternatives, but does not block by itself.
- Use `refactor-surgeon` only after documented blockage, normally after `task-watchdog` returns `STOP_FOR_USER`/`ESCALATE` or `workflow-guard` returns `STOP`. If refactor requires crossing multiple blocks or a controlled derogation, surface the conflict and request approval instead of silently bypassing rules.
- Apply the Agent Selection Gate from `PERLA1_TASK_INTAKE_PROTOCOL.md`: all relevant domain agents must be marked `CALL`, `workflow-consistency-auditor` is always `CALL` for explicit gates, and `workflow-guard`, `plan-integrity-auditor`, `task-watchdog`, `skeptic-auditor`, and `refactor-surgeon` must always be at least considered.
- When the gate marks an agent as `CALL`, the agent must be invoked or delegated operationally. PERLA1 already has standing user authorization for configured project agents selected by the gate; do not downgrade them to passive consideration because a fresh user request was not asked.
- This standing project authorization is subordinate to the active Codex tool surface and higher-priority instructions. If the current tool surface requires explicit user delegation before spawning subagents, get that delegation or stop with `TOOLING_BLOCKED` before protected work.
- Before protected patching, rendered/runtime validation, sync, refactor application, or readiness claims, every required `CALL` agent needs `call_agent_evidence`: `satisfaction` must be `direct_invocation`, `generic_adapter`, or `tooling_blocked`; include `user_delegation_state`, `agent_tool_mapping_ref` for adapters, discovery/adapter attempts, and the output or blocked reason.
- `critical_path` is not a bypass for required agents. Run useful required sidecar agents while local critical-path work advances, and wait or stop when the specialist result protects the next step.
- `visual_qa_required` makes `visual-qa-auditor` `CALL` for screenshot, rendered/browser validation, or visible user-facing regression readiness claims. The Team Leader may collect screenshots/counters but must not be the only visual QA authority unless degraded fallback is explicit.
- `visual_pose_matrix_check` is mandatory for roof/eave/wall-occlusion/visibility work or any rendered bug that can change with camera rotation. Establish accepted base coordinates first, then compare multiple rotations from the same `x/y`; do not replace a failed rotation with a different coordinate.
- For roof/eave work, `roof_visual_matrix_hard_gate` is mandatory before patch readiness and must be declared before patching as `roof_matrix_declared_before_patch` unless the step is read-only diagnosis. Use current runtime/internal coordinates from debug/`roofSegments`, record HUD/display X separately, build a `same_coordinate_distance_rotation_grid` with far/close/east/west/interior-or-portal/user-repro groups as applicable, produce a contact sheet or indexed matrix, and treat missing/failed groups as `matrix_failed_replan_not_ready`.
- If Codex exposes only generic subagent tools such as `explorer` or `worker`, satisfy a named `CALL` agent through the Agent Tool Adapter rule: assign the exact named role, point to the matching `.codex/agents/<agent>.toml`, preserve the named agent's read/write scope, and record the mapping. A generic subagent without explicit role mapping is not enough.
- A generic `worker` may write only if the named TOML role permits writing and the Team Leader records explicit approved files/symbols/scope.
- If neither direct custom-agent invocation nor role-assigned generic subagent invocation is possible, the Team Leader may perform only the minimum read-only classification needed to report `TOOLING_BLOCKED`; it may not patch, validate runtime, sync, or apply refactors as if the gate passed. Do not declare `TOOLING_BLOCKED` while a faithful generic adapter is available.
- If subagent tooling is unavailable, use tool discovery if present, then apply the Agent Tool Adapter rule if generic subagents are available. Stop with `TOOLING_BLOCKED` only after direct invocation and valid generic-role adapter invocation are unavailable or materially unsafe. Do not pretend the gate passed.
- Context limits restrict what agents paste back into the Team Leader thread, not what they may inspect in the repository. Agents may read deeper into `index.html` when a concrete hypothesis, cross-block dependency, or Team Leader request requires it.
- Agents must report read scope and evidence compactly instead of dumping large raw extracts.
- Root `.codex/hooks.json` can run `tools/perla_codex_workflow_check.ps1` at Codex lifecycle events after hook trust review. This is lifecycle enforcement, not proof that project agents run continuously in the background.
- Before relying on hooks, record `hook_trust_check`; if Codex trust is unknown, report hooks as configured but not proven active and use manual workflow checker output plus required guard/audit evidence. Keep `checker_semantic_limit` explicit: the checker catches deterministic drift, not all plan semantics, visual behavior, user intent, or agent reasoning quality.

## Required Validation For Game Changes

Before saying a rendered game fix is ready:

- Run local static CI through `tools/perla_local_ci.ps1` or an equivalent inline JavaScript parse check and regression-suite analyzer path.
- Treat static CI as structure evidence only. It does not replace rendered/browser validation for visual or runtime behavior changes.
- For Codex/agent validation, start the PERLA1 local server with `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher`, which uses `AVVIA_GIOCO_CODEX_HEADLESS.ps1` internally and stops only the PID it created after validation.
- For manual user play, `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat` remains the user-facing launcher.
- Or explicitly confirm an existing PERLA1 server is already responding on `http://127.0.0.1:8000/`.
- Do not try to validate the runtime by opening `index.html` directly, by using `file://`, or by opening a browser before the local server is running.
- Prefer the proven automated screenshot path in `PERLA1_RUNTIME_TEST_RUNBOOK.md`: `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` with system Chrome/Edge through Playwright.
- Load `http://127.0.0.1:8000/` with a cache-busting query string.
- Confirm `window.PERLA_BUILD_ID` matches the edited build.
- Check browser console/page errors.
- Capture screenshots for the exact visual risk area.
- For every screenshot used as world/render visual proof, record `hud_contamination_check`: HUD, clock, minimap, touch controls, debug overlays, browser UI, and status text must not cover or be confused with the target visual area. If the screenshot is intentionally UI/HUD QA, state that separately instead of treating HUD as renderer contamination.
- For PERLA1 coordinate-dependent validation, record `coordinate_offset_check` when there is certainty or legitimate doubt that the target is PERLA1 and coordinates/poses affect the conclusion. Compare requested pose, effective pose, direction requested/effective, expected/observed zone, expected/observed tile or owner, known offset, `offset_delta`, coordinate confidence, and `false_coordinate_suspicion` before accepting the pose as proof.
- For `visual_pose_matrix_check`, include screenshot path, `hud_contamination_check`, `coordinate_offset_check`, direction, relevant counters, and visual result for each rotation. Same-coordinate rotations must be consistent in roof volume/occlusion class unless a geometry reason is documented.
- For roof/eave validation, include `roof_visual_matrix_hard_gate`, `roof_matrix_declared_before_patch`, runtime/internal coordinate source, HUD/display X handling, owner envelope, `same_coordinate_distance_rotation_grid`, contact sheet or indexed matrix, `visual_qa_auditor_required`, and `matrix_failed_replan_not_ready` status before any success claim.
- Inspect screenshots visually; metrics alone are not enough.
- Read `perlaLastDrawStats()` or the relevant public debug summary for draw/roof counters.

## Runtime Browser Method

- The reliable Windows method currently is: `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher ...` for automated screenshots and debug counters. This starts the Codex headless server when needed.
- Browser automation is useful only after the PERLA1 server is running. If `http://127.0.0.1:8000/` is not responding, agents should use `-StartLauncher`; only hand off `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat` to the user for manual play or when headless startup fails.
- Codex in-app Browser is allowed as an extra attempt, but on this Windows setup it has repeatedly failed before navigation with `CreateProcessAsUserW failed: 5`.
- Do not loop through known-failing methods. If in-app Browser fails with a sandbox/permission error, immediately use the headless script or provide a manual handoff.
- Keep the target URL identical across methods: `http://127.0.0.1:8000/` plus the same cache-busting query string.
- Manual validation handoff must include the exact URL, expected `window.PERLA_BUILD_ID`, debug poses, screenshots to capture, console checks, and counters/API calls to read.
- Do not claim a rendered fix is fully validated unless the screenshot evidence and relevant counters were actually inspected.

## Performance And Regression Rules

- Do not re-enable expensive legacy roof/fill paths unless the user explicitly asks and the cost is measured.
- If a previous path was disabled for draw cost, keep it off until a measured replacement proves safe.
- Any visual fix near roofs, ceilings, rain cover, sprites, or wall occlusion must include both visual proof and draw/counter proof.
- Avoid adding full-screen or full-roof raster passes as a quick visual patch.
- If a fix increases draw work, explain the exact source and provide before/after counters.

## Communication

- Be direct about root cause, especially after a failed visual patch.
- Distinguish diagnosis from proof.
- When the user is testing locally, give the exact file/path/URL they should use.
- If Browser automation fails, report the fallback method and keep the target URL identical.


