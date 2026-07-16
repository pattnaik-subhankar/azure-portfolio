# PaySecure — Interview Readiness Pack

## 1. Why both Application Gateway WAF and APIM?

Application Gateway is the internet-facing regional ingress and WAF enforcement point. APIM is internal and owns API products, JWT/mTLS validation, quotas, transformations, versions, and backend routing. Combining them would blur responsibilities; the extra hop is justified only for a regulated partner API boundary.

## 2. Why internal APIM instead of external mode?

The design allows only the WAF/gateway layer to receive public traffic. Internal APIM removes its public gateway exposure and keeps API policy/backends on private address space. This increases DNS and network complexity, which is addressed with Terraform-managed zones and release tests.

## 3. Explain private endpoint DNS failure symptoms.

A workload may resolve a PaaS FQDN to a public address if the correct private zone is not linked, if a hybrid forwarder is missing, or if a stale record is used. The symptoms often look like firewall, TLS, or application failures. I test resolution from each caller and verify the returned private IP before troubleshooting application code.

## 4. How do you avoid deployment secrets?

Azure DevOps uses workload identity federation to receive short-lived Entra tokens. Terraform state is in a protected Azure Storage backend and access is RBAC-controlled. Workload access uses managed identities. Any remaining partner certificate is held in Key Vault with rotation ownership and audit.

## 5. Deny, Audit, or DeployIfNotExists policy?

Use **Deny** for a mature, non-negotiable control such as public network access after tested exceptions are understood. Use **Audit** to measure and socialize a new rule. Use **DeployIfNotExists** for safe, standard diagnostic settings; it should not silently remediate a control that could disrupt an application.

## 6. What would you challenge before production?

I would request partner TPS and payload profiles, data classification/residency, certificate ownership, supported region/SKU matrix, IP/DNS plan, hybrid connectivity, retention mandates, core-banking dependency behavior, RTO/RPO business impact analysis, and an operating model for 24x7 incidents. Architecture diagrams alone are not a production readiness decision.

## Whiteboard narrative

Start with trust boundaries: partners only reach WAF; APIM and all backends are private. Then draw hub-spoke and DNS. Explain identity, egress, observability, and policy guardrails. Finish with failure modes: DNS, firewall SNAT, WAF false positives, downstream timeouts, and regional recovery.
