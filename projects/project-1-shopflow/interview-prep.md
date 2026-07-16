# ShopFlow — Interview Preparation Pack (Project 1)

Practice these aloud. Answers are written the way a Solution Architect should speak: decision → reasoning → trade-off → evidence.

---

## Core Q&A

**Q1. Walk me through the architecture.**
"Order intake is an APIM-fronted Function that validates and enqueues to Service Bus, returning 202 with an order id. That's queue-based load leveling — during flash sales intake scales to 40x while fulfillment drains at a sustainable rate, so a downstream outage never loses an order. Reads (inventory/pricing) go direct to SQL with APIM response caching and Front Door edge caching. Cross-cutting: managed identities everywhere, Bicep IaC, multi-stage DevOps pipelines with what-if gates."

**Q2. Why Azure Functions instead of AKS or App Service?**
"Fit to team and workload. Event-driven, spiky, stateless handlers are the Functions sweet spot — I get scale-out and scale-to-baseline without owning cluster upgrades, node pools, or ingress controllers. App Service would mean paying for peak 24/7. I chose Premium plan specifically for VNet integration and pre-warmed instances to kill cold-start risk on the p95 SLA. If we had 30+ services and a platform team, AKS becomes the right answer — that's exactly what my manufacturing project explores."

**Q3. Why Service Bus and not Storage Queues or Event Hubs?**
"Three requirements picked it: dead-lettering with full DLQ semantics for poison orders, topics for fan-out to fulfillment/notification/audit consumers, and ordered sessions if we later need per-customer ordering. Storage Queues lack topics and rich DLQ. Event Hubs is a streaming log for millions of events — wrong model for discrete business transactions needing per-message completion."

**Q4. How do you guarantee an order is never lost?**
"Durability boundary is Service Bus: intake ACKs only after enqueue succeeds. Processor uses peek-lock — message completes only after SQL commit; on failure it retries then dead-letters. DLQ depth alerts at >0 within 5 minutes. Idempotency: order id is the dedup key, processor upserts, so redelivery is safe."

**Q5. Where does this architecture break at 100x scale?**
"First bottleneck is SQL write throughput — mitigations in order: batching in the processor, then Hyperscale, then splitting hot paths to Cosmos DB. Second is Service Bus Standard throughput — move to Premium messaging units. Third, APIM Standard v2 request limits — scale units or Premium. I documented each tier's limit and backpressure behavior; knowing where it breaks is the point of the design."

**Q6. Security — how do partners authenticate?**
"Two layers: Entra ID client-credentials JWT validated in APIM policy (audience + role claims), plus per-partner subscription keys for quota/rate identity. Service-to-service is all managed identities with RBAC data-plane roles — there isn't a single connection-string password in the system. Secrets that must exist live in Key Vault behind Key Vault references."

**Q7. Why service endpoints instead of private endpoints?**
"Proportionality. Retail catalog/order data at this sensitivity, single region, no regulator — service endpoints with deny-public firewalls give strong network isolation at zero PE cost and no DNS complexity. I know exactly what full private-endpoint zero-trust costs and requires — my finance project implements it — and I can articulate when each is justified. That judgment is the architect's job."

**Q8. Explain your DR posture.**
"RTO 4h, RPO 15m — set with the business, not assumed. SQL auto-failover group gives near-zero RPO for committed data. Whole environment is Bicep, so DR region rebuild is a pipeline run under an hour — tested, not theoretical. Known gap: in-flight Service Bus messages are region-local at Standard tier; documented and accepted — intake returns 503, clients retry, and the upgrade path is Premium geo-DR."

**Q9. How does the pipeline prevent bad deployments?**
"PSRule for Azure runs WAF checks on every PR — misconfigurations fail before merge. Deployment runs what-if and posts the diff for prod approval, so the approver sees exactly what changes. Post-deploy smoke tests hit synthetic order flow; health-gate failure redeploys the previous artifact."

**Q10. What would you do differently with more budget?**
"Service Bus Premium for geo-DR and predictable latency; private endpoints + hub-spoke; APIM multi-region active-active behind Front Door; and a proper consumer identity story with Entra External ID. Each is on the enhancements list with its cost trigger."

## Deep-dive follow-ups to expect

- APIM policy execution order (inbound → backend → outbound → on-error) — be ready to write `validate-jwt` + `rate-limit-by-key` from memory
- Peek-lock vs receive-and-delete; lock duration vs processing time; `maxConcurrentCalls`/prefetch tuning
- Zone-redundant vs geo-redundant — what each protects against
- 202 pattern: how clients get final status (status endpoint + Logic App webhooks)
- Managed identity token flow (IMDS endpoint → Entra token → RBAC check)
- What-if false positives/noise and how you handle them in gates
- Why Bicep here but Terraform in Project 2 (single-cloud native + type safety vs multi-team state management + ecosystem — shows tool judgment, not tribalism)

## Red lines (honesty script)

If asked "was this in production at LTIMindtree?":
"This is a portfolio build — production-grade patterns, deployed and torn down in my own subscription. What IS production experience: 6 years operating these exact services for Microsoft's global clients, including Sev-A escalations on APIM, Functions and Service Bus. The portfolio converts that operational depth into design ownership."
That answer gains trust. Never blur the line.
