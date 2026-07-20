# ADR-002: Compute Choice — Azure Functions vs AKS for Order Processing

**Status:** Accepted
**Date:** 2026-07-16
**Author:** Subhankar Pattnaik

## Context

The ShopFlow platform requires compute for two distinct workloads: HTTP-triggered order intake APIs (bursty, short-lived, scalable to zero) and queue-triggered order fulfillment processors (steady-state, message-driven). Both must scale independently and survive downstream failures.

## Decision

Use Azure Functions (Premium Plan) for all compute. HTTP-triggered Functions for intake APIs. Service Bus queue-triggered Functions for fulfillment processing. Premium Plan provides VNet integration and pre-warmed instances — eliminating cold start while keeping operational overhead low.

## Alternatives Considered

1. **AKS with KEDA:** Full control and scaling precision, but introduces cluster management, node pool sizing, and operational complexity disproportionate to the workload size.
2. **App Service:** Good for always-warm APIs but lacks native queue trigger scaling; requires WebJobs SDK or custom polling.
3. **Functions Consumption Plan:** Cost-optimal but cold start latency under burst would violate SLA for flash-sale intake.

## Consequences

- ✅ Zero cold start on Premium Plan with pre-warmed instances
- ✅ Native Service Bus trigger with built-in retry, dead-letter, and scaling
- ✅ VNet integration for private endpoint connectivity (progressive toward Project 2)
- ⚠️ Premium Plan has fixed baseline cost even at zero load (offset by at-scale efficiency)
- ⚠️ Function timeout at 10 min; long-running fulfillment needs Durable Functions or Logic Apps

## Related

- [ADR-001: Queue-Based Load Leveling](adr-001-load-leveling.md)
- [ADR-003: Messaging Selection](adr-003-messaging.md)
- [ADR-004: Async Intake Pattern](adr-004-async-intake.md)
