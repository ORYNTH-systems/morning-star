# MS-T6 — Uncertainty Non-Erasure Trial

**Verification Identifier:** MS-VER-T6-001  
**Theorem Identifier:** MS-T6  
**Document Identifier:** MS-V1-T6-DES-001  
**Design Status:** Design Candidate  
**Version:** 0.1.0

## 1. Purpose

This trial evaluates whether governed interpretation preserves declared uncertainty more reliably than interpretive processes that permit unresolved states to be silently converted into certainty.

## 2. Canonical Theorem

Uncertainty is an evidence-bearing constitutional state and shall not be erased merely because interpretation, compression, aggregation, or action selection requires a determinate output.

\[
Uncertain(x)=1
\nRightarrow
Certain(x)=1
\]

A determinate decision may be produced while uncertainty remains preserved in the evidence and result state.

## 3. Research Hypothesis

Interpretive processes governed by explicit uncertainty-preservation rules will produce fewer unsupported certainty claims and lower uncertainty-erasure rates than processes without such rules.

## 4. Null Hypothesis

Explicit uncertainty preservation will produce no measurable difference in unsupported certainty claims, semantic fidelity, or decision quality.

## 5. Experimental Conditions

### Condition A — Governed Uncertainty Preservation

Observers or systems must:

- identify the source uncertainty state;
- preserve missingness;
- preserve approximation;
- preserve conflict;
- preserve indeterminacy;
- distinguish evidence from inference;
- distinguish decision from certainty;
- record residual uncertainty;
- cite supporting evidence.

### Condition B — Ungoverned Determinization

Observers or systems receive the same evidence but are not required to preserve the source uncertainty state.

### Condition C — Fully Determinate Control

Observers or systems receive evidence that supports a determinate conclusion.

## 6. Independent Variables

\[
X =
(UncertaintyClass,
InterpretationCondition,
EvidenceCompleteness,
DecisionRequirement)
\]

## 7. Dependent Variables

The trial measures:

- uncertainty-erasure rate;
- unsupported-certainty rate;
- missingness-preservation rate;
- conflict-preservation rate;
- approximation-preservation rate;
- indeterminacy-preservation rate;
- evidence-inference separation accuracy;
- decision-certainty conflation rate;
- traceability completeness;
- residual-uncertainty reporting rate.

## 8. Controlled Variables

Paired cases shall preserve:

- source evidence;
- question or task;
- available time;
- observer access;
- response format;
- action requirement;
- scoring rules;
- assessment criteria;
- governing version.

## 9. Uncertainty State Model

The source uncertainty state is represented as:

\[
U =
(Type,
Scope,
Source,
Evidence,
ResolutionState,
Materiality)
\]

Permitted uncertainty classes include:

- UNKNOWN;
- MISSING;
- PARTIAL;
- APPROXIMATE;
- CONFLICTING;
- INDETERMINATE;
- DISPUTED;
- UNVERIFIED;
- INSUFFICIENT_EVIDENCE;
- NOT_APPLICABLE.

## 10. Uncertainty Preservation

Uncertainty is preserved when:

1. the source uncertainty class remains identifiable;
2. no unsupported certainty claim replaces it;
3. the affected scope remains explicit;
4. the evidence basis remains traceable;
5. any inference remains labeled as inference;
6. any decision remains distinct from epistemic certainty.

## 11. Uncertainty Erasure

Uncertainty erasure occurs when:

- missing becomes known;
- approximate becomes exact;
- conflicting becomes resolved without evidence;
- indeterminate becomes determinate without authority;
- disputed becomes settled without adjudication;
- unverified becomes verified without verification;
- insufficient evidence becomes a positive or negative conclusion.

## 12. Decision Under Uncertainty

A decision may be admissible when uncertainty remains.

\[
Decision(a)=1
\]

does not imply:

\[
Certain(Evidence(a))=1
\]

The decision record shall preserve:

- decision basis;
- uncertainty state;
- risk assumption;
- authority;
- reversibility;
- review condition.

## 13. Source State Architecture

Each source state shall include:

- evidence object;
- uncertainty class;
- affected property;
- uncertainty source;
- materiality;
- resolution status;
- canonical interpretation;
- prohibited certainty claim.

## 14. Trial Case Architecture

Each trial case shall include:

- one source uncertainty state;
- one interpretation task;
- one decision requirement where applicable;
- one canonical uncertainty-preserving response;
- one prohibited unsupported-certainty response;
- one expected assessment disposition;
- one governing version.

## 15. Transformation Classes

Observed transformations shall be classified as:

- PRESERVED;
- NARROWED_WITH_EVIDENCE;
- RESOLVED_WITH_EVIDENCE;
- ERASURE;
- INFLATION;
- MISCLASSIFICATION;
- DECISION_WITH_PRESERVED_UNCERTAINTY;
- INSUFFICIENT_EVIDENCE;
- DISPUTED.

## 16. Primary Outcome

The primary outcome is:

\[
UncertaintyErasureRate =
\frac{ErasedMaterialUncertaintyStates}
{MaterialUncertaintyStatesAssessed}
\]

## 17. Unsupported Certainty Rate

\[
UCR =
\frac{UnsupportedCertaintyClaims}
{UncertainInterpretationOpportunities}
\]

## 18. Preservation Rate

\[
UPR =
\frac{PreservedUncertaintyStates}
{UncertaintyStatesAssessed}
\]

## 19. Success Condition

MS-T6 receives preliminary support when:

1. governed preservation produces a lower uncertainty-erasure rate;
2. unsupported certainty claims decrease;
3. source uncertainty remains traceable;
4. determinate decisions can still be produced where admissible;
5. fully determinate controls do not generate artificial uncertainty;
6. findings are reproducible across the declared case set.

## 20. Falsification Condition

MS-T6 is falsified within the tested scope when governed uncertainty preservation:

- does not reduce uncertainty erasure;
- produces no measurable fidelity benefit;
- materially prevents valid determinate conclusions;
- produces equivalent or greater unsupported claims;
- fails reproducibly across the declared case set.

## 21. Inconclusive Condition

The result remains inconclusive when:

- source uncertainty is improperly classified;
- canonical responses are disputed;
- paired cases are not equivalent;
- observers receive inconsistent evidence;
- decision requirements differ materially;
- evidence is incomplete;
- assessor agreement is inadequate.

## 22. Resolution

Uncertainty may be resolved only when:

- new evidence is introduced;
- evidence is validated;
- conflicts are adjudicated by valid authority;
- the resolution scope is explicit;
- the prior uncertainty state remains traceable;
- the resolution does not exceed the evidence.

## 23. Uncertainty Narrowing

Uncertainty narrowing occurs when evidence reduces uncertainty without eliminating it.

Examples include:

- UNKNOWN to PARTIAL;
- APPROXIMATE to narrower APPROXIMATE;
- CONFLICTING to PARTIALLY_RESOLVED;
- INDETERMINATE to bounded alternatives.

Narrowing shall not be reported as complete resolution.

## 24. Uncertainty Inflation

Uncertainty inflation occurs when a determinate state is made uncertain without evidentiary basis.

The trial shall measure both erasure and inflation.

## 25. Non-Compensable Properties

The following shall not be averaged away:

- missingness;
- conflict state;
- approximation status;
- indeterminacy;
- verification status;
- evidence sufficiency;
- governing version;
- uncertainty source.

## 26. Research Boundary

This trial evaluates semantic and evidentiary preservation of uncertainty.

It does not establish:

- universal risk tolerance;
- legal evidentiary standards;
- medical decision thresholds;
- financial suitability;
- that action must stop whenever uncertainty exists;
- that every uncertainty state is equally material.

## 27. Design Invariants

1. Unknown shall not become known without evidence.
2. Missing shall not become present by assumption.
3. Approximate shall not become exact without justification.
4. Conflict shall not disappear without resolution evidence.
5. Decision shall remain distinct from certainty.
6. Inference shall remain distinct from source evidence.
7. Resolution shall preserve prior uncertainty history.
8. Uncertainty inflation shall also be measured.
9. Non-compensable uncertainty failures shall remain visible.
10. Results shall not exceed the tested uncertainty class.
