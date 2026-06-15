#!/usr/bin/env python3
"""Build-time importer for PERLA1 RTP character assets.

Reads the source RTP zip, writes optimized WebP assets under the dormant
runtime RTP folder, and updates the RTP manifest with concrete file metadata.
It never extracts arbitrary source paths directly to disk.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
import re
import shutil
import zipfile
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image


STANDARD_ANIMATIONS = [
    "iso_idle_up_right",
    "iso_idle_down_right",
    "iso_idle_right_right",
    "iso_walk_up_right",
    "iso_walk_down_right",
    "iso_walk_right_right",
]

TARGET_STANDARD_FRAME_COUNT = 8
RUNTIME_ATLAS_COLUMNS = 4
RUNTIME_ATLAS_ROWS = 2
RUNTIME_FRAME_SIZE = 256

RUNTIME_ANIMATION_IDS = {
    "iso_idle_up_right": "iso_idle_up",
    "iso_idle_down_right": "iso_idle_down",
    "iso_idle_right_right": "iso_idle_right",
    "iso_walk_up_right": "iso_walk_up",
    "iso_walk_down_right": "iso_walk_down",
    "iso_walk_right_right": "iso_walk_right",
}

RUNTIME_FACINGS = {
    "iso_idle_up": "up",
    "iso_idle_down": "down",
    "iso_idle_right": "right",
    "iso_walk_up": "up",
    "iso_walk_down": "down",
    "iso_walk_right": "right",
}


def slug_name(name: str) -> str:
    stem = Path(name).stem
    stem = re.sub(r"-(spritesheet|portrait)$", "", stem, flags=re.I)
    stem = stem.replace("_", " ").replace("-", " ")
    stem = re.sub(r"\s+", " ", stem).strip().lower()
    return re.sub(r"[^a-z0-9]+", "_", stem).strip("_")


def safe_member(path: str) -> str:
    normalized = path.replace("\\", "/")
    if normalized.startswith("/") or ".." in normalized.split("/"):
        raise ValueError(f"unsafe zip member path: {path}")
    return normalized


def safe_join(base: Path, *parts: str) -> Path:
    target = (base.joinpath(*parts)).resolve()
    base_resolved = base.resolve()
    if target != base_resolved and base_resolved not in target.parents:
        raise ValueError(f"unsafe output path: {target}")
    return target


def image_signature(data: bytes) -> str:
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "png"
    if data.startswith(b"\xff\xd8"):
        return "jpeg"
    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return "webp"
    return "unknown"


def source_hash(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def rel_to(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()


def save_webp(
    data: bytes,
    out_path: Path,
    *,
    max_side: int | None,
    quality: int,
    method: int,
    rtp_root: Path,
    force: bool,
) -> dict:
    if out_path.exists() and not force:
        try:
            with Image.open(out_path) as existing:
                width, height = existing.size
            return {
                "path": rel_to(rtp_root, out_path),
                "bytes": out_path.stat().st_size,
                "width": width,
                "height": height,
                "format": "webp",
                "reused": True,
            }
        except Exception:
            out_path.unlink()

    signature = image_signature(data[:16])
    if signature not in {"png", "jpeg", "webp"}:
        raise ValueError(f"unsupported image signature for {out_path.name}: {signature}")

    with Image.open(io.BytesIO(data)) as opened:
        im = opened.convert("RGBA")
        if max_side:
            im.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
        width, height = im.size
        out_path.parent.mkdir(parents=True, exist_ok=True)
        im.save(out_path, format="WEBP", quality=quality, method=method)

    return {
        "path": rel_to(rtp_root, out_path),
        "bytes": out_path.stat().st_size,
        "width": width,
        "height": height,
        "format": "webp",
        "reused": False,
    }


def image_diff_score(left: Image.Image, right: Image.Image) -> float:
    left_small = left.resize((64, 64), Image.Resampling.BILINEAR)
    right_small = right.resize((64, 64), Image.Resampling.BILINEAR)
    left_px = left_small.tobytes()
    right_px = right_small.tobytes()
    total = 0
    for i in range(0, len(left_px), 4):
        alpha_weight = max(left_px[i + 3], right_px[i + 3]) / 255.0
        total += (
            abs(left_px[i] - right_px[i])
            + abs(left_px[i + 1] - right_px[i + 1])
            + abs(left_px[i + 2] - right_px[i + 2])
            + abs(left_px[i + 3] - right_px[i + 3])
        ) * alpha_weight
    return total


def choose_representative_frames(frames: list[Image.Image], target_count: int) -> list[int]:
    if len(frames) <= target_count:
        return list(range(len(frames)))

    diffs = [image_diff_score(frames[i], frames[(i + 1) % len(frames)]) for i in range(len(frames))]
    total = sum(diffs)
    if total <= 0:
        return [round(i * (len(frames) - 1) / (target_count - 1)) for i in range(target_count)]

    selected = [0]
    for step in range(1, target_count):
        target = total * step / target_count
        accum = 0.0
        chosen = 0
        for index, diff in enumerate(diffs):
            next_accum = accum + diff
            if next_accum >= target:
                before_gap = abs(target - accum)
                after_gap = abs(next_accum - target)
                chosen = index if before_gap <= after_gap else (index + 1) % len(frames)
                break
            accum = next_accum
        if chosen == 0 and step != 0:
            chosen = min(len(frames) - 1, round(step * len(frames) / target_count))
        selected.append(chosen)

    # Keep ordering, uniqueness, and exact target count. If visual arc-length collapsed
    # two choices into one index, fill the largest temporal gaps.
    selected = sorted(set(selected))
    while len(selected) < target_count:
        cyclic = selected + [selected[0] + len(frames)]
        gap_start = max(range(len(selected)), key=lambda i: cyclic[i + 1] - cyclic[i])
        candidate = (cyclic[gap_start] + (cyclic[gap_start + 1] - cyclic[gap_start]) // 2) % len(frames)
        if candidate in selected:
            for offset in range(len(frames)):
                probe = (candidate + offset) % len(frames)
                if probe not in selected:
                    candidate = probe
                    break
        selected.append(candidate)
        selected = sorted(set(selected))

    return selected[:target_count]


def build_runtime_atlas(frames: list[Image.Image], frame_indices: list[int]) -> Image.Image:
    atlas = Image.new(
        "RGBA",
        (RUNTIME_ATLAS_COLUMNS * RUNTIME_FRAME_SIZE, RUNTIME_ATLAS_ROWS * RUNTIME_FRAME_SIZE),
        (0, 0, 0, 0),
    )
    for out_index, source_index in enumerate(frame_indices):
        frame = frames[source_index].convert("RGBA")
        if frame.size != (RUNTIME_FRAME_SIZE, RUNTIME_FRAME_SIZE):
            frame = frame.resize((RUNTIME_FRAME_SIZE, RUNTIME_FRAME_SIZE), Image.Resampling.LANCZOS)
        x = (out_index % RUNTIME_ATLAS_COLUMNS) * RUNTIME_FRAME_SIZE
        y = (out_index // RUNTIME_ATLAS_COLUMNS) * RUNTIME_FRAME_SIZE
        atlas.alpha_composite(frame, (x, y))
    return atlas


def save_image_webp(
    im: Image.Image,
    out_path: Path,
    *,
    quality: int,
    method: int,
    rtp_root: Path,
) -> dict:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    im.save(out_path, format="WEBP", quality=quality, method=method)
    return {
        "path": rel_to(rtp_root, out_path),
        "bytes": out_path.stat().st_size,
        "width": im.size[0],
        "height": im.size[1],
        "format": "webp",
        "reused": False,
    }


def clean_outputs(rtp_root: Path) -> None:
    targets = [
        rtp_root / "characters" / "portraits" / "main",
        rtp_root / "characters" / "sprites" / "main",
        rtp_root / "characters" / "sprites" / "npc",
        rtp_root / "characters" / "sprites" / "animals",
    ]
    for target in targets:
        target.mkdir(parents=True, exist_ok=True)
        for child in target.iterdir():
            if child.is_dir():
                shutil.rmtree(child)
            elif child.suffix.lower() == ".webp":
                child.unlink()


def root_category(filename: str) -> str:
    parts = safe_member(filename).split("/")
    return "/".join(parts[1:-1])


def import_assets(source_zip: Path, rtp_root: Path, force: bool, clean: bool) -> dict:
    source_zip = source_zip.resolve()
    rtp_root = rtp_root.resolve()
    manifest_path = rtp_root / "manifest" / "rtp.characters.json"
    with manifest_path.open("r", encoding="utf-8") as f:
        manifest = json.load(f)

    if clean:
        clean_outputs(rtp_root)

    for character in manifest["characters"]:
        character.pop("portraitAsset", None)
        character.pop("spriteAssets", None)
        character.pop("importWarnings", None)

    by_id = {character["id"]: character for character in manifest["characters"]}
    warnings: list[str] = []
    portraits = 0
    sprite_animations = 0

    with zipfile.ZipFile(source_zip) as zf:
        for info in zf.infolist():
            if info.is_dir():
                continue
            member = safe_member(info.filename)
            if root_category(member) != "characters portrait/main characters":
                continue
            if Path(member).suffix.lower() != ".png":
                continue
            identity = slug_name(Path(member).name)
            character = by_id.get(identity)
            if not character:
                warnings.append(f"portrait identity not in manifest: {identity}")
                continue
            out_path = safe_join(rtp_root, "characters", "portraits", "main", f"{identity}.webp")
            asset = save_webp(
                zf.read(info),
                out_path,
                max_side=512,
                quality=84,
                method=3,
                rtp_root=rtp_root,
                force=force,
            )
            asset.update(
                {
                    "purpose": "dialogue_portrait",
                    "dialogueStyle": "rpg_maker",
                    "loadPolicy": "dialogue_lazy_or_event_prefetch",
                }
            )
            character["portraitAsset"] = asset
            portraits += 1

        for outer in zf.infolist():
            if outer.is_dir() or not outer.filename.lower().endswith(".zip"):
                continue
            outer_member = safe_member(outer.filename)
            identity = slug_name(Path(outer_member).name)
            character = by_id.get(identity)
            if not character:
                warnings.append(f"spritesheet identity not in manifest: {identity}")
                continue

            role = character["role"]
            sprite_group = "animals" if role in {"animal", "animal_ambient"} else role
            if sprite_group not in {"main", "npc", "animals"}:
                warnings.append(f"unknown sprite role for {identity}: {role}")
                continue

            character["spriteAssets"] = {}
            out_dir = safe_join(rtp_root, "characters", "sprites", sprite_group, identity)
            out_dir.mkdir(parents=True, exist_ok=True)

            with zipfile.ZipFile(io.BytesIO(zf.read(outer))) as nested:
                nested_infos = {
                    safe_member(i.filename): i
                    for i in nested.infolist()
                    if not i.is_dir()
                }
                standard_found = 0
                for animation in STANDARD_ANIMATIONS:
                    atlas_name = f"{animation}/spritesheet.png"
                    atlas_json_name = f"{animation}/atlas.json"
                    frame_prefix = f"{animation}/frames/"
                    frame_infos = sorted(
                        [
                            info
                            for member, info in nested_infos.items()
                            if member.startswith(frame_prefix) and member.lower().endswith(".png")
                        ],
                        key=lambda info: safe_member(info.filename),
                    )
                    if not frame_infos and atlas_name not in nested_infos:
                        continue
                    if atlas_json_name not in nested_infos:
                        warnings.append(f"missing atlas json: {outer_member} :: {atlas_json_name}")
                    runtime_animation = RUNTIME_ANIMATION_IDS[animation]
                    out_path = safe_join(out_dir, f"{runtime_animation}.webp")
                    if frame_infos:
                        frames = [
                            Image.open(io.BytesIO(nested.read(frame_info))).convert("RGBA")
                            for frame_info in frame_infos
                        ]
                        frame_indices = choose_representative_frames(frames, TARGET_STANDARD_FRAME_COUNT)
                        runtime_atlas = build_runtime_atlas(frames, frame_indices)
                        asset = save_image_webp(
                            runtime_atlas,
                            out_path,
                            quality=82,
                            method=2,
                            rtp_root=rtp_root,
                        )
                    else:
                        frame_indices = list(range(25))
                        asset = save_webp(
                            nested.read(nested_infos[atlas_name]),
                            out_path,
                            max_side=None,
                            quality=82,
                            method=2,
                            rtp_root=rtp_root,
                            force=force,
                        )
                    asset.update(
                        {
                            "sourceAnimation": animation,
                            "state": "idle" if "_idle_" in runtime_animation else "walk",
                            "sourceFacing": RUNTIME_FACINGS[runtime_animation],
                            "frameCount": TARGET_STANDARD_FRAME_COUNT if frame_infos else 25,
                            "sourceFrameCount": len(frame_infos) if frame_infos else 25,
                            "frameIndices": frame_indices,
                            "sourceFrameSize": [256, 256],
                            "sourceAtlasSize": [1280, 1280],
                            "runtimeAtlasSize": [asset["width"], asset["height"]],
                            "runtimeGrid": {
                                "columns": RUNTIME_ATLAS_COLUMNS if frame_infos else 5,
                                "rows": RUNTIME_ATLAS_ROWS if frame_infos else 5,
                            },
                            "frameSelectionPolicy": "visual_arc_length_even_distribution"
                            if frame_infos
                            else "source_atlas_passthrough",
                            "mirrorsToLeft": RUNTIME_FACINGS[runtime_animation] == "right",
                            "runtimeRepresentation": "optimized_8_frame_atlas_webp"
                            if frame_infos
                            else "optimized_atlas_webp",
                        }
                    )
                    character["spriteAssets"][runtime_animation] = asset
                    standard_found += 1
                    sprite_animations += 1

                if standard_found:
                    continue

                png_infos = [
                    i
                    for i in nested.infolist()
                    if not i.is_dir() and safe_member(i.filename).lower().endswith(".png")
                ]
                if not png_infos:
                    warnings.append(f"no usable png in special spritesheet: {outer_member}")
                    continue
                for index, png_info in enumerate(sorted(png_infos, key=lambda i: safe_member(i.filename).lower()), start=1):
                    stem = slug_name(Path(safe_member(png_info.filename)).stem)
                    animation = f"{stem}_{index:04d}" if len(png_infos) > 1 else stem
                    out_path = safe_join(out_dir, f"{animation}.webp")
                    asset = save_webp(
                        nested.read(png_info),
                        out_path,
                        max_side=None,
                        quality=82,
                        method=2,
                        rtp_root=rtp_root,
                        force=force,
                    )
                    source_facing = "right" if "right" in animation else ("down" if "down" in animation else "unknown")
                    asset.update(
                        {
                            "state": "ambient",
                            "sourceFacing": source_facing,
                            "frameCount": 1,
                            "sourceFrameSize": [asset["width"], asset["height"]],
                            "sourceAtlasSize": [asset["width"], asset["height"]],
                            "mirrorsToLeft": source_facing == "right",
                            "runtimeRepresentation": "optimized_direct_webp",
                            "sourceLayout": "special_direct_png",
                        }
                    )
                    character["spriteAssets"][animation] = asset
                    sprite_animations += 1

    for character in manifest["characters"]:
        if character["id"] == "mara_selce":
            character["displayName"] = "Mara Selce"
        if character["role"] == "main" and character.get("portrait") == "include" and "portraitAsset" not in character:
            warnings.append(f"missing generated main portrait: {character['id']}")
        if character.get("spritesheet") == "include" and not character.get("spriteAssets"):
            warnings.append(f"missing generated sprite assets: {character['id']}")

    generated_webp = list((rtp_root / "characters").rglob("*.webp"))
    manifest["status"] = "optimized_asset_manifest"
    manifest["runtimeLoaded"] = False
    manifest["spriteContract"]["frameCount"] = TARGET_STANDARD_FRAME_COUNT
    manifest["spriteContract"]["sourceFrameCount"] = 25
    manifest["spriteContract"]["runtimeAtlasSize"] = [
        RUNTIME_ATLAS_COLUMNS * RUNTIME_FRAME_SIZE,
        RUNTIME_ATLAS_ROWS * RUNTIME_FRAME_SIZE,
    ]
    manifest["spriteContract"]["runtimeGrid"] = {
        "columns": RUNTIME_ATLAS_COLUMNS,
        "rows": RUNTIME_ATLAS_ROWS,
    }
    manifest["spriteContract"]["frameSelectionPolicy"] = "visual_arc_length_even_distribution"
    manifest["spriteContract"]["specialAmbientPolicy"] = (
        "keep_real_source_frame_count; do_not_duplicate_static_or_short_ambient_sources_to_8"
    )
    manifest["generatedAt"] = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    manifest["importer"] = {
        "name": "perla_rtp_asset_importer",
        "version": 1,
        "sourceSha256": source_hash(source_zip),
        "sourceZipName": source_zip.name,
        "imageFormat": "webp",
        "portraitMaxSidePx": 512,
        "portraitQuality": 84,
        "spriteAtlasQuality": 82,
        "standardAnimationFrameCount": TARGET_STANDARD_FRAME_COUNT,
        "standardAnimationFrameSelectionPolicy": "visual_arc_length_even_distribution",
        "standardRuntimeAtlasSize": [RUNTIME_ATLAS_COLUMNS * RUNTIME_FRAME_SIZE, RUNTIME_ATLAS_ROWS * RUNTIME_FRAME_SIZE],
        "standardRuntimeGrid": {"columns": RUNTIME_ATLAS_COLUMNS, "rows": RUNTIME_ATLAS_ROWS},
        "leftFacingPolicy": "derive_idle_left_and_walk_left_by_mirroring_right_assets",
        "doNotGenerateMirroredAssets": True,
    }
    manifest["assetCounts"] = {
        "generatedPortraits": portraits,
        "generatedSpriteAnimations": sprite_animations,
        "generatedWebpFiles": len(generated_webp),
        "generatedWebpBytes": sum(path.stat().st_size for path in generated_webp),
        "warnings": len(warnings),
    }
    manifest["importWarnings"] = warnings

    with manifest_path.open("w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=True)
        f.write("\n")

    return manifest["assetCounts"] | {"warningMessages": warnings}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-zip", required=True, type=Path)
    parser.add_argument("--rtp-root", required=True, type=Path)
    parser.add_argument("--force", action="store_true", help="Regenerate existing WebP files.")
    parser.add_argument("--clean", action="store_true", help="Delete generated WebP outputs before importing.")
    args = parser.parse_args()
    result = import_assets(args.source_zip, args.rtp_root, args.force, args.clean)
    print(json.dumps(result, indent=2))
    return 0 if result["warnings"] == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
