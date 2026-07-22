"""Tests for the typed runtime registry."""

from uuid import uuid4

import pytest

from morning_star.registries.memory import RuntimeRegistry


def test_registry_adds_and_reads_record() -> None:
    registry: RuntimeRegistry[str] = RuntimeRegistry()
    record_id = uuid4()

    registry.add(record_id, "record")

    assert registry.get(record_id) == "record"
    assert len(registry) == 1


def test_registry_rejects_duplicate_id() -> None:
    registry: RuntimeRegistry[str] = RuntimeRegistry()
    record_id = uuid4()

    registry.add(record_id, "first")

    with pytest.raises(ValueError):
        registry.add(record_id, "second")


def test_registry_replaces_existing_record() -> None:
    registry: RuntimeRegistry[str] = RuntimeRegistry()
    record_id = uuid4()

    registry.add(record_id, "first")
    registry.replace(record_id, "second")

    assert registry.get(record_id) == "second"


def test_registry_rejects_unknown_replacement() -> None:
    registry: RuntimeRegistry[str] = RuntimeRegistry()

    with pytest.raises(KeyError):
        registry.replace(uuid4(), "record")
