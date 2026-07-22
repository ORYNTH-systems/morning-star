"""Deterministic reconstruction of Morning Star runtime records."""

from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Any, Callable, TypeVar
from uuid import UUID

from morning_star.models.canonical import (
    ActorIdentity,
    AuthorityRecord,
    CanonicalObject,
    ConstitutionalTrace,
    DependencyRecord,
    EvidenceRecord,
    InterpretationRecord,
    ParticipationRecord,
    ProvenanceRecord,
    UncertaintyRecord,
)
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


T = TypeVar("T")


class ReconstructionError(ValueError):
    """Raised when canonical data cannot be reconstructed."""


def _uuid(value: Any) -> UUID:
    if isinstance(value, UUID):
        return value

    if not isinstance(value, str):
        raise ReconstructionError("UUID value must be a string.")

    try:
        return UUID(value)
    except ValueError as exc:
        raise ReconstructionError(f"Invalid UUID value: {value}") from exc


def _optional_uuid(value: Any) -> UUID | None:
    if value is None:
        return None

    return _uuid(value)


def _datetime(value: Any) -> datetime:
    if isinstance(value, datetime):
        result = value
    elif isinstance(value, str):
        try:
            result = datetime.fromisoformat(value)
        except ValueError as exc:
            raise ReconstructionError(
                f"Invalid datetime value: {value}"
            ) from exc
    else:
        raise ReconstructionError("Datetime value must be a string.")

    if result.tzinfo is None:
        raise ReconstructionError("Datetime values must be timezone-aware.")

    return result


def _enum(
    enum_type: type[T],
    value: Any,
) -> T:
    try:
        return enum_type(value)
    except (TypeError, ValueError) as exc:
        raise ReconstructionError(
            f"Invalid {enum_type.__name__} value: {value}"
        ) from exc


def _tuple_of_uuid(value: Any) -> tuple[UUID, ...]:
    if value is None:
        return ()

    if not isinstance(value, list):
        raise ReconstructionError("UUID sequence must be a list.")

    return tuple(_uuid(item) for item in value)


def _tuple_of_text(value: Any) -> tuple[str, ...]:
    if value is None:
        return ()

    if not isinstance(value, list):
        raise ReconstructionError("Text sequence must be a list.")

    if not all(isinstance(item, str) for item in value):
        raise ReconstructionError("Text sequence contains a non-string value.")

    return tuple(value)


def reconstruct_provenance(data: dict[str, Any]) -> ProvenanceRecord:
    return ProvenanceRecord(
        provenance_id=_uuid(data["provenance_id"]),
        source_ids=_tuple_of_text(data["source_ids"]),
        transformation_ids=_tuple_of_text(data["transformation_ids"]),
        authority_ids=_tuple_of_text(data["authority_ids"]),
        created_at=_datetime(data["created_at"]),
    )


def reconstruct_uncertainty(data: dict[str, Any]) -> UncertaintyRecord:
    return UncertaintyRecord(
        uncertainty_id=_uuid(data["uncertainty_id"]),
        uncertainty_type=_enum(
            UncertaintyType,
            data["uncertainty_type"],
        ),
        description=data["description"],
        blocks_admission=bool(data["blocks_admission"]),
        created_at=_datetime(data["created_at"]),
    )


def reconstruct_authority(data: dict[str, Any]) -> AuthorityRecord:
    return AuthorityRecord(
        authority_id=_uuid(data["authority_id"]),
        holder_id=data["holder_id"],
        authority_type=data["authority_type"],
        scope=data["scope"],
        source=data["source"],
        active=bool(data["active"]),
        effective_at=_datetime(data["effective_at"]),
        expires_at=(
            _datetime(data["expires_at"])
            if data["expires_at"] is not None
            else None
        ),
    )


def reconstruct_evidence(data: dict[str, Any]) -> EvidenceRecord:
    return EvidenceRecord(
        evidence_id=_uuid(data["evidence_id"]),
        evidence_type=data["evidence_type"],
        source=data["source"],
        method=data["method"],
        scope=data["scope"],
        integrity_verified=bool(data["integrity_verified"]),
        provenance_id=_optional_uuid(data["provenance_id"]),
        created_at=_datetime(data["created_at"]),
    )


def reconstruct_dependency(data: dict[str, Any]) -> DependencyRecord:
    return DependencyRecord(
        dependency_id=_uuid(data["dependency_id"]),
        source_object_id=data["source_object_id"],
        target_object_id=data["target_object_id"],
        relationship_type=data["relationship_type"],
        mandatory=bool(data["mandatory"]),
        satisfied=bool(data["satisfied"]),
        evidence_ids=_tuple_of_uuid(data["evidence_ids"]),
    )


def reconstruct_actor(data: dict[str, Any]) -> ActorIdentity:
    return ActorIdentity(
        actor_id=_uuid(data["actor_id"]),
        display_name=data["display_name"],
        identity_source=data["identity_source"],
        assurance_level=data["assurance_level"],
        provenance_id=_optional_uuid(data["provenance_id"]),
        uncertainty_ids=_tuple_of_uuid(data["uncertainty_ids"]),
        created_at=_datetime(data["created_at"]),
    )


def reconstruct_canonical_object(
    data: dict[str, Any],
) -> CanonicalObject:
    metadata = data["metadata"]

    if not isinstance(metadata, dict):
        raise ReconstructionError("metadata must be an object.")

    return CanonicalObject(
        object_id=_uuid(data["object_id"]),
        object_type=data["object_type"],
        canonical_name=data["canonical_name"],
        definition=data["definition"],
        scope=data["scope"],
        authority_id=_optional_uuid(data["authority_id"]),
        provenance_id=_optional_uuid(data["provenance_id"]),
        dependency_ids=_tuple_of_uuid(data["dependency_ids"]),
        uncertainty_ids=_tuple_of_uuid(data["uncertainty_ids"]),
        status=_enum(ObjectStatus, data["status"]),
        version=data["version"],
        created_at=_datetime(data["created_at"]),
        revised_at=_datetime(data["revised_at"]),
        validation_status=_enum(
            ValidationStatus,
            data["validation_status"],
        ),
        metadata=metadata,
    )


def reconstruct_interpretation(
    data: dict[str, Any],
) -> InterpretationRecord:
    return InterpretationRecord(
        interpretation_id=_uuid(data["interpretation_id"]),
        interpreted_object_id=_uuid(data["interpreted_object_id"]),
        interpretation_class=_enum(
            InterpretationClass,
            data["interpretation_class"],
        ),
        interpreter_id=_uuid(data["interpreter_id"]),
        authority_id=_optional_uuid(data["authority_id"]),
        source_basis=_tuple_of_text(data["source_basis"]),
        scope=data["scope"],
        dependency_ids=_tuple_of_uuid(data["dependency_ids"]),
        provenance_id=_optional_uuid(data["provenance_id"]),
        uncertainty_ids=_tuple_of_uuid(data["uncertainty_ids"]),
        admission_status=_enum(
            AdmissionStatus,
            data["admission_status"],
        ),
        version=data["version"],
        created_at=_datetime(data["created_at"]),
        revised_at=_datetime(data["revised_at"]),
        validation_status=_enum(
            ValidationStatus,
            data["validation_status"],
        ),
    )


def reconstruct_participation(
    data: dict[str, Any],
) -> ParticipationRecord:
    return ParticipationRecord(
        participation_id=_uuid(data["participation_id"]),
        actor_id=_uuid(data["actor_id"]),
        prior_role=_enum(
            ParticipationRole,
            data["prior_role"],
        ),
        requested_role=_enum(
            ParticipationRole,
            data["requested_role"],
        ),
        admitted_role=_enum(
            ParticipationRole,
            data["admitted_role"],
        ),
        decision=_enum(
            InitiationDecision,
            data["decision"],
        ),
        scope=data["scope"],
        authority_id=_optional_uuid(data["authority_id"]),
        evidence_ids=_tuple_of_uuid(data["evidence_ids"]),
        uncertainty_ids=_tuple_of_uuid(data["uncertainty_ids"]),
        effective_at=_datetime(data["effective_at"]),
        expires_at=(
            _datetime(data["expires_at"])
            if data["expires_at"] is not None
            else None
        ),
        validation_status=_enum(
            ValidationStatus,
            data["validation_status"],
        ),
    )


def reconstruct_trace(
    data: dict[str, Any],
) -> ConstitutionalTrace:
    return ConstitutionalTrace(
        trace_id=_uuid(data["trace_id"]),
        actor_id=_optional_uuid(data["actor_id"]),
        object_id=_optional_uuid(data["object_id"]),
        prior_state=_enum(
            ConstitutionalState,
            data["prior_state"],
        ),
        resulting_state=_enum(
            ConstitutionalState,
            data["resulting_state"],
        ),
        transition_id=data["transition_id"],
        authority_id=_optional_uuid(data["authority_id"]),
        evidence_ids=_tuple_of_uuid(data["evidence_ids"]),
        uncertainty_ids=_tuple_of_uuid(data["uncertainty_ids"]),
        occurred_at=_datetime(data["occurred_at"]),
    )


RECONSTRUCTORS: dict[str, Callable[[dict[str, Any]], Any]] = {
    "ACTOR_IDENTITY": reconstruct_actor,
    "AUTHORITY_RECORD": reconstruct_authority,
    "CANONICAL_OBJECT": reconstruct_canonical_object,
    "CONSTITUTIONAL_TRACE": reconstruct_trace,
    "DEPENDENCY_RECORD": reconstruct_dependency,
    "EVIDENCE_RECORD": reconstruct_evidence,
    "INTERPRETATION_RECORD": reconstruct_interpretation,
    "PARTICIPATION_RECORD": reconstruct_participation,
    "PROVENANCE_RECORD": reconstruct_provenance,
    "UNCERTAINTY_RECORD": reconstruct_uncertainty,
}


def reconstruct_runtime_object(
    object_type: str,
    payload: dict[str, Any],
) -> Any:
    try:
        reconstructor = RECONSTRUCTORS[object_type]
    except KeyError as exc:
        raise ReconstructionError(
            f"Unsupported runtime object type: {object_type}"
        ) from exc

    return reconstructor(payload)
