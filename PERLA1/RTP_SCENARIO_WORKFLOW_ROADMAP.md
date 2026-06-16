# PERLA1 RTP Scenario Workflow Roadmap

Status: permanent roadmap for RTP, sprites, events, dialogues, placements, behavior loops, and scenario/gameplay mapping.

This file is the durable state ledger for the RTP/scenario workflow. It is updated at the start and end of non-trivial RTP/sprite/event/dialogue tasks through `rtp-scenario-workflow-planner`, or by the Team Leader only when that planner is unavailable and the degraded fallback is recorded.

It does not activate runtime loading. RTP files remain dormant until runtime code explicitly loads them and the normal PERLA1 validation ladder passes.

## Source Of Truth

- Identity/assets: `01_GIOCO_PRONTO_LOCAL_TEST/assets/rtp/manifest/rtp.characters.json`
- RTP asset rules: `01_GIOCO_PRONTO_LOCAL_TEST/assets/rtp/README_RTP_ASSETS.md`
- Scenario mapping rules: `01_GIOCO_PRONTO_LOCAL_TEST/assets/rtp/SCENARIO_EVENT_MAPPING_PROTOCOL.md`
- Intake/gate rules: `PERLA1_TASK_INTAKE_PROTOCOL.md`
- Orchestration rules: `.codex/ORCHESTRATION.md`
- Static scenario validator: `tools/perla_rtp_scenario_validator.py`

## Current Position

- Current phase: `phase_1_foundation_ready`
- Current milestone: `milestone_1_rtp_assets_and_workflow_gate`
- Active task packet: `none_current_task_completed`
- Last updated: `2026-06-16`
- Runtime integration status: `dormant_not_loaded`
- Future scenario manifests status: `not_created_yet`

## Phase Roadmap

| Phase | Status | Objective | Completion Evidence |
| --- | --- | --- | --- |
| `phase_0_source_intake` | complete | Read supplied RTP zip, sceneggiatura/GDD/storyboard, identify source role and tone. | RTP audit and scenario/gameplay draft exist. |
| `phase_1_foundation_ready` | complete | Keep optimized RTP assets, manifest, schemas, validator, domain agents, planner, and roadmap coherent. | Workflow checker pass, RTP validator pass, planner registered, roadmap maintained. |
| `phase_2_scenario_manifests` | pending | Create `rtp.placements.json`, `rtp.behaviors.json`, `rtp.dialogues.json`, and `rtp.events.json` from sceneggiatura/gameplay. | Static RTP validator pass with future manifests present. |
| `phase_3_runtime_mapping_design` | pending | Map future manifests to runtime loader/event/dialogue architecture without activating unsafe behavior. | Code map, plan audit, no-paradox event graph, runtime integration plan. |
| `phase_4_runtime_integration` | pending | Load selected RTP data into PERLA1 runtime behind validated gates. | Static CI, runtime route, visual QA, performance/regression checks. |
| `phase_5_event_authoring` | pending | Author real map events, NPC/animal schedules, dialogue chains, resources, and battle placeholders. | Event/dialogue/placement audits, runtime validation, no-softlock checks. |
| `phase_6_intro_storyboard_asset` | future | Optimize and integrate intro storyboard/comic asset after core event workflow is stable. | Asset optimization audit and startup/runtime validation. |

## Active Task Packet

Task id: `roadmap_planner_integration`

Goal:

- Add a permanent RTP/scenario planner role.
- Ensure every non-trivial request about RTP, sprites, events, dialogues, characters, NPC, animals, placements, behavior, battle placeholders, resources, or base upgrades activates the RTP workflow branch.
- Ensure the planner is called at task start to state roadmap position and at task end to update this roadmap.

Required agents for this task type:

- `rtp-scenario-workflow-planner`: `CALL` at start and end.
- `workflow-consistency-auditor`: `CALL` for workflow/TOML/gate changes.
- `workflow-guard`: `CALL` for authority or loop risk before protected steps.
- `plan-integrity-auditor`: `CALL` when the planner's roadmap becomes an execution plan.
- `scenario-rtp-map-auditor`: `CALL` when scenario/RTP identity or manifest planning is touched.
- `map-placement-auditor`: `CALL` when placement/coordinate/walkability/visibility decisions are touched.
- `event-flow-auditor`: `CALL` when event graph, battle placeholder, prerequisite/effect, or no-softlock decisions are touched.
- `dialogue-continuity-auditor`: `CALL` when dialogue, speaker, portrait, or dialogueRefs are touched.
- `asset-integrity-auditor`: `CALL` for RTP manifest/assets/path/cache changes.
- `code-mapper`, `renderer-block-auditor`, `visual-qa-auditor`, `performance-auditor`, and `regression-auditor`: `CALL` when runtime/rendering/performance/regression scope appears.

## Milestones

### `milestone_1_rtp_assets_and_workflow_gate`

Status: `complete`

Completed:

- Optimized RTP assets are present under `assets/rtp/`.
- `rtp.characters.json` is the dormant identity/asset manifest.
- Future scenario schemas exist.
- Static RTP scenario validator exists.
- Four RTP domain auditors exist and are registered.
- `rtp-scenario-workflow-planner` exists and is registered with roadmap-only write scope.
- `RTP_SCENARIO_WORKFLOW_ROADMAP.md` is the permanent roadmap/state ledger.
- The intake gate, orchestration, project map, RTP README, scenario protocol, and PERLA1 AGENTS rules activate the RTP/scenario branch for non-trivial RTP/sprite/event/dialogue/personaggi work.
- Workflow checker enforces planner presence, planner scope, start/end rule, roadmap fields, and RTP validator execution.

In progress:

- None for this milestone.

Completion criteria:

- `tools/perla_codex_workflow_check.ps1 -Mode CI -Json` passes.
- `tools/perla_rtp_scenario_validator.py --json` passes.
- Planner TOML exists, has limited roadmap-only write scope, and is registered in workflow docs.
- This roadmap has current phase, milestone, active task packet, validation evidence, and next step.

Status: `complete`

### `milestone_2_future_manifest_authoring`

Status: `pending`

Objective:

- Build the first draft of `rtp.placements.json`, `rtp.behaviors.json`, `rtp.dialogues.json`, and `rtp.events.json` from sceneggiatura/gameplay.

Entry requirements:

- Planner start checkpoint.
- Scenario/RTP, placement, event-flow, and dialogue auditors selected by gate.
- Source files confirmed.

Exit requirements:

- Static RTP validator passes with future manifests present.
- Explicit vs inferred fields are marked.
- No animal dialogues.
- Battle placeholder `won/lost` branches exist.
- Missing assets are explicit placeholders.

### `milestone_3_runtime_integration_plan`

Status: `pending`

Objective:

- Design how runtime will consume selected RTP data without broad preload or duplicate left assets.

Entry requirements:

- Code mapper identifies loader/event/dialogue integration points.
- Plan-integrity audit approves the implementation plan.

Exit requirements:

- Runtime validation ladder defined.
- Cache/versioning policy defined.
- Visual/performance/regression risks assigned to auditors.

## Step State Rules

Allowed step states:

- `pending`
- `in_progress`
- `blocked`
- `pending_validation`
- `complete`
- `future`

Rules:

- A step is `complete` only when the roadmap names the evidence.
- A step is `pending_validation` when code/data was changed but required checker, validator, runtime, visual, or auditor evidence is missing.
- A step is `blocked` when the next action needs user approval, missing source material, unavailable tooling, or unresolved P0/P1 audit findings.
- A future manifest remains dormant until runtime integration is explicit.

## Validation Ledger

Latest known validation:

- RTP scenario validator: `pass_2026-06-16`; warnings only for future dormant manifests not created yet.
- Workflow checker: `pass_2026-06-16`; `blocking_failures: 0`, `warnings: 0`.
- TOML/JSON parse: `pass_2026-06-16`.
- Runtime validation: `not_applicable_dormant_workflow_only`

## Residual Risks

- Future scenario manifests are not created yet.
- Real map coordinates, walkability, visibility, collision, sprite density, and runtime event behavior remain unvalidated until runtime/map integration work begins.
- Existing dirty worktree changes outside this RTP workflow may require separate validation before sync.

## Task Log

### 2026-06-16 - `roadmap_planner_integration`

Completed:

- Added `rtp-scenario-workflow-planner`.
- Added this permanent roadmap.
- Registered start/end planner rules in PERLA1 intake, orchestration, project map, PERLA1 AGENTS, RTP README, scenario protocol, RTP manifest, and workflow checker.
- Aligned roof-sensitive workflow docs/TOMLs to the current V302 runtime contract required by the checker, without editing runtime code.
- Validated TOML/JSON parse, RTP scenario validator, and workflow checker.

Residual risk:

- Future scenario manifests are still not authored.
- Runtime/map coordinate validation remains pending until RTP data is actually integrated.

## Next Step

On the next non-trivial RTP/sprite/event/dialogue/personaggi task, call `rtp-scenario-workflow-planner` at start to open `milestone_2_future_manifest_authoring`, then call the matching RTP domain auditors before authoring future scenario manifests.
