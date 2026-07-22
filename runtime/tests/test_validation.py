"""Tests for the Morning Star constitutional validation engine."""

from uuid import uuid4

from morning_star.engines.validation import (
    FindingDisposition,
    ValidationEngine,
)
from morning_star.models.canonical import (
    AuthorityRecord,
    CanonicalObject,
    DependencyRecord,
    EvidenceRecord,
    InterpretationRecord,
    ParticipationRecord,
    ProvenanceRecord,
    UncertaintyRecord,
)
from morning_star.models.enums import (
    AdmissionStatus,
    InitiationDecision,
    InterpretationClass,
    ParticipationRole,
    UncertaintyType,
)


def build_authority() -> AuthorityRecord:
    return AuthorityRecord(
        holder_id="ORYNTH",
        authority_type="CONSTITUTIONAL",
        scope="Morning Star",
        source="Morning Star Constitution",
    )


def build_provenance() -> ProvenanceRecord:
    return ProvenanceRecord(
        source_ids=("constitution/CONSTITUTION.md",),
    )


def test_valid_canonical_object_passes() -> None:
    engine = ValidationEngine()
    authority = build_authority()
    provenance = build_provenance()

    subject = CanonicalObject(
        object_type="FRAMEWORK",
        canonical_name="Morning Star",
        definition="Constitutional semantic-entry architecture.",
        scope="ORYNTH ecosystem",
        authority_id=authority.authority_id,
        provenance_id=provenance.provenance_id,
    )

    result = engine.validate_canonical_object(
        subject,
        authorities={authority.authority_id: authority},
        provenances={provenance.provenance_id: provenance},
        uncertainties={},
        dependencies={},
    )

    assert result.valid is True
    assert result.findings == ()


def test_missing_object_authority_blocks() -> None:
    engine = ValidationEngine()
    provenance = build_provenance()

    subject = CanonicalObject(
        object_type="FRAMEWORK",
        canonical_name="Morning Star",
        definition="Constitutional semantic-entry architecture.",
        scope="ORYNTH ecosystem",
        provenance_id=provenance.provenance_id,
    )

    result = engine.validate_canonical_object(
        subject,
        authorities={},
        provenances={provenance.provenance_id: provenance},
        uncertainties={},
        dependencies={},
    )

    assert result.valid is False
    assert any(
        finding.disposition == FindingDisposition.BLOCK
        for finding in result.findings
    )


def test_unsatisfied_dependency_blocks() -> None:
    engine = ValidationEngine()
    authority = build_authority()
    provenance = build_provenance()

    dependency = DependencyRecord(
        source_object_id="OBJECT-A",
        target_object_id="OBJECT-B",
        relationship_type="DEPENDS_ON",
        mandatory=True,
        satisfied=False,
    )

    subject = CanonicalObject(
        object_type="FRAMEWORK",
        canonical_name="Morning Star",
        definition="Constitutional semantic-entry architecture.",
        scope="ORYNTH ecosystem",
        authority_id=authority.authority_id,
        provenance_id=provenance.provenance_id,
        dependency_ids=(dependency.dependency_id,),
    )

    result = engine.validate_canonical_object(
        subject,
        authorities={authority.authority_id: authority},
        provenances={provenance.provenance_id: provenance},
        uncertainties={},
        dependencies={dependency.dependency_id: dependency},
    )

    assert result.valid is False
    assert any(
        finding.invariant_id == "MS-INV-003"
        for finding in result.findings
    )


def test_canonical_interpretation_requires_authority() -> None:
    engine = ValidationEngine()
    provenance = build_provenance()

    source = CanonicalObject(
        object_type="FRAMEWORK",
        canonical_name="Morning Star",
        definition="Constitutional semantic-entry architecture.",
        scope="ORYNTH ecosystem",
        authority_id=uuid4(),
        provenance_id=provenance.provenance_id,
    )

    interpretation = InterpretationRecord(
        interpreted_object_id=source.object_id,
        interpretation_class=InterpretationClass.CANONICAL,
        source_basis=("constitution/CONSTITUTION.md",),
        scope="Morning Star",
        provenance_id=provenance.provenance_id,
        admission_status=AdmissionStatus.ADMISSIBLE,
    )

    result = engine.validate_interpretation(
        interpretation,
        source_object=source,
        authorities={},
        provenances={provenance.provenance_id: provenance},
        uncertainties={},
    )

    assert result.valid is False
    assert any(
        finding.invariant_id == "MS-INV-007"
        for finding in result.findings
    )


def test_blocking_uncertainty_prevents_interpretation_admission() -> None:
    engine = ValidationEngine()
    authority = build_authority()
    provenance = build_provenance()

    uncertainty = UncertaintyRecord(
        uncertainty_type=UncertaintyType.EVIDENTIARY,
        description="Source evidence is incomplete.",
        blocks_admission=True,
    )

    source = CanonicalObject(
        object_type="FRAMEWORK",
        canonical_name="Morning Star",
        definition="Constitutional semantic-entry architecture.",
        scope="ORYNTH ecosystem",
        authority_id=authority.authority_id,
        provenance_id=provenance.provenance_id,
    )

    interpretation = InterpretationRecord(
        interpreted_object_id=source.object_id,
        interpretation_class=InterpretationClass.CANONICAL,
        source_basis=("constitution/CONSTITUTION.md",),
        scope="Morning Star",
        authority_id=authority.authority_id,
        provenance_id=provenance.provenance_id,
        uncertainty_ids=(uncertainty.uncertainty_id,),
        admission_status=AdmissionStatus.ADMISSIBLE,
    )

    result = engine.validate_interpretation(
        interpretation,
        source_object=source,
        authorities={authority.authority_id: authority},
        provenances={provenance.provenance_id: provenance},
        uncertainties={uncertainty.uncertainty_id: uncertainty},
    )

    assert result.valid is False
    assert any(
        finding.invariant_id == "MS-INV-006"
        for finding in result.findings
    )


def test_valid_participation_admission_passes() -> None:
    engine = ValidationEngine()
    authority = build_authority()

    evidence = EvidenceRecord(
        evidence_type="ORIENTATION_ASSESSMENT",
        source="Morning Star",
        method="STRUCTURED_ASSESSMENT",
        scope="PR1",
        integrity_verified=True,
    )

    participation = ParticipationRecord(
        actor_id=uuid4(),
        prior_role=ParticipationRole.PR0,
        requested_role=ParticipationRole.PR1,
        admitted_role=ParticipationRole.PR1,
        decision=InitiationDecision.ADMIT,
        scope="Morning Star orientation",
        authority_id=authority.authority_id,
        evidence_ids=(evidence.evidence_id,),
    )

    result = engine.validate_participation(
        participation,
        authorities={authority.authority_id: authority},
        evidence={evidence.evidence_id: evidence},
        uncertainties={},
    )

    assert result.valid is True


def test_admission_without_evidence_fails() -> None:
    engine = ValidationEngine()
    authority = build_authority()

    participation = ParticipationRecord(
        actor_id=uuid4(),
        prior_role=ParticipationRole.PR0,
        requested_role=ParticipationRole.PR1,
        admitted_role=ParticipationRole.PR1,
        decision=InitiationDecision.ADMIT,
        scope="Morning Star orientation",
        authority_id=authority.authority_id,
        evidence_ids=(),
    )

    result = engine.validate_participation(
        participation,
        authorities={authority.authority_id: authority},
        evidence={},
        uncertainties={},
    )

    assert result.valid is False
    assert any(
        finding.invariant_id == "MS-INV-008"
        for finding in result.findings
    )


def test_admitted_role_cannot_exceed_requested_role() -> None:
    engine = ValidationEngine()
    authority = build_authority()

    evidence = EvidenceRecord(
        evidence_type="ASSESSMENT",
        source="Morning Star",
        method="STRUCTURED_ASSESSMENT",
        scope="PR1",
        integrity_verified=True,
    )

    participation = ParticipationRecord(
        actor_id=uuid4(),
        prior_role=ParticipationRole.PR0,
        requested_role=ParticipationRole.PR1,
        admitted_role=ParticipationRole.PR4,
        decision=InitiationDecision.ADMIT,
        scope="Morning Star orientation",
        authority_id=authority.authority_id,
        evidence_ids=(evidence.evidence_id,),
    )

    result = engine.validate_participation(
        participation,
        authorities={authority.authority_id: authority},
        evidence={evidence.evidence_id: evidence},
        uncertainties={},
    )

    assert result.valid is False
    assert any(
        finding.invariant_id == "MS-INV-009"
        for finding in result.findings
    )
