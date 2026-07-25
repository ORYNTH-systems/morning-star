# Morning Star CLI Commands

## Public executable

- Canonical command: `morning-star`
- Python target: `morning_star.cli.main:main`

## Supported command surface

- ``snapshot`` — ARGPARSE in ``runtime\src\morning_star\cli\main.py``
- ``status`` — ARGPARSE in ``runtime\src\morning_star\cli\main.py``
- ``validate`` — ARGPARSE in ``runtime\src\morning_star\cli\main.py``
- ``verify`` — ARGPARSE in ``runtime\src\morning_star\cli\main.py``

## Compatibility aliases

- None.

## Help behavior

- ``morning-star --help`` exits successfully.
- Repeated help output is deterministic.
