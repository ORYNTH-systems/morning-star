# Morning Star Ontology Validation Rules

**Document ID:** MS-V2-VALIDATION-001  
**Version:** 0.1.0  
**Status:** ONTOLOGY FOUNDATION  

## Validation Sequence

Every ontology object must pass:

1. JSON structural validation
2. object identifier validation
3. object-class registry validation
4. required-field validation
5. authority reference validation
6. status registry validation
7. uncertainty registry validation
8. provenance reference validation
9. relationship validation
10. lifecycle-transition validation
11. dependency validation
12. constitutional invariant validation
13. deterministic serialization validation
14. SHA-256 integrity validation

## Failure Rule

A failure at any stage prevents canonical admission.

The validator must preserve:

- failed stage;
- failure reason;
- affected field;
- governing rule;
- evidence;
- timestamp;
- reevaluation eligibility.

## Silent Default Rule

A validator must not silently create:

- authority;
- provenance;
- uncertainty;
- lifecycle state;
- semantic state;
- participation state;
- version;
- relationship;
- evidence;
- canonical equivalence.

## Duplicate Identity Rule

Duplicate object identifiers are prohibited.

Duplicate relationship identifiers are prohibited.

Object names may repeat only when identity and scope remain distinguishable.

## Referential Integrity Rule

Every referenced object, authority, provenance record, dependency, and relationship must resolve to a registered identifier or remain explicitly unresolved.

## Determinism Rule

Equivalent canonical objects must serialize to equivalent canonical bytes after normalized field ordering and newline handling.

## Constitutional Result

An object is ontologically admissible only when its identity, class, authority, scope, status, provenance, uncertainty, version, relationships, and validation state are all explicit and constitutionally coherent.
