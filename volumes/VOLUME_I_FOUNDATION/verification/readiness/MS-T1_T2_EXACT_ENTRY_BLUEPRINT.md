# MS-T1 and MS-T2 Exact Entry Blueprint

**Generated:** 2026-07-23T17:42:36-05:00

This blueprint records exact schemas, current values, missing fields, entry authorities, and governing source documents.

## MS-T1

**Trial:** `MS-T1_GOVERNED_INITIATION_TRIAL`

### TRIAL_CASES.csv

**Working path:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T1_CONTROLLED_EXECUTION\01_INPUT\TRIAL_CASES.csv`

**Collection copy:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T1_CONTROLLED_EXECUTION\00_COLLECTION_PACKET\TRIAL_CASES.COLLECTION_COPY.csv`

**Current row count:** 1

#### Schema

```text
"CaseID","GovernedObjectID","FrameworkID","GoverningVersion","MaterialPropertyCount","CanonicalSource","DependencyIDs","AuthoritySource","UncertaintyState","CaseStatus"
```

#### Current Rows

##### CSV Row 2

| Field | Current Value |
|---|---|
| CaseID | MS-T1-CASE-001 |
| GovernedObjectID | **MISSING** |
| FrameworkID | **MISSING** |
| GoverningVersion | **MISSING** |
| MaterialPropertyCount | **MISSING** |
| CanonicalSource | **MISSING** |
| DependencyIDs | **MISSING** |
| AuthoritySource | **MISSING** |
| UncertaintyState | **MISSING** |
| CaseStatus | DRAFT |

#### Field Authorities

| # | Field | Identity | Authority | Instruction |
|---:|---|---|---|---|
| 1 | CaseID | True | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | GovernedObjectID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 3 | FrameworkID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 4 | GoverningVersion | False | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 5 | MaterialPropertyCount | False | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 6 | CanonicalSource | False | GOVERNED_CASE_DESIGN | Provide a traceable reference to the supporting controlled source or observation. |
| 7 | DependencyIDs | False | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 8 | AuthoritySource | False | GOVERNED_CASE_DESIGN | Provide a traceable reference to the supporting controlled source or observation. |
| 9 | UncertaintyState | False | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 10 | CaseStatus | False | GOVERNED_CASE_DESIGN | Use only an authorized value defined by the trial procedure or data dictionary. |

#### Missing-Value Worklist

| CSV Row | Identity | Missing Field | Authority | Instruction |
|---|---|---|---|---|
| 2 | MS-T1-CASE-001 | GovernedObjectID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | MS-T1-CASE-001 | FrameworkID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | MS-T1-CASE-001 | GoverningVersion | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 2 | MS-T1-CASE-001 | MaterialPropertyCount | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 2 | MS-T1-CASE-001 | CanonicalSource | GOVERNED_CASE_DESIGN | Provide a traceable reference to the supporting controlled source or observation. |
| 2 | MS-T1-CASE-001 | DependencyIDs | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 2 | MS-T1-CASE-001 | AuthoritySource | GOVERNED_CASE_DESIGN | Provide a traceable reference to the supporting controlled source or observation. |
| 2 | MS-T1-CASE-001 | UncertaintyState | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |

### OBSERVER_RESPONSES.csv

**Working path:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T1_CONTROLLED_EXECUTION\02_EVIDENCE\OBSERVER_RESPONSES.csv`

**Collection copy:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T1_CONTROLLED_EXECUTION\00_COLLECTION_PACKET\OBSERVER_RESPONSES.COLLECTION_COPY.csv`

**Current row count:** 1

#### Schema

```text
"ResponseID","ObserverID","CaseID","EntryCondition","ObserverClass","PriorExposure","SubmittedAt","ResponseText","SourceReferences","DeclaredUncertainty","ResponseStatus"
```

#### Current Rows

##### CSV Row 2

| Field | Current Value |
|---|---|
| ResponseID | **MISSING** |
| ObserverID | **MISSING** |
| CaseID | **MISSING** |
| EntryCondition | **MISSING** |
| ObserverClass | **MISSING** |
| PriorExposure | **MISSING** |
| SubmittedAt | **MISSING** |
| ResponseText | **MISSING** |
| SourceReferences | **MISSING** |
| DeclaredUncertainty | **MISSING** |
| ResponseStatus | **MISSING** |

#### Field Authorities

| # | Field | Identity | Authority | Instruction |
|---:|---|---|---|---|
| 1 | ResponseID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | ObserverID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 3 | CaseID | True | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 4 | EntryCondition | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 5 | ObserverClass | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 6 | PriorExposure | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 7 | SubmittedAt | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 8 | ResponseText | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 9 | SourceReferences | False | OBSERVED_EXECUTION_ONLY | Provide a traceable reference to the supporting controlled source or observation. |
| 10 | DeclaredUncertainty | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 11 | ResponseStatus | False | OBSERVED_EXECUTION_ONLY | Use only an authorized value defined by the trial procedure or data dictionary. |

#### Missing-Value Worklist

| CSV Row | Identity | Missing Field | Authority | Instruction |
|---|---|---|---|---|
| 2 | UNASSIGNED-ROW-2 | ResponseID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | ObserverID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | CaseID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | EntryCondition | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | ObserverClass | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | PriorExposure | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | SubmittedAt | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | ResponseText | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | SourceReferences | OBSERVED_EXECUTION_ONLY | Provide a traceable reference to the supporting controlled source or observation. |
| 2 | UNASSIGNED-ROW-2 | DeclaredUncertainty | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | ResponseStatus | OBSERVED_EXECUTION_ONLY | Use only an authorized value defined by the trial procedure or data dictionary. |

### SEMANTIC_ASSESSMENTS.csv

**Working path:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T1_CONTROLLED_EXECUTION\03_ASSESSMENT\SEMANTIC_ASSESSMENTS.csv`

**Collection copy:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T1_CONTROLLED_EXECUTION\00_COLLECTION_PACKET\SEMANTIC_ASSESSMENTS.COLLECTION_COPY.csv`

**Current row count:** 1

#### Schema

```text
"AssessmentID","ResponseID","PropertyID","PropertyClass","Compensability","AssessorID","AssessmentResult","Materiality","EvidenceReference","Rationale","AdjudicationStatus","FinalResult"
```

#### Current Rows

##### CSV Row 2

| Field | Current Value |
|---|---|
| AssessmentID | **MISSING** |
| ResponseID | **MISSING** |
| PropertyID | **MISSING** |
| PropertyClass | **MISSING** |
| Compensability | **MISSING** |
| AssessorID | **MISSING** |
| AssessmentResult | **MISSING** |
| Materiality | **MISSING** |
| EvidenceReference | **MISSING** |
| Rationale | **MISSING** |
| AdjudicationStatus | **MISSING** |
| FinalResult | **MISSING** |

#### Field Authorities

| # | Field | Identity | Authority | Instruction |
|---:|---|---|---|---|
| 1 | AssessmentID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | ResponseID | True | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 3 | PropertyID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 4 | PropertyClass | False | GOVERNED_ASSESSOR_JUDGMENT | Assess against the declared semantic criteria and cite the supporting response evidence. |
| 5 | Compensability | False | GOVERNED_ASSESSOR_JUDGMENT | Assess against the declared semantic criteria and cite the supporting response evidence. |
| 6 | AssessorID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 7 | AssessmentResult | False | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |
| 8 | Materiality | False | GOVERNED_ASSESSOR_JUDGMENT | Assess against the declared semantic criteria and cite the supporting response evidence. |
| 9 | EvidenceReference | False | GOVERNED_ASSESSOR_JUDGMENT | Provide a traceable reference to the supporting controlled source or observation. |
| 10 | Rationale | False | GOVERNED_ASSESSOR_JUDGMENT | State the evidence-based rationale. Preserve uncertainty and contradictory observations. |
| 11 | AdjudicationStatus | False | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |
| 12 | FinalResult | False | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |

#### Missing-Value Worklist

| CSV Row | Identity | Missing Field | Authority | Instruction |
|---|---|---|---|---|
| 2 | UNASSIGNED-ROW-2 | AssessmentID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | ResponseID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | PropertyID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | PropertyClass | GOVERNED_ASSESSOR_JUDGMENT | Assess against the declared semantic criteria and cite the supporting response evidence. |
| 2 | UNASSIGNED-ROW-2 | Compensability | GOVERNED_ASSESSOR_JUDGMENT | Assess against the declared semantic criteria and cite the supporting response evidence. |
| 2 | UNASSIGNED-ROW-2 | AssessorID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | AssessmentResult | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |
| 2 | UNASSIGNED-ROW-2 | Materiality | GOVERNED_ASSESSOR_JUDGMENT | Assess against the declared semantic criteria and cite the supporting response evidence. |
| 2 | UNASSIGNED-ROW-2 | EvidenceReference | GOVERNED_ASSESSOR_JUDGMENT | Provide a traceable reference to the supporting controlled source or observation. |
| 2 | UNASSIGNED-ROW-2 | Rationale | GOVERNED_ASSESSOR_JUDGMENT | State the evidence-based rationale. Preserve uncertainty and contradictory observations. |
| 2 | UNASSIGNED-ROW-2 | AdjudicationStatus | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |
| 2 | UNASSIGNED-ROW-2 | FinalResult | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |

### Governing Source Documents

#### DESIGN.md

```markdown
# MS-T1 â€” Governed Initiation Comparative Trial

**Verification Identifier:** MS-VER-T1-001  
**Theorem Identifier:** MS-T1  
**Document Identifier:** MS-V1-T1-DES-001  
**Design Status:** Design Candidate  
**Version:** 0.1.0

## 1. Purpose

This trial evaluates whether governed initiation reduces material semantic divergence compared with unrestricted observer entry.

## 2. Canonical Theorem

For any governed ecosystem whose identity depends upon preservation of material distinctions, unrestricted observer interpretation creates a nonzero probability of semantic drift.

Therefore:

\[
Preserve(\mathbb{G})
\Rightarrow
GovernedInitiation(\mathbb{G})
\]

when observer interpretation may materially affect representation or action.

## 3. Research Hypothesis

Observers exposed to the Morning Star governed-initiation condition will demonstrate lower material semantic divergence than observers receiving unrestricted access to equivalent source material.

## 4. Null Hypothesis

There will be no reproducible difference in material semantic divergence between governed-initiation and unrestricted-entry observers.

## 5. Experimental Conditions

### Condition A â€” Governed Initiation

Observers receive:

- declared framework identity;
- canonical terminology;
- dependency ordering;
- scope boundaries;
- uncertainty rules;
- observer-role constraints;
- reconstruction requirements;
- traceability requirements.

### Condition B â€” Unrestricted Entry

Observers receive the same canonical source materials without the governed-initiation sequence or participation constraints.

## 6. Independent Variable

\[
X = EntryCondition
\]

where:

\[
X \in \{GOVERNED\_INITIATION, UNRESTRICTED\_ENTRY\}
\]

## 7. Dependent Variables

The trial measures:

- framework identity preservation;
- definition preservation;
- boundary preservation;
- dependency-order preservation;
- authority preservation;
- uncertainty preservation;
- source traceability;
- reconstruction fidelity;
- framework conflation count;
- unauthorized authority-claim count.

## 8. Controlled Variables

The following shall remain equivalent across conditions:

- source corpus;
- governed objects;
- allotted review period;
- response prompts;
- assessment criteria;
- scoring rules;
- evidence requirements;
- assessor access;
- governing framework version.

## 9. Observer Eligibility

Observers shall be eligible only when:

1. observer identity is recorded;
2. prior exposure is declared;
3. domain familiarity is declared;
4. condition assignment is recorded;
5. informed participation is documented where applicable;
6. no undisclosed conflict affects the trial;
7. the observer has not previously completed the same case set.

## 10. Case Architecture

Each trial case shall include:

- one canonical governed object;
- one declared framework identity;
- one constitutional definition;
- at least one material boundary;
- at least one dependency relation;
- one authority condition;
- one uncertainty condition;
- traceable source evidence;
- a reconstruction prompt.

## 11. Primary Outcome

The primary outcome is:

\[
MaterialSemanticDivergenceRate
=
\frac{MaterialDivergences}{MaterialPropertiesAssessed}
\]

## 12. Secondary Outcomes

Secondary outcomes include:

- non-compensable failure rate;
- framework conflation rate;
- dependency inversion rate;
- uncertainty-erasure rate;
- traceability failure rate;
- reconstruction completion rate;
- unauthorized authority inference rate.

## 13. Success Condition

MS-T1 receives preliminary support when:

1. the governed-initiation condition produces a lower material divergence rate;
2. the reduction is reproducible across cases;
3. no equivalent increase occurs in another non-compensable failure class;
4. assessors can reproduce material-property judgments;
5. uncertainty and limitations are explicitly retained.

## 14. Falsification Condition

MS-T1 is falsified within the tested scope when:

- unrestricted entry produces an equivalent or lower material divergence rate;
- the result is reproduced across the declared case set;
- measurement reliability is adequate;
- no uncontrolled variable plausibly explains the result.

## 15. Inconclusive Condition

The result remains inconclusive when:

- the case set is insufficient;
- assessor agreement is inadequate;
- observer groups are not comparable;
- source materials differ;
- protocol deviations materially affect results;
- evidence is incomplete;
- the measured effect is not reproducible.

## 16. Non-Compensable Properties

The following properties shall not be averaged away:

- canonical identity;
- constitutional boundary;
- dependency direction;
- authority source;
- uncertainty state;
- governing version;
- material traceability.

## 17. Research Boundary

This trial evaluates semantic-preservation effects of governed initiation.

It does not establish:

- universal pedagogical superiority;
- general intelligence differences;
- institutional authority;
- stewardship qualification;
- legal compliance;
- complete ecosystem adoption validity.

## 18. Design Invariants

1. Conditions shall use equivalent canonical source material.
2. Observer condition shall be recorded before response collection.
3. Scoring criteria shall be established before analysis.
4. Raw responses shall not be overwritten.
5. Assessor judgments shall remain traceable.
6. Missing evidence shall remain missing.
7. Uncertainty shall not be resolved by assumption.
8. Non-compensable failures shall remain individually visible.
9. The theorem shall not be supported solely by directional difference.
10. The trial result shall not exceed its tested scope.
```

#### PROCEDURE.md

```markdown
# MS-T1 Trial Procedure

**Document Identifier:** MS-V1-T1-PRO-001  
**Verification Identifier:** MS-VER-T1-001  
**Version:** 0.1.0

## 1. Preparation

1. Freeze the governing Morning Star version.
2. Select the governed objects.
3. establish the canonical answer key.
4. Register all material properties.
5. Assign case identifiers.
6. Validate both condition packages.
7. verify that source content is equivalent.
8. Record assessors and authority.
9. Freeze the scoring model.
10. Record the trial start state.

## 2. Observer Registration

For each observer:

1. assign an observer identifier;
2. record observer class;
3. record declared prior exposure;
4. record domain familiarity;
5. record trial condition;
6. record governing version;
7. preserve required consent or authorization evidence;
8. prevent access to the alternate condition package.

## 3. Condition Delivery

### Governed-Initiation Condition

Deliver:

1. observer orientation;
2. canonical vocabulary;
3. framework differentiation;
4. dependency sequence;
5. boundary rules;
6. uncertainty rules;
7. traceability requirements;
8. reconstruction instructions;
9. participation constraints.

### Unrestricted-Entry Condition

Deliver:

1. the same canonical source corpus;
2. the same case prompts;
3. the same response format;
4. no Morning Star initiation sequence.

## 4. Response Collection

Each observer shall:

1. identify the governed object;
2. define it;
3. state its boundary;
4. identify dependencies;
5. identify the authority source;
6. preserve declared uncertainty;
7. cite source evidence;
8. reconstruct the object in original wording;
9. distinguish interpretation from canonical statement;
10. declare unresolved uncertainty.

## 5. Assessment

Each response shall be evaluated property by property.

Assessment values are:

- PRESERVED;
- DIVERGENT;
- INSUFFICIENT_EVIDENCE;
- DISPUTED;
- NOT_APPLICABLE.

Assessors shall not infer preservation from fluency or confidence.

## 6. Adjudication

Where assessors disagree:

1. preserve both original assessments;
2. identify the disputed property;
3. record each rationale;
4. conduct bounded adjudication;
5. record final status;
6. retain the disagreement history.

## 7. Analysis

Calculate by condition:

- total material properties assessed;
- total preserved properties;
- total divergent properties;
- non-compensable failures;
- semantic divergence rate;
- uncertainty-erasure rate;
- dependency inversion rate;
- framework conflation rate;
- traceability failure rate;
- unauthorized authority-claim rate.

## 8. Closure

The trial may close only when:

- all required responses are recorded;
- all assessments are complete;
- disputes are resolved or preserved;
- protocol deviations are documented;
- analysis is reproducible;
- limitations are declared;
- theorem disposition is assigned;
- raw evidence remains preserved.
```

#### SCORING_MODEL.md

```markdown
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
```

#### DATA_DICTIONARY.md

```markdown
# MS-T1 Data Dictionary

**Document Identifier:** MS-V1-T1-DD-001  
**Version:** 0.1.0

## Trial Case Fields

| Field | Definition |
|---|---|
| CaseID | Stable trial-case identifier. |
| GovernedObjectID | Canonical identifier of the object under assessment. |
| FrameworkID | Canonical framework identifier. |
| GoverningVersion | Version applicable to the trial case. |
| MaterialPropertyCount | Number of material properties assessed. |
| CanonicalSource | Authoritative source location. |
| DependencyIDs | Declared upstream dependencies. |
| AuthoritySource | Canonical authority source. |
| UncertaintyState | Canonical uncertainty condition. |
| CaseStatus | DRAFT, APPROVED, ACTIVE, RETIRED, or SUPERSEDED. |

## Observer Response Fields

| Field | Definition |
|---|---|
| ResponseID | Stable response identifier. |
| ObserverID | Registered observer identifier. |
| CaseID | Trial case answered. |
| EntryCondition | GOVERNED_INITIATION or UNRESTRICTED_ENTRY. |
| ObserverClass | Declared observer class. |
| PriorExposure | Declared previous exposure. |
| SubmittedAt | Response submission timestamp. |
| ResponseText | Observer reconstruction. |
| SourceReferences | Sources cited by the observer. |
| DeclaredUncertainty | Uncertainty explicitly retained by the observer. |
| ResponseStatus | SUBMITTED, WITHDRAWN, INVALID, or SUPERSEDED. |

## Semantic Assessment Fields

| Field | Definition |
|---|---|
| AssessmentID | Stable assessment identifier. |
| ResponseID | Response being evaluated. |
| PropertyID | Material property assessed. |
| PropertyClass | IDENTITY, DEFINITION, BOUNDARY, DEPENDENCY, AUTHORITY, UNCERTAINTY, TRACEABILITY, or VERSION. |
| Compensability | COMPENSABLE or NON_COMPENSABLE. |
| AssessorID | Assessor identity. |
| AssessmentResult | PRESERVED, DIVERGENT, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. |
| Materiality | MATERIAL or NON_MATERIAL. |
| EvidenceReference | Evidence supporting the judgment. |
| Rationale | Assessment rationale. |
| AdjudicationStatus | NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. |
| FinalResult | Final preserved assessment result. |
```

## MS-T2

**Trial:** `MS-T2_DEPENDENCY_PROPAGATION_TRIAL`

### DEPENDENCY_CHAINS.csv

**Working path:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T2_CONTROLLED_EXECUTION\01_INPUT\DEPENDENCY_CHAINS.csv`

**Collection copy:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T2_CONTROLLED_EXECUTION\00_COLLECTION_PACKET\DEPENDENCY_CHAINS.COLLECTION_COPY.csv`

**Current row count:** 1

#### Schema

```text
"ChainID","ChainName","GoverningVersion","RootObjectID","TerminalObjectID","DependencyDepth","CorrectionAvailability","CanonicalSource","ChainStatus"
```

#### Current Rows

##### CSV Row 2

| Field | Current Value |
|---|---|
| ChainID | MS-T2-CHAIN-001 |
| ChainName | **MISSING** |
| GoverningVersion | **MISSING** |
| RootObjectID | **MISSING** |
| TerminalObjectID | **MISSING** |
| DependencyDepth | **MISSING** |
| CorrectionAvailability | **MISSING** |
| CanonicalSource | **MISSING** |
| ChainStatus | DRAFT |

#### Field Authorities

| # | Field | Identity | Authority | Instruction |
|---:|---|---|---|---|
| 1 | ChainID | True | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | ChainName | False | GOVERNED_DEPENDENCY_DESIGN | Define the canonical dependency relationship and expected propagation boundary. |
| 3 | GoverningVersion | False | GOVERNED_DEPENDENCY_DESIGN | Define the canonical dependency relationship and expected propagation boundary. |
| 4 | RootObjectID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 5 | TerminalObjectID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 6 | DependencyDepth | False | GOVERNED_DEPENDENCY_DESIGN | Define the canonical dependency relationship and expected propagation boundary. |
| 7 | CorrectionAvailability | False | GOVERNED_DEPENDENCY_DESIGN | Define the canonical dependency relationship and expected propagation boundary. |
| 8 | CanonicalSource | False | GOVERNED_DEPENDENCY_DESIGN | Provide a traceable reference to the supporting controlled source or observation. |
| 9 | ChainStatus | False | GOVERNED_DEPENDENCY_DESIGN | Use only an authorized value defined by the trial procedure or data dictionary. |

#### Missing-Value Worklist

| CSV Row | Identity | Missing Field | Authority | Instruction |
|---|---|---|---|---|
| 2 | MS-T2-CHAIN-001 | ChainName | GOVERNED_DEPENDENCY_DESIGN | Define the canonical dependency relationship and expected propagation boundary. |
| 2 | MS-T2-CHAIN-001 | GoverningVersion | GOVERNED_DEPENDENCY_DESIGN | Define the canonical dependency relationship and expected propagation boundary. |
| 2 | MS-T2-CHAIN-001 | RootObjectID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | MS-T2-CHAIN-001 | TerminalObjectID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | MS-T2-CHAIN-001 | DependencyDepth | GOVERNED_DEPENDENCY_DESIGN | Define the canonical dependency relationship and expected propagation boundary. |
| 2 | MS-T2-CHAIN-001 | CorrectionAvailability | GOVERNED_DEPENDENCY_DESIGN | Define the canonical dependency relationship and expected propagation boundary. |
| 2 | MS-T2-CHAIN-001 | CanonicalSource | GOVERNED_DEPENDENCY_DESIGN | Provide a traceable reference to the supporting controlled source or observation. |

### TRIAL_CASES.csv

**Working path:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T2_CONTROLLED_EXECUTION\01_INPUT\TRIAL_CASES.csv`

**Collection copy:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T2_CONTROLLED_EXECUTION\00_COLLECTION_PACKET\TRIAL_CASES.COLLECTION_COPY.csv`

**Current row count:** 2

#### Schema

```text
"CaseID","ChainID","Condition","SeedObjectID","DivergenceClass","OriginalValue","SeededValue","SeedPropertyClass","CorrectionEnabled","CaseStatus"
```

#### Current Rows

##### CSV Row 2

| Field | Current Value |
|---|---|
| CaseID | MS-T2-CASE-001-A |
| ChainID | MS-T2-CHAIN-001 |
| Condition | CANONICAL_UPSTREAM |
| SeedObjectID | **MISSING** |
| DivergenceClass | NONE |
| OriginalValue | **MISSING** |
| SeededValue | **MISSING** |
| SeedPropertyClass | **MISSING** |
| CorrectionEnabled | **MISSING** |
| CaseStatus | DRAFT |

##### CSV Row 3

| Field | Current Value |
|---|---|
| CaseID | MS-T2-CASE-001-B |
| ChainID | MS-T2-CHAIN-001 |
| Condition | DIVERGENT_UPSTREAM |
| SeedObjectID | **MISSING** |
| DivergenceClass | **MISSING** |
| OriginalValue | **MISSING** |
| SeededValue | **MISSING** |
| SeedPropertyClass | **MISSING** |
| CorrectionEnabled | **MISSING** |
| CaseStatus | DRAFT |

#### Field Authorities

| # | Field | Identity | Authority | Instruction |
|---:|---|---|---|---|
| 1 | CaseID | True | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | ChainID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 3 | Condition | False | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 4 | SeedObjectID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 5 | DivergenceClass | False | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 6 | OriginalValue | False | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 7 | SeededValue | False | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 8 | SeedPropertyClass | False | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 9 | CorrectionEnabled | False | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 10 | CaseStatus | False | GOVERNED_CASE_DESIGN | Use only an authorized value defined by the trial procedure or data dictionary. |

#### Missing-Value Worklist

| CSV Row | Identity | Missing Field | Authority | Instruction |
|---|---|---|---|---|
| 2 | MS-T2-CASE-001-A | SeedObjectID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | MS-T2-CASE-001-A | OriginalValue | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 2 | MS-T2-CASE-001-A | SeededValue | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 2 | MS-T2-CASE-001-A | SeedPropertyClass | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 2 | MS-T2-CASE-001-A | CorrectionEnabled | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 3 | MS-T2-CASE-001-B | SeedObjectID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 3 | MS-T2-CASE-001-B | DivergenceClass | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 3 | MS-T2-CASE-001-B | OriginalValue | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 3 | MS-T2-CASE-001-B | SeededValue | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 3 | MS-T2-CASE-001-B | SeedPropertyClass | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |
| 3 | MS-T2-CASE-001-B | CorrectionEnabled | GOVERNED_CASE_DESIGN | Complete from the governed trial design before execution begins. |

### PROPAGATION_EVENTS.csv

**Working path:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T2_CONTROLLED_EXECUTION\02_EVIDENCE\PROPAGATION_EVENTS.csv`

**Collection copy:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T2_CONTROLLED_EXECUTION\00_COLLECTION_PACKET\PROPAGATION_EVENTS.COLLECTION_COPY.csv`

**Current row count:** 1

#### Schema

```text
"EventID","CaseID","SourceObjectID","TargetObjectID","DependencyEdgeID","PropertyClass","PropagationLevel","EventClass","EvidenceReference","DetectedAt","DetectionMethod","EventStatus"
```

#### Current Rows

##### CSV Row 2

| Field | Current Value |
|---|---|
| EventID | **MISSING** |
| CaseID | **MISSING** |
| SourceObjectID | **MISSING** |
| TargetObjectID | **MISSING** |
| DependencyEdgeID | **MISSING** |
| PropertyClass | **MISSING** |
| PropagationLevel | **MISSING** |
| EventClass | **MISSING** |
| EvidenceReference | **MISSING** |
| DetectedAt | **MISSING** |
| DetectionMethod | **MISSING** |
| EventStatus | **MISSING** |

#### Field Authorities

| # | Field | Identity | Authority | Instruction |
|---:|---|---|---|---|
| 1 | EventID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | CaseID | True | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 3 | SourceObjectID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 4 | TargetObjectID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 5 | DependencyEdgeID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 6 | PropertyClass | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 7 | PropagationLevel | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 8 | EventClass | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 9 | EvidenceReference | False | OBSERVED_EXECUTION_ONLY | Provide a traceable reference to the supporting controlled source or observation. |
| 10 | DetectedAt | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 11 | DetectionMethod | False | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 12 | EventStatus | False | OBSERVED_EXECUTION_ONLY | Use only an authorized value defined by the trial procedure or data dictionary. |

#### Missing-Value Worklist

| CSV Row | Identity | Missing Field | Authority | Instruction |
|---|---|---|---|---|
| 2 | UNASSIGNED-ROW-2 | EventID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | CaseID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | SourceObjectID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | TargetObjectID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | DependencyEdgeID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | PropertyClass | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | PropagationLevel | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | EventClass | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | EvidenceReference | OBSERVED_EXECUTION_ONLY | Provide a traceable reference to the supporting controlled source or observation. |
| 2 | UNASSIGNED-ROW-2 | DetectedAt | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | DetectionMethod | OBSERVED_EXECUTION_ONLY | Enter only what was directly observed during controlled execution. Do not infer missing facts. |
| 2 | UNASSIGNED-ROW-2 | EventStatus | OBSERVED_EXECUTION_ONLY | Use only an authorized value defined by the trial procedure or data dictionary. |

### DOWNSTREAM_ASSESSMENTS.csv

**Working path:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T2_CONTROLLED_EXECUTION\03_ASSESSMENT\DOWNSTREAM_ASSESSMENTS.csv`

**Collection copy:** `C:\Users\18177\morning-star\volumes\VOLUME_I_FOUNDATION\verification\execution\MS-T2_CONTROLLED_EXECUTION\00_COLLECTION_PACKET\DOWNSTREAM_ASSESSMENTS.COLLECTION_COPY.csv`

**Current row count:** 1

#### Schema

```text
"AssessmentID","CaseID","ObjectID","PropertyClass","AssessorID","AssessmentResult","Materiality","Compensability","EvidenceReference","Rationale","FinalResult","AdjudicationStatus"
```

#### Current Rows

##### CSV Row 2

| Field | Current Value |
|---|---|
| AssessmentID | **MISSING** |
| CaseID | **MISSING** |
| ObjectID | **MISSING** |
| PropertyClass | **MISSING** |
| AssessorID | **MISSING** |
| AssessmentResult | **MISSING** |
| Materiality | **MISSING** |
| Compensability | **MISSING** |
| EvidenceReference | **MISSING** |
| Rationale | **MISSING** |
| FinalResult | **MISSING** |
| AdjudicationStatus | **MISSING** |

#### Field Authorities

| # | Field | Identity | Authority | Instruction |
|---:|---|---|---|---|
| 1 | AssessmentID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | CaseID | True | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 3 | ObjectID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 4 | PropertyClass | False | GOVERNED_ASSESSOR_JUDGMENT | Assess the downstream effect against the declared dependency and propagation criteria. |
| 5 | AssessorID | False | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 6 | AssessmentResult | False | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |
| 7 | Materiality | False | GOVERNED_ASSESSOR_JUDGMENT | Assess the downstream effect against the declared dependency and propagation criteria. |
| 8 | Compensability | False | GOVERNED_ASSESSOR_JUDGMENT | Assess the downstream effect against the declared dependency and propagation criteria. |
| 9 | EvidenceReference | False | GOVERNED_ASSESSOR_JUDGMENT | Provide a traceable reference to the supporting controlled source or observation. |
| 10 | Rationale | False | GOVERNED_ASSESSOR_JUDGMENT | State the evidence-based rationale. Preserve uncertainty and contradictory observations. |
| 11 | FinalResult | False | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |
| 12 | AdjudicationStatus | False | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |

#### Missing-Value Worklist

| CSV Row | Identity | Missing Field | Authority | Instruction |
|---|---|---|---|---|
| 2 | UNASSIGNED-ROW-2 | AssessmentID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | CaseID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | ObjectID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | PropertyClass | GOVERNED_ASSESSOR_JUDGMENT | Assess the downstream effect against the declared dependency and propagation criteria. |
| 2 | UNASSIGNED-ROW-2 | AssessorID | CONTROLLED_ID_ASSIGNMENT | Assign a unique stable identifier. Do not reuse an existing identity. |
| 2 | UNASSIGNED-ROW-2 | AssessmentResult | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |
| 2 | UNASSIGNED-ROW-2 | Materiality | GOVERNED_ASSESSOR_JUDGMENT | Assess the downstream effect against the declared dependency and propagation criteria. |
| 2 | UNASSIGNED-ROW-2 | Compensability | GOVERNED_ASSESSOR_JUDGMENT | Assess the downstream effect against the declared dependency and propagation criteria. |
| 2 | UNASSIGNED-ROW-2 | EvidenceReference | GOVERNED_ASSESSOR_JUDGMENT | Provide a traceable reference to the supporting controlled source or observation. |
| 2 | UNASSIGNED-ROW-2 | Rationale | GOVERNED_ASSESSOR_JUDGMENT | State the evidence-based rationale. Preserve uncertainty and contradictory observations. |
| 2 | UNASSIGNED-ROW-2 | FinalResult | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |
| 2 | UNASSIGNED-ROW-2 | AdjudicationStatus | GOVERNED_ASSESSOR_JUDGMENT | Use only an authorized value defined by the trial procedure or data dictionary. |

### Governing Source Documents

#### DESIGN.md

```markdown
# MS-T2 â€” Dependency Drift Propagation Trial

**Verification Identifier:** MS-VER-T2-001  
**Theorem Identifier:** MS-T2  
**Document Identifier:** MS-V1-T2-DES-001  
**Design Status:** Design Candidate  
**Version:** 0.1.0

## 1. Purpose

This trial evaluates whether material semantic divergence introduced into an upstream governed object creates measurable downstream semantic-integrity risk in dependent objects.

## 2. Canonical Theorem

Let governed object \(g_j\) depend upon governed object \(g_i\).

When:

\[
g_i \rightarrow g_j
\]

and:

\[
\Delta_s(C_{g_i},R_{O,g_i}) \neq 0
\]

then:

\[
Risk(\Delta_s(C_{g_j},R_{O,g_j})) > 0
\]

unless an independent correction, validation, or reconstruction mechanism interrupts propagation.

## 3. Research Hypothesis

Dependency chains containing seeded upstream material divergence will demonstrate a higher rate of downstream semantic divergence than equivalent chains using canonical upstream representations.

## 4. Null Hypothesis

Seeded upstream material divergence will produce no measurable increase in downstream semantic divergence.

## 5. Experimental Conditions

### Condition A â€” Canonical Upstream Representation

The dependency chain receives a canonical upstream object with preserved:

- identity;
- definition;
- boundary;
- dependency structure;
- authority;
- uncertainty;
- traceability;
- version.

### Condition B â€” Divergent Upstream Representation

The dependency chain receives an upstream representation containing one controlled material divergence.

Permitted seeded divergence classes include:

- IDENTITY_SUBSTITUTION;
- DEFINITION_EXPANSION;
- BOUNDARY_ERASURE;
- DEPENDENCY_INVERSION;
- AUTHORITY_INFLATION;
- UNCERTAINTY_ERASURE;
- TRACEABILITY_REMOVAL;
- VERSION_SUBSTITUTION.

## 6. Independent Variables

\[
X =
(UpstreamRepresentation,
DivergenceClass,
DependencyDepth,
CorrectionAvailability)
\]

where:

- `UpstreamRepresentation` is CANONICAL or DIVERGENT;
- `DivergenceClass` identifies the seeded material change;
- `DependencyDepth` is the number of downstream dependency levels;
- `CorrectionAvailability` identifies whether an interruption mechanism exists.

## 7. Dependent Variables

The trial measures:

- downstream material divergence rate;
- propagation depth;
- number of affected downstream objects;
- affected material-property classes;
- time to propagation detection;
- correction success rate;
- residual divergence after correction;
- traceability loss;
- observer reconstruction failure;
- authority-error propagation.

## 8. Controlled Variables

The following shall remain equivalent across paired cases:

- canonical source objects;
- dependency topology;
- governing version;
- observer or evaluator access;
- response prompts;
- assessment criteria;
- allotted review period;
- scoring method;
- downstream transformation rules.

## 9. Dependency Chain Model

A dependency chain is represented as:

\[
D_c = (g_0,g_1,\ldots,g_n)
\]

where:

\[
g_0 \rightarrow g_1 \rightarrow \cdots \rightarrow g_n
\]

Each edge shall declare:

- dependency type;
- dependency direction;
- required inherited properties;
- transformation rule;
- validation rule;
- correction mechanism;
- governing version.

## 10. Propagation Event

A propagation event exists when a material divergence present in an upstream representation appears in or materially affects a downstream object.

\[
PE(g_i,g_j,p)=1
\]

when divergence in property \(p\) at \(g_i\) causes divergence or invalid action at \(g_j\).

## 11. Primary Outcome

The primary outcome is:

\[
DownstreamDivergenceRate =
\frac{D_d}{P_d + D_d}
\]

where:

- \(D_d\) is the number of divergent downstream material properties;
- \(P_d\) is the number of preserved downstream material properties.

## 12. Propagation Risk

Define propagation risk:

\[
PR =
\frac{ObjectsAffected}{ObjectsExposed}
\]

and propagation depth:

\[
PD =
\max(LevelAffected)
\]

A divergence may propagate broadly, deeply, both, or neither.

## 13. Success Condition

MS-T2 receives preliminary support when:

1. divergent upstream conditions produce a reproducibly higher downstream divergence rate;
2. at least one downstream material property is affected through a declared dependency;
3. the effect exceeds paired canonical-chain results;
4. the propagation path remains traceable;
5. no uncontrolled source better explains the divergence.

## 14. Falsification Condition

MS-T2 is falsified for the tested dependency class when:

- seeded upstream divergence produces no measurable downstream effect;
- equivalent canonical and divergent chains remain semantically indistinguishable;
- the finding is reproduced across the declared case set;
- measurement reliability is adequate.

## 15. Inconclusive Condition

The result remains inconclusive when:

- dependency edges are ambiguous;
- seeded divergence is not materially valid;
- downstream transformations are inconsistent;
- propagation cannot be distinguished from independent observer error;
- evidence is incomplete;
- paired cases are not equivalent;
- correction mechanisms are uncontrolled.

## 16. Interruption Mechanisms

Propagation may be interrupted by:

- canonical-source validation;
- dependency-aware reconstruction;
- version validation;
- semantic convergence assessment;
- uncertainty preservation;
- authority verification;
- explicit correction;
- downstream independent derivation.

The existence of interruption does not negate dependency propagation risk.

## 17. Non-Compensable Properties

The following downstream failures shall remain independently visible:

- identity substitution;
- boundary failure;
- dependency inversion;
- authority inflation;
- uncertainty erasure;
- version substitution;
- traceability failure.

## 18. Research Boundary

This trial evaluates semantic propagation through declared dependency structures.

It does not establish that:

- every upstream error must propagate;
- every dependency has equal sensitivity;
- all semantic drift is dependency-derived;
- correction is always possible;
- all ecosystems require identical dependency controls.

## 19. Design Invariants

1. Every dependency edge shall be declared.
2. Every seeded divergence shall be intentional and traceable.
3. Canonical and divergent cases shall otherwise remain equivalent.
4. Downstream divergence shall be assessed property by property.
5. Independent observer error shall remain distinguishable from propagated error.
6. Correction mechanisms shall be declared before execution.
7. Missing evidence shall remain missing.
8. Non-compensable failures shall not be averaged away.
9. Propagation depth and breadth shall be reported separately.
10. The result shall not exceed the tested dependency class.
```

#### PROCEDURE.md

```markdown
# MS-T2 Trial Procedure

**Document Identifier:** MS-V1-T2-PRO-001  
**Verification Identifier:** MS-VER-T2-001  
**Version:** 0.1.0

## 1. Preparation

1. Freeze the governing Morning Star version.
2. Select the canonical governed objects.
3. Define each dependency chain.
4. Validate dependency direction.
5. define required inherited properties.
6. select one divergence class per controlled test case.
7. create paired canonical and divergent cases.
8. freeze downstream transformation rules.
9. register correction mechanisms.
10. freeze the scoring model.

## 2. Dependency Registration

For each dependency edge:

1. assign a dependency-edge identifier;
2. identify upstream object;
3. identify downstream object;
4. record dependency class;
5. record inherited properties;
6. record transformation rule;
7. record validation rule;
8. record governing version;
9. record correction availability.

## 3. Divergence Seeding

For each divergent trial case:

1. preserve the canonical upstream object;
2. create a separate divergent representation;
3. alter exactly one declared material property unless the design states otherwise;
4. record the original value;
5. record the divergent value;
6. record the divergence class;
7. verify that all other properties remain unchanged;
8. preserve the seeded artifact.

## 4. Chain Execution

For each paired chain:

1. provide the upstream representation to the downstream process or observer;
2. execute the declared transformation;
3. preserve every intermediate representation;
4. record each dependency edge traversed;
5. prevent undeclared correction;
6. capture downstream outputs;
7. repeat using the paired condition.

## 5. Downstream Assessment

Each downstream object shall be evaluated for:

- identity preservation;
- definition preservation;
- boundary preservation;
- dependency preservation;
- authority preservation;
- uncertainty preservation;
- traceability preservation;
- version preservation.

Assessment values are:

- PRESERVED;
- PROPAGATED_DIVERGENCE;
- INDEPENDENT_DIVERGENCE;
- CORRECTED;
- INSUFFICIENT_EVIDENCE;
- DISPUTED;
- NOT_APPLICABLE.

## 6. Propagation Classification

A divergence shall be classified as propagated only when:

1. the upstream divergence is verified;
2. the downstream property is materially affected;
3. a valid dependency path exists;
4. the downstream divergence corresponds to the upstream divergence;
5. no stronger independent cause is established.

## 7. Correction Evaluation

Where a correction mechanism exists:

1. record detection point;
2. identify correction authority;
3. apply the declared correction;
4. preserve pre-correction output;
5. preserve post-correction output;
6. assess residual divergence;
7. record correction success or failure.

## 8. Analysis

Calculate by condition and divergence class:

- downstream divergence rate;
- propagation-event count;
- propagation breadth;
- propagation depth;
- correction detection rate;
- correction success rate;
- residual divergence rate;
- independent divergence rate;
- disputed classification rate.

## 9. Closure

The trial may close only when:

- all dependency chains are recorded;
- all seeded divergences are verified;
- all paired cases are executed;
- all intermediate artifacts are preserved;
- all downstream assessments are complete;
- propagation classifications are traceable;
- correction outcomes are recorded;
- limitations are declared;
- theorem disposition is assigned.
```

#### SCORING_MODEL.md

```markdown
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
```

#### DATA_DICTIONARY.md

```markdown
# MS-T2 Data Dictionary

**Document Identifier:** MS-V1-T2-DD-001  
**Version:** 0.1.0

## Dependency Chain Fields

| Field | Definition |
|---|---|
| ChainID | Stable dependency-chain identifier. |
| ChainName | Human-readable chain name. |
| GoverningVersion | Morning Star or framework version governing the case. |
| RootObjectID | Initial upstream governed object. |
| TerminalObjectID | Final downstream governed object. |
| DependencyDepth | Number of declared dependency edges. |
| CorrectionAvailability | NONE, VALIDATION, RECONSTRUCTION, or GOVERNED_CORRECTION. |
| CanonicalSource | Authoritative chain definition source. |
| ChainStatus | DRAFT, APPROVED, ACTIVE, RETIRED, or SUPERSEDED. |

## Trial Case Fields

| Field | Definition |
|---|---|
| CaseID | Stable paired-case identifier. |
| ChainID | Dependency chain under test. |
| Condition | CANONICAL_UPSTREAM or DIVERGENT_UPSTREAM. |
| SeedObjectID | Object receiving the seeded representation. |
| DivergenceClass | Controlled material divergence class. |
| OriginalValue | Canonical property value. |
| SeededValue | Divergent property value. |
| SeedPropertyClass | Material property changed. |
| CorrectionEnabled | YES or NO. |
| CaseStatus | DRAFT, APPROVED, ACTIVE, COMPLETE, INVALID, or SUPERSEDED. |

## Propagation Event Fields

| Field | Definition |
|---|---|
| EventID | Stable propagation-event identifier. |
| CaseID | Trial case producing the event. |
| SourceObjectID | Object where divergence originated. |
| TargetObjectID | Downstream object materially affected. |
| DependencyEdgeID | Edge through which propagation occurred. |
| PropertyClass | Material property affected. |
| PropagationLevel | Downstream depth at which effect appeared. |
| EventClass | PROPAGATED, INTERRUPTED, CORRECTED, or UNRESOLVED. |
| EvidenceReference | Evidence supporting classification. |
| DetectedAt | Detection timestamp. |
| DetectionMethod | Method that identified the event. |
| EventStatus | OPEN, VERIFIED, DISPUTED, INVALID, or CLOSED. |

## Downstream Assessment Fields

| Field | Definition |
|---|---|
| AssessmentID | Stable assessment identifier. |
| CaseID | Trial case assessed. |
| ObjectID | Downstream object assessed. |
| PropertyClass | Material property under assessment. |
| AssessorID | Assessor identity. |
| AssessmentResult | PRESERVED, PROPAGATED_DIVERGENCE, INDEPENDENT_DIVERGENCE, CORRECTED, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. |
| Materiality | MATERIAL or NON_MATERIAL. |
| Compensability | COMPENSABLE or NON_COMPENSABLE. |
| EvidenceReference | Evidence supporting the judgment. |
| Rationale | Assessment rationale. |
| FinalResult | Final adjudicated result. |
| AdjudicationStatus | NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. |
```

## Governing Execution Boundary

Case and dependency definitions may be completed only from governed design sources. Observer responses, propagation events, semantic assessments, and downstream assessments require actual controlled execution evidence and may not be inferred merely to close a theorem.

