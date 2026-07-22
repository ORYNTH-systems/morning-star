"""Deterministic serialization and hashing for Morning Star runtime objects."""

from __future__ import annotations

import hashlib
import json
from dataclasses import fields, is_dataclass
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Any, Mapping, Sequence
from uuid import UUID


class SerializationError(ValueError):
    """Raised when a runtime value cannot be serialized canonically."""


def _canonicalize(value: Any) -> Any:
    """Convert supported runtime values to deterministic JSON-compatible data."""

    if value is None:
        return None

    if isinstance(value, bool):
        return value

    if isinstance(value, int):
        return value

    if isinstance(value, float):
        if value != value:
            raise SerializationError("NaN values are not canonically serializable.")

        if value in {float("inf"), float("-inf")}:
            raise SerializationError(
                "Infinite values are not canonically serializable."
            )

        return value

    if isinstance(value, str):
        return value

    if isinstance(value, UUID):
        return str(value)

    if isinstance(value, datetime):
        if value.tzinfo is None:
            raise SerializationError(
                "Naive datetimes are not canonically serializable."
            )

        return value.isoformat()

    if isinstance(value, Enum):
        return value.value

    if isinstance(value, Path):
        return value.as_posix()

    if is_dataclass(value):
        return {
            field.name: _canonicalize(getattr(value, field.name))
            for field in fields(value)
        }

    if isinstance(value, Mapping):
        normalized: dict[str, Any] = {}

        for key, item in value.items():
            if not isinstance(key, str):
                raise SerializationError(
                    "Canonical mapping keys must be strings."
                )

            normalized[key] = _canonicalize(item)

        return {
            key: normalized[key]
            for key in sorted(normalized)
        }

    if isinstance(value, tuple):
        return [_canonicalize(item) for item in value]

    if isinstance(value, list):
        return [_canonicalize(item) for item in value]

    if isinstance(value, set):
        canonical_items = [_canonicalize(item) for item in value]

        return sorted(
            canonical_items,
            key=lambda item: json.dumps(
                item,
                ensure_ascii=False,
                sort_keys=True,
                separators=(",", ":"),
            ),
        )

    if isinstance(value, Sequence):
        return [_canonicalize(item) for item in value]

    raise SerializationError(
        f"Unsupported canonical serialization type: {type(value).__name__}"
    )


def canonical_dict(value: Any) -> dict[str, Any]:
    """Return a canonical mapping representation."""

    canonical = _canonicalize(value)

    if not isinstance(canonical, dict):
        raise SerializationError(
            "canonical_dict requires a mapping or dataclass root object."
        )

    return canonical


def canonical_json(value: Any) -> str:
    """Return deterministic compact JSON."""

    return json.dumps(
        _canonicalize(value),
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
        allow_nan=False,
    )


def canonical_bytes(value: Any) -> bytes:
    """Return deterministic UTF-8 bytes."""

    return canonical_json(value).encode("utf-8")


def canonical_sha256(value: Any) -> str:
    """Return the SHA-256 digest of deterministic UTF-8 bytes."""

    return hashlib.sha256(canonical_bytes(value)).hexdigest().upper()


def verify_canonical_hash(value: Any, expected_hash: str) -> bool:
    """Verify a canonical SHA-256 digest."""

    if not isinstance(expected_hash, str):
        return False

    return canonical_sha256(value) == expected_hash.strip().upper()
