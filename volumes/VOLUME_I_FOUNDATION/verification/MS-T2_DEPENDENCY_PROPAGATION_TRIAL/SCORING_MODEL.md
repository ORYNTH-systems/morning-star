# MS-T2 Scoring Model

**Document Identifier:** MS-V1-T2-SCR-001  
**Version:** 0.1.0

## 1. Downstream Divergence Rate

\[
DDR =
\frac{P_D + I_D}{A_D}
\]

where:

- \(P_D\) is propagated material divergence;
- \(I_D\) is independent material divergence;
- \(A_D\) is assessed downstream material properties.

For theorem-specific analysis, propagated and independent divergence shall also be reported separately.

## 2. Propagated Divergence Rate

\[
PDR =
\frac{P_D}{A_D}
\]

## 3. Propagation Breadth

\[
PB =
\frac{ObjectsAffected}{ObjectsExposed}
\]

## 4. Propagation Depth

\[
PD =
\max(LevelAffected)
\]

## 5. Correction Success Rate

\[
CSR =
\frac{CorrectedEvents}{CorrectionAttempts}
\]

## 6. Residual Divergence Rate

\[
RDR =
\frac{ResidualDivergences}{CorrectedEvents}
\]

## 7. Condition Effect

\[
Effect =
PDR_{divergent}
-
PDR_{canonical}
\]

A positive value indicates greater propagation under the divergent condition.

## 8. Required Reporting

Report separately:

- canonical-condition divergence;
- divergent-condition divergence;
- propagated divergence;
- independent divergence;
- propagation breadth;
- propagation depth;
- correction attempts;
- correction success;
- residual divergence;
- insufficient-evidence rate;
- disputed-classification rate;
- non-compensable failures.

## 9. Prohibition

An aggregate score shall not conceal:

- dependency inversion;
- authority inflation;
- uncertainty erasure;
- identity substitution;
- version substitution;
- traceability failure.
