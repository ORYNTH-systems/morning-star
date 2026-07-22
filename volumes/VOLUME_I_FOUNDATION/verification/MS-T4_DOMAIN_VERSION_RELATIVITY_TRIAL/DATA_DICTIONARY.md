# MS-T4 Data Dictionary

**Document Identifier:** MS-V1-T4-DD-001  
**Version:** 0.1.0

## Domain Profile Fields

| Field | Definition |
|---|---|
| DomainID | Stable governed-domain identifier. |
| DomainName | Canonical domain name. |
| CanonicalPurpose | Declared domain purpose. |
| GovernedObjects | Governed object identifiers. |
| RequiredCapabilities | Capabilities required for competence. |
| BoundarySummary | Material domain boundaries. |
| DependencySummary | Material domain dependencies. |
| AuthoritySummary | Domain authority rules. |
| UncertaintySummary | Domain uncertainty rules. |
| CanonicalSource | Authoritative domain source. |
| DomainStatus | DRAFT, ACTIVE, RETIRED, or SUPERSEDED. |

## Version Profile Fields

| Field | Definition |
|---|---|
| VersionProfileID | Stable version-profile identifier. |
| DomainID | Governed domain. |
| Version | Governing version identifier. |
| EffectiveDate | Version effective date. |
| Supersedes | Prior version superseded. |
| ChangeClass | IDENTICAL, NON_MATERIAL_CHANGE, MATERIAL_CHANGE, BREAKING_CHANGE, or INDETERMINATE. |
| MaterialChanges | Declared material changes. |
| AuthorityState | ACTIVE, EXPIRED, WITHDRAWN, or SUPERSEDED. |
| CanonicalSource | Authoritative version source. |
| VersionStatus | DRAFT, ACTIVE, RETIRED, or SUPERSEDED. |

## Observer Baseline Fields

| Field | Definition |
|---|---|
| BaselineID | Stable observer-baseline identifier. |
| ObserverID | Observer identity. |
| SourceDomainID | Domain of verified competence. |
| SourceVersion | Version of verified competence. |
| CapabilityStatus | VERIFIED, PARTIAL, DISPUTED, EXPIRED, or INSUFFICIENT_EVIDENCE. |
| EvidenceReference | Evidence supporting baseline competence. |
| VerifiedAt | Verification timestamp. |
| ValidUntil | Expiration timestamp where applicable. |
| AuthorityScope | Authority associated with the baseline, if any. |
| Limitations | Declared limitations. |

## Transfer Case Fields

| Field | Definition |
|---|---|
| TransferCaseID | Stable transfer-case identifier. |
| ObserverID | Observer evaluated. |
| SourceDomainID | Verified source domain. |
| TargetDomainID | Target domain. |
| SourceVersion | Verified source version. |
| TargetVersion | Target governing version. |
| DomainDistanceClass | SAME, RELATED, DISTINCT, or INDETERMINATE. |
| VersionChangeClass | IDENTICAL, NON_MATERIAL_CHANGE, MATERIAL_CHANGE, BREAKING_CHANGE, or INDETERMINATE. |
| TransferRuleID | Applicable transfer-rule identifier. |
| ExpectedDisposition | Canonically expected transfer disposition. |
| CaseStatus | DRAFT, APPROVED, ACTIVE, COMPLETE, INVALID, or SUPERSEDED. |

## Transfer Response Fields

| Field | Definition |
|---|---|
| ResponseID | Stable response identifier. |
| TransferCaseID | Transfer case answered. |
| ObserverID | Responding observer. |
| TargetReconstruction | Observer reconstruction of target domain or object. |
| TargetVersionIdentified | Version identified by the observer. |
| AuthoritySourceIdentified | Authority source identified by the observer. |
| DeclaredTransferStatus | Observer-declared transfer status. |
| RevalidationRequired | YES, NO, or INDETERMINATE. |
| DeclaredUncertainty | Uncertainty retained by the observer. |
| EvidenceReferences | Sources cited by the observer. |
| SubmittedAt | Submission timestamp. |
| ResponseStatus | SUBMITTED, WITHDRAWN, INVALID, or SUPERSEDED. |

## Transfer Assessment Fields

| Field | Definition |
|---|---|
| AssessmentID | Stable assessment identifier. |
| ResponseID | Response being assessed. |
| PropertyClass | IDENTITY, DEFINITION, BOUNDARY, DEPENDENCY, VERSION, AUTHORITY, UNCERTAINTY, TRANSFER_RULE, or REVALIDATION. |
| AssessorID | Assessor identity. |
| AssessmentResult | PRESERVED, TRANSFER_ERROR, NEGATIVE_TRANSFER, PARTIAL_TRANSFER, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. |
| Materiality | MATERIAL or NON_MATERIAL. |
| Compensability | COMPENSABLE or NON_COMPENSABLE. |
| EvidenceReference | Evidence supporting the judgment. |
| Rationale | Assessment rationale. |
| TransferDisposition | TRANSFER_VALID, TRANSFER_PARTIAL, REVALIDATION_REQUIRED, TRANSFER_INVALID, INSUFFICIENT_EVIDENCE, or DISPUTED. |
| AdjudicationStatus | NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. |
| FinalResult | Final adjudicated result. |
