# ADR-004: Async Intake Pattern — 202 Accepted vs 201 Created

**Status:** Accepted
**Date:** 2026-07-16
**Author:** Subhankar Pattnaik

## Context

Order intake must be resilient to downstream fulfillment failures. If inventory reservation or payment processing fails, the order must not be lost — it must be queued and retried. A synchronous API that returns 201 Created implies the order is fully persisted and processed, which is false under failure conditions.

## Decision

Return `202 Accepted` with an order ID and a `Location` header pointing to a status endpoint. The order is durably enqueued in Service Bus before the response is sent. The client polls the status endpoint or receives a webhook callback when fulfillment completes.

## Alternatives Considered

1. **201 Created with synchronous processing:** Simpler client integration, but intake is blocked by fulfillment availability. Flash-sale surges would cascade-fail.
2. **WebSocket push:** Real-time status updates, but adds client complexity and requires persistent connections — not suitable for REST API partners.
3. **Long-polling:** Reduces client polling overhead but keeps connections open; APIM timeout limits apply.

## Consequences

- ✅ Order intake survives fulfillment outages (business requirement FR-3)
- ✅ Client gets immediate confirmation with tracking ID
- ⚠️ Client must implement polling logic (or webhook receiver)
- ⚠️ Status endpoint must be idempotent and cacheable
- ⚠️ Webhook delivery adds retry/failure complexity

## Related

- [ADR-001: Queue-Based Load Leveling](adr-001-load-leveling.md)
- [ADR-002: Compute Choice](adr-002-compute-choice.md)