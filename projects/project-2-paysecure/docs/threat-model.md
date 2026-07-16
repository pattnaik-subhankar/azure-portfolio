# PaySecure Threat Model (portfolio scope)

| Threat | Control | Validation evidence |
|---|---|---|
| Credential theft | Entra OAuth2, mTLS for high-trust APIs, managed identities, Key Vault | token/certificate rotation test and Key Vault audit logs |
| Direct backend exposure | private endpoints, disabled public network access, deny policy | policy compliance and failed public-path test |
| API abuse | WAF, APIM quotas/rate limits, JWT validation | load/abuse test and APIM metrics |
| Data exfiltration | forced egress, Firewall Premium allow lists, diagnostics | firewall logs and approved destination review |
| Privilege escalation | RBAC groups, PIM, least privilege, activity logs | access review and PIM audit |
| DNS manipulation/outage | centrally managed private zones, resolver monitoring, IaC | resolution test from each trust boundary |

This is a design-level threat model. A real bank would perform formal threat modeling, penetration testing, risk acceptance, and control-owner sign-off.
