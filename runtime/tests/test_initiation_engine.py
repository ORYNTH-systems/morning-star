"""Tests for participation initiation decisions."""

from uuid import uuid4

from morning_star.engines.initiation import (
    InitiationDecisionEngine,
    InitiationDisposition,
)
from morning_star.models.canonical import (
    AuthorityRecord,
    EvidenceRecord,
    ParticipationRecord,
    UncertaintyRecord,
)
from morning_star.models.enums import ParticipationRole


def build_authority() -> AuthorityRecord:
    return AuthorityRecord(
        holder_id="ORYNTH",
        authority_type="INITIATION",
        scope="Morning Star",
        source="Constitution",
    )


def build_evidence() -> EvidenceRecord:
    return EvidenceRecord(
        evidence_type="COMPETENCY_ASSESSMENT",
        source="Morning Star",
        method="STRUCTURED",
        scope="PR1",
        integrity_verified=True,
    )


def test_valid_initiation_is_admitted() -> None:
    authority = build_authority()
    evidence = build_evidence()

    participation = ParticipationRecord(
        actor_id=uuid4(),
        prior_role=ParticipationRole.PR0,
        requested_role=ParticipationRole.PR1,
        admitted_role=ParticipationRole.PR1,
        scope="Orientation",
        authority_id=authority.authority_id,
        evidence_ids=(evidence.evidence_id,),
    )

    result = InitiationDecisionEngine().decide(
        participation,
        authorities={authority.authority_id: authority},
        evidence={evidence.evidence_id: evidence},
        uncertainties={},
    )

    assert result.disposition == InitiationDisposition.ADMITTED


def test_missing_authority_denies_initiation() -> None:
    evidence = build_evidence()

    participation = ParticipationRecord(
        actor_id=uuid4(),
        prior_role=ParticipationRole.PR0,
        requested_role=ParticipationRole.PR1,
        admitted_role=ParticipationRole.PR1,
        scope="Orientation",
        authority_id=uuid4(),
        evidence_ids=(evidence.evidence_id,),
    )

    result = InitiationDecisionEngine().decide(
        participation,
        authorities={},
        evidence={evidence.evidence_id: evidence},
        uncertainties={},
    )

    assert result.disposition == InitiationDisposition.DENIED


def test_unverified_evidence_requires_remediation() -> None:
    authority = build_authority()

    evidence = EvidenceRecord(
        evidence_type="ASSESSMENT",
        source="Morning Star",
        method="STRUCTURED",
        scope="PR1",
        integrity_verified=False,
    )

    participation = ParticipationRecord(
        actor_id=uuid4(),
        prior_role=ParticipationRole.PR0,
        requested_role=ParticipationRole.PR1,
        admitted_role=ParticipationRole.PR1,
        scope="Orientation",
        authority_id=authority.authority_id,
        evidence_ids=(evidence.evidence_id,),
    )

    result = InitiationDecisionEngine().decide(
        participation,
        authorities={authority.authority_id: authority},
        evidence={evidence.evidence_id: evidence},
        uncertainties={},
    )

    assert (
        result.disposition
        == InitiationDisposition.REMEDIATION_REQUIRED
    )


def test_limited_role_is_admitted_with_limits() -> None:
    authority = build_authority()
    evidence = build_evidence()

    participation = ParticipationRecord(
        actor_id=uuid4(),
        prior_role=ParticipationRole.PR0,
        requested_role=ParticipationRole.PR3,
        admitted_role=ParticipationRole.PR1,
        scope="Limited participation",
        authority_id=authority.authority_id,
        evidence_ids=(evidence.evidence_id,),
    )

    result = InitiationDecisionEngine().decide(
        participation,
        authorities={authority.authority_id: authority},
        evidence={evidence.evidence_id: evidence},
        uncertainties={},
    )

    assert (
        result.disposition
        == InitiationDisposition.ADMITTED_WITH_LIMITS
    )


def test_blocking_uncertainty_requires_remediation() -> None:
    authority = build_authority()
    evidence = build_evidence()

    uncertainty = UncertaintyRecord(
        description="Competency unresolved.",
        blocks_admission=True,
    )

    participation = ParticipationRecord(
        actor_id=uuid4(),
        prior_role=ParticipationRole.PR0,
        requested_role=ParticipationRole.PR1,
        admitted_role=ParticipationRole.PR1,
        scope="Orientation",
        authority_id=authority.authority_id,
        evidence_ids=(evidence.evidence_id,),
        uncertainty_ids=(uncertainty.uncertainty_id,),
    )

    result = InitiationDecisionEngine().decide(
        participation,
        authorities={authority.authority_id: authority},
        evidence={evidence.evidence_id: evidence},
        uncertainties={
            uncertainty.uncertainty_id: uncertainty,
        },
    )

    assert (
        result.disposition
        == InitiationDisposition.REMEDIATION_REQUIRED
    )
