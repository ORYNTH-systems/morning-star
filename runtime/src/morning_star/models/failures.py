"""Canonical Morning Star runtime failure taxonomy."""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum
from typing import Any


class FailureDomain(StrEnum):
    IDENTITY = "IDENTITY"
    AUTHORITY = "AUTHORITY"
    EVIDENCE = "EVIDENCE"
    PROVENANCE = "PROVENANCE"
    UNCERTAINTY = "UNCERTAINTY"
    DEPENDENCY = "DEPENDENCY"
    INTERPRETATION = "INTERPRETATION"
    PARTICIPATION = "PARTICIPATION"
    TRANSITION = "TRANSITION"
    STORAGE = "STORAGE"
    INTEGRITY = "INTEGRITY"
    CONFIGURATION = "CONFIGURATION"
    ARCHITECTURE = "ARCHITECTURE"
    CONFORMANCE = "CONFORMANCE"
    INTERNAL = "INTERNAL"


class FailureSeverity(StrEnum):
    INFORMATIONAL = "INFORMATIONAL"
    LOW = "LOW"
    MODERATE = "MODERATE"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class FailureDisposition(StrEnum):
    CONTINUE = "CONTINUE"
    DEFER = "DEFER"
    REMEDIATE = "REMEDIATE"
    RECONSTRUCT = "RECONSTRUCT"
    SUSPEND = "SUSPEND"
    DENY = "DENY"
    HALT = "HALT"


@dataclass(frozen=True, slots=True)
class RuntimeFailure:
    code: str
    domain: FailureDomain
    severity: FailureSeverity
    disposition: FailureDisposition
    message: str
    recoverable: bool
    details: dict[str, Any]

    def __post_init__(self) -> None:
        if not self.code.startswith("MS-FAIL-"):
            raise ValueError(
                "Runtime failure codes must begin with MS-FAIL-."
            )

        if not self.message.strip():
            raise ValueError("Runtime failure message is required.")


FAILURE_CATALOG: dict[str, RuntimeFailure] = {
    "MS-FAIL-IDENTITY-001": RuntimeFailure(
        code="MS-FAIL-IDENTITY-001",
        domain=FailureDomain.IDENTITY,
        severity=FailureSeverity.HIGH,
        disposition=FailureDisposition.DEFER,
        message="Actor identity is unresolved.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-AUTHORITY-001": RuntimeFailure(
        code="MS-FAIL-AUTHORITY-001",
        domain=FailureDomain.AUTHORITY,
        severity=FailureSeverity.CRITICAL,
        disposition=FailureDisposition.DENY,
        message="Required authority is missing.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-AUTHORITY-002": RuntimeFailure(
        code="MS-FAIL-AUTHORITY-002",
        domain=FailureDomain.AUTHORITY,
        severity=FailureSeverity.CRITICAL,
        disposition=FailureDisposition.DENY,
        message="Authority is inactive or expired.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-EVIDENCE-001": RuntimeFailure(
        code="MS-FAIL-EVIDENCE-001",
        domain=FailureDomain.EVIDENCE,
        severity=FailureSeverity.HIGH,
        disposition=FailureDisposition.REMEDIATE,
        message="Required evidence is missing.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-EVIDENCE-002": RuntimeFailure(
        code="MS-FAIL-EVIDENCE-002",
        domain=FailureDomain.EVIDENCE,
        severity=FailureSeverity.HIGH,
        disposition=FailureDisposition.REMEDIATE,
        message="Evidence integrity is unverified.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-PROVENANCE-001": RuntimeFailure(
        code="MS-FAIL-PROVENANCE-001",
        domain=FailureDomain.PROVENANCE,
        severity=FailureSeverity.HIGH,
        disposition=FailureDisposition.RECONSTRUCT,
        message="Required provenance is missing.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-UNCERTAINTY-001": RuntimeFailure(
        code="MS-FAIL-UNCERTAINTY-001",
        domain=FailureDomain.UNCERTAINTY,
        severity=FailureSeverity.MODERATE,
        disposition=FailureDisposition.DEFER,
        message="Uncertainty remains unresolved.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-UNCERTAINTY-002": RuntimeFailure(
        code="MS-FAIL-UNCERTAINTY-002",
        domain=FailureDomain.UNCERTAINTY,
        severity=FailureSeverity.HIGH,
        disposition=FailureDisposition.RECONSTRUCT,
        message="Blocking uncertainty prevents admission.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-DEPENDENCY-001": RuntimeFailure(
        code="MS-FAIL-DEPENDENCY-001",
        domain=FailureDomain.DEPENDENCY,
        severity=FailureSeverity.HIGH,
        disposition=FailureDisposition.DEFER,
        message="Mandatory dependency is unsatisfied.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-DEPENDENCY-002": RuntimeFailure(
        code="MS-FAIL-DEPENDENCY-002",
        domain=FailureDomain.DEPENDENCY,
        severity=FailureSeverity.CRITICAL,
        disposition=FailureDisposition.HALT,
        message="Dependency cycle detected.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-INTERPRETATION-001": RuntimeFailure(
        code="MS-FAIL-INTERPRETATION-001",
        domain=FailureDomain.INTERPRETATION,
        severity=FailureSeverity.HIGH,
        disposition=FailureDisposition.RECONSTRUCT,
        message="Interpretation is inadmissible.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-INTERPRETATION-002": RuntimeFailure(
        code="MS-FAIL-INTERPRETATION-002",
        domain=FailureDomain.INTERPRETATION,
        severity=FailureSeverity.CRITICAL,
        disposition=FailureDisposition.RECONSTRUCT,
        message="Interpretation source identity does not match.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-PARTICIPATION-001": RuntimeFailure(
        code="MS-FAIL-PARTICIPATION-001",
        domain=FailureDomain.PARTICIPATION,
        severity=FailureSeverity.HIGH,
        disposition=FailureDisposition.DENY,
        message="Participation role exceeds admitted scope.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-TRANSITION-001": RuntimeFailure(
        code="MS-FAIL-TRANSITION-001",
        domain=FailureDomain.TRANSITION,
        severity=FailureSeverity.HIGH,
        disposition=FailureDisposition.DENY,
        message="Requested transition is constitutionally inadmissible.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-STORAGE-001": RuntimeFailure(
        code="MS-FAIL-STORAGE-001",
        domain=FailureDomain.STORAGE,
        severity=FailureSeverity.CRITICAL,
        disposition=FailureDisposition.HALT,
        message="Persistent storage operation failed.",
        recoverable=False,
        details={},
    ),
    "MS-FAIL-INTEGRITY-001": RuntimeFailure(
        code="MS-FAIL-INTEGRITY-001",
        domain=FailureDomain.INTEGRITY,
        severity=FailureSeverity.CRITICAL,
        disposition=FailureDisposition.HALT,
        message="Runtime payload integrity verification failed.",
        recoverable=False,
        details={},
    ),
    "MS-FAIL-INTEGRITY-002": RuntimeFailure(
        code="MS-FAIL-INTEGRITY-002",
        domain=FailureDomain.INTEGRITY,
        severity=FailureSeverity.CRITICAL,
        disposition=FailureDisposition.HALT,
        message="Runtime trace-chain verification failed.",
        recoverable=False,
        details={},
    ),
    "MS-FAIL-CONFIGURATION-001": RuntimeFailure(
        code="MS-FAIL-CONFIGURATION-001",
        domain=FailureDomain.CONFIGURATION,
        severity=FailureSeverity.CRITICAL,
        disposition=FailureDisposition.HALT,
        message="Runtime configuration is invalid.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-ARCHITECTURE-001": RuntimeFailure(
        code="MS-FAIL-ARCHITECTURE-001",
        domain=FailureDomain.ARCHITECTURE,
        severity=FailureSeverity.CRITICAL,
        disposition=FailureDisposition.HALT,
        message="Architecture manifest is missing or invalid.",
        recoverable=True,
        details={},
    ),
    "MS-FAIL-CONFORMANCE-001": RuntimeFailure(
        code="MS-FAIL-CONFORMANCE-001",
        domain=FailureDomain.CONFORMANCE,
        severity=FailureSeverity.CRITICAL,
        disposition=FailureDisposition.HALT,
        message="Runtime conformance validation failed.",
        recoverable=True,
        details={},
    ),
}


def failure_from_code(
    code: str,
    *,
    message: str | None = None,
    details: dict[str, Any] | None = None,
) -> RuntimeFailure:
    try:
        template = FAILURE_CATALOG[code]
    except KeyError as exc:
        raise KeyError(f"Unknown runtime failure code: {code}") from exc

    return RuntimeFailure(
        code=template.code,
        domain=template.domain,
        severity=template.severity,
        disposition=template.disposition,
        message=message or template.message,
        recoverable=template.recoverable,
        details=details or {},
    )
