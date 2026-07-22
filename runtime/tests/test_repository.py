"""Tests for the unified runtime repository."""

from pathlib import Path

import pytest

from morning_star.models.canonical import ProvenanceRecord
from morning_star.models.envelopes import RuntimeEnvelope
from morning_star.registries.repository import (
    RuntimeRepository,
    RuntimeRepositoryError,
)


def test_repository_saves_by_object_type(tmp_path: Path) -> None:
    repository = RuntimeRepository(tmp_path / "repository")

    record = ProvenanceRecord(
        source_ids=("source",),
    )

    envelope = RuntimeEnvelope.from_object(
        record,
        object_type="PROVENANCE_RECORD",
    )

    path = repository.save(envelope)

    assert path.parent.name == "provenance"
    assert repository.verify_all() is True


def test_repository_reconstructs_record(tmp_path: Path) -> None:
    repository = RuntimeRepository(tmp_path / "repository")

    original = ProvenanceRecord(
        source_ids=("source",),
    )

    envelope = RuntimeEnvelope.from_object(
        original,
        object_type="PROVENANCE_RECORD",
    )

    repository.save(envelope)

    reconstructed = repository.reconstruct(
        "PROVENANCE_RECORD",
        envelope.envelope_id,
    )

    assert reconstructed == original


def test_repository_counts_records(tmp_path: Path) -> None:
    repository = RuntimeRepository(tmp_path / "repository")

    envelope = RuntimeEnvelope.from_object(
        ProvenanceRecord(source_ids=("source",)),
        object_type="PROVENANCE_RECORD",
    )

    repository.save(envelope)
    counts = repository.counts()

    assert counts["PROVENANCE_RECORD"] == 1
    assert counts["CANONICAL_OBJECT"] == 0


def test_repository_generates_registry_hashes(
    tmp_path: Path,
) -> None:
    repository = RuntimeRepository(tmp_path / "repository")

    hashes = repository.hashes()

    assert set(hashes) == set(repository.counts())
    assert all(len(value) == 64 for value in hashes.values())


def test_repository_rejects_unknown_object_type(
    tmp_path: Path,
) -> None:
    repository = RuntimeRepository(tmp_path / "repository")

    with pytest.raises(RuntimeRepositoryError):
        repository.registry("UNKNOWN_OBJECT")
