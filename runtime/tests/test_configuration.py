"""Tests for runtime configuration."""

import json
from pathlib import Path

import pytest

from morning_star.config.runtime import (
    RuntimeConfiguration,
    RuntimeConfigurationError,
)


def build_configuration(
    tmp_path: Path,
) -> Path:
    architecture = tmp_path / "architecture.json"
    invariants = tmp_path / "invariants.csv"
    transitions = tmp_path / "transitions.csv"

    architecture.write_text(
        "{}",
        encoding="utf-8",
    )
    invariants.write_text(
        "InvariantID\nMS-INV-001\n",
        encoding="utf-8",
    )
    transitions.write_text(
        "TransitionID\nMS-TR-001\n",
        encoding="utf-8",
    )

    path = tmp_path / "runtime.config.json"

    path.write_text(
        json.dumps(
            {
                "runtime_id": "MS-RUNTIME-TEST",
                "runtime_version": "0.5.0",
                "architecture_manifest_path": "architecture.json",
                "invariant_registry_path": "invariants.csv",
                "transition_registry_path": "transitions.csv",
                "repository_path": "state/repository",
                "trace_ledger_path": "state/trace.json",
                "snapshot_path": "state/snapshot.json",
            }
        ),
        encoding="utf-8",
    )

    return path


def test_configuration_loads_relative_paths(
    tmp_path: Path,
) -> None:
    path = build_configuration(tmp_path)

    configuration = RuntimeConfiguration.load(path)

    assert configuration.runtime_id == "MS-RUNTIME-TEST"
    assert configuration.repository_path.is_absolute()


def test_configuration_verifies_required_sources(
    tmp_path: Path,
) -> None:
    path = build_configuration(tmp_path)

    configuration = RuntimeConfiguration.load(path)

    assert configuration.verify_required_sources() is True


def test_configuration_rejects_missing_fields(
    tmp_path: Path,
) -> None:
    path = tmp_path / "runtime.config.json"

    path.write_text(
        "{}",
        encoding="utf-8",
    )

    with pytest.raises(RuntimeConfigurationError):
        RuntimeConfiguration.load(path)


def test_configuration_rejects_non_object_root(
    tmp_path: Path,
) -> None:
    path = tmp_path / "runtime.config.json"

    path.write_text(
        "[]",
        encoding="utf-8",
    )

    with pytest.raises(RuntimeConfigurationError):
        RuntimeConfiguration.load(path)


def test_configuration_detects_missing_sources(
    tmp_path: Path,
) -> None:
    path = build_configuration(tmp_path)
    configuration = RuntimeConfiguration.load(path)

    configuration.architecture_manifest_path.unlink()

    with pytest.raises(RuntimeConfigurationError):
        configuration.verify_required_sources()
