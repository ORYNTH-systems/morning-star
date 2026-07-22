"""Constitutional validation engine foundation."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from enum import StrEnum
from typing import Iterable
from uuid import UUID

from morning_star.models.canonical import (
    AuthorityRecord,
    CanonicalObject,
    DependencyRecord,
    EvidenceRecord,
    InterpretationRecord,
    ParticipationRecord,
    ProvenanceRecord,
    UncertaintyRecord,
)
from morning_star.models.enums import (
    AdmissionStatus,
    InterpretationClass,
    InitiationDecision,
    ObjectStatus,
    ParticipationRole,
)


class FindingSeverity(StrEnum):
    INFO = "INFO"
    MODERATE = "MODERATE"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class FindingDisposition(StrEnum):
    PASS = "PASS"
    BLOCK = "BLOCK"
    REVALIDATION_REQUIRED = "REVALIDATION_REQUIRED"
    RECONSTRUCTION_REQUIRED = "RECONSTRUCTION_REQUIRED"
    INADMISSIBLE = "INADMISSIBLE"
    UNRESOLVED = "UNRESOLVED"


@dataclass(frozen=True, slots=True)
class ValidationFinding:
    finding_id: str
    invariant_id: str
    subject_id: str
    severity: FindingSeverity
    disposition: FindingDisposition
    message: str


@dataclass(frozen=True, slots=True)
class ValidationResult:
    subject_id: str
    valid: bool
    findings: tuple[ValidationFinding, ...]


class ValidationEngine:
    """Evaluate foundational Morning Star constitutional invariants."""

    def validate_canonical_object(
        self,
        subject: CanonicalObject,
        *,
        authorities: dict[UUID, AuthorityRecord],
        provenances: dict[UUID, ProvenanceRecord],
        uncertainties: dict[UUID, UncertaintyRecord],
        dependencies: dict[UUID, DependencyRecord],
    ) -> ValidationResult:
        findings: list[ValidationFinding] = []
        subject_id = str(subject.object_id)

        if subject.authority_id is None or subject.authority_id not in authorities:
            findings.append(
                self._finding(
                    "MS-RUNTIME-FIND-0001",
                    "MS-INV-004",
                    subject_id,
                    FindingSeverity.CRITICAL,
                    FindingDisposition.BLOCK,
                    "Canonical object authority is absent or unresolved.",
                )
            )
        else:
            authority = authorities[subject.authority_id]

            if not authority.active:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0002",
                        "MS-INV-004",
                        subject_id,
                        FindingSeverity.CRITICAL,
                        FindingDisposition.INADMISSIBLE,
                        "Canonical object authority is inactive.",
                    )
                )

            if (
                authority.expires_at is not None
                and authority.expires_at <= datetime.now(timezone.utc)
            ):
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0003",
                        "MS-INV-010",
                        subject_id,
                        FindingSeverity.HIGH,
                        FindingDisposition.REVALIDATION_REQUIRED,
                        "Canonical object authority has expired.",
                    )
                )

        if subject.provenance_id is None or subject.provenance_id not in provenances:
            findings.append(
                self._finding(
                    "MS-RUNTIME-FIND-0004",
                    "MS-INV-005",
                    subject_id,
                    FindingSeverity.CRITICAL,
                    FindingDisposition.INADMISSIBLE,
                    "Canonical object provenance is absent or unresolved.",
                )
            )

        for dependency_id in subject.dependency_ids:
            dependency = dependencies.get(dependency_id)

            if dependency is None:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0005",
                        "MS-INV-003",
                        subject_id,
                        FindingSeverity.HIGH,
                        FindingDisposition.BLOCK,
                        f"Dependency {dependency_id} is missing.",
                    )
                )
                continue

            if dependency.mandatory and not dependency.satisfied:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0006",
                        "MS-INV-003",
                        subject_id,
                        FindingSeverity.HIGH,
                        FindingDisposition.BLOCK,
                        f"Mandatory dependency {dependency_id} is unsatisfied.",
                    )
                )

        for uncertainty_id in subject.uncertainty_ids:
            if uncertainty_id not in uncertainties:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0007",
                        "MS-INV-006",
                        subject_id,
                        FindingSeverity.HIGH,
                        FindingDisposition.UNRESOLVED,
                        f"Declared uncertainty {uncertainty_id} is missing.",
                    )
                )

        if subject.status in {ObjectStatus.SUPERSEDED, ObjectStatus.REVOKED}:
            findings.append(
                self._finding(
                    "MS-RUNTIME-FIND-0008",
                    "MS-INV-010",
                    subject_id,
                    FindingSeverity.HIGH,
                    FindingDisposition.REVALIDATION_REQUIRED,
                    f"Canonical object status is {subject.status}.",
                )
            )

        return self._result(subject_id, findings)

    def validate_interpretation(
        self,
        subject: InterpretationRecord,
        *,
        source_object: CanonicalObject | None,
        authorities: dict[UUID, AuthorityRecord],
        provenances: dict[UUID, ProvenanceRecord],
        uncertainties: dict[UUID, UncertaintyRecord],
    ) -> ValidationResult:
        findings: list[ValidationFinding] = []
        subject_id = str(subject.interpretation_id)

        if source_object is None:
            findings.append(
                self._finding(
                    "MS-RUNTIME-FIND-0101",
                    "MS-INV-001",
                    subject_id,
                    FindingSeverity.CRITICAL,
                    FindingDisposition.INADMISSIBLE,
                    "Interpretation source object is missing.",
                )
            )
        elif source_object.object_id != subject.interpreted_object_id:
            findings.append(
                self._finding(
                    "MS-RUNTIME-FIND-0102",
                    "MS-INV-001",
                    subject_id,
                    FindingSeverity.CRITICAL,
                    FindingDisposition.RECONSTRUCTION_REQUIRED,
                    "Interpretation source identity does not match.",
                )
            )

        if subject.provenance_id is None or subject.provenance_id not in provenances:
            findings.append(
                self._finding(
                    "MS-RUNTIME-FIND-0103",
                    "MS-INV-005",
                    subject_id,
                    FindingSeverity.CRITICAL,
                    FindingDisposition.INADMISSIBLE,
                    "Interpretation provenance is absent.",
                )
            )

        if subject.interpretation_class == InterpretationClass.CANONICAL:
            if subject.authority_id is None or subject.authority_id not in authorities:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0104",
                        "MS-INV-007",
                        subject_id,
                        FindingSeverity.CRITICAL,
                        FindingDisposition.INADMISSIBLE,
                        "Canonical interpretation lacks governing authority.",
                    )
                )

            if subject.admission_status != AdmissionStatus.ADMISSIBLE:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0105",
                        "MS-INV-007",
                        subject_id,
                        FindingSeverity.CRITICAL,
                        FindingDisposition.RECONSTRUCTION_REQUIRED,
                        "Canonical interpretation is not fully admissible.",
                    )
                )

        for uncertainty_id in subject.uncertainty_ids:
            uncertainty = uncertainties.get(uncertainty_id)

            if uncertainty is None:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0106",
                        "MS-INV-006",
                        subject_id,
                        FindingSeverity.HIGH,
                        FindingDisposition.UNRESOLVED,
                        f"Interpretation uncertainty {uncertainty_id} is missing.",
                    )
                )
            elif uncertainty.blocks_admission and (
                subject.admission_status == AdmissionStatus.ADMISSIBLE
            ):
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0107",
                        "MS-INV-006",
                        subject_id,
                        FindingSeverity.CRITICAL,
                        FindingDisposition.RECONSTRUCTION_REQUIRED,
                        "Interpretation is admitted despite blocking uncertainty.",
                    )
                )

        return self._result(subject_id, findings)

    def validate_participation(
        self,
        subject: ParticipationRecord,
        *,
        authorities: dict[UUID, AuthorityRecord],
        evidence: dict[UUID, EvidenceRecord],
        uncertainties: dict[UUID, UncertaintyRecord],
    ) -> ValidationResult:
        findings: list[ValidationFinding] = []
        subject_id = str(subject.participation_id)

        admitted = subject.decision in {
            InitiationDecision.ADMIT,
            InitiationDecision.ADMIT_WITH_LIMITS,
            InitiationDecision.ADMIT_PROVISIONALLY,
            InitiationDecision.RENEW,
        }

        if admitted:
            if subject.authority_id is None or subject.authority_id not in authorities:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0201",
                        "MS-INV-004",
                        subject_id,
                        FindingSeverity.CRITICAL,
                        FindingDisposition.BLOCK,
                        "Participation admission lacks active authority.",
                    )
                )

            if not subject.evidence_ids:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0202",
                        "MS-INV-008",
                        subject_id,
                        FindingSeverity.CRITICAL,
                        FindingDisposition.INADMISSIBLE,
                        "Participation admission has no evidence.",
                    )
                )

        for evidence_id in subject.evidence_ids:
            evidence_record = evidence.get(evidence_id)

            if evidence_record is None:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0203",
                        "MS-INV-008",
                        subject_id,
                        FindingSeverity.HIGH,
                        FindingDisposition.UNRESOLVED,
                        f"Participation evidence {evidence_id} is missing.",
                    )
                )
            elif not evidence_record.integrity_verified:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0204",
                        "MS-INV-008",
                        subject_id,
                        FindingSeverity.CRITICAL,
                        FindingDisposition.INADMISSIBLE,
                        f"Participation evidence {evidence_id} is unverified.",
                    )
                )

        if self._role_level(subject.admitted_role) > self._role_level(
            subject.requested_role
        ):
            findings.append(
                self._finding(
                    "MS-RUNTIME-FIND-0205",
                    "MS-INV-009",
                    subject_id,
                    FindingSeverity.CRITICAL,
                    FindingDisposition.RECONSTRUCTION_REQUIRED,
                    "Admitted role exceeds requested role.",
                )
            )

        for uncertainty_id in subject.uncertainty_ids:
            uncertainty = uncertainties.get(uncertainty_id)

            if uncertainty is None:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0206",
                        "MS-INV-006",
                        subject_id,
                        FindingSeverity.HIGH,
                        FindingDisposition.UNRESOLVED,
                        f"Participation uncertainty {uncertainty_id} is missing.",
                    )
                )
            elif uncertainty.blocks_admission and admitted:
                findings.append(
                    self._finding(
                        "MS-RUNTIME-FIND-0207",
                        "MS-INV-006",
                        subject_id,
                        FindingSeverity.CRITICAL,
                        FindingDisposition.BLOCK,
                        "Participation admitted despite blocking uncertainty.",
                    )
                )

        return self._result(subject_id, findings)

    @staticmethod
    def _finding(
        finding_id: str,
        invariant_id: str,
        subject_id: str,
        severity: FindingSeverity,
        disposition: FindingDisposition,
        message: str,
    ) -> ValidationFinding:
        return ValidationFinding(
            finding_id=finding_id,
            invariant_id=invariant_id,
            subject_id=subject_id,
            severity=severity,
            disposition=disposition,
            message=message,
        )

    @staticmethod
    def _result(
        subject_id: str,
        findings: Iterable[ValidationFinding],
    ) -> ValidationResult:
        finding_tuple = tuple(findings)

        blocking = {
            FindingDisposition.BLOCK,
            FindingDisposition.REVALIDATION_REQUIRED,
            FindingDisposition.RECONSTRUCTION_REQUIRED,
            FindingDisposition.INADMISSIBLE,
            FindingDisposition.UNRESOLVED,
        }

        valid = not any(
            finding.disposition in blocking
            for finding in finding_tuple
        )

        return ValidationResult(
            subject_id=subject_id,
            valid=valid,
            findings=finding_tuple,
        )

    @staticmethod
    def _role_level(role: ParticipationRole) -> int:
        return {
            ParticipationRole.PR0: 0,
            ParticipationRole.PR1: 1,
            ParticipationRole.PR2: 2,
            ParticipationRole.PR3: 3,
            ParticipationRole.PR4: 4,
            ParticipationRole.PR5: 5,
            ParticipationRole.PR6: 6,
        }[role]
