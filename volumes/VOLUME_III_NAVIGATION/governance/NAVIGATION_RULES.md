# Morning Star Navigation Governance Rules

**Document ID:** MS-V3-GOV-001  
**Version:** 0.1.0  
**Status:** NAVIGATION FOUNDATION  

## Evaluation Order

Every navigation decision must be evaluated in this order:

1. canonical identity
2. object status
3. governing authority
4. observer state
5. destination role requirement
6. prerequisite status
7. dependency status
8. provenance
9. uncertainty
10. revision currency
11. prohibited conflation
12. trace integrity
13. path decision

A later stage may not override an earlier constitutional failure.

## Proceed Rule

A path may proceed only when all mandatory conditions are satisfied or an authorized bounded waiver exists.

## Uncertainty Rule

A path may proceed with uncertainty only when:

- uncertainty is explicit;
- uncertainty does not invalidate a mandatory prerequisite;
- uncertainty does not fabricate authority;
- downstream constraints remain enforced.

## Block Rule

A path must be blocked when continuation would violate a constitutional invariant.

## Deferral Rule

A path should be deferred rather than rejected when the unresolved condition is potentially resolvable and no current continuation is constitutionally admissible.

## Redirect Rule

A redirect must identify:

- original path;
- blocking condition;
- destination path;
- reason for redirection;
- retained progress;
- discarded assumptions;
- required new prerequisites.

## Re-entry Rule

No prior navigation state may be reused without checking:

- version currency;
- authority currency;
- dependency currency;
- role currency;
- unresolved conditions;
- drift events;
- required revalidation.

## Trace Rule

Every decision must preserve:

- rule evaluated;
- evidence;
- authority;
- decision;
- timestamp;
- resulting state;
- next permitted action.

## Determinism Rule

Equivalent constitutional inputs must produce equivalent navigation decisions.
