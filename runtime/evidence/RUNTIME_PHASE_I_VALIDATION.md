# Morning Star Volume V Initiation Validation

**Validation ID:** MS-V5-VAL-001  
**Generated:** 2026-07-22T16:25:43-05:00  
**Overall Result:**   

## Artifact Validation


Artifact                                                                 Exists Bytes SHA256                           
--------                                                                 ------ ----- ------                           
volumes/VOLUME_V_INITIATION/INITIATION.md                                  True 13995 142656A42512DA5FCE6DD9F53D2874...
volumes/VOLUME_V_INITIATION/README.md                                      True   858 9DDA4C33CCBA0258A5663DDC3603E8...
volumes/VOLUME_V_INITIATION/registries/PARTICIPATION_ROLE_REGISTRY.csv     True   617 57AFB325D8F4A3C01427E60203EFF2...
volumes/VOLUME_V_INITIATION/registries/COMPETENCY_DIMENSION_REGISTRY.csv   True  1651 C3B6D1AE1D8AE72CE106AD0BF69661...
volumes/VOLUME_V_INITIATION/registries/ASSESSMENT_CLASS_REGISTRY.csv       True   917 D851456FE29E161DA2BDD855130BD6...
volumes/VOLUME_V_INITIATION/registries/ASSESSMENT_RESULT_REGISTRY.csv      True  1015 F058823B7F57D1554325410EC31CAD...
volumes/VOLUME_V_INITIATION/registries/INITIATION_DECISION_REGISTRY.csv    True  1110 280022E101A8DA1142ECCFD3306D5B...
volumes/VOLUME_V_INITIATION/registries/INITIATION_FAILURE_REGISTRY.csv     True  1486 7EFF0B97E285BB9EB510DF463C33EE...
volumes/VOLUME_V_INITIATION/registries/ROLE_COMPETENCY_MATRIX.csv          True  1176 1D4CD70BDEAB12625B032079C143E0...
volumes/VOLUME_V_INITIATION/schemas/initiation-record.schema.json          True  2612 A546CDE70D3971CBC81E70832F27FF...
volumes/VOLUME_V_INITIATION/schemas/competency-assessment.schema.json      True  1967 5926FB67739B7F6C5A32624E8D20BA...
volumes/VOLUME_V_INITIATION/governance/INITIATION_RULES.md                 True  1959 4BF2C52C883FBAD74270534E5C7E62...
volumes/VOLUME_V_INITIATION/tests/REFERENCE_INITIATION_CASES.csv           True  1522 A18E54E743376F18C11375638D1B4A...




## Registry Validation


Registry                          Rows MinimumRows DuplicateCount Result
--------                          ---- ----------- -------------- ------
PARTICIPATION_ROLE_REGISTRY.csv      7           7              0 PASS  
COMPETENCY_DIMENSION_REGISTRY.csv   15          15              0 PASS  
ASSESSMENT_CLASS_REGISTRY.csv       12          12              0 PASS  
ASSESSMENT_RESULT_REGISTRY.csv       9           9              0 PASS  
INITIATION_DECISION_REGISTRY.csv    11          11              0 PASS  
INITIATION_FAILURE_REGISTRY.csv     12          12              0 PASS  
ROLE_COMPETENCY_MATRIX.csv           7           7              0 PASS  




## Schema Validation


Schema                            Parsed HasSchema HasId HasRequired Result
------                            ------ --------- ----- ----------- ------
initiation-record.schema.json       True      True  True        True PASS  
competency-assessment.schema.json   True      True  True        True PASS  




## Heading Validation


Requirement                            Present Result
-----------                            ------- ------
## 1. Purpose                             True PASS  
## 2. Initiation Authority                True PASS  
## 3. Initiation Subject                  True PASS  
## 4. Initiation Principle                True PASS  
## 5. Actor Identity                      True PASS  
## 6. Participation Roles                 True PASS  
## 7. PR0 — Observer                      True PASS  
## 8. PR1 — Oriented Observer             True PASS  
## 9. PR2 — Informed Participant          True PASS  
## 10. PR3 — Applied Participant          True PASS  
## 11. PR4 — Authorized Contributor       True PASS  
## 12. PR5 — Steward                      True PASS  
## 13. PR6 — Constitutional Maintainer    True PASS  
## 14. Competency Dimensions              True PASS  
## 15. Evidence Requirements              True PASS  
## 16. Assessment Classes                 True PASS  
## 17. Assessment Results                 True PASS  
## 18. Initiation Decisions               True PASS  
## 19. Role Transition                    True PASS  
## 20. Progressive Admission              True PASS  
## 21. Provisional Admission              True PASS  
## 22. Remediation                        True PASS  
## 23. Suspension                         True PASS  
## 24. Revocation                         True PASS  
## 25. Expiration and Renewal             True PASS  
## 26. Participation Scope                True PASS  
## 27. Participation Trace                True PASS  
## 28. Conflict of Interest               True PASS  
## 29. Appeal and Review                  True PASS  
## 30. Initiation Failure                 True PASS  
## 31. Deterministic Initiation           True PASS  
## 32. Prohibited Initiation Behavior     True PASS  
## 33. Canonical Result                   True PASS  




## Reference Initiation Cases


TestFile                       Rows Result
--------                       ---- ------
REFERENCE_INITIATION_CASES.csv   15 PASS  




## Role Competency Matrix Validation


RolesMissingFromMatrix UnexpectedMatrixRoles MissingCompetencyColumns UnexpectedCompetencyColumns Result
---------------------- --------------------- ------------------------ --------------------------- ------
                     0                     0                        0                           0 PASS  



