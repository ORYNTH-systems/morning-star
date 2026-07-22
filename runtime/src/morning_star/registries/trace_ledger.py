"""Immutable constitutional trace ledger."""

from __future__ import annotations

from dataclasses import dataclass, field

from morning_star.models.canonical import ConstitutionalTrace
from morning_star.models.envelopes import EnvelopeChain, RuntimeEnvelope


@dataclass(frozen=True, slots=True)
class TraceLedger:
    """Append-only hash-linked constitutional trace ledger."""

    chain: EnvelopeChain = field(default_factory=EnvelopeChain)

    def append(
        self,
        trace: ConstitutionalTrace,
    ) -> "TraceLedger":
        envelope = RuntimeEnvelope.from_object(
            trace,
            object_type="CONSTITUTIONAL_TRACE",
            schema_version="1.0.0",
            prior_envelope_hash=self.chain.head_hash,
        )

        return TraceLedger(
            chain=self.chain.append(envelope)
        )

    def verify(self) -> bool:
        return self.chain.verify()

    def __len__(self) -> int:
        return len(self.chain.envelopes)
