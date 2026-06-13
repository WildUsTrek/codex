# PERLA1 Task Intake Protocol

Last updated: 2026-06-14

This file is the required startup gate for meaningful PERLA1 work. It forces agent selection before planning, patching, validation, or refactor.

## Core Rule

Every meaningful task must pass through an Agent Selection Gate.

The Team Leader must decide which agents are `CALL`, `CONSIDER`, or `SKIP` for the current task. Agents marked `CALL` must be used before the task step they protect. Agents marked `CONSIDER` do not have to run, but their trigger must be checked.

This gate is meant to force the right agents for the task, not to call every agent blindly.

## Operational Agent Rule

`CALL` means operational delegation, not mental consideration.

The user gives standing PERLA1 authorization to use the configured project subagents selected by this protocol. A Team Leader must not downgrade a required `CALL` agent to `CONSIDER` only because it did not ask the user again.

If subagent or multi-agent tooling is not currently loaded, the Team Leader must first use the available tool-discovery mechanism when present. If the required agent still cannot be invoked, the gate is not satisfied: record `TOOLING_BLOCKED`, list the blocked `CALL` agents, and stop before patching, runtime validation, sync, or refactor application.

Self-performing the work of a required `CALL` agent is allowed only as an explicit degraded fallback after `workflow-guard` and `workflow-consistency-auditor` have recorded the tooling block and the Team Leader or user has accepted the reduced validation state. The final answer must keep that residual risk visible.

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
| `workflow-guard` | `CONSIDER` | Rule conflict, repeated method, unsafe validation, write-scope conflict, deterministic tool failure, refactor application, or next step cannot produce new evidence. |
| `workflow-consistency-auditor` | `CALL` | Every explicit Agent Selection Gate. Use lightweight gate audit for ordinary tasks; use full audit for `.md`/`.toml`/agent/rule/gate/orchestration changes, suspected hierarchy conflict, missing agent, permission paradox, or before sync after workflow-policy changes. |
| `task-watchdog` | `CONSIDER` | Multi-step/long task, three no-evidence cycles on one `logical_step_id`, first/second long failure, checkpoint needed, or unclear proof target. |
| `skeptic-auditor` | `CONSIDER` | Complex or high-risk task, uncertain diagnosis, multiple plausible plans, long/failing attempt, refactor plan, or critical renderer/runtime change. |
| `refactor-surgeon` | `CONSIDER` | Documented blockage where ordinary patching cannot progress. Default mode is `REFACTOR_PLAN_ONLY`; applying requires explicit approved scope. |

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
| Workflow docs, TOML agents, gate, orchestration, hierarchy | `workflow-consistency-auditor` | `CALL` |
| Current plan needs challenge or alternatives | `skeptic-auditor` | `CALL` for complex/high-risk/uncertain work |
| Narrow approved code patch | `safe-fixer` | `CALL` only after diagnosis and scope are clear |
| Map/index/context updates | `map-maintainer` | `CALL` only for allowed docs |
| Documented blockage requiring structural change | `refactor-surgeon` | `CALL` only in `REFACTOR_PLAN_ONLY` unless explicit apply approval exists |

## Required Intake Output

Use this compact form in the Team Leader scratchpad or handoff:

```text
task_id:
operation_id:
logical_step_id:
impacted_blocks:
files_expected:
validation_route:
agents:
- workflow-guard: CONSIDER/CALL/SKIP - reason
- workflow-consistency-auditor: CALL - reason
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
- `refactor-surgeon REFACTOR_PLAN_ONLY` may be used after blockage to propose scope and derogations.
- `refactor-surgeon APPLY_APPROVED_REFACTOR` is forbidden without explicit approved files/symbols/scope.
- `task-watchdog STOP_FOR_USER` requires user approval before another long attempt on the same `operation_id` or `logical_step_id`.
- `skeptic-auditor` challenges plans and proposes alternatives, but it does not block execution by itself.
- `CALL` agents do not approve their own write work as complete.
- `safe-fixer` and `refactor-surgeon APPLY_APPROVED_REFACTOR` must refuse to patch when there is no evidence that the gate ran and their file/symbol scope was approved.
- Gate evidence must include actual output from every required `CALL` agent, or a declared `TOOLING_BLOCKED` stop. A matrix that only says an agent was "considered" does not satisfy a `CALL`.
- If two `CALL` agents would write the same file or block, serialize the work.
