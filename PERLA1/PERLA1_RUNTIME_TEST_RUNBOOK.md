# PERLA1 Runtime Test Runbook

Last updated: 2026-06-14

This is the practical runtime validation path that worked on the Windows Codex desktop setup after repeated failed attempts. Use this before trying slower or less reliable browser paths.

## Correct Test Path

For rendered runtime validation, the reliable sequence is:

1. Start or confirm the PERLA1 server.
2. Load `http://127.0.0.1:8000/` with a cache-busting query string.
3. Use the debug API to set deterministic player poses.
4. Capture the `#screen` canvas.
5. Inspect the screenshot visually and read relevant counters.

The runtime is not validly tested through `file://` or by opening `index.html` directly.

## Server Startup

Normal startup entry point:

```text
AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat
```

This launcher calls:

```text
AVVIA_GIOCO_SERVER_POWERSHELL.ps1
```

and serves:

```text
http://127.0.0.1:8000/
```

Before browser validation, confirm the server:

```powershell
Invoke-WebRequest -Uri 'http://127.0.0.1:8000/?health_codex=1' -UseBasicParsing -TimeoutSec 2
```

If the server is not responding and the agent cannot launch the Windows launcher, stop and hand off: ask the user to run `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`.

## Known Reliable Screenshot Method

Use the helper script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -X 44.5 -Y 74.5 -Dx 0 -Dy 1
```

Default output goes to:

```text
%TEMP%\perla_runtime_screenshot.png
```

Example for the south beach:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -X 44.5 -Y 74.5 -Dx 0 -Dy 1 -OutputPath "$env:TEMP\perla_south_beach.png"
```

Run it from the `PERLA1/` directory, or pass the script path from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\PERLA1\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1 -X 44.5 -Y 74.5 -Dx 0 -Dy 1 -OutputPath "$env:TEMP\perla_south_beach.png"
```

Do not run the `.ps1` directly with `.\VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1` on locked-down Windows sessions. It can fail with:

```text
L'esecuzione di script è disabilitata nel sistema in uso.
```

Use `powershell -NoProfile -ExecutionPolicy Bypass -File ...`, matching the launcher style.

This method uses:

- the PERLA1 launcher/server on `127.0.0.1:8000`,
- bundled Codex Node.js,
- bundled Playwright packages with explicit `NODE_PATH`,
- installed system Chrome at `C:\Program Files\Google\Chrome\Application\chrome.exe`, with Edge fallback.

Why this method exists:

- raw `require('playwright')` from the repository can fail with `Cannot find module 'playwright'`;
- bundled Playwright can fail to launch its own browser if `ms-playwright\chromium_headless_shell-*` is missing;
- using system Chrome through Playwright avoids the missing bundled browser download;
- screenshots are written outside Git by default.

## Known-Failing Or Secondary Methods

Do not spend repeated attempts on these before using the reliable method above:

| Method | Status / Failure |
| --- | --- |
| Opening `index.html` directly | Invalid for final validation; bypasses the launcher/server route. |
| `file://` | Invalid for final validation and can hide server/cache/runtime issues. |
| Browser before server startup | Fails before testing the game. Start or confirm the launcher/server first. |
| Codex in-app Browser on this Windows setup | Known failure: `CreateProcessAsUserW failed: 5`. Treat as tooling failure, not runtime failure. |
| Playwright without explicit `NODE_PATH` | Can fail with `Cannot find module 'playwright'`. |
| Playwright bundled browser without system Chrome | Can fail because the Playwright browser executable is not installed. |
| Running the helper `.ps1` directly | Can fail under Windows execution policy. Use `powershell -NoProfile -ExecutionPolicy Bypass -File ...`. |

These methods may be retried only as secondary options if the reliable method stops working or if the user specifically asks to test that browser path.

## Loop Breaker Rule

If the same validation method fails twice without new evidence, stop and consult `workflow-guard`. If validation becomes a long task with repeated no-evidence cycles, also consult `task-watchdog`.

Stop immediately instead of retrying when the failure is already known and deterministic:

- `CreateProcessAsUserW failed: 5` from Codex in-app Browser;
- `Cannot find module 'playwright'` without changing `NODE_PATH`;
- missing `chromium_headless_shell` without switching to system Chrome/Edge;
- Windows execution policy blocking direct `.ps1` execution;
- `http://127.0.0.1:8000/` not responding because the launcher/server is not running.

The next attempt must materially change the method: start the server, use the runbook script, fix `NODE_PATH`, switch browser executable, use `ExecutionPolicy Bypass`, or hand off manual validation. Do not keep retrying the same command.

## Required Evidence

For a rendered fix to be called validated, collect:

- exact URL with cache-busting query string,
- `window.PERLA_BUILD_ID`,
- pose used via `window.__PERLA_DEBUG__.setPlayerForDebug(...)`,
- screenshot of `#screen`,
- console/page errors,
- `window.__PERLA_DEBUG__.perlaLastDrawStats()` or the relevant debug summary,
- visual inspection result.

Do not claim full rendered validation from a successful page load alone.
