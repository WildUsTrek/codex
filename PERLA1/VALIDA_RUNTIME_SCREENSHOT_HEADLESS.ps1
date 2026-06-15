param(
  [double]$X = 44.5,
  [double]$Y = 74.5,
  [double]$Dx = 0,
  [double]$Dy = 1,
  [int]$Width = 1280,
  [int]$Height = 800,
  [string]$OutputPath = (Join-Path $env:TEMP "perla_runtime_screenshot.png"),
  [int]$Port = 8000,
  [int[]]$FallbackPorts = @(8787, 8081, 5179, 9001, 43210),
  [switch]$StartLauncher
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$HeadlessLauncher = Join-Path $Root "AVVIA_GIOCO_CODEX_HEADLESS.ps1"
$SelectedPort = $Port
$Url = $null
$StartedHeadlessServer = $false
$HeadlessServerProcess = $null

function Get-CandidatePorts {
  $seen = @{}
  $ports = @($Port) + @($FallbackPorts)
  foreach ($candidate in $ports) {
    if ($candidate -le 0 -or $candidate -gt 65535) { continue }
    $key = [string]$candidate
    if ($seen.ContainsKey($key)) { continue }
    $seen[$key] = $true
    $candidate
  }
}

function New-PerlaRuntimeUrl {
  param([int]$CheckPort)
  return "http://127.0.0.1:$CheckPort/?v=headless_runtime_$([DateTimeOffset]::Now.ToUnixTimeMilliseconds())"
}

function Test-PerlaServer {
  param([int]$CheckPort)
  try {
    $r = Invoke-WebRequest -Uri "http://127.0.0.1:$CheckPort/?health_codex=1" -UseBasicParsing -TimeoutSec 2
    return ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500 -and $r.Content -match "PERLA_BUILD_ID|__PERLA_DEBUG__|PERLA1")
  } catch {
    return $false
  }
}

function Stop-CreatedHeadlessServer {
  if (!$StartedHeadlessServer -or !$HeadlessServerProcess) { return }

  if (!$HeadlessServerProcess.HasExited) {
    Stop-Process -Id $HeadlessServerProcess.Id -Force -ErrorAction SilentlyContinue
    try {
      [void]$HeadlessServerProcess.WaitForExit(3000)
    } catch {}
  }

  $stillRunning = Get-Process -Id $HeadlessServerProcess.Id -ErrorAction SilentlyContinue
  if ($stillRunning) {
    Write-Warning "PERLA1 headless server PID $($HeadlessServerProcess.Id) is still running after cleanup attempt."
  } else {
    Write-Host "PERLA1 validation server stopped: PID $($HeadlessServerProcess.Id)"
  }
}

$candidatePorts = @(Get-CandidatePorts)
$serverReady = $false
if (Test-PerlaServer -CheckPort $Port) {
  $SelectedPort = $Port
  $serverReady = $true
} elseif (!$StartLauncher) {
  foreach ($candidatePort in $candidatePorts) {
    if ($candidatePort -eq $Port) { continue }
    if (Test-PerlaServer -CheckPort $candidatePort) {
      $SelectedPort = $candidatePort
      $serverReady = $true
      break
    }
  }
}

if (!$serverReady) {
  if ($StartLauncher) {
    if (!(Test-Path -LiteralPath $HeadlessLauncher)) { throw "Codex headless launcher not found: $HeadlessLauncher" }
    $ready = $false

    foreach ($candidatePort in $candidatePorts) {
      if ($candidatePort -ne $Port -and (Test-PerlaServer -CheckPort $candidatePort)) {
        Write-Host "Skipping existing PERLA-like fallback server on port $candidatePort; -StartLauncher requires a fresh fallback server."
        continue
      }

      Remove-Item -LiteralPath (Join-Path $Root "AVVIO_GIOCO_CODEX_HEADLESS_READY.txt") -Force -ErrorAction SilentlyContinue
      $HeadlessServerProcess = Start-Process -FilePath "powershell.exe" -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$HeadlessLauncher`"",
        "-Serve",
        "-Port", "$candidatePort"
      ) -WorkingDirectory $Root -WindowStyle Hidden -PassThru
      $StartedHeadlessServer = $true

      for ($i = 0; $i -lt 24; $i++) {
        Start-Sleep -Milliseconds 500
        if (Test-PerlaServer -CheckPort $candidatePort) {
          $SelectedPort = $candidatePort
          $ready = $true
          break
        }
        if ($HeadlessServerProcess.HasExited) { break }
      }

      if ($ready) { break }

      if ($HeadlessServerProcess -and !$HeadlessServerProcess.HasExited) {
        Stop-Process -Id $HeadlessServerProcess.Id -Force -ErrorAction SilentlyContinue
      }
      $HeadlessServerProcess = $null
    }

    if (!$ready) {
      $triedPorts = ($candidatePorts -join ", ")
      throw "PERLA1 server did not respond after launching $HeadlessLauncher -Serve. Tried ports: $triedPorts"
    }
  } else {
    $triedPorts = ($candidatePorts -join ", ")
    throw "PERLA1 server is not responding on ports $triedPorts. Start AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat manually, or rerun with -StartLauncher to use AVVIA_GIOCO_CODEX_HEADLESS.ps1."
  }
}

$Url = New-PerlaRuntimeUrl -CheckPort $SelectedPort
Write-Host "PERLA1 validation URL: $Url"

$Node = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
$NodeRoot = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\node"
$NodeModules = Join-Path $NodeRoot "node_modules"
$PnpmModules = Join-Path $NodeModules ".pnpm\node_modules"

if (!(Test-Path -LiteralPath $Node)) { throw "Bundled Codex Node.js not found: $Node" }
if (!(Test-Path -LiteralPath $NodeModules)) { throw "Bundled node_modules not found: $NodeModules" }

$ChromeCandidates = @(
  "C:\Program Files\Google\Chrome\Application\chrome.exe",
  "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
  "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
)
$Chrome = $ChromeCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (!$Chrome) { throw "No system Chrome/Edge executable found for headless validation." }

$env:NODE_PATH = "$NodeModules;$PnpmModules"
$env:PERLA_SCREENSHOT_OUT = $OutputPath
$env:PERLA_URL = $Url
$env:PERLA_CHROME_EXE = $Chrome
$env:PERLA_POSE_X = [string]$X
$env:PERLA_POSE_Y = [string]$Y
$env:PERLA_POSE_DX = [string]$Dx
$env:PERLA_POSE_DY = [string]$Dy
$env:PERLA_VIEWPORT_W = [string]$Width
$env:PERLA_VIEWPORT_H = [string]$Height

$JsPath = Join-Path $env:TEMP "perla_runtime_screenshot_headless.js"
@'
const { chromium } = require("playwright");

(async () => {
  const out = process.env.PERLA_SCREENSHOT_OUT;
  const url = process.env.PERLA_URL;
  const executablePath = process.env.PERLA_CHROME_EXE;
  const x = Number(process.env.PERLA_POSE_X);
  const y = Number(process.env.PERLA_POSE_Y);
  const dx = Number(process.env.PERLA_POSE_DX);
  const dy = Number(process.env.PERLA_POSE_DY);
  const width = Number(process.env.PERLA_VIEWPORT_W || 1280);
  const height = Number(process.env.PERLA_VIEWPORT_H || 800);

  const browser = await chromium.launch({ headless: true, executablePath });
  const page = await browser.newPage({ viewport: { width, height }, deviceScaleFactor: 1 });
  const errors = [];

  page.on("console", message => {
    if (["error", "warning"].includes(message.type())) {
      errors.push(`${message.type()}: ${message.text()}`);
    }
  });
  page.on("pageerror", error => errors.push(`pageerror: ${error.message}`));

  await page.goto(url, { waitUntil: "domcontentloaded", timeout: 15000 });
  await page.waitForFunction(() => window.__PERLA_DEBUG__ && document.querySelector("#screen"), null, { timeout: 15000 });
  await page.waitForTimeout(1200);

  const info = await page.evaluate(async ({ x, y, dx, dy }) => {
    const d = window.__PERLA_DEBUG__;
    d.setPlayerForDebug(x, y, dx, dy);
    await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
    await new Promise(resolve => setTimeout(resolve, 350));
    const stats = d.perlaLastDrawStats ? d.perlaLastDrawStats() : {};
    const cellX = Math.floor(x);
    const cellY = Math.floor(y);
    return {
      build: window.PERLA_BUILD_ID || (d.getBuildId && d.getBuildId()),
      pose: { x, y, dx, dy },
      zone: d.zoneMask && d.zoneMask[cellY] ? d.zoneMask[cellY][cellX] : null,
      floor: d.fMap && d.fMap[cellY] ? d.fMap[cellY][cellX] : null,
      screen: d.screenSize ? d.screenSize() : null,
      stats: {
        mode: stats.mode,
        drawWorldMs: stats.drawWorldMs,
        floorSegments: stats.floorSegments,
        wallHits: stats.wallHits,
        spriteCandidates: stats.spriteCandidates,
        spriteVisible: stats.spriteVisible,
        spriteStripes: stats.spriteStripes,
        roofMsV198: stats.roofMsV198,
        roofSamplesV106: stats.roofSamplesV106,
        longViewZoneV260: stats.longViewZoneV260,
        longViewReasonV260: stats.longViewReasonV260
      }
    };
  }, { x, y, dx, dy });

  await page.locator("#screen").screenshot({ path: out });
  await browser.close();

  console.log(JSON.stringify({ out, url, info, errors }, null, 2));
})().catch(error => {
  console.error(error.stack || error.message);
  process.exit(1);
});
'@ | Set-Content -LiteralPath $JsPath -Encoding UTF8

$nodeExit = 0
try {
  & $Node $JsPath
  $nodeExit = $LASTEXITCODE
} finally {
  if ($StartedHeadlessServer) {
    Stop-CreatedHeadlessServer
    Remove-Item -LiteralPath (Join-Path $Root "AVVIO_GIOCO_CODEX_HEADLESS_READY.txt") -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath (Join-Path $Root "AVVIO_GIOCO_CODEX_HEADLESS_PID.txt") -Force -ErrorAction SilentlyContinue
  }
}

if ($nodeExit -ne 0) {
  exit $nodeExit
}
