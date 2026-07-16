# Observability and Cost Model

## Workbook views

1. **Ingress health:** APIM request volume, rejected schema/auth calls, latency, and opaque correlation IDs.
2. **Event health:** Event Hubs incoming/outgoing bytes, consumer lag, throughput-unit pressure, and checkpoint age.
3. **Workflow health:** Service Bus active/DLQ count, oldest message, session backlog, retries, and duplicate detection.
4. **Processor health:** Function failures, duration, concurrency, dependency failures, idempotency rejections.
5. **Data health:** Cosmos RU/s, 429 rate, hot-partition indicators, SQL resource utilization, storage immutability/audit success.
6. **Security health:** private-DNS checks, private-endpoint connection state, Key Vault denials, policy compliance, and privileged activity.

## Alerting principles

Alerts name service, environment, severity, and correlation ID—not patient names, identifiers, or payload content. Suppress duplicates during an acknowledged incident, route clinical workflow exceptions separately from platform availability alerts, and review thresholds after load tests.

## Cost levers

| Driver | Cost-control decision |
|---|---|
| Event Hubs | size throughput/processing units from sustained load and consumer lag; avoid overprovisioning baseline capacity |
| Cosmos DB | autoscale vs. provisioned throughput from measured spikiness; reduce cross-partition reads and 429 retries |
| Functions | Premium only where VNet/warm-start needs justify it; schedule non-production capacity |
| Log Analytics/Sentinel | retention by data class, archive cold evidence, and avoid payload logging |
| Network/CMK | treat private endpoints, DNS, firewall, and key operations as security baseline costs, not optional extras |

Create budgets by environment and tags; no portfolio estimate is presented as a production quote without region, volume, retention, and SKU inputs.
