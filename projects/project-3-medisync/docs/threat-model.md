# MediSync Threat Model (portfolio scope)

| Threat | Mitigation | Evidence |
|---|---|---|
| PHI exposure in logs | structured allow-listed logging, redaction tests, opaque correlation IDs | pipeline test and Log Analytics query review |
| Duplicate/poison events | idempotency store, retries, DLQ, replay runbook | controlled replay exercise |
| Unauthorised data path | private endpoints, Entra auth, RBAC, APIM policy | denied public-path and access tests |
| Data exfiltration | egress governance, Key Vault, diagnostic auditing | firewall/Key Vault audit review |
| Region outage | tested failover, Event Hubs recovery procedure, Cosmos design | DR exercise evidence |

Formal threat modeling, penetration testing, clinical risk management, and compliance approval are required before real PHI use.
