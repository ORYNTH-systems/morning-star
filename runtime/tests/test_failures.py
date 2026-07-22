"""Tests for runtime failure taxonomy."""

import pytest

from morning_star.models.failures import (
    FAILURE_CATALOG,
    FailureDisposition,
    FailureDomain,
    FailureSeverity,
    RuntimeFailure,
    failure_from_code,
)


def test_failure_catalog_codes_are_unique() -> None:
    assert len(FAILURE_CATALOG) == len(
        set(FAILURE_CATALOG)
    )


def test_failure_catalog_has_required_domains() -> None:
    domains = {
        failure.domain
        for failure in FAILURE_CATALOG.values()
    }

    assert FailureDomain.AUTHORITY in domains
    assert FailureDomain.EVIDENCE in domains
    assert FailureDomain.INTEGRITY in domains
    assert FailureDomain.CONFORMANCE in domains


def test_failure_from_code_returns_copy() -> None:
    failure = failure_from_code(
        "MS-FAIL-EVIDENCE-001",
        details={"record": "E-1"},
    )

    assert failure.code == "MS-FAIL-EVIDENCE-001"
    assert failure.details == {"record": "E-1"}


def test_unknown_failure_code_is_rejected() -> None:
    with pytest.raises(KeyError):
        failure_from_code("MS-FAIL-UNKNOWN-999")


def test_invalid_failure_code_prefix_is_rejected() -> None:
    with pytest.raises(ValueError):
        RuntimeFailure(
            code="INVALID",
            domain=FailureDomain.INTERNAL,
            severity=FailureSeverity.CRITICAL,
            disposition=FailureDisposition.HALT,
            message="Invalid.",
            recoverable=False,
            details={},
        )
