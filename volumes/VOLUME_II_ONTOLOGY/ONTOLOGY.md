# Morning Star Volume II — Ontology

**Document ID:** MS-V2-ONTOLOGY-001  
**Document Type:** Constitutional Volume Specification  
**Version:** 0.1.0  
**Status:** ONTOLOGY FOUNDATION  
**Governing Authority:** Morning Star Constitution  
**Author:** Ashley S. Harris  

---

## 1. Purpose

Volume II defines the canonical objects that may exist inside Morning Star, the identities those objects must preserve, the relationships they may form, the lifecycle states they may occupy, and the validation rules required for machine-stable representation.

Volume II does not determine whether every represented claim is true.

It determines whether the object representing that claim is constitutionally valid, attributable, traceable, stateful, bounded, and interoperable within Morning Star.

---

## 2. Ontological Authority

The Morning Star Constitution governs this volume.

Where this volume conflicts with the Constitution, the Constitution prevails.

Volume II may formalize constitutional objects but may not silently create new constitutional authority.

---

## 3. Canonical Object Principle

Every governed object must possess:

1. stable identity;
2. object class;
3. canonical name;
4. governing authority;
5. constitutional scope;
6. lifecycle state;
7. version;
8. provenance;
9. uncertainty status;
10. creation timestamp;
11. revision timestamp;
12. relationship trace;
13. validation status.

No object may enter canonical representation without satisfying the minimum schema for its object class.

---

## 4. Canonical Object Classes

Volume II recognizes the following canonical object classes:

- Framework
- CanonicalObject
- SemanticUnit
- Actor
- Observer
- Participant
- Steward
- ConstitutionalMaintainer
- AuthoritySource
- Dependency
- EntryPoint
- SemanticState
- ParticipationState
- Interpretation
- UncertaintyObject
- ProvenanceRecord
- EvidenceObject
- DriftEvent
- ReconstructionEvent
- Revision
- FrameworkAdmission
- VerificationResult
- AuditFinding
- CorrectionRecord

---

## 5. Object Identity

Every object must possess an immutable identifier.

Object identifiers must:

- be unique within Morning Star;
- remain stable across serialization;
- remain stable across non-substantive revision;
- never be silently reused;
- preserve supersession history;
- support deterministic reference;
- be traceable to creation authority.

Deletion must not cause identifier reassignment.

---

## 6. Object Status

The canonical object-status family is:

- PROPOSED
- REGISTERED
- ACTIVE
- UNDER_REVIEW
- VERIFIED
- SUPERSEDED
- DEPRECATED
- REVOKED
- REJECTED
- ARCHIVED
- UNRESOLVED

Status must remain separate from semantic state, participation state, verification result, and uncertainty class.

---

## 7. Relationship Classes

The canonical relationship family is:

- DEFINES
- GOVERNS
- OWNS
- REFERENCES
- DEPENDS_ON
- REQUIRES
- DERIVES_FROM
- INTERPRETS
- EVIDENCES
- VERIFIES
- CONTRADICTS
- SUPERSEDES
- REVISES
- RECONSTRUCTS
- ADMITS
- EXCLUDES
- IMPLEMENTS
- AUDITS
- CORRECTS

Every relationship must identify:

- relationship identifier;
- source object;
- target object;
- relationship class;
- governing authority;
- effective version;
- provenance;
- validation status.

---

## 8. Lifecycle Governance

Every object class must define:

- creation condition;
- registration condition;
- activation condition;
- review condition;
- revision condition;
- supersession condition;
- revocation condition;
- archival condition;
- prohibited transitions.

Lifecycle transitions must be explicit and evidence-bearing.

Silent transition is prohibited.

---

## 9. Authority Source

An authority source is a governed object establishing bounded definitional, approval, maintenance, interpretive, or operational authority.

An authority source must declare:

- authority identifier;
- authority type;
- authority holder;
- governed scope;
- effective version;
- source evidence;
- limitations;
- revocation conditions;
- delegation rules.

Authority must not be inferred solely from visibility, confidence, access, reputation, authorship, employment, or technical capability.

---

## 10. Semantic Unit

A semantic unit is the smallest governed unit of meaning that Morning Star represents independently.

A semantic unit must identify:

- canonical expression;
- definition;
- source authority;
- scope;
- dependencies;
- prohibited equivalences;
- interpretation boundary;
- uncertainty status;
- version.

Semantic units must not be decomposed or compressed in ways that erase constitutional meaning.

---

## 11. Interpretation Object

An interpretation object must identify:

- interpretation identifier;
- interpreted object;
- interpretation class;
- interpreter;
- source basis;
- scope;
- authority;
- confidence;
- uncertainty;
- dependencies;
- equivalence claim;
- admission status.

No interpretation may claim canonical equivalence without explicit evidence and authority.

---

## 12. Uncertainty Object

An uncertainty object preserves unresolved epistemic or constitutional status.

The canonical uncertainty family is:

- UNKNOWN
- INCOMPLETE
- APPROXIMATE
- DISPUTED
- SPECULATIVE
- INDETERMINATE
- CONFLICTING
- TEMPORARILY_UNAVAILABLE
- NOT_APPLICABLE

Unknown is not equivalent to false.

Incomplete is not equivalent to invalid.

Disputed is not equivalent to rejected.

---

## 13. Provenance Object

A provenance record must preserve:

- source;
- source type;
- creator;
- authority;
- acquisition method;
- transformation history;
- custody history;
- timestamps;
- version;
- hash where applicable;
- relationship to derived objects.

A citation alone does not constitute complete provenance.

---

## 14. Evidence Object

An evidence object must identify:

- evidence identifier;
- evidence type;
- source;
- claim supported;
- admissibility state;
- integrity state;
- scope;
- temporal validity;
- authority;
- uncertainty;
- hash;
- evaluation result.

Evidence must remain distinguishable from interpretation, claim, conclusion, and authority.

---

## 15. Drift Event

A drift event exists when an object or relationship no longer preserves one or more constitutional properties.

A drift event must record:

- affected object;
- prior state;
- detected state;
- drift class;
- violated invariant;
- detection source;
- evidence;
- severity;
- downstream impact;
- reconstruction requirement.

---

## 16. Reconstruction Event

A reconstruction event must preserve:

- drift event reference;
- affected object;
- last admissible state;
- corrective evidence;
- corrective authority;
- reconstruction method;
- resulting state;
- unresolved differences;
- downstream revalidation requirements.

Reconstruction must not erase the drift event.

---

## 17. Revision Object

A revision must identify:

- revised object;
- prior version;
- new version;
- revision authority;
- rationale;
- affected relationships;
- dependency impact;
- migration requirements;
- validation evidence;
- effective timestamp.

Revision must not silently alter historical canonical states.

---

## 18. Framework Admission Object

A framework admission object must identify:

- framework identity;
- framework authority;
- constitutional subject;
- boundaries;
- dependencies;
- version model;
- source corpus;
- relationship map;
- admission decision;
- admission scope;
- uncertainty;
- review date.

Admission establishes governable representation, not endorsement or universal correctness.

---

## 19. Verification Result

A verification result must identify:

- claim;
- verification method;
- evidence set;
- evaluation authority;
- scope;
- conditions;
- falsification criteria;
- result;
- uncertainty;
- reproducibility status;
- release status.

Verification scope must not exceed evidence scope.

---

## 20. Audit Finding

An audit finding must identify:

- affected object;
- violated requirement;
- finding class;
- severity;
- evidence;
- constitutional owner;
- required correction;
- verification status;
- closure status.

---

## 21. Correction Record

A correction record must preserve:

- finding reference;
- affected object;
- prior state;
- correction method;
- authority;
- evidence;
- resulting state;
- validation result;
- closure decision.

Correction must remain distinguishable from reconstruction, revision, deletion, and supersession.

---

## 22. Serialization Requirements

Every machine-stable object must support:

- deterministic field naming;
- explicit null handling;
- stable identifiers;
- explicit versions;
- explicit timestamps;
- explicit authority;
- explicit uncertainty;
- explicit lifecycle state;
- deterministic serialization;
- SHA-256 integrity verification;
- exact reconstruction.

Silent defaults are prohibited where they would change constitutional meaning.

---

## 23. Validation Order

Object validation must occur in this order:

1. structural validity;
2. identifier validity;
3. object-class validity;
4. required-field validity;
5. authority validity;
6. lifecycle-state validity;
7. relationship validity;
8. dependency validity;
9. provenance validity;
10. uncertainty validity;
11. constitutional-invariant validity;
12. serialization-integrity validity.

A later validation stage must not override an earlier failure.

---

## 24. Prohibited Ontological Conflations

The following conflations are prohibited:

- object identity with object name;
- authority with authorship;
- evidence with conclusion;
- interpretation with canonical source;
- semantic state with participation state;
- uncertainty with failure;
- revision with deletion;
- reconstruction with silent correction;
- admission with endorsement;
- verification with universal truth;
- lifecycle state with integrity state;
- relationship presence with relationship validity.

---

## 25. Canonical Result

The canonical result of Volume II is:

> A machine-stable, authority-bounded, provenance-preserving ontology in which every Morning Star object, relationship, lifecycle transition, uncertainty state, revision, drift event, and verification result can be deterministically represented and constitutionally validated.
