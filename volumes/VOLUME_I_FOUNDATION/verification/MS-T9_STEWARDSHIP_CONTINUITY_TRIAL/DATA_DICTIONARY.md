# MS-T9 Data Dictionary

**Document Identifier:** MS-V1-T9-DD-001  
**Version:** 0.1.0

## Governed Object Fields

| Field | Definition |
|---|---|
| ObjectID | Stable governed-object identifier. |
| ObjectName | Canonical object name. |
| ObjectType | Type of governed object. |
| CanonicalDefinition | Canonical definition. |
| CanonicalSource | Authoritative source reference. |
| GoverningVersion | Applicable version. |
| Domain | Governance domain. |
| Dependencies | Material dependencies. |
| UncertaintyState | Current uncertainty state. |
| ObjectStatus | DRAFT, ACTIVE, RETIRED, SUPERSEDED, or DISPUTED. |

## Steward Profile Fields

| Field | Definition |
|---|---|
| StewardID | Stable steward identifier. |
| StewardRole | Stewardship role. |
| CapabilityStatus | VERIFIED, PARTIAL, DISPUTED, EXPIRED, or INSUFFICIENT_EVIDENCE. |
| AuthoritySource | Source of stewardship authority. |
| AuthorityScope | Authorized stewardship scope. |
| EffectiveFrom | Authority start time. |
| EffectiveUntil | Authority expiration time. |
| Limitations | Declared limitations. |
| EvidenceReference | Evidence supporting role, capability, or authority. |
| StewardStatus | ACTIVE, INACTIVE, SUSPENDED, SUPERSEDED, or DISPUTED. |

## Stewardship Transfer Fields

| Field | Definition |
|---|---|
| TransferID | Stable transition identifier. |
| ObjectID | Governed object transferred. |
| SourceStewardID | Incumbent steward. |
| TargetStewardID | Successor steward. |
| TransferAuthority | Authority permitting transition. |
| TransferredDuties | Duties transferred. |
| ExcludedDuties | Duties explicitly excluded. |
| OpenObligations | Open obligations transferred. |
| EffectiveTime | Time transition becomes effective. |
| AcceptanceState | PENDING, ACCEPTED, PARTIAL, DECLINED, or DISPUTED. |
| TransitionCondition | GOVERNED_TRANSITION, INFORMAL_TRANSITION, BROKEN_TRANSITION, or NO_TRANSITION_CONTROL. |
| TransferStatus | DRAFT, APPROVED, EFFECTIVE, COMPLETE, INVALID, REVOKED, or SUPERSEDED. |

## Continuity Case Fields

| Field | Definition |
|---|---|
| CaseID | Stable continuity-case identifier. |
| TransferID | Stewardship transition under evaluation. |
| Condition | GOVERNED_TRANSITION, INFORMAL_TRANSITION, BROKEN_TRANSITION, or NO_TRANSITION_CONTROL. |
| TargetProperties | Material continuity properties assessed. |
| MissingProperties | Properties removed or unavailable in the case. |
| OperationalTask | Bounded stewardship task. |
| ExpectedDisposition | Expected transition disposition. |
| GoverningVersion | Version governing the case. |
| CaseStatus | DRAFT, APPROVED, ACTIVE, COMPLETE, INVALID, or SUPERSEDED. |

## Successor Response Fields

| Field | Definition |
|---|---|
| ResponseID | Stable response identifier. |
| CaseID | Continuity case answered. |
| SuccessorStewardID | Successor steward identity. |
| IdentifiedObjectID | Governed object identified. |
| IdentifiedCanonicalSource | Canonical source identified. |
| IdentifiedVersion | Governing version identified. |
| IdentifiedAuthority | Received authority identified. |
| IdentifiedExcludedAuthority | Excluded authority identified. |
| IdentifiedDependencies | Dependencies identified. |
| IdentifiedUncertainty | Uncertainty state identified. |
| IdentifiedOpenObligations | Open obligations identified. |
| IdentifiedRevisionHistory | Revision history identified. |
| IdentifiedEffectiveTime | Effective time identified. |
| IdentifiedAcceptanceLimits | Acceptance limitations identified. |
| OperationalDecision | Stewardship decision produced. |
| EvidenceReferences | Evidence cited. |
| SubmittedAt | Submission timestamp. |
| ResponseStatus | SUBMITTED, WITHDRAWN, INVALID, or SUPERSEDED. |

## Continuity Assessment Fields

| Field | Definition |
|---|---|
| AssessmentID | Stable continuity-assessment identifier. |
| ResponseID | Response assessed. |
| PropertyClass | IDENTITY, SOURCE, VERSION, AUTHORITY, SCOPE, DEPENDENCY, UNCERTAINTY, OBLIGATION, HISTORY, EFFECTIVE_TIME, ACCEPTANCE, or OPERATIONAL_DECISION. |
| AssessorID | Assessor identity. |
| AssessmentResult | PRESERVED, PRESERVED_WITH_LIMITATION, PARTIALLY_PRESERVED, LOST, EXPANDED_WITHOUT_AUTHORITY, MISCLASSIFIED, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. |
| Materiality | MATERIAL or NON_MATERIAL. |
| Compensability | COMPENSABLE or NON_COMPENSABLE. |
| EvidenceReference | Evidence supporting assessment. |
| Rationale | Assessment rationale. |
| TransitionDisposition | TRANSITION_VALID, TRANSITION_VALID_WITH_LIMITATIONS, TRANSITION_PARTIAL, REVALIDATION_REQUIRED, TRANSITION_INVALID, TRANSITION_NOT_EFFECTIVE, INSUFFICIENT_EVIDENCE, or DISPUTED. |
| AdjudicationStatus | NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. |
| FinalResult | Final adjudicated result. |
