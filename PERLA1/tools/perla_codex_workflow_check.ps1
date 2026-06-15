[CmdletBinding()]
param(
  [ValidateSet('Manual','CI','StopHook','SubagentStartHook','SubagentStopHook')]
  [string]$Mode = 'Manual',
  [switch]$Json,
  [switch]$Jsonl,
  [switch]$Strict
)

$ErrorActionPreference = 'Stop'

$scriptFile = $PSCommandPath
if (-not $scriptFile) {
  $scriptFile = $MyInvocation.MyCommand.Path
}

$toolsDir = Split-Path -Parent $scriptFile
$perlaRoot = Split-Path -Parent $toolsDir
$repoRoot = Split-Path -Parent $perlaRoot

$checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
  param(
    [string]$Id,
    [ValidateSet('P0','P1','P2','P3','INFO')]
    [string]$Severity,
    [bool]$Ok,
    [string]$Message,
    [string[]]$Files = @()
  )

  $checks.Add([pscustomobject]@{
    id = $Id
    severity = $Severity
    ok = $Ok
    message = $Message
    files = $Files
  }) | Out-Null
}

function Read-Text {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return $null
  }

  return Get-Content -LiteralPath $Path -Raw
}

function Require-File {
  param(
    [string]$Id,
    [string]$Path,
    [string]$Purpose
  )

  $exists = Test-Path -LiteralPath $Path
  Add-Check -Id $Id -Severity 'P1' -Ok $exists -Message $Purpose -Files @($Path)
}

$paths = @{
  RootHooks = Join-Path $repoRoot '.codex/hooks.json'
  PerlaConfig = Join-Path $perlaRoot '.codex/config.toml'
  PerlaOrchestration = Join-Path $perlaRoot '.codex/ORCHESTRATION.md'
  PerlaIntake = Join-Path $perlaRoot 'PERLA1_TASK_INTAKE_PROTOCOL.md'
  PerlaProjectMap = Join-Path $perlaRoot 'PERLA1_PROJECT_MAP.md'
  PerlaContextBudget = Join-Path $perlaRoot 'PERLA1_CONTEXT_BUDGET.md'
  PerlaAgents = Join-Path $perlaRoot 'AGENTS.md'
  PerlaBlockMap = Join-Path $perlaRoot 'PERLA1_BLOCK_MAP.md'
  PerlaRunbook = Join-Path $perlaRoot 'PERLA1_RUNTIME_TEST_RUNBOOK.md'
  PerlaSymbolIndex = Join-Path $perlaRoot 'PERLA1_SYMBOL_INDEX.md'
  RuntimeIndex = Join-Path $perlaRoot '01_GIOCO_PRONTO_LOCAL_TEST/index.html'
  RuntimeAgents = Join-Path $perlaRoot '01_GIOCO_PRONTO_LOCAL_TEST/AGENTS.md'
  RegressionSuite = Join-Path $perlaRoot 'tests/perla_regression_suite.json'
  PerlaBackupTool = Join-Path $perlaRoot 'tools/perla_project_backup.ps1'
  GitIgnore = Join-Path $repoRoot '.gitignore'
  PerlaTools = Join-Path $perlaRoot 'tools'
  AgentDir = Join-Path $perlaRoot '.codex/agents'
}

Require-File -Id 'required.root_hooks' -Path $paths.RootHooks -Purpose 'Root Codex hook file exists so sessions started from the synchronized repository can run workflow enforcement.'
Require-File -Id 'required.workflow_check' -Path $scriptFile -Purpose 'PERLA1 workflow validator script exists.'
Require-File -Id 'required.perla_config' -Path $paths.PerlaConfig -Purpose 'PERLA1 Codex agent config exists.'
Require-File -Id 'required.orchestration' -Path $paths.PerlaOrchestration -Purpose 'PERLA1 orchestration policy exists.'
Require-File -Id 'required.intake' -Path $paths.PerlaIntake -Purpose 'PERLA1 task intake protocol exists.'
Require-File -Id 'required.project_map' -Path $paths.PerlaProjectMap -Purpose 'PERLA1 project map exists.'
Require-File -Id 'required.context_budget' -Path $paths.PerlaContextBudget -Purpose 'PERLA1 context budget protocol exists.'
Require-File -Id 'required.agents' -Path $paths.PerlaAgents -Purpose 'PERLA1 AGENTS.md exists.'
Require-File -Id 'required.block_map' -Path $paths.PerlaBlockMap -Purpose 'PERLA1 block map exists.'
Require-File -Id 'required.runtime_runbook' -Path $paths.PerlaRunbook -Purpose 'PERLA1 runtime validation runbook exists.'
Require-File -Id 'required.symbol_index' -Path $paths.PerlaSymbolIndex -Purpose 'PERLA1 symbol index exists.'
Require-File -Id 'required.runtime_index' -Path $paths.RuntimeIndex -Purpose 'PERLA1 playable runtime index.html exists so current build contract can be derived.'
Require-File -Id 'required.runtime_agents' -Path $paths.RuntimeAgents -Purpose 'PERLA1 runtime-local AGENTS.md exists.'
Require-File -Id 'required.regression_suite' -Path $paths.RegressionSuite -Purpose 'PERLA1 structural regression suite exists so deterministic suite/build-id drift can be checked.'
Require-File -Id 'required.project_backup_tool' -Path $paths.PerlaBackupTool -Purpose 'PERLA1 project backup tool exists.'
Require-File -Id 'required.gitignore' -Path $paths.GitIgnore -Purpose 'Repository .gitignore exists for disposable workflow artifacts.'
Require-File -Id 'required.agent_dir' -Path $paths.AgentDir -Purpose 'PERLA1 project agent TOML directory exists.'

$configText = Read-Text -Path $paths.PerlaConfig
if ($null -ne $configText) {
  Add-Check -Id 'config.max_threads_12' -Severity 'P1' -Ok ($configText -match '(?m)^\s*max_threads\s*=\s*12\s*$') -Message 'Configured subagent concurrency remains max_threads = 12.' -Files @($paths.PerlaConfig)
  Add-Check -Id 'config.max_depth_1' -Severity 'P2' -Ok ($configText -match '(?m)^\s*max_depth\s*=\s*1\s*$') -Message 'Nested subagent fan-out remains capped at max_depth = 1.' -Files @($paths.PerlaConfig)
  Add-Check -Id 'config.job_timeout' -Severity 'P1' -Ok ($configText -match '(?m)^\s*job_max_runtime_seconds\s*=\s*1500\s*$') -Message 'Project agent hard timeout remains 1500 seconds, leaving margin after the 21-minute complex-step checkpoint.' -Files @($paths.PerlaConfig)
}

$heartbeatDocs = @(
  $paths.PerlaAgents,
  $paths.PerlaOrchestration,
  $paths.PerlaIntake,
  $paths.PerlaProjectMap
)

$heartbeatText = @(
  foreach ($docPath in $heartbeatDocs) {
    Read-Text -Path $docPath
  }
) -join "`n"

$heartbeatScanFiles = New-Object System.Collections.Generic.List[string]
foreach ($docPath in $heartbeatDocs) {
  $heartbeatScanFiles.Add($docPath) | Out-Null
}
if (Test-Path -LiteralPath $paths.AgentDir) {
  Get-ChildItem -LiteralPath $paths.AgentDir -Filter '*.toml' -File |
    ForEach-Object { $heartbeatScanFiles.Add($_.FullName) | Out-Null }
}

$heartbeatScanText = @(
  foreach ($scanPath in $heartbeatScanFiles) {
    Read-Text -Path $scanPath
  }
) -join "`n"

if ($heartbeatText.Trim().Length -gt 0) {
  Add-Check -Id 'heartbeat.simple_limit_12_minutes' -Severity 'P1' -Ok ($heartbeatText -match '12 minutes') -Message 'Workflow heartbeat simple-step limit is documented as 12 minutes.' -Files $heartbeatDocs
  Add-Check -Id 'heartbeat.complex_limit_21_minutes' -Severity 'P1' -Ok ($heartbeatText -match '21 minutes') -Message 'Workflow heartbeat complex-step limit is documented as 21 minutes.' -Files $heartbeatDocs
  Add-Check -Id 'heartbeat.no_stale_10_15_limits' -Severity 'P1' -Ok ($heartbeatScanText -notmatch '10/15|10-15|10 minutes|15 minutes|10-minute|15-minute|after 10 minutes|after 15 minutes|Ten minutes|Fifteen minutes') -Message 'Stale 10/15 minute heartbeat limits are absent from workflow docs and agent TOMLs.' -Files @($heartbeatScanFiles.ToArray())
  Add-Check -Id 'heartbeat.mandatory_checkpoint_details' -Severity 'P1' -Ok ($heartbeatText -match 'checkpoint.*mandatory' -and $heartbeatText -match 'task_id' -and $heartbeatText -match 'forbidden next action') -Message 'Workflow docs require a detailed checkpoint when heartbeat limits are reached.' -Files $heartbeatDocs
  Add-Check -Id 'heartbeat.job_timeout_margin' -Severity 'P1' -Ok ($configText -match '(?m)^\s*job_max_runtime_seconds\s*=\s*1500\s*$' -and $heartbeatText -match '21 minutes') -Message 'Agent hard timeout is higher than the 21-minute complex checkpoint, so the checkpoint can happen before timeout.' -Files @($paths.PerlaConfig, $paths.PerlaOrchestration, $paths.PerlaIntake)
}

$hookText = Read-Text -Path $paths.RootHooks
if ($null -ne $hookText) {
  try {
    $hookJson = $hookText | ConvertFrom-Json
    Add-Check -Id 'hooks.json_parse' -Severity 'P1' -Ok $true -Message 'Root hooks.json parses as JSON.' -Files @($paths.RootHooks)
    $hasStop = $null -ne $hookJson.hooks.Stop
    $hasStart = $null -ne $hookJson.hooks.SubagentStart
    $hasSubStop = $null -ne $hookJson.hooks.SubagentStop
    Add-Check -Id 'hooks.stop' -Severity 'P1' -Ok $hasStop -Message 'Stop hook is configured for end-of-turn workflow contract checking.' -Files @($paths.RootHooks)
    Add-Check -Id 'hooks.subagent_start' -Severity 'P2' -Ok $hasStart -Message 'SubagentStart hook is configured to surface workflow checks around delegated work.' -Files @($paths.RootHooks)
    Add-Check -Id 'hooks.subagent_stop' -Severity 'P2' -Ok $hasSubStop -Message 'SubagentStop hook is configured to surface workflow checks around delegated work completion.' -Files @($paths.RootHooks)
    Add-Check -Id 'hooks.validator_target' -Severity 'P1' -Ok ($hookText -match 'PERLA1/tools/perla_codex_workflow_check\.ps1') -Message 'Hooks target the PERLA1 workflow validator script.' -Files @($paths.RootHooks)

    $hookCommands = New-Object System.Collections.Generic.List[string]
    $hookModeExpectations = @{
      Stop = 'StopHook'
      SubagentStart = 'SubagentStartHook'
      SubagentStop = 'SubagentStopHook'
    }
    $hookModeFailures = @()
    foreach ($eventName in @('Stop', 'SubagentStart', 'SubagentStop')) {
      $eventEntries = $hookJson.hooks.$eventName
      foreach ($eventEntry in @($eventEntries)) {
        foreach ($handler in @($eventEntry.hooks)) {
          $expectedMode = $hookModeExpectations[$eventName]
          if ($null -ne $handler.command) {
            $command = [string]$handler.command
            $hookCommands.Add($command) | Out-Null
            if ($command -notmatch ('-Mode\s+' + [regex]::Escape($expectedMode))) {
              $hookModeFailures += ($eventName + ':command')
            }
          }
          if ($null -ne $handler.commandWindows) {
            $commandWindows = [string]$handler.commandWindows
            $hookCommands.Add($commandWindows) | Out-Null
            if ($commandWindows -notmatch ('-Mode\s+' + [regex]::Escape($expectedMode))) {
              $hookModeFailures += ($eventName + ':commandWindows')
            }
          }
        }
      }
    }

    $forbiddenHookPatterns = @(
      'https?://',
      '\bInvoke-WebRequest\b',
      '\bInvoke-RestMethod\b',
      '\biwr\b',
      '\bcurl\b',
      '\bwget\b',
      '(^|\s)git(\.exe)?\s',
      '(^|\s)gh(\.exe)?\s',
      '(^|\s)codex(\.exe)?\s',
      '(^|\s)node(\.exe)?\s',
      '(^|\s)npm(\.cmd|\.exe)?\s',
      '(^|\s)python(\.exe)?\s',
      '(^|\s)bash(\.exe)?\s',
      '\bStart-Process\b',
      '\bStart-Job\b',
      '\bRemove-Item\b',
      '\bSet-Content\b',
      '\bAdd-Content\b',
      '\bOut-File\b',
      '\bNew-Item\b',
      '\bspawn_agent\b',
      '\bmulti_agent\b'
    )

    $unsafeHookHits = @()
    foreach ($command in $hookCommands) {
      foreach ($pattern in $forbiddenHookPatterns) {
        if ($command -match $pattern) {
          $unsafeHookHits += $pattern
        }
      }
    }

    Add-Check -Id 'hooks.commands_static_safe' -Severity 'P1' -Ok ($unsafeHookHits.Count -eq 0) -Message 'Hook commands avoid network, Git mutation, filesystem writes, process spawning, Codex exec, and subagent spawning.' -Files @($paths.RootHooks)
    Add-Check -Id 'hooks.path_resolution_robust' -Severity 'P2' -Ok ($hookText -match 'Get-Item -LiteralPath \(Get-Location\)\.ProviderPath' -and $hookText -match '\$dir\.FullName') -Message 'Hook command resolves the repository root through filesystem paths and works from subdirectories.' -Files @($paths.RootHooks)
    Add-Check -Id 'hooks.modes_explicit' -Severity 'P1' -Ok ($hookText -match 'Mode StopHook' -and $hookText -match 'Mode SubagentStartHook' -and $hookText -match 'Mode SubagentStopHook') -Message 'Each hook event calls the validator with an explicit lifecycle mode.' -Files @($paths.RootHooks)
    Add-Check -Id 'hooks.event_modes_match' -Severity 'P1' -Ok ($hookModeFailures.Count -eq 0) -Message ('Each hook handler command mode matches its event. Mismatches: ' + (($hookModeFailures | Sort-Object) -join ', ')) -Files @($paths.RootHooks)
  }
  catch {
    Add-Check -Id 'hooks.json_parse' -Severity 'P1' -Ok $false -Message ("Root hooks.json failed to parse: " + $_.Exception.Message) -Files @($paths.RootHooks)
  }
}

$orchestrationText = Read-Text -Path $paths.PerlaOrchestration
if ($null -ne $orchestrationText) {
  Add-Check -Id 'docs.machine_enforcement_orchestration' -Severity 'P1' -Ok ($orchestrationText -match '## Machine Enforcement Layer') -Message 'Orchestration documents the executable workflow enforcement layer.' -Files @($paths.PerlaOrchestration)
  Add-Check -Id 'docs.codex_exec_json' -Severity 'P2' -Ok ($orchestrationText -match 'codex exec --json') -Message 'Orchestration documents codex exec JSONL as the scripted audit route.' -Files @($paths.PerlaOrchestration)
  Add-Check -Id 'docs.hook_trust' -Severity 'P1' -Ok ($orchestrationText -match 'trust review') -Message 'Orchestration states that non-managed Codex hooks require trust review before they actually enforce.' -Files @($paths.PerlaOrchestration)
  Add-Check -Id 'docs.subagents_not_daemons' -Severity 'P1' -Ok ($orchestrationText -match 'not persistent background daemons') -Message 'Orchestration states the real subagent model: summoned work units, not persistent background daemons.' -Files @($paths.PerlaOrchestration)
}

$intakeText = Read-Text -Path $paths.PerlaIntake
if ($null -ne $intakeText) {
  Add-Check -Id 'docs.machine_enforcement_intake' -Severity 'P1' -Ok ($intakeText -match '## Machine Enforcement Gate') -Message 'Task intake protocol documents when the machine validator and hooks are required evidence.' -Files @($paths.PerlaIntake)
  Add-Check -Id 'docs.no_magic_background' -Severity 'P1' -Ok ($intakeText -match 'not evidence that agents are continuously running') -Message 'Task intake protocol distinguishes hook checks from continuously running agents.' -Files @($paths.PerlaIntake)
}

$projectMapText = Read-Text -Path $paths.PerlaProjectMap
if ($null -ne $projectMapText) {
  Add-Check -Id 'docs.project_map_validator' -Severity 'P2' -Ok ($projectMapText -match 'perla_codex_workflow_check\.ps1') -Message 'Project map lists the workflow validator as a known local tool.' -Files @($paths.PerlaProjectMap)
}

$agentsText = Read-Text -Path $paths.PerlaAgents
if ($null -ne $agentsText) {
  Add-Check -Id 'docs.agents_validator' -Severity 'P2' -Ok ($agentsText -match 'perla_codex_workflow_check\.ps1') -Message 'PERLA1 AGENTS.md points maintainers to the executable workflow check.' -Files @($paths.PerlaAgents)
}

$backupToolText = Read-Text -Path $paths.PerlaBackupTool
if ($null -ne $backupToolText) {
  Add-Check -Id 'backup_tool.kind_modes' -Severity 'P1' -Ok ($backupToolText -match "ValidateSet\('User','Automatic'\)") -Message 'Project backup tool exposes User and Automatic modes.' -Files @($paths.PerlaBackupTool)
  Add-Check -Id 'backup_tool.default_repo_scope' -Severity 'P1' -Ok ($backupToolText -match 'defaultProjectRoot\s*=\s*Split-Path -Parent \$perlaRoot') -Message 'Project backup tool defaults to the full synchronized repository folder, not only PERLA1.' -Files @($paths.PerlaBackupTool)
  Add-Check -Id 'backup_tool.rtp_exclusion' -Severity 'P1' -Ok ($backupToolText -match 'PERLA1\\01_GIOCO_PRONTO_LOCAL_TEST\\assets\\rtp') -Message 'Project backup tool excludes only the requested RTP asset folder.' -Files @($paths.PerlaBackupTool)
  Add-Check -Id 'backup_tool.zip_archive' -Severity 'P1' -Ok ($backupToolText -match 'ZipFile' -and $backupToolText -match '\.zip') -Message 'Project backup tool creates zip archives, not backup folders.' -Files @($paths.PerlaBackupTool)
  Add-Check -Id 'backup_tool.automatic_retention_guard' -Severity 'P1' -Ok ($backupToolText -match '\$Kind -eq ''Automatic''' -and $backupToolText -match '\$files\.Count -le 10' -and $backupToolText -match 'AddDays\(-2\)' -and $backupToolText -match 'Remove-Item -LiteralPath \$file\.FullName') -Message 'Automatic backup retention is gated by Automatic mode, more than 10 files, and older-than-2-days file deletion.' -Files @($paths.PerlaBackupTool)
  Add-Check -Id 'backup_tool.user_no_retention' -Severity 'P1' -Ok ($backupToolText -match 'if \(\$Kind -eq ''Automatic''\)' -and $backupToolText -notmatch 'backup\\utente[\s\S]{0,300}Remove-Item') -Message 'User backup folder is not pruned by the backup tool.' -Files @($paths.PerlaBackupTool)
  Add-Check -Id 'backup_tool.schema_output' -Severity 'P2' -Ok ($backupToolText -match 'perla\.project_backup\.v1') -Message 'Project backup tool emits machine-readable backup result schema.' -Files @($paths.PerlaBackupTool)
}

$runtimeIndexText = Read-Text -Path $paths.RuntimeIndex
$runtimeAgentsText = Read-Text -Path $paths.RuntimeAgents
$regressionSuiteText = Read-Text -Path $paths.RegressionSuite
$regressionSuiteRequiredBuildId = ''
$regressionSuiteParseOk = $false
$regressionSuiteParseError = ''
if ($null -ne $regressionSuiteText) {
  try {
    $regressionSuite = $regressionSuiteText | ConvertFrom-Json
    $regressionSuiteParseOk = $true
    $regressionSuiteRequiredBuildId = [string]$regressionSuite.requiredBuildId
  }
  catch {
    $regressionSuiteParseError = $_.Exception.Message
  }
}
$blockMapTextForContract = Read-Text -Path $paths.PerlaBlockMap
$symbolIndexText = Read-Text -Path $paths.PerlaSymbolIndex
$orchestrationTextForContract = Read-Text -Path $paths.PerlaOrchestration
$safeFixerPath = Join-Path $paths.AgentDir 'safe-fixer.toml'
$regressionAuditorPath = Join-Path $paths.AgentDir 'regression-auditor.toml'
$safeFixerText = Read-Text -Path $safeFixerPath
$regressionAuditorText = Read-Text -Path $regressionAuditorPath

if ($null -ne $runtimeIndexText) {
  $buildMatch = [regex]::Match($runtimeIndexText, "PERLA_BUILD_ID\s*=\s*'([^']+)'")
  $buildId = if ($buildMatch.Success) { $buildMatch.Groups[1].Value } else { '' }
  $versionMatch = [regex]::Match($buildId, 'PERLA1_V(\d+)')
  $currentVersion = if ($versionMatch.Success) { 'V' + $versionMatch.Groups[1].Value } else { '' }

  Add-Check -Id 'runtime_contract.build_id_parse' -Severity 'P1' -Ok ($buildMatch.Success -and $versionMatch.Success) -Message ('Runtime PERLA_BUILD_ID is parseable for current contract derivation: ' + $buildId) -Files @($paths.RuntimeIndex)

  $suiteBuildMatchesRuntime = (
    $regressionSuiteParseOk -and
    $regressionSuiteRequiredBuildId.Length -gt 0 -and
    $buildId.Length -gt 0 -and
    $regressionSuiteRequiredBuildId -eq $buildId
  )
  $suiteBuildMessage = ('Deterministic regression suite requiredBuildId matches runtime PERLA_BUILD_ID. Suite=' + $regressionSuiteRequiredBuildId + '; runtime=' + $buildId + '.')
  if (-not $regressionSuiteParseOk -and $regressionSuiteParseError.Length -gt 0) {
    $suiteBuildMessage += (' Parse error: ' + $regressionSuiteParseError)
  }
  Add-Check -Id 'runtime_contract.deterministic_suite_build_id' -Severity 'P1' -Ok $suiteBuildMatchesRuntime -Message $suiteBuildMessage -Files @($paths.RegressionSuite, $paths.RuntimeIndex)

  if ($currentVersion.Length -gt 0) {
    $projectMapCurrent = (
      $null -ne $projectMapText -and
      $projectMapText -match [regex]::Escape($buildId) -and
      ($projectMapText -match ([regex]::Escape($currentVersion) + '\s*\|\s*current contract') -or $projectMapText -match ([regex]::Escape($currentVersion) + '.*current contract'))
    )
    Add-Check -Id 'runtime_contract.project_map_current_build' -Severity 'P1' -Ok $projectMapCurrent -Message ('Project map mirrors runtime current build and marks ' + $currentVersion + ' as current contract.') -Files @($paths.PerlaProjectMap, $paths.RuntimeIndex)

    $blockMapCurrent = (
      $null -ne $blockMapTextForContract -and
      $blockMapTextForContract -match [regex]::Escape($currentVersion) -and
      $blockMapTextForContract -match 'current|Highest-risk rendering block|roof-system'
    )
    Add-Check -Id 'runtime_contract.block_map_current_contract' -Severity 'P1' -Ok $blockMapCurrent -Message ('Block map roof-system contract mentions current runtime version ' + $currentVersion + '.') -Files @($paths.PerlaBlockMap, $paths.RuntimeIndex)

    $symbolIndexCurrent = (
      $null -ne $symbolIndexText -and
      $symbolIndexText -match [regex]::Escape($buildId) -and
      $symbolIndexText -match [regex]::Escape($currentVersion)
    )
    Add-Check -Id 'runtime_contract.symbol_index_current_build' -Severity 'P1' -Ok $symbolIndexCurrent -Message ('Symbol index mirrors runtime current build ' + $buildId + '.') -Files @($paths.PerlaSymbolIndex, $paths.RuntimeIndex)

    $runtimeAgentsCurrent = (
      $null -ne $runtimeAgentsText -and
      $runtimeAgentsText -match [regex]::Escape($buildId) -and
      $runtimeAgentsText -match ([regex]::Escape($currentVersion) + ' current visual contract') -and
      $runtimeAgentsText -match ('For ' + [regex]::Escape($currentVersion) + ' and successors')
    )
    Add-Check -Id 'runtime_contract.runtime_agents_current_contract' -Severity 'P1' -Ok $runtimeAgentsCurrent -Message ('Runtime-local AGENTS.md mirrors current roof contract ' + $currentVersion + ' and build id.') -Files @($paths.RuntimeAgents, $paths.RuntimeIndex)

    $agentTomlsCurrent = (
      $null -ne $safeFixerText -and
      $null -ne $regressionAuditorText -and
      $safeFixerText -match ('As of ' + [regex]::Escape($currentVersion)) -and
      $regressionAuditorText -match ('As of ' + [regex]::Escape($currentVersion))
    )
    Add-Check -Id 'runtime_contract.agent_tomls_current_contract' -Severity 'P1' -Ok $agentTomlsCurrent -Message ('Roof-sensitive agent TOMLs name the current runtime contract ' + $currentVersion + ' as current authority.') -Files @($safeFixerPath, $regressionAuditorPath, $paths.RuntimeIndex)

    $staleAuthorityPatterns = @(
      'As of V278',
      'As of V279',
      'V278 current',
      'V279 current',
      'V282 is the current runtime roof/portal contract',
      'drawModernIntegratedRoofCapV278` is the mapped wall-visible modern roof authority',
      'For V279 and successors',
      'PERLA1_V279_MODERN_ROOF_CAP_PROFILE_SAFE_LOCAL'
    )
    $staleAuthorityHits = @()
    foreach ($candidate in @(
      @{ Path = $paths.RuntimeAgents; Text = $runtimeAgentsText },
      @{ Path = $paths.PerlaBlockMap; Text = $blockMapTextForContract },
      @{ Path = $paths.PerlaOrchestration; Text = $orchestrationTextForContract },
      @{ Path = $safeFixerPath; Text = $safeFixerText },
      @{ Path = $regressionAuditorPath; Text = $regressionAuditorText }
    )) {
      if ($null -eq $candidate.Text) {
        continue
      }
      foreach ($pattern in $staleAuthorityPatterns) {
        if ($candidate.Text -match [regex]::Escape($pattern)) {
          $staleAuthorityHits += ($candidate.Path + ':' + $pattern)
        }
      }
    }
    Add-Check -Id 'runtime_contract.no_stale_roof_authority_phrases' -Severity 'P1' -Ok ($staleAuthorityHits.Count -eq 0) -Message ('Runtime roof authority docs avoid stale current-contract phrases. Hits: ' + (($staleAuthorityHits | Sort-Object) -join '; ')) -Files @($paths.RuntimeAgents, $paths.PerlaBlockMap, $paths.PerlaOrchestration, $safeFixerPath, $regressionAuditorPath)
  }
}

$acceleratorCoreDocs = @(
  $paths.PerlaIntake,
  $paths.PerlaOrchestration,
  $paths.PerlaAgents,
  $paths.PerlaProjectMap,
  $paths.PerlaBlockMap,
  $paths.PerlaContextBudget
)

$acceleratorGovernanceFiles = @(
  (Join-Path $paths.AgentDir 'plan-integrity-auditor.toml'),
  (Join-Path $paths.AgentDir 'workflow-guard.toml'),
  (Join-Path $paths.AgentDir 'workflow-consistency-auditor.toml'),
  (Join-Path $paths.AgentDir 'task-watchdog.toml'),
  (Join-Path $paths.AgentDir 'skeptic-auditor.toml'),
  (Join-Path $paths.AgentDir 'safe-fixer.toml'),
  (Join-Path $paths.AgentDir 'refactor-surgeon.toml'),
  (Join-Path $paths.AgentDir 'map-maintainer.toml')
)

$acceleratorScanFiles = @($acceleratorCoreDocs + $acceleratorGovernanceFiles)
$acceleratorText = @(
  foreach ($scanPath in $acceleratorScanFiles) {
    Read-Text -Path $scanPath
  }
) -join "`n"

if ($acceleratorText.Trim().Length -gt 0) {
  $intakeForAccelerator = Read-Text -Path $paths.PerlaIntake
  $orchestrationForAccelerator = Read-Text -Path $paths.PerlaOrchestration
  Add-Check -Id 'accelerator.canonical_intake_section' -Severity 'P1' -Ok ($intakeForAccelerator -match '## Complex Task Accelerator Protocol') -Message 'Task intake contains the canonical Complex Task Accelerator Protocol section.' -Files @($paths.PerlaIntake)
  Add-Check -Id 'accelerator.orchestration_section' -Severity 'P1' -Ok ($orchestrationForAccelerator -match '## Complex Task Accelerator') -Message 'Orchestration mirrors operational Complex Task Accelerator rules.' -Files @($paths.PerlaOrchestration)

  foreach ($docPath in $acceleratorCoreDocs) {
    $docText = Read-Text -Path $docPath
    Add-Check -Id ('accelerator.core_doc.' + ((Split-Path -Leaf $docPath) -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P2' -Ok ($docText -match 'Complex Task Accelerator|accelerator_brief') -Message ('Complex Task Accelerator is represented in core workflow doc: ' + (Split-Path -Leaf $docPath)) -Files @($docPath)
  }

  $requiredAcceleratorTerms = @(
    'accelerator_brief',
    'cheapest_discriminating_test',
    'critical_path',
    'sidecar_tasks',
    'serial_constraints',
    'validation_ladder',
    'checkpoint_ledger',
    'subagent_task_packet'
  )
  foreach ($term in $requiredAcceleratorTerms) {
    Add-Check -Id ('accelerator.required_term.' + $term) -Severity 'P1' -Ok ($acceleratorText -match [regex]::Escape($term)) -Message ('Complex Task Accelerator required term is documented/enforced: ' + $term) -Files $acceleratorScanFiles
  }

  $acceleratorTomlTermRequirements = @{
    'plan-integrity-auditor.toml' = @('accelerator_brief','cheapest_discriminating_test','critical_path','sidecar_tasks','serial_constraints','validation_ladder','checkpoint_ledger','subagent_task_packet')
    'workflow-guard.toml' = @('accelerator_brief','cheapest_discriminating_test','critical_path','sidecar_tasks','serial_constraints','validation_ladder','checkpoint_ledger','subagent_task_packet')
    'workflow-consistency-auditor.toml' = @('accelerator_brief','cheapest_discriminating_test','critical_path','sidecar_tasks','serial_constraints','validation_ladder','checkpoint_ledger','subagent_task_packet')
    'task-watchdog.toml' = @('accelerator_brief','cheapest_discriminating_test','critical_path','sidecar_tasks','serial_constraints','validation_ladder','checkpoint_ledger','subagent_task_packet')
    'skeptic-auditor.toml' = @('accelerator_brief','cheapest_discriminating_test','critical_path','sidecar_tasks','serial_constraints','validation_ladder','checkpoint_ledger','subagent_task_packet')
    'safe-fixer.toml' = @('accelerator_brief','cheapest_discriminating_test','critical_path','sidecar_tasks','serial_constraints','validation_ladder','checkpoint_ledger','subagent_task_packet')
    'refactor-surgeon.toml' = @('accelerator_brief','cheapest_discriminating_test','critical_path','sidecar_tasks','serial_constraints','validation_ladder','checkpoint_ledger','subagent_task_packet')
    'map-maintainer.toml' = @('accelerator_brief','cheapest_discriminating_test','critical_path','sidecar_tasks','serial_constraints','validation_ladder','checkpoint_ledger','subagent_task_packet')
  }

  foreach ($requirement in $acceleratorTomlTermRequirements.GetEnumerator()) {
    $agentPath = Join-Path $paths.AgentDir $requirement.Key
    $agentText = Read-Text -Path $agentPath
    $missingTerms = @()
    foreach ($term in $requirement.Value) {
      if ($null -eq $agentText -or $agentText -notmatch [regex]::Escape($term)) {
        $missingTerms += $term
      }
    }
    Add-Check -Id ('accelerator.toml_terms.' + (($requirement.Key -replace '\.toml$','') -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($missingTerms.Count -eq 0) -Message ('Agent TOML carries role-required Accelerator terms: ' + $requirement.Key + '. Missing: ' + (($missingTerms | Sort-Object) -join ', ')) -Files @($agentPath)
  }

  $governanceText = @(
    foreach ($governancePath in $acceleratorGovernanceFiles) {
      Read-Text -Path $governancePath
    }
  ) -join "`n"

  Add-Check -Id 'accelerator.toml_enforcement_governance' -Severity 'P1' -Ok ($governanceText -match 'accelerator_brief' -and $governanceText -match 'cheapest_discriminating_test' -and $governanceText -match 'critical_path' -and $governanceText -match 'sidecar_tasks' -and $governanceText -match 'serial_constraints' -and $governanceText -match 'validation_ladder' -and $governanceText -match 'checkpoint_ledger' -and $governanceText -match 'subagent_task_packet') -Message 'Governance/write TOMLs enforce the Complex Task Accelerator packet fields.' -Files $acceleratorGovernanceFiles
  Add-Check -Id 'accelerator.no_gate_bypass' -Severity 'P1' -Ok ($acceleratorText -match 'does not skip `CALL` agents|does not weaken required `CALL` agents|does not authorize bypassing approval' -and $acceleratorText -match 'heartbeat' -and $acceleratorText -match 'validation') -Message 'Accelerator wording states that speed does not bypass CALL agents, heartbeat, validation, or approval rules.' -Files $acceleratorScanFiles
  Add-Check -Id 'accelerator.broad_search_limit' -Severity 'P1' -Ok ($acceleratorText -match '1-2 broad') -Message 'Accelerator enforces the 1-2 broad-search pass limit before narrowing.' -Files $acceleratorScanFiles

  Add-Check -Id 'sidecar_integration.canonical_intake_section' -Severity 'P1' -Ok ($intakeForAccelerator -match '## Sidecar Result Integration Protocol') -Message 'Task intake contains the canonical Sidecar Result Integration Protocol section.' -Files @($paths.PerlaIntake)
  Add-Check -Id 'sidecar_integration.orchestration_section' -Severity 'P1' -Ok ($orchestrationForAccelerator -match '## Sidecar Result Integration') -Message 'Orchestration mirrors operational Sidecar Result Integration rules.' -Files @($paths.PerlaOrchestration)

  $requiredSidecarTerms = @(
    'Sidecar Result Integration Protocol',
    'sidecar_result_integration',
    'source_agent',
    'agent_tool_mapping_ref',
    'path_classification',
    'dependency_on_critical_path',
    'result_status',
    'evidence_received',
    'affects_critical_path',
    'changes_hypothesis',
    'changes_scope',
    'changes_validation',
    'accepted_into_plan',
    'integration_decision',
    'validation_impact',
    'write_scope_impact',
    'approval_impact',
    'heartbeat_checkpoint',
    'stop_condition_triggered',
    'discard_or_defer_reason',
    'ledger_update',
    'integrate',
    'defer',
    'discard',
    'replan',
    'stop'
  )
  foreach ($term in $requiredSidecarTerms) {
    Add-Check -Id ('sidecar_integration.required_term.' + ($term -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($acceleratorText -match [regex]::Escape($term)) -Message ('Sidecar Result Integration required term is documented/enforced: ' + $term) -Files $acceleratorScanFiles
  }

  $sidecarCoreDocTermRequirements = @{
    'PERLA1_TASK_INTAKE_PROTOCOL.md' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'ORCHESTRATION.md' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'AGENTS.md' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'PERLA1_PROJECT_MAP.md' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'PERLA1_CONTEXT_BUDGET.md' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'PERLA1_BLOCK_MAP.md' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
  }

  $sidecarCoreDocPaths = @{
    'PERLA1_TASK_INTAKE_PROTOCOL.md' = $paths.PerlaIntake
    'ORCHESTRATION.md' = $paths.PerlaOrchestration
    'AGENTS.md' = $paths.PerlaAgents
    'PERLA1_PROJECT_MAP.md' = $paths.PerlaProjectMap
    'PERLA1_CONTEXT_BUDGET.md' = $paths.PerlaContextBudget
    'PERLA1_BLOCK_MAP.md' = $paths.PerlaBlockMap
  }

  foreach ($requirement in $sidecarCoreDocTermRequirements.GetEnumerator()) {
    $docPath = $sidecarCoreDocPaths[$requirement.Key]
    $docText = Read-Text -Path $docPath
    $missingTerms = @()
    foreach ($term in $requirement.Value) {
      if ($null -eq $docText -or $docText -notmatch [regex]::Escape($term)) {
        $missingTerms += $term
      }
    }
    Add-Check -Id ('sidecar_integration.core_doc_terms.' + (($requirement.Key -replace '\.md$','') -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($missingTerms.Count -eq 0) -Message ('Core workflow doc carries required Sidecar Result Integration terms: ' + $requirement.Key + '. Missing: ' + (($missingTerms | Sort-Object) -join ', ')) -Files @($docPath)
  }

  $sidecarTomlTermRequirements = @{
    'plan-integrity-auditor.toml' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'workflow-guard.toml' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'workflow-consistency-auditor.toml' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'task-watchdog.toml' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'skeptic-auditor.toml' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'safe-fixer.toml' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'refactor-surgeon.toml' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
    'map-maintainer.toml' = @('sidecar_result_integration','result_status','affects_critical_path','dependency_on_critical_path','accepted_into_plan','integration_decision','validation_impact','write_scope_impact','approval_impact','heartbeat_checkpoint','stop_condition_triggered','discard_or_defer_reason','ledger_update')
  }

  foreach ($requirement in $sidecarTomlTermRequirements.GetEnumerator()) {
    $agentPath = Join-Path $paths.AgentDir $requirement.Key
    $agentText = Read-Text -Path $agentPath
    $missingTerms = @()
    foreach ($term in $requirement.Value) {
      if ($null -eq $agentText -or $agentText -notmatch [regex]::Escape($term)) {
        $missingTerms += $term
      }
    }
    Add-Check -Id ('sidecar_integration.toml_terms.' + (($requirement.Key -replace '\.toml$','') -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($missingTerms.Count -eq 0) -Message ('Agent TOML carries role-required Sidecar Result Integration terms: ' + $requirement.Key + '. Missing: ' + (($missingTerms | Sort-Object) -join ', ')) -Files @($agentPath)
  }

  Add-Check -Id 'sidecar_integration.no_approval_bypass' -Severity 'P1' -Ok ($acceleratorText -match 'Sidecar results are evidence inputs, not approvals|sidecar evidence as approval' -and $acceleratorText -match 'write_scope_impact' -and $acceleratorText -match 'validation_impact' -and $acceleratorText -match 'approval_impact') -Message 'Sidecar integration wording states that parallel evidence does not bypass approval, validation, or write-scope rules.' -Files $acceleratorScanFiles

  Add-Check -Id 'user_intake.canonical_intake_section' -Severity 'P1' -Ok ($intakeForAccelerator -match '## User Intake Relay Protocol') -Message 'Task intake contains the canonical User Intake Relay Protocol section.' -Files @($paths.PerlaIntake)
  Add-Check -Id 'user_intake.orchestration_section' -Severity 'P1' -Ok ($orchestrationForAccelerator -match '## User Intake Relay') -Message 'Orchestration mirrors operational User Intake Relay rules.' -Files @($paths.PerlaOrchestration)

  $requiredUserIntakeTerms = @(
    'User Intake Relay Protocol',
    'user_message_intake',
    'user_message_id',
    'message_class',
    'must_interrupt',
    'must_report_to_team_leader',
    'checkpoint_required',
    'user_intent_summary',
    'conflicts_current_plan',
    'changes_scope',
    'changes_validation',
    'changes_write_scope',
    'approval_impact',
    'agent_gate_impact',
    'agent_tool_mapping_impact',
    'critical_path_impact',
    'sidecar_integration_impact',
    'decision',
    'ledger_update',
    'relay_note',
    'next_action',
    'forbidden_next_action',
    'response_due'
  )
  foreach ($term in $requiredUserIntakeTerms) {
    Add-Check -Id ('user_intake.required_term.' + ($term -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($acceleratorText -match [regex]::Escape($term)) -Message ('User Intake Relay required term is documented/enforced: ' + $term) -Files $acceleratorScanFiles
  }

  $userIntakeCoreDocTermRequirements = @{
    'PERLA1_TASK_INTAKE_PROTOCOL.md' = @('user_message_intake','user_message_id','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'ORCHESTRATION.md' = @('user_message_intake','user_message_id','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'AGENTS.md' = @('user_message_intake','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'PERLA1_PROJECT_MAP.md' = @('user_message_intake','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'PERLA1_CONTEXT_BUDGET.md' = @('user_message_intake','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'PERLA1_BLOCK_MAP.md' = @('user_message_intake','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
  }

  foreach ($requirement in $userIntakeCoreDocTermRequirements.GetEnumerator()) {
    $docPath = $sidecarCoreDocPaths[$requirement.Key]
    $docText = Read-Text -Path $docPath
    $missingTerms = @()
    foreach ($term in $requirement.Value) {
      if ($null -eq $docText -or $docText -notmatch [regex]::Escape($term)) {
        $missingTerms += $term
      }
    }
    Add-Check -Id ('user_intake.core_doc_terms.' + (($requirement.Key -replace '\.md$','') -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($missingTerms.Count -eq 0) -Message ('Core workflow doc carries required User Intake Relay terms: ' + $requirement.Key + '. Missing: ' + (($missingTerms | Sort-Object) -join ', ')) -Files @($docPath)
  }

  $userIntakeTomlTermRequirements = @{
    'plan-integrity-auditor.toml' = @('user_message_intake','user_message_id','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'workflow-guard.toml' = @('user_message_intake','must_interrupt','must_report_to_team_leader','checkpoint_required','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'workflow-consistency-auditor.toml' = @('user_message_intake','user_message_id','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'task-watchdog.toml' = @('user_message_intake','user_message_id','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'skeptic-auditor.toml' = @('user_message_intake','user_message_id','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'safe-fixer.toml' = @('user_message_intake','user_message_id','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'refactor-surgeon.toml' = @('user_message_intake','user_message_id','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
    'map-maintainer.toml' = @('user_message_intake','user_message_id','message_class','must_interrupt','must_report_to_team_leader','checkpoint_required','user_intent_summary','conflicts_current_plan','changes_scope','changes_validation','changes_write_scope','approval_impact','agent_gate_impact','agent_tool_mapping_impact','critical_path_impact','sidecar_integration_impact','decision','ledger_update','relay_note','next_action','forbidden_next_action','response_due')
  }

  foreach ($requirement in $userIntakeTomlTermRequirements.GetEnumerator()) {
    $agentPath = Join-Path $paths.AgentDir $requirement.Key
    $agentText = Read-Text -Path $agentPath
    $missingTerms = @()
    foreach ($term in $requirement.Value) {
      if ($null -eq $agentText -or $agentText -notmatch [regex]::Escape($term)) {
        $missingTerms += $term
      }
    }
    Add-Check -Id ('user_intake.toml_terms.' + (($requirement.Key -replace '\.toml$','') -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($missingTerms.Count -eq 0) -Message ('Agent TOML carries role-required User Intake Relay terms: ' + $requirement.Key + '. Missing: ' + (($missingTerms | Sort-Object) -join ', ')) -Files @($agentPath)
  }

  Add-Check -Id 'user_intake.no_daemon_or_approval_bypass' -Severity 'P1' -Ok ($acceleratorText -match 'not a persistent background listener|not persistent background monitoring|does not promise a persistent background listener' -and $acceleratorText -match 'not approval authority|does not grant approval|Relay classification is not approval' -and $acceleratorText -match 'Team Leader') -Message 'User Intake Relay wording avoids always-on daemon claims and relay approval authority.' -Files $acceleratorScanFiles

  $finalizationRequiredTerms = @(
    'hook_trust_check',
    'checker_semantic_limit',
    'scoped_finalization',
    'finalization_gate',
    'workflow_tooling_manifest',
    'subagent_task_lifecycle',
    'project_backup_gate',
    'backup_user_requested',
    'automatic_task_backup',
    'selective_staging_only',
    'no_global_stage'
  )

  foreach ($term in $finalizationRequiredTerms) {
    Add-Check -Id ('finalization.required_term.' + $term) -Severity 'P1' -Ok ($acceleratorText -match [regex]::Escape($term)) -Message ('Finalization/trust/lifecycle required term is documented/enforced: ' + $term) -Files $acceleratorScanFiles
  }

  $finalizationCoreDocTermRequirements = @{
    'PERLA1_TASK_INTAKE_PROTOCOL.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle','project_backup_gate','backup_user_requested','automatic_task_backup','selective_staging_only','no_global_stage')
    'ORCHESTRATION.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle','project_backup_gate','backup_user_requested','automatic_task_backup','selective_staging_only','no_global_stage')
    'AGENTS.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle','project_backup_gate','backup_user_requested','automatic_task_backup','selective_staging_only','no_global_stage')
    'PERLA1_PROJECT_MAP.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle','project_backup_gate','backup_user_requested','automatic_task_backup')
    'PERLA1_CONTEXT_BUDGET.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle','project_backup_gate','backup_user_requested','automatic_task_backup','selective_staging_only','no_global_stage')
    'PERLA1_BLOCK_MAP.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle','project_backup_gate','backup_user_requested','automatic_task_backup')
  }

  foreach ($requirement in $finalizationCoreDocTermRequirements.GetEnumerator()) {
    $docPath = $sidecarCoreDocPaths[$requirement.Key]
    $docText = Read-Text -Path $docPath
    $missingTerms = @()
    foreach ($term in $requirement.Value) {
      if ($null -eq $docText -or $docText -notmatch [regex]::Escape($term)) {
        $missingTerms += $term
      }
    }
    Add-Check -Id ('finalization.core_doc_terms.' + (($requirement.Key -replace '\.md$','') -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($missingTerms.Count -eq 0) -Message ('Core workflow doc carries required finalization/trust/lifecycle terms: ' + $requirement.Key + '. Missing: ' + (($missingTerms | Sort-Object) -join ', ')) -Files @($docPath)
  }

  $finalizationTomlTermRequirements = @{
    'plan-integrity-auditor.toml' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle')
    'workflow-guard.toml' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle')
    'workflow-consistency-auditor.toml' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle')
    'task-watchdog.toml' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle')
    'skeptic-auditor.toml' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle')
    'safe-fixer.toml' = @('hook_trust_check','checker_semantic_limit','workflow_tooling_manifest','subagent_task_lifecycle')
    'refactor-surgeon.toml' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle')
    'map-maintainer.toml' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle')
  }

  foreach ($requirement in $finalizationTomlTermRequirements.GetEnumerator()) {
    $agentPath = Join-Path $paths.AgentDir $requirement.Key
    $agentText = Read-Text -Path $agentPath
    $missingTerms = @()
    foreach ($term in $requirement.Value) {
      if ($null -eq $agentText -or $agentText -notmatch [regex]::Escape($term)) {
        $missingTerms += $term
      }
    }
    Add-Check -Id ('finalization.toml_terms.' + (($requirement.Key -replace '\.toml$','') -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($missingTerms.Count -eq 0) -Message ('Agent TOML carries role-required finalization/trust/lifecycle terms: ' + $requirement.Key + '. Missing: ' + (($missingTerms | Sort-Object) -join ', ')) -Files @($agentPath)
  }

  Add-Check -Id 'finalization.no_global_stage_or_cleanup' -Severity 'P1' -Ok ($acceleratorText -match 'no_global_stage' -and $acceleratorText -match 'selective staging' -and $acceleratorText -match 'does not authorize rollback|does not authorize.*cleanup|not authorize rollback') -Message 'Finalization wording requires selective staging and does not authorize unrelated cleanup or rollback.' -Files $acceleratorScanFiles
  Add-Check -Id 'hooks.trust_not_forced' -Severity 'P1' -Ok ($acceleratorText -match 'cannot be forced|cannot force Codex|not necessarily trusted|not proven active' -and $acceleratorText -match 'manual workflow checker|run the workflow checker manually') -Message 'Hook trust wording states configured hooks are not proof of active trusted enforcement and defines manual fallback.' -Files $acceleratorScanFiles
  Add-Check -Id 'checker.semantic_limit' -Severity 'P1' -Ok ($acceleratorText -match 'checker_semantic_limit' -and $acceleratorText -match 'cannot prove|does not prove' -and $acceleratorText -match 'visual|rendered|user intent|agent reasoning') -Message 'Checker semantic limit is explicit: deterministic checks do not prove runtime visuals, user intent, or agent reasoning quality.' -Files $acceleratorScanFiles
  Add-Check -Id 'subagent_lifecycle.close_at_task_completion' -Severity 'P1' -Ok ($acceleratorText -match 'Team Leader task completion' -and $acceleratorText -match 'not close|Do not close' -and $acceleratorText -match 'internal step') -Message 'Subagent lifecycle says to close at Team Leader task completion or packet completion/obsolescence, not merely after an internal step.' -Files $acceleratorScanFiles

  $agentInvocationFiles = @(
    $paths.PerlaAgents,
    $paths.PerlaOrchestration,
    $paths.PerlaIntake,
    $paths.PerlaProjectMap,
    $paths.PerlaBlockMap,
    (Join-Path $paths.AgentDir 'workflow-guard.toml'),
    (Join-Path $paths.AgentDir 'workflow-consistency-auditor.toml'),
    (Join-Path $paths.AgentDir 'visual-qa-auditor.toml')
  )

  $agentInvocationText = @(
    foreach ($scanPath in $agentInvocationFiles) {
      Read-Text -Path $scanPath
    }
  ) -join "`n"

  $requiredAgentInvocationTerms = @(
    'call_agent_evidence',
    'direct_invocation',
    'generic_adapter',
    'tooling_blocked',
    'user_delegation_state',
    'agent_tool_mapping_ref',
    'tooling_discovery_attempted',
    'adapter_attempted',
    'visual_qa_required'
  )

  foreach ($term in $requiredAgentInvocationTerms) {
    Add-Check -Id ('agent_invocation.required_term.' + $term) -Severity 'P1' -Ok ($agentInvocationText -match [regex]::Escape($term)) -Message ('Agent invocation enforcement required term is documented/enforced: ' + $term) -Files $agentInvocationFiles
  }

  Add-Check -Id 'agent_invocation.critical_path_not_bypass' -Severity 'P1' -Ok ($agentInvocationText -match 'critical_path' -and $agentInvocationText -match 'not.*bypass|not an excuse|cannot.*bypass' -and $agentInvocationText -match 'sidecar') -Message 'Agent invocation wording states critical_path is not a bypass for required CALL agents and sidecars should run when useful.' -Files $agentInvocationFiles
  Add-Check -Id 'agent_invocation.visual_qa_call' -Severity 'P1' -Ok ($agentInvocationText -match 'visual_qa_required' -and $agentInvocationText -match 'visual-qa-auditor' -and $agentInvocationText -match 'screenshot|rendered|browser') -Message 'Visual QA wording makes visual-qa-auditor CALL for screenshot/rendered/browser validation or visible regression risk before readiness claims.' -Files $agentInvocationFiles
  Add-Check -Id 'agent_invocation.no_local_self_certification' -Severity 'P1' -Ok ($agentInvocationText -match 'only visual QA authority|Self-audit by the Team Leader is degraded evidence|self-audit by the Team Leader is degraded evidence' -and $agentInvocationText -match 'residual risk|degraded fallback') -Message 'Agent invocation wording blocks local-only self-certification except recorded degraded fallback with residual risk.' -Files $agentInvocationFiles

  $visualEvidenceFiles = @(
    $paths.PerlaAgents,
    $paths.PerlaOrchestration,
    $paths.PerlaIntake,
    $paths.PerlaProjectMap,
    $paths.PerlaBlockMap,
    $paths.PerlaContextBudget,
    $paths.PerlaRunbook,
    $paths.PerlaSymbolIndex,
    $paths.RuntimeAgents,
    (Join-Path $paths.AgentDir 'visual-qa-auditor.toml'),
    (Join-Path $paths.AgentDir 'workflow-guard.toml'),
    (Join-Path $paths.AgentDir 'workflow-consistency-auditor.toml'),
    (Join-Path $paths.AgentDir 'plan-integrity-auditor.toml'),
    (Join-Path $paths.AgentDir 'regression-auditor.toml'),
    (Join-Path $paths.AgentDir 'renderer-block-auditor.toml'),
    (Join-Path $paths.AgentDir 'performance-auditor.toml'),
    (Join-Path $paths.AgentDir 'safe-fixer.toml'),
    (Join-Path $paths.AgentDir 'refactor-surgeon.toml'),
    (Join-Path $paths.AgentDir 'task-watchdog.toml'),
    (Join-Path $paths.AgentDir 'skeptic-auditor.toml'),
    (Join-Path $paths.AgentDir 'map-maintainer.toml')
  )

  $visualEvidenceText = @(
    foreach ($scanPath in $visualEvidenceFiles) {
      Read-Text -Path $scanPath
    }
  ) -join "`n"

  $visualEvidenceRequiredTerms = @(
    'hud_contamination_check',
    'coordinate_offset_check',
    'visual_pose_matrix_check',
    'fixed_coordinate_groups',
    'same_coordinate_rotation_consistency',
    'requested_pose',
    'effective_pose',
    'direction_requested',
    'direction_effective',
    'zone',
    'offset_delta',
    'false_coordinate_suspicion',
    'roof_visual_matrix_hard_gate',
    'roof_matrix_declared_before_patch',
    'same_coordinate_distance_rotation_grid',
    'matrix_failed_replan_not_ready',
    'visual_qa_auditor_required'
  )

  foreach ($term in $visualEvidenceRequiredTerms) {
    Add-Check -Id ('visual_evidence.required_term.' + $term) -Severity 'P1' -Ok ($visualEvidenceText -match [regex]::Escape($term)) -Message ('Visual evidence hygiene required term is documented/enforced: ' + $term) -Files $visualEvidenceFiles
  }

  $visualCoreDocTermRequirements = @{
    'AGENTS.md' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'ORCHESTRATION.md' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'PERLA1_TASK_INTAKE_PROTOCOL.md' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','requested_pose','effective_pose','direction_requested','direction_effective','offset_delta','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready','visual_qa_auditor_required')
    'PERLA1_RUNTIME_TEST_RUNBOOK.md' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','requested_pose','effective_pose','direction_requested','direction_effective','offset_delta','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready','visual_qa_auditor_required')
    'PERLA1_PROJECT_MAP.md' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','same-coordinate','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'PERLA1_BLOCK_MAP.md' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'PERLA1_CONTEXT_BUDGET.md' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','offset_delta','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'PERLA1_SYMBOL_INDEX.md' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','roof_visual_matrix_hard_gate','setPlayerForDebug','collectPerlaDebugSnapshot','zoneAtPlayer','perlaLastDrawStats','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    '01_GIOCO_PRONTO_LOCAL_TEST/AGENTS.md' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','offset_delta','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
  }

  $visualCoreDocPaths = @{
    'AGENTS.md' = $paths.PerlaAgents
    'ORCHESTRATION.md' = $paths.PerlaOrchestration
    'PERLA1_TASK_INTAKE_PROTOCOL.md' = $paths.PerlaIntake
    'PERLA1_RUNTIME_TEST_RUNBOOK.md' = $paths.PerlaRunbook
    'PERLA1_PROJECT_MAP.md' = $paths.PerlaProjectMap
    'PERLA1_BLOCK_MAP.md' = $paths.PerlaBlockMap
    'PERLA1_CONTEXT_BUDGET.md' = $paths.PerlaContextBudget
    'PERLA1_SYMBOL_INDEX.md' = $paths.PerlaSymbolIndex
    '01_GIOCO_PRONTO_LOCAL_TEST/AGENTS.md' = $paths.RuntimeAgents
  }

  foreach ($requirement in $visualCoreDocTermRequirements.GetEnumerator()) {
    $docPath = $visualCoreDocPaths[$requirement.Key]
    $docText = Read-Text -Path $docPath
    $missingTerms = @()
    foreach ($term in $requirement.Value) {
      if ($null -eq $docText -or $docText -notmatch [regex]::Escape($term)) {
        $missingTerms += $term
      }
    }
    Add-Check -Id ('visual_evidence.core_doc_terms.' + (($requirement.Key -replace '\.md$','') -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($missingTerms.Count -eq 0) -Message ('Core workflow/runtime doc carries required visual evidence hygiene terms: ' + $requirement.Key + '. Missing: ' + (($missingTerms | Sort-Object) -join ', ')) -Files @($docPath)
  }

  $visualTomlTermRequirements = @{
    'visual-qa-auditor.toml' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','modernStableRoofPrimitiveFacesDrawnV281','modernStableRoofPrimitiveBudgetHitV281','requested_pose','effective_pose','direction_requested','direction_effective','offset_delta','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready','visual_qa_auditor_required')
    'workflow-guard.toml' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','modernStableRoofPrimitiveFacesDrawnV281','modernStableRoofPrimitiveBudgetHitV281','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready','visual_qa_auditor_required')
    'workflow-consistency-auditor.toml' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','suspicious_coordinates','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready','visual_qa_auditor_required')
    'plan-integrity-auditor.toml' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','requested_pose','effective_pose','offset_delta','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'regression-auditor.toml' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','modernStableRoofPrimitiveFacesDrawnV281','modernStableRoofPrimitiveSkippedTopFacesNearDoorV281','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'renderer-block-auditor.toml' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'performance-auditor.toml' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','same_coordinate_rotation_consistency','modernStableRoofPrimitiveBudgetHitV281','modernStableRoofPrimitiveWarnPixelsV281','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'safe-fixer.toml' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','modernStableRoofPrimitiveFacesDrawnV281','modernStableRoofPrimitiveBudgetHitV281','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'refactor-surgeon.toml' = @('hud_contamination_check','coordinate_offset_check')
    'task-watchdog.toml' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'skeptic-auditor.toml' = @('hud_contamination_check','coordinate_offset_check','visual_pose_matrix_check','fixed_coordinate_groups','same_coordinate_rotation_consistency','false_coordinate_suspicion','roof_visual_matrix_hard_gate','roof_matrix_declared_before_patch','same_coordinate_distance_rotation_grid','matrix_failed_replan_not_ready')
    'map-maintainer.toml' = @('hud_contamination_check','coordinate_offset_check','offset_delta','false_coordinate_suspicion')
  }

  foreach ($requirement in $visualTomlTermRequirements.GetEnumerator()) {
    $agentPath = Join-Path $paths.AgentDir $requirement.Key
    $agentText = Read-Text -Path $agentPath
    $missingTerms = @()
    foreach ($term in $requirement.Value) {
      if ($null -eq $agentText -or $agentText -notmatch [regex]::Escape($term)) {
        $missingTerms += $term
      }
    }
    Add-Check -Id ('visual_evidence.toml_terms.' + (($requirement.Key -replace '\.toml$','') -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($missingTerms.Count -eq 0) -Message ('Agent TOML carries role-required visual evidence hygiene terms: ' + $requirement.Key + '. Missing: ' + (($missingTerms | Sort-Object) -join ', ')) -Files @($agentPath)
  }

  Add-Check -Id 'visual_evidence.hud_not_geometry' -Severity 'P1' -Ok ($visualEvidenceText -match 'HUD|hud' -and $visualEvidenceText -match 'clock|orologio' -and $visualEvidenceText -match 'minimap' -and $visualEvidenceText -match 'renderer geometry|world/render') -Message 'Visual evidence rules distinguish HUD/clock/minimap/overlay contamination from renderer geometry.' -Files $visualEvidenceFiles
  Add-Check -Id 'visual_evidence.coordinate_perla_trigger' -Severity 'P1' -Ok ($visualEvidenceText -match 'certainty or legitimate doubt|certain or legitimately suspected|legitimate doubt' -and $visualEvidenceText -match 'PERLA1' -and $visualEvidenceText -match 'unrelated non-PERLA') -Message 'Coordinate offset check is scoped to PERLA1 certainty/legitimate doubt and does not burden unrelated non-PERLA work.' -Files $visualEvidenceFiles
  Add-Check -Id 'visual_evidence.pose_matrix_rotation_invariants' -Severity 'P1' -Ok ($visualEvidenceText -match 'visual_pose_matrix_check' -and $visualEvidenceText -match 'same-coordinate|same coordinate|same `x/y`' -and $visualEvidenceText -match 'center.*left.*right|left.*right' -and $visualEvidenceText -match 'budget|face count|faces') -Message 'Visual evidence rules require same-coordinate rotation matrix and counter invariants for rotation-sensitive rendered work.' -Files $visualEvidenceFiles
  Add-Check -Id 'visual_evidence.roof_matrix_hard_gate' -Severity 'P1' -Ok ($visualEvidenceText -match 'roof_visual_matrix_hard_gate' -and $visualEvidenceText -match 'roof_matrix_declared_before_patch' -and $visualEvidenceText -match 'same_coordinate_distance_rotation_grid' -and $visualEvidenceText -match 'runtime/internal|runtime internal|internal coordinate' -and $visualEvidenceText -match 'HUD/display|display X' -and $visualEvidenceText -match 'far.*close.*east.*west|east.*west.*interior|user-repro|user repro' -and $visualEvidenceText -match 'contact sheet|indexed matrix' -and $visualEvidenceText -match 'matrix_failed_replan_not_ready' -and $visualEvidenceText -match 'visual_qa_auditor_required|visual-qa-auditor') -Message 'Roof/eave visual evidence requires declared hard-gate matrix with runtime coordinates, HUD separation, required distance/rotation groups, contact sheet/index, visual QA, and hard fail wording.' -Files $visualEvidenceFiles
  Add-Check -Id 'visual_evidence.not_automatic_proof' -Severity 'P1' -Ok ($visualEvidenceText -match 'not.*automatic proof|Do not rewrite them into automatic proof|not.*substitute|cannot replace' -and $visualEvidenceText -match 'visual inspection|screenshot inspection|counters') -Message 'Visual evidence hygiene wording does not turn checks into automatic proof replacing inspection/counters.' -Files $visualEvidenceFiles
}

if (Test-Path -LiteralPath $paths.AgentDir) {
  $agentFiles = Get-ChildItem -LiteralPath $paths.AgentDir -Filter '*.toml' -File
  Add-Check -Id 'agents.toml_count' -Severity 'P2' -Ok ($agentFiles.Count -ge 1) -Message ("Project agent TOML files found: " + $agentFiles.Count) -Files @($paths.AgentDir)

  $agentNames = New-Object System.Collections.Generic.HashSet[string]
  foreach ($agentFile in $agentFiles) {
    $agentText = Read-Text -Path $agentFile.FullName
    if ($null -eq $agentText) {
      continue
    }
    $hasName = $agentText -match '(?m)^\s*name\s*='
    $hasDescription = $agentText -match '(?m)^\s*description\s*='
    $hasInstructions = $agentText -match '(?m)^\s*developer_instructions\s*='
    Add-Check -Id ('agents.schema.' + $agentFile.BaseName) -Severity 'P1' -Ok ($hasName -and $hasDescription -and $hasInstructions) -Message ('Agent TOML has required name, description, and developer_instructions fields: ' + $agentFile.Name) -Files @($agentFile.FullName)

    $nameMatch = [regex]::Match($agentText, '(?m)^\s*name\s*=\s*"([^"]+)"')
    if ($nameMatch.Success) {
      $declaredName = $nameMatch.Groups[1].Value
      $agentNames.Add($declaredName) | Out-Null
      Add-Check -Id ('agents.filename_matches_name.' + $agentFile.BaseName) -Severity 'P2' -Ok ($agentFile.BaseName -eq $declaredName) -Message ('Agent TOML filename matches name field: ' + $agentFile.Name) -Files @($agentFile.FullName)
    }
  }

  $registryText = @(
    Read-Text -Path $paths.PerlaOrchestration
    Read-Text -Path $paths.PerlaIntake
    Read-Text -Path $paths.PerlaProjectMap
  ) -join "`n"

  foreach ($agentName in $agentNames) {
    Add-Check -Id ('agents.registry_mentions.' + $agentName) -Severity 'P2' -Ok ($registryText -match [regex]::Escape($agentName)) -Message ('Agent is represented in orchestration/intake/project-map registry: ' + $agentName) -Files @($paths.PerlaOrchestration, $paths.PerlaIntake, $paths.PerlaProjectMap)
  }

  $docsForAgentRefs = @(
    $paths.PerlaOrchestration,
    $paths.PerlaIntake,
    $paths.PerlaProjectMap,
    $paths.PerlaBlockMap,
    $paths.PerlaAgents
  )

  $referencedAgents = New-Object System.Collections.Generic.HashSet[string]
  foreach ($docPath in $docsForAgentRefs) {
    $docText = Read-Text -Path $docPath
    if ($null -eq $docText) {
      continue
    }
    foreach ($match in [regex]::Matches($docText, '`([a-z][a-z0-9-]+)`')) {
      $token = $match.Groups[1].Value
      if ($token -match '(auditor|guard|watchdog|surgeon|fixer|mapper|maintainer)$') {
        $referencedAgents.Add($token) | Out-Null
      }
    }
  }

  $missingReferencedAgents = @()
  foreach ($agentRef in $referencedAgents) {
    if (-not $agentNames.Contains($agentRef)) {
      $missingReferencedAgents += $agentRef
    }
  }
  Add-Check -Id 'agents.referenced_agents_exist' -Severity 'P1' -Ok ($missingReferencedAgents.Count -eq 0) -Message ('Every workflow-doc agent reference has a matching TOML. Missing: ' + (($missingReferencedAgents | Sort-Object) -join ', ')) -Files $docsForAgentRefs
}

$gitIgnoreText = Read-Text -Path $paths.GitIgnore
if ($null -ne $gitIgnoreText) {
  $requiredIgnorePatterns = @(
    'PERLA1/report/WORKFLOW_CHECK_*.json',
    'PERLA1/report/WORKFLOW_CHECK_*.jsonl',
    'PERLA1/report/CODEX_EXEC_*.jsonl',
    'PERLA1/report/HOOK_*.log'
  )
  foreach ($ignorePattern in $requiredIgnorePatterns) {
    Add-Check -Id ('gitignore.workflow_artifact.' + ($ignorePattern -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P2' -Ok ($gitIgnoreText -match [regex]::Escape($ignorePattern)) -Message ('Disposable workflow artifact pattern is ignored: ' + $ignorePattern) -Files @($paths.GitIgnore)
  }
}

$blockMapText = Read-Text -Path $paths.PerlaBlockMap
if ($null -ne $blockMapText) {
  Add-Check -Id 'docs.block_map_jsonl_disposable' -Severity 'P2' -Ok ($blockMapText -match 'generated reports, JSON, JSONL, hook logs') -Message 'Block map states workflow JSON/JSONL/hook logs are disposable unless promoted.' -Files @($paths.PerlaBlockMap)
  Add-Check -Id 'docs.hooks_do_not_replace_call_agents' -Severity 'P1' -Ok ($blockMapText -match 'must not replace required `CALL` agent output') -Message 'Block map states hooks do not replace required CALL agent output.' -Files @($paths.PerlaBlockMap)
}

$forbiddenClaims = @(
  'agents are always running automatically',
  'subagents are always running automatically',
  'workflow-guard is a background daemon',
  'frasi stale non succederanno mai piu',
  'gli agenti sono sempre attivi',
  'subagent sempre attivi',
  'monitor continuo in background',
  'agenti sempre accesi',
  'subagent sempre accesi',
  'agenti sempre in esecuzione',
  'subagent sempre in esecuzione',
  'always-on agents',
  'always on agents',
  'continuous background monitor'
)

$docTargets = @(
  $paths.PerlaOrchestration,
  $paths.PerlaIntake,
  $paths.PerlaAgents,
  $paths.PerlaProjectMap
)

foreach ($claim in $forbiddenClaims) {
  $hitFiles = @()
  foreach ($target in $docTargets) {
    $text = Read-Text -Path $target
    if ($null -ne $text -and $text.ToLowerInvariant().Contains($claim)) {
      $hitFiles += $target
    }
  }
  Add-Check -Id ('docs.forbidden_claim.' + ($claim -replace '[^a-zA-Z0-9]+','_').Trim('_')) -Severity 'P1' -Ok ($hitFiles.Count -eq 0) -Message ('Forbidden absolute/background claim absent: ' + $claim) -Files $hitFiles
}

$failedBlocking = @(
  $checks |
    Where-Object {
      -not $_.ok -and ($_.severity -eq 'P0' -or $_.severity -eq 'P1')
    }
)

$failedAny = @($checks | Where-Object { -not $_.ok })
$blockingCount = [int]$failedBlocking.Count
$warningCount = [int]($failedAny.Count - $failedBlocking.Count)
$checkArray = @($checks.ToArray())
$status = 'pass'
if ($blockingCount -gt 0) {
  $status = 'fail'
}
elseif ($failedAny.Count -gt 0) {
  $status = 'warn'
}

$result = [pscustomobject]@{
  schema_version = 'perla.workflow.check.v1'
  tool = 'perla_codex_workflow_check'
  mode = $Mode
  status = $status
  generated_at = (Get-Date).ToString('o')
  repo_root = [string]$repoRoot
  perla_root = [string]$perlaRoot
  blocking_failures = $blockingCount
  warnings = $warningCount
  checks = $checkArray
}

if ($Jsonl) {
  foreach ($check in $checks) {
    [pscustomobject]@{
      schema_version = 'perla.workflow.check.v1'
      event = 'check'
      mode = $Mode
      check = $check
    } | ConvertTo-Json -Depth 6 -Compress
  }
  [pscustomobject]@{
    schema_version = 'perla.workflow.check.v1'
    event = 'summary'
    mode = $Mode
    status = $status
    blocking_failures = $blockingCount
    warnings = $warningCount
    generated_at = $result.generated_at
  } | ConvertTo-Json -Depth 6 -Compress
}
elseif ($Json) {
  $result | ConvertTo-Json -Depth 6
}
else {
  "PERLA1 Codex workflow check: $status"
  foreach ($check in $checks) {
    $prefix = if ($check.ok) { 'OK' } else { 'FAIL' }
    "$prefix [$($check.severity)] $($check.id): $($check.message)"
  }
}

if ($status -eq 'fail' -or ($Strict -and $status -ne 'pass')) {
  exit 1
}

exit 0
