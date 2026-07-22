"""Tests for immutable runtime envelopes."""

from dataclasses import replace
from uuid import UUID

import pytest

from morning_star.models.envelopes import (
    EnvelopeChain,
    RuntimeEnvelope,
)


def test_envelope_computes_payload_hash() -> None:
    envelope = RuntimeEnvelope(
        object_type="TEST_OBJECT",
        payload={"name": "Morning Star"},
    )

    assert len(envelope.payload_hash) == 64
    assert envelope.verify_payload() is True


def test_envelope_rejects_invalid_payload_hash() -> None:
    with pytest.raises(ValueError):
        RuntimeEnvelope(
            object_type="TEST_OBJECT",
            payload={"name": "Morning Star"},
            payload_hash="0" * 64,
        )


def test_envelope_hash_is_deterministic() -> None:
    envelope = RuntimeEnvelope(
        envelope_id=UUID("11111111-1111-1111-1111-111111111111"),
        object_type="TEST_OBJECT",
        payload={"name": "Morning Star"},
    )

    assert envelope.envelope_hash() == envelope.envelope_hash()


def test_empty_chain_has_no_head() -> None:
    chain = EnvelopeChain()

    assert chain.head_hash is None
    assert chain.verify() is True


def test_chain_accepts_correct_linkage() -> None:
    first = RuntimeEnvelope(
        object_type="TEST_OBJECT",
        payload={"sequence": 1},
    )

    chain = EnvelopeChain().append(first)

    second = RuntimeEnvelope(
        object_type="TEST_OBJECT",
        payload={"sequence": 2},
        prior_envelope_hash=chain.head_hash,
    )

    chain = chain.append(second)

    assert chain.verify() is True
    assert len(chain.envelopes) == 2


def test_chain_rejects_invalid_linkage() -> None:
    first = RuntimeEnvelope(
        object_type="TEST_OBJECT",
        payload={"sequence": 1},
    )

    chain = EnvelopeChain().append(first)

    invalid = RuntimeEnvelope(
        object_type="TEST_OBJECT",
        payload={"sequence": 2},
        prior_envelope_hash="F" * 64,
    )

    with pytest.raises(ValueError):
        chain.append(invalid)


def test_chain_detects_payload_tampering() -> None:
    first = RuntimeEnvelope(
        object_type="TEST_OBJECT",
        payload={"sequence": 1},
    )

    chain = EnvelopeChain().append(first)

    tampered = replace(first)
    object.__setattr__(tampered, "payload", {"sequence": 999})

    corrupted = EnvelopeChain(envelopes=(tampered,))

    assert corrupted.verify() is False

