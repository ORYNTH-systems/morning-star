# MS-T5 — Material Change Revalidation Trial

**Verification Identifier:** MS-VER-T5-001  
**Theorem Identifier:** MS-T5  
**Document Identifier:** MS-V1-T5-DES-001  
**Design Status:** Design Candidate  
**Version:** 0.1.0

## 1. Purpose

This trial evaluates whether a material constitutional revision creates measurable risk that prior observer verification no longer predicts current competence.

## 2. Canonical Theorem

A verified observer state is not permanently valid across material constitutional change.

\[
Verified(O,d,v_1)
\land
MaterialChange(v_1,v_2)
\nRightarrow
Verified(O,d,v_2)
\]

unless revalidation or an explicit compatibility rule establishes continuity.

## 3. Research Hypothesis

Observers who are not revalidated after a material revision will demonstrate lower post-revision semantic integrity than observers who complete governed revalidation.

## 4. Null Hypothesis

Material constitutional revision will not affect relevant observer competence, and revalidation will produce no measurable benefit.

## 5. Experimental Conditions

### Condition A — Revalidated Observer

The observer receives:

- formal change notice;
- material-change classification;
- affected-property list;
- superseded-rule identification;
- revised canonical material;
- governed revalidation;
- current-version confirmation.

### Condition B — Non-Revalidated Observer

The observer is evaluated against the revised framework without completing governed revalidation.

### Condition C — Non-Material Revision Control

The observer is evaluated after a revision classified as non-material.

## 6. Independent Variables

\[
X =
(RevisionClass,
RevisionMagnitude,
AffectedProperty,
RevalidationStatus)
\]

where:

- `RevisionClass` is NON_MATERIAL, MATERIAL, BREAKING, or INDETERMINATE;
- `RevisionMagnitude` records the scope of affected architecture;
- `AffectedProperty` identifies the changed material property;
- `RevalidationStatus` is COMPLETED, NOT_COMPLETED, PARTIAL, or NOT_REQUIRED.

## 7. Dependent Variables

The trial measures:

- post-revision reconstruction accuracy;
- obsolete-rule use;
- version-mixing frequency;
- governing-version accuracy;
- dependency-order error;
- authority-scope error;
- boundary error;
- uncertainty-state error;
- revision-recognition accuracy;
- revalidation-completion accuracy.

## 8. Controlled Variables

Paired cases shall preserve:

- observer identity;
- pre-revision baseline competence;
- source domain;
- target task;
- allotted review period;
- assessment criteria;
- scoring rules;
- evaluator instructions;
- governing revision package.

The controlled difference shall be revalidation status.

## 9. Material Revision Model

A revision is represented as:

\[
R =
(SourceVersion,
TargetVersion,
ChangeClass,
AffectedObjects,
AffectedProperties,
CompatibilityState)
\]

## 10. Material Change Classes

Permitted material change classes include:

- IDENTITY_CHANGE;
- DEFINITION_CHANGE;
- BOUNDARY_CHANGE;
- DEPENDENCY_CHANGE;
- AUTHORITY_CHANGE;
- PARTICIPATION_CHANGE;
- UNCERTAINTY_CHANGE;
- PROCEDURE_CHANGE;
- VERIFICATION_CHANGE;
- INTERPRETATION_CHANGE;
- MULTI_PROPERTY_CHANGE.

## 11. Revalidation Requirement

Revalidation is required when:

\[
MaterialChange(v_1,v_2)=1
\]

and the observer's verified competence depends upon an affected property.

## 12. Compatibility Rule

A compatibility rule may preserve prior verification only when it declares:

- source version;
- target version;
- unaffected capabilities;
- affected capabilities;
- required limitations;
- evidence basis;
- authority source;
- expiration condition.

Silence shall not constitute compatibility.

## 13. Observer Baseline

Each observer baseline shall include:

- observer identifier;
- domain;
- verified version;
- verified capabilities;
- verification evidence;
- verification date;
- limitations;
- authority scope;
- expiration state.

## 14. Revalidation Case Architecture

Each case shall include:

- observer baseline;
- source version;
- target version;
- revision class;
- affected material properties;
- revalidation condition;
- current canonical answer;
- superseded answer;
- expected disposition;
- post-revision task.

## 15. Post-Revision Error Classes

Errors shall include:

- OBSOLETE_RULE_USE;
- VERSION_MIXING;
- SUPERSEDED_AUTHORITY_USE;
- OLD_BOUNDARY_APPLICATION;
- OLD_DEPENDENCY_ORDER;
- UNCERTAINTY_STATE_ERASURE;
- REVISION_NON_RECOGNITION;
- INVALID_COMPATIBILITY_ASSUMPTION.

## 16. Primary Outcome

The primary outcome is:

\[
PostRevisionAccuracy =
\frac{CurrentPropertiesPreserved}
{CurrentPropertiesAssessed}
\]

## 17. Obsolete Rule Rate

\[
ORR =
\frac{ObsoleteRulesApplied}
{RevisionSensitiveOpportunities}
\]

## 18. Version Mixing Rate

\[
VMR =
\frac{MixedVersionResponses}
{ResponsesAssessed}
\]

## 19. Success Condition

MS-T5 receives preliminary support when:

1. non-revalidated observers demonstrate lower post-revision accuracy;
2. obsolete-rule or version-mixing errors increase without revalidation;
3. revalidated observers more reliably identify the current governing version;
4. the effect is concentrated in revision-sensitive properties;
5. non-material revision controls do not produce equivalent degradation;
6. results are reproducible across the declared case set.

## 20. Falsification Condition

MS-T5 is falsified for the tested revision class when:

- non-revalidated observers perform equivalently to revalidated observers;
- material changes do not affect relevant competence;
- obsolete-rule and version-mixing rates remain equivalent;
- the result is reproducible with adequate measurement reliability.

## 21. Inconclusive Condition

The result remains inconclusive when:

- revision materiality is disputed;
- observer baselines are incomplete;
- revalidation packages differ materially;
- current and superseded answers are ambiguous;
- cases are not revision-sensitive;
- evidence is insufficient;
- assessor agreement is inadequate.

## 22. Partial Revalidation

Partial revalidation shall identify:

- capabilities revalidated;
- capabilities not revalidated;
- permissible scope;
- prohibited scope;
- expiration conditions;
- remaining uncertainty.

Partial revalidation shall not be reported as full current competence.

## 23. Revision Awareness

Revision awareness alone does not establish current competence.

\[
AwareOfRevision(O)=1
\nRightarrow
CompetentUnderRevision(O)=1
\]

The observer must demonstrate preservation of affected material properties.

## 24. Non-Compensable Properties

The following shall not be averaged away:

- governing version;
- authority source;
- constitutional boundary;
- dependency direction;
- uncertainty state;
- revision identity;
- supersession state.

## 25. Research Boundary

This trial evaluates competence continuity after material framework revision.

It does not establish:

- universal retraining requirements;
- professional credential expiration;
- legal recertification rules;
- permanent invalidity of prior competence;
- that every revision requires full revalidation.

## 26. Design Invariants

1. Materiality shall be classified before execution.
2. Source and target versions shall be explicit.
3. Superseded rules shall remain traceable.
4. Revalidation status shall be recorded.
5. Revision awareness shall remain distinct from competence.
6. Partial revalidation shall remain bounded.
7. Non-material controls shall be included.
8. Version mixing shall remain individually visible.
9. Missing evidence shall remain missing.
10. Results shall not exceed the tested revision class.
