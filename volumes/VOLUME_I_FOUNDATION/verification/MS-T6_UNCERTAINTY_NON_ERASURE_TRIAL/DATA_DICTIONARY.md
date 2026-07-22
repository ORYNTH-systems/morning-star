# MS-T6 Data Dictionary

**Document Identifier:** MS-V1-T6-DD-001  
**Version:** 0.1.0

## Source Uncertainty State Fields

| Field | Definition |
|---|---|
| SourceStateID | Stable source uncertainty identifier. |
| EvidenceObjectID | Evidence object containing uncertainty. |
| UncertaintyClass | UNKNOWN, MISSING, PARTIAL, APPROXIMATE, CONFLICTING, INDETERMINATE, DISPUTED, UNVERIFIED, INSUFFICIENT_EVIDENCE, or NOT_APPLICABLE. |
| AffectedProperty | Property affected by uncertainty. |
| UncertaintySource | Origin of uncertainty. |
| Materiality | MATERIAL or NON_MATERIAL. |
| ResolutionState | OPEN, PARTIALLY_RESOLVED, RESOLVED, DISPUTED, or SUPERSEDED. |
| CanonicalEvidence | Authoritative evidence reference. |
| ProhibitedInference | Unsupported conclusion prohibited by the source state. |
| GoverningVersion | Applicable governing version. |

## Uncertainty Case Fields

| Field | Definition |
|---|---|
| CaseID | Stable trial-case identifier. |
| SourceStateID | Source uncertainty state under evaluation. |
| Condition | GOVERNED_PRESERVATION, UNGOVERNED_DETERMINIZATION, or DETERMINATE_CONTROL. |
| InterpretationTask | Required interpretive task. |
| DecisionRequired | YES or NO. |
| CanonicalResponseClass | Expected uncertainty-preserving response class. |
| ProhibitedResponseClass | Unsupported response class. |
| ExpectedDisposition | Canonically expected assessment result. |
| CaseStatus | DRAFT, APPROVED, ACTIVE, COMPLETE, INVALID, or SUPERSEDED. |

## Observer Response Fields

| Field | Definition |
|---|---|
| ResponseID | Stable response identifier. |
| CaseID | Trial case answered. |
| ObserverID | Observer or system identifier. |
| EvidenceStateIdentified | Evidence state identified in response. |
| UncertaintyClassIdentified | Uncertainty class identified in response. |
| Interpretation | Interpretation produced. |
| Decision | Decision produced where required. |
| CertaintyClaim | Certainty claim made by observer. |
| DeclaredUncertainty | Residual uncertainty explicitly preserved. |
| ResolutionRequirements | Evidence or process required for resolution. |
| EvidenceReferences | Sources cited by observer. |
| SubmittedAt | Submission timestamp. |
| ResponseStatus | SUBMITTED, WITHDRAWN, INVALID, or SUPERSEDED. |

## Uncertainty Transformation Fields

| Field | Definition |
|---|---|
| TransformationID | Stable transformation identifier. |
| ResponseID | Response producing the transformation. |
| SourceUncertaintyClass | Original uncertainty class. |
| OutputUncertaintyClass | Resulting uncertainty class. |
| TransformationClass | PRESERVED, NARROWED_WITH_EVIDENCE, RESOLVED_WITH_EVIDENCE, ERASURE, INFLATION, MISCLASSIFICATION, or DECISION_WITH_PRESERVED_UNCERTAINTY. |
| SupportingEvidence | Evidence supporting the transformation. |
| CertaintyAsserted | YES or NO. |
| ActionOccurred | YES or NO. |
| ResidualUncertainty | Remaining uncertainty. |
| TraceabilityState | COMPLETE, PARTIAL, MISSING, or DISPUTED. |

## Uncertainty Assessment Fields

| Field | Definition |
|---|---|
| AssessmentID | Stable assessment identifier. |
| ResponseID | Response assessed. |
| PropertyClass | MISSINGNESS, APPROXIMATION, CONFLICT, INDETERMINACY, VERIFICATION, EVIDENCE_SUFFICIENCY, DECISION, or TRACEABILITY. |
| AssessorID | Assessor identity. |
| AssessmentResult | PRESERVED, NARROWED_WITH_EVIDENCE, RESOLVED_WITH_EVIDENCE, ERASURE, INFLATION, MISCLASSIFICATION, DECISION_WITH_PRESERVED_UNCERTAINTY, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. |
| Materiality | MATERIAL or NON_MATERIAL. |
| Compensability | COMPENSABLE or NON_COMPENSABLE. |
| EvidenceReference | Evidence supporting assessment. |
| Rationale | Assessment rationale. |
| AdjudicationStatus | NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. |
| FinalResult | Final adjudicated result. |
