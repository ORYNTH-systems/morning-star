"""Persistent append-only constitutional trace ledger."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from uuid import UUID

from morning_star.models.canonical import ConstitutionalTrace
from morning_star.models.envelopes import RuntimeEnvelope
from morning_star.models.reconstruction import reconstruct_trace
from morning_star.models.serialization import canonical_json
from morning_star.storage.atomic import atomic_write_bytes


class TraceLedgerCorruptionError(ValueError):
    """Raised when persistent trace history is invalid."""


@dataclass(frozen=True, slots=True)
class PersistentTraceLedger:
    """Append and recover hash-linked constitutional trace envelopes."""

    path: Path

    def _load_raw(self) -> list[dict[str, object]]:
        if not self.path.exists():
            return []

        try:
            data = json.loads(self.path.read_text(encoding="utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise TraceLedgerCorruptionError(
                "Trace ledger is not valid JSON."
            ) from exc

        if not isinstance(data, list):
            raise TraceLedgerCorruptionError(
                "Trace ledger root must be an array."
            )

        return data

    def load_envelopes(self) -> tuple[RuntimeEnvelope, ...]:
        raw_entries = self._load_raw()
        envelopes: list[RuntimeEnvelope] = []
        expected_prior: str | None = None

        for index, raw in enumerate(raw_entries):
            if not isinstance(raw, dict):
                raise TraceLedgerCorruptionError(
                    f"Ledger entry {index} is not an object."
                )

            try:
                from datetime import datetime

                envelope = RuntimeEnvelope(
                    envelope_id=UUID(str(raw["envelope_id"])),
                    object_type=str(raw["object_type"]),
                    schema_version=str(raw["schema_version"]),
                    payload=dict(raw["payload"]),
                    payload_hash=str(raw["payload_hash"]),
                    prior_envelope_hash=(
                        str(raw["prior_envelope_hash"])
                        if raw["prior_envelope_hash"] is not None
                        else None
                    ),
                    created_at=datetime.fromisoformat(
                        str(raw["created_at"])
                    ),
                )
            except (KeyError, TypeError, ValueError) as exc:
                raise TraceLedgerCorruptionError(
                    f"Invalid ledger entry {index}."
                ) from exc

            if envelope.object_type != "CONSTITUTIONAL_TRACE":
                raise TraceLedgerCorruptionError(
                    f"Ledger entry {index} has invalid object type."
                )

            if envelope.prior_envelope_hash != expected_prior:
                raise TraceLedgerCorruptionError(
                    f"Ledger chain break at entry {index}."
                )

            expected_prior = envelope.envelope_hash()
            envelopes.append(envelope)

        return tuple(envelopes)

    def append(
        self,
        trace: ConstitutionalTrace,
    ) -> RuntimeEnvelope:
        envelopes = self.load_envelopes()

        prior_hash = (
            envelopes[-1].envelope_hash()
            if envelopes
            else None
        )

        envelope = RuntimeEnvelope.from_object(
            trace,
            object_type="CONSTITUTIONAL_TRACE",
            schema_version="1.0.0",
            prior_envelope_hash=prior_hash,
        )

        updated = [
            *[json.loads(canonical_json(item)) for item in envelopes],
            json.loads(canonical_json(envelope)),
        ]

        atomic_write_bytes(
            self.path,
            canonical_json(updated).encode("utf-8"),
        )

        self.verify()

        return envelope

    def traces(self) -> tuple[ConstitutionalTrace, ...]:
        return tuple(
            reconstruct_trace(envelope.payload)
            for envelope in self.load_envelopes()
        )

    def verify(self) -> bool:
        self.load_envelopes()

        return True

    @property
    def head_hash(self) -> str | None:
        envelopes = self.load_envelopes()

        if not envelopes:
            return None

        return envelopes[-1].envelope_hash()

    def __len__(self) -> int:
        return len(self.load_envelopes())
