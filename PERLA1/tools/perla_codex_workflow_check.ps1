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
    'selective_staging_only',
    'no_global_stage'
  )

  foreach ($term in $finalizationRequiredTerms) {
    Add-Check -Id ('finalization.required_term.' + $term) -Severity 'P1' -Ok ($acceleratorText -match [regex]::Escape($term)) -Message ('Finalization/trust/lifecycle required term is documented/enforced: ' + $term) -Files $acceleratorScanFiles
  }

  $finalizationCoreDocTermRequirements = @{
    'PERLA1_TASK_INTAKE_PROTOCOL.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle','selective_staging_only','no_global_stage')
    'ORCHESTRATION.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle','selective_staging_only','no_global_stage')
    'AGENTS.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle','selective_staging_only','no_global_stage')
    'PERLA1_PROJECT_MAP.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle')
    'PERLA1_CONTEXT_BUDGET.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle','selective_staging_only','no_global_stage')
    'PERLA1_BLOCK_MAP.md' = @('hook_trust_check','checker_semantic_limit','scoped_finalization','finalization_gate','workflow_tooling_manifest','subagent_task_lifecycle')
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
