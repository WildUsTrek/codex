param(
  [switch]$RuntimeScreenshots,
  [string]$NodePath = "",
  [string]$ReportPath = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Analyzer = Join-Path $Root "tools\perla_runtime_analyzer.mjs"
$Suite = Join-Path $Root "tests\perla_regression_suite.json"

function Resolve-PerlaNode {
  param([string]$ExplicitPath)
  if ($ExplicitPath -and (Test-Path -LiteralPath $ExplicitPath)) { return $ExplicitPath }
  $cmd = Get-Command node -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $bundled = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
  if (Test-Path -LiteralPath $bundled) { return $bundled }
  throw "Node.js not found. Pass -NodePath or install Node.js."
}

$Node = Resolve-PerlaNode -ExplicitPath $NodePath
if (!(Test-Path -LiteralPath $Analyzer)) { throw "Analyzer not found: $Analyzer" }
if (!(Test-Path -LiteralPath $Suite)) { throw "Regression suite not found: $Suite" }

if (!$ReportPath) {
  $ReportPath = Join-Path $Root "report\RUNTIME_STRUCTURE_CURRENT.json"
}

Write-Host "[PERLA1 CI] Node: $Node"
Write-Host "[PERLA1 CI] Static structure and regression checks"
& $Node $Analyzer --check --suite $Suite --out $ReportPath --pretty

if ($LASTEXITCODE -ne 0) {
  throw "PERLA1 static checks failed."
}

if ($RuntimeScreenshots) {
  $Validator = Join-Path $Root "VALIDA_RUNTIME_SCREENSHOT_HEADLESS.ps1"
  if (!(Test-Path -LiteralPath $Validator)) { throw "Runtime validator not found: $Validator" }
  $PoseReport = Get-Content -LiteralPath $Suite -Raw | ConvertFrom-Json
  foreach ($pose in $PoseReport.runtimeSmokePoses) {
    $safeName = ($pose.name -replace "[^A-Za-z0-9_-]", "_")
    $out = Join-Path $env:TEMP "perla_ci_${safeName}.png"
    Write-Host "[PERLA1 CI] Runtime screenshot pose: $($pose.name)"
    powershell -NoProfile -ExecutionPolicy Bypass -File $Validator -StartLauncher -X $pose.x -Y $pose.y -Dx $pose.dx -Dy $pose.dy -OutputPath $out
  }
}

Write-Host "[PERLA1 CI] OK"
