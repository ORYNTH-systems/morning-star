# MS-T1 and MS-T2 Pre-Execution Completion Instructions

## Purpose

These forms govern completion of identity, case-design, and dependency-design fields that must exist before controlled execution begins.

## Prohibited Entries

Do not enter:

- invented observer responses;
- inferred propagation events;
- fabricated semantic assessments;
- fabricated downstream assessments;
- theorem results;
- theorem dispositions;
- values unsupported by a governed source.

## Required Fields

Every completion-form row requires:

1. `ProposedValue`
2. `SourceReference`
3. `CompletedBy`
4. `CompletedAt`
5. `ReviewStatus`
6. `Reviewer`
7. `ReviewDate`

## Authorized Review Statuses

Use only:

- `NOT_COMPLETED`
- `PENDING_REVIEW`
- `APPROVED`
- `REJECTED`
- `REQUIRES_REVISION`

## Completion Rule

A row is admissibly complete only when:

- `ProposedValue` is populated;
- `SourceReference` identifies a controlled source;
- `CompletedBy` is populated;
- `CompletedAt` is a valid timestamp;
- `ReviewStatus` is `APPROVED`;
- `Reviewer` is populated;
- `ReviewDate` is a valid timestamp.

## Execution Gate

Controlled execution remains blocked until every pre-execution completion row is approved.
