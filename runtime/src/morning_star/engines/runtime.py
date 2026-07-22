"""Integrated Morning Star runtime orchestration."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from uuid import UUID

from morning_star.engines.dependencies import (
    DependencyEvaluation,
    DependencyGraphEngine,
)
from morning_star.engines.initiation import (
    InitiationDecisionEngine,
    InitiationEvaluation,
)
from morning_star.engines.interpretation import (
    InterpretationAdmissionEngine,
    InterpretationDecision,
)
from morning_star.engines.navigation import (
    NavigationDecision,
    NavigationDecisionEngine,
    NavigationRequest,
)
from morning_star.engines.transitions import (
    StateTransitionEngine,
    TransitionRequest,
)
from morning_star.models.canonical import (
    AuthorityRecord,
    CanonicalObject,
    ConstitutionalTrace,
    DependencyRecord,
    EvidenceRecord,
    InterpretationRecord,
    ParticipationRecord,
    UncertaintyRecord,
)
from morning_star.models.envelopes import RuntimeEnvelope
from morning_star.registries.persistent_trace import (
    PersistentTraceLedger,
)
from morning_star.registries.repository import RuntimeRepository
from morning_star.registries.transaction import RuntimeTransaction


@dataclass(frozen=True, slots=True)
class RuntimeOrchestrator:
    repository: RuntimeRepository
    trace_ledger: PersistentTraceLedger

    def persist_records(
        self,
        records: tuple[tuple[str, object], ...],
    ) -> tuple[Path, ...]:
        transaction = RuntimeTransaction(self.repository)

        for object_type, record in records:
            transaction.stage(
                RuntimeEnvelope.from_object(
                    record,
                    object_type=object_type,
                )
            )

        return transaction.commit()

    def evaluate_dependencies(
        self,
        dependencies: tuple[DependencyRecord, ...],
        *,
        known_object_ids: set[str],
    ) -> DependencyEvaluation:
        return DependencyGraphEngine().evaluate(
            dependencies,
            known_object_ids=known_object_ids,
        )

    def decide_navigation(
        self,
        request: NavigationRequest,
    ) -> NavigationDecision:
        return NavigationDecisionEngine().decide(request)

    def decide_interpretation(
        self,
        interpretation: InterpretationRecord,
        *,
        source_object: CanonicalObject | None,
        uncertainties: dict[object, UncertaintyRecord],
    ) -> InterpretationDecision:
        return InterpretationAdmissionEngine().decide(
            interpretation,
            source_object=source_object,
            uncertainties=uncertainties,
        )

    def decide_initiation(
        self,
        participation: ParticipationRecord,
        *,
        authorities: dict[UUID, AuthorityRecord],
        evidence: dict[UUID, EvidenceRecord],
        uncertainties: dict[UUID, UncertaintyRecord],
    ) -> InitiationEvaluation:
        return InitiationDecisionEngine().decide(
            participation,
            authorities=authorities,
            evidence=evidence,
            uncertainties=uncertainties,
        )

    def execute_transition(
        self,
        request: TransitionRequest,
    ) -> ConstitutionalTrace:
        trace = StateTransitionEngine().execute(request)
        self.trace_ledger.append(trace)

        return trace
