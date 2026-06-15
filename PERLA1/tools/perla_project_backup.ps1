[CmdletBinding()]
param(
  [ValidateSet('User','Automatic')]
  [string]$Kind = 'Automatic',
  [string]$ProjectRoot = '',
  [string]$BackupRoot = '',
  [switch]$WhatIfOnly
)

$ErrorActionPreference = 'Stop'

$scriptFile = $PSCommandPath
if (-not $scriptFile) {
  $scriptFile = $MyInvocation.MyCommand.Path
}

$toolsDir = Split-Path -Parent $scriptFile
$perlaRoot = Split-Path -Parent $toolsDir
$defaultProjectRoot = Split-Path -Parent $perlaRoot

if (-not $ProjectRoot) {
  $ProjectRoot = $defaultProjectRoot
}

$projectItem = Get-Item -LiteralPath $ProjectRoot -ErrorAction Stop
$ProjectRoot = $projectItem.FullName

if (-not $BackupRoot) {
  $githubRoot = Split-Path -Parent $ProjectRoot
  $BackupRoot = Join-Path $githubRoot 'backup'
}

$BackupRoot = [System.IO.Path]::GetFullPath($BackupRoot)
$targetLeaf = if ($Kind -eq 'User') { 'utente' } else { 'automatici' }
$targetDir = Join-Path $BackupRoot $targetLeaf

$excludeRtpRoot = Join-Path $ProjectRoot 'PERLA1\01_GIOCO_PRONTO_LOCAL_TEST\assets\rtp'
$excludeRtpRoot = [System.IO.Path]::GetFullPath($excludeRtpRoot).TrimEnd('\')

function Test-ExcludedPath {
  param([string]$Path)
  $full = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
  return ($full -eq $excludeRtpRoot -or $full.StartsWith($excludeRtpRoot + '\', [System.StringComparison]::OrdinalIgnoreCase))
}

function ConvertTo-BackupRelativePath {
  param(
    [string]$Root,
    [string]$Path
  )

  $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
  $pathFull = [System.IO.Path]::GetFullPath($Path)
  $rootUri = [System.Uri]::new($rootFull)
  $pathUri = [System.Uri]::new($pathFull)
  return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace('/','\')
}

function Invoke-AutomaticRetention {
  param([string]$Directory)

  if (-not (Test-Path -LiteralPath $Directory)) {
    return @()
  }

  $files = @(Get-ChildItem -LiteralPath $Directory -File -ErrorAction Stop)
  if ($files.Count -le 10) {
    return @()
  }

  $cutoff = (Get-Date).AddDays(-2)
  $removed = New-Object System.Collections.Generic.List[string]
  foreach ($file in $files) {
    if ($file.LastWriteTime -lt $cutoff) {
      if (-not $WhatIfOnly) {
        Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
      }
      $removed.Add($file.FullName) | Out-Null
    }
  }
  return @($removed.ToArray())
}

if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
  throw "ProjectRoot is not a directory: $ProjectRoot"
}

if (-not $WhatIfOnly) {
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

$removedAutomaticFiles = New-Object 'System.Collections.Generic.List[string]'
if ($Kind -eq 'Automatic') {
  foreach ($removedFile in @(Invoke-AutomaticRetention -Directory $targetDir)) {
    $removedAutomaticFiles.Add($removedFile) | Out-Null
  }
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$safeProjectName = (Split-Path -Leaf $ProjectRoot) -replace '[^A-Za-z0-9_.-]', '_'
$zipName = '{0}_{1}_{2}.zip' -f $safeProjectName, $Kind.ToLowerInvariant(), $timestamp
$zipPath = Join-Path $targetDir $zipName

$filesToBackup = @(
  Get-ChildItem -LiteralPath $ProjectRoot -Recurse -File -Force |
    Where-Object { -not (Test-ExcludedPath -Path $_.FullName) }
)

if ($filesToBackup.Count -eq 0) {
  throw "No files selected for backup from $ProjectRoot"
}

if (-not $WhatIfOnly) {
  Add-Type -AssemblyName System.IO.Compression
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  if (Test-Path -LiteralPath $zipPath) {
    throw "Backup already exists: $zipPath"
  }
  $zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
  try {
    foreach ($file in $filesToBackup) {
      $relative = ConvertTo-BackupRelativePath -Root $ProjectRoot -Path $file.FullName
      $entryName = (Join-Path $safeProjectName $relative).Replace('\','/')
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $entryName, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
  }
  finally {
    $zip.Dispose()
  }
}

$result = [pscustomobject]@{
  schema = 'perla.project_backup.v1'
  kind = $Kind
  projectRoot = $ProjectRoot
  backupRoot = $BackupRoot
  targetDir = $targetDir
  zipPath = $zipPath
  excludedRoot = $excludeRtpRoot
  filesBackedUp = $filesToBackup.Count
  automaticRetentionApplied = ($Kind -eq 'Automatic')
  automaticFilesRemoved = $removedAutomaticFiles
  whatIfOnly = [bool]$WhatIfOnly
}

$result | ConvertTo-Json -Depth 4
