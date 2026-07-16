# Phase 2 — Enterprise Project Blueprints (Overview)

Four production-grade projects, progressive complexity. Each gets a full deep-dive folder with: architecture doc, IaC skeleton, pipelines, README, diagram spec, interview Q&A, trade-offs, cost model.

**Authenticity rule:** every service used is either (a) on the resume, or (b) a realistic 1-step extension that Subhankar can learn while building and defend in interviews.

---

## Project 1 — ShopFlow (Retail) · E-Commerce API Modernization Platform
**Complexity: ⭐⭐ Foundation — plays 100% to existing strengths**

- **Business problem:** Regional retailer's monolithic order system can't handle flash-sale traffic; partners need API access; releases take weeks.
- **Core architecture:** APIM (developer portal + products/subscriptions) → Azure Functions (order/inventory/pricing APIs) + Logic Apps (order orchestration, partner notifications) → Azure SQL (Elastic Pool) + Blob Storage. **Service Bus** queues/topics decouple order intake from fulfillment (new skill, gentle intro).
- **Key services:** APIM, Functions (Premium), Logic Apps Standard, Service Bus, Azure SQL, Blob, Key Vault, App Insights, Front Door (basic).
- **Security:** APIM subscription keys + Entra ID OAuth2 for partners; managed identities everywhere; Key Vault for secrets.
- **Networking:** VNet integration for Functions, service endpoints → (upgraded to private endpoints in Project 2 — deliberate progression story).
- **IaC:** Bicep modules (resume-native).
- **CI/CD:** Azure DevOps YAML — build/test/what-if/deploy, dev→prod with approvals.
- **HA/DR:** Zone-redundant services, SQL auto-failover group (single region + DR pair).
- **Resume impact:** "Designed and built event-decoupled e-commerce API platform handling burst traffic via Service Bus load-leveling; 100% Bicep + Azure DevOps."
- **Interview themes:** Why Functions vs App Service vs AKS; Service Bus vs Storage Queue; APIM policy design (rate limiting, caching, JWT validation); consumption vs premium plans.

## Project 2 — PaySecure (Finance) · Zero-Trust Open Banking API Platform
**Complexity: ⭐⭐⭐ Security & networking depth — monetizes escalation scars**

- **Business problem:** Mid-size bank must expose open-banking APIs (PSD2-style) with zero public exposure of backends, full auditability, and regulator-ready governance.
- **Core architecture:** Hub-spoke topology. Hub: Azure Firewall Premium, Bastion, shared DNS (Private DNS zones + resolver). Spoke: APIM **internal mode** behind App Gateway WAF v2, Functions + Web Apps with **private endpoints only**, Azure SQL private endpoint, Key Vault (HSM-backed keys), all egress via firewall.
- **Key services:** App Gateway WAF, APIM (internal), Functions, Azure SQL, Key Vault Premium, Azure Firewall Premium, Private DNS, Bastion, Defender for Cloud, Log Analytics + Sentinel (basic detections).
- **Identity:** Entra ID OAuth2 client-credentials + mTLS for partner APIs; PIM concepts documented; managed identities; zero shared secrets.
- **Governance:** Azure Policy initiative (deny public endpoints, require PE, require diagnostics — DINE) — *direct extension of real DINE work*.
- **IaC:** Terraform (modules: network-hub, network-spoke, apim, app, data, security) with remote state + state locking.
- **CI/CD:** Multi-stage with security gates — tfsec/checkov scan, plan approval, OIDC federation (no service principal secrets).
- **HA/DR:** Zone redundancy; documented RTO 4h/RPO 15m with paired-region strategy.
- **Resume impact:** "Designed zero-trust hub-spoke financial API platform: private-endpoint-only backends, APIM internal mode, policy-as-code compliance guardrails, Terraform + OIDC pipelines."
- **Interview themes:** Hub-spoke vs VWAN; App GW + APIM layering; private endpoint DNS (the #1 real-world failure you've actually debugged); firewall SNAT/forced tunneling; policy deny vs DINE vs audit.

## Project 3 — MediSync (Healthcare) · Event-Driven Patient Data Interoperability Hub
**Complexity: ⭐⭐⭐⭐ Data, compliance, DR depth**

- **Business problem:** Hospital group with 12 facilities has siloed patient systems; needs near-real-time HL7/FHIR-style data exchange with audit trail, PHI protection, and provable DR.
- **Core architecture:** Ingestion APIs (APIM + Functions) → **Event Hubs** (high-throughput telemetry/ADT feeds) + Service Bus (ordered clinical workflows, sessions) → processing Functions → **Cosmos DB** (patient event store, multi-region) + Azure SQL (relational reporting) → Logic Apps for downstream notifications. Event Grid for reactive plumbing.
- **Key services:** Event Hubs, Service Bus (sessions/dedup), Cosmos DB, Functions, APIM, Logic Apps, Key Vault (CMK/customer-managed keys), Storage (immutable audit blobs), Azure Monitor + workbooks.
- **Compliance angle:** HIPAA-style controls documented — encryption at rest with CMK, private endpoints, immutable audit logs, RBAC least privilege, data residency. (Documented as compliance-*informed* design, not a certification claim.)
- **DR:** Multi-region: Cosmos multi-region writes vs single-write trade-off documented; Event Hubs geo-DR alias; RTO/RPO matrix per component — this project owns the DR interview conversation.
- **IaC:** Bicep + Terraform mix documented deliberately (when each wins).
- **Resume impact:** "Designed event-driven healthcare interoperability platform processing ordered clinical event streams with multi-region DR (RTO 1h/RPO 5m) and CMK encryption."
- **Interview themes:** Event Hubs vs Service Bus vs Event Grid (the classic); Cosmos consistency levels; idempotency + dedup; partition strategy; PHI data protection layers.

## Project 4 — EdgeForge (Manufacturing) · Global IoT Telemetry Platform on Enterprise Landing Zone
**Complexity: ⭐⭐⭐⭐⭐ Capstone — Solution Architect-level, ties to real Stack Edge/DataBox experience**

- **Business problem:** Global manufacturer (40 plants, 3 continents) needs predictive-maintenance telemetry platform: edge ingestion at plants (constrained/offline-capable), centralized analytics, enterprise governance for 100+ future workloads.
- **Two-layer design (the architect move):**
  1. **Enterprise landing zone (CAF-aligned):** management group hierarchy, subscription vending strategy, Azure Policy initiative library (policy-as-code repo), hub-spoke per region (3 regional hubs), centralized identity/logging/security, cost management + budgets/tags taxonomy.
  2. **Workload:** Edge (IoT Edge / Stack Edge narrative from real experience) → Event Hubs (regional) → **AKS** (stream processors, KEDA autoscaling, workload identity) → ADLS Gen2 (bronze/silver/gold) + Azure SQL → APIM for internal data products → Power BI-ready serving layer.
- **Key services:** Management Groups, Azure Policy, AKS (private cluster), Event Hubs, ADLS Gen2, Functions, APIM, Front Door, Firewall Premium, Log Analytics (regional + central), Grafana/workbooks, Defender for Cloud.
- **HA/DR:** Multi-region active-active ingestion, active-passive analytics; chaos/failure-mode analysis section (drawing on real Sev-A escalation patterns).
- **Cost:** FinOps section — reservations vs savings plans, AKS spot node pools, Event Hubs throughput units vs premium, tiered storage lifecycle.
- **IaC:** Terraform with proper module registry structure + Bicep for policy definitions; environments via workspaces/directories comparison.
- **Resume impact:** "Designed CAF-aligned multi-region landing zone and IoT telemetry workload (AKS + Event Hubs) for global manufacturing scenario; policy-as-code governance for 100+ workload scale-out."
- **Interview themes:** Everything — this is the whiteboard-interview project. Landing zone design, region selection, AKS vs Functions at scale, data lake zoning, WAF pillar-by-pillar review.

---

## Progression logic (tell this story in interviews)
1 → PaaS mastery in public · 2 → zero-trust security depth · 3 → data/eventing + DR · 4 → enterprise-scale governance = the Solution Architect arc.

## Next actions
- [ ] Deep-dive Project 1 (full doc + IaC skeleton + pipeline + README + Q&A)
- [ ] Then 2 → 3 → 4, one at a time, production quality.
