"""Tests for canonical Morning Star domain objects."""

from datetime import timedelta
from uuid import uuid4

import pytest

from morning_star.models.canonical import (
    ActorIdentity,
    AuthorityRecord,
    CanonicalObject,
    DependencyRecord,
    EvidenceRecord,
    InterpretationRecord,
    ParticipationRecord,
    ProvenanceRecord,
    UncertaintyRecord,
    utc_now,
)
from morning_star.models.enums import (
    AdmissionStatus,
    InitiationDecision,
    InterpretationClass,
    ParticipationRole,
    UncertaintyType,
)


def test_provenance_requires_source() -> None:
    with pytest.raises(ValueError):
        ProvenanceRecord(source_ids=())


def test_authority_rejects_invalid_expiration() -> None:
    now = utc_now()

    with pytest.raises(ValueError):
        AuthorityRecord(
            holder_id="ACTOR-1",
            authority_type="CANONICAL",
            scope="Morning Star",
            source="Constitution",
            effective_at=now,
            expires_at=now - timedelta(seconds=1),
        )


def test_dependency_rejects_self_reference() -> None:
    with pytest.raises(ValueError):
        DependencyRecord(
            source_object_id="OBJECT-1",
            target_object_id="OBJECT-1",
            relationship_type="DEPENDS_ON",
        )


def test_actor_identity_requires_name() -> None:
    with pytest.raises(ValueError):
        ActorIdentity(
            display_name="",
            identity_source="TEST",
            assurance_level="VERIFIED",
        )


def test_canonical_object_constructs() -> None:
    authority_id = uuid4()
    provenance_id = uuid4()

    subject = CanonicalObject(
        object_type="FRAMEWORK",
        canonical_name="Morning Star",
        definition="Entry governance architecture.",
        scope="ORYNTH ecosystem",
        authority_id=authority_id,
        provenance_id=provenance_id,
    )

    assert subject.authority_id == authority_id
    assert subject.provenance_id == provenance_id


def test_interpretation_requires_source_basis() -> None:
    with pytest.raises(ValueError):
        InterpretationRecord(
            interpretation_class=InterpretationClass.DERIVED,
            scope="Test",
            source_basis=(),
        )


def test_participation_rejects_invalid_expiration() -> None:
    now = utc_now()

    with pytest.raises(ValueError):
        ParticipationRecord(
            actor_id=uuid4(),
            prior_role=ParticipationRole.PR0,
            requested_role=ParticipationRole.PR1,
            admitted_role=ParticipationRole.PR1,
            decision=InitiationDecision.ADMIT,
            scope="Orientation",
            effective_at=now,
            expires_at=now - timedelta(seconds=1),
        )


def test_evidence_record_constructs() -> None:
    evidence = EvidenceRecord(
        evidence_type="ASSESSMENT",
        source="REFERENCE",
        method="STRUCTURED_REVIEW",
        scope="PR1",
        integrity_verified=True,
    )

    assert evidence.integrity_verified is True


def test_uncertainty_record_constructs() -> None:
    uncertainty = UncertaintyRecord(
        uncertainty_type=UncertaintyType.EVIDENTIARY,
        description="Evidence remains incomplete.",
        blocks_admission=True,
    )

    assert uncertainty.blocks_admission is True


def test_canonical_interpretation_constructs() -> None:
    interpretation = InterpretationRecord(
        interpretation_class=InterpretationClass.CANONICAL,
        source_basis=("constitution/CONSTITUTION.md",),
        scope="Morning Star",
        admission_status=AdmissionStatus.ADMISSIBLE,
    )

    assert interpretation.interpretation_class == InterpretationClass.CANONICAL
