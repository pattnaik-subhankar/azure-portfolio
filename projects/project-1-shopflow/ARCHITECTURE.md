# ShopFlow — E-Commerce API Modernization Platform
## Complete Architecture Document (Project 1 of 4)

**Industry:** Retail · **Complexity:** ⭐⭐ Foundation · **IaC:** Bicep · **CI/CD:** Azure DevOps

---

## 1. Business Problem

**FictionalRetail Co.** (mid-size retailer, 120 stores + web) runs order management on a monolithic on-prem .NET app:

- Flash-sale events (festival season) crash the order system — peak traffic is **40x baseline**
- Partners (delivery aggregators, marketplaces) integrate via nightly SFTP file drops — orders lag by hours
- Releases require full-system downtime windows; deployment cadence is ~6 weeks
- No API layer → every new channel (mobile app, marketplace) means custom point-to-point integration

**Goal:** Expose order, inventory, and pricing capabilities as governed APIs; absorb burst traffic without over-provisioning; enable independent, zero-downtime releases.

## 2. Functional Requirements

| ID | Requirement |
|----|-------------|
| FR-1 | Partners and internal channels place orders via REST APIs |
| FR-2 | Inventory availability queryable in near-real-time (<500ms p95) |
| FR-3 | Order intake must never be lost, even if fulfillment systems are down |
| FR-4 | Partner onboarding self-service via API developer portal (docs, keys, quotas) |
| FR-5 | Order-status notifications pushed to partners (webhook + email) |
| FR-6 | Pricing rules updatable by business without code deployment |
| FR-7 | Full audit trail of order lifecycle events |

## 3. Non-Functional Requirements

| Category | Target |
|----------|--------|
| Availability | 99.9% for order intake (measured monthly) |
| Performance | p95 < 500ms reads, < 800ms order submission ACK |
| Scalability | 40x burst (50 → 2,000 orders/min) with no manual intervention |
| Security | No secrets in code; OAuth2 for partners; TLS 1.2+ everywhere |
| Recoverability | RTO 4h, RPO 15min |
| Cost | Burst capacity must not require 24/7 provisioned peak capacity |
| Operability | Single pane of glass for API + backend health; alerting < 5 min detection |

## 4. Complete Azure Architecture

**Pattern: API façade + queue-based load leveling + event-driven fulfillment.**

```
                        ┌─────────────────────────────────────────────┐
  Partners / Web /      │                AZURE (Prod region:          │
  Mobile channels       │                Central India / South India DR)│
        │               │                                             │
        ▼               │                                             │
 ┌──────────────┐       │  ┌──────────────────────────────────────┐   │
 │ Azure Front  │──────▶│  │ API Management (Standard v2)          │   │
 │ Door (WAF)   │       │  │  · Products: Partner / Internal       │   │
 └──────────────┘       │  │  · Policies: JWT validation, rate     │   │
                        │  │    limit, cache, correlation-id       │   │
                        │  └───────┬──────────────┬───────────────┘   │
                        │          │              │                   │
                        │          ▼              ▼                   │
                        │  ┌──────────────┐  ┌──────────────┐         │
                        │  │ Functions:   │  │ Functions:   │         │
                        │  │ Orders API   │  │ Inventory /  │         │
                        │  │ (Premium EP1)│  │ Pricing API  │         │
                        │  └──────┬───────┘  └──────┬───────┘         │
                        │         │ enqueue         │ read            │
                        │         ▼                 ▼                 │
                        │  ┌──────────────┐  ┌──────────────┐         │
                        │  │ Service Bus  │  │ Azure SQL    │         │
                        │  │ (Standard)   │  │ (GP, zone-   │         │
                        │  │ q: orders-in │  │  redundant,  │         │
                        │  │ t: order-    │  │  failover    │         │
                        │  │    events    │  │  group)      │         │
                        │  └──────┬───────┘  └──────────────┘         │
                        │         │ trigger                           │
                        │         ▼                                   │
                        │  ┌──────────────┐  ┌──────────────┐         │
                        │  │ Functions:   │─▶│ Logic Apps   │         │
                        │  │ Fulfillment  │  │ (Standard):  │         │
                        │  │ processor    │  │ notify       │         │
                        │  └──────┬───────┘  │ partners /   │         │
                        │         │          │ email        │         │
                        │         ▼          └──────────────┘         │
                        │  ┌──────────────┐  ┌──────────────┐         │
                        │  │ Blob Storage │  │ Key Vault    │         │
                        │  │ (audit,      │  │ (secrets,    │         │
                        │  │  immutable)  │  │  conn refs)  │         │
                        │  └──────────────┘  └──────────────┘         │
                        │                                             │
                        │  App Insights ◀── all components ──▶ Log    │
                        │                    Analytics Workspace       │
                        └─────────────────────────────────────────────┘
```

### Architecture diagram (text description for draw.io/Mermaid rendering)
1. **Edge:** Azure Front Door Standard with WAF policy → single entry, TLS termination, global anycast.
2. **API layer:** APIM Standard v2. Two products (Partner, Internal). Policies: `validate-jwt` (Entra ID), `rate-limit-by-key` (per subscription), `cache-lookup` on inventory GETs, `set-header` correlation-id injection.
3. **Compute:** Two Function Apps (Premium EP1, VNet-integrated): `orders-api` (HTTP trigger → validates → enqueues to Service Bus → returns 202 + order id), `catalog-api` (inventory/pricing reads from SQL with output caching).
4. **Messaging:** Service Bus Standard. Queue `orders-inbound` (load leveling), topic `order-events` with subscriptions per consumer (fulfillment, notifications, audit).
5. **Processing:** `fulfillment-processor` Function (Service Bus trigger, batched) writes to SQL, emits status events to topic.
6. **Orchestration:** Logic App Standard subscribes to `order-events` → partner webhooks (with retry policy) + Office 365/SendGrid email connector.
7. **Data:** Azure SQL GP zone-redundant + auto-failover group to paired region. Blob Storage with immutability policy for order audit trail.
8. **Cross-cutting:** Key Vault (Key Vault references in app settings), App Insights + Log Analytics, all identities are managed identities.

## 5. Azure Services & Why

| Service | Why (vs alternatives) |
|---------|----------------------|
| APIM Standard v2 | Developer portal for FR-4; policy engine for auth/quota/cache. Consumption tier lacks dev portal; Premium unjustified at this scale |
| Functions Premium EP1 | Burst scale (FR: 40x) without cold-start SLA risk of Consumption; VNet integration; cheaper than idle App Service capacity |
| Service Bus Standard | FR-3 durability + load leveling; topics enable fan-out. Storage Queues lack topics/sessions/dead-lettering depth; Event Hubs is streaming, wrong fit for discrete orders |
| Logic Apps Standard | Business-editable workflows (FR-6 notification rules), 400+ connectors, VNet support vs Consumption |
| Azure SQL GP zone-redundant | Relational fit for orders/inventory; ZR gives in-region HA; failover group = DR story |
| Front Door + WAF | Global entry, OWASP protection, caching static catalog responses |
| Key Vault | Zero secrets in code/config; Key Vault references |
| App Insights + Log Analytics | Distributed tracing across APIM→Functions→SB→SQL via correlation id |

## 6. Security Architecture

- **North-south:** Front Door WAF (OWASP CRS) → APIM (JWT validation with Entra ID; per-partner subscription keys as second factor; rate limits per product).
- **Identity:** All service-to-service auth via **system-assigned managed identities** (Functions→SQL uses Entra auth, Functions→Service Bus uses Azure RBAC data-plane roles, Functions→Key Vault via KV references). Zero connection-string passwords.
- **Secrets:** Key Vault, RBAC authorization model (not access policies), soft-delete + purge protection.
- **Data:** TLS 1.2 min everywhere; SQL TDE (service-managed keys — CMK deferred to Project 3 deliberately); Blob immutability (WORM) for audit container.
- **Least privilege:** Custom RBAC assignments scoped at resource level; pipeline identity limited to resource group Contributor + explicit data-plane roles.

## 7. Networking Design

- Function Apps: **regional VNet integration** → subnet with service endpoints to SQL/Storage/Service Bus + `Microsoft.Web` delegation.
- SQL/Storage/Service Bus: firewall = deny public, allow VNet subnet (service endpoints).
- APIM Standard v2 with VNet integration for backend calls; front stays public behind Front Door (access restricted to Front Door via `X-Azure-FDID` check + APIM policy).
- **Deliberate scope decision:** service endpoints, not private endpoints — documented trade-off; Project 2 upgrades to full private-endpoint zero-trust. This progression is itself an interview talking point.

## 8. Identity Management

- **Partner apps:** Entra ID app registrations, client-credentials flow, roles claim → APIM `validate-jwt` policy checks audience + role.
- **Internal channels:** same tenant, separate app registrations per channel.
- **Workload identities:** managed identities everywhere; pipeline uses **workload identity federation (OIDC)** — no SP secrets.
- **Humans:** RBAC via Entra groups (readers for support, contributors for engineers); JIT elevation documented as PIM pattern.

## 9. Infrastructure as Code (Bicep)

Modular Bicep with `main.bicep` orchestrator + modules; parameter files per environment; `what-if` gate in pipeline. See `/infra` in repo structure below and skeleton files in this folder.

## 10. CI/CD (Azure DevOps)

Multi-stage YAML (see `azure-pipelines.yml`):
1. **Build:** lint Bicep (`az bicep build`), run PSRule for Azure (WAF checks), build/test Function code (dotnet)
2. **Dev deploy:** `what-if` → deploy infra → deploy code → smoke tests (Postman/newman collection)
3. **Prod deploy:** manual approval gate + `what-if` diff posted to run summary → deploy → health-check gate → auto-rollback on failed health probe (redeploy previous artifact)

Branching: trunk-based; `feature/*` → PR (build + PSRule + review) → `main` → auto dev, approved prod.

## 11. Monitoring & Logging

- App Insights (workspace-based) with distributed tracing; correlation-id propagated via APIM policy → Functions → Service Bus application property → processor.
- Log Analytics: APIM diagnostics, Function logs, SQL audit, Service Bus metrics.
- **Alerts:** DLQ depth > 0 (5 min), order queue age > 2 min, p95 latency breach, SQL DTU > 80%, failed-request anomaly.
- **Workbook:** order funnel (received → queued → fulfilled → notified) with per-stage latency.
- Availability tests: synthetic order submission every 5 min from 3 regions.

## 12. Cost Optimization

| Decision | Saving |
|----------|--------|
| Functions Premium with min 1 / max 20 instances vs provisioned App Service peak | Pay for burst only when bursting |
| Service Bus Standard (not Premium) | Premium's dedicated capacity unjustified below ~1K msg/s sustained |
| APIM Standard v2 (not Premium) | No multi-region APIM requirement yet |
| SQL GP with right-sized vCores + auto-pause considered (rejected: cold-start risk) | Documented decision |
| Front Door caching for catalog GETs | Offloads ~60% of read traffic from Functions |
| Budgets + alerts at RG level, tagging: `costCenter`, `env`, `owner` | Governance hygiene |

**Estimated monthly (prod):** ~$650–900 (APIM ~$250, Functions EP1 ~$160+burst, SQL GP 2vCore ZR ~$300, SB/Storage/misc ~$60). Dev env ~$150 using Consumption tiers.

## 13. High Availability

- Zone-redundant: SQL (ZR), Service Bus Standard (zone-resilient by platform), Functions across zones (EP plan zone balancing), APIM v2 platform-managed.
- Queue-based decoupling = fulfillment outage does **not** stop order intake (FR-3).
- Health endpoints + Front Door probes.

## 14. Disaster Recovery (RTO 4h / RPO 15m)

- SQL auto-failover group → paired region (RPO ≤ 5s typical, 15m worst-case bound).
- IaC = entire environment redeployable to DR region in <1h (tested via pipeline `deploy-dr` job).
- Service Bus: pending messages are region-local (documented, accepted risk at this tier — mitigation: intake returns 503, clients retry; Premium geo-DR is the Project 3 upgrade).
- Blob audit: RA-GRS.
- **DR runbook** in `/docs/runbooks/dr-failover.md` with decision tree + failback steps.

## 15. Scalability Strategy

- Front Door absorbs/caches read bursts → APIM rate-limit protects backends → Functions scale-out (EP1, max 20) → Service Bus levels write bursts → fulfillment processes at sustainable rate (`maxConcurrentCalls` tuned) → SQL protected from thundering herd.
- Each tier's limit + backpressure behavior documented in `/docs/scalability.md` (this table is a favorite interview artifact).

## 16. Folder / Repository Structure

```
shopflow-azure-platform/
├── README.md                    # Case-study style (see README template)
├── docs/
│   ├── architecture.md          # this document
│   ├── diagrams/                # drawio + exported PNG/SVG
│   ├── adr/                     # Architecture Decision Records (ADR-001..n)
│   ├── runbooks/dr-failover.md
│   └── scalability.md
├── infra/
│   ├── main.bicep
│   ├── main.dev.bicepparam
│   ├── main.prod.bicepparam
│   └── modules/
│       ├── apim.bicep
│       ├── function-app.bicep
│       ├── service-bus.bicep
│       ├── sql.bicep
│       ├── storage.bicep
│       ├── key-vault.bicep
│       ├── front-door.bicep
│       └── monitoring.bicep
├── src/
│   ├── OrdersApi/               # .NET 8 isolated Functions
│   ├── CatalogApi/
│   ├── FulfillmentProcessor/
│   └── ShopFlow.Shared/
├── workflows/                   # Logic App Standard project
├── pipelines/
│   ├── azure-pipelines.yml
│   └── templates/               # reusable stage/job templates
├── tests/
│   ├── unit/
│   └── smoke/postman/
└── .editorconfig / .gitignore / LICENSE
```

## 17. Resume Impact (honest phrasing)

> **ShopFlow — E-Commerce API Platform (Portfolio Project)**
> Designed and implemented an event-decoupled retail API platform on Azure: APIM façade with JWT/rate-limit policies, Service Bus load-leveling absorbing 40x traffic bursts, zero-downtime fulfillment via queue-triggered Functions; 100% Bicep IaC with multi-stage Azure DevOps pipelines (what-if gates, PSRule WAF checks, OIDC federation).

## 18. Architecture Trade-offs (own these in interviews)

| Decision | Alternative | Why this way |
|----------|-------------|--------------|
| Functions vs AKS | AKS microservices | Team size/ops maturity; no container estate to justify cluster ops overhead; Functions = faster time-to-value. "AKS is Project 4 where scale justifies it" |
| Service endpoints vs Private endpoints | Full PE zero-trust | Cost + complexity proportionate to data sensitivity; PE story deliberately staged in Project 2 |
| Service Bus Standard vs Premium | Premium (geo-DR, dedicated) | Cost; message-loss-on-region-loss risk documented + accepted with client-retry mitigation |
| 202-async order intake vs sync 201 | Synchronous write to SQL | Burst survival > immediate consistency; status endpoint + webhooks close the UX gap |
| APIM v2 vs Application Gateway only | App GW + custom auth | Developer portal, product/subscription model, policy engine are the product requirements |

## 19. Future Enhancements

- Private endpoints + hub-spoke (→ becomes Project 2)
- Service Bus Premium with geo-DR alias
- Cosmos DB for catalog reads at global scale
- APIM multi-region + Front Door origin groups
- B2C/Entra External ID for consumer identity
- Canary releases via deployment slots + traffic splitting
