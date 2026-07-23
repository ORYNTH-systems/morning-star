# MS-T1 and MS-T2 Controlled Execution Harness

**Generated:** 2026-07-23T17:23:47-05:00

**Overall State:** EVIDENCE_ENTRY_REQUIRED

## Harness Function

This harness validates schemas, row completeness, evidence identity uniqueness, and theorem scoring eligibility. It does not create observations or force a theorem disposition.

## Theorem State

| Theorem | Required Files | Valid Files | Blocking Files | Execution State | Scoring Permitted |
|---|---:|---:|---:|---|---|
| MS-T1 | 3 | 0 | 3 | EVIDENCE_ENTRY_REQUIRED | False |
| MS-T2 | 4 | 0 | 4 | EVIDENCE_ENTRY_REQUIRED | False |

## File Validation

| Theorem | File | Role | Meaningful Rows | Complete | Incomplete | Duplicates | Status |
|---|---|---|---:|---:|---:|---:|---|
| MS-T1 | OBSERVER_RESPONSES.csv | PRIMARY_EVIDENCE | 0 | 0 | 0 | 0 | EMPTY_EVIDENCE |
| MS-T1 | SEMANTIC_ASSESSMENTS.csv | ASSESSMENT_EVIDENCE | 0 | 0 | 0 | 0 | EMPTY_EVIDENCE |
| MS-T1 | TRIAL_CASES.csv | CASE_DEFINITION | 1 | 0 | 1 | 0 | INCOMPLETE_ROWS |
| MS-T2 | DEPENDENCY_CHAINS.csv | CHAIN_DEFINITION | 1 | 0 | 1 | 0 | INCOMPLETE_ROWS |
| MS-T2 | DOWNSTREAM_ASSESSMENTS.csv | ASSESSMENT_EVIDENCE | 0 | 0 | 0 | 0 | EMPTY_EVIDENCE |
| MS-T2 | PROPAGATION_EVENTS.csv | PRIMARY_EVIDENCE | 0 | 0 | 0 | 0 | EMPTY_EVIDENCE |
| MS-T2 | TRIAL_CASES.csv | CASE_DEFINITION | 2 | 0 | 2 | 0 | INCOMPLETE_ROWS |

## Implemented Controls

| Control | Theorem | Class | Status | Description |
|---|---|---|---|---|
| MS-T1-CTRL-001 | MS-T1 | SCHEMA_VALIDATION | IMPLEMENTED | Every governed CSV must exist and preserve its declared schema. |
| MS-T1-CTRL-002 | MS-T1 | EVIDENCE_COMPLETENESS | IMPLEMENTED | Every material evidence row must contain values for all declared fields. |
| MS-T1-CTRL-003 | MS-T1 | IDENTITY_UNIQUENESS | IMPLEMENTED | Evidence identities must not be duplicated within a governed CSV. |
| MS-T1-CTRL-004 | MS-T1 | NO_SYNTHETIC_EVIDENCE | ENFORCED | The harness validates supplied evidence but does not invent observations, assessments, or outcomes. |
| MS-T1-CTRL-005 | MS-T1 | DISPOSITION_GATING | ENFORCED | Theorem scoring and disposition remain blocked until all required evidence files validate. |
| MS-T2-CTRL-001 | MS-T2 | SCHEMA_VALIDATION | IMPLEMENTED | Every governed CSV must exist and preserve its declared schema. |
| MS-T2-CTRL-002 | MS-T2 | EVIDENCE_COMPLETENESS | IMPLEMENTED | Every material evidence row must contain values for all declared fields. |
| MS-T2-CTRL-003 | MS-T2 | IDENTITY_UNIQUENESS | IMPLEMENTED | Evidence identities must not be duplicated within a governed CSV. |
| MS-T2-CTRL-004 | MS-T2 | NO_SYNTHETIC_EVIDENCE | ENFORCED | The harness validates supplied evidence but does not invent observations, assessments, or outcomes. |
| MS-T2-CTRL-005 | MS-T2 | DISPOSITION_GATING | ENFORCED | Theorem scoring and disposition remain blocked until all required evidence files validate. |

## Current Gate

Controlled scoring remains prohibited. Populate the governed evidence registers using the trial procedures, then rerun this harness.
