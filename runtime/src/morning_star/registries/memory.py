"""Typed in-memory runtime registry."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Generic, Iterable, TypeVar
from uuid import UUID


T = TypeVar("T")


@dataclass(slots=True)
class RuntimeRegistry(Generic[T]):
    """Store uniquely identified runtime objects."""

    _records: dict[UUID, T] = field(default_factory=dict)

    def add(self, record_id: UUID, record: T) -> None:
        if record_id in self._records:
            raise ValueError(f"Duplicate record ID: {record_id}")

        self._records[record_id] = record

    def replace(self, record_id: UUID, record: T) -> None:
        if record_id not in self._records:
            raise KeyError(f"Unknown record ID: {record_id}")

        self._records[record_id] = record

    def get(self, record_id: UUID) -> T:
        try:
            return self._records[record_id]
        except KeyError as exc:
            raise KeyError(f"Unknown record ID: {record_id}") from exc

    def contains(self, record_id: UUID) -> bool:
        return record_id in self._records

    def values(self) -> tuple[T, ...]:
        return tuple(self._records.values())

    def extend(self, records: Iterable[tuple[UUID, T]]) -> None:
        for record_id, record in records:
            self.add(record_id, record)

    def __len__(self) -> int:
        return len(self._records)
