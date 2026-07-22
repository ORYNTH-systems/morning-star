# MS-T8 Data Dictionary

**Document Identifier:** MS-V1-T8-DD-001  
**Version:** 0.1.0

## Canonical Object Fields

| Field | Definition |
|---|---|
| ObjectID | Stable canonical-object identifier. |
| ObjectType | Type of governed object. |
| ObjectName | Canonical object name. |
| CanonicalDefinition | Canonical definition. |
| Domain | Governed domain. |
| GoverningVersion | Applicable version. |
| AuthoritySource | Authority governing the object. |
| CanonicalSource | Authoritative source reference. |
| ObjectStatus | DRAFT, ACTIVE, RETIRED, SUPERSEDED, or DISPUTED. |

## Evidence Reference Fields

| Field | Definition |
|---|---|
| EvidenceID | Stable evidence identifier. |
| EvidenceType | DOCUMENT, REGISTER, DATASET, DECISION, REVISION, TRANSFORMATION, or OTHER. |
| SourceReference | Source location or identifier. |
| GoverningVersion | Version associated with evidence. |
| ProvenanceAuthority | Authority or provenance source. |
| IntegrityReference | Hash, checksum, commit, or equivalent reference. |
| UncertaintyState | Evidence uncertainty state. |
| AccessibilityState | AVAILABLE, RESTRICTED, MISSING, BROKEN, or DISPUTED. |
| EvidenceStatus | ACTIVE, SUPERSEDED, INVALID, or DISPUTED. |

## Traceability Chain Fields

| Field | Definition |
|---|---|
| ChainID | Stable traceability-chain identifier. |
| SourceObjectID | Originating canonical object. |
| ResultObjectID | Current result object. |
| LinkSequence | Ordered material-link sequence. |
| RequiredLinkCount | Number of required material links. |
| ResolvedLinkCount | Number of resolving links. |
| MissingLinkClasses | Missing material-link classes. |
| TransformationCount | Number of transformations. |
| RevisionDepth | Number of revisions traversed. |
| ChainCondition | COMPLETE_TRACEABILITY, PARTIAL_TRACEABILITY, BROKEN_TRACEABILITY, or DETERMINATE_CONTROL. |
| ChainStatus | DRAFT, APPROVED, ACTIVE, COMPLETE, INVALID, or SUPERSEDED. |

## Reconstruction Case Fields

| Field | Definition |
|---|---|
| CaseID | Stable reconstruction-case identifier. |
| ChainID | Traceability chain under evaluation. |
| Condition | COMPLETE_TRACEABILITY, PARTIAL_TRACEABILITY, BROKEN_TRACEABILITY, or DETERMINATE_CONTROL. |
| TargetProperties | Material properties to reconstruct. |
| HiddenLinks | Links withheld or removed for the condition. |
| ExpectedReconstruction | Expected canonical reconstruction. |
| ExpectedDisposition | Expected reconstruction disposition. |
| GoverningVersion | Version governing the case. |
| CaseStatus | DRAFT, APPROVED, ACTIVE, COMPLETE, INVALID, or SUPERSEDED. |

## Reconstruction Response Fields

| Field | Definition |
|---|---|
| ResponseID | Stable response identifier. |
| CaseID | Reconstruction case answered. |
| ObserverID | Observer or system identity. |
| ReconstructedObjectID | Object identity reconstructed. |
| ReconstructedSource | Canonical source reconstructed. |
| ReconstructedVersion | Governing version reconstructed. |
| ReconstructedAuthority | Authority source reconstructed. |
| ReconstructedDependencies | Dependencies reconstructed. |
| ReconstructedTransformations | Transformations reconstructed. |
| ReconstructedEvidence | Evidence references reconstructed. |
| ReconstructedUncertainty | Uncertainty state reconstructed. |
| ReconstructedSupersession | Supersession state reconstructed. |
| MissingOrAmbiguousLinks | Links identified as missing or ambiguous. |
| EvidenceReferences | Records cited by observer. |
| SubmittedAt | Submission timestamp. |
| ResponseStatus | SUBMITTED, WITHDRAWN, INVALID, or SUPERSEDED. |

## Traceability Assessment Fields

| Field | Definition |
|---|---|
| AssessmentID | Stable assessment identifier. |
| ResponseID | Response assessed. |
| PropertyClass | IDENTITY, SOURCE, VERSION, AUTHORITY, DEPENDENCY, TRANSFORMATION, EVIDENCE, UNCERTAINTY, SUPERSESSION, or RESULT. |
| AssessorID | Assessor identity. |
| AssessmentResult | CORRECTLY_RECONSTRUCTED, PARTIALLY_RECONSTRUCTED, RECONSTRUCTED_WITH_UNCERTAINTY, INCORRECTLY_RECONSTRUCTED, UNSUPPORTED_RECONSTRUCTION, NOT_RECONSTRUCTABLE, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. |
| FailureClass | MISSING, BROKEN, AMBIGUOUS, NON_RESOLVING, VERSION_MISMATCHED, IDENTITY_MISMATCHED, AUTHORITY_MISMATCHED, ORDER_INVERTED, SUPERSEDED_WITHOUT_NOTICE, UNSUPPORTED, or NOT_APPLICABLE. |
| Materiality | MATERIAL or NON_MATERIAL. |
| Compensability | COMPENSABLE or NON_COMPENSABLE. |
| EvidenceReference | Evidence supporting assessment. |
| Rationale | Assessment rationale. |
| AdjudicationStatus | NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. |
| FinalResult | Final adjudicated result. |
