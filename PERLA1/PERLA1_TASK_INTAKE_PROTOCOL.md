# PERLA1 Task Intake Protocol

Last updated: 2026-06-14

This file is the required startup gate for meaningful PERLA1 work. It forces agent selection before planning, patching, validation, or refactor.

## Core Rule

Every meaningful task must pass through an Agent Selection Gate.

The Team Leader must decide which agents are `CALL`, `CONSIDER`, or `SKIP` for the current task. Agents marked `CALL` must be used before the task step they protect. Agents marked `CONSIDER` do not have to run, but their trigger must be checked.

This gate is meant to force the right agents for the task, not to call every agent blindly.

## Standing Guard Set

For delicate PERLA1 work, the guard agents are not optional monitoring decoration. They are the startup safety layer.

The Standing Guard Set is:

- `workflow-consistency-auditor`;
- `workflow-guard`;
- `plan-integrity-auditor` when an implementation plan, plan approval, alternative selection, rollback strategy, or delicate patch scope is involved;
- `task-watchdog`;
- `skeptic-auditor` when diagnosis, rollback, renderer behavior, refactor, or policy changes are involved.

The Standing Guard Set is `CALL` before the first operational patch, runtime validation, sync, or refactor when any of these are true:

- runtime renderer behavior changes, especially roof, ceiling, rain, sprites, wall occlusion, minimap, performance, or launcher/server route;
- a previous patch failed visually or behaviorally;
- the task asks for rollback, deletion, contract changes, or cleanup of a failed patch stack;
- workflow policy, AGENTS, TOML, orchestration, task intake, or agent rules may change;
- a tool or launcher path failed and the next step depends on choosing a fallback;
- the Team Leader is about to continue after an interrupt, silent wait, no-evidence loop, or user concern about workflow quality.

If the active tool surface exposes only generic subagents, the Standing Guard Set must be satisfied through the Agent Tool Adapter Rule. A generic `explorer` assigned explicitly as `workflow-guard`, `workflow-consistency-auditor`, `plan-integrity-auditor`, or another named read-only guard is acceptable only when its prompt names the role, points to the matching `.codex/agents/<agent>.toml`, and preserves the named agent's read-only scope.

The Team Leader may skip spawning the full Standing Guard Set only for tiny direct answers, simple shell checks, or read-only clarification that cannot affect files, validation claims, sync, or runtime behavior. The final answer must not imply a protected gate ran when it did not.

When a guard agent finds a P0/P1 workflow issue, the next operational patch, validation, sync, or refactor must stop until the issue is resolved or the user explicitly approves a controlled derogation.

User supervision is required before:

- weakening, deleting, or bypassing a safety rule;
- changing which file is source of truth;
- changing a runtime contract after a failed patch series;
- allowing a write agent to touch files outside its documented write scope;
- proceeding with degraded validation after required guard/domain agents are unavailable.

## Task Wall-Clock Limit

Every meaningful `task_id` has a maximum wall-clock runtime of 5 hours unless the user explicitly grants a new budget.

This is a whole-task safety cap, separate from the 12/21 minute heartbeat limits for a single `operation_id` or `logical_step_id`.

At task start, record:

- `task_started_at`;
- `max_task_runtime: 5h`;
- `last_completed_checkpoint`;
- current token/context risk if known.

At every heartbeat checkpoint, update `elapsed_task_time` and `last_completed_checkpoint`.

When elapsed time reaches 4h30m, `task-watchdog` becomes `CALL` and must prepare a checkpoint handoff plan.

When elapsed time reaches 5h:

- do not start any new operational step;
- do not continue only to "finish" the current operation;
- stop at the last completed checkpoint;
- report unfinished work, partial evidence, open files/symbols, validation status, and the safest continuation plan;
- request user approval before resuming with a new budget.

If the current step has already made local edits that are not checkpointed, do not claim them as complete. Report them as partial/unverified work with exact files and required validation. Do not revert user changes, and do not perform extra cleanup unless the user explicitly approves it or the cleanup is already part of a safe checkpoint.

`task-watchdog STOP_FOR_USER` is mandatory at the 5h cap.

## Progress Heartbeat Rule

The Team Leader must not wait silently for a long subagent, browser, runtime, shell, or comparison step.

Before any step that may block, record the expected evidence and a checkpoint limit. For simple comparisons or small audits, the checkpoint limit is 12 minutes per `operation_id` or `logical_step_id`. For complex runtime/workflow steps, the checkpoint limit is 21 minutes per `operation_id` or `logical_step_id`. These limits do not cap the whole user task: a task may legitimately last longer when it is split into checkpoints that produce evidence. The project agent timeout is only a hard ceiling, not permission to stay silent until timeout.

If the checkpoint limit is reached without meaningful new evidence, `task-watchdog` becomes `CALL`. If the next step would repeat the same method, wait for an unknown process, or cannot state what it will prove, `workflow-guard` also becomes `CALL`.

`workflow-guard` is not a background daemon. It is an enforced checkpoint agent: the Team Leader must call it at the defined triggers before continuing.

Large `rg`, diff, or search output is not progress by itself. If a command produces broad/noisy output from `index.html` or another large file, the Team Leader must stop reading raw output, reduce the query or switch to targeted function/block comparison, and summarize only actionable evidence.

`max_threads` is a concurrency budget, not a cap on required agents. The Team Leader must invoke every required `CALL` agent. If a task legitimately needs many agents, including 7 agents and especially more than the configured concurrency budget, use the required agents and batch only when tooling imposes a hard runtime limit. Never downgrade or skip a required `CALL` agent because of `max_threads`.

Checkpoint evidence before retrying must include:

- `task_id`;
- `task_started_at`;
- `elapsed_task_time`;
- `operation_id`;
- `logical_step_id`;
- elapsed time;
- method tried;
- evidence gained;
- next proof target;
- retry count for the same operation/logical step;
- last completed checkpoint;
- allowed next action;
- forbidden next action.

At the 12-minute simple-step limit or 21-minute complex-step limit, this checkpoint is mandatory before another wait, retry, subagent wait, browser attempt, runtime validation attempt, or patch. A generic progress sentence is not enough.

## Complex Task Accelerator Protocol

Use this protocol for complex, high-risk, delicate, multi-agent, runtime, workflow, refactor, failed-patch recovery, or long tasks, and for any task likely to cross one heartbeat checkpoint.

The purpose is to reduce waiting time without reducing depth. It does that by forcing a small proof target, separating critical-path work from sidecar work, and making checkpoints reusable.

Before the first expensive patch, broad validation, long wait, or large agent batch, record a Complex Task Execution Brief:

```text
accelerator_brief:
  objective:
  risk_class:
  current_hypothesis:
  cheapest_discriminating_test:
  critical_path:
  sidecar_tasks:
  serial_constraints:
  first_checkpoint:
  stop_or_replan_condition:
  validation_ladder:
  checkpoint_ledger:
  subagent_task_packets:
```

Definitions:

- `critical_path`: the next proof or change that blocks every other useful step. Keep it local unless a specialist result is strictly required before progress.
- `sidecar_tasks`: independent read-only audits, disjoint file reads, or independent validation checks that can run while the Team Leader advances the critical path.
- `serial_constraints`: same-file writes, same block edits, shared source-of-truth decisions, or tasks where one answer changes the next question. Do not parallelize these.
- `cheapest_discriminating_test`: the smallest command, read, diff, counter, screenshot pose, hook check, or symbol check that can distinguish between plausible hypotheses before a costly patch or validation run.

If two or more plausible routes exist, the cheapest discriminating test is mandatory before selecting the expensive route, unless the user explicitly approves exploratory cost.

The checkpoint ledger is the reusable state for long work:

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

For runtime or visual changes, use a validation ladder instead of jumping directly to the broadest test:

1. static parse or policy check;
2. targeted symbol, counter, debug API, or analyzer focus;
3. targeted screenshot or deterministic pose;
4. regression poses and acceptance screenshots;
5. broader validation only when the changed surface justifies it.

Broad search limit: after 1-2 broad `rg`, diff, or search passes without decision-grade evidence, stop broad searching and narrow to named symbols, block ids, line windows, analyzer focus, or deterministic comparison. Raw output volume is not progress.

Every delegated complex-task subagent needs a standard task packet:

```text
subagent_task_packet:
  required_agent:
  tool_used:
  role:
  file_or_block_scope:
  exact_question:
  max_output:
  forbidden_actions:
  path_classification: critical_path/sidecar/serial
  checkpoint_deadline:
  expected_evidence:
```

A subagent packet is invalid if it asks for broad exploration without a concrete question, gives write authority without disjoint ownership, or lets a sidecar task block the critical path without a stated dependency.

## Sidecar Result Integration Protocol

Use this protocol whenever a sidecar subagent, read-only audit, validation helper, or parallel tool result returns while the Team Leader is still advancing the `critical_path`.

The purpose is to integrate useful parallel evidence without letting every sidecar response interrupt or stall the main flow.

For each returning sidecar result, record a compact integration decision:

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

Decision meanings:

- `integrate`: use the result now because it changes the next useful action, reduces risk, or confirms the current path.
- `defer`: keep the result in the `checkpoint_ledger` because it is useful later but does not affect the current `critical_path`.
- `discard`: ignore the result as non-actionable, duplicate, stale, out of scope, or unsupported; record why if it could otherwise create confusion.
- `replan`: revise the active plan because the result changes hypothesis, scope, validation, or dependency ordering.
- `stop`: call `workflow-guard`, `task-watchdog`, or the user because the result exposes unsafe scope, missing approval, invalid validation, source-of-truth conflict, or a blocking contradiction.

Sidecar integration rules:

- A sidecar result must not interrupt the `critical_path` unless `affects_critical_path: yes`, `result_status: blocking/conflicting`, or the original packet declared an explicit dependency.
- `dependency_on_critical_path: yes` is valid only when the original `subagent_task_packet` declared that dependency or a later checkpoint explicitly reclassified it.
- A `no_change` result should usually become `defer` or `discard`, not a new analysis loop.
- A `conflicting` result must identify the conflict and the cheapest discriminating test before replan or stop.
- A `blocking` result must name the rule, file, validation route, dependency, or approval that blocks continuation.
- Every `integrate`, `defer`, or `replan` decision must update `checkpoint_ledger` when the evidence may matter later.
- A sidecar result cannot authorize writes, broaden scope, lower validation, or bypass a required `CALL` agent. If it implies any of those, use `stop`.
- `accepted_into_plan: yes` is allowed only after checking `validation_impact`, `write_scope_impact`, `approval_impact`, and Agent Tool Adapter mapping when the result comes from a generic subagent.

## User Intake Relay Protocol

Use this protocol when the user sends a message during active, long, delicate, multi-agent, runtime, workflow, refactor, or validation work.

The purpose is to keep user requests visible and actionable without turning a liaison or sidecar into a background daemon, approval authority, or alternate Team Leader.

For each relevant user message, record a compact intake decision:

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

Message handling rules:

- A `status_request` should be answered from the current checkpoint, command state, agent state, or `checkpoint_ledger` without stopping the `critical_path` when no decision changes.
- `new_requirement`, `correction`, `scope_change`, `validation_request`, `priority_change`, or `approval` must be checked before the next operational step if they affect objective, scope, source of truth, validation, write authority, agent gate, Agent Tool Adapter, or user approval.
- `blocker` or `stop_request` sets `must_interrupt: yes` and requires `checkpoint`, `replan`, or `stop` before continuing.
- `must_report_to_team_leader: yes` means the note must enter `checkpoint_ledger` and be read before the next patch, runtime validation, sync, refactor application, or final readiness claim.
- A relay or sidecar may classify a user message, but cannot approve writes, lower validation, satisfy missing `CALL` agents, change source of truth, or override the Team Leader, `workflow-guard`, `task-watchdog`, or explicit user approval rules.
- `message_class: approval` only means the original user message appears to contain approval. The relay does not grant approval; the Team Leader must verify original user intent plus `approval_impact`, `write_scope_impact`, and `validation_impact` before acting.
- This protocol does not promise a persistent background listener. If the active tool surface cannot process the message until the Team Leader returns from a blocking tool call, the next checkpoint must classify the message before continuing.
- If the message changes the plan while sidecar work is active, also use Sidecar Result Integration for any returned sidecar evidence that is affected by the new user input.
- Use `stop` when the message asks to stop/pause, changes objective/source of truth, requires degraded validation, grants or denies approval needed by the plan, conflicts with the current plan, requires broader write scope, arrives at the 5h cap, or would make continuing unsafe without user confirmation.
- Use `checkpoint` or `replan` when the message changes scope, validation route, priority, agent gate, Agent Tool Adapter state, or critical path but does not require explicit stop.

## Operational Agent Rule

`CALL` means operational delegation, not mental consideration.

The user gives standing PERLA1 authorization to use the configured project subagents selected by this protocol. A Team Leader must not downgrade a required `CALL` agent to `CONSIDER` only because it did not ask the user again.

This project authorization does not override higher-priority Codex tool-surface rules. If the active tool surface requires explicit user delegation before spawning subagents, obtain it or stop with `TOOLING_BLOCKED` before patching, runtime validation, sync, or refactor application.

If subagent or multi-agent tooling is not currently loaded, the Team Leader must first use the available tool-discovery mechanism when present, then apply the Agent Tool Adapter Rule if generic subagents are available. Only if direct invocation, role-assigned generic invocation, and approved degraded read-only self-audit are all unavailable or rejected may the Team Leader record `TOOLING_BLOCKED`, list the blocked `CALL` agents, and stop before patching, runtime validation, sync, or refactor application.

## Agent Tool Adapter Rule

PERLA1 names project agents by role, such as `workflow-consistency-auditor`, `workflow-guard`, or `visual-qa-auditor`. The active Codex tool surface may expose those custom agents directly, or it may expose only generic subagent types such as `explorer` and `worker`.

TOML `name` and `description` define the precise PERLA1 role identity and instructions. They do not guarantee the Codex UI display name, generated nickname, icon, or direct callability; those depend on the active Codex tool surface.

A required named `CALL` agent is satisfied only by one of these:

- direct invocation of the matching project agent;
- a generic subagent explicitly assigned that named role, instructed to read and follow the matching `.codex/agents/<agent>.toml` plus required PERLA1 docs, with read/write scope matching the named agent;
- a declared `TOOLING_BLOCKED` stop.

Before declaring `TOOLING_BLOCKED`, the Team Leader must try this adapter rule when any generic subagent surface is available. A missing custom agent name is not a block if an available generic `explorer` or `worker` can be role-assigned to the named agent, pointed to the matching TOML instructions, and constrained to the same read/write scope.

When a generic subagent is used as an adapter, the Team Leader must record the mapping:

```text
agent_tool_mapping:
- required_agent:
  tool_used:
  spawned_type:
  instruction_source:
  audit_mode_if_any:
  sandbox_or_scope:
  output_decision:
  degraded_capability:
  status:
```

Using a generic `explorer` or `worker` without explicit role assignment and TOML instruction source does not satisfy a named `CALL` agent.

For write agents, a generic `worker` receives write authority only when the named TOML role permits write access and the Team Leader records explicit approved files/symbols/scope. Otherwise the adapted role is read-only.

If neither direct custom-agent invocation nor role-assigned generic subagent invocation is possible, the Team Leader may perform only the minimum read-only classification needed to report `TOOLING_BLOCKED`. This does not satisfy the gate and does not permit patching, runtime validation, sync, or refactor application.

Self-performing the work of a required `CALL` agent is allowed only as an explicit degraded fallback after `workflow-guard` and `workflow-consistency-auditor` have recorded the tooling block and the Team Leader or user has accepted the reduced validation state. The final answer must keep that residual risk visible.

## Subagent Task Lifecycle

Use `subagent_task_lifecycle` for every delegated agent in a meaningful PERLA1 task.

A subagent is a task resource owned by the Team Leader, not a permanent service and not a per-step disposable unless its whole assigned task is complete or unsafe to continue.

Lifecycle record:

```text
subagent_task_lifecycle:
  agent:
  agent_id:
  required_agent:
  task_id:
  operation_id:
  logical_step_id:
  packet_ref:
  status: planned/running/returned/integrated/closed/stale/aborted
  result_integrated: yes/no
  final_sidecar_integration_ref:
  close_condition:
  close_at_team_task_completion: yes/no
  closed_by:
  closed_at:
  residual_ui_history: yes/no
```

Rules:

- Do not close a useful subagent merely because one internal step finished. Keep it open while its assigned task can still contribute to the Team Leader's current task.
- Close a subagent when the Team Leader task is complete, when its assigned packet is fully integrated and no follow-up is needed, when the plan changes so the packet is obsolete, or when it is stale/aborted and recorded as such.
- Before closing, integrate or explicitly defer/discard its latest result through `sidecar_result_integration` when it produced evidence that could affect the plan.
- After final delivery for a task that used subagents, the Team Leader must close no-longer-needed subagents that are still open in the active tool surface. UI history may remain visible; that is not evidence that the agent is still running.
- A closed or stale UI record must not be counted as active work unless the tool surface reports it as running or pending work that can still produce output.

## Machine Enforcement Gate

For workflow-policy, TOML, AGENTS, orchestration, hook, launcher/sync, or agent-rule changes, run the executable workflow check before final delivery when practical:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\tools\perla_codex_workflow_check.ps1 -Mode CI -Json
```

The deterministic check emits schema `perla.workflow.check.v1`. Use `-Json` for one summary object or `-Jsonl` when a pipeline needs one event per check plus a final summary. Exit code `1` is blocking for P0/P1 failures or for any non-pass status when `-Strict` is used.

For scripted Codex review, use `codex exec --json` so the audit stream can be captured as JSONL. This supplements the deterministic PowerShell check; it does not replace the required project agents selected by the gate.

Root `.codex/hooks.json` runs the same check on Codex `Stop`, `SubagentStart`, and `SubagentStop` events after the hook is loaded and trusted by Codex. Hook output is lifecycle evidence, not evidence that agents are continuously running. Hooks are not background daemons and are not a substitute for spawning/directing required `CALL` agents.

If the hook reports a P0/P1 failure, the next operational patch, runtime validation, refactor application, or sync must stop until the failure is fixed or the user explicitly approves a controlled derogation.

### Hook Trust Check

`hook_trust_check` is required before relying on hooks as enforcement evidence for workflow-policy, TOML, AGENTS, orchestration, hook, launcher/sync, or agent-rule changes.

Record:

```text
hook_trust_check:
  hook_file:
  events_expected: Stop/SubagentStart/SubagentStop
  validator_target:
  static_safety_check:
  local_manual_run:
  codex_trust_status: trusted/untrusted/unknown/platform-managed
  enforcement_assumption:
  fallback_if_untrusted:
```

Rules:

- A committed `.codex/hooks.json` means hooks are configured, not necessarily trusted by the current Codex client.
- If `codex_trust_status` is `untrusted` or `unknown`, run the workflow checker manually before final claims and do not claim hook enforcement is active.
- The fallback for untrusted hooks is manual `perla_codex_workflow_check.ps1` evidence plus required guard/audit agents; never pretend that hooks ran.

### Checker Semantic Limit

`checker_semantic_limit` must stay explicit. The deterministic checker proves only mechanically inspectable contracts: file presence, JSON parse, known terms, TOML schema, configured limits, hook command shape, and forbidden obvious claims. It cannot prove the whole semantic correctness of a plan, visual runtime behavior, user intent, or whether an agent truly reasoned well.

Mitigation:

- Use the checker for deterministic P0/P1 drift.
- Use `workflow-consistency-auditor` for hierarchy, permission, and cross-document meaning.
- Use `workflow-guard` for loop/current-step safety.
- Use `plan-integrity-auditor`, `task-watchdog`, and domain auditors when their triggers fire.
- Do not replace audit agents with grep-style checks and do not treat audit agents as substitutes for deterministic checks.

## Scoped Finalization Gate

Use `scoped_finalization` and `finalization_gate` before final delivery, staging, sync, or any claim that a meaningful patch is ready.

The purpose is dirty worktree separation: finish the approved scope without absorbing unrelated runtime, launcher, report, generated, or user edits.

Record:

```text
finalization_gate:
  task_id:
  approved_scope:
  changed_in_scope:
  changed_out_of_scope:
  generated_or_disposable:
  untracked_workflow_tooling:
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

Rules:

- Never use global staging, broad cleanup, or unrelated revert as a finalization shortcut.
- If the worktree is dirty, separate `changed_in_scope`, `changed_out_of_scope`, and `generated_or_disposable` before final claims.
- Stage or sync only files in the approved scope, and only after user approval when the repository contains meaningful unrelated changes.
- Runtime/launcher/report changes outside the approved workflow scope remain out of scope and must be named as residual risk if they affect sync safety.
- Final delivery must say which validation ran and which relevant validation did not run.
- Before final delivery, close subagents only when the Team Leader's task is complete or their assigned packet is fully integrated/obsolete; do not close active subagents just because an internal step ended.

## Workflow Tooling Manifest

`workflow_tooling_manifest` distinguishes project workflow tools from disposable outputs.

Tracked workflow tooling candidates:

- `PERLA1/tools/perla_codex_workflow_check.ps1`
- `PERLA1/tools/perla_local_ci.ps1`
- `PERLA1/tools/perla_runtime_analyzer.mjs`
- `PERLA1/.codex/config.toml`
- `PERLA1/.codex/ORCHESTRATION.md`
- `PERLA1/.codex/agents/*.toml`
- `PERLA1/tests/perla_regression_suite.json`
- `PERLA1/01_GIOCO_PRONTO_LOCAL_TEST/src/module-boundaries.json`
- `PERLA1/01_GIOCO_PRONTO_LOCAL_TEST/src/README.md`

Disposable unless explicitly promoted:

- `PERLA1/report/WORKFLOW_CHECK_*.json`
- `PERLA1/report/WORKFLOW_CHECK_*.jsonl`
- `PERLA1/report/CODEX_EXEC_*.jsonl`
- `PERLA1/report/HOOK_*.log`
- local screenshots, temporary server logs, and one-off generated analyzer reports.

Rules:

- Tooling files that enforce workflow, CI, analyzer contracts, or subagent configuration should be made tracciable/salvabile when they are part of the approved system scope.
- Generated evidence remains disposable unless the user explicitly asks to promote that artifact.
- `PERLA1/tools/` is not automatically all in scope: classify each file as tracked tooling, disposable output, or out-of-scope before staging/sync.

## Mandatory Gate

Before meaningful work, define:

- `task_id`;
- likely `operation_id`;
- likely `logical_step_id`;
- changed or inspected files;
- impacted block ids, if runtime is involved;
- expected validation route;
- agent matrix.

If a value is unknown, mark it as `Da indagare` and assign `code-mapper` when structure matters.

## Always Gate Agents

These agents are always present in the gate. `workflow-consistency-auditor` is always `CALL` for explicit gates; the others are always at least `CONSIDER`.

| Agent | Default | Must Call When |
| --- | --- | --- |
| `workflow-guard` | `CONSIDER` | Rule conflict, repeated method, unsafe validation, write-scope conflict, first deterministic tool failure before retry, refactor application, missing heartbeat, silent wait past checkpoint, or next step cannot produce new evidence. |
| `workflow-consistency-auditor` | `CALL` | Every explicit Agent Selection Gate. Use lightweight gate audit for ordinary tasks; use full audit for `.md`/`.toml`/agent/rule/gate/orchestration changes, suspected hierarchy conflict, missing agent, permission paradox, or before sync after workflow-policy changes. |
| `plan-integrity-auditor` | `CONSIDER` | Explicit multi-step plan, user-approved plan before execution, alternatives/strategy choice, delicate runtime/launcher/workflow/refactor/rollback work, failed-patch recovery, or any plan that changes validation requirements, runtime contracts, or agent/workflow rules. |
| `task-watchdog` | `CONSIDER` | Multi-step/long task, any subagent/tool job expected to exceed 12-21 minutes, any job timeout, simple task with no evidence after 12 minutes, complex task with no evidence after 21 minutes, task elapsed time reaches 4h30m, task elapsed time reaches 5h, three no-evidence cycles on one `logical_step_id`, first/second long failure, checkpoint needed, or unclear proof target. |
| `skeptic-auditor` | `CONSIDER` | Complex or high-risk task, uncertain diagnosis, multiple plausible plans, long/failing attempt, refactor plan, or critical renderer/runtime change. |
| `refactor-surgeon` | `CONSIDER` | Documented blockage where ordinary patching cannot progress. Default mode is `REFACTOR_PLAN_ONLY`; applying requires explicit approved scope. |

## Delicate Task Governance Preflight

For delicate tasks, both `workflow-consistency-auditor` and `workflow-guard` are `CALL` before the protected step.

Delicate tasks include workflow policy changes, TOML agent changes, permissions or hierarchy changes, runtime validation route changes, GitHub sync after policy changes, refactor planning/application, critical renderer/runtime changes, failed-patch rollback, and any task where agent availability or authority is uncertain.

`workflow-consistency-auditor` checks whether the rules and adapter mapping are coherent. `workflow-guard` checks whether the next operational step is safe to execute. `plan-integrity-auditor` checks whether the proposed plan is objective-fit, scoped, dependency-complete, and verifiable before execution. These agents may be satisfied through direct named agents or valid Agent Tool Adapter mappings.

## Domain Agent Matrix

| Task Signal | Agent | Default |
| --- | --- | --- |
| Unknown structure, symbols, ownership, or line hints | `code-mapper` | `CALL` |
| Runtime renderer order, buffers, roof, sprites, rain, minimap | `renderer-block-auditor` | `CALL` |
| Behavior regression or invariant risk | `regression-auditor` | `CALL` |
| Performance, counters, draw cost, cache/hotspot risk | `performance-auditor` | `CALL` |
| Screenshot, rendered QA, browser/runtime validation | `visual-qa-auditor` | `CALL` |
| Assets, manifest, paths, missing textures | `asset-integrity-auditor` | `CALL` |
| Launcher, server, sync, GitHub Desktop Git fallback | `launcher-sync-auditor` | `CALL` |
| Static CI, analyzer, dependency graph, regression suite, modularization scaffold, generated structure reports | `code-mapper`, `regression-auditor`, `launcher-sync-auditor` | `CALL` according to changed file and validation route |
| Workflow docs, TOML agents, gate, orchestration, hierarchy | `workflow-consistency-auditor` | `CALL` |
| Implementation plan quality, objective fit, success/stop/fallback criteria, or plan approval before execution | `plan-integrity-auditor` | `CALL` for delicate, multi-step, failed-patch, rollback, refactor, workflow-policy, or alternatives-based work |
| Current plan needs challenge or alternatives | `skeptic-auditor` | `CALL` for complex/high-risk/uncertain work |
| Narrow approved code patch | `safe-fixer` | `CALL` only after diagnosis and scope are clear |
| Map/index/context updates | `map-maintainer` | `CALL` only for allowed docs |
| Documented blockage requiring structural change | `refactor-surgeon` | `CALL` only in `REFACTOR_PLAN_ONLY` unless explicit apply approval exists |

## Required Intake Output

Use this compact form in the Team Leader scratchpad or handoff:

```text
task_id:
task_started_at:
elapsed_task_time:
max_task_runtime:
operation_id:
logical_step_id:
last_completed_checkpoint:
impacted_blocks:
files_expected:
validation_route:
agent_tool_mapping:
agents:
- workflow-guard: CONSIDER/CALL/SKIP - reason
- workflow-consistency-auditor: CALL - reason
- plan-integrity-auditor: CONSIDER/CALL/SKIP - reason
- task-watchdog: CONSIDER/CALL/SKIP - reason
- skeptic-auditor: CONSIDER/CALL/SKIP - reason
- refactor-surgeon: CONSIDER/CALL/SKIP - reason
- code-mapper: CONSIDER/CALL/SKIP - reason
- renderer-block-auditor: CONSIDER/CALL/SKIP - reason
- regression-auditor: CONSIDER/CALL/SKIP - reason
- performance-auditor: CONSIDER/CALL/SKIP - reason
- visual-qa-auditor: CONSIDER/CALL/SKIP - reason
- asset-integrity-auditor: CONSIDER/CALL/SKIP - reason
- launcher-sync-auditor: CONSIDER/CALL/SKIP - reason
- safe-fixer: CONSIDER/CALL/SKIP - reason
- map-maintainer: CONSIDER/CALL/SKIP - reason
```

For tiny direct answers or simple shell checks, the gate can stay implicit. For code edits, runtime validation, multi-agent work, or refactor, it must be explicit.

## Anti-Paradox Rules

- `workflow-guard STOP` blocks unsafe execution, not plan-only analysis that is explicitly meant to surface the conflict.
- `workflow-consistency-auditor` is `CALL` for every explicit gate. `STOP_NEXT_STEP` or `STOP_FOR_USER` must be resolved before the next operational patch, validation, sync, or refactor application.
- `plan-integrity-auditor PLAN_REVISION_REQUIRED` blocks the next operational patch, validation, sync, or refactor application until the plan is corrected. `STOP_FOR_USER` requires a user choice or approval before execution.
- `refactor-surgeon REFACTOR_PLAN_ONLY` may be used after blockage to propose scope and derogations.
- `refactor-surgeon APPLY_APPROVED_REFACTOR` is forbidden without explicit approved files/symbols/scope.
- `task-watchdog STOP_FOR_USER` requires user approval before another long attempt on the same `operation_id` or `logical_step_id`.
- `task-watchdog STOP_FOR_USER` is mandatory when a `task_id` reaches the 5h wall-clock cap. Continuing requires explicit user approval with a new budget.
- `skeptic-auditor` challenges plans and proposes alternatives, but it does not block execution by itself.
- `plan-integrity-auditor` audits whether a selected/proposed plan is executable and aligned with the objective; it does not replace `skeptic-auditor` for strategy alternatives or `workflow-guard` for circuit-breaking.
- `CALL` agents do not approve their own write work as complete.
- `safe-fixer` and `refactor-surgeon APPLY_APPROVED_REFACTOR` must refuse to patch when there is no evidence that the gate ran and their file/symbol scope was approved.
- Gate evidence must include actual output from every required `CALL` agent, or a declared `TOOLING_BLOCKED` stop. A matrix that only says an agent was "considered" does not satisfy a `CALL`.
- If two `CALL` agents would write the same file or block, serialize the work.
- `TOOLING_BLOCKED` is valid only after adapter options are exhausted. If a generic subagent can faithfully assume the named role with the matching TOML and scope, the gate is degraded-but-satisfied, not blocked.
- If a higher-priority Codex tool-surface rule requires explicit user delegation before spawning subagents and that delegation is missing, `TOOLING_BLOCKED` is valid even when generic subagents technically exist.
- If the blocked agents are governance agents themselves and no subagent surface exists, the Team Leader may perform a read-only governance self-audit only to prepare a user supervision request. It must not silently continue to patch, validate, sync, or refactor unless the user accepts the reduced assurance.
