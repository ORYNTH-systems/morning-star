# MS-T6 Scoring Model

**Document Identifier:** MS-V1-T6-SCR-001  
**Version:** 0.1.0

## 1. Uncertainty Erasure Rate

\[
UER =
\frac{ErasedMaterialUncertaintyStates}
{MaterialUncertaintyStatesAssessed}
\]

## 2. Unsupported Certainty Rate

\[
UCR =
\frac{UnsupportedCertaintyClaims}
{UncertainInterpretationOpportunities}
\]

## 3. Uncertainty Preservation Rate

\[
UPR =
\frac{PreservedUncertaintyStates}
{UncertaintyStatesAssessed}
\]

## 4. Uncertainty Inflation Rate

\[
UIR =
\frac{UnsupportedUncertaintyInflations}
{DeterminateControlOpportunities}
\]

## 5. Valid Resolution Rate

\[
VRR =
\frac{EvidenceSupportedResolutions}
{ResolutionClaims}
\]

## 6. Valid Narrowing Rate

\[
VNR =
\frac{EvidenceSupportedNarrowings}
{NarrowingClaims}
\]

## 7. Decision-Certainty Conflation Rate

\[
DCCR =
\frac{DecisionsReportedAsCertainty}
{DecisionsUnderUncertainty}
\]

## 8. Residual Uncertainty Reporting Rate

\[
RURR =
\frac{ResponsesReportingResidualUncertainty}
{ResponsesWithResidualUncertainty}
\]

## 9. Condition Effect

\[
Effect =
UER_{ungoverned}
-
UER_{governed}
\]

A positive result favors governed uncertainty preservation.

## 10. Required Reporting

Report separately:

- governed uncertainty-erasure rate;
- ungoverned uncertainty-erasure rate;
- unsupported-certainty rate;
- preservation rate;
- inflation rate;
- valid-resolution rate;
- valid-narrowing rate;
- decision-certainty conflation rate;
- residual-uncertainty reporting rate;
- traceability completeness;
- insufficient-evidence rate;
- disputed-assessment rate.

## 11. Prohibition

No aggregate score shall conceal:

- missingness erasure;
- conflict erasure;
- approximation converted to exactness;
- indeterminacy converted to certainty;
- unverified converted to verified;
- insufficient evidence converted to conclusion.
