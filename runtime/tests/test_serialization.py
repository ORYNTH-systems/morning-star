"""Tests for deterministic Morning Star serialization."""

from dataclasses import dataclass
from datetime import datetime, timezone
from uuid import UUID

import pytest

from morning_star.models.serialization import (
    SerializationError,
    canonical_bytes,
    canonical_dict,
    canonical_json,
    canonical_sha256,
    verify_canonical_hash,
)


@dataclass(frozen=True)
class Sample:
    name: str
    count: int
    identifier: UUID
    created_at: datetime


def build_sample() -> Sample:
    return Sample(
        name="Morning Star",
        count=5,
        identifier=UUID("11111111-1111-1111-1111-111111111111"),
        created_at=datetime(
            2026,
            7,
            22,
            12,
            0,
            0,
            tzinfo=timezone.utc,
        ),
    )


def test_canonical_json_is_deterministic() -> None:
    first = {
        "z": 1,
        "a": 2,
    }

    second = {
        "a": 2,
        "z": 1,
    }

    assert canonical_json(first) == canonical_json(second)


def test_canonical_bytes_are_utf8_json() -> None:
    value = {"name": "Morning Star"}

    assert canonical_bytes(value) == b'{"name":"Morning Star"}'


def test_canonical_hash_is_deterministic() -> None:
    sample = build_sample()

    first = canonical_sha256(sample)
    second = canonical_sha256(sample)

    assert first == second
    assert len(first) == 64


def test_hash_verification_passes() -> None:
    sample = build_sample()
    expected = canonical_sha256(sample)

    assert verify_canonical_hash(sample, expected) is True


def test_hash_verification_fails() -> None:
    sample = build_sample()

    assert verify_canonical_hash(sample, "0" * 64) is False


def test_dataclass_serialization_preserves_fields() -> None:
    sample = build_sample()
    result = canonical_dict(sample)

    assert result["name"] == "Morning Star"
    assert result["count"] == 5
    assert result["identifier"] == "11111111-1111-1111-1111-111111111111"


def test_naive_datetime_is_rejected() -> None:
    with pytest.raises(SerializationError):
        canonical_json(
            {
                "created_at": datetime(2026, 7, 22, 12, 0, 0),
            }
        )


def test_non_string_mapping_key_is_rejected() -> None:
    with pytest.raises(SerializationError):
        canonical_json({1: "invalid"})


def test_nan_is_rejected() -> None:
    with pytest.raises(SerializationError):
        canonical_json({"value": float("nan")})


def test_set_serialization_is_deterministic() -> None:
    first = canonical_json({"values": {"b", "a", "c"}})
    second = canonical_json({"values": {"c", "b", "a"}})

    assert first == second
