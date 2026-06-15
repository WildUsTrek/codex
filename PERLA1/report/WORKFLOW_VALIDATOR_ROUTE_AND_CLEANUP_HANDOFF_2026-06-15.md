# PERLA1 Workflow Validator Route And Cleanup Handoff

Date: 2026-06-15

## Why This Exists

Codex validation was repeatedly falling back into manual port probing, ad hoc `python -m http.server` attempts, and Playwright runtime rediscovery when `127.0.0.1:8000` was unavailable or sandboxed. That created confusion, repeated work, and inconsistent instructions for agents and subagents.

This handoff records the workflow changes made to prevent future agents from reintroducing the old loop.

## What Changed

- `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` is now the single Codex fast path for rendered validation.
- The validator tries the requested port first, defaulting to `8000`, then known fallback ports `8787`, `8081`, `5179`, `9001`, and `43210`.
- The validator prints the selected validation URL. Agents must use that exact URL, including fallback port and cache-busting query.
- With `-StartLauncher`, the validator may reuse an already responding server only on the requested port. Existing fallback-port servers are skipped to avoid silently validating a stale session.
- The validator stops and verifies only the headless server PID it created. It does not kill pre-existing manual/user servers.
- At finalization, close only recognized PERLA/Codex server processes that are no longer useful. Do not kill arbitrary processes or user-owned manual play sessions.

## Files Touched For This Workflow

- `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1`
- `PERLA1_RUNTIME_TEST_RUNBOOK.md`
- `AGENTS.md`
- `.codex/ORCHESTRATION.md`
- `.codex/agents/visual-qa-auditor.toml`
- `.codex/agents/workflow-guard.toml`
- `.codex/agents/launcher-sync-auditor.toml`
- `.codex/agents/refactor-surgeon.toml`
- `tools/perla_codex_workflow_check.ps1`
- `PERLA1_PROJECT_MAP.md`
- `PERLA1_BLOCK_MAP.md`
- `PERLA1_SYMBOL_INDEX.md`
- `01_GIOCO_PRONTO_LOCAL_TEST/AGENTS.md`
- `.codex/agents/safe-fixer.toml`
- `.codex/agents/regression-auditor.toml`

## Related Contract Alignment

The runtime build currently exposed by `index.html` after the concurrent V292 runtime work is:

```text
PERLA1_V292_REPLAY_RAIN_GUARD_COLUMN_OCCLUSION_SAFE_LOCAL
```

The workflow docs, symbol index, runtime-local AGENTS, regression suite, and roof-sensitive TOML agents were aligned to that build. V292 is wall/replay and game-room column occlusion work; it does not replace the V281/V283 roof/canopy authority. V291 tamarisk foreground restore is retained as inactive diagnostics in the V292 runtime and must not be used as current success proof.

## Concurrent Work Integrity Note

During the handoff cleanup, another thread had already introduced V292 runtime and RTP/scenario workflow changes. The failed large patch attempt did not leave a broken partial code block, but it exposed duplicated registry rows for the four RTP/scenario auditors in `PERLA1_PROJECT_MAP.md`, `.codex/ORCHESTRATION.md`, and `PERLA1_TASK_INTAKE_PROTOCOL.md`.

Resolution:

- kept the richer existing concurrent RTP/scenario auditor registry entries;
- removed only the duplicate rows added during the later cleanup pass;
- aligned V292 references in `PERLA1_SYMBOL_INDEX.md`, `01_GIOCO_PRONTO_LOCAL_TEST/AGENTS.md`, `tests/perla_regression_suite.json`, `.codex/agents/regression-auditor.toml`, and `.codex/agents/safe-fixer.toml`;
- did not revert concurrent runtime/RTP/schema changes.

## Required Validation Command

From `PERLA1/`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher -X 44.5 -Y 74.5 -Dx 0 -Dy 1
```

If a specific fallback port is needed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher -Port 43210 -X 44.5 -Y 74.5 -Dx 0 -Dy 1
```

Use the URL printed by the validator. Do not replace it with a hard-coded `http://127.0.0.1:8000/` if a fallback port was selected.

## Verification Completed

- `tools/perla_codex_workflow_check.ps1 -Mode CI -Json`: pass, 0 failures, 0 warnings after duplicate registry cleanup.
- `tools/perla_local_ci.ps1`: OK for static structure/regression checks on `PERLA1_V292_REPLAY_RAIN_GUARD_COLUMN_OCCLUSION_SAFE_LOCAL`.
- Earlier headless validator test on fallback port `43214`: passed and verified server cleanup.
- Runtime build observed by static CI after concurrent work: `PERLA1_V292_REPLAY_RAIN_GUARD_COLUMN_OCCLUSION_SAFE_LOCAL`.
- Console/page errors from validator run: none.
- Server cleanup: validator printed `PERLA1 validation server stopped: PID ...`.
- Known PERLA listener ports checked after validation: no listeners remained.

## Do Not Reintroduce

- Do not manually probe ports before trying `VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -StartLauncher`.
- Do not rediscover Playwright paths manually before using the validator.
- Do not require Codex validation to stay on `8000` when the validator printed a fallback URL.
- Do not treat fallback-port existing servers as fresh proof under `-StartLauncher`.
- Do not kill pre-existing manual/user servers automatically.
