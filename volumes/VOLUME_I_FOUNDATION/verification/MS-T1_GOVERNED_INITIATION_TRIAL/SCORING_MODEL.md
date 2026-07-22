# MS-T1 Scoring Model

**Document Identifier:** MS-V1-T1-SCR-001  
**Version:** 0.1.0

## 1. Property Values

For each material property \(p\):

\[
d_p =
\begin{cases}
0, & PRESERVED \\
1, & DIVERGENT \\
\bot, & INSUFFICIENT\_EVIDENCE \\
\delta, & DISPUTED
\end{cases}
\]

## 2. Material Semantic Divergence Rate

\[
MSDR =
\frac{D}{P + D}
\]

where:

- \(D\) is the number of materially divergent properties;
- \(P\) is the number of materially preserved properties.

Insufficient and disputed assessments shall be reported separately and shall not be silently included as preserved.

## 3. Non-Compensable Failure Rate

\[
NCFR =
\frac{N_D}{N_A}
\]

where:

- \(N_D\) is the number of divergent non-compensable properties;
- \(N_A\) is the number of assessed non-compensable properties.

## 4. Condition Effect

\[
Effect =
MSDR_{unrestricted}
-
MSDR_{governed}
\]

A positive value favors governed initiation.

A positive value alone does not establish theorem support.

## 5. Required Reporting

Report separately:

- material divergence rate;
- non-compensable failure rate;
- insufficient-evidence rate;
- disputed-assessment rate;
- observer completion rate;
- assessor agreement;
- protocol-deviation count;
- case-level results;
- condition-level results.

## 6. Prohibition

No aggregate score may conceal a divergent non-compensable property.
