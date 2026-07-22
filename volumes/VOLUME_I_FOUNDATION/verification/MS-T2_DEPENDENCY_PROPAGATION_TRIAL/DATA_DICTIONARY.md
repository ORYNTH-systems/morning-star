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
