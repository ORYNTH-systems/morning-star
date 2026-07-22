"""Tests for runtime transaction boundaries."""

from pathlib import Path

import pytest

from morning_star.models.canonical import (
    ProvenanceRecord,
    UncertaintyRecord,
)
from morning_star.models.envelopes import RuntimeEnvelope
from morning_star.registries.repository import RuntimeRepository
from morning_star.registries.transaction import (
    RuntimeTransaction,
    TransactionError,
)


def test_transaction_commits_multiple_records(
    tmp_path: Path,
) -> None:
    repository = RuntimeRepository(tmp_path / "repository")
    transaction = RuntimeTransaction(repository)

    provenance = RuntimeEnvelope.from_object(
        ProvenanceRecord(source_ids=("source",)),
        object_type="PROVENANCE_RECORD",
    )

    uncertainty = RuntimeEnvelope.from_object(
        UncertaintyRecord(),
        object_type="UNCERTAINTY_RECORD",
    )

    transaction.stage(provenance)
    transaction.stage(uncertainty)

    paths = transaction.commit()

    assert len(paths) == 2
    assert transaction.committed is True
    assert repository.verify_all() is True


def test_transaction_rejects_duplicate_stage(
    tmp_path: Path,
) -> None:
    repository = RuntimeRepository(tmp_path / "repository")
    transaction = RuntimeTransaction(repository)

    envelope = RuntimeEnvelope.from_object(
        ProvenanceRecord(source_ids=("source",)),
        object_type="PROVENANCE_RECORD",
    )

    transaction.stage(envelope)

    with pytest.raises(TransactionError):
        transaction.stage(envelope)


def test_transaction_rejects_empty_commit(
    tmp_path: Path,
) -> None:
    repository = RuntimeRepository(tmp_path / "repository")
    transaction = RuntimeTransaction(repository)

    with pytest.raises(TransactionError):
        transaction.commit()


def test_transaction_cannot_commit_twice(
    tmp_path: Path,
) -> None:
    repository = RuntimeRepository(tmp_path / "repository")
    transaction = RuntimeTransaction(repository)

    transaction.stage(
        RuntimeEnvelope.from_object(
            ProvenanceRecord(source_ids=("source",)),
            object_type="PROVENANCE_RECORD",
        )
    )

    transaction.commit()

    with pytest.raises(TransactionError):
        transaction.commit()
