"""Tests for governed navigation decisions."""

from morning_star.engines.navigation import (
    NavigationDecisionEngine,
    NavigationDecisionType,
    NavigationRequest,
)
from morning_star.models.enums import ConstitutionalState


def test_first_encounter_proceeds() -> None:
    engine = NavigationDecisionEngine()

    decision = engine.decide(
        NavigationRequest(
            current_state=ConstitutionalState.UNENCOUNTERED,
            target_state=ConstitutionalState.ENCOUNTERED,
        )
    )

    assert decision.decision == NavigationDecisionType.PROCEED
    assert decision.next_state == ConstitutionalState.ENCOUNTERED


def test_unresolved_identity_blocks_navigation() -> None:
    engine = NavigationDecisionEngine()

    decision = engine.decide(
        NavigationRequest(
            current_state=ConstitutionalState.ENCOUNTERED,
            target_state=ConstitutionalState.IDENTIFIED,
            identity_resolved=False,
        )
    )

    assert (
        decision.decision
        == NavigationDecisionType.REQUIRE_CONTEXT
    )


def test_unresolved_dependencies_block_navigation() -> None:
    engine = NavigationDecisionEngine()

    decision = engine.decide(
        NavigationRequest(
            current_state=ConstitutionalState.CONTEXTUALIZED,
            target_state=ConstitutionalState.DEPENDENCY_RESOLVED,
            identity_resolved=True,
            context_resolved=True,
            dependencies_resolved=False,
        )
    )

    assert (
        decision.decision
        == NavigationDecisionType.REQUIRE_DEPENDENCY_RESOLUTION
    )


def test_out_of_sequence_target_is_redirected() -> None:
    engine = NavigationDecisionEngine()

    decision = engine.decide(
        NavigationRequest(
            current_state=ConstitutionalState.IDENTIFIED,
            target_state=ConstitutionalState.INTERPRETED,
            identity_resolved=True,
            context_resolved=True,
        )
    )

    assert decision.decision == NavigationDecisionType.REDIRECT
    assert decision.next_state == ConstitutionalState.CONTEXTUALIZED


def test_admissible_interpretation_allows_progress() -> None:
    engine = NavigationDecisionEngine()

    decision = engine.decide(
        NavigationRequest(
            current_state=ConstitutionalState.DEPENDENCY_RESOLVED,
            target_state=ConstitutionalState.INTERPRETED,
            identity_resolved=True,
            context_resolved=True,
            dependencies_resolved=True,
            interpretation_admissible=True,
        )
    )

    assert decision.decision == NavigationDecisionType.PROCEED
    assert decision.next_state == ConstitutionalState.INTERPRETED
