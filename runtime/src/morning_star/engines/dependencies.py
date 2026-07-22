"""Dependency graph evaluation for Morning Star runtime objects."""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum
from typing import Iterable
from uuid import UUID

from morning_star.models.canonical import DependencyRecord


class DependencyDisposition(StrEnum):
    SATISFIED = "SATISFIED"
    UNSATISFIED = "UNSATISFIED"
    MISSING = "MISSING"
    CYCLIC = "CYCLIC"


@dataclass(frozen=True, slots=True)
class DependencyFinding:
    dependency_id: UUID | None
    source_object_id: str
    target_object_id: str
    disposition: DependencyDisposition
    message: str


@dataclass(frozen=True, slots=True)
class DependencyEvaluation:
    valid: bool
    findings: tuple[DependencyFinding, ...]
    ordered_object_ids: tuple[str, ...]


class DependencyGraphEngine:
    """Validate dependencies and derive deterministic dependency order."""

    def evaluate(
        self,
        dependencies: Iterable[DependencyRecord],
        *,
        known_object_ids: set[str],
    ) -> DependencyEvaluation:
        records = tuple(dependencies)
        findings: list[DependencyFinding] = []

        adjacency: dict[str, set[str]] = {
            object_id: set()
            for object_id in known_object_ids
        }

        indegree: dict[str, int] = {
            object_id: 0
            for object_id in known_object_ids
        }

        for record in records:
            if record.source_object_id not in known_object_ids:
                findings.append(
                    DependencyFinding(
                        dependency_id=record.dependency_id,
                        source_object_id=record.source_object_id,
                        target_object_id=record.target_object_id,
                        disposition=DependencyDisposition.MISSING,
                        message="Dependency source object is missing.",
                    )
                )
                continue

            if record.target_object_id not in known_object_ids:
                findings.append(
                    DependencyFinding(
                        dependency_id=record.dependency_id,
                        source_object_id=record.source_object_id,
                        target_object_id=record.target_object_id,
                        disposition=DependencyDisposition.MISSING,
                        message="Dependency target object is missing.",
                    )
                )
                continue

            if record.mandatory and not record.satisfied:
                findings.append(
                    DependencyFinding(
                        dependency_id=record.dependency_id,
                        source_object_id=record.source_object_id,
                        target_object_id=record.target_object_id,
                        disposition=DependencyDisposition.UNSATISFIED,
                        message="Mandatory dependency is unsatisfied.",
                    )
                )

            if (
                record.target_object_id
                not in adjacency[record.source_object_id]
            ):
                adjacency[record.source_object_id].add(
                    record.target_object_id
                )
                indegree[record.target_object_id] += 1

        queue = sorted(
            object_id
            for object_id, degree in indegree.items()
            if degree == 0
        )

        ordered: list[str] = []

        while queue:
            current = queue.pop(0)
            ordered.append(current)

            for target in sorted(adjacency[current]):
                indegree[target] -= 1

                if indegree[target] == 0:
                    queue.append(target)
                    queue.sort()

        if len(ordered) != len(known_object_ids):
            cyclic = sorted(
                object_id
                for object_id, degree in indegree.items()
                if degree > 0
            )

            for object_id in cyclic:
                findings.append(
                    DependencyFinding(
                        dependency_id=None,
                        source_object_id=object_id,
                        target_object_id=object_id,
                        disposition=DependencyDisposition.CYCLIC,
                        message="Dependency cycle detected.",
                    )
                )

        valid = not any(
            finding.disposition
            in {
                DependencyDisposition.UNSATISFIED,
                DependencyDisposition.MISSING,
                DependencyDisposition.CYCLIC,
            }
            for finding in findings
        )

        return DependencyEvaluation(
            valid=valid,
            findings=tuple(findings),
            ordered_object_ids=tuple(ordered),
        )
