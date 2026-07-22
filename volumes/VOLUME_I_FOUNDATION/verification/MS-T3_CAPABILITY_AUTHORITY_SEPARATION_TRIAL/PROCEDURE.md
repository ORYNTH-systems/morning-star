# MS-T3 Trial Procedure

**Document Identifier:** MS-V1-T3-PRO-001  
**Verification Identifier:** MS-VER-T3-001  
**Version:** 0.1.0

## 1. Preparation

1. Freeze the governing Morning Star version.
2. define the capability vocabulary.
3. define the authority vocabulary.
4. select governed roles and domains.
5. create paired authority scenarios.
6. register correct dispositions.
7. freeze action-class boundaries.
8. freeze exception rules.
9. register assessors.
10. freeze the scoring model.

## 2. Participant Capability Registration

For each participant:

1. assign a participant identifier;
2. record the relevant domain;
3. record capability evidence;
4. assign capability status;
5. record evidence date;
6. record assessor identity;
7. record limitations;
8. record capability expiration where applicable.

## 3. Authority Assignment Registration

For each authority assignment:

1. assign an authority-assignment identifier;
2. identify participant;
3. identify authority source;
4. identify role;
5. identify domain;
6. identify permitted action classes;
7. identify governing version;
8. identify start time;
9. identify expiration time;
10. identify constraints;
11. identify delegation basis;
12. record authority status.

## 4. Scenario Pairing

For each scenario pair:

1. preserve the same participant capability;
2. preserve the same action request;
3. preserve the same governed object;
4. preserve the same environment;
5. apply explicit assignment in one condition;
6. apply capability inference in the paired condition;
7. prevent cross-condition contamination;
8. verify scenario equivalence.

## 5. Decision Collection

For each action opportunity, record whether the participant or system:

- PERMITTED;
- BLOCKED;
- ESCALATED;
- DEFERRED;
- REQUESTED_AUTHORITY;
- REQUESTED_CAPABILITY_REVIEW;
- ACTED_WITHOUT_AUTHORITY;
- ACTED_OUTSIDE_SCOPE.

Each decision shall include rationale and evidence.

## 6. Action Assessment

Each action shall be assessed as:

- VALID_AUTHORIZED_ACTION;
- UNAUTHORIZED_ACTION;
- SCOPE_VIOLATION;
- FALSE_BLOCK;
- VALID_ESCALATION;
- INVALID_ESCALATION;
- INSUFFICIENT_CAPABILITY;
- INSUFFICIENT_EVIDENCE;
- DISPUTED;
- NOT_APPLICABLE.

## 7. Authority Validation

Assessors shall verify:

1. authority source;
2. role match;
3. domain match;
4. action-class match;
5. governing-version match;
6. temporal validity;
7. delegation validity;
8. constraint satisfaction;
9. revocation state;
10. exception-rule validity.

## 8. Capability Validation

Assessors shall independently verify:

1. capability evidence;
2. domain relevance;
3. evidence currency;
4. limitation state;
5. qualification status;
6. required reconstruction competence.

Capability assessment shall not determine authority status.

## 9. Accountability Assessment

For each action, record:

- responsible participant;
- assigning authority;
- approving authority;
- reviewing authority;
- action evidence;
- correction responsibility;
- reversal responsibility;
- unresolved accountability ambiguity.

## 10. Analysis

Calculate by condition:

- unauthorized-action rate;
- valid-action completion rate;
- false-block rate;
- role-scope violation rate;
- domain-scope violation rate;
- temporal violation rate;
- version mismatch rate;
- delegation failure rate;
- traceability completeness;
- accountability ambiguity rate;
- correction and reversal rate.

## 11. Adjudication

Where assessors disagree:

1. preserve original judgments;
2. identify disputed authority property;
3. preserve supporting evidence;
4. conduct bounded adjudication;
5. record final result;
6. retain disagreement history.

## 12. Closure

The trial may close only when:

- all capability profiles are recorded;
- all authority assignments are recorded;
- all scenario pairs are complete;
- all action decisions are preserved;
- all authority assessments are complete;
- false blocks are evaluated;
- exception cases are resolved or preserved;
- accountability findings are recorded;
- analysis is reproducible;
- limitations are declared;
- theorem disposition is assigned.
