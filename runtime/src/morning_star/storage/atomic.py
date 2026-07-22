"""Atomic deterministic file storage utilities."""

from __future__ import annotations

import os
import tempfile
from pathlib import Path
from typing import Any

from morning_star.models.serialization import canonical_bytes


class StorageIntegrityError(ValueError):
    """Raised when stored data fails integrity validation."""


def atomic_write_bytes(
    path: Path,
    data: bytes,
) -> None:
    """Write bytes atomically within the target directory."""

    path = path.resolve()
    path.parent.mkdir(parents=True, exist_ok=True)

    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.",
        suffix=".tmp",
        dir=path.parent,
    )

    temporary_path = Path(temporary_name)

    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(data)
            handle.flush()
            os.fsync(handle.fileno())

        os.replace(temporary_path, path)
    except Exception:
        temporary_path.unlink(missing_ok=True)
        raise


def atomic_write_canonical_json(
    path: Path,
    value: Any,
) -> None:
    """Serialize canonically and write atomically."""

    atomic_write_bytes(
        path,
        canonical_bytes(value),
    )


def read_bytes(
    path: Path,
) -> bytes:
    """Read complete file bytes."""

    if not path.exists():
        raise FileNotFoundError(path)

    if not path.is_file():
        raise IsADirectoryError(path)

    return path.read_bytes()


def verify_file_hash(
    path: Path,
    expected_hash: str,
) -> bool:
    """Verify a file's raw SHA-256 digest."""

    import hashlib

    actual = hashlib.sha256(read_bytes(path)).hexdigest().upper()

    return actual == expected_hash.strip().upper()
