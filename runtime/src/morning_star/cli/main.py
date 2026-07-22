"""Morning Star command-line interface."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from morning_star.api.runtime import MorningStarRuntimeApi
from morning_star.config.runtime import RuntimeConfiguration
from morning_star.models.serialization import canonical_json


def _result_payload(result: Any) -> dict[str, Any]:
    return {
        "success": result.success,
        "operation": result.operation,
        "data": result.data,
        "failures": [
            {
                "code": failure.code,
                "domain": failure.domain.value,
                "severity": failure.severity.value,
                "disposition": failure.disposition.value,
                "message": failure.message,
                "recoverable": failure.recoverable,
                "details": failure.details,
            }
            for failure in result.failures
        ],
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="morning-star",
        description=(
            "Morning Star constitutional reference runtime."
        ),
    )

    parser.add_argument(
        "--config",
        required=True,
        type=Path,
        help="Path to runtime configuration JSON.",
    )

    subparsers = parser.add_subparsers(
        dest="command",
        required=True,
    )

    subparsers.add_parser(
        "validate",
        help="Validate architecture and runtime environment.",
    )

    subparsers.add_parser(
        "verify",
        help="Verify repository and trace-ledger integrity.",
    )

    subparsers.add_parser(
        "snapshot",
        help="Generate a deterministic runtime snapshot.",
    )

    subparsers.add_parser(
        "status",
        help="Display runtime status.",
    )

    return parser


def main(
    argv: list[str] | None = None,
) -> int:
    parser = build_parser()
    arguments = parser.parse_args(argv)

    try:
        configuration = RuntimeConfiguration.load(
            arguments.config
        )

        api = MorningStarRuntimeApi(configuration)

        if arguments.command == "validate":
            result = api.validate_environment()
        elif arguments.command == "verify":
            result = api.verify_integrity()
        elif arguments.command == "snapshot":
            result = api.generate_snapshot()
        elif arguments.command == "status":
            environment = api.validate_environment()
            integrity = api.verify_integrity()

            payload = {
                "success": (
                    environment.success
                    and integrity.success
                ),
                "operation": "STATUS",
                "data": {
                    "environment": _result_payload(
                        environment
                    ),
                    "integrity": _result_payload(
                        integrity
                    ),
                },
                "failures": [],
            }

            print(canonical_json(payload))

            return 0 if payload["success"] else 1
        else:
            parser.error(
                f"Unsupported command: {arguments.command}"
            )

        print(
            canonical_json(
                _result_payload(result)
            )
        )

        return 0 if result.success else 1
    except Exception as exc:
        print(
            json.dumps(
                {
                    "success": False,
                    "operation": "CLI",
                    "data": {},
                    "failures": [
                        {
                            "code": "MS-FAIL-CONFIGURATION-001",
                            "message": str(exc),
                        }
                    ],
                },
                sort_keys=True,
                separators=(",", ":"),
            )
        )

        return 2


if __name__ == "__main__":
    sys.exit(main())
