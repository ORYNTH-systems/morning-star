# MS-T8 Scoring Model

**Document Identifier:** MS-V1-T8-SCR-001  
**Version:** 0.1.0

## 1. Reconstruction Accuracy

\[
RA =
\frac{CorrectlyRecoveredMaterialProperties}
{MaterialPropertiesAssessed}
\]

## 2. Traceability Completeness Rate

\[
TCR =
\frac{ResolvedMaterialLinks}
{RequiredMaterialLinks}
\]

## 3. Provenance Ambiguity Rate

\[
PAR =
\frac{AmbiguousMaterialProperties}
{MaterialPropertiesAssessed}
\]

## 4. Unsupported Reconstruction Rate

\[
URR =
\frac{UnsupportedRecoveredProperties}
{RecoveredPropertiesClaimed}
\]

## 5. Identity Recovery Rate

\[
IRR =
\frac{CorrectObjectIdentityRecoveries}
{IdentityAssessments}
\]

## 6. Version Recovery Rate

\[
VRR =
\frac{CorrectVersionRecoveries}
{VersionAssessments}
\]

## 7. Authority Recovery Rate

\[
ARR =
\frac{CorrectAuthorityRecoveries}
{AuthorityAssessments}
\]

## 8. Dependency Recovery Rate

\[
DRR =
\frac{CorrectDependencyRecoveries}
{DependencyAssessments}
\]

## 9. Transformation Recovery Rate

\[
TRR =
\frac{CorrectTransformationRecoveries}
{TransformationAssessments}
\]

## 10. Uncertainty Recovery Rate

\[
URR_{uncertainty} =
\frac{CorrectUncertaintyRecoveries}
{UncertaintyAssessments}
\]

## 11. Complete-Chain Effect

\[
Effect =
RA_{complete}
-
RA_{partial\ or\ broken}
\]

A positive result favors governed traceability completeness.

## 12. Required Reporting

Report separately:

- complete-chain reconstruction accuracy;
- partial-chain reconstruction accuracy;
- broken-chain reconstruction accuracy;
- determinate-control reconstruction accuracy;
- traceability completeness rate;
- provenance ambiguity rate;
- unsupported reconstruction rate;
- identity recovery rate;
- canonical-source recovery rate;
- version recovery rate;
- authority recovery rate;
- dependency recovery rate;
- transformation recovery rate;
- uncertainty recovery rate;
- supersession recovery rate;
- insufficient-evidence rate;
- disputed-assessment rate.

## 13. Prohibition

No aggregate score shall conceal:

- object-identity failure;
- governing-version failure;
- authority-source failure;
- dependency inversion;
- transformation-order failure;
- missing evidence;
- uncertainty erasure;
- supersession failure;
- unsupported reconstruction.
