"""Atomic multi-record transaction staging."""

from __future__ import annotations

import shutil
import tempfile
from dataclasses import dataclass, field
from pathlib import Path
from uuid import UUID, uuid4

from morning_star.models.envelopes import RuntimeEnvelope
from morning_star.registries.repository import (
    OBJECT_TYPE_DIRECTORIES,
    RuntimeRepository,
)


class TransactionError(ValueError):
    """Raised when a runtime transaction cannot commit."""


@dataclass(slots=True)
class RuntimeTransaction:
    """Stage and atomically commit multiple runtime envelopes."""

    repository: RuntimeRepository
    transaction_id: UUID = field(default_factory=uuid4)
    _envelopes: list[RuntimeEnvelope] = field(default_factory=list)
    _committed: bool = False

    def stage(
        self,
        envelope: RuntimeEnvelope,
    ) -> None:
        if self._committed:
            raise TransactionError(
                "Cannot stage records after transaction commit."
            )

        if envelope.object_type not in OBJECT_TYPE_DIRECTORIES:
            raise TransactionError(
                f"Unsupported object type: {envelope.object_type}"
            )

        if any(
            existing.envelope_id == envelope.envelope_id
            for existing in self._envelopes
        ):
            raise TransactionError(
                f"Duplicate staged envelope ID: {envelope.envelope_id}"
            )

        self._envelopes.append(envelope)

    def commit(self) -> tuple[Path, ...]:
        if self._committed:
            raise TransactionError(
                "Transaction has already been committed."
            )

        if not self._envelopes:
            raise TransactionError(
                "Cannot commit an empty transaction."
            )

        staging_parent = self.repository.root.parent
        staging_root = Path(
            tempfile.mkdtemp(
                prefix=f".transaction-{self.transaction_id}-",
                dir=staging_parent,
            )
        )

        staged_repository = RuntimeRepository(staging_root)

        try:
            staged_paths: list[Path] = []

            for envelope in self._envelopes:
                staged_paths.append(
                    staged_repository.save(envelope)
                )

            staged_repository.verify_all()

            committed_paths: list[Path] = []

            for envelope in self._envelopes:
                source_path = (
                    staging_root
                    / OBJECT_TYPE_DIRECTORIES[envelope.object_type]
                    / f"{envelope.envelope_id}.json"
                )

                target_path = (
                    self.repository.root
                    / OBJECT_TYPE_DIRECTORIES[envelope.object_type]
                    / f"{envelope.envelope_id}.json"
                )

                if target_path.exists():
                    existing = self.repository.load(
                        envelope.object_type,
                        envelope.envelope_id,
                    )

                    if existing.envelope_hash() != envelope.envelope_hash():
                        raise TransactionError(
                            f"Envelope collision during commit: "
                            f"{envelope.envelope_id}"
                        )

                    committed_paths.append(target_path)
                    continue

                target_path.parent.mkdir(
                    parents=True,
                    exist_ok=True,
                )

                source_path.replace(target_path)
                committed_paths.append(target_path)

            self.repository.verify_all()
            self._committed = True

            return tuple(committed_paths)
        finally:
            shutil.rmtree(
                staging_root,
                ignore_errors=True,
            )

    @property
    def staged_count(self) -> int:
        return len(self._envelopes)

    @property
    def committed(self) -> bool:
        return self._committed
