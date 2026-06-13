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
5. Automation: full-file parse/search/indexing is allowed, but do not paste full-file output into the main thread.

Line-window sizes are defaults, not hard safety limits. If 120 lines are insufficient, read more. The safety rule is to report compact evidence, not to remain under-informed.

## Reporting Model

Agent handoffs should include enough detail for the Team Leader to decide the next step:

- files read;
- symbols and line hints verified from the current repository;
- block ids involved;
- read scope, for example `local function window`, `caller/callee chain`, or `cross-block render order`;
- evidence, risk, and unknowns;
- exact next action or validation needed.

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
