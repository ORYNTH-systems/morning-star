"""Public application service API for Morning Star runtime."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any
from uuid import UUID

from morning_star.config.runtime import RuntimeConfiguration
from morning_star.engines.manifest import ArchitectureManifest
from morning_star.engines.registry_ingestion import ConstitutionalRegistry
from morning_star.engines.runtime import RuntimeOrchestrator
from morning_star.engines.transitions import TransitionRequest
from morning_star.models.canonical import (
    AuthorityRecord,
    CanonicalObject,
    DependencyRecord,
    EvidenceRecord,
    InterpretationRecord,
    ParticipationRecord,
    UncertaintyRecord,
)
from morning_star.models.failures import (
    RuntimeFailure,
    failure_from_code,
)
from morning_star.models.serialization import canonical_dict
from morning_star.models.snapshot import RuntimeSnapshot
from morning_star.registries.persistent_trace import (
    PersistentTraceLedger,
)
from morning_star.registries.repository import RuntimeRepository


@dataclass(frozen=True, slots=True)
class ApiResult:
    success: bool
    operation: str
    data: dict[str, Any]
    failures: tuple[RuntimeFailure, ...] = ()


class MorningStarRuntimeApi:
    """Stable public API over the constitutional runtime."""

    def __init__(
        self,
        configuration: RuntimeConfiguration,
    ) -> None:
        self.configuration = configuration
        self.repository = RuntimeRepository(
            configuration.repository_path
        )
        self.trace_ledger = PersistentTraceLedger(
            configuration.trace_ledger_path
        )
        self.orchestrator = RuntimeOrchestrator(
            repository=self.repository,
            trace_ledger=self.trace_ledger,
        )

    def validate_environment(self) -> ApiResult:
        failures: list[RuntimeFailure] = []

        try:
            self.configuration.verify_required_sources()

            manifest = ArchitectureManifest.load(
                self.configuration.architecture_manifest_path
            )

            invariants = ConstitutionalRegistry.load(
                self.configuration.invariant_registry_path,
                identifier_column="InvariantID",
            )

            transitions = ConstitutionalRegistry.load(
                self.configuration.transition_registry_path,
                identifier_column="TransitionID",
            )

            if (
                self.configuration.require_frozen_architecture
                and manifest.status != "ARCHITECTURE_FROZEN"
            ):
                failures.append(
                    failure_from_code(
                        "MS-FAIL-ARCHITECTURE-001",
                        message="Architecture is not frozen.",
                    )
                )

            if len(transitions) != 17:
                failures.append(
                    failure_from_code(
                        "MS-FAIL-CONFORMANCE-001",
                        message=(
                            "State-transition registry must contain "
                            "exactly 17 transitions."
                        ),
                        details={
                            "actual_transition_count": len(transitions),
                        },
                    )
                )

            return ApiResult(
                success=not failures,
                operation="VALIDATE_ENVIRONMENT",
                data={
                    "architecture_id": manifest.architecture_id,
                    "architecture_version": manifest.version,
                    "architecture_status": manifest.status,
                    "invariant_count": len(invariants),
                    "transition_count": len(transitions),
                    "repository_counts": self.repository.counts(),
                    "trace_count": len(self.trace_ledger),
                },
                failures=tuple(failures),
            )
        except Exception as exc:
            return ApiResult(
                success=False,
                operation="VALIDATE_ENVIRONMENT",
                data={},
                failures=(
                    failure_from_code(
                        "MS-FAIL-CONFIGURATION-001",
                        message=str(exc),
                    ),
                ),
            )

    def persist_records(
        self,
        records: tuple[tuple[str, object], ...],
    ) -> ApiResult:
        try:
            paths = self.orchestrator.persist_records(records)

            return ApiResult(
                success=True,
                operation="PERSIST_RECORDS",
                data={
                    "record_count": len(paths),
                    "paths": tuple(str(path) for path in paths),
                },
            )
        except Exception as exc:
            return ApiResult(
                success=False,
                operation="PERSIST_RECORDS",
                data={},
                failures=(
                    failure_from_code(
                        "MS-FAIL-STORAGE-001",
                        message=str(exc),
                    ),
                ),
            )

    def evaluate_dependencies(
        self,
        dependencies: tuple[DependencyRecord, ...],
        *,
        known_object_ids: set[str],
    ) -> ApiResult:
        result = self.orchestrator.evaluate_dependencies(
            dependencies,
            known_object_ids=known_object_ids,
        )

        failures: list[RuntimeFailure] = []

        for finding in result.findings:
            if finding.disposition.value == "UNSATISFIED":
                failures.append(
                    failure_from_code(
                        "MS-FAIL-DEPENDENCY-001",
                        message=finding.message,
                    )
                )

            if finding.disposition.value == "CYCLIC":
                failures.append(
                    failure_from_code(
                        "MS-FAIL-DEPENDENCY-002",
                        message=finding.message,
                    )
                )

        return ApiResult(
            success=result.valid,
            operation="EVALUATE_DEPENDENCIES",
            data={
                "ordered_object_ids": result.ordered_object_ids,
                "findings": tuple(
                    canonical_dict(finding)
                    for finding in result.findings
                ),
            },
            failures=tuple(failures),
        )

    def evaluate_interpretation(
        self,
        interpretation: InterpretationRecord,
        *,
        source_object: CanonicalObject | None,
        uncertainties: dict[object, UncertaintyRecord],
    ) -> ApiResult:
        decision = self.orchestrator.decide_interpretation(
            interpretation,
            source_object=source_object,
            uncertainties=uncertainties,
        )

        success = decision.decision.value in {
            "ADMIT",
            "ADMIT_WITH_LIMITS",
            "ADMIT_WITH_UNCERTAINTY",
        }

        failures: tuple[RuntimeFailure, ...] = ()

        if not success:
            failure_code = (
                "MS-FAIL-INTERPRETATION-002"
                if "SOURCE_IDENTITY_MISMATCH"
                in decision.reason_codes
                else "MS-FAIL-INTERPRETATION-001"
            )

            failures = (
                failure_from_code(
                    failure_code,
                    details={
                        "reason_codes": decision.reason_codes,
                    },
                ),
            )

        return ApiResult(
            success=success,
            operation="EVALUATE_INTERPRETATION",
            data={
                "decision": decision.decision.value,
                "admission_status": decision.admission_status.value,
                "reason_codes": decision.reason_codes,
            },
            failures=failures,
        )

    def evaluate_initiation(
        self,
        participation: ParticipationRecord,
        *,
        authorities: dict[UUID, AuthorityRecord],
        evidence: dict[UUID, EvidenceRecord],
        uncertainties: dict[UUID, UncertaintyRecord],
    ) -> ApiResult:
        result = self.orchestrator.decide_initiation(
            participation,
            authorities=authorities,
            evidence=evidence,
            uncertainties=uncertainties,
        )

        success = result.disposition.value in {
            "ADMITTED",
            "ADMITTED_WITH_LIMITS",
            "PROVISIONAL",
        }

        failures: list[RuntimeFailure] = []

        if "AUTHORITY_MISSING" in result.reason_codes:
            failures.append(
                failure_from_code(
                    "MS-FAIL-AUTHORITY-001"
                )
            )

        if "EVIDENCE_MISSING" in result.reason_codes:
            failures.append(
                failure_from_code(
                    "MS-FAIL-EVIDENCE-001"
                )
            )

        if "EVIDENCE_NOT_VERIFIED" in result.reason_codes:
            failures.append(
                failure_from_code(
                    "MS-FAIL-EVIDENCE-002"
                )
            )

        if "BLOCKING_UNCERTAINTY" in result.reason_codes:
            failures.append(
                failure_from_code(
                    "MS-FAIL-UNCERTAINTY-002"
                )
            )

        return ApiResult(
            success=success,
            operation="EVALUATE_INITIATION",
            data={
                "disposition": result.disposition.value,
                "decision": result.decision.value,
                "reason_codes": result.reason_codes,
            },
            failures=tuple(failures),
        )

    def execute_transition(
        self,
        request: TransitionRequest,
    ) -> ApiResult:
        try:
            trace = self.orchestrator.execute_transition(request)

            return ApiResult(
                success=True,
                operation="EXECUTE_TRANSITION",
                data={
                    "trace": canonical_dict(trace),
                    "trace_head_hash": self.trace_ledger.head_hash,
                    "trace_count": len(self.trace_ledger),
                },
            )
        except Exception as exc:
            return ApiResult(
                success=False,
                operation="EXECUTE_TRANSITION",
                data={},
                failures=(
                    failure_from_code(
                        "MS-FAIL-TRANSITION-001",
                        message=str(exc),
                    ),
                ),
            )

    def verify_integrity(self) -> ApiResult:
        failures: list[RuntimeFailure] = []

        try:
            repository_valid = self.repository.verify_all()
        except Exception as exc:
            repository_valid = False
            failures.append(
                failure_from_code(
                    "MS-FAIL-INTEGRITY-001",
                    message=str(exc),
                )
            )

        try:
            ledger_valid = self.trace_ledger.verify()
        except Exception as exc:
            ledger_valid = False
            failures.append(
                failure_from_code(
                    "MS-FAIL-INTEGRITY-002",
                    message=str(exc),
                )
            )

        return ApiResult(
            success=repository_valid and ledger_valid,
            operation="VERIFY_INTEGRITY",
            data={
                "repository_valid": repository_valid,
                "trace_ledger_valid": ledger_valid,
                "repository_counts": self.repository.counts(),
                "trace_count": len(self.trace_ledger)
                if ledger_valid
                else None,
            },
            failures=tuple(failures),
        )

    def generate_snapshot(self) -> ApiResult:
        environment = self.validate_environment()

        if not environment.success:
            return ApiResult(
                success=False,
                operation="GENERATE_SNAPSHOT",
                data={},
                failures=environment.failures,
            )

        manifest = ArchitectureManifest.load(
            self.configuration.architecture_manifest_path
        )

        snapshot = RuntimeSnapshot(
            runtime_version=self.configuration.runtime_version,
            architecture_version=manifest.version,
            architecture_hash=manifest.aggregate_hash,
            registry_counts=self.repository.counts(),
            registry_hashes=self.repository.hashes(),
            trace_count=len(self.trace_ledger),
            trace_head_hash=self.trace_ledger.head_hash,
        )

        snapshot.write(self.configuration.snapshot_path)

        return ApiResult(
            success=True,
            operation="GENERATE_SNAPSHOT",
            data={
                "snapshot_path": str(
                    self.configuration.snapshot_path
                ),
                "snapshot_hash": snapshot.snapshot_hash,
            },
        )
