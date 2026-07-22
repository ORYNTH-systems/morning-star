# MS-T3 Data Dictionary

**Document Identifier:** MS-V1-T3-DD-001  
**Version:** 0.1.0

## Authority Scenario Fields

| Field | Definition |
|---|---|
| ScenarioID | Stable trial-scenario identifier. |
| ScenarioPairID | Identifier linking paired conditions. |
| AuthorityModel | EXPLICIT_ASSIGNMENT or CAPABILITY_INFERENCE. |
| ParticipantID | Participant presented with the action opportunity. |
| GovernedObjectID | Object affected by the action. |
| RequestedAction | Action under evaluation. |
| RequiredRole | Role required for valid action. |
| RequiredDomain | Domain required for valid action. |
| RequiredVersion | Governing version required for valid action. |
| RequiredCapability | Capability threshold required. |
| CorrectDisposition | Canonically valid action disposition. |
| ScenarioStatus | DRAFT, APPROVED, ACTIVE, COMPLETE, INVALID, or SUPERSEDED. |

## Participant Capability Fields

| Field | Definition |
|---|---|
| CapabilityRecordID | Stable capability-record identifier. |
| ParticipantID | Participant whose capability is assessed. |
| Domain | Capability domain. |
| CapabilityClass | Knowledge, skill, reconstruction, evaluation, correction, or governance capability. |
| CapabilityStatus | UNASSESSED, INSUFFICIENT, PARTIAL, QUALIFIED, DISPUTED, EXPIRED, or SUPERSEDED. |
| EvidenceReference | Evidence supporting the capability status. |
| AssessorID | Capability assessor. |
| AssessedAt | Assessment timestamp. |
| ExpiresAt | Capability expiration timestamp where applicable. |
| Limitations | Declared limitations. |

## Authority Assignment Fields

| Field | Definition |
|---|---|
| AssignmentID | Stable authority-assignment identifier. |
| ParticipantID | Participant receiving authority. |
| AuthoritySource | Canonical source of authority. |
| RoleID | Assigned role. |
| Domain | Authorized domain. |
| PermittedActions | Authorized action classes. |
| GoverningVersion | Version within assignment scope. |
| ValidFrom | Assignment start timestamp. |
| ValidUntil | Assignment expiration timestamp. |
| Constraints | Applicable constraints. |
| DelegationBasis | Source and validity of delegation. |
| AuthorityStatus | NOT_ASSIGNED, ACTIVE, LIMITED, SUSPENDED, EXPIRED, REVOKED, DISPUTED, or SUPERSEDED. |

## Action Decision Fields

| Field | Definition |
|---|---|
| DecisionID | Stable decision identifier. |
| ScenarioID | Scenario under evaluation. |
| ParticipantID | Participant making or receiving the decision. |
| Decision | PERMITTED, BLOCKED, ESCALATED, DEFERRED, REQUESTED_AUTHORITY, REQUESTED_CAPABILITY_REVIEW, ACTED_WITHOUT_AUTHORITY, or ACTED_OUTSIDE_SCOPE. |
| DecisionRationale | Recorded decision rationale. |
| EvidenceReference | Evidence used for the decision. |
| DecidedAt | Decision timestamp. |
| ActionOccurred | YES or NO. |
| ActionResult | Outcome of the attempted or completed action. |

## Authority Assessment Fields

| Field | Definition |
|---|---|
| AssessmentID | Stable authority-assessment identifier. |
| DecisionID | Decision being assessed. |
| AssessorID | Assessor identity. |
| CapabilityValid | YES, NO, DISPUTED, or INSUFFICIENT_EVIDENCE. |
| AuthoritySourceValid | YES, NO, DISPUTED, or INSUFFICIENT_EVIDENCE. |
| RoleMatch | YES, NO, or NOT_APPLICABLE. |
| DomainMatch | YES, NO, or NOT_APPLICABLE. |
| ActionScopeMatch | YES, NO, or NOT_APPLICABLE. |
| VersionMatch | YES, NO, or NOT_APPLICABLE. |
| TemporalValidity | VALID, EXPIRED, NOT_STARTED, or INDETERMINATE. |
| DelegationValidity | VALID, INVALID, NOT_APPLICABLE, or INDETERMINATE. |
| AssessmentResult | VALID_AUTHORIZED_ACTION, UNAUTHORIZED_ACTION, SCOPE_VIOLATION, FALSE_BLOCK, VALID_ESCALATION, INVALID_ESCALATION, INSUFFICIENT_CAPABILITY, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. |
| EvidenceReference | Evidence supporting the assessment. |
| Rationale | Assessment rationale. |
| AdjudicationStatus | NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. |
| FinalResult | Final adjudicated result. |
