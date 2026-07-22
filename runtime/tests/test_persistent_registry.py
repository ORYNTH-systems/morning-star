"""Tests for persistent runtime registries."""

import json
from pathlib import Path

import pytest

from morning_star.models.canonical import ProvenanceRecord
from morning_star.models.envelopes import RuntimeEnvelope
from morning_star.registries.persistent import (
    PersistentRegistry,
    RegistryCorruptionError,
)


def build_envelope() -> RuntimeEnvelope:
    provenance = ProvenanceRecord(
        source_ids=("constitution/CONSTITUTION.md",),
    )

    return RuntimeEnvelope.from_object(
        provenance,
        object_type="PROVENANCE_RECORD",
    )


def test_registry_saves_and_loads_envelope(tmp_path: Path) -> None:
    registry = PersistentRegistry(tmp_path / "registry")
    envelope = build_envelope()

    registry.save(envelope)
    loaded = registry.load(envelope.envelope_id)

    assert loaded == envelope
    assert registry.verify_all() is True


def test_registry_reconstructs_object(tmp_path: Path) -> None:
    registry = PersistentRegistry(tmp_path / "registry")
    envelope = build_envelope()

    registry.save(envelope)
    reconstructed = registry.reconstruct(envelope.envelope_id)

    assert reconstructed.source_ids == (
        "constitution/CONSTITUTION.md",
    )


def test_registry_rejects_id_collision(tmp_path: Path) -> None:
    registry = PersistentRegistry(tmp_path / "registry")
    envelope = build_envelope()

    registry.save(envelope)

    conflicting = RuntimeEnvelope(
        envelope_id=envelope.envelope_id,
        object_type="PROVENANCE_RECORD",
        payload={
            "provenance_id": str(envelope.envelope_id),
            "source_ids": ["different"],
            "transformation_ids": [],
            "authority_ids": [],
            "created_at": envelope.created_at.isoformat(),
        },
    )

    with pytest.raises(RegistryCorruptionError):
        registry.save(conflicting)


def test_registry_detects_tampered_payload(tmp_path: Path) -> None:
    registry = PersistentRegistry(tmp_path / "registry")
    envelope = build_envelope()
    path = registry.save(envelope)

    raw = json.loads(path.read_text(encoding="utf-8"))
    raw["payload"]["source_ids"] = ["tampered"]

    path.write_text(
        json.dumps(raw),
        encoding="utf-8",
    )

    with pytest.raises(RegistryCorruptionError):
        registry.load(envelope.envelope_id)


def test_registry_lists_identifiers(tmp_path: Path) -> None:
    registry = PersistentRegistry(tmp_path / "registry")
    first = build_envelope()
    second = build_envelope()

    registry.save(first)
    registry.save(second)

    assert set(registry.list_ids()) == {
        first.envelope_id,
        second.envelope_id,
    }

    assert len(registry) == 2
