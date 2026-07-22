"""Immutable hash-bearing runtime envelopes."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from typing import Any
from uuid import UUID, uuid4

from morning_star.models.canonical import utc_now
from morning_star.models.serialization import (
    canonical_bytes,
    canonical_dict,
    canonical_sha256,
)


@dataclass(frozen=True, slots=True)
class RuntimeEnvelope:
    """Immutable transport and persistence envelope."""

    envelope_id: UUID = field(default_factory=uuid4)
    object_type: str = ""
    schema_version: str = "1.0.0"
    payload: dict[str, Any] = field(default_factory=dict)
    payload_hash: str = ""
    prior_envelope_hash: str | None = None
    created_at: datetime = field(default_factory=utc_now)

    def __post_init__(self) -> None:
        if not self.object_type.strip():
            raise ValueError("object_type must be a non-empty string.")

        if not self.schema_version.strip():
            raise ValueError("schema_version must be a non-empty string.")

        computed = canonical_sha256(self.payload)

        if not self.payload_hash:
            object.__setattr__(self, "payload_hash", computed)
        elif self.payload_hash.upper() != computed:
            raise ValueError("payload_hash does not match the canonical payload.")

        if self.prior_envelope_hash is not None:
            normalized = self.prior_envelope_hash.strip().upper()

            if len(normalized) != 64:
                raise ValueError(
                    "prior_envelope_hash must be a 64-character SHA-256 digest."
                )

            object.__setattr__(
                self,
                "prior_envelope_hash",
                normalized,
            )

    @classmethod
    def from_object(
        cls,
        value: Any,
        *,
        object_type: str,
        schema_version: str = "1.0.0",
        prior_envelope_hash: str | None = None,
    ) -> "RuntimeEnvelope":
        """Create an immutable envelope from a canonical runtime object."""

        return cls(
            object_type=object_type,
            schema_version=schema_version,
            payload=canonical_dict(value),
            prior_envelope_hash=prior_envelope_hash,
        )

    def canonical_bytes(self) -> bytes:
        """Serialize the complete envelope deterministically."""

        return canonical_bytes(self)

    def envelope_hash(self) -> str:
        """Hash the complete envelope."""

        return canonical_sha256(self)

    def verify_payload(self) -> bool:
        """Verify payload integrity."""

        return canonical_sha256(self.payload) == self.payload_hash


@dataclass(frozen=True, slots=True)
class EnvelopeChain:
    """Ordered immutable chain of runtime envelopes."""

    envelopes: tuple[RuntimeEnvelope, ...] = ()

    def append(self, envelope: RuntimeEnvelope) -> "EnvelopeChain":
        """Return a new chain containing the supplied envelope."""

        expected_prior = (
            self.envelopes[-1].envelope_hash()
            if self.envelopes
            else None
        )

        if envelope.prior_envelope_hash != expected_prior:
            raise ValueError(
                "Envelope prior hash does not match the current chain head."
            )

        return EnvelopeChain(
            envelopes=(*self.envelopes, envelope)
        )

    def verify(self) -> bool:
        """Verify payload hashes and chain linkage."""

        expected_prior: str | None = None

        for envelope in self.envelopes:
            if not envelope.verify_payload():
                return False

            if envelope.prior_envelope_hash != expected_prior:
                return False

            expected_prior = envelope.envelope_hash()

        return True

    @property
    def head_hash(self) -> str | None:
        """Return the current chain-head hash."""

        if not self.envelopes:
            return None

        return self.envelopes[-1].envelope_hash()
