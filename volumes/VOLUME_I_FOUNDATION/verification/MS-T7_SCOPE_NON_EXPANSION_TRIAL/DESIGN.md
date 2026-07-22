# MS-T7 — Scope Non-Expansion Trial

**Verification Identifier:** MS-VER-T7-001  
**Theorem Identifier:** MS-T7  
**Document Identifier:** MS-V1-T7-DES-001  
**Design Status:** Design Candidate  
**Version:** 0.1.0

## 1. Purpose

This trial evaluates whether governed interpretation prevents a bounded canonical claim from being expanded beyond its declared subject, domain, conditions, evidence, authority, version, or intended application.

## 2. Canonical Theorem

Interpretation shall not expand the valid scope of a canonical claim.

Let:

\[
S(C)=
(Subject,
Domain,
Conditions,
Evidence,
Authority,
Version,
Application)
\]

Then an interpretation \(I\) is scope-admissible only when:

\[
S(I) \subseteq S(C)
\]

unless an independently governed derivation explicitly establishes a broader claim.

## 3. Research Hypothesis

Observers using explicit scope-preservation rules will produce fewer unsupported scope expansions than observers interpreting the same claims without governed scope controls.

## 4. Null Hypothesis

Explicit scope-preservation rules will produce no measurable reduction in unsupported expansion, overgeneralization, or authority inflation.

## 5. Experimental Conditions

### Condition A — Governed Scope Preservation

Observers must identify and preserve:

- canonical subject;
- governed domain;
- applicable conditions;
- evidence boundary;
- authority boundary;
- governing version;
- intended application;
- exclusions;
- unresolved limitations.

### Condition B — Ungoverned Interpretation

Observers receive the same canonical source but no explicit requirement to preserve its scope properties.

### Condition C — Valid Derived Expansion

Observers receive additional evidence and authority sufficient to support a broader independently governed claim.

## 6. Independent Variables

\[
X =
(InterpretationCondition,
ClaimComplexity,
ScopeProperty,
DerivationEvidence)
\]

## 7. Dependent Variables

The trial measures:

- unsupported scope-expansion rate;
- subject-expansion rate;
- domain-expansion rate;
- condition-erasure rate;
- evidence-overreach rate;
- authority-inflation rate;
- version-overreach rate;
- application-overreach rate;
- exclusion-erasure rate;
- valid-derivation recognition rate.

## 8. Controlled Variables

Paired cases shall preserve:

- canonical source claim;
- available evidence;
- observer access;
- response prompt;
- allotted review period;
- scoring criteria;
- evaluator instructions;
- governing version.

## 9. Scope Model

A canonical claim scope is represented as:

\[
S_C =
(Sub,D,C,E,A,V,P,X)
\]

where:

- \(Sub\) is the subject;
- \(D\) is the governed domain;
- \(C\) is the applicable condition set;
- \(E\) is the evidence boundary;
- \(A\) is the authority boundary;
- \(V\) is the governing version;
- \(P\) is the permitted application;
- \(X\) is the exclusion set.

## 10. Scope Expansion

A scope expansion occurs when an interpretation asserts applicability beyond at least one canonical property without sufficient independent support.

Permitted expansion classes include:

- SUBJECT_EXPANSION;
- DOMAIN_EXPANSION;
- CONDITION_ERASURE;
- EVIDENCE_OVERREACH;
- AUTHORITY_INFLATION;
- VERSION_OVERREACH;
- APPLICATION_OVERREACH;
- EXCLUSION_ERASURE;
- UNIVERSALIZATION;
- FALSE_EQUIVALENCE.

## 11. Scope Preservation

Scope is preserved when:

1. the canonical subject remains unchanged;
2. domain applicability remains bounded;
3. conditions remain explicit;
4. evidence is not overstated;
5. authority is not enlarged;
6. version applicability remains current;
7. application remains within declared use;
8. exclusions remain visible;
9. uncertainty and limitations remain preserved.

## 12. Valid Derived Expansion

A broader claim may be admissible only when a separate derivation establishes:

- additional evidence;
- valid inferential method;
- explicit authority;
- declared broader scope;
- affected limitations;
- traceability to the source claim;
- independent verification status.

A valid derived claim shall not be represented as the original canonical claim.

## 13. Source Claim Architecture

Each source claim shall include:

- claim identifier;
- canonical text;
- subject;
- domain;
- conditions;
- evidence boundary;
- authority boundary;
- governing version;
- intended application;
- exclusions;
- uncertainty state;
- canonical source.

## 14. Trial Case Architecture

Each trial case shall include:

- one canonical source claim;
- one targeted scope property;
- one interpretation task;
- one experimental condition;
- one canonical bounded interpretation;
- one prohibited expanded interpretation;
- one expected disposition.

## 15. Interpretation Classes

Responses shall be classified as:

- SCOPE_PRESERVED;
- VALID_DERIVED_EXPANSION;
- PARTIAL_SCOPE_PRESERVATION;
- UNSUPPORTED_SCOPE_EXPANSION;
- SCOPE_CONTRACTION;
- SCOPE_MISCLASSIFICATION;
- INSUFFICIENT_EVIDENCE;
- DISPUTED;
- NOT_APPLICABLE.

## 16. Primary Outcome

The primary outcome is:

\[
UnsupportedScopeExpansionRate =
\frac{UnsupportedMaterialExpansions}
{ScopeInterpretationOpportunities}
\]

## 17. Property Preservation Rate

\[
SPR =
\frac{ScopePropertiesPreserved}
{ScopePropertiesAssessed}
\]

## 18. Valid Derivation Recognition Rate

\[
VDRR =
\frac{CorrectlyRecognizedDerivedClaims}
{ValidDerivedExpansionCases}
\]

## 19. Success Condition

MS-T7 receives preliminary support when:

1. governed interpretation produces fewer unsupported expansions;
2. material scope properties remain more accurately preserved;
3. valid derived expansions remain distinguishable from the source claim;
4. authority and evidence boundaries remain traceable;
5. the control condition does not merely cause indiscriminate contraction;
6. results are reproducible across the declared case set.

## 20. Falsification Condition

MS-T7 is falsified within the tested claim class when explicit scope governance:

- does not reduce unsupported expansion;
- prevents valid derived interpretation;
- materially increases incorrect scope contraction;
- produces no reproducible preservation benefit.

## 21. Inconclusive Condition

The result remains inconclusive when:

- canonical claim scope is ambiguous;
- exclusions are under-specified;
- evidence boundaries are disputed;
- authority boundaries are unclear;
- paired cases are not equivalent;
- derivation evidence is incomplete;
- assessor agreement is inadequate.

## 22. Scope Contraction

Scope contraction occurs when an interpretation invalidly narrows a claim below its canonical scope.

The trial shall measure both expansion and contraction.

Scope preservation does not mean minimizing every claim.

## 23. Universalization

Universalization occurs when a bounded claim is presented as universally applicable without sufficient derivation.

Examples include converting:

- one tested system into all systems;
- one domain into all domains;
- one version into all versions;
- one observer population into all observers;
- one condition into unconditional applicability;
- one evidentiary result into an absolute law.

## 24. Authority Inflation

Authority inflation occurs when a source with limited authority is interpreted as establishing authority beyond its declared jurisdiction, role, domain, action class, or version.

Capability, publication, authorship, expertise, or performance shall not silently enlarge authority.

## 25. Non-Compensable Properties

The following shall not be averaged away:

- subject identity;
- domain boundary;
- applicability conditions;
- evidence boundary;
- authority boundary;
- governing version;
- exclusion state;
- derivation identity.

## 26. Research Boundary

This trial evaluates scope preservation in governed interpretation.

It does not establish:

- legal claim construction;
- judicial interpretation rules;
- universal scientific generalization standards;
- that broader derivations are prohibited;
- that every claim must remain permanently unchanged.

## 27. Design Invariants

1. Every source claim shall have an explicit scope profile.
2. Interpretation shall remain distinguishable from derivation.
3. Derived claims shall receive distinct identifiers.
4. Evidence boundaries shall remain visible.
5. Authority shall not expand through interpretation alone.
6. Conditions shall not disappear silently.
7. Version applicability shall remain explicit.
8. Exclusions shall remain traceable.
9. Scope contraction shall also be measured.
10. Results shall not exceed the tested claim class.
