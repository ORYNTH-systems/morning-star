# Morning Star Batch A Transaction Governance

## Constitutional source of truth

The sole constitutional source of Batch A work items is:

`PREEXECUTION_COMPLETION_WORKLIST.csv`

Completion forms are synchronized projections of approved transaction records.

## Separation of responsibility

Resolution engines may only append proposed records to `BATCH_A_TRANSACTION_REGISTER.csv`.

Resolution engines are prohibited from directly modifying:

- the canonical worklist
- completion forms
- frozen datasets
- execution evidence
- theorem dispositions

Only the Batch A Synchronization Engine may propagate validated transaction values into the canonical worklist and linked completion forms.

## Transaction lifecycle

1. A work item is read from the canonical worklist.
2. The responsible engine proposes a transaction.
3. The validation engine evaluates the proposal.
4. Failed proposals remain preserved as audit evidence.
5. Validated proposals become eligible for synchronization.
6. The synchronization engine updates governed targets atomically.
7. Synchronization results are written back to the transaction register.

## Rollback rule

Rollback never deletes transaction history. A rollback creates a new governed transaction referencing the transaction it reverses.

## Constitutional boundary

Batch A may complete pre-execution values. It may not create execution evidence, perform theorem assessment, or assign final theorem disposition.
