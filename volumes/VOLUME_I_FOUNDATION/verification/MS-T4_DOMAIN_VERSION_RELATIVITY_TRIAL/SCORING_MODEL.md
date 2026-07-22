# MS-T4 Scoring Model

**Document Identifier:** MS-V1-T4-SCR-001  
**Version:** 0.1.0

## 1. Transfer Accuracy

\[
TA =
\frac{PreservedTargetProperties}
{TargetPropertiesAssessed}
\]

## 2. Transfer Error Rate

\[
TER =
\frac{TransferErrors}
{TargetPropertiesAssessed}
\]

## 3. Negative Transfer Rate

\[
NTR =
\frac{NegativeTransferErrors}
{TransferOpportunities}
\]

## 4. False Equivalence Rate

\[
FER =
\frac{UnsupportedEquivalenceClaims}
{TransferOpportunities}
\]

## 5. Version Error Rate

\[
VER =
\frac{GoverningVersionErrors}
{VersionAssessments}
\]

## 6. Authority Scope Error Rate

\[
ASER =
\frac{AuthorityScopeErrors}
{AuthorityAssessments}
\]

## 7. Revalidation Recognition Rate

\[
RRR =
\frac{CorrectRevalidationDeterminations}
{RevalidationAssessments}
\]

## 8. Transfer Distance Effect

\[
Effect =
TA_{same\ domain,\ same\ version}
-
TA_{cross\ domain\ or\ material\ version}
\]

A positive result indicates degradation across domain or version distance.

## 9. Required Reporting

Report separately:

- same-domain same-version accuracy;
- same-domain material-version accuracy;
- related-domain accuracy;
- distinct-domain accuracy;
- transfer error rate;
- negative-transfer rate;
- false-equivalence rate;
- governing-version error rate;
- authority-scope error rate;
- uncertainty-erasure rate;
- revalidation-recognition rate;
- partial-transfer rate;
- insufficient-evidence rate;
- disputed-assessment rate.

## 10. Prohibition

No aggregate score shall conceal:

- wrong target domain;
- wrong governing version;
- invalid authority transfer;
- dependency inversion;
- uncertainty erasure;
- unsupported universal competence;
- invalid transfer-rule use.
