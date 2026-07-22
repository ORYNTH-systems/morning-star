# Morning Star Volume III Navigation Validation

**Validation ID:** MS-V3-VAL-001  
**Generated:** 2026-07-22T16:04:32-05:00  
**Overall Result:**   

## Artifact Validation


Artifact                                                                   Exists Bytes SHA256                         
--------                                                                   ------ ----- ------                         
volumes/VOLUME_III_NAVIGATION/NAVIGATION.md                                  True 11101 18001AD402FD746222C2F2366864...
volumes/VOLUME_III_NAVIGATION/README.md                                      True   816 A6060C785084111E5506B95E9D68...
volumes/VOLUME_III_NAVIGATION/registries/ENTRY_POINT_REGISTRY.csv            True   997 7DBE51E7115B86382572D82B0AD9...
volumes/VOLUME_III_NAVIGATION/registries/NAVIGATION_CLASS_REGISTRY.csv       True  1201 F2191D60C989026D17B94F865204...
volumes/VOLUME_III_NAVIGATION/registries/PREREQUISITE_STATUS_REGISTRY.csv    True   842 26EE0AE3F6AE44B82D6D68E0223D...
volumes/VOLUME_III_NAVIGATION/registries/NAVIGATION_DECISION_REGISTRY.csv    True  1009 7603E900E66C2CDB54BCB5268B7C...
volumes/VOLUME_III_NAVIGATION/registries/PATH_STATUS_REGISTRY.csv            True  1011 9575B148227BCDFAD359C236FA05...
volumes/VOLUME_III_NAVIGATION/registries/NAVIGATION_FAILURE_REGISTRY.csv     True  1284 4BA425C93B1A8CA90E01F9D66F2B...
volumes/VOLUME_III_NAVIGATION/registries/RECOMMENDATION_CLASS_REGISTRY.csv   True   595 F8B5B68A0D5134B96DD003C09782...
volumes/VOLUME_III_NAVIGATION/schemas/navigation-session.schema.json         True  2024 340E3B777BA6A57B869338E3F69B...
volumes/VOLUME_III_NAVIGATION/schemas/navigation-path.schema.json            True  1753 CFC6EA8FA0FA09F0F5137201F10B...
volumes/VOLUME_III_NAVIGATION/governance/NAVIGATION_RULES.md                 True  1901 36D6B14AB4AB64DD3E4BF8636020...
volumes/VOLUME_III_NAVIGATION/tests/REFERENCE_PATHS.csv                      True  1457 5EEA75423F6E1A3FF08BB2FD76CE...




## Registry Validation


Registry                          Rows MinimumRows DuplicateCount Result
--------                          ---- ----------- -------------- ------
ENTRY_POINT_REGISTRY.csv             9           9              0 PASS  
NAVIGATION_CLASS_REGISTRY.csv       12          12              0 PASS  
PREREQUISITE_STATUS_REGISTRY.csv     8           8              0 PASS  
NAVIGATION_DECISION_REGISTRY.csv     9           9              0 PASS  
PATH_STATUS_REGISTRY.csv            11          11              0 PASS  
NAVIGATION_FAILURE_REGISTRY.csv     11          11              0 PASS  
RECOMMENDATION_CLASS_REGISTRY.csv    5           5              0 PASS  




## Schema Validation


Schema                         Parsed HasSchema HasId HasRequired Result
------                         ------ --------- ----- ----------- ------
navigation-session.schema.json   True      True  True        True PASS  
navigation-path.schema.json      True      True  True        True PASS  




## Heading Validation


Requirement                           Present Result
-----------                           ------- ------
## 1. Purpose                            True PASS  
## 2. Navigation Authority               True PASS  
## 3. Navigation Subject                 True PASS  
## 4. Entry Points                       True PASS  
## 5. First-Contact Governance           True PASS  
## 6. Navigation Path                    True PASS  
## 7. Navigation Classes                 True PASS  
## 8. Prerequisite Resolution            True PASS  
## 9. Dependency-Aware Routing           True PASS  
## 10. Observer-State Assessment         True PASS  
## 11. Novice and Expert Navigation      True PASS  
## 12. Blocked Pathways                  True PASS  
## 13. Deferred Pathways                 True PASS  
## 14. Return and Re-entry               True PASS  
## 15. Navigation Trace                  True PASS  
## 16. Navigation Decision               True PASS  
## 17. Recommendation Boundaries         True PASS  
## 18. Framework Discovery Order         True PASS  
## 19. Cross-Framework Navigation        True PASS  
## 20. Revision-Aware Navigation         True PASS  
## 21. Navigation Failure                True PASS  
## 22. Exit Governance                   True PASS  
## 23. Deterministic Navigation          True PASS  
## 24. Prohibited Navigation Behavior    True PASS  
## 25. Canonical Result                  True PASS  




## Reference Path Validation


TestFile            Rows Result
--------            ---- ------
REFERENCE_PATHS.csv   10 PASS  



