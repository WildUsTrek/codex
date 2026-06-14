param(
  [int]$Port = 8000,
  [int]$TimeoutSec = 12,
  [switch]$KillExisting,
  [switch]$Stop,
  [switch]$Status,
  [switch]$Serve
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Game = Join-Path $Root "01_GIOCO_PRONTO_LOCAL_TEST"
$Log = Join-Path $Root "AVVIO_GIOCO_CODEX_HEADLESS_LOG.txt"
$PidFile = Join-Path $Root "AVVIO_GIOCO_CODEX_HEADLESS_PID.txt"
$ReadyFile = Join-Path $Root "AVVIO_GIOCO_CODEX_HEADLESS_READY.txt"
$Url = "http://127.0.0.1:$Port/"

function Write-HeadlessLog($msg) {
  $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg"
  Add-Content -LiteralPath $Log -Value $line -Encoding UTF8
  Write-Host $msg
}

function Test-PerlaHeadlessServer {
  param([int]$CheckPort = $Port)
  try {
    $r = Invoke-WebRequest -Uri "http://127.0.0.1:$CheckPort/?health_codex=1" -UseBasicParsing -TimeoutSec 2
    return ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500 -and $r.Content -match "PERLA_BUILD_ID|__PERLA_DEBUG__|PERLA1")
  } catch {
    return $false
  }
}

function Get-StoredServerPid {
  if (!(Test-Path -LiteralPath $PidFile)) { return $null }
  $raw = (Get-Content -LiteralPath $PidFile -ErrorAction SilentlyContinue | Select-Object -First 1)
  $parsed = 0
  if ([int]::TryParse([string]$raw, [ref]$parsed)) { return $parsed }
  return $null
}

function Stop-StoredServer {
  $storedPid = Get-StoredServerPid
  if (!$storedPid) { return $false }
  $proc = Get-Process -Id $storedPid -ErrorAction SilentlyContinue
  if (!$proc) { return $false }
  Write-HeadlessLog "Stopping stored PERLA1 headless server PID $storedPid"
  Stop-Process -Id $storedPid -Force -ErrorAction Stop
  Start-Sleep -Milliseconds 500
  return $true
}

function Assert-PortAvailableOrOwned {
  $listeners = @()
  try {
    $listeners = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
  } catch {
    $listeners = @()
  }
  if (!$listeners -or $listeners.Count -eq 0) { return }

  $storedPid = Get-StoredServerPid
  foreach ($listener in $listeners) {
    $owner = $listener.OwningProcess
    if ($storedPid -and $owner -eq $storedPid) { continue }
    throw "Port $Port is already used by PID $owner and is not the stored PERLA1 Codex headless server. Stop it manually or choose another port."
  }
}

function Get-ContentType($path) {
  $ext = [System.IO.Path]::GetExtension($path).ToLowerInvariant()
  switch ($ext) {
    ".html" { return "text/html; charset=utf-8" }
    ".htm"  { return "text/html; charset=utf-8" }
    ".js"   { return "application/javascript; charset=utf-8" }
    ".mjs"  { return "application/javascript; charset=utf-8" }
    ".css"  { return "text/css; charset=utf-8" }
    ".json" { return "application/json; charset=utf-8" }
    ".svg"  { return "image/svg+xml; charset=utf-8" }
    ".png"  { return "image/png" }
    ".jpg"  { return "image/jpeg" }
    ".jpeg" { return "image/jpeg" }
    ".webp" { return "image/webp" }
    ".glb"  { return "model/gltf-binary" }
    ".gltf" { return "model/gltf+json; charset=utf-8" }
    ".bin"  { return "application/octet-stream" }
    ".ogg"  { return "audio/ogg" }
    ".wav"  { return "audio/wav" }
    ".mp3"  { return "audio/mpeg" }
    ".txt"  { return "text/plain; charset=utf-8" }
    default { return "application/octet-stream" }
  }
}

function Write-BytesSafe($stream, [byte[]]$bytes) {
  try {
    $stream.Write($bytes, 0, $bytes.Length)
    return $true
  } catch {
    return $false
  }
}

function Send-Response($stream, [int]$statusCode, [string]$statusText, [string]$contentType, [byte[]]$body, [string]$method) {
  if ($null -eq $body) { $body = New-Object byte[] 0 }
  $headerText = "HTTP/1.1 $statusCode $statusText`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nAccess-Control-Allow-Origin: *`r`nCache-Control: no-cache, no-store, must-revalidate`r`nConnection: close`r`n`r`n"
  $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headerText)
  if (!(Write-BytesSafe $stream $headerBytes)) { return }
  if ($method -ne "HEAD" -and $body.Length -gt 0) {
    [void](Write-BytesSafe $stream $body)
  }
}

function Start-ServeLoop {
  Clear-Content -LiteralPath $Log -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $ReadyFile -Force -ErrorAction SilentlyContinue
  Set-Content -LiteralPath $PidFile -Value ([string]$PID) -Encoding ASCII
  Write-HeadlessLog "PERLA1 Codex headless static server starting"
  Write-HeadlessLog "PID: $PID"
  Write-HeadlessLog "Root: $Root"
  Write-HeadlessLog "Game: $Game"
  Write-HeadlessLog "Port: $Port"

  $index = Join-Path $Game "index.html"
  if (!(Test-Path -LiteralPath $index -PathType Leaf)) {
    Write-HeadlessLog "ERROR: index.html not found at $index"
    exit 1
  }

  $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse("127.0.0.1"), $Port)
  try {
    $listener.Start()
  } catch {
    Write-HeadlessLog "ERROR: cannot bind $Url - $($_.Exception.Message)"
    exit 1
  }

  Set-Content -LiteralPath $ReadyFile -Encoding UTF8 -Value @(
    "ready=1"
    "pid=$PID"
    "url=$Url"
    "root=$Root"
    "game=$Game"
    "started=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  )
  Write-HeadlessLog "READY $Url"

  while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $null
    try {
      $client.NoDelay = $true
      $stream = $client.GetStream()
      $buffer = New-Object byte[] 8192
      $read = $stream.Read($buffer, 0, $buffer.Length)
      if ($read -le 0) { continue }

      $requestText = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
      $firstLine = ($requestText -split "`r?`n")[0]
      $parts = $firstLine -split " "
      if ($parts.Length -lt 2) { continue }

      $method = $parts[0]
      $rawPath = $parts[1]

      if ($method -ne "GET" -and $method -ne "HEAD") {
        $body = [System.Text.Encoding]::UTF8.GetBytes("Metodo non supportato")
        Send-Response $stream 405 "Method Not Allowed" "text/plain; charset=utf-8" $body $method
        continue
      }

      $pathOnly = ($rawPath -split "\?")[0]
      $pathOnly = [System.Uri]::UnescapeDataString($pathOnly)
      if ($pathOnly -eq "/" -or $pathOnly -eq "") { $pathOnly = "/index.html" }
      if ($pathOnly -eq "/__perla_health") {
        $body = [System.Text.Encoding]::UTF8.GetBytes("ok")
        Send-Response $stream 200 "OK" "text/plain; charset=utf-8" $body $method
        continue
      }
      if ($pathOnly -eq "/favicon.ico") {
        Send-Response $stream 204 "No Content" "image/x-icon" (New-Object byte[] 0) $method
        continue
      }

      $relative = $pathOnly.TrimStart("/").Replace("/", [System.IO.Path]::DirectorySeparatorChar)
      $fullPath = [System.IO.Path]::GetFullPath((Join-Path $Game $relative))
      $gameFull = [System.IO.Path]::GetFullPath($Game)

      if (!$fullPath.StartsWith($gameFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        $body = [System.Text.Encoding]::UTF8.GetBytes("Forbidden")
        Send-Response $stream 403 "Forbidden" "text/plain; charset=utf-8" $body $method
        continue
      }

      if (!(Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        $body = [System.Text.Encoding]::UTF8.GetBytes("Not found: $pathOnly")
        Send-Response $stream 404 "Not Found" "text/plain; charset=utf-8" $body $method
        Write-HeadlessLog "404 $pathOnly"
        continue
      }

      $bytes = [System.IO.File]::ReadAllBytes($fullPath)
      Send-Response $stream 200 "OK" (Get-ContentType $fullPath) $bytes $method
    } catch {
      try { Write-HeadlessLog "REQUEST ERROR: $($_.Exception.Message)" } catch {}
    } finally {
      try { if ($stream) { $stream.Close() } } catch {}
      try { $client.Close() } catch {}
    }
  }
}

if ($Serve) {
  Start-ServeLoop
  exit 0
}

if ($Status) {
  $storedPid = Get-StoredServerPid
  $responding = Test-PerlaHeadlessServer
  Write-Host "url=$Url"
  Write-Host "pid=$storedPid"
  Write-Host "responding=$responding"
  if (Test-Path -LiteralPath $ReadyFile) { Get-Content -LiteralPath $ReadyFile }
  exit 0
}

if ($Stop) {
  [void](Stop-StoredServer)
  Remove-Item -LiteralPath $ReadyFile -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $PidFile -Force -ErrorAction SilentlyContinue
  exit 0
}

if ($KillExisting) {
  [void](Stop-StoredServer)
  Remove-Item -LiteralPath $ReadyFile -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $PidFile -Force -ErrorAction SilentlyContinue
  Start-Sleep -Milliseconds 500
}

if (Test-PerlaHeadlessServer) {
  Write-HeadlessLog "Existing PERLA1 server already responding at $Url"
  exit 0
}

Assert-PortAvailableOrOwned

Remove-Item -LiteralPath $ReadyFile -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $PidFile -Force -ErrorAction SilentlyContinue

$argsList = @(
  "-NoProfile",
  "-ExecutionPolicy", "Bypass",
  "-File", "`"$PSCommandPath`"",
  "-Serve",
  "-Port", "$Port"
)

$proc = Start-Process -FilePath "powershell.exe" -ArgumentList $argsList -WorkingDirectory $Root -WindowStyle Hidden -PassThru
Write-HeadlessLog "Started PERLA1 Codex headless server process PID $($proc.Id)"

$deadline = (Get-Date).AddSeconds($TimeoutSec)
while ((Get-Date) -lt $deadline) {
  Start-Sleep -Milliseconds 300
  if ((Test-Path -LiteralPath $ReadyFile) -and (Test-PerlaHeadlessServer)) {
    Write-HeadlessLog "PERLA1 Codex headless server ready at $Url"
    exit 0
  }
}

Write-HeadlessLog "ERROR: server did not become ready within $TimeoutSec seconds"
if (Test-Path -LiteralPath $Log) {
  Get-Content -LiteralPath $Log | Select-Object -Last 20
}
exit 1
