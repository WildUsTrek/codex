# PERLA1 Controlled Modularization Plan

Last updated: 2026-06-14

This plan introduces a measured path out of the current monolithic runtime while keeping `01_GIOCO_PRONTO_LOCAL_TEST/index.html` as the playable source of truth until each extraction is proven.

## Current State

- Runtime source of truth: `01_GIOCO_PRONTO_LOCAL_TEST/index.html`.
- The monolith is intentionally mapped through `PERLA1_PROJECT_MAP.md`, `PERLA1_BLOCK_MAP.md`, `PERLA1_CONTEXT_BUDGET.md`, and `PERLA1_SYMBOL_INDEX.md`.
- New structural tooling lives under `tools/`.
- Local structural checks are defined by `tests/perla_regression_suite.json`.

## Phase 0 - Measurement First

Goal: understand the monolith before moving code.

- Run `tools/perla_runtime_analyzer.mjs` to extract inline JavaScript, parse-check it, map functions/globals, classify blocks, and build a conservative internal dependency graph.
- Run `tools/perla_local_ci.ps1` before and after meaningful runtime work.
- Treat generated structure reports as disposable evidence unless a report is explicitly promoted into project history.

Exit criteria:

- Static parse check passes.
- Required runtime symbols are present.
- Focus graph includes renderer, roof, rain, sprites, minimap, and debug entry points.

## Phase 1 - Non-Runtime Module Scaffolding

Goal: prepare module boundaries without changing runtime behavior.

Allowed:

- Create metadata, docs, test suites, local CI wrappers, and generated analysis reports.
- Create future module boundary manifests.

Forbidden:

- Loading external module scripts in the browser.
- Removing inline runtime code.
- Moving renderer, roof, rain, sprite, wall, or minimap logic.

## Phase 2 - Low-Risk Extraction

Goal: move pure or nearly pure code first.

Candidate order:

1. Build metadata and debug constants.
2. Static asset manifest data.
3. Small pure math/color/hash helpers with no DOM or renderer side effects.
4. Validation/debug report formatters.

Required proof for each extraction:

- `perla_local_ci.ps1` passes.
- Inline build id remains verifiable through the served runtime.
- No change to user-visible rendering unless the task explicitly requires it.

## Phase 3 - Runtime Adapter Layer

Goal: introduce ordered loading while preserving current globals.

Pattern:

- Extract one low-risk module at a time.
- Re-export the exact globals expected by `index.html`.
- Keep the old inline implementation available until the external module is proven.
- Use cache-busted server validation, not `file://`.

## Phase 4 - High-Risk Renderer Decomposition

Goal: split renderer blocks only after low-risk module loading is stable.

High-risk blocks:

- `roof-system`
- `floor-ceiling`
- `wallcasting`
- `sprites`
- `weather-rain`
- `minimap`

Required proof:

- Static CI passes.
- Runtime screenshot validation covers affected poses.
- Relevant counters are inspected.
- The patch updates project maps when block ownership or contracts change.

## Stop Conditions

Stop before applying extraction if:

- The dependency graph shows unclear cross-block ownership.
- A moved symbol is called before it is initialized.
- A runtime path would require weakening validation rules.
- A visual block extraction cannot be validated through screenshot and counters.
