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
