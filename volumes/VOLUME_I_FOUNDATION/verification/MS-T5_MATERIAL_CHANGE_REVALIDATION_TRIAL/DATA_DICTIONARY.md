# MS-T5 Data Dictionary

**Document Identifier:** MS-V1-T5-DD-001  
**Version:** 0.1.0

## Material Revision Fields

| Field | Definition |
|---|---|
| RevisionID | Stable revision identifier. |
| SourceVersion | Version before revision. |
| TargetVersion | Version after revision. |
| EffectiveDate | Date the revision became governing. |
| ChangeClass | NON_MATERIAL, MATERIAL, BREAKING, or INDETERMINATE. |
| MaterialChangeType | Identity, definition, boundary, dependency, authority, participation, uncertainty, procedure, verification, interpretation, or multi-property change. |
| AffectedObjects | Governed objects affected. |
| AffectedProperties | Material properties affected. |
| CompatibilityState | COMPATIBLE, PARTIALLY_COMPATIBLE, INCOMPATIBLE, or INDETERMINATE. |
| AuthoritySource | Authority approving the revision. |
| CanonicalSource | Authoritative revision evidence. |
| RevisionStatus | DRAFT, ACTIVE, RETIRED, or SUPERSEDED. |

## Observer Baseline Fields

| Field | Definition |
|---|---|
| BaselineID | Stable observer-baseline identifier. |
| ObserverID | Observer identity. |
| DomainID | Verified domain. |
| VerifiedVersion | Version under which competence was verified. |
| VerifiedCapabilities | Capabilities established by evidence. |
| EvidenceReference | Baseline evidence. |
| VerifiedAt | Verification timestamp. |
| ValidUntil | Expiration timestamp where applicable. |
| AuthorityScope | Associated authority scope, if any. |
| Limitations | Declared limitations. |

## Revalidation Case Fields

| Field | Definition |
|---|---|
| CaseID | Stable case identifier. |
| ObserverID | Observer evaluated. |
| RevisionID | Revision governing the case. |
| SourceVersion | Observer baseline version. |
| TargetVersion | Current governing version. |
| RevalidationCondition | REVALIDATED, NOT_REVALIDATED, PARTIALLY_REVALIDATED, or NON_MATERIAL_CONTROL. |
| AffectedPropertyClass | Revision-sensitive property under test. |
| CurrentCanonicalValue | Current correct value. |
| SupersededValue | Prior value no longer governing. |
| ExpectedDisposition | Canonically expected result. |
| CaseStatus | DRAFT, APPROVED, ACTIVE, COMPLETE, INVALID, or SUPERSEDED. |

## Post-Revision Response Fields

| Field | Definition |
|---|---|
| ResponseID | Stable response identifier. |
| CaseID | Revalidation case answered. |
| ObserverID | Responding observer. |
| GoverningVersionIdentified | Version identified by observer. |
| CurrentReconstruction | Observer reconstruction under current version. |
| SupersededRulesIdentified | Superseded rules correctly identified. |
| AuthoritySourceIdentified | Current authority source identified. |
| RevalidationClaim | Observer claim regarding current competence. |
| DeclaredUncertainty | Uncertainty retained by observer. |
| EvidenceReferences | Sources cited by observer. |
| SubmittedAt | Submission timestamp. |
| ResponseStatus | SUBMITTED, WITHDRAWN, INVALID, or SUPERSEDED. |

## Revalidation Assessment Fields

| Field | Definition |
|---|---|
| AssessmentID | Stable assessment identifier. |
| ResponseID | Response assessed. |
| PropertyClass | VERSION, IDENTITY, DEFINITION, BOUNDARY, DEPENDENCY, AUTHORITY, UNCERTAINTY, SUPERSESSION, or COMPATIBILITY. |
| AssessorID | Assessor identity. |
| AssessmentResult | CURRENTLY_PRESERVED, OBSOLETE_RULE_USE, VERSION_MIXING, REVISION_ERROR, PARTIALLY_CURRENT, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. |
| Materiality | MATERIAL or NON_MATERIAL. |
| Compensability | COMPENSABLE or NON_COMPENSABLE. |
| EvidenceReference | Evidence supporting the judgment. |
| Rationale | Assessment rationale. |
| RevalidationDisposition | REVALIDATION_SUCCESSFUL, REVALIDATION_PARTIAL, REVALIDATION_FAILED, REVALIDATION_NOT_REQUIRED, INSUFFICIENT_EVIDENCE, or DISPUTED. |
| AdjudicationStatus | NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. |
| FinalResult | Final adjudicated result. |
