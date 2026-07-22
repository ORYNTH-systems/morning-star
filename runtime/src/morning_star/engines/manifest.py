"""Load and verify the Morning Star architecture manifest."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


class ArchitectureManifestError(ValueError):
    """Raised when architecture manifest validation fails."""


@dataclass(frozen=True, slots=True)
class ArchitectureManifest:
    architecture_id: str
    architecture_name: str
    version: str
    status: str
    constitutional_subject: str
    volumes: tuple[dict[str, Any], ...]
    invariant_registry: str
    state_transition_registry: str
    generated_at: str
    git_commit: str
    artifact_count: int
    aggregate_hash: str

    @classmethod
    def load(
        cls,
        path: Path,
    ) -> "ArchitectureManifest":
        if not path.exists():
            raise FileNotFoundError(path)

        try:
            raw = json.loads(path.read_text(encoding="utf-8-sig"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise ArchitectureManifestError(
                "Architecture manifest is invalid JSON."
            ) from exc

        required = {
            "architecture_id",
            "architecture_name",
            "version",
            "status",
            "constitutional_subject",
            "volumes",
            "invariant_registry",
            "state_transition_registry",
            "generated_at",
            "git_commit",
            "artifact_count",
            "aggregate_hash",
        }

        missing = sorted(required.difference(raw))

        if missing:
            raise ArchitectureManifestError(
                f"Architecture manifest is missing fields: {missing}"
            )

        if raw["architecture_id"] != "MS-ARCH-001":
            raise ArchitectureManifestError(
                "Unexpected architecture ID."
            )

        if raw["architecture_name"] != "Morning Star":
            raise ArchitectureManifestError(
                "Unexpected architecture name."
            )

        if raw["status"] != "ARCHITECTURE_FROZEN":
            raise ArchitectureManifestError(
                "Architecture is not frozen."
            )

        volumes = raw["volumes"]

        if not isinstance(volumes, list) or len(volumes) != 5:
            raise ArchitectureManifestError(
                "Architecture manifest must contain exactly five volumes."
            )

        expected_ids = {
            "MS-V1",
            "MS-V2",
            "MS-V3",
            "MS-V4",
            "MS-V5",
        }

        actual_ids = {
            volume.get("volume_id")
            for volume in volumes
            if isinstance(volume, dict)
        }

        if actual_ids != expected_ids:
            raise ArchitectureManifestError(
                "Architecture volume set is invalid."
            )

        aggregate_hash = raw["aggregate_hash"]

        if (
            not isinstance(aggregate_hash, str)
            or len(aggregate_hash) != 64
            or any(
                character not in "0123456789ABCDEFabcdef"
                for character in aggregate_hash
            )
        ):
            raise ArchitectureManifestError(
                "Architecture aggregate hash is invalid."
            )

        return cls(
            architecture_id=raw["architecture_id"],
            architecture_name=raw["architecture_name"],
            version=raw["version"],
            status=raw["status"],
            constitutional_subject=raw["constitutional_subject"],
            volumes=tuple(volumes),
            invariant_registry=raw["invariant_registry"],
            state_transition_registry=raw["state_transition_registry"],
            generated_at=raw["generated_at"],
            git_commit=raw["git_commit"],
            artifact_count=int(raw["artifact_count"]),
            aggregate_hash=aggregate_hash.upper(),
        )
