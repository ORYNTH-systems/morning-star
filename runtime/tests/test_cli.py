"""Tests for the Morning Star command-line interface."""

import json
from pathlib import Path

from morning_star.cli.main import main


def build_cli_configuration(
    tmp_path: Path,
) -> Path:
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

    configuration_path = tmp_path / "runtime.config.json"

    configuration_path.write_text(
        json.dumps(
            {
                "runtime_id": "MS-RUNTIME-CLI",
                "runtime_version": "0.5.0",
                "architecture_manifest_path": "manifest.json",
                "invariant_registry_path": "invariants.csv",
                "transition_registry_path": "transitions.csv",
                "repository_path": "repository",
                "trace_ledger_path": "trace-ledger.json",
                "snapshot_path": "snapshot.json",
            }
        ),
        encoding="utf-8",
    )

    return configuration_path


def test_cli_validate(
    tmp_path: Path,
    capsys,
) -> None:
    configuration = build_cli_configuration(tmp_path)

    result = main(
        [
            "--config",
            str(configuration),
            "validate",
        ]
    )

    output = capsys.readouterr().out

    assert result == 0
    assert '"success":true' in output


def test_cli_verify(
    tmp_path: Path,
    capsys,
) -> None:
    configuration = build_cli_configuration(tmp_path)

    result = main(
        [
            "--config",
            str(configuration),
            "verify",
        ]
    )

    output = capsys.readouterr().out

    assert result == 0
    assert '"operation":"VERIFY_INTEGRITY"' in output


def test_cli_snapshot(
    tmp_path: Path,
    capsys,
) -> None:
    configuration = build_cli_configuration(tmp_path)

    result = main(
        [
            "--config",
            str(configuration),
            "snapshot",
        ]
    )

    output = capsys.readouterr().out

    assert result == 0
    assert '"operation":"GENERATE_SNAPSHOT"' in output
    assert (tmp_path / "snapshot.json").exists()


def test_cli_invalid_configuration_returns_two(
    tmp_path: Path,
    capsys,
) -> None:
    missing = tmp_path / "missing.json"

    result = main(
        [
            "--config",
            str(missing),
            "validate",
        ]
    )

    output = capsys.readouterr().out

    assert result == 2
    assert "MS-FAIL-CONFIGURATION-001" in output
