"""Tests for persistent constitutional trace ledgers."""

import json
from pathlib import Path
from uuid import uuid4

import pytest

from morning_star.engines.transitions import (
    StateTransitionEngine,
    TransitionRequest,
)
from morning_star.models.enums import ConstitutionalState
from morning_star.registries.persistent_trace import (
    PersistentTraceLedger,
    TraceLedgerCorruptionError,
)


def build_trace():
    engine = StateTransitionEngine()

    return engine.execute(
        TransitionRequest(
            transition_id="MS-TR-001",
            current_state=ConstitutionalState.UNENCOUNTERED,
            actor_id=uuid4(),
            object_id=uuid4(),
            evidence_ids=(uuid4(),),
        )
    )


def test_persistent_ledger_appends_trace(tmp_path: Path) -> None:
    ledger = PersistentTraceLedger(
        tmp_path / "trace-ledger.json"
    )

    trace = build_trace()
    ledger.append(trace)

    assert len(ledger) == 1
    assert ledger.verify() is True
    assert ledger.traces() == (trace,)


def test_persistent_ledger_recovers_chain(tmp_path: Path) -> None:
    path = tmp_path / "trace-ledger.json"
    first_ledger = PersistentTraceLedger(path)

    first_ledger.append(build_trace())
    first_ledger.append(build_trace())

    recovered = PersistentTraceLedger(path)

    assert len(recovered) == 2
    assert recovered.verify() is True
    assert recovered.head_hash is not None


def test_persistent_ledger_detects_chain_tampering(
    tmp_path: Path,
) -> None:
    path = tmp_path / "trace-ledger.json"
    ledger = PersistentTraceLedger(path)

    ledger.append(build_trace())
    ledger.append(build_trace())

    raw = json.loads(path.read_text(encoding="utf-8"))
    raw[1]["prior_envelope_hash"] = "0" * 64

    path.write_text(
        json.dumps(raw),
        encoding="utf-8",
    )

    with pytest.raises(TraceLedgerCorruptionError):
        ledger.verify()


def test_persistent_ledger_detects_payload_tampering(
    tmp_path: Path,
) -> None:
    path = tmp_path / "trace-ledger.json"
    ledger = PersistentTraceLedger(path)

    ledger.append(build_trace())

    raw = json.loads(path.read_text(encoding="utf-8"))
    raw[0]["payload"]["transition_id"] = "MS-TR-999"

    path.write_text(
        json.dumps(raw),
        encoding="utf-8",
    )

    with pytest.raises(ValueError):
        ledger.verify()
