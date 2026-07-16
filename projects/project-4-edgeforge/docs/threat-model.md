# EdgeForge Threat Model (portfolio scope)

| Threat | Primary controls | Validation |
|---|---|---|
| Compromised edge identity | certificate lifecycle, revocation, least privilege, outbound-only path | revocation drill and audit review |
| Plant connectivity loss | edge buffering, retention limit, idempotent replay | WAN-loss exercise |
| Public cluster/data exposure | private AKS, private endpoints, deny/audit policy | policy and network tests |
| Supply-chain compromise | scanned/signed images, protected pipeline, workload identity | build provenance and admission checks |
| Telemetry exfiltration | egress controls, data classification, RBAC, diagnostic review | firewall and access review |
| Cost runaway | budgets, KEDA limits, retention/lifecycle policies | anomaly alerts and load test |

OT risk assessment, device-hardening standards, and plant safety controls are mandatory organizational responsibilities outside this Azure portfolio design.
