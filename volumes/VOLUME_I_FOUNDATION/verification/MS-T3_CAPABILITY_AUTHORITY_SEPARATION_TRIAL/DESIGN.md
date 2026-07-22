# MS-T3 — Capability and Authority Separation Trial

**Verification Identifier:** MS-VER-T3-001  
**Theorem Identifier:** MS-T3  
**Document Identifier:** MS-V1-T3-DES-001  
**Design Status:** Design Candidate  
**Version:** 0.1.0

## 1. Purpose

This trial evaluates whether systems that preserve capability and authority as independent constitutional properties produce fewer unauthorized actions than systems that infer authority from demonstrated capability.

## 2. Canonical Theorem

No demonstrated capability is sufficient to create constitutional authority unless authority is explicitly assigned by a valid governing mechanism.

\[
Capability(O,d)=1
\nRightarrow
Authority(O,d)=1
\]

Capability may establish eligibility for consideration, but it does not independently create permission, jurisdiction, mandate, delegation, stewardship, or governance authority.

## 3. Research Hypothesis

Explicit authority assignment will reduce unauthorized actions, scope violations, and accountability failures compared with governance models that infer authority from capability.

## 4. Null Hypothesis

Separating capability from authority will produce no measurable governance benefit compared with authority inferred from capability.

## 5. Experimental Conditions

### Condition A — Explicit Authority Assignment

Participants may act only when:

- capability requirements are satisfied;
- role assignment exists;
- authority source is valid;
- domain scope is declared;
- action class is permitted;
- governing version is known;
- temporal validity is active;
- applicable constraints are satisfied.

### Condition B — Capability-Inferred Authority

Participants are permitted or expected to act when they demonstrate relevant capability, without a separate explicit authority-assignment requirement.

## 6. Independent Variable

\[
X = AuthorityModel
\]

where:

\[
X \in
\{
EXPLICIT\_ASSIGNMENT,
CAPABILITY\_INFERENCE
\}
\]

## 7. Dependent Variables

The trial measures:

- unauthorized action rate;
- role-scope violation rate;
- domain-scope violation rate;
- temporal-authority violation rate;
- version-authority mismatch rate;
- invalid delegation rate;
- accountability ambiguity;
- traceability completeness;
- valid-action completion rate;
- correction and reversal cost.

## 8. Controlled Variables

Paired scenarios shall preserve:

- participant capability;
- task complexity;
- governed object;
- action request;
- available evidence;
- decision time;
- governing rules;
- environmental conditions;
- assessment criteria.

The controlled difference shall be the authority model.

## 9. Capability Model

Participant capability is represented as:

\[
C_O =
(K,S,E,R,V)
\]

where:

- \(K\) is relevant knowledge;
- \(S\) is demonstrated skill;
- \(E\) is evidence of competence;
- \(R\) is reconstruction competence;
- \(V\) is verified domain competence.

Capability status shall use:

- UNASSESSED;
- INSUFFICIENT;
- PARTIAL;
- QUALIFIED;
- DISPUTED;
- EXPIRED;
- SUPERSEDED.

## 10. Authority Model

Authority is represented as:

\[
A_O =
(Source,Role,Domain,Action,Version,Time,Constraints)
\]

Valid authority requires all material properties to be present and admissible.

Authority status shall use:

- NOT_ASSIGNED;
- ACTIVE;
- LIMITED;
- SUSPENDED;
- EXPIRED;
- REVOKED;
- DISPUTED;
- SUPERSEDED.

## 11. Authority Validity Function

For participant \(O\), action \(a\), domain \(d\), version \(v\), and time \(t\):

\[
ValidAuthority(O,a,d,v,t)
=
S_A
\land
R_A
\land
D_A
\land
X_A
\land
V_A
\land
T_A
\land
C_A
\]

where:

- \(S_A\) is valid authority source;
- \(R_A\) is valid role;
- \(D_A\) is matching domain;
- \(X_A\) is permitted action class;
- \(V_A\) is matching governing version;
- \(T_A\) is temporal validity;
- \(C_A\) is constraint satisfaction.

## 12. Unauthorized Action

An unauthorized action occurs when:

\[
Attempted(O,a)=1
\]

and:

\[
ValidAuthority(O,a,d,v,t)=0
\]

Capability does not alter this result.

## 13. Scenario Architecture

Each trial scenario shall include:

- one participant;
- one capability profile;
- one governed role;
- one action request;
- one authority source;
- one domain boundary;
- one action-class boundary;
- one governing version;
- one temporal condition;
- one or more constraints;
- one correct authority disposition.

## 14. Scenario Classes

The trial shall include scenarios involving:

- qualified but unauthorized participants;
- authorized but insufficiently capable participants;
- qualified and authorized participants;
- neither qualified nor authorized participants;
- expired authority;
- revoked authority;
- domain mismatch;
- role mismatch;
- action-class mismatch;
- version mismatch;
- invalid delegation;
- emergency or exceptional authority.

## 15. Primary Outcome

The primary outcome is:

\[
UnauthorizedActionRate =
\frac{UnauthorizedActions}{ActionOpportunities}
\]

## 16. Secondary Outcomes

Secondary outcomes include:

- valid-action completion rate;
- false-block rate;
- authority-verification accuracy;
- capability-verification accuracy;
- scope-violation rate;
- correction cost;
- reversal frequency;
- accountability-resolution time;
- traceability completeness.

## 17. Success Condition

MS-T3 receives preliminary support when:

1. explicit assignment produces a lower unauthorized-action rate;
2. valid authorized actions remain substantially executable;
3. capability is not treated as authority;
4. authority decisions are reproducible from preserved evidence;
5. accountability is materially clearer under explicit assignment;
6. no equivalent governance defect offsets the observed benefit.

## 18. Falsification Condition

MS-T3 is falsified within the tested scope when capability-inferred authority produces outcomes that are equally or more:

- bounded;
- coherent;
- traceable;
- accountable;
- reversible;
- non-destructive;

without a valid separate authority-assignment mechanism.

## 19. Inconclusive Condition

The result remains inconclusive when:

- capability definitions are ambiguous;
- authority assignments are incomplete;
- scenarios do not preserve equivalence;
- action outcomes cannot be classified reliably;
- participants receive inconsistent instructions;
- evidence is insufficient;
- exception rules are uncontrolled;
- assessor agreement is inadequate.

## 20. False Blocking

Explicit authority governance shall also be evaluated for invalid obstruction.

A false block occurs when:

\[
ValidAuthority(O,a,d,v,t)=1
\]

and:

\[
ActionBlocked(O,a)=1
\]

without another valid constitutional basis.

Reducing unauthorized action by preventing all action does not support the theorem.

## 21. Emergency Authority

Emergency authority shall remain governed.

An emergency condition shall not convert capability into authority automatically unless an explicit constitutional rule defines that transition.

Emergency authority shall declare:

- activation condition;
- authority source;
- permitted scope;
- duration;
- required evidence;
- review requirement;
- expiration condition.

## 22. Non-Compensable Properties

The following shall not be averaged away:

- authority source;
- role identity;
- domain scope;
- action scope;
- governing version;
- temporal validity;
- revocation state;
- delegation validity.

## 23. Research Boundary

This trial evaluates constitutional authority assignment.

It does not establish:

- employment eligibility;
- legal licensure;
- institutional legitimacy;
- moral authority;
- political authority;
- universal organizational design;
- general participant intelligence.

## 24. Design Invariants

1. Capability shall remain distinct from authority.
2. Every authority assignment shall identify a source.
3. Every action shall be assessed against role and scope.
4. Expired or revoked authority shall remain invalid.
5. Valid capability shall not cure invalid authority.
6. Valid authority shall not cure insufficient capability.
7. False blocks shall be reported.
8. Unauthorized actions shall remain individually visible.
9. Exception authority shall be explicit.
10. The result shall not exceed the tested governance domain.
