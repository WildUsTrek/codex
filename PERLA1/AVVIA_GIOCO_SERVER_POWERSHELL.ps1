# PERLA1 V274 - geometric eave edge safe + launcher porta 8000 smart
# Build gioco: PERLA1_V274_REAL_ROOF_GEOMETRIC_EAVE_EDGE_SAFE_LOCAL
# Repack/launcher: PERLA1_V274_REAL_ROOF_GEOMETRIC_EAVE_EDGE_SAFE_LOCAL
param(
  [int]$Port = 8000,
  [switch]$KillExisting
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Game = Join-Path $Root "01_GIOCO_PRONTO_LOCAL_TEST"
$Log = Join-Path $Root "AVVIO_GIOCO_POWERSHELL_LOG.txt"

function Write-Log($msg) {
  $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg"
  Add-Content -Path $Log -Value $line -Encoding UTF8
  Write-Host $msg
}

function Is-BenignTransportAbort($ex) {
  $m = ""
  try { $m = $ex.ToString() } catch { $m = "" }
  return (
    $m -like "*Impossibile scrivere dati sulla connessione di trasporto*" -or
    $m -like "*Unable to write data to the transport connection*" -or
    $m -like "*Connessione interrotta dal software del computer host*" -or
    $m -like "*forcibly closed by the remote host*" -or
    $m -like "*connection was aborted*" -or
    $m -like "*broken pipe*"
  )
}


function Stop-ExistingPerlaServerOnPort([int]$Port) {
  if (-not $KillExisting) { return }
  Write-Log "Controllo vecchi server sulla porta $Port..."
  $currentPid = $PID
  $connections = @()
  try {
    $connections = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
  } catch {
    $connections = @()
  }
  foreach ($c in $connections) {
    $owner = $c.OwningProcess
    if (-not $owner -or $owner -eq $currentPid) { continue }
    $proc = $null
    $cmd = ""
    try { $proc = Get-Process -Id $owner -ErrorAction SilentlyContinue } catch { $proc = $null }
    try { $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId=$owner" -ErrorAction SilentlyContinue).CommandLine } catch { $cmd = "" }
    $safeMatch = $false
    if ($cmd -and ($cmd -like "*AVVIA_GIOCO_SERVER_POWERSHELL.ps1*" -or $cmd -like "*$Root*" -or $cmd -like "*PERLA1*")) { $safeMatch = $true }
    if ($proc -and ($proc.ProcessName -match "powershell|pwsh|cmd")) { if ($cmd -like "*$Root*" -or $cmd -like "*PERLA1*") { $safeMatch = $true } }
    if ($safeMatch) {
      Write-Log "Chiudo vecchio server PERLA1 sulla porta ${Port}: PID $owner $($proc.ProcessName)"
      try { Stop-Process -Id $owner -Force -ErrorAction Stop; Start-Sleep -Milliseconds 650 } catch { Write-Log "WARN: non sono riuscito a chiudere PID ${owner}: $($_.Exception.Message)" }
    } else {
      Write-Log "WARN: porta $Port occupata da processo non riconosciuto, non lo chiudo automaticamente. PID $owner CMD: $cmd"
    }
  }
}

function Write-BytesSafe($stream, [byte[]]$bytes) {
  try {
    $stream.Write($bytes, 0, $bytes.Length)
    return $true
  } catch {
    if (Is-BenignTransportAbort $_.Exception) { return $false }
    throw
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

Clear-Content -Path $Log -ErrorAction SilentlyContinue
Write-Log "PERLA1 V274 - Geometric Eave Edge PowerShell static server robusto"
Write-Log "Root: $Root"
Write-Log "Game: $Game"
Write-Log "Port: $Port"

if (!(Test-Path (Join-Path $Game "index.html"))) {
  Write-Log "ERRORE: index.html non trovato in $Game"
  Write-Host ""
  Write-Host "ERRORE: non trovo 01_GIOCO_PRONTO_LOCAL_TEST\index.html"
  Write-Host "Hai estratto completamente lo ZIP?"
  Write-Host ""
  Read-Host "Premi INVIO per chiudere"
  exit 1
}

Stop-ExistingPerlaServerOnPort $Port

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse("127.0.0.1"), $Port)

try {
  $listener.Start()
} catch {
  Stop-ExistingPerlaServerOnPort $Port
  Start-Sleep -Milliseconds 500
  try { $listener.Start() } catch {
    Write-Log "ERRORE: porta $Port non disponibile o bloccata anche dopo tentativo di pulizia. $($_.Exception.Message)"
    Write-Host ""
    Write-Host "ERRORE: la porta $Port non e disponibile."
    Write-Host "Ho provato a chiudere vecchi server PERLA1 riconoscibili; se resta bloccata, la porta e usata da un altro processo."
    Write-Host ""
    Read-Host "Premi INVIO per chiudere"
    exit 1
  }
}

$url = "http://127.0.0.1:$Port/"
Write-Log "Server avviato su $url"
Write-Host ""
Write-Host "============================================================"
Write-Host " PERLA1 V274 - SERVER POWERSHELL ROBUSTO"
Write-Host "============================================================"
Write-Host ""
Write-Host "Apro il browser su $url"
Write-Host "NON chiudere questa finestra mentre giochi."
Write-Host "Per fermare il server: CTRL + C oppure chiudi questa finestra."
Write-Host ""

Start-Process $url

while ($true) {
  $client = $listener.AcceptTcpClient()
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
    if ($pathOnly -eq "/") { $pathOnly = "/index.html" }
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

    if (!(Test-Path $fullPath -PathType Leaf)) {
      $body = [System.Text.Encoding]::UTF8.GetBytes("Not found: $pathOnly")
      Send-Response $stream 404 "Not Found" "text/plain; charset=utf-8" $body $method
      Write-Log "404 $pathOnly"
      continue
    }

    $bytes = [System.IO.File]::ReadAllBytes($fullPath)
    $ctype = Get-ContentType $fullPath
    Send-Response $stream 200 "OK" $ctype $bytes $method
  } catch {
    if (!(Is-BenignTransportAbort $_.Exception)) {
      try { Write-Log "ERRORE richiesta: $($_.Exception.Message)" } catch {}
    }
  } finally {
    try { $stream.Close() } catch {}
    try { $client.Close() } catch {}
  }
}
