"""Interpretation classification and admission engine."""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum

from morning_star.models.canonical import (
    CanonicalObject,
    InterpretationRecord,
    UncertaintyRecord,
)
from morning_star.models.enums import (
    AdmissionStatus,
    InterpretationClass,
)


class InterpretationDecisionType(StrEnum):
    ADMIT = "ADMIT"
    ADMIT_WITH_LIMITS = "ADMIT_WITH_LIMITS"
    ADMIT_WITH_UNCERTAINTY = "ADMIT_WITH_UNCERTAINTY"
    REQUIRE_RECONSTRUCTION = "REQUIRE_RECONSTRUCTION"
    REJECT = "REJECT"


@dataclass(frozen=True, slots=True)
class InterpretationDecision:
    decision: InterpretationDecisionType
    admission_status: AdmissionStatus
    reason_codes: tuple[str, ...]


class InterpretationAdmissionEngine:
    """Determine whether an interpretation is constitutionally admissible."""

    def decide(
        self,
        interpretation: InterpretationRecord,
        *,
        source_object: CanonicalObject | None,
        uncertainties: dict[object, UncertaintyRecord],
    ) -> InterpretationDecision:
        reasons: list[str] = []

        if source_object is None:
            return InterpretationDecision(
                decision=InterpretationDecisionType.REJECT,
                admission_status=AdmissionStatus.INADMISSIBLE,
                reason_codes=("SOURCE_OBJECT_MISSING",),
            )

        if (
            source_object.object_id
            != interpretation.interpreted_object_id
        ):
            return InterpretationDecision(
                decision=(
                    InterpretationDecisionType
                    .REQUIRE_RECONSTRUCTION
                ),
                admission_status=(
                    AdmissionStatus.RECONSTRUCTION_REQUIRED
                ),
                reason_codes=("SOURCE_IDENTITY_MISMATCH",),
            )

        if not interpretation.source_basis:
            return InterpretationDecision(
                decision=InterpretationDecisionType.REJECT,
                admission_status=AdmissionStatus.INADMISSIBLE,
                reason_codes=("SOURCE_BASIS_MISSING",),
            )

        blocking_uncertainty = False
        unresolved_uncertainty = False

        for uncertainty_id in interpretation.uncertainty_ids:
            uncertainty = uncertainties.get(uncertainty_id)

            if uncertainty is None:
                unresolved_uncertainty = True
                reasons.append("UNCERTAINTY_RECORD_MISSING")
                continue

            if uncertainty.blocks_admission:
                blocking_uncertainty = True
                reasons.append("BLOCKING_UNCERTAINTY")

        if blocking_uncertainty:
            return InterpretationDecision(
                decision=(
                    InterpretationDecisionType
                    .REQUIRE_RECONSTRUCTION
                ),
                admission_status=(
                    AdmissionStatus.RECONSTRUCTION_REQUIRED
                ),
                reason_codes=tuple(reasons),
            )

        if unresolved_uncertainty:
            return InterpretationDecision(
                decision=(
                    InterpretationDecisionType
                    .ADMIT_WITH_UNCERTAINTY
                ),
                admission_status=(
                    AdmissionStatus.ADMISSIBLE_WITH_UNCERTAINTY
                ),
                reason_codes=tuple(reasons),
            )

        limited_classes = {
            InterpretationClass.ANALOGICAL,
            InterpretationClass.COMPARATIVE,
            InterpretationClass.EDUCATIONAL,
            InterpretationClass.OPERATIONAL,
            InterpretationClass.SPECULATIVE,
            InterpretationClass.TRANSLATIONAL,
        }

        inadmissible_classes = {
            InterpretationClass.CONFLICTING,
            InterpretationClass.INADMISSIBLE,
            InterpretationClass.UNRESOLVED,
        }

        if interpretation.interpretation_class in inadmissible_classes:
            return InterpretationDecision(
                decision=InterpretationDecisionType.REJECT,
                admission_status=AdmissionStatus.INADMISSIBLE,
                reason_codes=("INTERPRETATION_CLASS_INADMISSIBLE",),
            )

        if interpretation.interpretation_class in limited_classes:
            return InterpretationDecision(
                decision=(
                    InterpretationDecisionType
                    .ADMIT_WITH_LIMITS
                ),
                admission_status=(
                    AdmissionStatus.ADMISSIBLE_WITH_LIMITS
                ),
                reason_codes=("INTERPRETATION_SCOPE_LIMITED",),
            )

        return InterpretationDecision(
            decision=InterpretationDecisionType.ADMIT,
            admission_status=AdmissionStatus.ADMISSIBLE,
            reason_codes=(),
        )
