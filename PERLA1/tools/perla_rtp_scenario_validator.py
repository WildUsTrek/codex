#!/usr/bin/env python3
"""Static validator for PERLA1 dormant RTP scenario manifests.

This tool intentionally avoids third-party dependencies. It validates the
mechanically checkable contract for future RTP placement, behavior, dialogue,
and event manifests before they are connected to runtime code.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


TIME_BANDS = {
    "dawn",
    "morning",
    "day",
    "afternoon",
    "sunset",
    "night",
    "storm_or_special_weather",
    "event_only",
}

ROLE_TO_ENTITY_TYPE = {
    "main": "main_character",
    "npc": "npc",
    "animal": "animal",
    "animal_ambient": "animal_ambient",
}

FUTURE_MANIFESTS = {
    "placements": "rtp.placements.json",
    "behaviors": "rtp.behaviors.json",
    "dialogues": "rtp.dialogues.json",
    "events": "rtp.events.json",
}

SCHEMAS = {
    "placements": "rtp.placements.schema.json",
    "behaviors": "rtp.behaviors.schema.json",
    "dialogues": "rtp.dialogues.schema.json",
    "events": "rtp.events.schema.json",
}


def read_json(path: Path, errors: list[str]) -> Any | None:
    try:
        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError:
        errors.append(f"missing_json:{path}")
    except json.JSONDecodeError as exc:
        errors.append(f"invalid_json:{path}:{exc.lineno}:{exc.colno}:{exc.msg}")
    return None


def as_list(value: Any) -> list[Any]:
    return value if isinstance(value, list) else []


def require_fields(record: dict[str, Any], fields: list[str], where: str, errors: list[str]) -> None:
    for field in fields:
        if field not in record:
            errors.append(f"missing_field:{where}.{field}")


def require_condition_array(records: list[Any], where: str, errors: list[str]) -> None:
    for index, record in enumerate(records):
        if not isinstance(record, dict):
            errors.append(f"invalid_condition:{where}[{index}]:must_be_object")
            continue
        for field in ("state", "op", "value"):
            if field not in record:
                errors.append(f"invalid_condition:{where}[{index}]:missing_{field}")


def check_duplicate(ids: list[str], label: str, errors: list[str]) -> None:
    seen: set[str] = set()
    for item_id in ids:
        if item_id in seen:
            errors.append(f"duplicate_id:{label}:{item_id}")
        seen.add(item_id)


def load_characters(manifest: dict[str, Any], errors: list[str]) -> dict[str, dict[str, Any]]:
    characters = as_list(manifest.get("characters"))
    if not characters:
        errors.append("rtp_characters_manifest_has_no_characters")
        return {}
    result: dict[str, dict[str, Any]] = {}
    for index, character in enumerate(characters):
        if not isinstance(character, dict):
            errors.append(f"invalid_character_record:{index}")
            continue
        char_id = character.get("id")
        if not isinstance(char_id, str) or not char_id:
            errors.append(f"invalid_character_id:{index}")
            continue
        if char_id in result:
            errors.append(f"duplicate_character_id:{char_id}")
        result[char_id] = character
    return result


def validate_schemas(schema_dir: Path, warnings: list[str], errors: list[str]) -> None:
    for label, filename in SCHEMAS.items():
        path = schema_dir / filename
        schema = read_json(path, errors)
        if schema is None:
            continue
        if schema.get("$id") != f"perla1.rtp.{label}.schema.v1":
            warnings.append(f"schema_id_unexpected:{path}")


def validate_no_left_duplicates(rtp_root: Path, errors: list[str]) -> None:
    left_assets = sorted(rtp_root.glob("characters/sprites/**/iso_*_left.webp"))
    if left_assets:
        for path in left_assets:
            errors.append(f"left_facing_duplicate_asset:{path.relative_to(rtp_root)}")


def validate_placements(data: dict[str, Any], characters: dict[str, dict[str, Any]], errors: list[str], warnings: list[str]) -> set[str]:
    placements = as_list(data.get("placements"))
    ids: list[str] = []
    active_by_entity_band: dict[tuple[str, str], tuple[str, str]] = {}
    for index, placement in enumerate(placements):
        where = f"placements[{index}]"
        if not isinstance(placement, dict):
            errors.append(f"invalid_record:{where}")
            continue
        require_fields(
            placement,
            [
                "id",
                "entityType",
                "zone",
                "position",
                "placementSource",
                "placementRationale",
                "timeBands",
                "timeBandSource",
                "availabilityConditions",
                "eventLinks",
            ],
            where,
            errors,
        )
        placement_id = placement.get("id")
        if isinstance(placement_id, str):
            ids.append(placement_id)

        entity_id = placement.get("entityId")
        placeholder_id = placement.get("placeholderId")
        if not entity_id and not placeholder_id:
            errors.append(f"missing_entity_or_placeholder:{where}")
        if entity_id:
            character = characters.get(entity_id)
            if character is None:
                errors.append(f"unknown_entity:{where}:{entity_id}")
            else:
                expected_type = ROLE_TO_ENTITY_TYPE.get(character.get("role"))
                if expected_type and placement.get("entityType") != expected_type:
                    errors.append(f"entity_type_mismatch:{where}:{entity_id}:expected_{expected_type}")

        position = placement.get("position")
        if not isinstance(position, dict) or "status" not in position:
            errors.append(f"invalid_position:{where}")
        elif position.get("status") in {"exact", "inferred"}:
            if not isinstance(position.get("x"), (int, float)) or not isinstance(position.get("y"), (int, float)):
                errors.append(f"position_requires_numeric_xy:{where}")
            if position.get("walkabilityStatus", "runtime_pending") == "runtime_pending":
                warnings.append(f"runtime_walkability_pending:{where}")
            if position.get("visibilityStatus", "runtime_pending") == "runtime_pending":
                warnings.append(f"runtime_visibility_pending:{where}")

        if placement.get("placementSource") == "inferred" and not placement.get("placementRationale"):
            errors.append(f"inferred_placement_needs_rationale:{where}")
        if placement.get("timeBandSource") == "inferred" and not placement.get("placementRationale"):
            errors.append(f"inferred_time_band_needs_rationale:{where}")

        bands = as_list(placement.get("timeBands"))
        if not bands:
            errors.append(f"missing_time_bands:{where}")
        for band in bands:
            if band not in TIME_BANDS:
                errors.append(f"invalid_time_band:{where}:{band}")
            if entity_id and band != "event_only":
                key = (entity_id, band)
                current = (str(placement.get("zone", "")), str(position.get("x") if isinstance(position, dict) else ""))
                previous = active_by_entity_band.get(key)
                if previous is not None and previous != current and not placement.get("mutuallyExclusiveWith"):
                    errors.append(f"schedule_conflict:{entity_id}:{band}:{previous}->{current}")
                active_by_entity_band[key] = current

    check_duplicate(ids, "placement", errors)
    return set(ids)


def validate_behaviors(data: dict[str, Any], characters: dict[str, dict[str, Any]], placement_ids: set[str], errors: list[str]) -> set[str]:
    behaviors = as_list(data.get("behaviors"))
    ids: list[str] = []
    for index, behavior in enumerate(behaviors):
        where = f"behaviors[{index}]"
        if not isinstance(behavior, dict):
            errors.append(f"invalid_record:{where}")
            continue
        require_fields(
            behavior,
            [
                "id",
                "placementId",
                "entityId",
                "mode",
                "anchor",
                "radius",
                "idleSeconds",
                "walkSeconds",
                "turnBehavior",
                "collisionPolicy",
                "schedulePolicy",
                "leftFacingPolicy",
            ],
            where,
            errors,
        )
        if isinstance(behavior.get("id"), str):
            ids.append(behavior["id"])
        if behavior.get("entityId") not in characters:
            errors.append(f"unknown_entity:{where}:{behavior.get('entityId')}")
        if behavior.get("placementId") not in placement_ids:
            errors.append(f"unknown_placement:{where}:{behavior.get('placementId')}")
        if behavior.get("leftFacingPolicy") != "derive_by_mirroring_right_assets":
            errors.append(f"invalid_left_facing_policy:{where}")
        if isinstance(behavior.get("radius"), (int, float)) and behavior["radius"] < 0:
            errors.append(f"invalid_radius:{where}")
    check_duplicate(ids, "behavior", errors)
    return set(ids)


def validate_dialogues(data: dict[str, Any], characters: dict[str, dict[str, Any]], event_ids: set[str], event_participants: dict[str, set[str]], errors: list[str]) -> set[str]:
    dialogues = as_list(data.get("dialogues"))
    ids: list[str] = []
    for index, dialogue in enumerate(dialogues):
        where = f"dialogues[{index}]"
        if not isinstance(dialogue, dict):
            errors.append(f"invalid_record:{where}")
            continue
        require_fields(
            dialogue,
            ["id", "speakerId", "eventId", "lineType", "portraitPolicy", "conditions", "effects"],
            where,
            errors,
        )
        if not dialogue.get("textRef") and not dialogue.get("line"):
            errors.append(f"dialogue_needs_text_ref_or_line:{where}")
        dialogue_id = dialogue.get("id")
        if isinstance(dialogue_id, str):
            ids.append(dialogue_id)
        speaker_id = dialogue.get("speakerId")
        character = characters.get(speaker_id)
        if character is None:
            errors.append(f"unknown_speaker:{where}:{speaker_id}")
        else:
            role = character.get("role")
            if role in {"animal", "animal_ambient"}:
                errors.append(f"animal_has_dialogue:{where}:{speaker_id}")
            policy = dialogue.get("portraitPolicy")
            if policy == "main_character_portrait" and role != "main":
                errors.append(f"portrait_policy_main_only:{where}:{speaker_id}")
            if policy == "npc_portrait_exception" and not dialogue.get("portraitExceptionApproved"):
                errors.append(f"npc_portrait_exception_not_approved:{where}:{speaker_id}")

        event_id = dialogue.get("eventId")
        if event_id not in event_ids:
            errors.append(f"unknown_event:{where}:{event_id}")
        if event_id in event_participants and speaker_id not in event_participants[event_id] and not dialogue.get("speakerParticipantExceptionApproved"):
            errors.append(f"speaker_not_event_participant:{where}:{speaker_id}:{event_id}")
        require_condition_array(as_list(dialogue.get("conditions")), f"{where}.conditions", errors)
        require_condition_array(as_list(dialogue.get("effects")), f"{where}.effects", errors)
    check_duplicate(ids, "dialogue", errors)
    return set(ids)


def validate_events(data: dict[str, Any], characters: dict[str, dict[str, Any]], dialogue_ids: set[str], errors: list[str]) -> tuple[set[str], dict[str, set[str]]]:
    events = as_list(data.get("events"))
    ids: list[str] = []
    participants_by_event: dict[str, set[str]] = {}
    for index, event in enumerate(events):
        where = f"events[{index}]"
        if not isinstance(event, dict):
            errors.append(f"invalid_record:{where}")
            continue
        require_fields(
            event,
            [
                "eventId",
                "eventType",
                "location",
                "timeBand",
                "participants",
                "trigger",
                "conditions",
                "effects",
                "dialogueRefs",
                "successState",
                "failureState",
                "noParadoxChecks",
            ],
            where,
            errors,
        )
        event_id = event.get("eventId")
        if isinstance(event_id, str):
            ids.append(event_id)
        if event.get("timeBand") not in TIME_BANDS:
            errors.append(f"invalid_time_band:{where}:{event.get('timeBand')}")
        participants = set()
        for participant in as_list(event.get("participants")):
            if participant not in characters and not str(participant).startswith("placeholder."):
                errors.append(f"unknown_participant:{where}:{participant}")
            participants.add(str(participant))
        if isinstance(event_id, str):
            participants_by_event[event_id] = participants
        if dialogue_ids:
            for dialogue_ref in as_list(event.get("dialogueRefs")):
                if dialogue_ref not in dialogue_ids:
                    errors.append(f"unknown_dialogue_ref:{where}:{dialogue_ref}")
        require_condition_array(as_list(event.get("conditions")), f"{where}.conditions", errors)
        require_condition_array(as_list(event.get("effects")), f"{where}.effects", errors)
        check_branch_conflicts(as_list(event.get("effects")), f"{where}.effects", errors)

        if event.get("eventType") == "battle_placeholder":
            placeholder = event.get("battlePlaceholder")
            if not isinstance(placeholder, dict):
                errors.append(f"missing_battle_placeholder:{where}")
            else:
                if placeholder.get("battleAppIntegrated") is not False:
                    errors.append(f"battle_placeholder_must_be_not_integrated:{where}")
                switch = placeholder.get("testSwitch")
                outcomes = set(as_list(switch.get("outcomes"))) if isinstance(switch, dict) else set()
                if not isinstance(switch, dict) or switch.get("enabled") is not True or outcomes != {"won", "lost"}:
                    errors.append(f"battle_placeholder_switch_requires_won_lost:{where}")
            if not as_list(event.get("effectsOnWon")) or not as_list(event.get("effectsOnLost")):
                errors.append(f"battle_placeholder_needs_won_lost_effects:{where}")
            require_condition_array(as_list(event.get("effectsOnWon")), f"{where}.effectsOnWon", errors)
            require_condition_array(as_list(event.get("effectsOnLost")), f"{where}.effectsOnLost", errors)
            check_branch_conflicts(as_list(event.get("effectsOnWon")), f"{where}.effectsOnWon", errors)
            check_branch_conflicts(as_list(event.get("effectsOnLost")), f"{where}.effectsOnLost", errors)
    check_duplicate(ids, "event", errors)
    return set(ids), participants_by_event


def validate_event_dialogue_refs(data: dict[str, Any], dialogue_ids: set[str], errors: list[str]) -> None:
    for index, event in enumerate(as_list(data.get("events"))):
        if not isinstance(event, dict):
            continue
        where = f"events[{index}]"
        for dialogue_ref in as_list(event.get("dialogueRefs")):
            if dialogue_ref not in dialogue_ids:
                errors.append(f"unknown_dialogue_ref:{where}:{dialogue_ref}")


def check_branch_conflicts(effects: list[Any], where: str, errors: list[str]) -> None:
    assigned: dict[str, Any] = {}
    for index, effect in enumerate(effects):
        if not isinstance(effect, dict) or effect.get("op") != "set":
            continue
        state = effect.get("state")
        if not isinstance(state, str):
            continue
        value = effect.get("value")
        if state in assigned and assigned[state] != value:
            errors.append(f"contradictory_effect:{where}[{index}]:{state}")
        assigned[state] = value


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Validate dormant PERLA1 RTP scenario manifests.")
    parser.add_argument("--rtp-root", default="PERLA1/01_GIOCO_PRONTO_LOCAL_TEST/assets/rtp", help="RTP asset root.")
    parser.add_argument("--runtime-snapshot", default=None, help="Reserved future JSON snapshot for coordinate/walkability validation.")
    parser.add_argument("--json", action="store_true", help="Emit JSON summary.")
    args = parser.parse_args(argv)

    rtp_root = Path(args.rtp_root)
    manifest_dir = rtp_root / "manifest"
    schema_dir = rtp_root / "schema"
    errors: list[str] = []
    warnings: list[str] = []

    validate_schemas(schema_dir, warnings, errors)
    characters_manifest = read_json(manifest_dir / "rtp.characters.json", errors)
    characters = load_characters(characters_manifest or {}, errors)
    validate_no_left_duplicates(rtp_root, errors)

    if characters_manifest:
        sprite_contract = characters_manifest.get("spriteContract", {})
        if isinstance(sprite_contract, dict):
            left_policy = str(sprite_contract.get("leftFacingPolicy", ""))
            if "mirroring_right_assets" not in left_policy:
                errors.append("characters_manifest_left_facing_policy_not_mirror")
            if sprite_contract.get("doNotGenerateMirroredAssets") is not True:
                errors.append("characters_manifest_allows_mirrored_duplicates")

    loaded: dict[str, Any] = {}
    for label, filename in FUTURE_MANIFESTS.items():
        path = manifest_dir / filename
        if not path.exists():
            warnings.append(f"dormant_manifest_missing_optional:{filename}")
            continue
        data = read_json(path, errors)
        if isinstance(data, dict):
            loaded[label] = data
            if data.get("schemaVersion") != 1:
                errors.append(f"invalid_schema_version:{filename}")

    placement_ids: set[str] = set()
    behavior_ids: set[str] = set()
    event_ids: set[str] = set()
    dialogue_ids: set[str] = set()
    event_participants: dict[str, set[str]] = {}

    if "placements" in loaded:
        placement_ids = validate_placements(loaded["placements"], characters, errors, warnings)
    if "events" in loaded:
        event_ids, event_participants = validate_events(loaded["events"], characters, set(), errors)
    if "behaviors" in loaded:
        behavior_ids = validate_behaviors(loaded["behaviors"], characters, placement_ids, errors)
    if "dialogues" in loaded:
        dialogue_ids = validate_dialogues(loaded["dialogues"], characters, event_ids, event_participants, errors)
    if "events" in loaded:
        validate_event_dialogue_refs(loaded["events"], dialogue_ids, errors)

    if args.runtime_snapshot:
        warnings.append("runtime_snapshot_validation_reserved_for_future_map_export")

    result = {
        "schema": "perla.rtp.scenario.validator.v1",
        "status": "pass" if not errors else "fail",
        "rtpRoot": str(rtp_root),
        "counts": {
            "characters": len(characters),
            "placements": len(as_list(loaded.get("placements", {}).get("placements") if isinstance(loaded.get("placements"), dict) else [])),
            "behaviors": len(as_list(loaded.get("behaviors", {}).get("behaviors") if isinstance(loaded.get("behaviors"), dict) else [])),
            "dialogues": len(as_list(loaded.get("dialogues", {}).get("dialogues") if isinstance(loaded.get("dialogues"), dict) else [])),
            "events": len(as_list(loaded.get("events", {}).get("events") if isinstance(loaded.get("events"), dict) else [])),
            "behaviorIds": len(behavior_ids),
        },
        "loadedManifests": sorted(loaded.keys()),
        "errors": errors,
        "warnings": warnings,
    }

    if args.json:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print(f"PERLA1 RTP scenario validator: {result['status']}")
        for item in errors:
            print(f"ERROR {item}")
        for item in warnings:
            print(f"WARN {item}")
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
