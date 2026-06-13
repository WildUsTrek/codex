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
10. Assign write work only after diagnosis is clear.
11. Keep write scopes disjoint when multiple agents are active.
12. Validate through the PERLA1 launcher/server route for runtime behavior changes.
13. Update technical maps/indexes only when structure, contracts, validation, tooling, symbol hints, or recurring risks change.

## Agent Selection Gate

Use `PERLA1_TASK_INTAKE_PROTOCOL.md` before meaningful work.

- `workflow-consistency-auditor` is `CALL` for every explicit gate; it can run a lightweight gate audit when policy files are not changing.
- `workflow-guard`, `task-watchdog`, `skeptic-auditor`, and `refactor-surgeon` are always at least `CONSIDER`.
- Domain agents are `CALL` when their task signal matches the current work.
- `CALL` means the agent must actually be invoked or delegated before the protected step. It cannot be treated as a passive checklist item.
- The user has standing project authorization for PERLA1 configured subagents selected by the gate. Do not require a fresh user sentence before using a required project agent.
- If subagent tooling is not visible, first use tool discovery when available. If the required agent still cannot be invoked, return `TOOLING_BLOCKED` with the blocked agents and stop before patching, runtime validation, sync, or refactor application.
- A write agent is never `CALL` until diagnosis, scope, and ownership are clear.
- Write agents must refuse to patch if there is no evidence that the Agent Selection Gate ran and their file/symbol scope was approved.
- If an agent is relevant but not called, the Team Leader must have a concrete reason.
- The gate can stay implicit only for tiny direct answers or simple shell checks.

## Context Budget Protocol

Use `PERLA1_CONTEXT_BUDGET.md` when work touches the monolithic runtime or when subagents are active.

- Context budget controls what is returned to the main thread, not what an agent may inspect in the repository.
- Agents should start from maps and symbol hints, then use `rg` and targeted reads.
- If a local window is not enough, agents may inspect a larger caller/callee chain or cross-block renderer path.
- The Team Leader may request deeper detail, a longer extract, or a second pass when the first handoff is insufficient.
- Handoffs must include read scope, symbols, line hints, evidence, unknowns, and next action.
- Raw monolith dumps and repeated searches without a new hypothesis are workflow risks; consult `workflow-guard`.

## Runtime Server Requirement

Rendered PERLA1 validation requires the local PowerShell server. Browser automation alone cannot serve the game.

Required route:

- Start `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`, which calls `AVVIA_GIOCO_SERVER_POWERSHELL.ps1` on port `8000`.
- Or explicitly confirm that an existing launcher-started PERLA1 server is already responding at `http://127.0.0.1:8000/`.
- Then load `http://127.0.0.1:8000/` with a cache-busting query string.

Do not validate rendered runtime behavior with `file://`, by opening `index.html` directly, or by asking a browser agent to navigate before the server is running. If the server is not running and the agent cannot launch it, the correct output is a server-start handoff, not a failed runtime diagnosis.

## Browser Fallback Protocol

Rendered runtime validation should use the proven Windows path in `PERLA1_RUNTIME_TEST_RUNBOOK.md` first unless the user specifically asks to test another browser path.

Known reliable automated method:

- `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat` starts the server.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 ...` captures `#screen` with system Chrome/Edge through Playwright.
- Screenshots default to `%TEMP%`, not the Git repository.

Other browser paths are secondary attempts. A Browser bootstrap failure is a tooling failure, not proof that the PERLA1 runtime is broken.

Known tooling failure class:

- `CreateProcessAsUserW failed: 5`
- Windows sandbox or permission errors while launching/attaching the in-app Browser
- Browser plugin connection failure before page navigation

When this happens:

1. Confirm the PERLA1 launcher/server route is running, or hand off startup via `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`.
2. Keep the validation target identical: `http://127.0.0.1:8000/` with a cache-busting query string.
3. Record the Browser failure class briefly.
4. Use `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 ...` or equivalent Playwright/system Chrome headless flow.
5. If headless browser validation also fails, provide a manual validation handoff with exact URL, launcher to run, expected `window.PERLA_BUILD_ID`, debug poses, screenshots to capture, and counters/API calls to read.
6. Do not mark a rendered fix as fully validated unless visual evidence and relevant counters were actually inspected.

Subagents should not attempt to open Chrome, Edge, or external GUI browsers directly unless the Team Leader explicitly assigns that fallback path. Do not repeatedly retry known-failing methods before using the runbook method.

## Workflow Circuit Breaker

Use `workflow-guard` as the official loop detector and circuit breaker when a workflow shows repeated failure, tool drift, or validation uncertainty.

Call or consult it before continuing when any of these occur:

- the same method failed twice without new evidence;
- in-app Browser failed with `CreateProcessAsUserW failed: 5`;
- runtime validation was attempted before the launcher/server was running;
- Playwright failed because `NODE_PATH` or browser executable resolution was wrong;
- a `.ps1` helper failed due Windows execution policy;
- an agent proposes `file://` or direct `index.html` validation;
- a write agent tries to validate its own change as complete;
- a patch touches roofs/ceilings/rain/sprites without the required visual and counter proof;
- multiple agents may write the same runtime block.

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

- three progressive failures or no-evidence cycles on the same `logical_step_id`;
- first long failure on the same operation/logical step;
- second long failure on the same operation/logical step;
- 30-45 minutes without meaningful new evidence;
- inability to state what the next step is trying to prove.

Failure brief rule:

- On `CHECKPOINT`, `REPLAN`, `STOP_FOR_USER`, or `ESCALATE`, the watchdog must request or define a failure brief if evidence is scattered.
- The Team Leader assigns the brief to the best read-only specialist: `code-mapper`, `renderer-block-auditor`, `regression-auditor`, `performance-auditor`, `visual-qa-auditor`, `asset-integrity-auditor`, or `launcher-sync-auditor`.
- The brief must include attempted objective, operation/logical ids, checkpoint id, methods tried, evidence collected, what is excluded, unknowns, best restart checkpoint, and two or three real continuation plans with cost/risk.

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

- Runtime refactors require JavaScript parse validation at minimum.
- Render-path refactors require launcher/server runtime validation, screenshots when visual risk exists, and relevant counters.
- `refactor-surgeon` does not validate its own work as complete; final readiness requires Team Leader review and/or separate read-only auditor evidence.

## Agent Roles

| Agent | Sandbox | Primary Use | Write Scope |
| --- | --- | --- | --- |
| `code-mapper` | `read-only` | Find real structure, symbols, entry points, and touched blocks. | None. |
| `workflow-guard` | `read-only` | Circuit breaker for unsafe plans, workflow loops, repeated failed methods, and rule conflicts. | None. |
| `workflow-consistency-auditor` | `read-only` | Audits `.md`/TOML/gate/orchestration coherence, hierarchy, permissions, and structural workflow holes. | None. |
| `task-watchdog` | `read-only` | Long-task governor for checkpoints, progressive failures, restart decisions, and user stop conditions. | None. |
| `skeptic-auditor` | `read-only` | Challenges current plan, surfaces weak assumptions, and proposes grounded plan B/C alternatives. | None. |
| `refactor-surgeon` | `workspace-write` | Emergency unblocker for minimum sufficient, reversible refactors after documented blockage. | Explicit approved files/symbols only; plan-only by default. |
| `regression-auditor` | `read-only` | Identify behavioral and rendering regressions. | None. |
| `performance-auditor` | `read-only` | Identify draw/fps/cache/counter risks. | None. |
| `renderer-block-auditor` | `read-only` | Audit render ordering and cross-block renderer effects. | None. |
| `visual-qa-auditor` | `read-only` | Define and inspect visual validation evidence. | None. |
| `asset-integrity-auditor` | `read-only` | Check manifest, asset paths, missing files, and cache risks. | None. |
| `launcher-sync-auditor` | `read-only` | Check launcher, server, sync scripts, and path-relative behavior. | None. |
| `safe-fixer` | `workspace-write` | Make one narrow approved code patch. | Explicit assigned files only, normally active runtime. |
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
- `safe-fixer` does not redefine validation requirements while patching runtime code.
- A Team Leader cannot satisfy a `CALL` agent by saying it was only considered. Missing subagent tooling is a workflow block, not approval to bypass the gate.
- Historical snapshots in `report/` never become the runtime source of truth.
- The current runtime remains `01_GIOCO_PRONTO_LOCAL_TEST/index.html` unless the user explicitly changes the project architecture.
- Browser automation failure does not lower the validation bar; it only changes the tool used to collect evidence.
- `workflow-consistency-auditor` does not patch files or supersede `workflow-guard`; P0/P1 findings must be resolved before the next operational step.
- `task-watchdog` does not override `workflow-guard`; if a plan is unsafe, `workflow-guard` wins. If a plan is safe but stale or too long, `task-watchdog` decides checkpoint/replan/stop.
- `skeptic-auditor` does not override `workflow-guard` or `task-watchdog`; it gives the Team Leader alternative plans and evidence tests.
- If rules conflict, the stricter safety rule wins and `workflow-guard` should return `STOP`.

## Parallelism

Current project limits are defined in `.codex/config.toml`:

- `max_threads = 4`
- `max_depth = 1`
- `job_max_runtime_seconds = 2400`

Use parallel agents only when their tasks are independent or their write scopes are disjoint. If two agents would need the same code block, serialize the work.

## Required Team Leader Final Check

Before final delivery after meaningful work:

- confirm which blocks changed,
- confirm which files changed,
- state what validation ran,
- state what validation remains, if any,
- remind the user to run the parent sync script unless commit/push was handled.
