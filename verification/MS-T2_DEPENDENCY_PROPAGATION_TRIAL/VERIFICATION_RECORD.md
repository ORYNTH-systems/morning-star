# MS-T2 Dependency Propagation Verification Record

## Verification Identity

- **Theorem:** MS-T2
- **Trial:** MS-T2 Dependency Propagation
- **Verification Method:** Controlled downstream reconstruction
- **Verification Status:** EMPIRICALLY_SUPPORTED
- **Constitutional Disposition:** SUPPORTED_IN_CONTROLLED_RECONSTRUCTION
- **Execution Timestamp:** 2026-07-23 10:35:49

## Verified Proposition

For the tested governed-object relations, a constitutionally material mutation introduced into an upstream object produced an observable semantic change in the reconstructed downstream dependent object.

## Trial Results

| Trial | Source Object | Dependent Object | Divergence | Propagation | Status |
|---|---|---|---|---|---|
| MS-T2-0001 | GO-0001 | GO-0002 | EXECUTED | OBSERVED | SUPPORTED_IN_CONTROLLED_RECONSTRUCTION |
| MS-T2-0002 | GO-0002 | GO-0005 | EXECUTED | OBSERVED | SUPPORTED_IN_CONTROLLED_RECONSTRUCTION |
| MS-T2-0003 | GO-0003 | GO-0004 | EXECUTED | OBSERVED | SUPPORTED_IN_CONTROLLED_RECONSTRUCTION |
| MS-T2-0004 | GO-0005 | GO-0006 | EXECUTED | OBSERVED | SUPPORTED_IN_CONTROLLED_RECONSTRUCTION |
| MS-T2-0005 | GO-0006 | GO-0007 | EXECUTED | OBSERVED | SUPPORTED_IN_CONTROLLED_RECONSTRUCTION |

## Aggregate Result

- **Total trials:** 5
- **Controlled reconstructions:** 5
- **Observed semantic propagations:** 5
- **Unobserved propagations:** 0

## Scope

Controlled downstream reconstruction using explicit constitutional term substitution

## Limitation

Results demonstrate propagation under the defined reconstruction contracts and do not establish universal propagation across every possible implementation.

## Evidence Artifacts

- OBJECT_REGISTRY.csv
- TRIAL_REGISTER.csv
- MUTATION_REGISTER.csv
- MUTATION_EVIDENCE.csv
- RECONSTRUCTION_CONTRACTS.csv
- DOWNSTREAM_SEMANTIC_EXPOSURE.csv
- INTEGRATED_VERIFICATION_RESULTS.csv
- RECONSTRUCTION_RESULTS.csv
- STRICT_RECONSTRUCTION_RESULTS.csv
- VERIFICATION_SUMMARY.csv
- reconstructed-downstream/

## Constitutional Conclusion

MS-T2 is empirically supported within the declared controlled-reconstruction scope. The evidence demonstrates that constitutionally material upstream divergence can propagate into dependent semantic artifacts when those artifacts are reconstructed under explicit dependency contracts.

This result does not establish universal propagation across all implementations, representations, or execution environments.