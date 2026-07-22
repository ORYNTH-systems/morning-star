"""Participation initiation decision engine."""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum
from uuid import UUID

from morning_star.models.canonical import (
    AuthorityRecord,
    EvidenceRecord,
    ParticipationRecord,
    UncertaintyRecord,
)
from morning_star.models.enums import InitiationDecision


class InitiationDisposition(StrEnum):
    ADMITTED = "ADMITTED"
    ADMITTED_WITH_LIMITS = "ADMITTED_WITH_LIMITS"
    PROVISIONAL = "PROVISIONAL"
    DEFERRED = "DEFERRED"
    REMEDIATION_REQUIRED = "REMEDIATION_REQUIRED"
    DENIED = "DENIED"


@dataclass(frozen=True, slots=True)
class InitiationEvaluation:
    disposition: InitiationDisposition
    decision: InitiationDecision
    reason_codes: tuple[str, ...]


class InitiationDecisionEngine:
    """Evaluate evidence, authority, uncertainty, and role bounds."""

    def decide(
        self,
        participation: ParticipationRecord,
        *,
        authorities: dict[UUID, AuthorityRecord],
        evidence: dict[UUID, EvidenceRecord],
        uncertainties: dict[UUID, UncertaintyRecord],
    ) -> InitiationEvaluation:
        reasons: list[str] = []

        authority = (
            authorities.get(participation.authority_id)
            if participation.authority_id is not None
            else None
        )

        if authority is None:
            return InitiationEvaluation(
                disposition=InitiationDisposition.DENIED,
                decision=InitiationDecision.DENY,
                reason_codes=("AUTHORITY_MISSING",),
            )

        if not authority.active:
            return InitiationEvaluation(
                disposition=InitiationDisposition.DENIED,
                decision=InitiationDecision.DENY,
                reason_codes=("AUTHORITY_INACTIVE",),
            )

        role_levels = {
            "PR0": 0,
            "PR1": 1,
            "PR2": 2,
            "PR3": 3,
            "PR4": 4,
            "PR5": 5,
            "PR6": 6,
        }

        requested_level = role_levels[
            participation.requested_role.value
        ]

        admitted_level = role_levels[
            participation.admitted_role.value
        ]

        if admitted_level > requested_level:
            return InitiationEvaluation(
                disposition=(
                    InitiationDisposition.REMEDIATION_REQUIRED
                ),
                decision=InitiationDecision.REQUIRE_REASSESSMENT,
                reason_codes=("ADMITTED_ROLE_EXCEEDS_REQUEST",),
            )

        if not participation.evidence_ids:
            return InitiationEvaluation(
                disposition=InitiationDisposition.DEFERRED,
                decision=InitiationDecision.DEFER,
                reason_codes=("EVIDENCE_MISSING",),
            )

        for evidence_id in participation.evidence_ids:
            record = evidence.get(evidence_id)

            if record is None:
                reasons.append("EVIDENCE_RECORD_MISSING")
                continue

            if not record.integrity_verified:
                reasons.append("EVIDENCE_NOT_VERIFIED")

        if reasons:
            return InitiationEvaluation(
                disposition=(
                    InitiationDisposition.REMEDIATION_REQUIRED
                ),
                decision=InitiationDecision.REQUIRE_REMEDIATION,
                reason_codes=tuple(sorted(set(reasons))),
            )

        blocking_uncertainty = False
        unresolved_uncertainty = False

        for uncertainty_id in participation.uncertainty_ids:
            uncertainty = uncertainties.get(uncertainty_id)

            if uncertainty is None:
                unresolved_uncertainty = True
                continue

            if uncertainty.blocks_admission:
                blocking_uncertainty = True

        if blocking_uncertainty:
            return InitiationEvaluation(
                disposition=(
                    InitiationDisposition.REMEDIATION_REQUIRED
                ),
                decision=InitiationDecision.REQUIRE_REMEDIATION,
                reason_codes=("BLOCKING_UNCERTAINTY",),
            )

        if unresolved_uncertainty:
            return InitiationEvaluation(
                disposition=InitiationDisposition.PROVISIONAL,
                decision=InitiationDecision.ADMIT_PROVISIONALLY,
                reason_codes=("UNCERTAINTY_UNRESOLVED",),
            )

        if admitted_level < requested_level:
            return InitiationEvaluation(
                disposition=(
                    InitiationDisposition.ADMITTED_WITH_LIMITS
                ),
                decision=InitiationDecision.ADMIT_WITH_LIMITS,
                reason_codes=("ROLE_SCOPE_LIMITED",),
            )

        return InitiationEvaluation(
            disposition=InitiationDisposition.ADMITTED,
            decision=InitiationDecision.ADMIT,
            reason_codes=(),
        )
