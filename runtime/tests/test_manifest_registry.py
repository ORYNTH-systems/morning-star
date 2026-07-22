"""Tests for architecture manifest and constitutional registries."""

import csv
import json
from pathlib import Path

import pytest

from morning_star.engines.manifest import (
    ArchitectureManifest,
    ArchitectureManifestError,
)
from morning_star.engines.registry_ingestion import (
    ConstitutionalRegistry,
    ConstitutionalRegistryError,
)


def build_manifest(path: Path) -> None:
    data = {
        "architecture_id": "MS-ARCH-001",
        "architecture_name": "Morning Star",
        "version": "1.0.0-rc.1",
        "status": "ARCHITECTURE_FROZEN",
        "constitutional_subject": "Semantic preservation.",
        "volumes": [
            {"volume_id": f"MS-V{index}"}
            for index in range(1, 6)
        ],
        "invariant_registry": "governance/invariants.csv",
        "state_transition_registry": "governance/transitions.csv",
        "generated_at": "2026-07-22T12:00:00+00:00",
        "git_commit": "abc123",
        "artifact_count": 50,
        "aggregate_hash": "A" * 64,
    }

    path.write_text(
        json.dumps(data),
        encoding="utf-8",
    )


def test_architecture_manifest_loads(tmp_path: Path) -> None:
    path = tmp_path / "manifest.json"
    build_manifest(path)

    manifest = ArchitectureManifest.load(path)

    assert manifest.architecture_id == "MS-ARCH-001"
    assert len(manifest.volumes) == 5


def test_unfrozen_manifest_is_rejected(tmp_path: Path) -> None:
    path = tmp_path / "manifest.json"
    build_manifest(path)

    raw = json.loads(path.read_text(encoding="utf-8"))
    raw["status"] = "ARCHITECTURE_FREEZE_CANDIDATE"

    path.write_text(
        json.dumps(raw),
        encoding="utf-8",
    )

    with pytest.raises(ArchitectureManifestError):
        ArchitectureManifest.load(path)


def test_registry_loads_unique_identifiers(tmp_path: Path) -> None:
    path = tmp_path / "registry.csv"

    with path.open(
        "w",
        encoding="utf-8",
        newline="",
    ) as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["InvariantID", "Name"],
        )
        writer.writeheader()
        writer.writerow({
            "InvariantID": "MS-INV-001",
            "Name": "Identity",
        })
        writer.writerow({
            "InvariantID": "MS-INV-002",
            "Name": "Framework",
        })

    registry = ConstitutionalRegistry.load(
        path,
        identifier_column="InvariantID",
    )

    assert len(registry) == 2
    assert registry.get("MS-INV-001")["Name"] == "Identity"


def test_registry_rejects_duplicate_identifiers(
    tmp_path: Path,
) -> None:
    path = tmp_path / "registry.csv"

    path.write_text(
        "InvariantID,Name\n"
        "MS-INV-001,Identity\n"
        "MS-INV-001,Duplicate\n",
        encoding="utf-8",
    )

    with pytest.raises(ConstitutionalRegistryError):
        ConstitutionalRegistry.load(
            path,
            identifier_column="InvariantID",
        )


def test_registry_rejects_missing_identifier_column(
    tmp_path: Path,
) -> None:
    path = tmp_path / "registry.csv"

    path.write_text(
        "Name\nIdentity\n",
        encoding="utf-8",
    )

    with pytest.raises(ConstitutionalRegistryError):
        ConstitutionalRegistry.load(
            path,
            identifier_column="InvariantID",
        )
