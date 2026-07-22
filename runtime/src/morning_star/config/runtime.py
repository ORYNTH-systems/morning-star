"""Morning Star runtime configuration model and loader."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


class RuntimeConfigurationError(ValueError):
    """Raised when runtime configuration is invalid."""


@dataclass(frozen=True, slots=True)
class RuntimeConfiguration:
    runtime_id: str
    runtime_version: str
    architecture_manifest_path: Path
    invariant_registry_path: Path
    transition_registry_path: Path
    repository_path: Path
    trace_ledger_path: Path
    snapshot_path: Path
    strict_integrity: bool = True
    allow_provisional_admission: bool = True
    require_frozen_architecture: bool = True

    def __post_init__(self) -> None:
        if not self.runtime_id.strip():
            raise RuntimeConfigurationError(
                "runtime_id is required."
            )

        if not self.runtime_version.strip():
            raise RuntimeConfigurationError(
                "runtime_version is required."
            )

    @classmethod
    def from_dict(
        cls,
        data: dict[str, Any],
        *,
        base_path: Path,
    ) -> "RuntimeConfiguration":
        required = {
            "runtime_id",
            "runtime_version",
            "architecture_manifest_path",
            "invariant_registry_path",
            "transition_registry_path",
            "repository_path",
            "trace_ledger_path",
            "snapshot_path",
        }

        missing = sorted(required.difference(data))

        if missing:
            raise RuntimeConfigurationError(
                f"Configuration fields missing: {missing}"
            )

        def resolve(value: Any) -> Path:
            if not isinstance(value, str) or not value.strip():
                raise RuntimeConfigurationError(
                    "Configuration paths must be non-empty strings."
                )

            path = Path(value)

            if not path.is_absolute():
                path = base_path / path

            return path.resolve()

        return cls(
            runtime_id=str(data["runtime_id"]),
            runtime_version=str(data["runtime_version"]),
            architecture_manifest_path=resolve(
                data["architecture_manifest_path"]
            ),
            invariant_registry_path=resolve(
                data["invariant_registry_path"]
            ),
            transition_registry_path=resolve(
                data["transition_registry_path"]
            ),
            repository_path=resolve(data["repository_path"]),
            trace_ledger_path=resolve(data["trace_ledger_path"]),
            snapshot_path=resolve(data["snapshot_path"]),
            strict_integrity=bool(
                data.get("strict_integrity", True)
            ),
            allow_provisional_admission=bool(
                data.get("allow_provisional_admission", True)
            ),
            require_frozen_architecture=bool(
                data.get("require_frozen_architecture", True)
            ),
        )

    @classmethod
    def load(
        cls,
        path: Path,
    ) -> "RuntimeConfiguration":
        if not path.exists():
            raise FileNotFoundError(path)

        try:
            data = json.loads(
                path.read_text(encoding="utf-8-sig")
            )
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise RuntimeConfigurationError(
                "Runtime configuration is invalid JSON."
            ) from exc

        if not isinstance(data, dict):
            raise RuntimeConfigurationError(
                "Runtime configuration root must be an object."
            )

        return cls.from_dict(
            data,
            base_path=path.parent,
        )

    def verify_required_sources(self) -> bool:
        required_paths = (
            self.architecture_manifest_path,
            self.invariant_registry_path,
            self.transition_registry_path,
        )

        missing = [
            path
            for path in required_paths
            if not path.exists() or not path.is_file()
        ]

        if missing:
            raise RuntimeConfigurationError(
                f"Required runtime sources missing: {missing}"
            )

        return True
