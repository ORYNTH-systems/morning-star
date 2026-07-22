"""Unified persistent repository for Morning Star runtime records."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any
from uuid import UUID

from morning_star.models.envelopes import RuntimeEnvelope
from morning_star.models.serialization import canonical_sha256
from morning_star.registries.persistent import PersistentRegistry


OBJECT_TYPE_DIRECTORIES: dict[str, str] = {
    "ACTOR_IDENTITY": "actors",
    "AUTHORITY_RECORD": "authorities",
    "CANONICAL_OBJECT": "canonical-objects",
    "DEPENDENCY_RECORD": "dependencies",
    "EVIDENCE_RECORD": "evidence",
    "INTERPRETATION_RECORD": "interpretations",
    "PARTICIPATION_RECORD": "participation",
    "PROVENANCE_RECORD": "provenance",
    "UNCERTAINTY_RECORD": "uncertainty",
}


class RuntimeRepositoryError(ValueError):
    """Raised when unified repository operations are invalid."""


@dataclass(frozen=True, slots=True)
class RuntimeRepository:
    """Object-type-specific persistent repository."""

    root: Path

    def __post_init__(self) -> None:
        self.root.mkdir(parents=True, exist_ok=True)

        for directory in OBJECT_TYPE_DIRECTORIES.values():
            (self.root / directory).mkdir(
                parents=True,
                exist_ok=True,
            )

    def registry(
        self,
        object_type: str,
    ) -> PersistentRegistry:
        try:
            directory = OBJECT_TYPE_DIRECTORIES[object_type]
        except KeyError as exc:
            raise RuntimeRepositoryError(
                f"Unsupported repository object type: {object_type}"
            ) from exc

        return PersistentRegistry(self.root / directory)

    def save(
        self,
        envelope: RuntimeEnvelope,
    ) -> Path:
        return self.registry(envelope.object_type).save(envelope)

    def load(
        self,
        object_type: str,
        envelope_id: UUID,
    ) -> RuntimeEnvelope:
        return self.registry(object_type).load(envelope_id)

    def reconstruct(
        self,
        object_type: str,
        envelope_id: UUID,
    ) -> Any:
        return self.registry(object_type).reconstruct(envelope_id)

    def list_ids(
        self,
        object_type: str,
    ) -> tuple[UUID, ...]:
        return self.registry(object_type).list_ids()

    def counts(self) -> dict[str, int]:
        return {
            object_type: len(self.registry(object_type))
            for object_type in sorted(OBJECT_TYPE_DIRECTORIES)
        }

    def hashes(self) -> dict[str, str]:
        hashes: dict[str, str] = {}

        for object_type in sorted(OBJECT_TYPE_DIRECTORIES):
            registry = self.registry(object_type)

            material = [
                registry.load(identifier)
                for identifier in registry.list_ids()
            ]

            hashes[object_type] = canonical_sha256(material)

        return hashes

    def verify_all(self) -> bool:
        for object_type in OBJECT_TYPE_DIRECTORIES:
            self.registry(object_type).verify_all()

        return True
