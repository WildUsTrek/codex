# PERLA1 Multi-Agent Orchestration

Last updated: 2026-06-14

This file defines how the Team Leader uses project-scoped agents for PERLA1. It complements `AGENTS.md`, `PERLA1_PROJECT_MAP.md`, `PERLA1_BLOCK_MAP.md`, `PERLA1_CONTEXT_BUDGET.md`, `PERLA1_SYMBOL_INDEX.md`, and `PERLA1_TASK_INTAKE_PROTOCOL.md`.

## Core Principle

The Team Leader owns coordination, final integration, and the user-facing answer. Subagents provide bounded analysis, narrow patches, or validation evidence. No subagent can relax project rules, approve its own work, or redefine the source of truth.

## Standard Flow

1. Read the applicable `AGENTS.md` files.
2. Read `PERLA1_PROJECT_MAP.md`.
3. Read `PERLA1_CONTEXT_BUDGET.md` for monolithic runtime work or multi-agent mapping.
4. Read `PERLA1_TASK_INTAKE_PROTOCOL.md` before meaningful edits, runtime validation, multi-agent work, or refactor planning.
5. Read `PERLA1_BLOCK_MAP.md` and `PERLA1_SYMBOL_INDEX.md` for monolithic runtime work.
6. Read `PERLA1_RUNTIME_TEST_RUNBOOK.md` before rendered/browser validation.
7. Identify impacted block ids before patching.
8. Run the Agent Selection Gate and mark each relevant agent as `CALL`, `CONSIDER`, or `SKIP`.
9. Use read-only auditors for mapping, regression, performance, visual, asset, or launcher concerns.
10. When `plan-integrity-auditor` is `CALL`, audit the selected plan before assigning write work.
11. Assign write work only after diagnosis, plan scope, and ownership are clear.
12. Keep write scopes disjoint when multiple agents are active.
13. Run local static CI for meaningful runtime or `tooling-ci` changes when practical, preferably with `-ReportPath` outside the repo for disposable reports.
14. Validate through the PERLA1 launcher/server route for runtime behavior changes.
15. Maintain workflow heartbeat checkpoints during long waits or tool/subagent work.
16. Run the `project_backup_gate` when required: user-requested backups before the next protected step, and automatic task backups before final delivery for meaningful tasks when filesystem permissions allow it.
17. Update technical maps/indexes only when structure, contracts, validation, tooling, symbol hints, or recurring risks change.

## Agent Selection Gate

Use `PERLA1_TASK_INTAKE_PROTOCOL.md` before meaningful work.

- For delicate runtime, rollback, failed-patch, validation, launcher, sync, workflow-policy, AGENTS, TOML, orchestration, refactor, or user-escalated work, invoke the Standing Guard Set from `PERLA1_TASK_INTAKE_PROTOCOL.md` before the first operational patch, runtime validation, sync, or refactor.
- The Standing Guard Set is governance, not background magic: the Team Leader must spawn/direct the guard agents or record a valid `agent_tool_mapping` adapter before continuing.
- `workflow-consistency-auditor` is `CALL` for every explicit gate; it can run a lightweight gate audit when policy files are not changing.
- `workflow-guard`, `plan-integrity-auditor`, `task-watchdog`, `skeptic-auditor`, and `refactor-surgeon` are always at least `CONSIDER`.
- Domain agents are `CALL` when their task signal matches the current work.
- `CALL` means the agent must actually be invoked or delegated before the protected step. It cannot be treated as a passive checklist item.
- Before a protected patch, rendered/runtime validation, sync, refactor application, or readiness claim, every required `CALL` agent needs `call_agent_evidence` with exactly one satisfaction state: `direct_invocation`, `generic_adapter`, or `tooling_blocked`.
- `call_agent_evidence` must include `user_delegation_state`, `agent_tool_mapping_ref` when a generic adapter is used, `tooling_discovery_attempted`, `adapter_attempted`, and the output or blocked reason.
- `critical_path` is not a bypass for required agents. If a `CALL` agent can run as an independent sidecar while the Team Leader advances non-overlapping local work, start it first. If the specialist output protects the next step, wait for it or stop with `TOOLING_BLOCKED`.
- `visual_qa_required`: screenshots, rendered QA, browser/runtime validation, or visible user-facing regression risk make `visual-qa-auditor` `CALL` before readiness claims. The Team Leader may collect screenshots/counters but cannot be the only visual QA authority unless `call_agent_evidence` records `tooling_blocked` or explicitly accepted degraded fallback with residual risk.
- `visual_pose_matrix_check`: roof/eave/wall-occlusion/visibility work, and any visual bug that can vary by camera angle, requires accepted base coordinates plus same-coordinate rotation sweeps before readiness claims. For roof/eave work this escalates to `roof_visual_matrix_hard_gate`: `roof_matrix_declared_before_patch`, current runtime/internal coordinates, HUD/display X recorded separately, `same_coordinate_distance_rotation_grid` with far/close/east/west/interior-or-portal/user-repro groups as applicable, same-coordinate rotations, contact sheet or indexed matrix, counters, `hud_contamination_check`, `coordinate_offset_check`, and a `visual-qa-auditor` result. A single attractive screenshot is not enough; partial matrices are `matrix_failed_replan_not_ready` when rotation/distance changes hide roof volume, colmo/ridge, ceiling authority, or budget failure.
- The user has standing project authorization for PERLA1 configured subagents selected by the gate. Do not require a fresh user sentence before using a required project agent.
- Standing project authorization is subordinate to higher-priority Codex tool-surface rules. If the active tool surface requires explicit user delegation before spawning subagents, obtain it or stop with `TOOLING_BLOCKED` before protected work.
- If subagent tooling is not visible, first use tool discovery when available. If only generic subagent types are visible, apply the Agent Tool Adapter rule before considering `TOOLING_BLOCKED`.
- If the tool surface exposes only generic subagent types such as `explorer` or `worker`, use the Agent Tool Adapter rule from `PERLA1_TASK_INTAKE_PROTOCOL.md`: assign the generic subagent the exact named role, require it to read/follow `.codex/agents/<agent>.toml` and the required PERLA1 docs, and record the mapping. A generic subagent without this explicit role mapping does not satisfy a named `CALL`.
- TOML `name` and `description` define the project role identity and instructions; they do not guarantee the Codex UI display name, nickname, icon, or direct callability, which depend on the active tool surface.
- Do not treat generic subagent availability as `TOOLING_BLOCKED` when a valid adapter can be spawned. Use `TOOLING_BLOCKED` only after direct invocation and adapter invocation are both impossible or materially unsafe.
- A write agent is never `CALL` until diagnosis, scope, and ownership are clear.
- `plan-integrity-auditor` is `CALL` before executing an explicit multi-step plan, a user-approved plan, a delicate patch plan, a rollback/refactor strategy, or an alternatives-based route choice.
- Write agents must refuse to patch if there is no evidence that the Agent Selection Gate ran and their file/symbol scope was approved.
- If an agent is relevant but not called, the Team Leader must have a concrete reason.
- The gate can stay implicit only for tiny direct answers or simple shell checks.

## Workflow Heartbeat

The Team Leader must actively monitor workflow progress. This is checkpoint-enforced, not a claim that a read-only agent runs as a background daemon.

The Team Leader is responsible for starting the guard agents. A missed startup gate is itself a workflow anomaly: before continuing, run a workflow-consistency audit, classify what was missed, repair the rule/process hole when allowed, and report residual risk to the user.

Before starting a potentially blocking step, record:

- expected evidence;
- `task_started_at`;
- elapsed time for the whole `task_id`;
- current `task_id`, `operation_id`, and `logical_step_id`;
- last completed checkpoint;
- checkpoint limit;
- forbidden repeated method.

Checkpoint limits:

- 12 minutes per `operation_id` or `logical_step_id` for simple file comparison, small audits, simple shell checks, or bounded read-only inspection.
- 21 minutes per `operation_id` or `logical_step_id` for complex runtime, workflow, browser, subagent, or multi-file investigation.
- These are per-step heartbeat limits, not a whole-task time limit. Longer tasks are allowed when each checkpoint produces evidence and a bounded next proof target.
- The configured `job_max_runtime_seconds` is a hard ceiling only. Do not wait silently until it expires.
- Whole-task wall-clock limit: 5 hours per `task_id`, unless the user explicitly grants a new budget.
- At 4h30m elapsed task time, call `task-watchdog` to prepare a checkpoint handoff.
- At 5h elapsed task time, stop at the last completed checkpoint and request user approval before resuming with a new budget.

Mandatory escalation:

- If the whole `task_id` reaches 4h30m elapsed, call `task-watchdog`.
- If the whole `task_id` reaches 5h elapsed, return `STOP_FOR_USER`; do not start a new operational step and do not continue merely to finish the current one.
- If no meaningful new evidence exists at the checkpoint, call `task-watchdog`.
- If the next action repeats the same method, cannot produce new evidence, waits on an unknown state, or follows a known failing tool path, call `workflow-guard`.
- If an interrupt/new user question arrives while a long step is active, checkpoint immediately before resuming work.
- If a subagent is still running but not blocking the immediate next local step, continue non-overlapping local work instead of waiting.
- If the Team Leader is blocked only because a subagent has not returned, wait in bounded slices and checkpoint before another wait.
- If `rg`, diff, or another search emits excessive output from the monolith, stop consuming raw output and narrow to named functions, block ids, line windows, or deterministic file comparison.
- Use every agent required by the Agent Selection Gate. If the task genuinely needs many `CALL` agents, including 7 agents and especially more than the configured concurrency budget, use the required agents and batch only when the active tool surface imposes a hard limit. `max_threads` is a technical concurrency cap, not permission to downgrade necessary agents.
- Do not fill all available subagent slots with non-critical explorers before required governance/domain agents have run. If capacity is tight, prioritize required `CALL` agents and serialize optional `CONSIDER` work.
- For rendered visual work, do not let local Team Leader interpretation replace the visual specialist. If `visual-qa-auditor`, `plan-integrity-auditor`, or `workflow-guard` is required and not invoked through direct invocation or a valid generic adapter, the next protected patch/readiness claim must stop as `TOOLING_BLOCKED` or degraded fallback with residual risk.

Checkpoint evidence before retrying must include `task_id`, `task_started_at`, `elapsed_task_time`, `operation_id`, `logical_step_id`, elapsed step time, method tried, evidence gained, next proof target, retry count, last completed checkpoint, allowed next action, and forbidden next action.

When the 12-minute simple-step limit or 21-minute complex-step limit is reached, the checkpoint is mandatory before another wait, retry, subagent wait, browser attempt, runtime validation attempt, or patch. A status-only sentence is not enough; the checkpoint must carry the evidence fields above.

Workflow anomalies must be classified before the next operational step. Repeated tool fallback, missing subagent tooling, stale validation route, skipped heartbeat checkpoint, silent downgrade from `CALL` to `CONSIDER`, or inconsistent agent authority must trigger `workflow-guard`; if the anomaly concerns `.md`/TOML/gate hierarchy or agent permissions, also trigger `workflow-consistency-auditor` full audit.

Agent adapter anomalies are workflow anomalies. If a Team Leader cannot show direct named-agent invocation, valid generic-role mapping, or `TOOLING_BLOCKED`, the gate is not satisfied.

If neither direct custom-agent invocation nor role-assigned generic subagent invocation is possible, the Team Leader may do only the minimum read-only classification required to report `TOOLING_BLOCKED`. This does not authorize patching, runtime validation, sync, refactor application, or claiming the gate passed.

## Context Budget Protocol

Use `PERLA1_CONTEXT_BUDGET.md` when work touches the monolithic runtime or when subagents are active.

- Context budget controls what is returned to the main thread, not what an agent may inspect in the repository.
- Agents should start from maps and symbol hints, then use `rg` and targeted reads.
- If a local window is not enough, agents may inspect a larger caller/callee chain or cross-block renderer path.
- The Team Leader may request deeper detail, a longer extract, or a second pass when the first handoff is insufficient.
- Handoffs must include read scope, symbols, line hints, evidence, unknowns, and next action.
- Raw monolith dumps and repeated searches without a new hypothesis are workflow risks; consult `workflow-guard`.

## Complex Task Accelerator

Use the Complex Task Accelerator Protocol from `PERLA1_TASK_INTAKE_PROTOCOL.md` for complex, high-risk, delicate, multi-agent, runtime, workflow, refactor, failed-patch recovery, or long tasks.

The Team Leader owns the Complex Task Execution Brief. It must be created before the first expensive patch, broad validation, long wait, or large agent batch when the protocol applies.

Operational rules:

- Identify the `critical_path` first. Keep moving locally on the blocking proof/change unless a specialist answer is strictly required.
- Assign `sidecar_tasks` only when they are independent, read-only or disjoint, and can produce useful evidence while the critical path advances.
- Mark `serial_constraints` when two tasks touch the same file/block/write scope or when one result changes the next question. Serial work is not parallelized.
- Run the `cheapest_discriminating_test` before committing to an expensive implementation or validation route when two or more hypotheses are plausible.
- Use the `validation_ladder`: static/policy check, targeted symbol/counter/debug/analyzer evidence, targeted screenshot, regression poses, then broader validation only when justified.
- Maintain the `checkpoint_ledger` so a resumed task knows what is verified, what is excluded, what must not be repeated, and the next cheapest test.
- Do not spawn optional sidecar agents before required guard/domain `CALL` agents.
- Do not let a sidecar result block the critical path unless its packet explicitly marks a dependency.
- After 1-2 broad `rg`, diff, or search passes without decision-grade evidence, narrow to symbols, block ids, line windows, analyzer focus, or deterministic comparison.

Each complex-task subagent receives a `subagent_task_packet` with role, scope, exact question, max output, forbidden actions, path classification, checkpoint deadline, and expected evidence. A generic prompt like "study this area" does not satisfy the protocol for complex work.

## Sidecar Result Integration

Use the Sidecar Result Integration Protocol from `PERLA1_TASK_INTAKE_PROTOCOL.md` whenever a sidecar agent or parallel tool returns while the Team Leader is still advancing the `critical_path`.

The Team Leader must classify the result before letting it affect the active step:

```text
sidecar_result_integration:
  agent:
  source_agent:
  agent_tool_mapping_ref:
  original_packet:
  path_classification: critical_path/sidecar/serial
  dependency_on_critical_path: yes/no
  result_status: useful/no_change/conflicting/blocking
  evidence_received:
  affects_critical_path: yes/no
  changes_hypothesis:
  changes_scope:
  changes_validation:
  validation_impact:
  write_scope_impact:
  approval_impact:
  heartbeat_checkpoint:
  accepted_into_plan: yes/no
  integration_decision: integrate/defer/discard/replan/stop
  stop_condition_triggered:
  discard_or_defer_reason:
  ledger_update:
  next_action:
```

Operational rules:

- Continue non-overlapping local work while sidecar tasks run.
- Do not wait for a sidecar result unless it is an explicit dependency for the `critical_path`.
- When a sidecar returns, use `integrate` only if the result changes or confirms the next useful action.
- Use `defer` when the result is useful but not relevant to the current `critical_path`; add it to `checkpoint_ledger`.
- Use `discard` for duplicate, stale, unsupported, or out-of-scope output; do not open a new analysis loop.
- Use `replan` when the result changes hypothesis, scope, validation, or dependency ordering.
- Use `stop` when the result exposes unsafe scope, missing approval, invalid validation, source-of-truth conflict, or a blocking contradiction.
- A sidecar result cannot authorize writes, lower validation, bypass `CALL` agents, bypass Agent Tool Adapter rules, or override user approval requirements.
- `accepted_into_plan: yes` requires explicit review of validation, write-scope, approval, heartbeat, and adapter impact. If any impact is unsafe or unclear, use `replan` or `stop`.

## User Intake Relay

Use the User Intake Relay Protocol from `PERLA1_TASK_INTAKE_PROTOCOL.md` when the user sends a message during active, long, delicate, multi-agent, runtime, workflow, refactor, or validation work.

The Team Leader owns the response and the integration decision. A relay classification is evidence, not authority.

```text
user_message_intake:
  user_message_id:
  received_at:
  task_id:
  operation_id:
  logical_step_id:
  active_step_state:
  message_class: status_request/new_requirement/correction/approval/blocker/stop_request/scope_change/validation_request/priority_change/other
  urgency: low/normal/high/blocking
  elapsed_task_time:
  elapsed_step_time:
  checkpoint_required: yes/no
  checkpoint_id:
  user_intent_summary:
  affects_current_objective: yes/no
  affects_critical_path: yes/no
  critical_path_impact:
  conflicts_current_plan: yes/no
  changes_scope:
  changes_validation:
  changes_write_scope:
  must_interrupt: yes/no
  must_report_to_team_leader: yes/no
  requested_status:
  source_of_truth_impact:
  validation_impact:
  write_scope_impact:
  approval_impact:
  agent_gate_impact:
  agent_tool_mapping_impact:
  agent_or_tool_impact:
  sidecar_integration_impact:
  decision: answer_now/continue/checkpoint/replan/stop/defer_to_checkpoint
  ledger_update:
  relay_note:
  next_action:
  forbidden_next_action:
  response_due: immediate/next_checkpoint/final
```

Operational rules:

- Answer `status_request` messages from current evidence without blocking `critical_path` when no decision changes.
- Checkpoint before continuing when a user message changes objective, source of truth, validation route, write scope, approval state, priority, or stop conditions.
- A `blocker` or `stop_request` must interrupt before the next operational patch, runtime validation, sync, or refactor application.
- `must_report_to_team_leader: yes` requires a `checkpoint_ledger` update and Team Leader review before the next protected step.
- A relay may classify and summarize; it cannot approve writes, lower validation, satisfy missing `CALL` agents, change source of truth, or override `workflow-guard`, `task-watchdog`, Agent Tool Adapter, or explicit user approval.
- `message_class: approval` is classification only. It does not grant approval; the Team Leader must verify the original user intent and approval/write/validation impact before acting.
- This is not a persistent background listener guarantee. If the tool surface delays message handling while a blocking tool runs, the next checkpoint must classify the message before continuing.

## Subagent Lifecycle

Use `subagent_task_lifecycle` for every spawned or directly invoked PERLA1 subagent.

Operational rules:

- The Team Leader owns subagent lifecycle. A subagent is kept open while its assigned task can still produce useful evidence for the Team Leader's current `task_id`.
- Do not close a subagent at the end of one internal step if the Team Leader task and assigned packet are still active.
- Close a subagent at Team Leader task completion, or earlier only when its packet is fully integrated, obsolete, stale, aborted, or explicitly unsafe to continue.
- Before closing, classify the latest result with Sidecar Result Integration when it contains evidence that could affect the plan.
- At final delivery after multi-agent work, record `subagent_task_lifecycle`, `result_integrated`, `final_sidecar_integration_ref`, `subagents_to_keep_open`, and `subagents_to_close`.
- UI history entries may remain visible after closure. Treat UI history as residual display state, not as proof of active compute, unless the tool surface reports a running/pending status.
- Closed agents are not reusable proof that a future gate ran. A new protected task still needs a fresh Agent Selection Gate or a recorded valid continuation checkpoint.

## Tooling-CI Protocol

The `tooling-ci` block covers static analysis, dependency graph extraction, regression-suite metadata, generated structure reports, and modularization scaffolding.

Source files:

- `tools/perla_runtime_analyzer.mjs`
- `tools/perla_local_ci.ps1`
- `tests/perla_regression_suite.json`
- `PERLA1_MODULARIZATION_PLAN.md`
- `01_GIOCO_PRONTO_LOCAL_TEST/src/module-boundaries.json`
- `01_GIOCO_PRONTO_LOCAL_TEST/src/README.md`

Rules:

- `01_GIOCO_PRONTO_LOCAL_TEST/index.html` remains the runtime source of truth.
- `src/` is scaffold-only until an explicitly approved extraction changes the runtime loading path and passes static plus rendered validation.
- `safe-fixer` may patch `tooling-ci` only with explicit assigned files or explicit `tooling-ci` block scope.
- Generated reports such as `report/RUNTIME_STRUCTURE_CURRENT.json` are disposable local evidence unless the user explicitly asks to promote them.
- Prefer `tools/perla_local_ci.ps1 -ReportPath` outside the repository for routine validation to avoid report churn.
- Static CI can prove parse, symbol, dependency, and suite-contract evidence. It cannot prove rendered browser behavior, screenshots, counters, or visual correctness.

## Machine Enforcement Layer

PERLA1 has an executable workflow guard in `tools/perla_codex_workflow_check.ps1`. It is the canonical local check for the workflow rules that can be verified mechanically: hook presence, required policy files, agent TOML schema fields, configured thread limits, codex-exec documentation, hook-trust wording, and the explicit rule that subagents are summoned work units, not persistent background daemons.

Use it directly for local or CI-style checks:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\tools\perla_codex_workflow_check.ps1 -Mode CI -Json
```

Output contract:

- JSON schema id: `perla.workflow.check.v1`.
- `-Json` emits one JSON object with `status`, `blocking_failures`, `warnings`, and `checks`.
- `-Jsonl` emits one compressed JSON object per check plus a final `summary` event.
- Exit code `0` means no P0/P1 workflow failure was found; warnings may still exist.
- Exit code `1` means at least one P0/P1 workflow failure, or any non-pass status when `-Strict` is used.

For Codex scripting workflows, the companion route is `codex exec --json` so the resulting audit events are machine-readable JSONL. Use that for scheduled, CI, or pre-sync review work when a Codex model audit is needed in addition to the local deterministic checks. Do not treat `codex exec` as a permanent background agent service.

The repository root `.codex/hooks.json` wires `Stop`, `SubagentStart`, and `SubagentStop` to the local workflow check. These hooks only enforce after Codex has loaded the root `.codex` layer and the non-managed hook definition has passed Codex trust review. A hook file committed to the repo is readiness for enforcement, not proof that the current Codex client already trusted and ran it.

Hook trust check:

- Record `hook_trust_check` before relying on hooks as enforcement evidence for workflow-policy, TOML, AGENTS, orchestration, hook, launcher/sync, or agent-rule changes.
- Include `hook_file`, `events_expected`, `validator_target`, `static_safety_check`, `local_manual_run`, `codex_trust_status`, `enforcement_assumption`, and `fallback_if_untrusted`.
- If trust is unknown or unconfirmed, run `tools/perla_codex_workflow_check.ps1` manually and report hooks as configured but not proven active.
- Hook trust cannot be forced from inside the repository when the Codex platform requires external/user trust confirmation.

Hook semantics:

- Hooks run a fixed local command only; they must not build shell commands from prompt text, fetch network data, mutate Git state, or spawn agents.
- Hooks fail closed for P0/P1 deterministic workflow failures by returning a non-zero exit code.
- Hooks are evidence about the lifecycle check they ran; they are not equivalent to output from a required `CALL` agent.
- Hook checks are guard rails around lifecycle events. They do not replace the Agent Selection Gate, do not spawn missing project agents by themselves, and are not evidence that agents are continuously running. The Team Leader still owns invoking required `CALL` agents or recording a valid `agent_tool_mapping` / `TOOLING_BLOCKED` state before protected work.

Checker semantic limit:

- Keep `checker_semantic_limit` visible in final workflow decisions. The PowerShell checker verifies deterministic text/config contracts only.
- The checker does not prove rendered behavior, true user intent, plan quality, agent reasoning quality, or all cross-document semantics.
- Mitigate that limit with `workflow-consistency-auditor`, `workflow-guard`, `plan-integrity-auditor`, `task-watchdog`, and domain auditors when their triggers fire.
- A passing checker plus missing required audit output is not a passed gate.

## Project Backup Gate

Use `tools/perla_project_backup.ps1` as the canonical backup tool.

Backup scope is the full synchronized repository folder:

```text
C:\Users\ASUS\Documents\GitHub\codex
```

The only excluded path is:

```text
C:\Users\ASUS\Documents\GitHub\codex\PERLA1\01_GIOCO_PRONTO_LOCAL_TEST\assets\rtp
```

Operational rules:

- Backups are timestamped `.zip` archives, not copied backup directories.
- `backup_user_requested`: `-Kind User` writes to `C:\Users\ASUS\Documents\GitHub\backup\utente` when the user explicitly orders a backup.
- `backup\utente` is append-only unless the user explicitly orders a specific deletion.
- `-Kind Automatic` writes to `C:\Users\ASUS\Documents\GitHub\backup\automatici` before final delivery of a meaningful task when filesystem permissions allow it.
- Before creating an automatic backup, if `backup\automatici` contains more than 10 files, delete only files older than 2 days. Never delete folders and never delete anything under `backup\utente`.
- If writing outside the repository needs filesystem approval, request it. If approval is unavailable, record `backup_not_created_permission_blocked` in `finalization_gate` and report it.
- Backup zip files are outside Git and must not be staged.

## Scoped Finalization

Use `scoped_finalization` and `finalization_gate` before final delivery, staging, sync, or a readiness claim.

Required finalization record:

```text
finalization_gate:
  task_id:
  approved_scope:
  changed_in_scope:
  changed_out_of_scope:
  generated_or_disposable:
  untracked_workflow_tooling:
  project_backup_gate:
    user_backup_requested: yes/no
    user_backup_status: created/not_requested/blocked/failed
    automatic_task_backup_status: created/blocked/failed/not_meaningful_task
    backup_tool:
    backup_path:
    excluded_path:
    retention_applied:
    files_removed_from_automatici:
  validation_run:
  blocking_failures:
  subagent_task_lifecycle:
  subagents_to_keep_open:
  subagents_to_close:
  staging_plan: none/selective
  selective_staging_only: yes/no
  no_global_stage: yes/no
  sync_safe: yes/no
  residual_risk:
```

Operational rules:

- Separate in-scope edits from out-of-scope dirty worktree changes before final claims.
- Never do broad/global staging when unrelated runtime, launcher, report, generated, or user changes exist.
- Use selective staging only for approved scope, and ask the user before staging/sync when unrelated meaningful changes are present.
- Generated reports, JSON/JSONL, hook logs, local screenshots, and temporary server logs stay disposable unless explicitly promoted.
- `PERLA1/tools/` requires classification through `workflow_tooling_manifest`; do not assume every file under it is either disposable or tracked.
- A final answer must distinguish validated facts from residual risk when any required validation was not run.

## Runtime Server Requirement

Rendered PERLA1 validation requires the local PowerShell server. Browser automation alone cannot serve the game.

Required route:

- For Codex/agent validation, use `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher`, which starts `AVVIA_GIOCO_CODEX_HEADLESS.ps1 -Serve` on port `8000` without opening a browser window and stops the created PID after validation.
- For manual user play, use `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`, which calls `AVVIA_GIOCO_SERVER_POWERSHELL.ps1` on port `8000` and opens the browser.
- Or explicitly confirm that an existing PERLA1 server is already responding at `http://127.0.0.1:8000/`.
- Then load `http://127.0.0.1:8000/` with a cache-busting query string.

Do not validate rendered runtime behavior with `file://`, by opening `index.html` directly, by launching the user `.bat` hidden as a Codex workaround, or by asking a browser agent to navigate before the server is running. If the headless launcher cannot start the server, the correct output is a server-start handoff, not a failed runtime diagnosis.

## Browser Fallback Protocol

Rendered runtime validation should use the proven Windows path in `PERLA1_RUNTIME_TEST_RUNBOOK.md` first unless the user specifically asks to test another browser path.

Known reliable automated method:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher ...` starts the Codex headless server when needed and captures `#screen` with system Chrome/Edge through Playwright.
- `AVVIA_GIOCO_CODEX_HEADLESS.ps1` writes `AVVIO_GIOCO_CODEX_HEADLESS_LOG.txt`, PID, and ready files for deterministic startup checks.
- Screenshots default to `%TEMP%`, not the Git repository.

Other browser paths are secondary attempts. A Browser bootstrap failure is a tooling failure, not proof that the PERLA1 runtime is broken.

Known tooling failure class:

- `CreateProcessAsUserW failed: 5`
- Windows sandbox or permission errors while launching/attaching the in-app Browser
- Browser plugin connection failure before page navigation

When this happens:

1. Confirm the PERLA1 server route is running, or use `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher`.
2. Keep the validation target identical: `http://127.0.0.1:8000/` with a cache-busting query string.
3. Record the Browser failure class briefly.
4. Use `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 ...` or equivalent Playwright/system Chrome headless flow.
5. If headless browser validation also fails, provide a manual validation handoff with exact URL, launcher to run, expected `window.PERLA_BUILD_ID`, debug poses, screenshots to capture, and counters/API calls to read.
6. Do not mark a rendered fix as fully validated unless visual evidence and relevant counters were actually inspected.

Visual evidence hygiene:

- Use `hud_contamination_check` for screenshots used as world/render proof. HUD, clock, minimap, controls, status text, debug overlays, and browser UI are contamination when they cover or could be confused with the target rendered area. If the test is intentionally UI/HUD layout QA, state that separately and do not treat HUD visibility as renderer contamination.
- Use `coordinate_offset_check` when there is certainty or legitimate doubt that the target is PERLA1 and a conclusion depends on coordinates, deterministic poses, map cells, or screenshot placement. Record requested/effective pose, direction requested/effective, expected/observed zone, expected/observed tile or owner, known offset, `offset_delta`, coordinate confidence, and `false_coordinate_suspicion`.
- Suspicious PERLA1 coordinates require map/debug inspection or an adjusted retry before renderer conclusions.

Subagents should not attempt to open Chrome, Edge, the user `.bat`, or external GUI browsers directly unless the Team Leader explicitly assigns that fallback path. Do not repeatedly retry known-failing methods before using the runbook method.

## Workflow Circuit Breaker

Use `workflow-guard` as the official loop detector and circuit breaker when a workflow shows repeated failure, tool drift, or validation uncertainty.

Call or consult it before continuing when any of these occur:

- the same method failed twice without new evidence;
- a deterministic tool failure happened and the next step would retry that tool or method;
- in-app Browser failed with `CreateProcessAsUserW failed: 5`;
- runtime validation was attempted before the launcher/server was running;
- Playwright failed because `NODE_PATH` or browser executable resolution was wrong;
- a `.ps1` helper failed due Windows execution policy;
- an agent proposes `file://` or direct `index.html` validation;
- a plan treats local static CI as a replacement for rendered/browser validation of runtime behavior;
- a plan would stage generated local CI reports without explicit report promotion;
- a write agent tries to validate its own change as complete;
- a patch touches roofs/ceilings/rain/sprites without the required visual and counter proof;
- multiple agents may write the same runtime block.
- a task passes its heartbeat checkpoint without meaningful new evidence;
- the Team Leader is about to wait again for a subagent/tool without a new reason;
- the session appears unresponsive after an interrupt or new user question;
- a simple comparison/audit is taking more than 12 minutes without deterministic diff/tool output.

`workflow-guard` returns `PROCEED` only when the next step materially changes the method or adds new evidence. It returns `STOP` when the next step would repeat a known failure or violate project rules.

## Workflow Consistency Auditor

Use `workflow-consistency-auditor` to audit the workflow system itself: `.md` policy files, TOML agents, gate membership, hierarchy, permissions, and source-of-truth rules.

It is read-only. It does not patch. It returns:

- `PROCEED`
- `PROCEED_WITH_WARNINGS`
- `STOP_NEXT_STEP`
- `STOP_FOR_USER`

Mandatory call triggers:

- every explicit Agent Selection Gate, using lightweight gate audit when no workflow policy changed;
- any `.md` or `.toml` workflow/policy/agent change;
- adding, removing, or renaming an agent;
- changing `PERLA1_TASK_INTAKE_PROTOCOL.md`, `.codex/ORCHESTRATION.md`, or AGENTS files;
- suspected hierarchy conflict between local AGENTS, project map, block map, runbook, and TOML rules;
- suspected permission paradox or agent required to do something outside its scope;
- before GitHub sync when workflow policy files changed meaningfully.

Severity behavior:

- P0 Critical: return `STOP_FOR_USER` or `STOP_NEXT_STEP`.
- P1 High: return `STOP_NEXT_STEP` before patch/runtime/refactor/sync continues.
- P2/P3: return `PROCEED_WITH_WARNINGS` unless the Team Leader decides to fix immediately.

`workflow-consistency-auditor` does not replace `workflow-guard`: consistency auditor finds structural rule holes, guard enforces safety on the current plan.

## Plan Integrity Auditor

Use `plan-integrity-auditor` to audit the selected implementation plan before execution.

It is read-only. It checks whether the plan is aligned with the user's actual objective, scoped to real files/symbols/blocks/dependencies, coherent with current workflow rules and runtime contracts, explicit about success/stop/fallback criteria, and testable through the required validation route.

Mandatory call triggers:

- the user asks for a plan, approves a plan, asks to proceed with a plan, or asks to choose between alternatives;
- a patch is delicate: runtime renderer behavior, roof/ceiling/rain/sprites/minimap/performance, launcher/server, sync, workflow policy, TOML/AGENTS, rollback, deletion, cleanup of failed patch stacks, or refactor planning/application;
- a previous patch failed visually or behaviorally and a new route is being selected;
- safe-fixer or refactor-surgeon is about to receive execution scope from a non-trivial plan;
- validation requirements, runtime contracts, or agent/workflow rules would change.

Decisions:

- `PLAN_OK`: proceed with the plan.
- `PLAN_OK_WITH_WARNINGS`: proceed while carrying stated residual risks.
- `PLAN_REVISION_REQUIRED`: correct the plan before operational patch, validation, sync, or refactor application.
- `STOP_FOR_USER`: user choice or approval is required before execution.

`plan-integrity-auditor` does not replace `workflow-guard`, `workflow-consistency-auditor`, `task-watchdog`, `skeptic-auditor`, `visual-qa-auditor`, or `safe-fixer`.

## Contract Drift Guard

Before any operational patch, runtime validation, refactor application, or sync that touches a versioned runtime contract, compare the relevant `.codex/agents/*.toml` instructions against `PERLA1_PROJECT_MAP.md` and `PERLA1_BLOCK_MAP.md`.

- The project map and block map are the source of truth for current runtime contracts; TOML agents may specialize behavior but must not preserve stale version authority.
- If a TOML file contradicts the current contract, fix the TOML or record an explicit user-approved derogation before the protected step.
- Prefer TOML wording that points agents to the current project/block maps, then records the current version contract as a dated snapshot.
- `workflow-consistency-auditor` is `CALL` after any TOML, AGENTS, orchestration, or intake-protocol change, and before sync when these files changed.
- For roof work under the current V281R/V281 contract, `drawStableModernOwnerRoofPrimitiveV281` is the mapped modern owner `1`/`2` roof authority when primitive preflight accepts the roof; `drawModernIntegratedRoofCapV278` is historical/diagnostic and must stay disabled as normal authority under V281; V265/V277 remain fallback/support paths only when primitive preflight rejects, V282 portal/slab helpers remain dormant/off diagnostics unless explicitly approved, and V266/V267/V270/V271/V273/V274/V275 remain runtime-off unless a later project-map contract and explicit user-approved scope supersede it.

## Long Task Watchdog

Use `task-watchdog` when a task may run long or when the Team Leader needs an explicit checkpoint decision.

It tracks three identifiers:

- `task_id`: the broad user objective.
- `operation_id`: the concrete operation being attempted.
- `logical_step_id`: the logical/cognitive step, independent from the tool used.

Required decisions:

- `CONTINUE`: new evidence exists and the next step can produce more.
- `CHECKPOINT`: evidence must be consolidated before more work.
- `REPLAN`: first long failure; restart may proceed from the best checkpoint with a materially different plan.
- `STOP_FOR_USER`: second long failure in the same `operation_id` or `logical_step_id`; user approval is required.
- `ESCALATE`: a missing specialist, tool, or architectural decision blocks progress.

Mandatory triggers:

- 4h30m elapsed wall-clock time on the whole `task_id`: prepare checkpoint handoff.
- 5h elapsed wall-clock time on the whole `task_id`: `STOP_FOR_USER`; stop at the last completed checkpoint.
- any subagent/tool job expected to exceed 12-21 minutes;
- any job timeout before retrying;
- three progressive failures or no-evidence cycles on the same `logical_step_id`;
- first long failure on the same operation/logical step;
- second long failure on the same operation/logical step;
- 12 minutes without meaningful new evidence on a simple comparison, small audit, or bounded read-only task;
- 21 minutes without meaningful new evidence on complex runtime, workflow, browser, subagent, or multi-file work;
- inability to state what the next step is trying to prove.

Failure brief rule:

- On `CHECKPOINT`, `REPLAN`, `STOP_FOR_USER`, or `ESCALATE`, the watchdog must request or define a failure brief if evidence is scattered.
- The Team Leader assigns the brief to the best read-only specialist: `code-mapper`, `renderer-block-auditor`, `regression-auditor`, `performance-auditor`, `visual-qa-auditor`, `asset-integrity-auditor`, or `launcher-sync-auditor`.
- The brief must include attempted objective, operation/logical ids, checkpoint id, methods tried, evidence collected, what is excluded, unknowns, best restart checkpoint, and two or three real continuation plans with cost/risk.
- At the 5h cap, the failure brief must also include elapsed task time, last completed checkpoint, partial/unverified local edits if any, validation status, and the requested new budget.

## Skeptic Auditor

Use `skeptic-auditor` to challenge the current plan before the Team Leader commits to a risky, uncertain, long, or repeated path.

It is read-only and does not block by itself. It produces a `SKEPTIC_REVIEW` comparing:

- current plan;
- evidence supporting it;
- evidence against it or missing;
- assumptions to test;
- plan B and plan C;
- cheapest discriminating test;
- recommendation and confidence.

Mandatory call triggers:

- diagnosis is uncertain or based on stale reports;
- two or more plans are plausible;
- task-watchdog returns `CHECKPOINT`, `REPLAN`, `STOP_FOR_USER`, or `ESCALATE`;
- `refactor-surgeon` is asked for `REFACTOR_PLAN_ONLY`;
- the task touches critical renderer/runtime paths such as roof, ceiling, rain, sprites, minimap, or performance hot paths;
- the Team Leader is about to continue after a long or failed attempt.

`skeptic-auditor` does not replace `workflow-guard`: guard decides safety, skeptic compares strategy.

## Emergency Refactor Surgeon

Use `refactor-surgeon` only as an emergency unblocker after a documented blockage. It is not a normal fixer and it is not a cleanup agent.

Allowed triggers:

- `task-watchdog` returns `STOP_FOR_USER` or `ESCALATE` and the failure brief shows that ordinary work is blocked.
- `workflow-guard` returns `STOP` because the current workflow cannot proceed safely, and a refactor plan may remove the blocker.
- The user or Team Leader explicitly requests a refactor plan for a documented blocker.

Required mode sequence:

1. `REFACTOR_PLAN_ONLY`: default. No file edits. The agent proposes objective, evidence, minimum sufficient scope, touched symbols, rule conflicts, requested derogations, rollback plan, validation plan, risks, and stop conditions.
2. `APPLY_APPROVED_REFACTOR`: only after explicit approval and approved scope. If the required scope grows or a new rule conflict appears, stop and return `STOP_FOR_USER`.

Scope rule:

- Use the minimum demonstrably sufficient scope, not "one function only" and not broad cleanup.
- The scope may cross functions or blocks only when the failure brief proves the coupling.
- Refactor authority never permits silent bypass of source-of-truth, validation, user approval, or write-boundary rules.

Derogation rule:

- The agent may propose a controlled derogation when a procedural rule blocks the only plausible path.
- It cannot self-approve derogations.
- Strong or ambiguous rule conflicts go to the user with `STOP_FOR_USER`.

Validation rule:

- Runtime refactors require local static CI or JavaScript parse validation at minimum.
- Render-path refactors require launcher/server runtime validation, screenshots when visual risk exists, and relevant counters.
- `refactor-surgeon` does not validate its own work as complete; final readiness requires Team Leader review and/or separate read-only auditor evidence.

## Agent Roles

| Agent | Sandbox | Primary Use | Write Scope |
| --- | --- | --- | --- |
| `code-mapper` | `read-only` | Find real structure, symbols, entry points, and touched blocks. | None. |
| `workflow-guard` | `read-only` | Circuit breaker for unsafe plans, workflow loops, repeated failed methods, and rule conflicts. | None. |
| `workflow-consistency-auditor` | `read-only` | Audits `.md`/TOML/gate/orchestration coherence, hierarchy, permissions, and structural workflow holes. | None. |
| `plan-integrity-auditor` | `read-only` | Audits implementation plans for objective fit, scope, dependencies, validation, success/stop/fallback criteria, and workflow coherence before execution. | None. |
| `task-watchdog` | `read-only` | Long-task governor for checkpoints, progressive failures, restart decisions, and user stop conditions. | None. |
| `skeptic-auditor` | `read-only` | Challenges current plan, surfaces weak assumptions, and proposes grounded plan B/C alternatives. | None. |
| `refactor-surgeon` | `workspace-write` | Emergency unblocker for minimum sufficient, reversible refactors after documented blockage. | Explicit approved files/symbols only; plan-only by default. |
| `regression-auditor` | `read-only` | Identify behavioral and rendering regressions. | None. |
| `performance-auditor` | `read-only` | Identify draw/fps/cache/counter risks. | None. |
| `renderer-block-auditor` | `read-only` | Audit render ordering and cross-block renderer effects. | None. |
| `visual-qa-auditor` | `read-only` | Define and inspect visual validation evidence. | None. |
| `asset-integrity-auditor` | `read-only` | Check manifest, asset paths, missing files, and cache risks. | None. |
| `launcher-sync-auditor` | `read-only` | Check launcher, server, sync scripts, and path-relative behavior. | None. |
| `safe-fixer` | `workspace-write` | Make one narrow approved runtime or tooling patch. | Explicit assigned files only, normally active runtime; `tooling-ci` only when explicitly scoped. |
| `map-maintainer` | `workspace-write` | Update technical maps/indexes/intake after meaningful structural changes. | `PERLA1_PROJECT_MAP.md`, `PERLA1_BLOCK_MAP.md`, `PERLA1_CONTEXT_BUDGET.md`, `PERLA1_SYMBOL_INDEX.md`, and `PERLA1_TASK_INTAKE_PROTOCOL.md` only. |

## Extra Temporary Agents

An extra temporary agent is allowed only when all of these are true:

- the task need is not covered by an existing project agent,
- the Team Leader gives a concrete bounded prompt,
- the agent starts read-only by default,
- any write permission has an explicit file/block ownership boundary,
- the agent is not used to bypass validation, sandbox, or review rules.

Examples:

- external documentation lookup,
- one-off mathematical or geometry check,
- focused browser automation review,
- independent investigation of a user-provided repro.

## Non-Paradox Rules

- Agents do not authorize their own escalation from read-only to write.
- A write agent does not validate its own patch as complete.
- `refactor-surgeon` does not start as a broad refactor authority; it starts plan-only unless an approved scope is explicit.
- `refactor-surgeon` may propose rule conflicts and derogations, but it does not silently bypass or self-approve them.
- `workflow-guard STOP` blocks unsafe execution, but it does not block `refactor-surgeon REFACTOR_PLAN_ONLY` when the purpose is to surface a conflict for user approval.
- `map-maintainer` does not edit `AGENTS.md`, `.codex/config.toml`, `.codex/agents/*.toml`, this orchestration policy, runtime code, launchers, reports, or assets.
- `safe-fixer` does not redefine validation requirements while patching runtime or `tooling-ci` code.
- Static CI does not replace rendered/browser validation for visual runtime changes.
- Generated local CI reports do not become documentation or Git artifacts unless explicitly promoted.
- A Team Leader cannot satisfy a `CALL` agent by saying it was only considered. Missing direct custom-agent tooling requires tool discovery and the Agent Tool Adapter rule first; it becomes `TOOLING_BLOCKED` only after direct invocation and valid generic-role adapter invocation are unavailable or materially unsafe.
- Historical snapshots in `report/` never become the runtime source of truth.
- The current runtime remains `01_GIOCO_PRONTO_LOCAL_TEST/index.html` unless the user explicitly changes the project architecture.
- Browser automation failure does not lower the validation bar; it only changes the tool used to collect evidence.
- `workflow-consistency-auditor` does not patch files or supersede `workflow-guard`; P0/P1 findings must be resolved before the next operational step.
- `plan-integrity-auditor` does not patch files or choose strategy alone; it blocks execution only through `PLAN_REVISION_REQUIRED` or `STOP_FOR_USER` on the selected plan.
- `task-watchdog` does not override `workflow-guard`; if a plan is unsafe, `workflow-guard` wins. If a plan is safe but stale or too long, `task-watchdog` decides checkpoint/replan/stop.
- `skeptic-auditor` does not override `workflow-guard` or `task-watchdog`; it gives the Team Leader alternative plans and evidence tests.
- `scoped_finalization` does not authorize rollback, cleanup, deletion, or staging of unrelated dirty work. It classifies worktree state and protects out-of-scope changes.
- `finalization_gate` does not let a write agent validate its own work. Final readiness still requires Team Leader review and the required separate validation/audit evidence.
- `hook_trust_check` cannot force Codex to trust hooks. It records whether hooks are configured, locally runnable, and trusted/proven active when the platform exposes that evidence.
- `checker_semantic_limit` prevents false confidence: a passing deterministic checker is not proof of visual correctness, user intent, runtime behavior, or complete semantic audit.
- `subagent_task_lifecycle` does not create permanent background agents. It only records owned work units and when to keep/close them.
- If rules conflict, the stricter safety rule wins and `workflow-guard` should return `STOP`.

## Parallelism

Current project limits are defined in `.codex/config.toml`:

- `max_threads = 12`
- `max_depth = 1`
- `job_max_runtime_seconds = 1500`

Use parallel agents only when their tasks are independent or their write scopes are disjoint. If two agents would need the same code block, serialize the write work. Do not use the thread cap as a target to fill, and do not use it as an excuse to skip required `CALL` agents. When the gate requires more agents than can safely run in parallel, batch them by priority without downgrading them.

The timeout is a hard cap. The heartbeat rules above require checkpoint decisions earlier than the cap.

## Required Team Leader Final Check

Before final delivery after meaningful work:

- confirm which blocks changed,
- confirm which files changed,
- run or record `finalization_gate`,
- separate `changed_in_scope`, `changed_out_of_scope`, `generated_or_disposable`, and `untracked_workflow_tooling`,
- record `hook_trust_check` when hook enforcement is part of the claim,
- keep `checker_semantic_limit` visible when relying on deterministic checker output,
- confirm required `CALL` agent outputs through `call_agent_evidence`, or recorded `TOOLING_BLOCKED` state,
- record `subagent_task_lifecycle`, including which subagents were integrated, deferred/discarded, kept open, or closed,
- close no-longer-needed subagents only after Team Leader task completion or packet integration/obsolescence/staleness,
- state what validation ran,
- state what validation remains, if any,
- state whether staging/sync is safe, and use selective staging only when approved scope is clean,
- remind the user to run the parent sync script unless commit/push was handled.
