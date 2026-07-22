"""Tests for atomic deterministic storage."""

from pathlib import Path

from morning_star.storage.atomic import (
    atomic_write_bytes,
    atomic_write_canonical_json,
    read_bytes,
    verify_file_hash,
)


def test_atomic_write_bytes(tmp_path: Path) -> None:
    path = tmp_path / "record.bin"

    atomic_write_bytes(path, b"morning-star")

    assert read_bytes(path) == b"morning-star"


def test_atomic_write_replaces_existing_file(tmp_path: Path) -> None:
    path = tmp_path / "record.bin"

    atomic_write_bytes(path, b"first")
    atomic_write_bytes(path, b"second")

    assert read_bytes(path) == b"second"


def test_atomic_write_creates_parent_directory(tmp_path: Path) -> None:
    path = tmp_path / "nested" / "record.bin"

    atomic_write_bytes(path, b"value")

    assert path.exists()


def test_atomic_canonical_json_is_deterministic(tmp_path: Path) -> None:
    first = tmp_path / "first.json"
    second = tmp_path / "second.json"

    atomic_write_canonical_json(
        first,
        {"z": 1, "a": 2},
    )

    atomic_write_canonical_json(
        second,
        {"a": 2, "z": 1},
    )

    assert first.read_bytes() == second.read_bytes()


def test_verify_file_hash(tmp_path: Path) -> None:
    import hashlib

    path = tmp_path / "record.bin"
    data = b"morning-star"

    atomic_write_bytes(path, data)

    expected = hashlib.sha256(data).hexdigest()

    assert verify_file_hash(path, expected) is True
    assert verify_file_hash(path, "0" * 64) is False
