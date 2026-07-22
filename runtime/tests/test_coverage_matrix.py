"""Tests for architecture-to-runtime coverage."""

import csv
from pathlib import Path


def test_coverage_matrix_is_complete() -> None:
    runtime_root = Path(__file__).resolve().parents[1]

    path = (
        runtime_root
        / "coverage"
        / "ARCHITECTURE_RUNTIME_COVERAGE_MATRIX.csv"
    )

    with path.open(
        "r",
        encoding="utf-8-sig",
        newline="",
    ) as handle:
        rows = tuple(csv.DictReader(handle))

    assert len(rows) >= 20

    identifiers = [
        row["RequirementID"]
        for row in rows
    ]

    assert len(identifiers) == len(set(identifiers))

    assert all(
        row["CoverageStatus"] == "COVERED"
        for row in rows
    )

    assert all(
        row["RuntimeComponent"].strip()
        for row in rows
    )

    assert all(
        row["VerificationArtifact"].strip()
        for row in rows
    )
