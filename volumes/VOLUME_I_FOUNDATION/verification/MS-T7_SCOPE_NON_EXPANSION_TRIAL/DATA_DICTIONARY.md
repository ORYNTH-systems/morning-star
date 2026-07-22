# MS-T7 Data Dictionary

**Document Identifier:** MS-V1-T7-DD-001  
**Version:** 0.1.0

## Source Claim Fields

| Field | Definition |
|---|---|
| ClaimID | Stable canonical-claim identifier. |
| CanonicalText | Exact canonical claim text. |
| Subject | Governed subject of the claim. |
| Domain | Domain within which the claim applies. |
| Conditions | Conditions required for applicability. |
| EvidenceBoundary | Evidence supporting the claim. |
| AuthorityBoundary | Authority under which the claim is established. |
| GoverningVersion | Version governing the claim. |
| IntendedApplication | Permitted application of the claim. |
| Exclusions | Explicit exclusions. |
| UncertaintyState | Declared uncertainty state. |
| CanonicalSource | Authoritative source reference. |
| ClaimStatus | DRAFT, ACTIVE, RETIRED, or SUPERSEDED. |

## Scope Profile Fields

| Field | Definition |
|---|---|
| ScopeProfileID | Stable scope-profile identifier. |
| ClaimID | Canonical claim governed by the profile. |
| PropertyClass | SUBJECT, DOMAIN, CONDITION, EVIDENCE, AUTHORITY, VERSION, APPLICATION, EXCLUSION, or UNCERTAINTY. |
| CanonicalValue | Canonical property value. |
| ProhibitedExpansion | Unsupported broader interpretation. |
| PermittedDerivation | Governed broader derivation where applicable. |
| Materiality | MATERIAL or NON_MATERIAL. |
| Compensability | COMPENSABLE or NON_COMPENSABLE. |
| EvidenceReference | Evidence supporting the scope property. |

## Interpretation Case Fields

| Field | Definition |
|---|---|
| CaseID | Stable interpretation-case identifier. |
| ClaimID | Canonical claim interpreted. |
| ScopePropertyClass | Scope property targeted by the case. |
| Condition | GOVERNED_SCOPE_PRESERVATION, UNGOVERNED_INTERPRETATION, or VALID_DERIVED_EXPANSION. |
| InterpretationTask | Required interpretation task. |
| AdditionalEvidence | Additional derivation evidence, if any. |
| ExpectedClassification | Canonically expected response class. |
| ProhibitedClassification | Unsupported response class. |
| CaseStatus | DRAFT, APPROVED, ACTIVE, COMPLETE, INVALID, or SUPERSEDED. |

## Observer Response Fields

| Field | Definition |
|---|---|
| ResponseID | Stable observer-response identifier. |
| CaseID | Interpretation case answered. |
| ObserverID | Observer or system identity. |
| RestatedClaim | Observer restatement of the claim. |
| IdentifiedSubject | Subject identified by observer. |
| IdentifiedDomain | Domain identified by observer. |
| IdentifiedConditions | Conditions identified by observer. |
| IdentifiedEvidenceBoundary | Evidence boundary identified by observer. |
| IdentifiedAuthorityBoundary | Authority boundary identified by observer. |
| IdentifiedVersion | Version identified by observer. |
| IdentifiedApplication | Intended application identified by observer. |
| IdentifiedExclusions | Exclusions identified by observer. |
| Interpretation | Interpretation produced. |
| DerivationClaimed | YES, NO, or INDETERMINATE. |
| EvidenceReferences | Sources cited by observer. |
| SubmittedAt | Submission timestamp. |
| ResponseStatus | SUBMITTED, WITHDRAWN, INVALID, or SUPERSEDED. |

## Scope Assessment Fields

| Field | Definition |
|---|---|
| AssessmentID | Stable scope-assessment identifier. |
| ResponseID | Response assessed. |
| PropertyClass | SUBJECT, DOMAIN, CONDITION, EVIDENCE, AUTHORITY, VERSION, APPLICATION, EXCLUSION, UNCERTAINTY, or DERIVATION_IDENTITY. |
| AssessorID | Assessor identity. |
| AssessmentResult | PRESERVED, VALIDLY_DERIVED, EXPANDED_WITHOUT_SUPPORT, CONTRACTED_WITHOUT_SUPPORT, MISCLASSIFIED, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. |
| Materiality | MATERIAL or NON_MATERIAL. |
| Compensability | COMPENSABLE or NON_COMPENSABLE. |
| EvidenceReference | Evidence supporting assessment. |
| Rationale | Assessment rationale. |
| AdjudicationStatus | NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. |
| FinalResult | Final adjudicated result. |
