"""Integrated Morning Star conformance scenario."""

from pathlib import Path
from uuid import uuid4

from morning_star.engines.navigation import NavigationRequest
from morning_star.engines.runtime import RuntimeOrchestrator
from morning_star.engines.transitions import TransitionRequest
from morning_star.models.canonical import (
    AuthorityRecord,
    CanonicalObject,
    EvidenceRecord,
    InterpretationRecord,
    ParticipationRecord,
    ProvenanceRecord,
)
from morning_star.models.enums import (
    ConstitutionalState,
    InterpretationClass,
    ParticipationRole,
)
from morning_star.registries.persistent_trace import (
    PersistentTraceLedger,
)
from morning_star.registries.repository import RuntimeRepository


def test_complete_entry_to_participation_flow(
    tmp_path: Path,
) -> None:
    repository = RuntimeRepository(
        tmp_path / "repository"
    )

    trace_ledger = PersistentTraceLedger(
        tmp_path / "trace-ledger.json"
    )

    runtime = RuntimeOrchestrator(
        repository=repository,
        trace_ledger=trace_ledger,
    )

    provenance = ProvenanceRecord(
        source_ids=("constitution/CONSTITUTION.md",),
    )

    authority = AuthorityRecord(
        holder_id="ORYNTH",
        authority_type="CONSTITUTIONAL_INITIATION",
        scope="Morning Star",
        source="Constitution",
    )

    evidence = EvidenceRecord(
        evidence_type="COMPETENCY_ASSESSMENT",
        source="Morning Star",
        method="STRUCTURED_ASSESSMENT",
        scope="PR1",
        integrity_verified=True,
        provenance_id=provenance.provenance_id,
    )

    canonical_object = CanonicalObject(
        object_type="FRAMEWORK",
        canonical_name="Morning Star",
        definition="Canonical entry architecture.",
        scope="ORYNTH ecosystem",
        authority_id=authority.authority_id,
        provenance_id=provenance.provenance_id,
    )

    interpretation = InterpretationRecord(
        interpreted_object_id=canonical_object.object_id,
        interpretation_class=InterpretationClass.CANONICAL,
        interpreter_id=uuid4(),
        authority_id=authority.authority_id,
        source_basis=("constitution/CONSTITUTION.md",),
        scope="Morning Star",
        provenance_id=provenance.provenance_id,
    )

    participation = ParticipationRecord(
        actor_id=uuid4(),
        prior_role=ParticipationRole.PR0,
        requested_role=ParticipationRole.PR1,
        admitted_role=ParticipationRole.PR1,
        scope="Morning Star orientation",
        authority_id=authority.authority_id,
        evidence_ids=(evidence.evidence_id,),
    )

    runtime.persist_records(
        (
            ("PROVENANCE_RECORD", provenance),
            ("AUTHORITY_RECORD", authority),
            ("EVIDENCE_RECORD", evidence),
            ("CANONICAL_OBJECT", canonical_object),
            ("INTERPRETATION_RECORD", interpretation),
            ("PARTICIPATION_RECORD", participation),
        )
    )

    assert repository.verify_all() is True

    interpretation_decision = runtime.decide_interpretation(
        interpretation,
        source_object=canonical_object,
        uncertainties={},
    )

    assert interpretation_decision.decision.value == "ADMIT"

    initiation_decision = runtime.decide_initiation(
        participation,
        authorities={
            authority.authority_id: authority,
        },
        evidence={
            evidence.evidence_id: evidence,
        },
        uncertainties={},
    )

    assert initiation_decision.disposition.value == "ADMITTED"

    navigation_decision = runtime.decide_navigation(
        NavigationRequest(
            current_state=ConstitutionalState.DEPENDENCY_RESOLVED,
            target_state=ConstitutionalState.INTERPRETED,
            identity_resolved=True,
            context_resolved=True,
            dependencies_resolved=True,
            interpretation_admissible=True,
        )
    )

    assert navigation_decision.decision.value == "PROCEED"

    transitions = (
        (
            "MS-TR-001",
            ConstitutionalState.UNENCOUNTERED,
            False,
        ),
        (
            "MS-TR-002",
            ConstitutionalState.ENCOUNTERED,
            False,
        ),
        (
            "MS-TR-003",
            ConstitutionalState.IDENTIFIED,
            False,
        ),
        (
            "MS-TR-004",
            ConstitutionalState.CONTEXTUALIZED,
            False,
        ),
        (
            "MS-TR-005",
            ConstitutionalState.DEPENDENCY_RESOLVED,
            False,
        ),
        (
            "MS-TR-006",
            ConstitutionalState.INTERPRETED,
            True,
        ),
        (
            "MS-TR-007",
            ConstitutionalState.COMPETENCY_EVALUATED,
            True,
        ),
        (
            "MS-TR-008",
            ConstitutionalState.PARTICIPATION_ADMITTED,
            True,
        ),
    )

    for transition_id, current_state, authority_required in transitions:
        runtime.execute_transition(
            TransitionRequest(
                transition_id=transition_id,
                actor_id=participation.actor_id,
                object_id=canonical_object.object_id,
                current_state=current_state,
                authority_id=(
                    authority.authority_id
                    if authority_required
                    else None
                ),
                evidence_ids=(evidence.evidence_id,),
            )
        )

    assert len(trace_ledger) == 8
    assert trace_ledger.verify() is True
    assert (
        trace_ledger.traces()[-1].resulting_state
        == ConstitutionalState.PARTICIPATION_ACTIVE
    )
