"""Tests for the constitutional trace ledger."""

from uuid import uuid4

from morning_star.engines.transitions import (
    StateTransitionEngine,
    TransitionRequest,
)
from morning_star.models.enums import ConstitutionalState
from morning_star.registries.trace_ledger import TraceLedger


def build_trace():
    engine = StateTransitionEngine()

    request = TransitionRequest(
        transition_id="MS-TR-001",
        current_state=ConstitutionalState.UNENCOUNTERED,
        actor_id=uuid4(),
        object_id=uuid4(),
        evidence_ids=(uuid4(),),
    )

    return engine.execute(request)


def test_empty_trace_ledger_is_valid() -> None:
    ledger = TraceLedger()

    assert ledger.verify() is True
    assert len(ledger) == 0


def test_trace_ledger_appends_trace() -> None:
    ledger = TraceLedger()
    trace = build_trace()

    ledger = ledger.append(trace)

    assert ledger.verify() is True
    assert len(ledger) == 1


def test_trace_ledger_is_immutable() -> None:
    original = TraceLedger()
    trace = build_trace()

    updated = original.append(trace)

    assert len(original) == 0
    assert len(updated) == 1


def test_trace_ledger_builds_hash_chain() -> None:
    ledger = TraceLedger()
    first = build_trace()
    second = build_trace()

    ledger = ledger.append(first)
    first_head = ledger.chain.head_hash

    ledger = ledger.append(second)

    assert ledger.chain.envelopes[1].prior_envelope_hash == first_head
    assert ledger.verify() is True
