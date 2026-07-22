# MS-T9 Scoring Model

**Document Identifier:** MS-V1-T9-SCR-001  
**Version:** 0.1.0

## 1. Continuity Accuracy

\[
CA =
\frac{MaterialPropertiesPreserved}
{MaterialPropertiesAssessed}
\]

## 2. Authority Continuity Rate

\[
ACR =
\frac{CorrectAuthorityDeterminations}
{AuthorityAssessments}
\]

## 3. Scope Preservation Rate

\[
SPR =
\frac{ScopePropertiesPreserved}
{ScopePropertiesAssessed}
\]

## 4. Obligation Preservation Rate

\[
OPR =
\frac{OpenObligationsPreserved}
{OpenObligationsTransferred}
\]

## 5. Unauthorized Change Rate

\[
UCR =
\frac{UnauthorizedMaterialChanges}
{MaterialChangeOpportunities}
\]

## 6. Transition Ambiguity Rate

\[
TAR =
\frac{AmbiguousMaterialProperties}
{MaterialTransitionPropertiesAssessed}
\]

## 7. Operational Continuity Rate

\[
OCR =
\frac{ValidSuccessorDecisions}
{OperationalContinuityTasks}
\]

## 8. Acceptance Accuracy Rate

\[
AAR =
\frac{CorrectAcceptanceDeterminations}
{AcceptanceAssessments}
\]

## 9. Governed Transition Effect

\[
Effect =
CA_{governed}
-
CA_{informal\ or\ broken}
\]

A positive result favors governed stewardship transition.

## 10. Continuity Utility Constraint

The theorem shall not be supported by continuity accuracy alone.

\[
ContinuityUtility =
HighContinuity
\land
ValidAuthority
\land
LowUnauthorizedChange
\land
ObligationPreservation
\]

## 11. Required Reporting

Report separately:

- governed-transition continuity accuracy;
- informal-transition continuity accuracy;
- broken-transition continuity accuracy;
- no-transition-control accuracy;
- authority continuity rate;
- scope preservation rate;
- governing-version accuracy;
- dependency preservation rate;
- uncertainty preservation rate;
- obligation preservation rate;
- unauthorized-change rate;
- transition ambiguity rate;
- acceptance accuracy rate;
- operational continuity rate;
- insufficient-evidence rate;
- disputed-assessment rate.

## 12. Prohibition

No aggregate score shall conceal:

- object-identity failure;
- invalid authority transfer;
- scope expansion;
- wrong governing version;
- dependency loss;
- uncertainty erasure;
- abandoned obligations;
- missing acceptance;
- unauthorized material change.
