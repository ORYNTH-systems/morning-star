# Morning Star Constitutional Core Validation

**Validation ID:** MS-VAL-CONSTITUTIONAL-CORE-001  
**Generated:** 2026-07-22T15:53:14-05:00  
**Overall Result:**   

## Artifact Validation


Artifact                                                   Exists Bytes SHA256                                         
--------                                                   ------ ----- ------                                         
constitution/CONSTITUTION.md                                 True 14271 36F3177F4412DA10C217836BD5567FF84076DB929005...
constitution/PURPOSE.md                                      True  1983 55BD7A5E82AF2FE3D42D2EAB120485D716529BBE51B9...
constitution/PHILOSOPHY.md                                   True  2635 E73CE21E25275ECC32C3739B07E9748263E3906977F4...
constitution/README.md                                       True   772 0A0AC807C280D1F0F46E3249198C577AC9CD2DDE7039...
constitution/registries/TERMINOLOGY_REGISTRY.csv             True  3289 40827A735A975064456CD5452DA409C69E139ED395DA...
constitution/registries/ROLE_REGISTRY.csv                    True  1255 FE7DF374C38BB2E1A162E356452E337744795432C9F7...
constitution/registries/STATE_REGISTRY.csv                   True  1986 D5F7CEF137AC2B5A114C06F9616458785E0B90FE5921...
constitution/registries/INVARIANT_REGISTRY.csv               True  1749 75AD4654BAD6C0F3883960586356AB88473D37689F5C...
constitution/registries/AUTHORITY_OWNERSHIP_MAP.csv          True  2308 3899B420FD118ECC78D1AF0C615576D5751466DAEA5F...
constitution/registries/DEPENDENCY_GRAPH.csv                 True  1905 45317B60E01E08D694313AB941AEEE402F3C89DB53DA...
constitution/registries/PROHIBITED_CONFLATION_REGISTER.csv   True  1691 D56829D09BD1597606C9F400A0B834D11C613C2EFABC...
constitution/governance/AMENDMENT_PROCEDURE.md               True  2063 DFB735EBC7C86F14F656004E984987CBDBA68693A5C0...




## Registry Parsing


Registry                           Rows Result
--------                           ---- ------
AUTHORITY_OWNERSHIP_MAP.csv          15 PASS  
DEPENDENCY_GRAPH.csv                 12 PASS  
INVARIANT_REGISTRY.csv               12 PASS  
PROHIBITED_CONFLATION_REGISTER.csv   10 PASS  
ROLE_REGISTRY.csv                     7 PASS  
STATE_REGISTRY.csv                   13 PASS  
TERMINOLOGY_REGISTRY.csv             17 PASS  




## Duplicate Identifier Review


Registry                           Identifier       DuplicateCount Result
--------                           ----------       -------------- ------
TERMINOLOGY_REGISTRY.csv           TermID                        0 PASS  
ROLE_REGISTRY.csv                  RoleID                        0 PASS  
STATE_REGISTRY.csv                 StateID                       0 PASS  
INVARIANT_REGISTRY.csv             InvariantID                   0 PASS  
AUTHORITY_OWNERSHIP_MAP.csv        ResponsibilityID              0 PASS  
DEPENDENCY_GRAPH.csv               DependencyID                  0 PASS  
PROHIBITED_CONFLATION_REGISTER.csv ConflationID                  0 PASS  




## Constitutional Heading Review


Requirement                          Present Result
-----------                          ------- ------
## 1. Constitutional Purpose            True PASS  
## 2. Constitutional Subject            True PASS  
## 3. Constitutional Authority Order    True PASS  
## 4. Governed Domain                   True PASS  
## 5. Constitutional Boundary           True PASS  
## 6. Canonical Objects                 True PASS  
## 7. Participation Roles               True PASS  
## 8. Semantic States                   True PASS  
## 9. Interpretation Classes            True PASS  
## 10. Constitutional Invariants        True PASS  
## 11. Dependency Governance            True PASS  
## 12. Authority and Ownership          True PASS  
## 13. Evidence and Verification        True PASS  
## 14. Drift and Reconstruction         True PASS  
## 15. Framework Admission              True PASS  
## 16. Amendment Governance             True PASS  
## 17. Constitutional Freeze            True PASS  
## 18. Supremacy Clause                 True PASS  
## 19. Constitutional Result            True PASS  



