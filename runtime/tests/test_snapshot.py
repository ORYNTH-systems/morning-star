"""Tests for deterministic runtime snapshots."""

from pathlib import Path

from morning_star.models.snapshot import RuntimeSnapshot


def build_snapshot() -> RuntimeSnapshot:
    return RuntimeSnapshot(
        runtime_version="0.3.0",
        architecture_version="1.0.0-rc.1",
        architecture_hash="A" * 64,
        registry_counts={
            "objects": 10,
            "traces": 5,
        },
        registry_hashes={
            "objects": "B" * 64,
            "traces": "C" * 64,
        },
        trace_count=5,
        trace_head_hash="D" * 64,
    )


def test_snapshot_generates_hash() -> None:
    snapshot = build_snapshot()

    assert len(snapshot.snapshot_hash) == 64
    assert snapshot.verify() is True


def test_snapshot_writes_canonical_json(tmp_path: Path) -> None:
    snapshot = build_snapshot()
    path = tmp_path / "snapshot.json"

    snapshot.write(path)

    assert path.exists()
    assert b'"snapshot_hash"' in path.read_bytes()


def test_snapshot_rejects_invalid_architecture_hash() -> None:
    import pytest

    with pytest.raises(ValueError):
        RuntimeSnapshot(
            runtime_version="0.3.0",
            architecture_version="1.0.0",
            architecture_hash="invalid",
        )


def test_snapshot_rejects_invalid_declared_hash() -> None:
    import pytest

    snapshot = build_snapshot()

    with pytest.raises(ValueError):
        RuntimeSnapshot(
            snapshot_id=snapshot.snapshot_id,
            runtime_version=snapshot.runtime_version,
            architecture_version=snapshot.architecture_version,
            architecture_hash=snapshot.architecture_hash,
            registry_counts=snapshot.registry_counts,
            registry_hashes=snapshot.registry_hashes,
            trace_count=snapshot.trace_count,
            trace_head_hash=snapshot.trace_head_hash,
            created_at=snapshot.created_at,
            snapshot_hash="0" * 64,
        )
