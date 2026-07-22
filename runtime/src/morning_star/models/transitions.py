"""Canonical state-transition definitions."""

from __future__ import annotations

from dataclasses import dataclass

from morning_star.models.enums import ConstitutionalState


@dataclass(frozen=True, slots=True)
class TransitionRule:
    transition_id: str
    prior_state: ConstitutionalState
    resulting_state: ConstitutionalState
    governing_volume: str
    authority_required: bool
    evidence_required: bool
    uncertainty_review_required: bool
    description: str

    def __post_init__(self) -> None:
        if not self.transition_id.strip():
            raise ValueError("transition_id must be non-empty.")

        if not self.governing_volume.strip():
            raise ValueError("governing_volume must be non-empty.")

        if not self.description.strip():
            raise ValueError("description must be non-empty.")

        if self.prior_state == self.resulting_state:
            raise ValueError("A transition rule must change state.")


CANONICAL_TRANSITIONS: tuple[TransitionRule, ...] = (
    TransitionRule(
        transition_id="MS-TR-001",
        prior_state=ConstitutionalState.UNENCOUNTERED,
        resulting_state=ConstitutionalState.ENCOUNTERED,
        governing_volume="MS-V3",
        authority_required=False,
        evidence_required=True,
        uncertainty_review_required=False,
        description="Record governed first encounter.",
    ),
    TransitionRule(
        transition_id="MS-TR-002",
        prior_state=ConstitutionalState.ENCOUNTERED,
        resulting_state=ConstitutionalState.IDENTIFIED,
        governing_volume="MS-V2",
        authority_required=False,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Resolve governed identity.",
    ),
    TransitionRule(
        transition_id="MS-TR-003",
        prior_state=ConstitutionalState.IDENTIFIED,
        resulting_state=ConstitutionalState.CONTEXTUALIZED,
        governing_volume="MS-V3",
        authority_required=False,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Establish framework context and scope.",
    ),
    TransitionRule(
        transition_id="MS-TR-004",
        prior_state=ConstitutionalState.CONTEXTUALIZED,
        resulting_state=ConstitutionalState.DEPENDENCY_RESOLVED,
        governing_volume="MS-V3",
        authority_required=False,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Resolve mandatory dependencies.",
    ),
    TransitionRule(
        transition_id="MS-TR-005",
        prior_state=ConstitutionalState.DEPENDENCY_RESOLVED,
        resulting_state=ConstitutionalState.INTERPRETED,
        governing_volume="MS-V4",
        authority_required=False,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Admit a classified interpretation.",
    ),
    TransitionRule(
        transition_id="MS-TR-006",
        prior_state=ConstitutionalState.INTERPRETED,
        resulting_state=ConstitutionalState.COMPETENCY_EVALUATED,
        governing_volume="MS-V5",
        authority_required=True,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Evaluate required competencies.",
    ),
    TransitionRule(
        transition_id="MS-TR-007",
        prior_state=ConstitutionalState.COMPETENCY_EVALUATED,
        resulting_state=ConstitutionalState.PARTICIPATION_ADMITTED,
        governing_volume="MS-V5",
        authority_required=True,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Admit bounded participation.",
    ),
    TransitionRule(
        transition_id="MS-TR-008",
        prior_state=ConstitutionalState.PARTICIPATION_ADMITTED,
        resulting_state=ConstitutionalState.PARTICIPATION_ACTIVE,
        governing_volume="MS-V5",
        authority_required=True,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Activate participation within declared scope.",
    ),
    TransitionRule(
        transition_id="MS-TR-009",
        prior_state=ConstitutionalState.PARTICIPATION_ACTIVE,
        resulting_state=ConstitutionalState.REVALIDATION_REQUIRED,
        governing_volume="MS-V1",
        authority_required=False,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Require revalidation after governing change.",
    ),
    TransitionRule(
        transition_id="MS-TR-010",
        prior_state=ConstitutionalState.PARTICIPATION_ACTIVE,
        resulting_state=ConstitutionalState.RECONSTRUCTION_REQUIRED,
        governing_volume="MS-V4",
        authority_required=False,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Require reconstruction after detected semantic drift.",
    ),
    TransitionRule(
        transition_id="MS-TR-011",
        prior_state=ConstitutionalState.PARTICIPATION_ACTIVE,
        resulting_state=ConstitutionalState.SUSPENDED,
        governing_volume="MS-V5",
        authority_required=True,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Suspend participation.",
    ),
    TransitionRule(
        transition_id="MS-TR-012",
        prior_state=ConstitutionalState.SUSPENDED,
        resulting_state=ConstitutionalState.PARTICIPATION_ACTIVE,
        governing_volume="MS-V5",
        authority_required=True,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Reinstate participation after review.",
    ),
    TransitionRule(
        transition_id="MS-TR-013",
        prior_state=ConstitutionalState.SUSPENDED,
        resulting_state=ConstitutionalState.REVOKED,
        governing_volume="MS-V5",
        authority_required=True,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Revoke participation.",
    ),
    TransitionRule(
        transition_id="MS-TR-014",
        prior_state=ConstitutionalState.REVALIDATION_REQUIRED,
        resulting_state=ConstitutionalState.PARTICIPATION_ACTIVE,
        governing_volume="MS-V5",
        authority_required=True,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Restore active participation after revalidation.",
    ),
    TransitionRule(
        transition_id="MS-TR-015",
        prior_state=ConstitutionalState.RECONSTRUCTION_REQUIRED,
        resulting_state=ConstitutionalState.INTERPRETED,
        governing_volume="MS-V4",
        authority_required=True,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Restore interpreted state after reconstruction.",
    ),
    TransitionRule(
        transition_id="MS-TR-016",
        prior_state=ConstitutionalState.PARTICIPATION_ACTIVE,
        resulting_state=ConstitutionalState.EXITED,
        governing_volume="MS-V3",
        authority_required=False,
        evidence_required=True,
        uncertainty_review_required=False,
        description="Record governed exit.",
    ),
    TransitionRule(
        transition_id="MS-TR-017",
        prior_state=ConstitutionalState.EXITED,
        resulting_state=ConstitutionalState.REVALIDATION_REQUIRED,
        governing_volume="MS-V3",
        authority_required=False,
        evidence_required=True,
        uncertainty_review_required=True,
        description="Require validation before re-entry.",
    ),
)


TRANSITION_RULES_BY_ID: dict[str, TransitionRule] = {
    rule.transition_id: rule
    for rule in CANONICAL_TRANSITIONS
}
