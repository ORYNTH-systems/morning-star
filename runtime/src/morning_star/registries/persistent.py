"""Persistent hash-verified Morning Star runtime registry."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from uuid import UUID

from morning_star.models.envelopes import RuntimeEnvelope
from morning_star.models.reconstruction import reconstruct_runtime_object
from morning_star.models.serialization import canonical_dict
from morning_star.storage.atomic import atomic_write_canonical_json


class RegistryCorruptionError(ValueError):
    """Raised when persisted registry data is corrupt or inconsistent."""


@dataclass(frozen=True, slots=True)
class PersistentRegistry:
    """Store immutable runtime envelopes on disk by envelope ID."""

    root: Path

    def __post_init__(self) -> None:
        self.root.mkdir(parents=True, exist_ok=True)

    def _path(self, envelope_id: UUID) -> Path:
        return self.root / f"{envelope_id}.json"

    def save(
        self,
        envelope: RuntimeEnvelope,
    ) -> Path:
        path = self._path(envelope.envelope_id)

        if path.exists():
            existing = self.load(envelope.envelope_id)

            if existing.envelope_hash() != envelope.envelope_hash():
                raise RegistryCorruptionError(
                    f"Envelope ID collision: {envelope.envelope_id}"
                )

            return path

        atomic_write_canonical_json(
            path,
            canonical_dict(envelope),
        )

        loaded = self.load(envelope.envelope_id)

        if loaded.envelope_hash() != envelope.envelope_hash():
            raise RegistryCorruptionError(
                f"Post-write verification failed: {envelope.envelope_id}"
            )

        return path

    def load(
        self,
        envelope_id: UUID,
    ) -> RuntimeEnvelope:
        path = self._path(envelope_id)

        if not path.exists():
            raise KeyError(f"Unknown envelope ID: {envelope_id}")

        try:
            raw = json.loads(path.read_text(encoding="utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise RegistryCorruptionError(
                f"Invalid registry JSON: {path}"
            ) from exc

        try:
            envelope = RuntimeEnvelope(
                envelope_id=UUID(raw["envelope_id"]),
                object_type=raw["object_type"],
                schema_version=raw["schema_version"],
                payload=raw["payload"],
                payload_hash=raw["payload_hash"],
                prior_envelope_hash=raw["prior_envelope_hash"],
                created_at=__import__("datetime").datetime.fromisoformat(
                    raw["created_at"]
                ),
            )
        except (KeyError, TypeError, ValueError) as exc:
            raise RegistryCorruptionError(
                f"Invalid envelope structure: {path}"
            ) from exc

        if not envelope.verify_payload():
            raise RegistryCorruptionError(
                f"Envelope payload verification failed: {path}"
            )

        return envelope

    def reconstruct(
        self,
        envelope_id: UUID,
    ) -> Any:
        envelope = self.load(envelope_id)

        return reconstruct_runtime_object(
            envelope.object_type,
            envelope.payload,
        )

    def list_ids(self) -> tuple[UUID, ...]:
        identifiers: list[UUID] = []

        for path in sorted(self.root.glob("*.json")):
            try:
                identifiers.append(UUID(path.stem))
            except ValueError as exc:
                raise RegistryCorruptionError(
                    f"Invalid registry filename: {path.name}"
                ) from exc

        return tuple(identifiers)

    def verify_all(self) -> bool:
        for envelope_id in self.list_ids():
            self.load(envelope_id)

        return True

    def __len__(self) -> int:
        return len(self.list_ids())
