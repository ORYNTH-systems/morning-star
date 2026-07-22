# MS-T7 Scoring Model

**Document Identifier:** MS-V1-T7-SCR-001  
**Version:** 0.1.0

## 1. Unsupported Scope Expansion Rate

\[
USER =
\frac{UnsupportedMaterialExpansions}
{ScopeInterpretationOpportunities}
\]

## 2. Scope Property Preservation Rate

\[
SPPR =
\frac{ScopePropertiesPreserved}
{ScopePropertiesAssessed}
\]

## 3. Scope Contraction Rate

\[
SCR =
\frac{UnsupportedMaterialContractions}
{ScopeInterpretationOpportunities}
\]

## 4. Authority Inflation Rate

\[
AIR =
\frac{AuthorityExpansionsWithoutSupport}
{AuthorityInterpretationOpportunities}
\]

## 5. Evidence Overreach Rate

\[
EOR =
\frac{ClaimsExceedingEvidence}
{EvidenceInterpretationOpportunities}
\]

## 6. Condition Erasure Rate

\[
CER =
\frac{MaterialConditionsErased}
{ConditionInterpretationOpportunities}
\]

## 7. Version Overreach Rate

\[
VOR =
\frac{UnsupportedVersionTransfers}
{VersionInterpretationOpportunities}
\]

## 8. Valid Derivation Recognition Rate

\[
VDRR =
\frac{CorrectValidDerivationClassifications}
{ValidDerivedExpansionCases}
\]

## 9. Condition Effect

\[
Effect =
USER_{ungoverned}
-
USER_{governed}
\]

A positive result favors governed scope preservation.

## 10. Preservation Utility Constraint

The theorem shall not be supported by expansion reduction alone.

Governed scope preservation shall also avoid excessive invalid contraction.

\[
ScopeUtility =
LowExpansion
\land
LowInvalidContraction
\land
HighValidDerivationRecognition
\]

## 11. Required Reporting

Report separately:

- governed unsupported-expansion rate;
- ungoverned unsupported-expansion rate;
- scope-property preservation rate;
- scope-contraction rate;
- authority-inflation rate;
- evidence-overreach rate;
- condition-erasure rate;
- version-overreach rate;
- application-overreach rate;
- exclusion-erasure rate;
- universalization rate;
- valid-derivation recognition rate;
- insufficient-evidence rate;
- disputed-assessment rate.

## 12. Prohibition

No aggregate score shall conceal:

- subject substitution;
- domain expansion;
- condition erasure;
- evidence overreach;
- authority inflation;
- version overreach;
- exclusion erasure;
- false derivation identity.
