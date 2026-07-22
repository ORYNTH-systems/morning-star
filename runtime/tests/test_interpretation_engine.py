"""Tests for interpretation admission."""

from uuid import uuid4

from morning_star.engines.interpretation import (
    InterpretationAdmissionEngine,
    InterpretationDecisionType,
)
from morning_star.models.canonical import (
    CanonicalObject,
    InterpretationRecord,
    UncertaintyRecord,
)
from morning_star.models.enums import InterpretationClass


def build_source() -> CanonicalObject:
    return CanonicalObject(
        object_type="FRAMEWORK",
        canonical_name="Morning Star",
        definition="Entry governance.",
        scope="ORYNTH ecosystem",
        authority_id=uuid4(),
        provenance_id=uuid4(),
    )


def test_canonical_interpretation_is_admitted() -> None:
    source = build_source()

    interpretation = InterpretationRecord(
        interpreted_object_id=source.object_id,
        interpretation_class=InterpretationClass.CANONICAL,
        source_basis=("constitution/CONSTITUTION.md",),
        scope="Morning Star",
    )

    decision = InterpretationAdmissionEngine().decide(
        interpretation,
        source_object=source,
        uncertainties={},
    )

    assert decision.decision == InterpretationDecisionType.ADMIT


def test_analogical_interpretation_is_limited() -> None:
    source = build_source()

    interpretation = InterpretationRecord(
        interpreted_object_id=source.object_id,
        interpretation_class=InterpretationClass.ANALOGICAL,
        source_basis=("source",),
        scope="Comparison",
    )

    decision = InterpretationAdmissionEngine().decide(
        interpretation,
        source_object=source,
        uncertainties={},
    )

    assert (
        decision.decision
        == InterpretationDecisionType.ADMIT_WITH_LIMITS
    )


def test_conflicting_interpretation_is_rejected() -> None:
    source = build_source()

    interpretation = InterpretationRecord(
        interpreted_object_id=source.object_id,
        interpretation_class=InterpretationClass.CONFLICTING,
        source_basis=("source",),
        scope="Conflict",
    )

    decision = InterpretationAdmissionEngine().decide(
        interpretation,
        source_object=source,
        uncertainties={},
    )

    assert decision.decision == InterpretationDecisionType.REJECT


def test_blocking_uncertainty_requires_reconstruction() -> None:
    source = build_source()
    uncertainty = UncertaintyRecord(
        description="Identity conflict.",
        blocks_admission=True,
    )

    interpretation = InterpretationRecord(
        interpreted_object_id=source.object_id,
        interpretation_class=InterpretationClass.CANONICAL,
        source_basis=("source",),
        scope="Morning Star",
        uncertainty_ids=(uncertainty.uncertainty_id,),
    )

    decision = InterpretationAdmissionEngine().decide(
        interpretation,
        source_object=source,
        uncertainties={
            uncertainty.uncertainty_id: uncertainty,
        },
    )

    assert (
        decision.decision
        == InterpretationDecisionType.REQUIRE_RECONSTRUCTION
    )
