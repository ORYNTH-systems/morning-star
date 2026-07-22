"""Deterministic runtime snapshot generation."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any
from uuid import UUID, uuid4

from morning_star.models.canonical import utc_now
from morning_star.models.serialization import (
    canonical_dict,
    canonical_sha256,
)
from morning_star.storage.atomic import atomic_write_canonical_json


@dataclass(frozen=True, slots=True)
class RuntimeSnapshot:
    snapshot_id: UUID = field(default_factory=uuid4)
    runtime_version: str = ""
    architecture_version: str = ""
    architecture_hash: str = ""
    registry_counts: dict[str, int] = field(default_factory=dict)
    registry_hashes: dict[str, str] = field(default_factory=dict)
    trace_count: int = 0
    trace_head_hash: str | None = None
    created_at: datetime = field(default_factory=utc_now)
    snapshot_hash: str = ""

    def __post_init__(self) -> None:
        if not self.runtime_version.strip():
            raise ValueError("runtime_version is required.")

        if not self.architecture_version.strip():
            raise ValueError("architecture_version is required.")

        if len(self.architecture_hash) != 64:
            raise ValueError(
                "architecture_hash must be a SHA-256 digest."
            )

        hash_material = {
            "snapshot_id": self.snapshot_id,
            "runtime_version": self.runtime_version,
            "architecture_version": self.architecture_version,
            "architecture_hash": self.architecture_hash,
            "registry_counts": self.registry_counts,
            "registry_hashes": self.registry_hashes,
            "trace_count": self.trace_count,
            "trace_head_hash": self.trace_head_hash,
            "created_at": self.created_at,
        }

        computed = canonical_sha256(hash_material)

        if not self.snapshot_hash:
            object.__setattr__(
                self,
                "snapshot_hash",
                computed,
            )
        elif self.snapshot_hash.upper() != computed:
            raise ValueError("snapshot_hash is invalid.")

    def write(
        self,
        path: Path,
    ) -> None:
        atomic_write_canonical_json(
            path,
            canonical_dict(self),
        )

    def verify(self) -> bool:
        comparison = RuntimeSnapshot(
            snapshot_id=self.snapshot_id,
            runtime_version=self.runtime_version,
            architecture_version=self.architecture_version,
            architecture_hash=self.architecture_hash,
            registry_counts=self.registry_counts,
            registry_hashes=self.registry_hashes,
            trace_count=self.trace_count,
            trace_head_hash=self.trace_head_hash,
            created_at=self.created_at,
        )

        return comparison.snapshot_hash == self.snapshot_hash
