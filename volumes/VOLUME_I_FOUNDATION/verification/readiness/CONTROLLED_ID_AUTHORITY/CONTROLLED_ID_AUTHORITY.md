# Morning Star Controlled ID Authority

## Purpose

The Morning Star Controlled ID Authority governs the creation, issuance,
uniqueness, persistence, status, and traceability of identifiers used by
verification trials.

## Authority

Identifiers governed by this authority may not be inferred from descriptive
content, copied from unrelated records, or generated independently by evidence
collectors or assessors.

## CaseID Format

Canonical CaseIDs use the following format:

`<THEOREM-CODE>-CASE-<FOUR-DIGIT-SEQUENCE>`

Examples:

- `MST1-CASE-0001`
- `MST2-CASE-0001`

## Issuance Rules

1. Each CaseID identifies exactly one governed trial case.
2. A CaseID must be unique within the Morning Star verification system.
3. A CaseID is immutable after issuance.
4. A revoked identifier is never reassigned.
5. Related input, evidence, and assessment records must reference the same CaseID.
6. Identifier issuance does not constitute execution evidence.
7. Identifier issuance does not determine theorem outcome.
8. Every issuance must be recorded in the controlled issuance register.

## Authority Boundary

The Controlled ID Authority may:

- create canonical identifiers;
- verify uniqueness;
- record issuance provenance;
- preserve prior provisional identities;
- revoke identifiers through a governed record.

The Controlled ID Authority may not:

- invent observer responses;
- invent propagation events;
- make assessor judgments;
- determine theorem results;
- alter raw execution evidence.
