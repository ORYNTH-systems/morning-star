"""Load constitutional CSV registries into verified runtime records."""

from __future__ import annotations

import csv
from dataclasses import dataclass
from pathlib import Path


class ConstitutionalRegistryError(ValueError):
    """Raised when a constitutional CSV registry is invalid."""


@dataclass(frozen=True, slots=True)
class ConstitutionalRegistry:
    path: Path
    identifier_column: str
    rows: tuple[dict[str, str], ...]

    @classmethod
    def load(
        cls,
        path: Path,
        *,
        identifier_column: str,
    ) -> "ConstitutionalRegistry":
        if not path.exists():
            raise FileNotFoundError(path)

        with path.open(
            "r",
            encoding="utf-8-sig",
            newline="",
        ) as handle:
            reader = csv.DictReader(handle)

            if reader.fieldnames is None:
                raise ConstitutionalRegistryError(
                    "Registry contains no header."
                )

            if identifier_column not in reader.fieldnames:
                raise ConstitutionalRegistryError(
                    f"Missing identifier column: {identifier_column}"
                )

            rows = tuple(dict(row) for row in reader)

        if not rows:
            raise ConstitutionalRegistryError(
                "Registry contains no records."
            )

        identifiers: list[str] = []

        for index, row in enumerate(rows, start=1):
            identifier = row.get(identifier_column, "").strip()

            if not identifier:
                raise ConstitutionalRegistryError(
                    f"Blank identifier at row {index}."
                )

            identifiers.append(identifier)

        duplicates = sorted(
            identifier
            for identifier in set(identifiers)
            if identifiers.count(identifier) > 1
        )

        if duplicates:
            raise ConstitutionalRegistryError(
                f"Duplicate identifiers: {duplicates}"
            )

        return cls(
            path=path,
            identifier_column=identifier_column,
            rows=rows,
        )

    def get(
        self,
        identifier: str,
    ) -> dict[str, str]:
        for row in self.rows:
            if row[self.identifier_column] == identifier:
                return row

        raise KeyError(identifier)

    def identifiers(self) -> tuple[str, ...]:
        return tuple(
            row[self.identifier_column]
            for row in self.rows
        )

    def __len__(self) -> int:
        return len(self.rows)
