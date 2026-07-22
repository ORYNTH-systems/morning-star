"""Tests for the Morning Star public runtime API."""

import json
from pathlib import Path
from uuid import uuid4

from morning_star.api.runtime import MorningStarRuntimeApi
from morning_star.config.runtime import RuntimeConfiguration
from morning_star.engines.transitions import TransitionRequest
from morning_star.models.canonical import (
    AuthorityRecord,
    EvidenceRecord,
    ParticipationRecord,
)
from morning_star.models.enums import (
    ConstitutionalState,
    ParticipationRole,
)


def build_runtime(
    tmp_path: Path,
) -> MorningStarRuntimeApi:
    manifest_path = tmp_path / "manifest.json"
    invariant_path = tmp_path / "invariants.csv"
    transition_path = tmp_path / "transitions.csv"

    manifest_path.write_text(
        json.dumps(
            {
                "architecture_id": "MS-ARCH-001",
                "architecture_name": "Morning Star",
                "version": "1.0.0-rc.1",
                "status": "ARCHITECTURE_FROZEN",
                "constitutional_subject": "Semantic integrity.",
                "volumes": [
                    {"volume_id": f"MS-V{index}"}
                    for index in range(1, 6)
                ],
                "invariant_registry": "invariants.csv",
                "state_transition_registry": "transitions.csv",
                "generated_at": "2026-07-22T12:00:00+00:00",
                "git_commit": "abc123",
                "artifact_count": 50,
                "aggregate_hash": "A" * 64,
            }
        ),
        encoding="utf-8",
    )

    invariant_path.write_text(
        "InvariantID,Name\n"
        "MS-INV-001,Identity\n",
        encoding="utf-8",
    )

    transition_path.write_text(
        "TransitionID,Name\n"
        + "\n".join(
            f"MS-TR-{index:03d},Transition {index}"
            for index in range(1, 18)
        )
        + "\n",
        encoding="utf-8",
    )

    configuration = RuntimeConfiguration(
        runtime_id="MS-RUNTIME-TEST",
        runtime_version="0.5.0",
        architecture_manifest_path=manifest_path,
        invariant_registry_path=invariant_path,
        transition_registry_path=transition_path,
        repository_path=tmp_path / "repository",
        trace_ledger_path=tmp_path / "trace-ledger.json",
        snapshot_path=tmp_path / "snapshot.json",
    )

    return MorningStarRuntimeApi(configuration)


def test_api_validates_environment(
    tmp_path: Path,
) -> None:
    api = build_runtime(tmp_path)

    result = api.validate_environment()

    assert result.success is True
    assert result.data["transition_count"] == 17


def test_api_verifies_empty_runtime_integrity(
    tmp_path: Path,
) -> None:
    api = build_runtime(tmp_path)

    result = api.verify_integrity()

    assert result.success is True


def test_api_executes_transition(
    tmp_path: Path,
) -> None:
    api = build_runtime(tmp_path)

    result = api.execute_transition(
        TransitionRequest(
            transition_id="MS-TR-001",
            current_state=ConstitutionalState.UNENCOUNTERED,
            actor_id=uuid4(),
            object_id=uuid4(),
            evidence_ids=(uuid4(),),
        )
    )

    assert result.success is True
    assert result.data["trace_count"] == 1


def test_api_returns_failure_for_invalid_transition(
    tmp_path: Path,
) -> None:
    api = build_runtime(tmp_path)

    result = api.execute_transition(
        TransitionRequest(
            transition_id="MS-TR-001",
            current_state=ConstitutionalState.IDENTIFIED,
            evidence_ids=(uuid4(),),
        )
    )

    assert result.success is False
    assert (
        result.failures[0].code
        == "MS-FAIL-TRANSITION-001"
    )


def test_api_evaluates_valid_initiation(
    tmp_path: Path,
) -> None:
    api = build_runtime(tmp_path)

    authority = AuthorityRecord(
        holder_id="ORYNTH",
        authority_type="INITIATION",
        scope="Morning Star",
        source="Constitution",
    )

    evidence = EvidenceRecord(
        evidence_type="ASSESSMENT",
        source="Morning Star",
        method="STRUCTURED",
        scope="PR1",
        integrity_verified=True,
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

    result = api.evaluate_initiation(
        participation,
        authorities={
            authority.authority_id: authority,
        },
        evidence={
            evidence.evidence_id: evidence,
        },
        uncertainties={},
    )

    assert result.success is True


def test_api_generates_snapshot(
    tmp_path: Path,
) -> None:
    api = build_runtime(tmp_path)

    result = api.generate_snapshot()

    assert result.success is True
    assert api.configuration.snapshot_path.exists()
