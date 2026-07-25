"""Morning Star shared operational runtime standards."""

from __future__ import annotations

import json
import logging
import os
import pathlib
import sys
from enum import IntEnum
from typing import Any, Callable, Mapping

from morning_star.cli.main import main as _canonical_main


class ExitCode(IntEnum):
    """Canonical Morning Star process exit codes."""

    SUCCESS = 0
    OPERATIONAL_ERROR = 1
    INVALID_INPUT = 2
    CONFIGURATION_ERROR = 3
    VERIFICATION_FAILURE = 4
    INTERRUPTED = 130


class RuntimeConfigurationError(RuntimeError):
    """Raised when operational runtime configuration is invalid."""


def _defaults_path() -> pathlib.Path:
    return pathlib.Path(__file__).with_name("operational-defaults.json")


def load_runtime_config(
    path: str | os.PathLike[str] | None = None,
) -> dict[str, Any]:
    """Load and validate the operational runtime configuration."""

    config_path = pathlib.Path(path) if path else _defaults_path()

    if not config_path.is_file():
        raise RuntimeConfigurationError(
            f"Runtime configuration does not exist: {config_path}"
        )

    try:
        with config_path.open("r", encoding="utf-8-sig") as stream:
            config = json.load(stream)
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeConfigurationError(
            f"Unable to load runtime configuration: {config_path}"
        ) from exc

    if not isinstance(config, dict):
        raise RuntimeConfigurationError(
            "Runtime configuration must be a JSON object."
        )

    for required_key in ("logging", "exit_codes", "error_boundary"):
        if required_key not in config:
            raise RuntimeConfigurationError(
                f"Runtime configuration is missing: {required_key}"
            )

    return config


def configure_logging(
    config: Mapping[str, Any] | None = None,
) -> logging.Logger:
    """Configure deterministic process-level logging."""

    effective_config = dict(config or load_runtime_config())
    logging_config = effective_config["logging"]

    level_name = str(
        os.getenv(
            "MORNING_STAR_LOG_LEVEL",
            logging_config.get("level", "INFO"),
        )
    ).upper()

    level = getattr(logging, level_name, None)

    if not isinstance(level, int):
        raise RuntimeConfigurationError(
            f"Unsupported log level: {level_name}"
        )

    logging.basicConfig(
        level=level,
        format=str(logging_config["format"]),
        datefmt=str(logging_config["date_format"]),
        stream=sys.stderr,
        force=True,
    )

    return logging.getLogger("morning_star")


def execute_with_boundary(
    operation: Callable[[], Any],
) -> int:
    """Execute one CLI operation through the canonical error boundary."""

    logger = configure_logging()

    try:
        result = operation()

        if result is None:
            return int(ExitCode.SUCCESS)

        if isinstance(result, bool):
            return int(
                ExitCode.SUCCESS
                if result
                else ExitCode.OPERATIONAL_ERROR
            )

        if isinstance(result, int):
            return result

        return int(ExitCode.SUCCESS)
    except SystemExit:
        raise
    except KeyboardInterrupt:
        logger.warning("Execution interrupted.")
        return int(ExitCode.INTERRUPTED)
    except RuntimeConfigurationError as exc:
        logger.error("%s", exc)
        return int(ExitCode.CONFIGURATION_ERROR)
    except (TypeError, ValueError) as exc:
        logger.error("%s", exc)
        return int(ExitCode.INVALID_INPUT)
    except Exception:
        logger.exception("Unhandled Morning Star runtime failure.")
        return int(ExitCode.OPERATIONAL_ERROR)


def main() -> int:
    """Canonical console wrapper preserving the existing CLI surface."""

    return execute_with_boundary(_canonical_main)
