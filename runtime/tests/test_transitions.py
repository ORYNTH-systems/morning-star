"""Tests for deterministic constitutional state transitions."""

from uuid import uuid4

import pytest

from morning_star.engines.transitions import (
    StateTransitionEngine,
    TransitionRejectedError,
    TransitionRequest,
)
from morning_star.models.enums import ConstitutionalState
from morning_star.models.transitions import (
    CANONICAL_TRANSITIONS,
    TRANSITION_RULES_BY_ID,
)


def test_all_canonical_transition_ids_are_unique() -> None:
    ids = [
        rule.transition_id
        for rule in CANONICAL_TRANSITIONS
    ]

    assert len(ids) == len(set(ids))
    assert len(ids) == 17


def test_transition_registry_contains_all_rules() -> None:
    assert len(TRANSITION_RULES_BY_ID) == len(CANONICAL_TRANSITIONS)


def test_first_encounter_transition_succeeds() -> None:
    engine = StateTransitionEngine()

    request = TransitionRequest(
        transition_id="MS-TR-001",
        current_state=ConstitutionalState.UNENCOUNTERED,
        actor_id=uuid4(),
        object_id=uuid4(),
        evidence_ids=(uuid4(),),
    )

    decision = engine.evaluate(request)

    assert decision.accepted is True
    assert decision.resulting_state == ConstitutionalState.ENCOUNTERED
    assert decision.trace is not None


def test_prior_state_mismatch_rejects_transition() -> None:
    engine = StateTransitionEngine()

    request = TransitionRequest(
        transition_id="MS-TR-001",
        current_state=ConstitutionalState.IDENTIFIED,
        evidence_ids=(uuid4(),),
    )

    decision = engine.evaluate(request)

    assert decision.accepted is False
    assert "PRIOR_STATE_MISMATCH" in decision.reason_codes


def test_authority_required_transition_rejects_without_authority() -> None:
    engine = StateTransitionEngine()

    request = TransitionRequest(
        transition_id="MS-TR-006",
        current_state=ConstitutionalState.INTERPRETED,
        evidence_ids=(uuid4(),),
    )

    decision = engine.evaluate(request)

    assert decision.accepted is False
    assert "AUTHORITY_REQUIRED" in decision.reason_codes


def test_evidence_required_transition_rejects_without_evidence() -> None:
    engine = StateTransitionEngine()

    request = TransitionRequest(
        transition_id="MS-TR-001",
        current_state=ConstitutionalState.UNENCOUNTERED,
        evidence_ids=(),
    )

    decision = engine.evaluate(request)

    assert decision.accepted is False
    assert "EVIDENCE_REQUIRED" in decision.reason_codes


def test_execute_returns_trace() -> None:
    engine = StateTransitionEngine()

    request = TransitionRequest(
        transition_id="MS-TR-007",
        current_state=ConstitutionalState.COMPETENCY_EVALUATED,
        actor_id=uuid4(),
        object_id=uuid4(),
        authority_id=uuid4(),
        evidence_ids=(uuid4(),),
    )

    trace = engine.execute(request)

    assert trace.transition_id == "MS-TR-007"
    assert trace.resulting_state == ConstitutionalState.PARTICIPATION_ADMITTED


def test_execute_raises_when_rejected() -> None:
    engine = StateTransitionEngine()

    request = TransitionRequest(
        transition_id="MS-TR-007",
        current_state=ConstitutionalState.COMPETENCY_EVALUATED,
        evidence_ids=(),
    )

    with pytest.raises(TransitionRejectedError):
        engine.execute(request)


def test_unknown_transition_is_rejected() -> None:
    engine = StateTransitionEngine()

    request = TransitionRequest(
        transition_id="MS-TR-999",
        current_state=ConstitutionalState.UNENCOUNTERED,
    )

    with pytest.raises(TransitionRejectedError):
        engine.evaluate(request)


def test_uncertainty_review_requires_authority() -> None:
    engine = StateTransitionEngine()

    request = TransitionRequest(
        transition_id="MS-TR-005",
        current_state=ConstitutionalState.DEPENDENCY_RESOLVED,
        evidence_ids=(uuid4(),),
        uncertainty_ids=(uuid4(),),
    )

    decision = engine.evaluate(request)

    assert decision.accepted is False
    assert (
        "UNCERTAINTY_REVIEW_AUTHORITY_REQUIRED"
        in decision.reason_codes
    )
