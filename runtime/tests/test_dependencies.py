"""Tests for dependency graph evaluation."""

from morning_star.engines.dependencies import (
    DependencyDisposition,
    DependencyGraphEngine,
)
from morning_star.models.canonical import DependencyRecord


def test_dependency_graph_orders_objects() -> None:
    engine = DependencyGraphEngine()

    dependencies = (
        DependencyRecord(
            source_object_id="A",
            target_object_id="B",
            relationship_type="PRECEDES",
            satisfied=True,
        ),
        DependencyRecord(
            source_object_id="B",
            target_object_id="C",
            relationship_type="PRECEDES",
            satisfied=True,
        ),
    )

    result = engine.evaluate(
        dependencies,
        known_object_ids={"A", "B", "C"},
    )

    assert result.valid is True
    assert result.ordered_object_ids == ("A", "B", "C")


def test_unsatisfied_dependency_fails() -> None:
    engine = DependencyGraphEngine()

    dependency = DependencyRecord(
        source_object_id="A",
        target_object_id="B",
        relationship_type="PRECEDES",
        mandatory=True,
        satisfied=False,
    )

    result = engine.evaluate(
        (dependency,),
        known_object_ids={"A", "B"},
    )

    assert result.valid is False
    assert any(
        finding.disposition
        == DependencyDisposition.UNSATISFIED
        for finding in result.findings
    )


def test_missing_dependency_target_fails() -> None:
    engine = DependencyGraphEngine()

    dependency = DependencyRecord(
        source_object_id="A",
        target_object_id="B",
        relationship_type="PRECEDES",
        satisfied=True,
    )

    result = engine.evaluate(
        (dependency,),
        known_object_ids={"A"},
    )

    assert result.valid is False
    assert any(
        finding.disposition == DependencyDisposition.MISSING
        for finding in result.findings
    )


def test_dependency_cycle_is_detected() -> None:
    engine = DependencyGraphEngine()

    dependencies = (
        DependencyRecord(
            source_object_id="A",
            target_object_id="B",
            relationship_type="PRECEDES",
            satisfied=True,
        ),
        DependencyRecord(
            source_object_id="B",
            target_object_id="A",
            relationship_type="PRECEDES",
            satisfied=True,
        ),
    )

    result = engine.evaluate(
        dependencies,
        known_object_ids={"A", "B"},
    )

    assert result.valid is False
    assert any(
        finding.disposition == DependencyDisposition.CYCLIC
        for finding in result.findings
    )
