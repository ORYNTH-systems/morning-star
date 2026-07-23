# MS-T1 and MS-T2 Schema and Rule Register

**Generated:** 2026-07-23T17:21:39-05:00

This register captures the exact CSV schemas and operational rules required before controlled trial execution.

## MS-T1

### CSV Schemas

#### OBSERVER_RESPONSES.csv

| Position | Column |
|---:|---|
| 1 | ResponseID |
| 2 | ObserverID |
| 3 | CaseID |
| 4 | EntryCondition |
| 5 | ObserverClass |
| 6 | PriorExposure |
| 7 | SubmittedAt |
| 8 | ResponseText |
| 9 | SourceReferences |
| 10 | DeclaredUncertainty |
| 11 | ResponseStatus |

**Imported rows:** 1

**Current row completeness:**

- CSV row 2: **INCOMPLETE**; missing: ResponseID, ObserverID, CaseID, EntryCondition, ObserverClass, PriorExposure, SubmittedAt, ResponseText, SourceReferences, DeclaredUncertainty, ResponseStatus

#### SEMANTIC_ASSESSMENTS.csv

| Position | Column |
|---:|---|
| 1 | AssessmentID |
| 2 | ResponseID |
| 3 | PropertyID |
| 4 | PropertyClass |
| 5 | Compensability |
| 6 | AssessorID |
| 7 | AssessmentResult |
| 8 | Materiality |
| 9 | EvidenceReference |
| 10 | Rationale |
| 11 | AdjudicationStatus |
| 12 | FinalResult |

**Imported rows:** 1

**Current row completeness:**

- CSV row 2: **INCOMPLETE**; missing: AssessmentID, ResponseID, PropertyID, PropertyClass, Compensability, AssessorID, AssessmentResult, Materiality, EvidenceReference, Rationale, AdjudicationStatus, FinalResult

#### TRIAL_CASES.csv

| Position | Column |
|---:|---|
| 1 | CaseID |
| 2 | GovernedObjectID |
| 3 | FrameworkID |
| 4 | GoverningVersion |
| 5 | MaterialPropertyCount |
| 6 | CanonicalSource |
| 7 | DependencyIDs |
| 8 | AuthoritySource |
| 9 | UncertaintyState |
| 10 | CaseStatus |

**Imported rows:** 1

**Current row completeness:**

- CSV row 2: **INCOMPLETE**; missing: GovernedObjectID, FrameworkID, GoverningVersion, MaterialPropertyCount, CanonicalSource, DependencyIDs, AuthoritySource, UncertaintyState

### Operational Rules

#### DESIGN.md

- **MS-T1-RULE-0001** — MEASUREMENT, line 11: This trial evaluates whether governed initiation reduces material semantic divergence compared with unrestricted observer entry.
- **MS-T1-RULE-0002** — EVIDENCE, line 15: For any governed ecosystem whose identity depends upon preservation of material distinctions, unrestricted observer interpretation creates a nonzero probability of semantic drift.
- **MS-T1-RULE-0003** — EVIDENCE, line 25: when observer interpretation may materially affect representation or action.
- **MS-T1-RULE-0004** — MEASUREMENT, line 29: Observers exposed to the Morning Star governed-initiation condition will demonstrate lower material semantic divergence than observers receiving unrestricted access to equivalent source material.
- **MS-T1-RULE-0005** — MEASUREMENT, line 33: There will be no reproducible difference in material semantic divergence between governed-initiation and unrestricted-entry observers.
- **MS-T1-RULE-0006** — OPERATIONAL, line 39: Observers receive:
- **MS-T1-RULE-0007** — EVIDENCE, line 46: - observer-role constraints;
- **MS-T1-RULE-0008** — OPERATIONAL, line 52: Observers receive the same canonical source materials without the governed-initiation sequence or participation constraints.
- **MS-T1-RULE-0009** — NORMATIVE, line 83: The following shall remain equivalent across conditions:
- **MS-T1-RULE-0010** — EVIDENCE, line 89: - assessment criteria;
- **MS-T1-RULE-0011** — EVIDENCE, line 91: - evidence requirements;
- **MS-T1-RULE-0012** — NORMATIVE, line 97: Observers shall be eligible only when:
- **MS-T1-RULE-0013** — EVIDENCE, line 99: 1. observer identity is recorded;
- **MS-T1-RULE-0014** — EVIDENCE, line 105: 7. the observer has not previously completed the same case set.
- **MS-T1-RULE-0015** — NORMATIVE, line 109: Each trial case shall include:
- **MS-T1-RULE-0016** — EVIDENCE, line 118: - traceable source evidence;
- **MS-T1-RULE-0017** — OPERATIONAL, line 126: MaterialSemanticDivergenceRate
- **MS-T1-RULE-0018** — OPERATIONAL, line 128: \frac{MaterialDivergences}{MaterialPropertiesAssessed}
- **MS-T1-RULE-0019** — OPERATIONAL, line 135: - non-compensable failure rate;
- **MS-T1-RULE-0020** — OPERATIONAL, line 139: - traceability failure rate;
- **MS-T1-RULE-0021** — MEASUREMENT, line 147: 1. the governed-initiation condition produces a lower material divergence rate;
- **MS-T1-RULE-0022** — REPRODUCIBILITY, line 148: 2. the reduction is reproducible across cases;
- **MS-T1-RULE-0023** — OPERATIONAL, line 149: 3. no equivalent increase occurs in another non-compensable failure class;
- **MS-T1-RULE-0024** — REPRODUCIBILITY, line 150: 4. assessors can reproduce material-property judgments;
- **MS-T1-RULE-0025** — DISPOSITION, line 155: MS-T1 is falsified within the tested scope when:
- **MS-T1-RULE-0026** — MEASUREMENT, line 157: - unrestricted entry produces an equivalent or lower material divergence rate;
- **MS-T1-RULE-0027** — REPRODUCIBILITY, line 158: - the result is reproduced across the declared case set;
- **MS-T1-RULE-0028** — DISPOSITION, line 164: The result remains inconclusive when:
- **MS-T1-RULE-0029** — MEASUREMENT, line 167: - assessor agreement is inadequate;
- **MS-T1-RULE-0030** — EVIDENCE, line 168: - observer groups are not comparable;
- **MS-T1-RULE-0031** — EVIDENCE, line 171: - evidence is incomplete;
- **MS-T1-RULE-0032** — REPRODUCIBILITY, line 172: - the measured effect is not reproducible.
- **MS-T1-RULE-0033** — NORMATIVE, line 176: The following properties shall not be averaged away:
- **MS-T1-RULE-0034** — NORMATIVE, line 201: 1. Conditions shall use equivalent canonical source material.
- **MS-T1-RULE-0035** — NORMATIVE, line 202: 2. Observer condition shall be recorded before response collection.
- **MS-T1-RULE-0036** — NORMATIVE, line 203: 3. Scoring criteria shall be established before analysis.
- **MS-T1-RULE-0037** — NORMATIVE, line 204: 4. Raw responses shall not be overwritten.
- **MS-T1-RULE-0038** — NORMATIVE, line 205: 5. Assessor judgments shall remain traceable.
- **MS-T1-RULE-0039** — NORMATIVE, line 206: 6. Missing evidence shall remain missing.
- **MS-T1-RULE-0040** — NORMATIVE, line 207: 7. Uncertainty shall not be resolved by assumption.
- **MS-T1-RULE-0041** — NORMATIVE, line 208: 8. Non-compensable failures shall remain individually visible.
- **MS-T1-RULE-0042** — NORMATIVE, line 209: 9. The theorem shall not be supported solely by directional difference.
- **MS-T1-RULE-0043** — NORMATIVE, line 210: 10. The trial result shall not exceed its tested scope.

#### PROCEDURE.md

- **MS-T1-RULE-0044** — EVIDENCE, line 22: For each observer:
- **MS-T1-RULE-0045** — EVIDENCE, line 24: 1. assign an observer identifier;
- **MS-T1-RULE-0046** — EVIDENCE, line 25: 2. record observer class;
- **MS-T1-RULE-0047** — NORMATIVE, line 30: 7. preserve required consent or authorization evidence;
- **MS-T1-RULE-0048** — EVIDENCE, line 39: 1. observer orientation;
- **MS-T1-RULE-0049** — NORMATIVE, line 60: Each observer shall:
- **MS-T1-RULE-0050** — EVIDENCE, line 68: 7. cite source evidence;
- **MS-T1-RULE-0051** — NORMATIVE, line 75: Each response shall be evaluated property by property.
- **MS-T1-RULE-0052** — EVIDENCE, line 77: Assessment values are:
- **MS-T1-RULE-0053** — OPERATIONAL, line 81: - INSUFFICIENT_EVIDENCE;
- **MS-T1-RULE-0054** — DISPOSITION, line 82: - DISPUTED;
- **MS-T1-RULE-0055** — NORMATIVE, line 85: Assessors shall not infer preservation from fluency or confidence.
- **MS-T1-RULE-0056** — OPERATIONAL, line 91: 1. preserve both original assessments;
- **MS-T1-RULE-0057** — DISPOSITION, line 92: 2. identify the disputed property;
- **MS-T1-RULE-0058** — OPERATIONAL, line 96: 6. retain the disagreement history.
- **MS-T1-RULE-0059** — MEASUREMENT, line 100: Calculate by condition:
- **MS-T1-RULE-0060** — OPERATIONAL, line 105: - non-compensable failures;
- **MS-T1-RULE-0061** — MEASUREMENT, line 106: - semantic divergence rate;
- **MS-T1-RULE-0062** — OPERATIONAL, line 110: - traceability failure rate;
- **MS-T1-RULE-0063** — NORMATIVE, line 117: - all required responses are recorded;
- **MS-T1-RULE-0064** — OPERATIONAL, line 118: - all assessments are complete;
- **MS-T1-RULE-0065** — REPRODUCIBILITY, line 121: - analysis is reproducible;
- **MS-T1-RULE-0066** — EVIDENCE, line 124: - raw evidence remains preserved.

#### SCORING_MODEL.md

- **MS-T1-RULE-0067** — OPERATIONAL, line 15: \bot, & INSUFFICIENT\_EVIDENCE \\
- **MS-T1-RULE-0068** — DISPOSITION, line 16: \delta, & DISPUTED
- **MS-T1-RULE-0069** — NORMATIVE, line 32: Insufficient and disputed assessments shall be reported separately and shall not be silently included as preserved.
- **MS-T1-RULE-0070** — MEASUREMENT, line 63: - material divergence rate;
- **MS-T1-RULE-0071** — OPERATIONAL, line 64: - non-compensable failure rate;
- **MS-T1-RULE-0072** — EVIDENCE, line 65: - insufficient-evidence rate;
- **MS-T1-RULE-0073** — DISPOSITION, line 66: - disputed-assessment rate;
- **MS-T1-RULE-0074** — EVIDENCE, line 67: - observer completion rate;
- **MS-T1-RULE-0075** — MEASUREMENT, line 68: - assessor agreement;
- **MS-T1-RULE-0076** — MEASUREMENT, line 75: No aggregate score may conceal a divergent non-compensable property.

#### DATA_DICTIONARY.md

- **MS-T1-RULE-0077** — EVIDENCE, line 11: \| GovernedObjectID \| Canonical identifier of the object under assessment. \|
- **MS-T1-RULE-0078** — EVIDENCE, line 26: \| ObserverID \| Registered observer identifier. \|
- **MS-T1-RULE-0079** — EVIDENCE, line 29: \| ObserverClass \| Declared observer class. \|
- **MS-T1-RULE-0080** — EVIDENCE, line 32: \| ResponseText \| Observer reconstruction. \|
- **MS-T1-RULE-0081** — EVIDENCE, line 33: \| SourceReferences \| Sources cited by the observer. \|
- **MS-T1-RULE-0082** — EVIDENCE, line 34: \| DeclaredUncertainty \| Uncertainty explicitly retained by the observer. \|
- **MS-T1-RULE-0083** — EVIDENCE, line 41: \| AssessmentID \| Stable assessment identifier. \|
- **MS-T1-RULE-0084** — DISPOSITION, line 47: \| AssessmentResult \| PRESERVED, DIVERGENT, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. \|
- **MS-T1-RULE-0085** — EVIDENCE, line 49: \| EvidenceReference \| Evidence supporting the judgment. \|
- **MS-T1-RULE-0086** — EVIDENCE, line 50: \| Rationale \| Assessment rationale. \|
- **MS-T1-RULE-0087** — OPERATIONAL, line 51: \| AdjudicationStatus \| NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. \|
- **MS-T1-RULE-0088** — EVIDENCE, line 52: \| FinalResult \| Final preserved assessment result. \|

#### REPRODUCIBILITY.md

- **MS-T1-RULE-0089** — NORMATIVE, line 6: A reproduction package shall include:
- **MS-T1-RULE-0090** — EVIDENCE, line 17: 10. de-identified observer responses where permissible;
- **MS-T1-RULE-0091** — OPERATIONAL, line 18: 11. semantic assessments;
- **MS-T1-RULE-0092** — REPRODUCIBILITY, line 24: A result is reproducible only when an independent evaluator can reconstruct the reported measurements from preserved evidence.

#### LIMITATIONS.md

- **MS-T1-RULE-0093** — NORMATIVE, line 6: The trial shall evaluate and report:
- **MS-T1-RULE-0094** — EVIDENCE, line 8: - observer-selection effects;
- **MS-T1-RULE-0095** — NORMATIVE, line 21: Limitations shall not be used to erase admissible results, but they shall constrain the scope of any theorem disposition.

## MS-T2

### CSV Schemas

#### DEPENDENCY_CHAINS.csv

| Position | Column |
|---:|---|
| 1 | ChainID |
| 2 | ChainName |
| 3 | GoverningVersion |
| 4 | RootObjectID |
| 5 | TerminalObjectID |
| 6 | DependencyDepth |
| 7 | CorrectionAvailability |
| 8 | CanonicalSource |
| 9 | ChainStatus |

**Imported rows:** 1

**Current row completeness:**

- CSV row 2: **INCOMPLETE**; missing: ChainName, GoverningVersion, RootObjectID, TerminalObjectID, DependencyDepth, CorrectionAvailability, CanonicalSource

#### DOWNSTREAM_ASSESSMENTS.csv

| Position | Column |
|---:|---|
| 1 | AssessmentID |
| 2 | CaseID |
| 3 | ObjectID |
| 4 | PropertyClass |
| 5 | AssessorID |
| 6 | AssessmentResult |
| 7 | Materiality |
| 8 | Compensability |
| 9 | EvidenceReference |
| 10 | Rationale |
| 11 | FinalResult |
| 12 | AdjudicationStatus |

**Imported rows:** 1

**Current row completeness:**

- CSV row 2: **INCOMPLETE**; missing: AssessmentID, CaseID, ObjectID, PropertyClass, AssessorID, AssessmentResult, Materiality, Compensability, EvidenceReference, Rationale, FinalResult, AdjudicationStatus

#### PROPAGATION_EVENTS.csv

| Position | Column |
|---:|---|
| 1 | EventID |
| 2 | CaseID |
| 3 | SourceObjectID |
| 4 | TargetObjectID |
| 5 | DependencyEdgeID |
| 6 | PropertyClass |
| 7 | PropagationLevel |
| 8 | EventClass |
| 9 | EvidenceReference |
| 10 | DetectedAt |
| 11 | DetectionMethod |
| 12 | EventStatus |

**Imported rows:** 1

**Current row completeness:**

- CSV row 2: **INCOMPLETE**; missing: EventID, CaseID, SourceObjectID, TargetObjectID, DependencyEdgeID, PropertyClass, PropagationLevel, EventClass, EvidenceReference, DetectedAt, DetectionMethod, EventStatus

#### TRIAL_CASES.csv

| Position | Column |
|---:|---|
| 1 | CaseID |
| 2 | ChainID |
| 3 | Condition |
| 4 | SeedObjectID |
| 5 | DivergenceClass |
| 6 | OriginalValue |
| 7 | SeededValue |
| 8 | SeedPropertyClass |
| 9 | CorrectionEnabled |
| 10 | CaseStatus |

**Imported rows:** 2

**Current row completeness:**

- CSV row 2: **INCOMPLETE**; missing: SeedObjectID, OriginalValue, SeededValue, SeedPropertyClass, CorrectionEnabled
- CSV row 3: **INCOMPLETE**; missing: SeedObjectID, DivergenceClass, OriginalValue, SeededValue, SeedPropertyClass, CorrectionEnabled

### Operational Rules

#### DESIGN.md

- **MS-T2-RULE-0001** — MEASUREMENT, line 11: This trial evaluates whether material semantic divergence introduced into an upstream governed object creates measurable downstream semantic-integrity risk in dependent objects.
- **MS-T2-RULE-0002** — MEASUREMENT, line 35: unless an independent correction, validation, or reconstruction mechanism interrupts propagation.
- **MS-T2-RULE-0003** — MEASUREMENT, line 39: Dependency chains containing seeded upstream material divergence will demonstrate a higher rate of downstream semantic divergence than equivalent chains using canonical upstream representations.
- **MS-T2-RULE-0004** — MEASUREMENT, line 43: Seeded upstream material divergence will produce no measurable increase in downstream semantic divergence.
- **MS-T2-RULE-0005** — MEASUREMENT, line 62: The dependency chain receives an upstream representation containing one controlled material divergence.
- **MS-T2-RULE-0006** — MEASUREMENT, line 64: Permitted seeded divergence classes include:
- **MS-T2-RULE-0007** — OPERATIONAL, line 80: DivergenceClass,
- **MS-T2-RULE-0008** — OPERATIONAL, line 82: CorrectionAvailability)
- **MS-T2-RULE-0009** — OPERATIONAL, line 88: - `DivergenceClass` identifies the seeded material change;
- **MS-T2-RULE-0010** — OPERATIONAL, line 90: - `CorrectionAvailability` identifies whether an interruption mechanism exists.
- **MS-T2-RULE-0011** — MEASUREMENT, line 96: - downstream material divergence rate;
- **MS-T2-RULE-0012** — MEASUREMENT, line 97: - propagation depth;
- **MS-T2-RULE-0013** — MEASUREMENT, line 100: - time to propagation detection;
- **MS-T2-RULE-0014** — MEASUREMENT, line 101: - correction success rate;
- **MS-T2-RULE-0015** — MEASUREMENT, line 102: - residual divergence after correction;
- **MS-T2-RULE-0016** — EVIDENCE, line 104: - observer reconstruction failure;
- **MS-T2-RULE-0017** — MEASUREMENT, line 105: - authority-error propagation.
- **MS-T2-RULE-0018** — NORMATIVE, line 109: The following shall remain equivalent across paired cases:
- **MS-T2-RULE-0019** — EVIDENCE, line 114: - observer or evaluator access;
- **MS-T2-RULE-0020** — EVIDENCE, line 116: - assessment criteria;
- **MS-T2-RULE-0021** — NORMATIVE, line 135: Each edge shall declare:
- **MS-T2-RULE-0022** — NORMATIVE, line 139: - required inherited properties;
- **MS-T2-RULE-0023** — MEASUREMENT, line 142: - correction mechanism;
- **MS-T2-RULE-0024** — MEASUREMENT, line 147: A propagation event exists when a material divergence present in an upstream representation appears in or materially affects a downstream object.
- **MS-T2-RULE-0025** — MEASUREMENT, line 153: when divergence in property \(p\) at \(g_i\) causes divergence or invalid action at \(g_j\).
- **MS-T2-RULE-0026** — OPERATIONAL, line 160: DownstreamDivergenceRate =
- **MS-T2-RULE-0027** — MEASUREMENT, line 171: Define propagation risk:
- **MS-T2-RULE-0028** — MEASUREMENT, line 178: and propagation depth:
- **MS-T2-RULE-0029** — MEASUREMENT, line 185: A divergence may propagate broadly, deeply, both, or neither.
- **MS-T2-RULE-0030** — MEASUREMENT, line 191: 1. divergent upstream conditions produce a reproducibly higher downstream divergence rate;
- **MS-T2-RULE-0031** — MEASUREMENT, line 194: 4. the propagation path remains traceable;
- **MS-T2-RULE-0032** — MEASUREMENT, line 195: 5. no uncontrolled source better explains the divergence.
- **MS-T2-RULE-0033** — DISPOSITION, line 199: MS-T2 is falsified for the tested dependency class when:
- **MS-T2-RULE-0034** — MEASUREMENT, line 201: - seeded upstream divergence produces no measurable downstream effect;
- **MS-T2-RULE-0035** — REPRODUCIBILITY, line 203: - the finding is reproduced across the declared case set;
- **MS-T2-RULE-0036** — DISPOSITION, line 208: The result remains inconclusive when:
- **MS-T2-RULE-0037** — MEASUREMENT, line 211: - seeded divergence is not materially valid;
- **MS-T2-RULE-0038** — MEASUREMENT, line 213: - propagation cannot be distinguished from independent observer error;
- **MS-T2-RULE-0039** — EVIDENCE, line 214: - evidence is incomplete;
- **MS-T2-RULE-0040** — MEASUREMENT, line 216: - correction mechanisms are uncontrolled.
- **MS-T2-RULE-0041** — MEASUREMENT, line 220: Propagation may be interrupted by:
- **MS-T2-RULE-0042** — EVIDENCE, line 225: - semantic convergence assessment;
- **MS-T2-RULE-0043** — MEASUREMENT, line 228: - explicit correction;
- **MS-T2-RULE-0044** — MEASUREMENT, line 231: The existence of interruption does not negate dependency propagation risk.
- **MS-T2-RULE-0045** — NORMATIVE, line 235: The following downstream failures shall remain independently visible:
- **MS-T2-RULE-0046** — OPERATIONAL, line 238: - boundary failure;
- **MS-T2-RULE-0047** — OPERATIONAL, line 243: - traceability failure.
- **MS-T2-RULE-0048** — MEASUREMENT, line 247: This trial evaluates semantic propagation through declared dependency structures.
- **MS-T2-RULE-0049** — NORMATIVE, line 251: - every upstream error must propagate;
- **MS-T2-RULE-0050** — MEASUREMENT, line 254: - correction is always possible;
- **MS-T2-RULE-0051** — NORMATIVE, line 259: 1. Every dependency edge shall be declared.
- **MS-T2-RULE-0052** — NORMATIVE, line 260: 2. Every seeded divergence shall be intentional and traceable.
- **MS-T2-RULE-0053** — NORMATIVE, line 261: 3. Canonical and divergent cases shall otherwise remain equivalent.
- **MS-T2-RULE-0054** — NORMATIVE, line 262: 4. Downstream divergence shall be assessed property by property.
- **MS-T2-RULE-0055** — NORMATIVE, line 263: 5. Independent observer error shall remain distinguishable from propagated error.
- **MS-T2-RULE-0056** — NORMATIVE, line 264: 6. Correction mechanisms shall be declared before execution.
- **MS-T2-RULE-0057** — NORMATIVE, line 265: 7. Missing evidence shall remain missing.
- **MS-T2-RULE-0058** — NORMATIVE, line 266: 8. Non-compensable failures shall not be averaged away.
- **MS-T2-RULE-0059** — NORMATIVE, line 267: 9. Propagation depth and breadth shall be reported separately.
- **MS-T2-RULE-0060** — NORMATIVE, line 268: 10. The result shall not exceed the tested dependency class.

#### PROCEDURE.md

- **MS-T2-RULE-0061** — NORMATIVE, line 13: 5. define required inherited properties.
- **MS-T2-RULE-0062** — MEASUREMENT, line 14: 6. select one divergence class per controlled test case.
- **MS-T2-RULE-0063** — MEASUREMENT, line 17: 9. register correction mechanisms.
- **MS-T2-RULE-0064** — MEASUREMENT, line 32: 9. record correction availability.
- **MS-T2-RULE-0065** — MEASUREMENT, line 43: 6. record the divergence class;
- **MS-T2-RULE-0066** — EVIDENCE, line 51: 1. provide the upstream representation to the downstream process or observer;
- **MS-T2-RULE-0067** — MEASUREMENT, line 55: 5. prevent undeclared correction;
- **MS-T2-RULE-0068** — NORMATIVE, line 61: Each downstream object shall be evaluated for:
- **MS-T2-RULE-0069** — EVIDENCE, line 72: Assessment values are:
- **MS-T2-RULE-0070** — OPERATIONAL, line 75: - PROPAGATED_DIVERGENCE;
- **MS-T2-RULE-0071** — OPERATIONAL, line 76: - INDEPENDENT_DIVERGENCE;
- **MS-T2-RULE-0072** — OPERATIONAL, line 78: - INSUFFICIENT_EVIDENCE;
- **MS-T2-RULE-0073** — DISPOSITION, line 79: - DISPUTED;
- **MS-T2-RULE-0074** — NORMATIVE, line 84: A divergence shall be classified as propagated only when:
- **MS-T2-RULE-0075** — MEASUREMENT, line 86: 1. the upstream divergence is verified;
- **MS-T2-RULE-0076** — MEASUREMENT, line 89: 4. the downstream divergence corresponds to the upstream divergence;
- **MS-T2-RULE-0077** — MEASUREMENT, line 94: Where a correction mechanism exists:
- **MS-T2-RULE-0078** — MEASUREMENT, line 97: 2. identify correction authority;
- **MS-T2-RULE-0079** — MEASUREMENT, line 98: 3. apply the declared correction;
- **MS-T2-RULE-0080** — MEASUREMENT, line 99: 4. preserve pre-correction output;
- **MS-T2-RULE-0081** — MEASUREMENT, line 100: 5. preserve post-correction output;
- **MS-T2-RULE-0082** — MEASUREMENT, line 101: 6. assess residual divergence;
- **MS-T2-RULE-0083** — MEASUREMENT, line 102: 7. record correction success or failure.
- **MS-T2-RULE-0084** — MEASUREMENT, line 106: Calculate by condition and divergence class:
- **MS-T2-RULE-0085** — MEASUREMENT, line 108: - downstream divergence rate;
- **MS-T2-RULE-0086** — MEASUREMENT, line 109: - propagation-event count;
- **MS-T2-RULE-0087** — MEASUREMENT, line 110: - propagation breadth;
- **MS-T2-RULE-0088** — MEASUREMENT, line 111: - propagation depth;
- **MS-T2-RULE-0089** — MEASUREMENT, line 112: - correction detection rate;
- **MS-T2-RULE-0090** — MEASUREMENT, line 113: - correction success rate;
- **MS-T2-RULE-0091** — MEASUREMENT, line 114: - residual divergence rate;
- **MS-T2-RULE-0092** — MEASUREMENT, line 115: - independent divergence rate;
- **MS-T2-RULE-0093** — DISPOSITION, line 116: - disputed classification rate.
- **MS-T2-RULE-0094** — OPERATIONAL, line 123: - all seeded divergences are verified;
- **MS-T2-RULE-0095** — OPERATIONAL, line 126: - all downstream assessments are complete;
- **MS-T2-RULE-0096** — MEASUREMENT, line 127: - propagation classifications are traceable;
- **MS-T2-RULE-0097** — MEASUREMENT, line 128: - correction outcomes are recorded;

#### SCORING_MODEL.md

- **MS-T2-RULE-0098** — MEASUREMENT, line 15: - \(P_D\) is propagated material divergence;
- **MS-T2-RULE-0099** — MEASUREMENT, line 16: - \(I_D\) is independent material divergence;
- **MS-T2-RULE-0100** — NORMATIVE, line 19: For theorem-specific analysis, propagated and independent divergence shall also be reported separately.
- **MS-T2-RULE-0101** — OPERATIONAL, line 46: \frac{CorrectedEvents}{CorrectionAttempts}
- **MS-T2-RULE-0102** — OPERATIONAL, line 53: \frac{ResidualDivergences}{CorrectedEvents}
- **MS-T2-RULE-0103** — MEASUREMENT, line 65: A positive value indicates greater propagation under the divergent condition.
- **MS-T2-RULE-0104** — MEASUREMENT, line 71: - canonical-condition divergence;
- **MS-T2-RULE-0105** — MEASUREMENT, line 72: - divergent-condition divergence;
- **MS-T2-RULE-0106** — MEASUREMENT, line 73: - propagated divergence;
- **MS-T2-RULE-0107** — MEASUREMENT, line 74: - independent divergence;
- **MS-T2-RULE-0108** — MEASUREMENT, line 75: - propagation breadth;
- **MS-T2-RULE-0109** — MEASUREMENT, line 76: - propagation depth;
- **MS-T2-RULE-0110** — MEASUREMENT, line 77: - correction attempts;
- **MS-T2-RULE-0111** — MEASUREMENT, line 78: - correction success;
- **MS-T2-RULE-0112** — MEASUREMENT, line 79: - residual divergence;
- **MS-T2-RULE-0113** — EVIDENCE, line 80: - insufficient-evidence rate;
- **MS-T2-RULE-0114** — DISPOSITION, line 81: - disputed-classification rate;
- **MS-T2-RULE-0115** — OPERATIONAL, line 82: - non-compensable failures.
- **MS-T2-RULE-0116** — NORMATIVE, line 86: An aggregate score shall not conceal:
- **MS-T2-RULE-0117** — OPERATIONAL, line 93: - traceability failure.

#### DATA_DICTIONARY.md

- **MS-T2-RULE-0118** — OPERATIONAL, line 16: \| CorrectionAvailability \| NONE, VALIDATION, RECONSTRUCTION, or GOVERNED_CORRECTION. \|
- **MS-T2-RULE-0119** — MEASUREMENT, line 28: \| DivergenceClass \| Controlled material divergence class. \|
- **MS-T2-RULE-0120** — OPERATIONAL, line 32: \| CorrectionEnabled \| YES or NO. \|
- **MS-T2-RULE-0121** — MEASUREMENT, line 39: \| EventID \| Stable propagation-event identifier. \|
- **MS-T2-RULE-0122** — MEASUREMENT, line 41: \| SourceObjectID \| Object where divergence originated. \|
- **MS-T2-RULE-0123** — MEASUREMENT, line 43: \| DependencyEdgeID \| Edge through which propagation occurred. \|
- **MS-T2-RULE-0124** — OPERATIONAL, line 45: \| PropagationLevel \| Downstream depth at which effect appeared. \|
- **MS-T2-RULE-0125** — EVIDENCE, line 47: \| EvidenceReference \| Evidence supporting classification. \|
- **MS-T2-RULE-0126** — DISPOSITION, line 50: \| EventStatus \| OPEN, VERIFIED, DISPUTED, INVALID, or CLOSED. \|
- **MS-T2-RULE-0127** — EVIDENCE, line 56: \| AssessmentID \| Stable assessment identifier. \|
- **MS-T2-RULE-0128** — EVIDENCE, line 59: \| PropertyClass \| Material property under assessment. \|
- **MS-T2-RULE-0129** — DISPOSITION, line 61: \| AssessmentResult \| PRESERVED, PROPAGATED_DIVERGENCE, INDEPENDENT_DIVERGENCE, CORRECTED, INSUFFICIENT_EVIDENCE, DISPUTED, or NOT_APPLICABLE. \|
- **MS-T2-RULE-0130** — EVIDENCE, line 64: \| EvidenceReference \| Evidence supporting the judgment. \|
- **MS-T2-RULE-0131** — EVIDENCE, line 65: \| Rationale \| Assessment rationale. \|
- **MS-T2-RULE-0132** — OPERATIONAL, line 67: \| AdjudicationStatus \| NOT_REQUIRED, OPEN, RESOLVED, or UNRESOLVED. \|

#### REPRODUCIBILITY.md

- **MS-T2-RULE-0133** — NORMATIVE, line 6: A reproduction package shall include:
- **MS-T2-RULE-0134** — MEASUREMENT, line 19: 12. correction mechanisms;
- **MS-T2-RULE-0135** — MEASUREMENT, line 21: 14. propagation events;
- **MS-T2-RULE-0136** — OPERATIONAL, line 22: 15. downstream assessments;
- **MS-T2-RULE-0137** — MEASUREMENT, line 28: A result is reproducible only when an independent evaluator can reconstruct each propagation classification from preserved evidence.

#### LIMITATIONS.md

- **MS-T2-RULE-0138** — NORMATIVE, line 6: The trial shall evaluate and report:
- **MS-T2-RULE-0139** — MEASUREMENT, line 9: - artificial divergence seeding;
- **MS-T2-RULE-0140** — EVIDENCE, line 11: - observer-specific error;
- **MS-T2-RULE-0141** — MEASUREMENT, line 13: - correction-mechanism effects;
- **MS-T2-RULE-0142** — MEASUREMENT, line 18: - multiple-cause propagation;
- **MS-T2-RULE-0143** — NORMATIVE, line 21: A failure to propagate in one dependency class shall not be generalized to all dependency structures.

## Register Summary

| Theorem | Record Type | Classification | Count |
|---|---|---|---:|
| MS-T1 | CSV_SCHEMA | SCHEMA_COLUMN | 33 |
| MS-T1 | EXECUTION_RULE | DISPOSITION | 7 |
| MS-T1 | EXECUTION_RULE | EVIDENCE | 31 |
| MS-T1 | EXECUTION_RULE | MEASUREMENT | 11 |
| MS-T1 | EXECUTION_RULE | NORMATIVE | 23 |
| MS-T1 | EXECUTION_RULE | OPERATIONAL | 17 |
| MS-T1 | EXECUTION_RULE | REPRODUCIBILITY | 6 |
| MS-T2 | CSV_SCHEMA | SCHEMA_COLUMN | 43 |
| MS-T2 | EXECUTION_RULE | DISPOSITION | 7 |
| MS-T2 | EXECUTION_RULE | EVIDENCE | 14 |
| MS-T2 | EXECUTION_RULE | MEASUREMENT | 77 |
| MS-T2 | EXECUTION_RULE | NORMATIVE | 23 |
| MS-T2 | EXECUTION_RULE | OPERATIONAL | 21 |
| MS-T2 | EXECUTION_RULE | REPRODUCIBILITY | 1 |

## Governance State

The schema and governing rules are now consolidated. Evidence generation remains prohibited until a controlled execution harness implements these fields and rules without replacing missing observations with assumptions.
