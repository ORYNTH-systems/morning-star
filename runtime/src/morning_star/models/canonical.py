"""Canonical Morning Star runtime domain objects."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any
from uuid import UUID, uuid4

from morning_star.models.enums import (
    AdmissionStatus,
    ConstitutionalState,
    InitiationDecision,
    InterpretationClass,
    ObjectStatus,
    ParticipationRole,
    UncertaintyType,
    ValidationStatus,
)


def utc_now() -> datetime:
    """Return an aware UTC timestamp."""
    return datetime.now(timezone.utc)


def require_text(value: str, field_name: str) -> None:
    """Require a non-empty string."""
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"{field_name} must be a non-empty string.")


@dataclass(frozen=True, slots=True)
class ProvenanceRecord:
    provenance_id: UUID = field(default_factory=uuid4)
    source_ids: tuple[str, ...] = ()
    transformation_ids: tuple[str, ...] = ()
    authority_ids: tuple[str, ...] = ()
    created_at: datetime = field(default_factory=utc_now)

    def __post_init__(self) -> None:
        if not self.source_ids:
            raise ValueError("ProvenanceRecord requires at least one source_id.")


@dataclass(frozen=True, slots=True)
class UncertaintyRecord:
    uncertainty_id: UUID = field(default_factory=uuid4)
    uncertainty_type: UncertaintyType = UncertaintyType.NONE
    description: str = "No material uncertainty declared."
    blocks_admission: bool = False
    created_at: datetime = field(default_factory=utc_now)

    def __post_init__(self) -> None:
        require_text(self.description, "description")


@dataclass(frozen=True, slots=True)
class AuthorityRecord:
    authority_id: UUID = field(default_factory=uuid4)
    holder_id: str = ""
    authority_type: str = ""
    scope: str = ""
    source: str = ""
    active: bool = True
    effective_at: datetime = field(default_factory=utc_now)
    expires_at: datetime | None = None

    def __post_init__(self) -> None:
        require_text(self.holder_id, "holder_id")
        require_text(self.authority_type, "authority_type")
        require_text(self.scope, "scope")
        require_text(self.source, "source")

        if self.expires_at is not None and self.expires_at <= self.effective_at:
            raise ValueError("expires_at must occur after effective_at.")


@dataclass(frozen=True, slots=True)
class EvidenceRecord:
    evidence_id: UUID = field(default_factory=uuid4)
    evidence_type: str = ""
    source: str = ""
    method: str = ""
    scope: str = ""
    integrity_verified: bool = False
    provenance_id: UUID | None = None
    created_at: datetime = field(default_factory=utc_now)

    def __post_init__(self) -> None:
        require_text(self.evidence_type, "evidence_type")
        require_text(self.source, "source")
        require_text(self.method, "method")
        require_text(self.scope, "scope")


@dataclass(frozen=True, slots=True)
class DependencyRecord:
    dependency_id: UUID = field(default_factory=uuid4)
    source_object_id: str = ""
    target_object_id: str = ""
    relationship_type: str = ""
    mandatory: bool = True
    satisfied: bool = False
    evidence_ids: tuple[UUID, ...] = ()

    def __post_init__(self) -> None:
        require_text(self.source_object_id, "source_object_id")
        require_text(self.target_object_id, "target_object_id")
        require_text(self.relationship_type, "relationship_type")

        if self.source_object_id == self.target_object_id:
            raise ValueError("A dependency cannot reference the same source and target.")


@dataclass(frozen=True, slots=True)
class ActorIdentity:
    actor_id: UUID = field(default_factory=uuid4)
    display_name: str = ""
    identity_source: str = ""
    assurance_level: str = ""
    provenance_id: UUID | None = None
    uncertainty_ids: tuple[UUID, ...] = ()
    created_at: datetime = field(default_factory=utc_now)

    def __post_init__(self) -> None:
        require_text(self.display_name, "display_name")
        require_text(self.identity_source, "identity_source")
        require_text(self.assurance_level, "assurance_level")


@dataclass(frozen=True, slots=True)
class CanonicalObject:
    object_id: UUID = field(default_factory=uuid4)
    object_type: str = ""
    canonical_name: str = ""
    definition: str = ""
    scope: str = ""
    authority_id: UUID | None = None
    provenance_id: UUID | None = None
    dependency_ids: tuple[UUID, ...] = ()
    uncertainty_ids: tuple[UUID, ...] = ()
    status: ObjectStatus = ObjectStatus.DRAFT
    version: str = "0.1.0"
    created_at: datetime = field(default_factory=utc_now)
    revised_at: datetime = field(default_factory=utc_now)
    validation_status: ValidationStatus = ValidationStatus.NOT_VALIDATED
    metadata: dict[str, Any] = field(default_factory=dict)

    def __post_init__(self) -> None:
        require_text(self.object_type, "object_type")
        require_text(self.canonical_name, "canonical_name")
        require_text(self.definition, "definition")
        require_text(self.scope, "scope")
        require_text(self.version, "version")

        if self.revised_at < self.created_at:
            raise ValueError("revised_at cannot precede created_at.")


@dataclass(frozen=True, slots=True)
class InterpretationRecord:
    interpretation_id: UUID = field(default_factory=uuid4)
    interpreted_object_id: UUID = field(default_factory=uuid4)
    interpretation_class: InterpretationClass = InterpretationClass.UNRESOLVED
    interpreter_id: UUID = field(default_factory=uuid4)
    authority_id: UUID | None = None
    source_basis: tuple[str, ...] = ()
    scope: str = ""
    dependency_ids: tuple[UUID, ...] = ()
    provenance_id: UUID | None = None
    uncertainty_ids: tuple[UUID, ...] = ()
    admission_status: AdmissionStatus = AdmissionStatus.UNRESOLVED
    version: str = "0.1.0"
    created_at: datetime = field(default_factory=utc_now)
    revised_at: datetime = field(default_factory=utc_now)
    validation_status: ValidationStatus = ValidationStatus.NOT_VALIDATED

    def __post_init__(self) -> None:
        if not self.source_basis:
            raise ValueError("InterpretationRecord requires source_basis.")

        require_text(self.scope, "scope")
        require_text(self.version, "version")

        if self.revised_at < self.created_at:
            raise ValueError("revised_at cannot precede created_at.")


@dataclass(frozen=True, slots=True)
class ParticipationRecord:
    participation_id: UUID = field(default_factory=uuid4)
    actor_id: UUID = field(default_factory=uuid4)
    prior_role: ParticipationRole = ParticipationRole.PR0
    requested_role: ParticipationRole = ParticipationRole.PR0
    admitted_role: ParticipationRole = ParticipationRole.PR0
    decision: InitiationDecision = InitiationDecision.DEFER
    scope: str = ""
    authority_id: UUID | None = None
    evidence_ids: tuple[UUID, ...] = ()
    uncertainty_ids: tuple[UUID, ...] = ()
    effective_at: datetime = field(default_factory=utc_now)
    expires_at: datetime | None = None
    validation_status: ValidationStatus = ValidationStatus.NOT_VALIDATED

    def __post_init__(self) -> None:
        require_text(self.scope, "scope")

        if self.expires_at is not None and self.expires_at <= self.effective_at:
            raise ValueError("expires_at must occur after effective_at.")


@dataclass(frozen=True, slots=True)
class ConstitutionalTrace:
    trace_id: UUID = field(default_factory=uuid4)
    actor_id: UUID | None = None
    object_id: UUID | None = None
    prior_state: ConstitutionalState = ConstitutionalState.UNENCOUNTERED
    resulting_state: ConstitutionalState = ConstitutionalState.UNENCOUNTERED
    transition_id: str = ""
    authority_id: UUID | None = None
    evidence_ids: tuple[UUID, ...] = ()
    uncertainty_ids: tuple[UUID, ...] = ()
    occurred_at: datetime = field(default_factory=utc_now)

    def __post_init__(self) -> None:
        require_text(self.transition_id, "transition_id")

        if self.prior_state == self.resulting_state:
            raise ValueError("A constitutional transition must change state.")
