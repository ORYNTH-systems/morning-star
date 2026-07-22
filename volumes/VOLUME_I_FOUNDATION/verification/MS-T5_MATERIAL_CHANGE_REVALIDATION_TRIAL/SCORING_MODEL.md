# MS-T5 Scoring Model

**Document Identifier:** MS-V1-T5-SCR-001  
**Version:** 0.1.0

## 1. Post-Revision Accuracy

\[
PRA =
\frac{CurrentPropertiesPreserved}
{CurrentPropertiesAssessed}
\]

## 2. Obsolete Rule Rate

\[
ORR =
\frac{ObsoleteRulesApplied}
{RevisionSensitiveOpportunities}
\]

## 3. Version Mixing Rate

\[
VMR =
\frac{MixedVersionResponses}
{ResponsesAssessed}
\]

## 4. Revision Recognition Rate

\[
RRR =
\frac{CorrectRevisionRecognitions}
{RevisionRecognitionOpportunities}
\]

## 5. Supersession Recognition Rate

\[
SRR =
\frac{CorrectSupersessionDeterminations}
{SupersessionAssessments}
\]

## 6. Revalidation Benefit

\[
RB =
PRA_{revalidated}
-
PRA_{not\ revalidated}
\]

A positive result favors governed revalidation.

## 7. Material Revision Effect

\[
MRE =
PRA_{nonmaterial\ control}
-
PRA_{material,\ not\ revalidated}
\]

## 8. Revalidation Success Rate

\[
RSR =
\frac{SuccessfulRevalidations}
{CompletedRevalidations}
\]

## 9. Required Reporting

Report separately:

- revalidated post-revision accuracy;
- non-revalidated post-revision accuracy;
- partial-revalidation accuracy;
- non-material control accuracy;
- obsolete-rule rate;
- version-mixing rate;
- revision-recognition rate;
- supersession-recognition rate;
- authority-error rate;
- dependency-error rate;
- boundary-error rate;
- uncertainty-error rate;
- insufficient-evidence rate;
- disputed-assessment rate.

## 10. Prohibition

No aggregate score shall conceal:

- wrong governing version;
- superseded authority use;
- obsolete boundary use;
- obsolete dependency order;
- uncertainty-state erasure;
- invalid compatibility assumption.
