# Morning Star Volume II Ontology Validation

**Validation ID:** MS-V2-VAL-001  
**Generated:** 2026-07-22T16:01:03-05:00  
**Overall Result:**   

## Artifact Validation


Artifact                                                                Exists Bytes SHA256                            
--------                                                                ------ ----- ------                            
volumes/VOLUME_II_ONTOLOGY/ONTOLOGY.md                                    True 10114 58A515FD7924791CF631319FCD8E1E0...
volumes/VOLUME_II_ONTOLOGY/README.md                                      True   709 786CBCD2AE48AB6294C17F871239E1C...
volumes/VOLUME_II_ONTOLOGY/registries/OBJECT_CLASS_REGISTRY.csv           True  1903 F8B41370D0489A45ADFC5750E769F94...
volumes/VOLUME_II_ONTOLOGY/registries/RELATIONSHIP_REGISTRY.csv           True  1479 3410754BF46CD97F036557B594C13D0...
volumes/VOLUME_II_ONTOLOGY/registries/OBJECT_STATUS_REGISTRY.csv          True  1149 DEEAD1681AA57CC5B4297324A3391FA...
volumes/VOLUME_II_ONTOLOGY/registries/UNCERTAINTY_REGISTRY.csv            True  1007 39AB8D587B8833C37599B5E33AD563F...
volumes/VOLUME_II_ONTOLOGY/registries/LIFECYCLE_TRANSITION_REGISTRY.csv   True  1016 7A9473BEC8357D8D8EDECD570960024...
volumes/VOLUME_II_ONTOLOGY/schemas/canonical-object.schema.json           True  2089 81D96D4E604226B21CD38EC509BD66B...
volumes/VOLUME_II_ONTOLOGY/schemas/relationship.schema.json               True  1591 D31FB46660DB5E9740E0C2AA8BE5573...
volumes/VOLUME_II_ONTOLOGY/governance/VALIDATION_RULES.md                 True  1904 0F5F6CA4AA414587B16B1FC1B0569AE...




## Registry Validation


Registry                          Rows MinimumRows DuplicateCount Result
--------                          ---- ----------- -------------- ------
OBJECT_CLASS_REGISTRY.csv           24          24              0 PASS  
RELATIONSHIP_REGISTRY.csv           19          19              0 PASS  
OBJECT_STATUS_REGISTRY.csv          11          11              0 PASS  
UNCERTAINTY_REGISTRY.csv             9           9              0 PASS  
LIFECYCLE_TRANSITION_REGISTRY.csv   17          17              0 PASS  




## Schema Validation


Schema                       Parsed HasSchema HasId HasRequired Result
------                       ------ --------- ----- ----------- ------
canonical-object.schema.json   True      True  True        True PASS  
relationship.schema.json       True      True  True        True PASS  




## Ontology Heading Validation


Requirement                               Present Result
-----------                               ------- ------
## 1. Purpose                                True PASS  
## 2. Ontological Authority                  True PASS  
## 3. Canonical Object Principle             True PASS  
## 4. Canonical Object Classes               True PASS  
## 5. Object Identity                        True PASS  
## 6. Object Status                          True PASS  
## 7. Relationship Classes                   True PASS  
## 8. Lifecycle Governance                   True PASS  
## 9. Authority Source                       True PASS  
## 10. Semantic Unit                         True PASS  
## 11. Interpretation Object                 True PASS  
## 12. Uncertainty Object                    True PASS  
## 13. Provenance Object                     True PASS  
## 14. Evidence Object                       True PASS  
## 15. Drift Event                           True PASS  
## 16. Reconstruction Event                  True PASS  
## 17. Revision Object                       True PASS  
## 18. Framework Admission Object            True PASS  
## 19. Verification Result                   True PASS  
## 20. Audit Finding                         True PASS  
## 21. Correction Record                     True PASS  
## 22. Serialization Requirements            True PASS  
## 23. Validation Order                      True PASS  
## 24. Prohibited Ontological Conflations    True PASS  
## 25. Canonical Result                      True PASS  



