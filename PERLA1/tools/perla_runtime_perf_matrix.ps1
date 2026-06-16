param(
  [string]$OutputDir = "",
  [int]$Port = 8000,
  [int[]]$FallbackPorts = @(8787, 8081, 5179, 9001, 43210),
  [string]$ExpectedBuild = "",
  [string[]]$Weathers = @(),
  [string]$ScenarioPath = "",
  [int]$StartupTimeoutSec = 14,
  [int]$PageTimeoutMs = 20000,
  [int]$WarmupMs = 700,
  [int]$SampleMs = 1400,
  [int]$TransitionMs = 700,
  [switch]$Deep,
  [switch]$DryRun,
  [switch]$Smoke,
  [switch]$TransitionSweeps
)

$ErrorActionPreference = "Stop"

$ToolsRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ToolsRoot
$RepoRoot = Split-Path -Parent $ProjectRoot
$Launcher = Join-Path $ProjectRoot "AVVIA_GIOCO_CODEX_HEADLESS.ps1"
$SuitePath = Join-Path $ProjectRoot "tests\perla_regression_suite.json"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

if (!$OutputDir) {
  $OutputDir = Join-Path $env:TEMP "PERLA1_perf_matrix_$Timestamp"
}

function Get-FullPathSafe {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) { throw "Path is empty." }
  $base = $Path
  if (![System.IO.Path]::IsPathRooted($base)) {
    $base = Join-Path (Get-Location) $base
  }
  return [System.IO.Path]::GetFullPath($base)
}

function Test-PathInside {
  param([string]$ChildPath, [string]$ParentPath)
  $child = (Get-FullPathSafe $ChildPath).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
  $parent = (Get-FullPathSafe $ParentPath).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
  return $child.StartsWith($parent, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-CandidatePorts {
  $seen = @{}
  foreach ($candidate in (@($Port) + @($FallbackPorts))) {
    if ($candidate -le 0 -or $candidate -gt 65535) { continue }
    $key = [string]$candidate
    if ($seen.ContainsKey($key)) { continue }
    $seen[$key] = $true
    $candidate
  }
}

function Test-PerlaServer {
  param([int]$CheckPort)
  try {
    $uri = "http://127.0.0.1:$CheckPort/?health_codex=1"
    $r = Invoke-WebRequest -Uri $uri -UseBasicParsing -TimeoutSec 2
    return ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500 -and $r.Content -match "PERLA_BUILD_ID|__PERLA_DEBUG__|PERLA1")
  } catch {
    return $false
  }
}

function Resolve-ExpectedBuild {
  if ($ExpectedBuild) { return $ExpectedBuild }
  if (Test-Path -LiteralPath $SuitePath -PathType Leaf) {
    $suite = Get-Content -LiteralPath $SuitePath -Raw | ConvertFrom-Json
    if ($suite.requiredBuildId) { return [string]$suite.requiredBuildId }
  }

  $index = Join-Path $ProjectRoot "01_GIOCO_PRONTO_LOCAL_TEST\index.html"
  if (Test-Path -LiteralPath $index -PathType Leaf) {
    $match = Select-String -LiteralPath $index -Pattern "const\s+PERLA_BUILD_ID\s*=\s*'([^']+)'" | Select-Object -First 1
    if ($match -and $match.Matches.Count -gt 0) { return $match.Matches[0].Groups[1].Value }
  }

  throw "Cannot resolve expected PERLA build id. Pass -ExpectedBuild explicitly."
}

function Resolve-NodeRuntime {
  param([switch]$Required)
  $node = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
  $nodeRoot = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\node"
  $nodeModules = Join-Path $nodeRoot "node_modules"
  $pnpmModules = Join-Path $nodeModules ".pnpm\node_modules"

  $missing = @()
  if (!(Test-Path -LiteralPath $node -PathType Leaf)) { $missing += "bundled node.exe: $node" }
  if (!(Test-Path -LiteralPath $nodeModules -PathType Container)) { $missing += "bundled node_modules: $nodeModules" }

  if ($missing.Count -gt 0) {
    if ($Required) { throw ("Bundled Codex Node/Playwright runtime missing: " + ($missing -join "; ")) }
    return [pscustomobject]@{ Node = $node; NodeModules = $nodeModules; PnpmModules = $pnpmModules; Ready = $false; Missing = $missing }
  }

  return [pscustomobject]@{ Node = $node; NodeModules = $nodeModules; PnpmModules = $pnpmModules; Ready = $true; Missing = @() }
}

function Resolve-SystemChrome {
  param([switch]$Required)
  $candidates = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
  )
  $chrome = $candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
  if (!$chrome -and $Required) { throw "No system Chrome/Edge executable found for Playwright." }
  return $chrome
}

function Get-DefaultScenarios {
  if (Test-Path -LiteralPath $SuitePath -PathType Leaf) {
    $suite = Get-Content -LiteralPath $SuitePath -Raw | ConvertFrom-Json
    if ($suite.runtimeSmokePoses -and $suite.runtimeSmokePoses.Count -gt 0) {
      return @($suite.runtimeSmokePoses | ForEach-Object {
        [pscustomobject]@{
          name = [string]$_.name
          x = [double]$_.x
          y = [double]$_.y
          dx = [double]$_.dx
          dy = [double]$_.dy
        }
      })
    }
  }

  return @(
    [pscustomobject]@{ name = "reception_west_south_edge"; x = 64.99; y = 8.44; dx = 1; dy = 0 },
    [pscustomobject]@{ name = "reception_diagonal_ne"; x = 64.99; y = 8.44; dx = 0.7071; dy = -0.7071 },
    [pscustomobject]@{ name = "bath_south_side"; x = 99; y = 71; dx = 0; dy = -1 }
  )
}

function ConvertTo-ScenarioList {
  param($RawScenarios, [string]$Source)
  $items = @($RawScenarios)
  if ($items.Count -eq 0) { throw "No scenarios found in $Source." }
  return @($items | ForEach-Object {
    if ($null -eq $_.name -or $null -eq $_.x -or $null -eq $_.y -or $null -eq $_.dx -or $null -eq $_.dy) {
      throw "Invalid scenario in $Source. Required fields: name, x, y, dx, dy."
    }
    [pscustomobject]@{
      name = [string]$_.name
      x = [double]$_.x
      y = [double]$_.y
      dx = [double]$_.dx
      dy = [double]$_.dy
      expectedZone = $(if ($null -ne $_.expectedZone) { [string]$_.expectedZone } else { $null })
      expectedOwner = $(if ($null -ne $_.expectedOwner) { $_.expectedOwner } else { $null })
      transitionSequence = $(if ($null -ne $_.transitionSequence) { @($_.transitionSequence) } else { @() })
      source = $Source
    }
  })
}

function Get-ScenarioMatrix {
  if ([string]::IsNullOrWhiteSpace($ScenarioPath)) {
    return @(Get-DefaultScenarios | ForEach-Object {
      if ($null -eq $_.source) { $_ | Add-Member -NotePropertyName source -NotePropertyValue "default_suite" -Force }
      $_
    })
  }
  $scenarioFull = Get-FullPathSafe $ScenarioPath
  if (!(Test-Path -LiteralPath $scenarioFull -PathType Leaf)) {
    throw "ScenarioPath not found: $scenarioFull"
  }
  $json = Get-Content -LiteralPath $scenarioFull -Raw | ConvertFrom-Json
  if ($json -is [System.Array]) {
    return @(ConvertTo-ScenarioList -RawScenarios $json -Source $scenarioFull)
  }
  if ($json.scenarios) {
    return @(ConvertTo-ScenarioList -RawScenarios $json.scenarios -Source $scenarioFull)
  }
  if ($json.runtimeSmokePoses) {
    return @(ConvertTo-ScenarioList -RawScenarios $json.runtimeSmokePoses -Source $scenarioFull)
  }
  throw "ScenarioPath JSON must be an array or contain scenarios/runtimeSmokePoses: $scenarioFull"
}

function Get-WeatherMatrix {
  $allowed = @("clear", "cloudy", "rain", "storm")
  $raw = @()
  foreach ($entry in @($Weathers)) {
    if ([string]::IsNullOrWhiteSpace($entry)) { continue }
    $raw += @(([string]$entry).Split(",") | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ })
  }
  if ($raw.Count -eq 0) { $raw = @("clear", "storm") }
  $seen = @{}
  $out = @()
  foreach ($weather in $raw) {
    if ($weather -notin $allowed) {
      throw "Unsupported weather '$weather'. Allowed: $($allowed -join ', ')."
    }
    if ($seen.ContainsKey($weather)) { continue }
    $seen[$weather] = $true
    $out += $weather
  }
  return $out
}

function Get-ViewportMatrix {
  $all = @(
    [pscustomobject]@{ name = "desktop"; width = 1280; height = 800; isMobile = $false; hasTouch = $false; deviceScaleFactor = 1 },
    [pscustomobject]@{ name = "mobile_portrait"; width = 390; height = 844; isMobile = $true; hasTouch = $true; deviceScaleFactor = 2 },
    [pscustomobject]@{ name = "mobile_landscape"; width = 844; height = 390; isMobile = $true; hasTouch = $true; deviceScaleFactor = 2 }
  )
  if ($Smoke) { return @($all | Where-Object { $_.name -in @("desktop", "mobile_portrait") }) }
  return $all
}

function Start-OrReusePerlaServer {
  if (!(Test-Path -LiteralPath $Launcher -PathType Leaf)) { throw "Codex headless launcher not found: $Launcher" }

  $ports = @(Get-CandidatePorts)
  if (Test-PerlaServer -CheckPort $Port) {
    return [pscustomobject]@{
      Url = "http://127.0.0.1:$Port/"
      Port = $Port
      Started = $false
      Process = $null
      Owner = "preexisting_requested_port"
    }
  }

  foreach ($candidate in $ports) {
    if ($candidate -ne $Port -and (Test-PerlaServer -CheckPort $candidate)) {
      Write-Host "Skipping existing PERLA-like fallback server on port $candidate; perf matrix requires a fresh fallback server."
      continue
    }

    $argsList = @(
      "-NoProfile",
      "-ExecutionPolicy", "Bypass",
      "-File", "`"$Launcher`"",
      "-Serve",
      "-Port", "$candidate"
    )
    $proc = Start-Process -FilePath "powershell.exe" -ArgumentList $argsList -WorkingDirectory $ProjectRoot -WindowStyle Hidden -PassThru
    $deadline = (Get-Date).AddSeconds($StartupTimeoutSec)
    while ((Get-Date) -lt $deadline) {
      Start-Sleep -Milliseconds 350
      if (Test-PerlaServer -CheckPort $candidate) {
        return [pscustomobject]@{
          Url = "http://127.0.0.1:$candidate/"
          Port = $candidate
          Started = $true
          Process = $proc
          Owner = "runner_created"
        }
      }
      if ($proc.HasExited) { break }
    }

    if ($proc -and !$proc.HasExited) {
      Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
  }

  throw "PERLA1 server did not respond. Tried ports: $($ports -join ', ')."
}

function Stop-CreatedPerlaServer {
  param($Server)
  if (!$Server -or !$Server.Started -or !$Server.Process) { return }
  $proc = Get-Process -Id $Server.Process.Id -ErrorAction SilentlyContinue
  if ($proc) {
    Stop-Process -Id $Server.Process.Id -Force -ErrorAction SilentlyContinue
    try { [void]$Server.Process.WaitForExit(3000) } catch {}
  }
  Remove-Item -LiteralPath (Join-Path $ProjectRoot "AVVIO_GIOCO_CODEX_HEADLESS_READY.txt") -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath (Join-Path $ProjectRoot "AVVIO_GIOCO_CODEX_HEADLESS_PID.txt") -Force -ErrorAction SilentlyContinue
}

$OutputFull = Get-FullPathSafe $OutputDir
if (Test-PathInside -ChildPath $OutputFull -ParentPath $RepoRoot) {
  throw "Refusing to write performance matrix output inside the repository: $OutputFull"
}

$expected = Resolve-ExpectedBuild
$nodeRuntime = Resolve-NodeRuntime -Required:(!$DryRun)
$chrome = Resolve-SystemChrome -Required:(!$DryRun)
$scenarios = @(Get-ScenarioMatrix)
if ($Smoke) { $scenarios = @($scenarios | Select-Object -First 1) }
$viewports = @(Get-ViewportMatrix)
$weathers = @(Get-WeatherMatrix)
$cellCount = $scenarios.Count * $viewports.Count * $weathers.Count

if ($DryRun) {
  Write-Host "PERLA1 performance matrix dry run"
  Write-Host "project=$ProjectRoot"
  Write-Host "output=$OutputFull"
  Write-Host "expectedBuild=$expected"
  Write-Host "ports=$((@(Get-CandidatePorts)) -join ',')"
  Write-Host "nodeReady=$($nodeRuntime.Ready)"
  if (!$nodeRuntime.Ready) { Write-Host "nodeMissing=$($nodeRuntime.Missing -join '; ')" }
  Write-Host "chrome=$chrome"
  Write-Host "deep=$([bool]$Deep)"
  Write-Host "smoke=$([bool]$Smoke)"
  Write-Host "transitionSweeps=$([bool]$TransitionSweeps)"
  Write-Host "scenarioPath=$ScenarioPath"
  Write-Host "cells=$cellCount"
  Write-Host "viewports=$((@($viewports | ForEach-Object { $_.name })) -join ',')"
  Write-Host "weather=$($weathers -join ',')"
  Write-Host "scenarios=$((@($scenarios | ForEach-Object { $_.name })) -join ',')"
  exit 0
}

New-Item -ItemType Directory -Force -Path $OutputFull | Out-Null
$ScreenshotsDir = Join-Path $OutputFull "screenshots"
New-Item -ItemType Directory -Force -Path $ScreenshotsDir | Out-Null

$JsonReport = Join-Path $OutputFull "PERLA1_perf_matrix_report.json"
$MarkdownSummary = Join-Path $OutputFull "PERLA1_perf_matrix_summary.md"
$ConfigPath = Join-Path $OutputFull "PERLA1_perf_matrix_config.json"
$RunnerJs = Join-Path $OutputFull "PERLA1_perf_matrix_runner.js"

$server = $null
try {
  $server = Start-OrReusePerlaServer
  $url = "$($server.Url)?v=perf_matrix_$Timestamp"

  $config = [pscustomobject]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    projectRoot = $ProjectRoot
    outputDir = $OutputFull
    screenshotsDir = $ScreenshotsDir
    jsonReportPath = $JsonReport
    markdownSummaryPath = $MarkdownSummary
    url = $url
    expectedBuild = $expected
    smoke = [bool]$Smoke
    scenarioPath = $ScenarioPath
    pageTimeoutMs = $PageTimeoutMs
    warmupMs = $WarmupMs
    sampleMs = $SampleMs
    transitionMs = $TransitionMs
    transitionSweeps = [bool]$TransitionSweeps
    deep = [bool]$Deep
    chrome = $chrome
    node = $nodeRuntime.Node
    server = [pscustomobject]@{ port = $server.Port; started = [bool]$server.Started; owner = $server.Owner; pid = $(if ($server.Process) { $server.Process.Id } else { $null }) }
    viewports = $viewports
    weathers = $weathers
    scenarios = $scenarios
  }
  $configJson = $config | ConvertTo-Json -Depth 20
  [System.IO.File]::WriteAllText($ConfigPath, $configJson, [System.Text.UTF8Encoding]::new($false))

  @'
const fs = require("fs");
const path = require("path");
const { chromium } = require("playwright");

const config = JSON.parse(fs.readFileSync(process.env.PERLA_MATRIX_CONFIG, "utf8"));

function safeName(value) {
  return String(value || "cell").replace(/[^A-Za-z0-9_.-]+/g, "_").replace(/^_+|_+$/g, "");
}

function relForMarkdown(file) {
  return path.relative(config.outputDir, file).replace(/\\/g, "/");
}

function finite(value) {
  return Number.isFinite(value) ? value : null;
}

function pickDrawMs(cell) {
  const stats = cell.lastDrawStats || {};
  const perf = cell.perfReport || {};
  return finite(perf.overall && perf.overall.drawWorldMs && perf.overall.drawWorldMs.avg) ?? finite(stats.drawWorldMs);
}

function pickFps(cell) {
  const perf = cell.perfReport || {};
  return finite(perf.overall && perf.overall.fps && (perf.overall.fps.p50 ?? perf.overall.fps.avg));
}

function pickOverall(cell, group, field) {
  const perf = cell.perfReport || {};
  const summary = perf.overall && perf.overall[group];
  return finite(summary && summary[field]);
}

function pickSampleClass(cell, sampleClass, group, field) {
  const perf = cell.perfReport || {};
  const classes = perf.sampleClassesV301 || {};
  const cls = classes[sampleClass] || perf[`${sampleClass}V301`] || {};
  const summary = cls[group];
  return finite(summary && summary[field]);
}

function pickTransitionMax(cell) {
  const values = [];
  const primary = pickSampleClass(cell, "transition", "drawWorldMs", "max");
  if (primary != null) values.push(primary);
  const reports = cell.transitionReports || {};
  for (const key of Object.keys(reports)) {
    const p = reports[key] || {};
    const v = p.sampleClassesV301 && p.sampleClassesV301.transition && p.sampleClassesV301.transition.drawWorldMs && p.sampleClassesV301.transition.drawWorldMs.max;
    if (Number.isFinite(v)) values.push(v);
  }
  return values.length ? Math.max(...values) : null;
}

function pickHotspot(cell, group, field) {
  const stats = cell.lastDrawStats || {};
  const worst = cell.perfReport && cell.perfReport.worstFrames && cell.perfReport.worstFrames[0];
  const hs = worst && worst.hotspotsV300 && worst.hotspotsV300[group];
  if (hs && Number.isFinite(hs[field])) return hs[field];
  if (group === "sprites") {
    if (field === "candidates") return finite(stats.spriteCandidates);
    if (field === "stripes") return finite(stats.spriteStripes);
    if (field === "visible") return finite(stats.spriteVisible);
  }
  if (group === "renderer" && field === "floorSegments") return finite(stats.floorSegments);
  if (group === "coverage" && field === "totalMs") return finite(stats.coverageTotalMsV261);
  if (group === "adaptive" && field === "level") return finite(stats.smartAdaptiveLevelV300);
  return null;
}

function markdown(report) {
  const lines = [];
  lines.push("# PERLA1 Performance Matrix");
  lines.push("");
  lines.push(`- Generated: ${report.generatedAt}`);
  lines.push(`- URL: ${report.url}`);
  lines.push(`- Expected build: ${report.expectedBuild}`);
  lines.push(`- Observed build: ${report.observedBuild || "n/a"}`);
  lines.push(`- Smoke: ${report.smoke}`);
  lines.push(`- Server: port ${report.server.port}, started=${report.server.started}`);
  lines.push("");
  lines.push("| Scenario | Weather | Viewport | Touch | draw avg | draw p95 | steady p95 | warmup p95 | transition max | FPS | CPU p95 | cand | stripes | floor | cov ms | AQ | Screenshot |");
  lines.push("|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|");
  for (const cell of report.cells) {
    const draw = pickDrawMs(cell);
    const drawP95 = pickOverall(cell, "drawWorldMs", "p95");
    const drawMax = pickOverall(cell, "drawWorldMs", "max");
    const steadyP95 = pickSampleClass(cell, "steady", "drawWorldMs", "p95");
    const warmupP95 = pickSampleClass(cell, "warmup", "drawWorldMs", "p95");
    const transitionMax = pickTransitionMax(cell);
    const cpuP95 = pickOverall(cell, "cpuMs", "p95");
    const fps = pickFps(cell);
    const shot = cell.screenshot ? relForMarkdown(cell.screenshot) : "";
    const touch = cell.viewport.isMobile ? (cell.touch && cell.touch.ok ? "yes" : "no") : "n/a";
    const cand = pickHotspot(cell, "sprites", "candidates");
    const stripes = pickHotspot(cell, "sprites", "stripes");
    const floor = pickHotspot(cell, "renderer", "floorSegments");
    const cov = pickHotspot(cell, "coverage", "totalMs");
    const aq = pickHotspot(cell, "adaptive", "level");
    lines.push(`| ${cell.scenario.name} | ${cell.weather} | ${cell.viewport.name} | ${touch} | ${draw == null ? "" : draw.toFixed(3)} | ${drawP95 == null ? "" : drawP95.toFixed(3)} | ${steadyP95 == null ? "" : steadyP95.toFixed(3)} | ${warmupP95 == null ? "" : warmupP95.toFixed(3)} | ${transitionMax == null ? "" : transitionMax.toFixed(3)} | ${fps == null ? "" : fps.toFixed(1)} | ${cpuP95 == null ? "" : cpuP95.toFixed(3)} | ${cand == null ? "" : cand} | ${stripes == null ? "" : stripes} | ${floor == null ? "" : floor} | ${cov == null ? "" : cov.toFixed(3)} | ${aq == null ? "" : aq} | ${shot} |`);
  }
  if (report.error) {
    lines.push("");
    lines.push(`Error: ${report.error}`);
  }
  return lines.join("\n") + "\n";
}

async function waitFrames(page, count) {
  for (let i = 0; i < count; i++) {
    await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => resolve())));
  }
}

async function markedWait(page, durationMs, prefix) {
  await page.evaluate(label => window.perlaPerfMark(label), `${prefix}_start`);
  const deadline = Date.now() + Math.max(0, durationMs || 0);
  let marker = 0;
  while (Date.now() < deadline) {
    marker += 1;
    await page.evaluate(label => window.perlaPerfMark(label), `${prefix}_${marker}`);
    await page.waitForTimeout(120);
  }
  await page.evaluate(label => window.perlaPerfMark(label), `${prefix}_end`);
}

async function runTransitionSweeps(page, scenario, weather, cellName) {
  const result = { enabled: !!config.transitionSweeps, weather: [], zone: [] };
  if (!config.transitionSweeps) return result;

  let currentWeather = weather;
  for (const target of config.weathers || []) {
    if (!target || target === currentWeather) continue;
    await page.evaluate(({ target, label }) => {
      window.perlaPerfMark(`${label}_before_set_weather`);
      window.perlaSetWeather(target);
      window.perlaPerfMark(`${label}_after_set_weather`);
    }, { target, label: `transition_weather_${currentWeather}_to_${target}` });
    await markedWait(page, config.transitionMs, `transition_weather_${currentWeather}_to_${target}`);
    result.weather.push({ from: currentWeather, to: target, durationMs: config.transitionMs });
    currentWeather = target;
  }

  if (currentWeather !== weather) {
    await page.evaluate(({ weather }) => window.perlaSetWeather(weather), { weather });
    await markedWait(page, Math.min(config.transitionMs, 360), `transition_weather_return_${weather}`);
  }

  const steps = Array.isArray(scenario.transitionSequence) ? scenario.transitionSequence : [];
  let prevName = scenario.name;
  for (const rawStep of steps) {
    const step = rawStep || {};
    if (!Number.isFinite(Number(step.x)) || !Number.isFinite(Number(step.y)) || !Number.isFinite(Number(step.dx)) || !Number.isFinite(Number(step.dy))) continue;
    const name = safeName(step.name || `${prevName}_to_step`);
    await page.evaluate(({ step, label }) => {
      window.perlaPerfMark(`${label}_before_set_pose`);
      window.__PERLA_DEBUG__.setPlayerForDebug(Number(step.x), Number(step.y), Number(step.dx), Number(step.dy));
      window.perlaPerfMark(`${label}_after_set_pose`);
    }, { step, label: `transition_zone_${name}` });
    await markedWait(page, Number(step.transitionMs) || config.transitionMs, `transition_zone_${name}`);
    result.zone.push({ from: prevName, to: step.name || name, durationMs: Number(step.transitionMs) || config.transitionMs, expectedZone: step.expectedZone || null });
    prevName = step.name || name;
  }

  await page.evaluate(({ scenario }) => {
    window.__PERLA_DEBUG__.setPlayerForDebug(scenario.x, scenario.y, scenario.dx, scenario.dy);
  }, { scenario });
  return result;
}

async function checkRequiredApi(page) {
  return await page.evaluate(() => {
    const d = window.__PERLA_DEBUG__;
    const missing = [];
    if (!d) missing.push("window.__PERLA_DEBUG__");
    if (d && typeof d.setPlayerForDebug !== "function") missing.push("__PERLA_DEBUG__.setPlayerForDebug");
    if (typeof window.perlaSetWeather !== "function") missing.push("window.perlaSetWeather");
    if (typeof window.perlaPerfStart !== "function") missing.push("window.perlaPerfStart");
    if (typeof window.perlaPerfMark !== "function") missing.push("window.perlaPerfMark");
    if (typeof window.perlaPerfStop !== "function") missing.push("window.perlaPerfStop");
    if (d && typeof d.collectPerlaDebugSnapshot !== "function") missing.push("__PERLA_DEBUG__.collectPerlaDebugSnapshot");
    if (d && typeof d.perlaLastDrawStats !== "function") missing.push("__PERLA_DEBUG__.perlaLastDrawStats");
    const build = window.PERLA_BUILD_ID || window.__PERLA_BUILD_ID__ || (d && d.getBuildId && d.getBuildId()) || null;
    return { missing, build };
  });
}

async function checkTouch(page, viewport) {
  const touch = await page.evaluate(() => ({
    maxTouchPoints: navigator.maxTouchPoints || 0,
    ontouchstart: "ontouchstart" in window,
    coarsePointer: !!(window.matchMedia && window.matchMedia("(pointer: coarse)").matches)
  }));
  touch.ok = !viewport.isMobile || (touch.maxTouchPoints > 0 && touch.ontouchstart && touch.coarsePointer);
  return touch;
}

function expectedRuntimeMode(viewport) {
  if (!viewport.isMobile) return "desktop";
  return viewport.width > viewport.height ? "mobile-landscape" : "mobile-portrait";
}

function classifyHud(snapshot, viewport, screenshot) {
  const layout = snapshot && snapshot.layout ? snapshot.layout : {};
  const screen = snapshot && snapshot.renderer ? snapshot.renderer : {};
  const mode = snapshot && snapshot.viewport ? snapshot.viewport.mode : null;
  const canvas = layout.canvas || null;
  const elements = [];
  const overlap = [];
  const target = { type: "canvas_world", width: screen.screenW || null, height: screen.screenH || null };
  const maybe = [
    ["clock", layout.clockHud],
    ["minimap", layout.miniMap],
    ["controls", layout.mobileControls],
    ["debug_overlay", layout.debugButton]
  ];
  for (const [name, rect] of maybe) {
    if (rect && rect.width > 1 && rect.height > 1) {
      elements.push(name);
      if (canvas && rect.right > canvas.left && rect.left < canvas.right && rect.bottom > canvas.top && rect.top < canvas.bottom) {
        overlap.push(name);
      }
    }
  }
  return {
    screenshot_path: screenshot,
    viewport: { requested: viewport.name, runtimeMode: mode, canvas: target },
    target_visual_area: target,
    hud_visible: elements.length > 0,
    hud_elements: elements,
    hud_overlaps_target: overlap.length > 0,
    contamination_level: overlap.length ? (viewport.isMobile ? "medium" : "low") : "none",
    action: overlap.length ? "accept_for_performance_identity_reject_as_visual_proof" : "accept",
    notes: "Canvas-only #screen screenshot. DOM HUD overlap is recorded separately; performance ranking is not visual fix readiness."
  };
}

function classifyCoordinate(snapshot, scenario, weather) {
  const player = snapshot && snapshot.player ? snapshot.player : {};
  const renderer = snapshot && snapshot.renderer ? snapshot.renderer : {};
  const dx = Number(scenario.dx);
  const dy = Number(scenario.dy);
  const ex = Number(renderer.dir && renderer.dir.x);
  const ey = Number(renderer.dir && renderer.dir.y);
  const requested = { x: Number(scenario.x), y: Number(scenario.y), dx, dy };
  const effective = { x: player.posXActual ?? null, displayX: player.posX ?? null, y: player.posY ?? null, dx: Number.isFinite(ex) ? ex : null, dy: Number.isFinite(ey) ? ey : null };
  const offsetDelta = {
    x: Number.isFinite(effective.x) ? +(effective.x - requested.x).toFixed(4) : null,
    y: Number.isFinite(effective.y) ? +(effective.y - requested.y).toFixed(4) : null
  };
  const dirDelta = Number.isFinite(ex) && Number.isFinite(ey)
    ? +(Math.hypot(ex - dx, ey - dy)).toFixed(4)
    : null;
  const suspicious = Math.abs(offsetDelta.x || 0) > 0.05 || Math.abs(offsetDelta.y || 0) > 0.05 || (dirDelta != null && dirDelta > 0.05);
  return {
    target_project: "PERLA1",
    trigger: "coordinate_dependent_validation",
    requested_pose: requested,
    effective_pose: effective,
    direction_requested: { dx, dy },
    direction_effective: { dx: effective.dx, dy: effective.dy },
    expected_zone: scenario.expectedZone || null,
    observed_zone: player.zone || null,
    expected_tile_or_owner: scenario.expectedOwner || null,
    observed_tile_or_owner: { floorType: player.floorType ?? null, wallType: player.wallType ?? null, cMap: player.cMap ?? null, outdoors: player.outdoors ?? null },
    known_offset_applied: "debug API runtime coordinates; HUD/display X recorded separately when available",
    offset_delta: offsetDelta,
    direction_delta: dirDelta,
    coordinate_source: "scenario:setPlayerForDebug + collectPerlaDebugSnapshot",
    coordinate_confidence: suspicious ? "medium" : "high",
    suspicious_coordinates: suspicious,
    false_coordinate_suspicion: !suspicious,
    weather,
    action: suspicious ? "inspect_map_or_debug_api_before_visual_claim" : "accept_for_performance_ranking"
  };
}

async function runCell(browser, report, scenario, weather, viewport, index) {
  const cellName = safeName(`${String(index).padStart(2, "0")}_${scenario.name}_${weather}_${viewport.name}`);
  const screenshot = path.join(config.screenshotsDir, `${cellName}.png`);
  const context = await browser.newContext({
    viewport: { width: viewport.width, height: viewport.height },
    deviceScaleFactor: viewport.deviceScaleFactor || 1,
    isMobile: !!viewport.isMobile,
    hasTouch: !!viewport.hasTouch,
    userAgent: viewport.isMobile
      ? "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1 PERLA1PerfMatrix"
      : undefined
  });
  const page = await context.newPage();
  await page.addInitScript(deep => {
    window.__PERLA_MATRIX_DEEP__ = !!deep;
  }, !!config.deep);
  const consoleMessages = [];
  const pageErrors = [];
  page.on("console", message => {
    if (["error", "warning"].includes(message.type())) {
      consoleMessages.push({ type: message.type(), text: message.text() });
    }
  });
  page.on("pageerror", error => pageErrors.push(error.message));

  try {
    await page.goto(`${config.url}&cell=${encodeURIComponent(cellName)}`, { waitUntil: "domcontentloaded", timeout: config.pageTimeoutMs });
    await page.waitForFunction(() => window.__PERLA_DEBUG__ && document.querySelector("#screen"), null, { timeout: config.pageTimeoutMs });
    await waitFrames(page, 2);

    const api = await checkRequiredApi(page);
    if (api.missing.length) {
      throw new Error(`Missing PERLA debug API: ${api.missing.join(", ")}`);
    }
    if (config.expectedBuild && api.build !== config.expectedBuild) {
      throw new Error(`Build mismatch: expected ${config.expectedBuild}, observed ${api.build}`);
    }
    report.observedBuild = report.observedBuild || api.build;

    const touch = await checkTouch(page, viewport);
    if (viewport.isMobile && !touch.ok) {
      throw new Error(`Mobile viewport is not touch-enabled: ${viewport.name} maxTouchPoints=${touch.maxTouchPoints} ontouchstart=${touch.ontouchstart} coarsePointer=${touch.coarsePointer}`);
    }

    await page.evaluate(({ scenario, weather, cellName }) => {
      window.perlaSetWeather(weather);
      window.__PERLA_DEBUG__.setPlayerForDebug(scenario.x, scenario.y, scenario.dx, scenario.dy);
      window.perlaPerfStart({ reason: `perf_matrix:${cellName}`, sampleIntervalMs: 100, deep: !!window.__PERLA_MATRIX_DEEP__ });
      window.perlaPerfMark("after_pose_weather");
    }, { scenario, weather, cellName });

    await markedWait(page, config.warmupMs, "phase_warmup");
    await waitFrames(page, 2);

    await markedWait(page, config.sampleMs, "phase_steady");
    const transitionSweeps = await runTransitionSweeps(page, scenario, weather, cellName);

    await page.evaluate(() => window.perlaPerfMark("before_canvas_screenshot"));
    await page.locator("#screen").screenshot({ path: screenshot });
    await page.evaluate(() => window.perlaPerfMark("after_canvas_screenshot"));

    const payload = await page.evaluate(({ scenario, weather, viewport, cellName }) => {
      const d = window.__PERLA_DEBUG__;
      const lastDrawStats = d.perlaLastDrawStats();
      const debugSnapshot = d.collectPerlaDebugSnapshot(`perf_matrix:${cellName}`);
      const perfReport = window.perlaPerfStop();
      return {
        build: window.PERLA_BUILD_ID || (d.getBuildId && d.getBuildId()) || null,
        scenario,
        weather,
        viewport,
        pose: { x: scenario.x, y: scenario.y, dx: scenario.dx, dy: scenario.dy },
        screen: d.screenSize ? d.screenSize() : null,
        viewportMode: d.currentViewportMode ? d.currentViewportMode() : null,
        lastDrawStats,
        debugSnapshot,
        perfReport
      };
    }, { scenario, weather, viewport, cellName });
    payload.transitionSweeps = transitionSweeps;

    const runtimeMode = payload.viewportMode;
    const expectedMode = expectedRuntimeMode(viewport);
    if (runtimeMode !== expectedMode) {
      throw new Error(`Runtime viewport mode mismatch for ${viewport.name}: expected ${expectedMode}, observed ${runtimeMode}`);
    }

    report.cells.push(Object.assign({
      index,
      cellName,
      screenshot,
      touch,
      hud_contamination_check: classifyHud(payload.debugSnapshot, viewport, screenshot),
      coordinate_offset_check: classifyCoordinate(payload.debugSnapshot, scenario, weather),
      consoleMessages,
      pageErrors
    }, payload));
  } finally {
    await context.close();
  }
}

(async () => {
  const report = {
    generatedAt: new Date().toISOString(),
    url: config.url,
    expectedBuild: config.expectedBuild,
    observedBuild: null,
    smoke: !!config.smoke,
    server: config.server,
    node: config.node,
    chrome: config.chrome,
    viewports: config.viewports,
    weathers: config.weathers,
    scenarios: config.scenarios,
    cells: []
  };

  let browser = null;
  try {
    browser = await chromium.launch({ headless: true, executablePath: config.chrome });
    let index = 0;
    for (const scenario of config.scenarios) {
      for (const weather of config.weathers) {
        for (const viewport of config.viewports) {
          index += 1;
          await runCell(browser, report, scenario, weather, viewport, index);
        }
      }
    }
  } catch (error) {
    report.error = error && (error.stack || error.message) || String(error);
    fs.writeFileSync(config.jsonReportPath, JSON.stringify(report, null, 2), "utf8");
    fs.writeFileSync(config.markdownSummaryPath, markdown(report), "utf8");
    console.error(report.error);
    process.exitCode = 1;
    return;
  } finally {
    if (browser) {
      await browser.close();
    }
  }

  fs.writeFileSync(config.jsonReportPath, JSON.stringify(report, null, 2), "utf8");
  fs.writeFileSync(config.markdownSummaryPath, markdown(report), "utf8");
  console.log(JSON.stringify({
    ok: true,
    cells: report.cells.length,
    jsonReport: config.jsonReportPath,
    markdownSummary: config.markdownSummaryPath
  }, null, 2));
})().catch(error => {
  console.error(error.stack || error.message);
  process.exit(1);
});
'@ | Set-Content -LiteralPath $RunnerJs -Encoding UTF8

  $env:NODE_PATH = "$($nodeRuntime.NodeModules);$($nodeRuntime.PnpmModules)"
  $env:PERLA_MATRIX_CONFIG = $ConfigPath
  & $nodeRuntime.Node $RunnerJs
  if ($LASTEXITCODE -ne 0) {
    throw "PERLA1 performance matrix failed. See $JsonReport and $MarkdownSummary"
  }

  Write-Host "PERLA1 performance matrix complete"
  Write-Host "output=$OutputFull"
  Write-Host "json=$JsonReport"
  Write-Host "markdown=$MarkdownSummary"
} finally {
  Stop-CreatedPerlaServer -Server $server
}
