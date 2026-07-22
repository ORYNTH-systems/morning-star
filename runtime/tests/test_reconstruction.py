"""Tests for deterministic runtime reconstruction."""

from uuid import uuid4

import pytest

from morning_star.models.canonical import (
    AuthorityRecord,
    CanonicalObject,
    ConstitutionalTrace,
    ProvenanceRecord,
)
from morning_star.models.enums import ConstitutionalState
from morning_star.models.reconstruction import (
    ReconstructionError,
    reconstruct_runtime_object,
)
from morning_star.models.serialization import canonical_dict


def test_reconstruct_provenance_exactly() -> None:
    original = ProvenanceRecord(
        source_ids=("constitution/CONSTITUTION.md",),
        transformation_ids=("TRANSFORM-1",),
        authority_ids=("AUTHORITY-1",),
    )

    reconstructed = reconstruct_runtime_object(
        "PROVENANCE_RECORD",
        canonical_dict(original),
    )

    assert reconstructed == original


def test_reconstruct_authority_exactly() -> None:
    original = AuthorityRecord(
        holder_id="ORYNTH",
        authority_type="CONSTITUTIONAL",
        scope="Morning Star",
        source="Constitution",
    )

    reconstructed = reconstruct_runtime_object(
        "AUTHORITY_RECORD",
        canonical_dict(original),
    )

    assert reconstructed == original


def test_reconstruct_canonical_object_exactly() -> None:
    original = CanonicalObject(
        object_type="FRAMEWORK",
        canonical_name="Morning Star",
        definition="Semantic entry governance.",
        scope="ORYNTH ecosystem",
        authority_id=uuid4(),
        provenance_id=uuid4(),
        metadata={"phase": 3},
    )

    reconstructed = reconstruct_runtime_object(
        "CANONICAL_OBJECT",
        canonical_dict(original),
    )

    assert reconstructed == original


def test_reconstruct_trace_exactly() -> None:
    original = ConstitutionalTrace(
        actor_id=uuid4(),
        object_id=uuid4(),
        prior_state=ConstitutionalState.UNENCOUNTERED,
        resulting_state=ConstitutionalState.ENCOUNTERED,
        transition_id="MS-TR-001",
        evidence_ids=(uuid4(),),
    )

    reconstructed = reconstruct_runtime_object(
        "CONSTITUTIONAL_TRACE",
        canonical_dict(original),
    )

    assert reconstructed == original


def test_unknown_object_type_is_rejected() -> None:
    with pytest.raises(ReconstructionError):
        reconstruct_runtime_object(
            "UNKNOWN_OBJECT",
            {},
        )


def test_invalid_uuid_is_rejected() -> None:
    original = ProvenanceRecord(
        source_ids=("source",),
    )

    payload = canonical_dict(original)
    payload["provenance_id"] = "invalid"

    with pytest.raises(ReconstructionError):
        reconstruct_runtime_object(
            "PROVENANCE_RECORD",
            payload,
        )
