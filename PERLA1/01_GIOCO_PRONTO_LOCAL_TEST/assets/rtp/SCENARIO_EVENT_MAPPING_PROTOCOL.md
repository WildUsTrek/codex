# PERLA1 Scenario And Event Mapping Protocol

Status: dormant planning protocol for future scenario/gameplay integration.

This document defines how future sceneggiatura and gameplay specifications must be converted into PERLA1 map placements, time schedules, behavior loops, dialogue/event lines, battle placeholders, and missing-asset placeholders.

It does not override `AGENTS.md`, `PERLA1_TASK_INTAKE_PROTOCOL.md`, or runtime validation rules. It becomes operational only when a task imports or maps scenario/gameplay content.

## Trigger

Use this protocol whenever the task goal mentions sceneggiatura, gameplay, events, eventi, dialoghi, NPC placement, character placement, animals, resources, player base upgrades, battle launch, or story-to-map mapping.

Required references:

- `assets/rtp/README_RTP_ASSETS.md`
- `assets/rtp/manifest/rtp.characters.json`
- this file
- `PERLA1/report/SCENEGGIATURA_GAMEPLAY_MAPPING_DRAFT_2026-06-14.md` when using the first supplied sceneggiatura/GDD/storyboard source set

## Core Principle

The scenario/gameplay input is the design source. The runtime map is the spatial constraint. The RTP manifest is the identity/asset source.

When the scenario is precise, follow it. When it is incomplete, infer the most plausible placement, schedule, behavior, or representation and mark the result as inferred with a short rationale.

Never silently invent facts as if they were specified.

## Future Output Manifests

When scenario integration begins, generate explicit data manifests instead of burying decisions in runtime code:

```text
assets/rtp/manifest/
  rtp.characters.json      # existing identity/assets manifest
  rtp.placements.json      # map positions, zones, schedules
  rtp.behaviors.json       # idle/walk loops, patrol rules, ambient routines
  rtp.dialogues.json       # character-only dialogue/event lines
  rtp.events.json          # story/gameplay event mapping and placeholders
```

These files must remain dormant until `index.html` or future runtime modules explicitly load them.

## Entity Classification

Every scenario/gameplay entity must be classified before placement:

| Entity type | Examples | Required mapping |
|---|---|---|
| `main_character` | Bruno Basalto, Imperio, Nina Ciottolo | placement, time bands, behavior loop, dialogue lines, event links |
| `npc` | Agente Igiene 007, Nonna Pina | placement, time bands, behavior loop, dialogue lines, event links |
| `animal` | cat, dog, birds, lizard | placement, time bands, ambient behavior loop only |
| `resource` | collectible materials, pickups | placeholder asset, spawn logic, placement |
| `base_or_upgrade` | player base, upgrade stages | placeholder or required asset, map footprint, upgrade states |
| `system_event` | battle, unlock, quest step, tutorial | trigger position, prerequisites, outcome handling |

Animals must not receive dialogue lines. If a future design needs animal communication, it must be promoted to a special narrative exception instead of being treated as default animal behavior.

## Placement Rules

For each entity, produce a placement record with:

- `id`
- `entityType`
- `zone`
- `position`: exact coordinates if provided, otherwise inferred coordinates
- `placementSource`: `script_explicit`, `gameplay_explicit`, or `inferred`
- `placementRationale`
- `timeBands`
- `availabilityConditions`
- `eventLinks`
- `validationNotes`

If the scenario does not specify a position, infer one from:

- character role and narrative function;
- referenced place, activity, or relationship;
- gameplay access flow;
- nearby event triggers;
- biome/zone fit for animals;
- visibility and readability in raycaster view;
- avoidance of blocked tiles, roofs, walls, tight corridors, and high-overdraw crowds.

Do not place entities only because there is empty space. Placement must support story clarity, gameplay readability, and believable world life.

## Time Bands

Every character or animal must receive time-band availability.

Use explicit scenario times when present. If missing, infer plausible bands and mark them as inferred.

Recommended normalized bands:

```text
dawn
morning
day
afternoon
sunset
night
storm_or_special_weather
event_only
```

Rules:

- One entity cannot be in two incompatible locations in the same time band.
- Event-critical characters should use `event_only` or a tightly scoped band when their presence would otherwise create paradoxes.
- Animals may use wider ambient bands, but should still respect biome and activity.
- If time of day is irrelevant, use `day` as a default only with `timeBandSource: "inferred"`.

## Behavior Loop Rules

Every placed character/animal needs an intelligent map behavior loop.

Standard behavior shape:

```json
{
  "mode": "idle_walk_loop",
  "anchor": {"x": 0, "y": 0},
  "radius": 2,
  "idleSeconds": [2, 6],
  "walkSeconds": [1, 4],
  "turnBehavior": "face_path_or_player_when_interacted",
  "collisionPolicy": "non_blocking_or_soft_blocking",
  "schedulePolicy": "active_only_in_time_bands"
}
```

Premium raycaster-world standards:

- routines should make the world feel alive without blocking player flow;
- patrol radius should stay readable and local unless the character has a story reason to roam;
- important characters should idle near readable landmarks or event anchors;
- animals should use ambient movement, short patrols, fleeing/perching/resting loops, or biome-specific idle;
- no behavior should create heavy sprite clustering in one camera corridor;
- no routine should require left-facing duplicate assets; left-facing render is derived by mirror.

## Dialogue Rules

Dialogues are for characters only: `main_character` and `npc`.

For every character dialogue:

- connect it to a scenario line, event line, quest step, or fallback ambient line;
- record prerequisites and outcome effects;
- attach the correct portrait only for main characters unless an NPC portrait exception is explicitly approved;
- do not assign dialogue to animals;
- do not let dialogue contradict the entity's time band or current event state.

Recommended future dialogue record:

```json
{
  "id": "dialogue.bruno_basalto.intro_001",
  "speakerId": "bruno_basalto",
  "eventId": "event.intro.meet_bruno",
  "lineType": "event",
  "portraitPolicy": "main_character_portrait",
  "conditions": [],
  "effects": []
}
```

## Battle Placeholder Switch

When a scenario/gameplay event is supposed to launch battle, the final integration will call a separate battle app.

Until that app is integrated, map the battle as a test switch:

```json
{
  "type": "battle_placeholder",
  "battleAppIntegrated": false,
  "testSwitch": {
    "enabled": true,
    "prompt": "Segnare questa battle come vinta o persa?",
    "outcomes": ["won", "lost"]
  }
}
```

Rules:

- The switch must be fast to disable once the real battle app call exists.
- Both `won` and `lost` branches must be mapped if the game system depends on them.
- The placeholder must be visibly marked in data as temporary; never hide it as final battle logic.

## Missing Asset And Placeholder Rules

When the scenario/gameplay requires something not present in RTP assets, create an explicit placeholder mapping:

- player base and upgrade stages;
- collectible resources;
- interactable props;
- quest objects;
- doors, gates, unlock devices;
- battle/event markers.

Placeholder record must include:

- `placeholderId`
- `missingAssetType`
- `temporaryRepresentation`
- `recommendedFinalAsset`
- `placement`
- `upgradeOrStateVariants` when relevant
- `validationRisk`

Do not block scenario mapping just because a final sprite is missing. Represent it honestly and flag the asset gap.

## Event Mapping Rules

Every scenario/gameplay event must receive:

- `eventId`
- `eventType`
- `location`
- `timeBand`
- `participants`
- `trigger`
- `conditions`
- `effects`
- `dialogueRefs`
- `battleRef` if any
- `placeholderRefs` if any
- `successState`
- `failureState`
- `noParadoxChecks`

Events must be placed where the player can understand them spatially. If the best exact location is not specified, infer it and document why.

## Coherence And No-Paradox Validation

Before declaring a scenario/gameplay mapping ready, validate:

- all referenced character/animal IDs exist in `rtp.characters.json`;
- no animal has dialogue;
- no NPC portrait is used unless explicitly promoted;
- no entity is scheduled in impossible overlapping locations;
- event prerequisites and effects do not create loops or dead states;
- battle placeholders have both `won` and `lost` test outcomes when downstream logic needs them;
- missing assets are explicit placeholders, not silent omissions;
- inferred placements and time bands are marked as inferred;
- important events are reachable, visible, and not hidden behind walls/roofs or blocked routes;
- behavior loops do not block required paths;
- sprite density remains reasonable for raycaster performance;
- left-facing behavior uses mirror logic and does not create duplicate left assets;
- runtime integration changes still require the normal PERLA1 validation ladder.

## Acceptance Checklist

For each scenario/gameplay import, the final mapping report must state:

- source scenario/gameplay files read;
- entities discovered;
- placements explicit vs inferred;
- time bands explicit vs inferred;
- behavior loops assigned;
- dialogue lines mapped, characters only;
- battle placeholders created;
- missing assets/placeholders created;
- no-paradox validation result;
- runtime files changed, if any;
- validation performed and remaining risk.
