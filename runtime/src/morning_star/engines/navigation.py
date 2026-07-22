"""Governed navigation decision engine."""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import StrEnum
from uuid import UUID, uuid4

from morning_star.models.canonical import utc_now
from morning_star.models.enums import ConstitutionalState


class NavigationDecisionType(StrEnum):
    PROCEED = "PROCEED"
    DEFER = "DEFER"
    REDIRECT = "REDIRECT"
    REQUIRE_CONTEXT = "REQUIRE_CONTEXT"
    REQUIRE_DEPENDENCY_RESOLUTION = "REQUIRE_DEPENDENCY_RESOLUTION"
    REQUIRE_RECONSTRUCTION = "REQUIRE_RECONSTRUCTION"
    DENY = "DENY"


@dataclass(frozen=True, slots=True)
class NavigationRequest:
    request_id: UUID = field(default_factory=uuid4)
    actor_id: UUID | None = None
    object_id: UUID | None = None
    current_state: ConstitutionalState = ConstitutionalState.UNENCOUNTERED
    target_state: ConstitutionalState = ConstitutionalState.ENCOUNTERED
    identity_resolved: bool = False
    context_resolved: bool = False
    dependencies_resolved: bool = False
    interpretation_admissible: bool = False
    competency_evaluated: bool = False
    requested_at: object = field(default_factory=utc_now)


@dataclass(frozen=True, slots=True)
class NavigationDecision:
    request_id: UUID
    decision: NavigationDecisionType
    next_state: ConstitutionalState
    reason_codes: tuple[str, ...]


class NavigationDecisionEngine:
    """Determine the next constitutionally admissible navigation state."""

    def decide(
        self,
        request: NavigationRequest,
    ) -> NavigationDecision:
        reasons: list[str] = []

        if request.current_state == ConstitutionalState.UNENCOUNTERED:
            return NavigationDecision(
                request_id=request.request_id,
                decision=NavigationDecisionType.PROCEED,
                next_state=ConstitutionalState.ENCOUNTERED,
                reason_codes=(),
            )

        if (
            request.current_state == ConstitutionalState.ENCOUNTERED
            and not request.identity_resolved
        ):
            reasons.append("IDENTITY_UNRESOLVED")

            return NavigationDecision(
                request_id=request.request_id,
                decision=NavigationDecisionType.REQUIRE_CONTEXT,
                next_state=ConstitutionalState.ENCOUNTERED,
                reason_codes=tuple(reasons),
            )

        if (
            request.current_state == ConstitutionalState.IDENTIFIED
            and not request.context_resolved
        ):
            reasons.append("CONTEXT_UNRESOLVED")

            return NavigationDecision(
                request_id=request.request_id,
                decision=NavigationDecisionType.REQUIRE_CONTEXT,
                next_state=ConstitutionalState.IDENTIFIED,
                reason_codes=tuple(reasons),
            )

        if (
            request.current_state == ConstitutionalState.CONTEXTUALIZED
            and not request.dependencies_resolved
        ):
            reasons.append("DEPENDENCIES_UNRESOLVED")

            return NavigationDecision(
                request_id=request.request_id,
                decision=(
                    NavigationDecisionType
                    .REQUIRE_DEPENDENCY_RESOLUTION
                ),
                next_state=ConstitutionalState.CONTEXTUALIZED,
                reason_codes=tuple(reasons),
            )

        if (
            request.current_state
            == ConstitutionalState.DEPENDENCY_RESOLVED
            and not request.interpretation_admissible
        ):
            reasons.append("INTERPRETATION_NOT_ADMISSIBLE")

            return NavigationDecision(
                request_id=request.request_id,
                decision=(
                    NavigationDecisionType.REQUIRE_RECONSTRUCTION
                ),
                next_state=ConstitutionalState.DEPENDENCY_RESOLVED,
                reason_codes=tuple(reasons),
            )

        if (
            request.current_state == ConstitutionalState.INTERPRETED
            and not request.competency_evaluated
        ):
            reasons.append("COMPETENCY_NOT_EVALUATED")

            return NavigationDecision(
                request_id=request.request_id,
                decision=NavigationDecisionType.DEFER,
                next_state=ConstitutionalState.INTERPRETED,
                reason_codes=tuple(reasons),
            )

        allowed_targets: dict[
            ConstitutionalState,
            ConstitutionalState,
        ] = {
            ConstitutionalState.ENCOUNTERED:
                ConstitutionalState.IDENTIFIED,
            ConstitutionalState.IDENTIFIED:
                ConstitutionalState.CONTEXTUALIZED,
            ConstitutionalState.CONTEXTUALIZED:
                ConstitutionalState.DEPENDENCY_RESOLVED,
            ConstitutionalState.DEPENDENCY_RESOLVED:
                ConstitutionalState.INTERPRETED,
            ConstitutionalState.INTERPRETED:
                ConstitutionalState.COMPETENCY_EVALUATED,
            ConstitutionalState.COMPETENCY_EVALUATED:
                ConstitutionalState.PARTICIPATION_ADMITTED,
            ConstitutionalState.PARTICIPATION_ADMITTED:
                ConstitutionalState.PARTICIPATION_ACTIVE,
        }

        expected = allowed_targets.get(request.current_state)

        if expected is None:
            return NavigationDecision(
                request_id=request.request_id,
                decision=NavigationDecisionType.DENY,
                next_state=request.current_state,
                reason_codes=("NO_STANDARD_FORWARD_PATH",),
            )

        if request.target_state != expected:
            return NavigationDecision(
                request_id=request.request_id,
                decision=NavigationDecisionType.REDIRECT,
                next_state=expected,
                reason_codes=("TARGET_STATE_OUT_OF_SEQUENCE",),
            )

        return NavigationDecision(
            request_id=request.request_id,
            decision=NavigationDecisionType.PROCEED,
            next_state=expected,
            reason_codes=(),
        )
