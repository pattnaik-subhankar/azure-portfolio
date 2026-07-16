# ADR-001: Queue-Based Load Leveling for Order Intake

**Status:** Accepted
**Date:** 2026-07-16
**Author:** Subhankar Pattnaik

## Context

The e-commerce platform must accept orders during flash-sale events where traffic spikes to 40x baseline (~50 → 2,000 orders/min). Fulfillment systems (inventory reservation, payment processing, warehouse dispatch) have bounded throughput and cannot scale linearly. A direct synchronous write to the database under burst conditions would exhaust connection pools, cause timeouts, and result in lost orders.

## Decision

Decouple order intake from fulfillment using a message queue (Azure Service Bus). The Orders API writes an order message and immediately returns `202 Accepted` with an order ID. A background fulfillment processor drains the queue at a sustainable rate.

## Alternatives Considered

1. **Synchronous write (201 Created):** Simple, but fulfillment downtime blocks intake; burst = throttled connections and 5xx errors.
2. **Rate limiting at APIM:** Protects backend but rejects legitimate orders — unacceptable for revenue.
3. **Database-side queuing:** Uses SQL as the queue (orders table + status). Couples scaling with DB capacity; adds transaction overhead.

## Consequences

- ✅ Order intake survives downstream outages (business requirement FR-3)
- ✅ Functions scale independently: intake on HTTP triggers, fulfillment on queue triggers
- ✅ Backpressure is explicit — queue depth is observable, alertable
- ⚠️ Slight UX shift: client must poll status endpoint or receive webhook for final confirmation
- ⚠️ Additional operational complexity: monitoring DLQ, message deduplication, idempotent processors

## Related

- [ADR-002: Compute Choice (Functions vs AKS)](adr-002-compute-choice.md)
- [ADR-003: Messaging Selection (Service Bus)](adr-003-messaging.md)
- [ADR-004: Async Intake Pattern (202 vs 201)](adr-004-async-intake.md)
