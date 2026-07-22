# Evidence Intake Plan

| Field | Value |
|---|---|
| Trial ID | MS-T1-TRIAL-0001 |
| Theorem ID | MS-T1 |
| Verification ID | MS-T1-VERIFICATION |
| Intake State | OPEN |
| Requirement Count | 4 |
| Evidence Class Count | 5 |
| Registered Evidence Count | 0 |
| Evaluation State | NOT_STARTED |
| Result State | UNRESOLVED |
| Initialized At | 2026-07-22T19:31:18.5992537Z |

## Purpose

This plan governs the collection and registration of evidence required for the bounded verification trial.

Evidence intake does not itself constitute evaluation or theorem execution.

## Required Evidence Classes

1. **Input evidence** — the governed initial state.
2. **Constraint evidence** — evidence relevant to applicability and satisfaction of constraints.
3. **Trace evidence** — ordered transitions, decisions, and execution events.
4. **Output evidence** — the governed resulting state.
5. **Uncertainty evidence** — missing, approximate, contradictory, or unresolved information.

## Registration Rules

Each evidence item must receive:

- a unique evidence identifier;
- an evidence class;
- a source path;
- a registration time;
- provenance status;
- review status;
- admissibility status;
- uncertainty status;
- explanatory notes when qualification is required.

## Constitutional Constraints

- Missing evidence remains missing.
- Uncertainty remains explicit.
- Evidence is not admissible merely because it exists.
- Evidence registration does not equal evidence validation.
- Evidence validation does not equal theorem satisfaction.
- No condition or constraint may be evaluated before its supporting evidence is registered and reviewed.
- No final result may be assigned during evidence intake.
