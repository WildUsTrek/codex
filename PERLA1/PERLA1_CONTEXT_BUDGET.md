# PERLA1 Context Budget Protocol

Last updated: 2026-06-14

This file defines how agents should work on the PERLA1 monolithic runtime without saturating the Codex context window.

## Core Rule

Context budget limits what an agent copies back into the Team Leader thread. It does not limit what an agent may inspect in the real repository when that inspection is useful for the task.

Agents may read deeper into `01_GIOCO_PRONTO_LOCAL_TEST/index.html` when there is a concrete reason: a symbol spans a large function, a renderer path crosses blocks, a contract is uncertain, a bug depends on call order, or the Team Leader asks for a deeper pass.

## Reading Model

For monolithic runtime work, use progressive disclosure:

1. Orientation: read `AGENTS.md`, `PERLA1_PROJECT_MAP.md`, `PERLA1_BLOCK_MAP.md`, this file, `PERLA1_SYMBOL_INDEX.md`, and `PERLA1_TASK_INTAKE_PROTOCOL.md`.
2. Search: use `rg` for symbols, contracts, build ids, debug hooks, counters, and block boundaries.
3. Local read: inspect the function, helper, or data block around the matching symbol.
4. Extended read: inspect related callers, callees, buffers, and validation hooks when the local window is not enough.
5. Automation: use `tools/perla_runtime_analyzer.mjs` or equivalent full-file parse/search/indexing when function maps, dependency graphs, or block summaries reduce risk. Do not paste full-file output or full dependency graphs into the main thread.

Line-window sizes are defaults, not hard safety limits. If 120 lines are insufficient, read more. The safety rule is to report compact evidence, not to remain under-informed.

## Reporting Model

Agent handoffs should include enough detail for the Team Leader to decide the next step:

- files read;
- symbols and line hints verified from the current repository;
- block ids involved;
- read scope, for example `local function window`, `caller/callee chain`, or `cross-block render order`;
- evidence, risk, and unknowns;
- exact next action or validation needed.
- when using the analyzer, report only the relevant focus graph, top large functions, failures, and warnings; keep the full generated JSON as a file reference if needed.
- for visual PERLA1 evidence, report compact `hud_contamination_check`, `coordinate_offset_check`, and `visual_pose_matrix_check` results when screenshots/poses/coordinates affect the conclusion. For roof/eave work, include `roof_visual_matrix_hard_gate` and `roof_matrix_declared_before_patch`: matrix id, required groups completed/missing, runtime/internal coordinate source, HUD/display X handling, owner envelope, contact sheet or indexed matrix path, `same_coordinate_distance_rotation_grid` result, key counters, `visual_qa_auditor_required` status, and whether any failure is `matrix_failed_replan_not_ready`. Include decision-grade fields only: target visual area, HUD overlap/action, requested/effective pose, direction, expected/observed zone or tile/owner, `offset_delta`, coordinate confidence, `false_coordinate_suspicion`, accepted base coordinates, same-coordinate rotations, counters, and pass/fail/degraded action.

Avoid raw dumps. If a large extract is needed, write or reference a focused report only when the Team Leader asks for it or when it materially reduces context pressure.

## Team Leader Rights

The Team Leader may request:

- a deeper read of any branch of `index.html`;
- a second pass with a larger context window;
- a focused symbol map;
- a longer evidence extract;
- a new read-only temporary agent for a gap not covered by configured agents.

Subagents must not refuse a useful deeper read only because a default line window was already used.

## Forbidden Patterns

- Pasting the whole monolithic `index.html` into the main thread.
- Repeating the same search/read cycle without a new hypothesis.
- Treating old reports or maps as stronger evidence than current runtime code.
- Hiding uncertainty just to keep the handoff short.
- Letting a write agent patch before the impacted block and evidence are clear.

Use `workflow-guard` when context pressure, repeated reads, or tool failures start creating a loop.

## Accelerated Complex Task Handoffs

For tasks governed by the Complex Task Accelerator Protocol, context discipline is stricter because speed depends on reusable evidence.

The Team Leader or subagent handoff should include:

- `accelerator_brief` status;
- `critical_path`, `sidecar_tasks`, and `serial_constraints`;
- `cheapest_discriminating_test` and result;
- `validation_ladder` step reached;
- `checkpoint_ledger` entries that are useful for restart;
- `subagent_task_packet` scope and answer when delegated.
- `sidecar_result_integration` for each returned sidecar that affects or might affect the active plan, including `result_status`, `affects_critical_path`, `dependency_on_critical_path`, `accepted_into_plan`, `integration_decision`, `validation_impact`, `write_scope_impact`, `approval_impact`, `heartbeat_checkpoint`, `stop_condition_triggered`, `discard_or_defer_reason`, and `ledger_update`.

Checkpoint ledger entries should preserve decision-grade evidence, not raw dumps:

```text
checkpoint_ledger:
- checkpoint_id:
  verified:
  excluded:
  current_hypothesis:
  files_read:
  do_not_repeat:
  next_cheapest_test:
  open_risks:
```

After 1-2 broad `rg`, diff, or search passes without decision-grade evidence, stop broad searching and narrow the handoff to symbols, block ids, line windows, analyzer focus, or deterministic comparison. A useful deep read is allowed when it follows a concrete hypothesis; repeated unfocused output is not.

Sidecar results should be integrated compactly. Use `integrate` only when they change or confirm the next useful action, `defer` when they matter later, `discard` when they are duplicate/stale/out of scope, `replan` when they change hypothesis/scope/validation, and `stop` when they expose unsafe scope, missing approval, invalid validation, or a blocking contradiction.

## User Intake Relay Handoffs

When the user sends a message during active or long work, keep the handoff compact but decision-grade:

- `user_message_intake`, `user_message_id`, `message_class`, and `user_intent_summary`;
- `must_interrupt`, `must_report_to_team_leader`, `checkpoint_required`, and `response_due`;
- `conflicts_current_plan`, `changes_scope`, `changes_validation`, `changes_write_scope`;
- `approval_impact`, `agent_gate_impact`, `agent_tool_mapping_impact`, `critical_path_impact`, and `sidecar_integration_impact`;
- `decision`, `ledger_update`, `relay_note`, `next_action`, and `forbidden_next_action`.

User intake notes are checkpoint evidence. They are not persistent background monitoring, not approval authority, and not a substitute for required `CALL` agents, validation, write-scope approval, or Team Leader review.

## Finalization Handoffs

For meaningful protected work, the final handoff should preserve `scoped_finalization`, `finalization_gate`, `hook_trust_check`, `checker_semantic_limit`, `workflow_tooling_manifest`, and `subagent_task_lifecycle` as compact evidence, not raw dumps.

Include:

- approved scope and changed files in scope;
- out-of-scope dirty worktree files left untouched;
- generated/disposable artifacts not promoted;
- untracked workflow tooling that should be made tracciable/salvabile or deliberately left out;
- validation run and validation not run;
- hook trust status and fallback if hooks are configured but not proven trusted;
- checker result plus reminder of semantic limits;
- `project_backup_gate` status: `backup_user_requested`, `automatic_task_backup`, backup path, excluded RTP path, retention result, and `backup_not_created_permission_blocked` if filesystem approval was unavailable;
- subagents integrated, deferred/discarded, kept open, closed, stale, or visible only as UI history;
- staging/sync state, including `selective_staging_only`, `no_global_stage`, `sync_safe`, and residual risk.

Do not paste full git status, full checker JSON, or long hook logs unless requested. Summarize decision-grade evidence and point to exact files or generated artifacts when they matter.

Do not paste long screenshot narratives. For HUD/coordinate/`visual_pose_matrix_check` validation, summarize whether the proof is clean, degraded, retried/cropped, UI-level, matrix-failed, or rejected as world/render proof. For roof/eave validation, never compress away missing groups or failed rotations; report `matrix_failed_replan_not_ready` explicitly instead of calling the result ready.

## Long Task Checkpoints

Use `task-watchdog` when work is long, evidence is scattered, or the same logical step is repeated without clear progress.

Track:

- `task_id`: broad user objective;
- `operation_id`: concrete operation being attempted;
- `logical_step_id`: logical step such as `analyze-screenshot-evidence`, `find-root-cause`, `validate-runtime`, `map-render-pipeline`, or `produce-plan`;
- `checkpoint_id`: best known restart point.

Rules:

- Three progressive failures or no-evidence cycles on the same `logical_step_id` require a checkpoint.
- The first long failure in the same operation/logical step may replan from the best checkpoint.
- The second long failure in the same operation/logical step requires `STOP_FOR_USER` and an approval plan.
- A failure brief must consolidate methods tried, evidence collected, excluded causes, unknowns, best checkpoint, and real continuation plans.

## Emergency Refactor Context

Use `refactor-surgeon` only when a documented blocker shows that ordinary patching cannot progress.

Rules:

- Default mode is `REFACTOR_PLAN_ONLY`; no files are edited during planning.
- Applying a refactor requires explicit approved scope.
- The allowed scope is the minimum demonstrably sufficient scope, even if that means more than one function or one block.
- If the minimum scope requires a controlled derogation, surface the rule conflict and request approval.
- Do not use refactor authority for broad cleanup or style-only changes.
