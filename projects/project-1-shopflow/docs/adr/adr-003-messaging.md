# ADR-003: Messaging Selection — Service Bus vs Storage Queue vs Event Hubs

**Status:** Accepted
**Date:** 2026-07-16
**Author:** Subhankar Pattnaik

## Context

ShopFlow needs a message broker for order intake decoupling. The platform must guarantee at-least-once delivery, ordered processing within a session, and dead-letter handling for poison messages. The system must also support partner notifications (event-driven, fan-out) for order status changes.

## Decision

Use Azure Service Bus for order processing (queues + sessions). Use Event Grid for partner notifications (push-based, fan-out). Keep Event Hubs out of scope for this project — it's designed for high-throughput telemetry, not ordered transactional messaging.

## Alternatives Considered

1. **Storage Queue:** Simple, cheap, infinite capacity. No sessions, no FIFO guarantee, no dead-letter visibility. Rejected for production order processing.
2. **Event Hubs:** High-throughput, partitioned. But lacks sessions, dedup, and per-message dead-letter. Better suited for Project 3 (MediSync) telemetry ingestion.
3. **RabbitMQ on AKS:** Full AMQP control. Adds cluster management and operational burden — overkill for a single messaging pattern.

## Consequences

- ✅ Sessions guarantee FIFO per order stream
- ✅ Dead-letter queue with reason headers for operational visibility
- ✅ Service Bus Explorer for support debugging
- ⚠️ Premium tier needed for VNet integration (higher cost than Standard)
- ⚠️ Maximum 80 GB per queue (avoid using as event store — Cosmos DB for that)

## Related

- [ADR-001: Queue-Based Load Leveling](adr-001-load-leveling.md)
- [ADR-002: Compute Choice](adr-002-compute-choice.md)
- [ADR-004: Async Intake Pattern](adr-004-async-intake.md)