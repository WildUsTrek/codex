# PERLA1 Agent Guide

Scope: this file applies to the whole repository. More specific `AGENTS.md` files in subfolders override or extend these rules.

## Project Shape

- The playable runtime is `01_GIOCO_PRONTO_LOCAL_TEST/index.html`.
- The Windows launcher is `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`, which calls `AVVIA_GIOCO_SERVER_POWERSHELL.ps1` on `http://127.0.0.1:8000/`.
- Files under `report/` are diagnostics, snapshots, extracted scripts, and historical evidence. They are not the runtime unless a task explicitly says otherwise.
- `PERLA1_PROJECT_MAP.md` is the compact technical map of structure, engine flow, dependencies, validation, and known critical risks.
- `PERLA1_BLOCK_MAP.md` is the block-level ownership map for the monolithic runtime.
- `PERLA1_CONTEXT_BUDGET.md` defines how agents inspect the monolithic runtime without flooding the Team Leader context.
- `PERLA1_SYMBOL_INDEX.md` is a verified orientation index for current high-value runtime symbols. It is not a substitute for reading code before patching.
- `PERLA1_TASK_INTAKE_PROTOCOL.md` is the startup gate for selecting and forcing the relevant agents for meaningful tasks.
- `PERLA1_RUNTIME_TEST_RUNBOOK.md` is the practical runtime validation guide for launcher/server/browser/screenshot testing on this Windows setup.
- `.codex/ORCHESTRATION.md` defines the project-scoped multi-agent workflow and anti-paradox rules.
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
- `safe-fixer` is the only general runtime write agent and must receive a narrow approved scope.
- `refactor-surgeon` is an emergency write agent for documented blockage only. It may plan or apply the minimum demonstrably sufficient reversible refactor, but it must start in `REFACTOR_PLAN_ONLY` unless explicit approved scope is provided.
- `map-maintainer` may update only `PERLA1_PROJECT_MAP.md`, `PERLA1_BLOCK_MAP.md`, `PERLA1_CONTEXT_BUDGET.md`, `PERLA1_SYMBOL_INDEX.md`, and `PERLA1_TASK_INTAKE_PROTOCOL.md`; it must not edit runtime code, `.codex/agents/*.toml`, `.codex/config.toml`, `.codex/ORCHESTRATION.md`, or `AGENTS.md`.
- Extra temporary agents are allowed only for concrete gaps not covered by configured agents. They start read-only by default and need explicit file/block ownership before any write task.
- A write agent cannot validate its own patch as complete. Final readiness requires Team Leader review or separate read-only validation.
- If two agents would write the same file or block, serialize the work instead of running them in parallel.
- If orchestration rules conflict, follow the stricter rule and use `workflow-guard` to return `STOP` before continuing.
- Use `workflow-guard` as a circuit breaker when a method fails twice, when a known deterministic tool failure appears, or when the next step would not produce new evidence.
- Use `workflow-consistency-auditor` for every explicit Agent Selection Gate. It can run a lightweight gate audit for ordinary tasks and must run a full audit when workflow docs, TOML agents, gate rules, orchestration, AGENTS hierarchy, or permissions change.
- Use `task-watchdog` for long-running work, repeated no-evidence cycles, checkpoint decisions, and user stop conditions. It tracks `task_id`, `operation_id`, and `logical_step_id`.
- A first long failure in the same operation or logical step may restart from the best checkpoint with a materially different plan. A second long failure in the same operation or logical step must stop for user approval.
- After three progressive failures or no-evidence cycles on the same `logical_step_id`, require a checkpoint and a failure brief before continuing.
- Use `skeptic-auditor` for complex, high-risk, uncertain, long-running, repeated, or refactor-adjacent work. It challenges the current plan and proposes grounded plan B/C alternatives, but does not block by itself.
- Use `refactor-surgeon` only after documented blockage, normally after `task-watchdog` returns `STOP_FOR_USER`/`ESCALATE` or `workflow-guard` returns `STOP`. If refactor requires crossing multiple blocks or a controlled derogation, surface the conflict and request approval instead of silently bypassing rules.
- Apply the Agent Selection Gate from `PERLA1_TASK_INTAKE_PROTOCOL.md`: all relevant domain agents must be marked `CALL`, `workflow-consistency-auditor` is always `CALL` for explicit gates, and `workflow-guard`, `task-watchdog`, `skeptic-auditor`, and `refactor-surgeon` must always be at least considered.
- When the gate marks an agent as `CALL`, the agent must be invoked or delegated operationally. PERLA1 already has standing user authorization for configured project agents selected by the gate; do not downgrade them to passive consideration because a fresh user request was not asked.
- If subagent tooling is unavailable, use tool discovery if present. If the required agent still cannot be invoked, stop with `TOOLING_BLOCKED` before patching, validating, syncing, or applying refactors. Do not pretend the gate passed.
- Context limits restrict what agents paste back into the Team Leader thread, not what they may inspect in the repository. Agents may read deeper into `index.html` when a concrete hypothesis, cross-block dependency, or Team Leader request requires it.
- Agents must report read scope and evidence compactly instead of dumping large raw extracts.

## Required Validation For Game Changes

Before saying a rendered game fix is ready:

- Parse the inline JavaScript from `01_GIOCO_PRONTO_LOCAL_TEST/index.html`.
- Start the PERLA1 local server with `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`, or explicitly confirm an existing server from that launcher is already responding on `http://127.0.0.1:8000/`.
- Do not try to validate the runtime by opening `index.html` directly, by using `file://`, or by opening a browser before the local server is running.
- Prefer the proven automated screenshot path in `PERLA1_RUNTIME_TEST_RUNBOOK.md`: `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` with system Chrome/Edge through Playwright.
- Load `http://127.0.0.1:8000/` with a cache-busting query string.
- Confirm `window.PERLA_BUILD_ID` matches the edited build.
- Check browser console/page errors.
- Capture screenshots for the exact visual risk area.
- Inspect screenshots visually; metrics alone are not enough.
- Read `perlaLastDrawStats()` or the relevant public debug summary for draw/roof counters.

## Runtime Browser Method

- The reliable Windows method currently is: launcher/server first, then `powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 ...` for automated screenshots and debug counters.
- Browser automation is useful only after the PERLA1 server is running. If `http://127.0.0.1:8000/` is not responding, start or ask the user to start `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat` first.
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


