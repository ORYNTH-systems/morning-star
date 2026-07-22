"""Deterministic Morning Star state-transition engine."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from uuid import UUID, uuid4

from morning_star.models.canonical import ConstitutionalTrace, utc_now
from morning_star.models.enums import ConstitutionalState
from morning_star.models.transitions import (
    TRANSITION_RULES_BY_ID,
    TransitionRule,
)


class TransitionRejectedError(ValueError):
    """Raised when a requested transition is constitutionally inadmissible."""


@dataclass(frozen=True, slots=True)
class TransitionRequest:
    request_id: UUID = field(default_factory=uuid4)
    transition_id: str = ""
    actor_id: UUID | None = None
    object_id: UUID | None = None
    current_state: ConstitutionalState = ConstitutionalState.UNENCOUNTERED
    authority_id: UUID | None = None
    evidence_ids: tuple[UUID, ...] = ()
    uncertainty_ids: tuple[UUID, ...] = ()
    requested_at: datetime = field(default_factory=utc_now)

    def __post_init__(self) -> None:
        if not self.transition_id.strip():
            raise ValueError("transition_id must be non-empty.")


@dataclass(frozen=True, slots=True)
class TransitionDecision:
    request_id: UUID
    transition_id: str
    accepted: bool
    prior_state: ConstitutionalState
    resulting_state: ConstitutionalState
    reason_codes: tuple[str, ...]
    trace: ConstitutionalTrace | None
    decided_at: datetime = field(default_factory=utc_now)


class StateTransitionEngine:
    """Evaluate and execute canonical Morning Star state transitions."""

    def evaluate(
        self,
        request: TransitionRequest,
    ) -> TransitionDecision:
        rule = self._get_rule(request.transition_id)
        reasons: list[str] = []

        if request.current_state != rule.prior_state:
            reasons.append("PRIOR_STATE_MISMATCH")

        if rule.authority_required and request.authority_id is None:
            reasons.append("AUTHORITY_REQUIRED")

        if rule.evidence_required and not request.evidence_ids:
            reasons.append("EVIDENCE_REQUIRED")

        if (
            rule.uncertainty_review_required
            and request.uncertainty_ids
            and request.authority_id is None
        ):
            reasons.append("UNCERTAINTY_REVIEW_AUTHORITY_REQUIRED")

        accepted = not reasons

        trace = None

        if accepted:
            trace = ConstitutionalTrace(
                actor_id=request.actor_id,
                object_id=request.object_id,
                prior_state=rule.prior_state,
                resulting_state=rule.resulting_state,
                transition_id=rule.transition_id,
                authority_id=request.authority_id,
                evidence_ids=request.evidence_ids,
                uncertainty_ids=request.uncertainty_ids,
            )

        return TransitionDecision(
            request_id=request.request_id,
            transition_id=rule.transition_id,
            accepted=accepted,
            prior_state=request.current_state,
            resulting_state=(
                rule.resulting_state
                if accepted
                else request.current_state
            ),
            reason_codes=tuple(reasons),
            trace=trace,
        )

    def execute(
        self,
        request: TransitionRequest,
    ) -> ConstitutionalTrace:
        decision = self.evaluate(request)

        if not decision.accepted or decision.trace is None:
            reason_text = ", ".join(decision.reason_codes)

            raise TransitionRejectedError(
                f"Transition {request.transition_id} rejected: {reason_text}"
            )

        return decision.trace

    @staticmethod
    def _get_rule(transition_id: str) -> TransitionRule:
        try:
            return TRANSITION_RULES_BY_ID[transition_id]
        except KeyError as exc:
            raise TransitionRejectedError(
                f"Unknown transition rule: {transition_id}"
            ) from exc
