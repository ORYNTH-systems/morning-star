# MS-T3 Scoring Model

**Document Identifier:** MS-V1-T3-SCR-001  
**Version:** 0.1.0

## 1. Unauthorized Action Rate

\[
UAR =
\frac{UnauthorizedActions}{ActionOpportunities}
\]

## 2. Valid Action Completion Rate

\[
VACR =
\frac{ValidAuthorizedActionsCompleted}{ValidAuthorizedActionOpportunities}
\]

## 3. False Block Rate

\[
FBR =
\frac{FalseBlocks}{ValidAuthorizedActionOpportunities}
\]

## 4. Scope Violation Rate

\[
SVR =
\frac{RoleScopeViolations + DomainScopeViolations + ActionScopeViolations}
{ActionOpportunities}
\]

## 5. Authority Verification Accuracy

\[
AVA =
\frac{CorrectAuthorityDeterminations}
{AuthorityDeterminations}
\]

## 6. Capability Verification Accuracy

\[
CVA =
\frac{CorrectCapabilityDeterminations}
{CapabilityDeterminations}
\]

## 7. Traceability Completeness

\[
TC =
\frac{DecisionsWithCompleteAuthorityEvidence}
{DecisionsAssessed}
\]

## 8. Accountability Ambiguity Rate

\[
AAR =
\frac{ActionsWithUnresolvedResponsibility}
{ActionsAssessed}
\]

## 9. Condition Effect

\[
Effect_{UAR}
=
UAR_{capability\ inference}
-
UAR_{explicit\ assignment}
\]

A positive result favors explicit authority assignment.

## 10. Governance Utility Constraint

The theorem shall not be supported by unauthorized-action reduction alone.

The explicit-assignment condition shall also maintain an admissible valid-action completion rate.

\[
GovernanceUtility =
LowUnauthorizedAction
\land
AcceptableValidActionCompletion
\]

## 11. Required Reporting

Report separately:

- unauthorized-action rate;
- valid-action completion rate;
- false-block rate;
- scope-violation rate;
- expired-authority violation rate;
- revoked-authority violation rate;
- invalid-delegation rate;
- version-mismatch rate;
- traceability completeness;
- accountability ambiguity;
- disputed-assessment rate;
- insufficient-evidence rate.

## 12. Prohibition

No aggregate score shall conceal:

- invalid authority source;
- revoked authority;
- expired authority;
- role mismatch;
- domain mismatch;
- action-scope mismatch;
- invalid delegation;
- governing-version mismatch.
