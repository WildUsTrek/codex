# PERLA1 Multi-Agent Orchestration

Last updated: 2026-06-13

This file defines how the Team Leader uses project-scoped agents for PERLA1. It complements `AGENTS.md`, `PERLA1_PROJECT_MAP.md`, and `PERLA1_BLOCK_MAP.md`.

## Core Principle

The Team Leader owns coordination, final integration, and the user-facing answer. Subagents provide bounded analysis, narrow patches, or validation evidence. No subagent can relax project rules, approve its own work, or redefine the source of truth.

## Standard Flow

1. Read the applicable `AGENTS.md` files.
2. Read `PERLA1_PROJECT_MAP.md`.
3. Read `PERLA1_BLOCK_MAP.md` for monolithic runtime work.
4. Identify impacted block ids before patching.
5. Use read-only auditors for mapping, regression, performance, visual, asset, or launcher concerns.
6. Assign write work only after diagnosis is clear.
7. Keep write scopes disjoint when multiple agents are active.
8. Validate through the local server route for runtime behavior changes.
9. Update project/block maps only when structure, contracts, validation, tooling, or recurring risks change.

## Agent Roles

| Agent | Sandbox | Primary Use | Write Scope |
| --- | --- | --- | --- |
| `code-mapper` | `read-only` | Find real structure, symbols, entry points, and touched blocks. | None. |
| `workflow-guard` | `read-only` | Stop unsafe plans, repeated failed approaches, or rule conflicts. | None. |
| `regression-auditor` | `read-only` | Identify behavioral and rendering regressions. | None. |
| `performance-auditor` | `read-only` | Identify draw/fps/cache/counter risks. | None. |
| `renderer-block-auditor` | `read-only` | Audit render ordering and cross-block renderer effects. | None. |
| `visual-qa-auditor` | `read-only` | Define and inspect visual validation evidence. | None. |
| `asset-integrity-auditor` | `read-only` | Check manifest, asset paths, missing files, and cache risks. | None. |
| `launcher-sync-auditor` | `read-only` | Check launcher, server, sync scripts, and path-relative behavior. | None. |
| `safe-fixer` | `workspace-write` | Make one narrow approved code patch. | Explicit assigned files only, normally active runtime. |
| `map-maintainer` | `workspace-write` | Update technical maps after meaningful structural changes. | `PERLA1_PROJECT_MAP.md` and `PERLA1_BLOCK_MAP.md` only. |

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
- `map-maintainer` does not edit `AGENTS.md`, `.codex/config.toml`, `.codex/agents/*.toml`, or this orchestration policy.
- `safe-fixer` does not redefine validation requirements while patching runtime code.
- Historical snapshots in `report/` never become the runtime source of truth.
- The current runtime remains `01_GIOCO_PRONTO_LOCAL_TEST/index.html` unless the user explicitly changes the project architecture.
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
