# ADR-003: Global Ingestion — Active-Active vs Active-Passive

**Status:** Accepted
**Date:** 2026-07-18
**Author:** Subhankar Pattnaik

## Context

EdgeForge spans 40 plants across 3 continents. Network latency from a single-region ingestion point would exceed 200ms for remote plants, violating telemetry freshness requirements. Plants must continue buffering data during regional network partitions.

## Decision

Deploy active-active ingestion: 3 regional Event Hubs instances (Americas, EMEA, APAC), each receiving telemetry from plants in their geography. Plants publish to their nearest regional hub. Centralized analytics in a primary region with cross-region replication for DR.

## Alternatives Considered

1. **Single-region ingestion with global Front Door:** Simpler but adds 150-300ms latency for remote plants — violates real-time monitoring SLAs for predictive maintenance.
2. **Active-passive with failover:** Reduces cost but passive region is "cold" — recovery involves DNS flip and data backlog catch-up, RTO >30 min.
3. **Full mesh (every region to every region):** Maximum resilience but cross-region data duplication creates consistency conflicts and 3x egress cost.

## Consequences

- ✅ <50ms ingestion latency per plant (regional proximity)
- ✅ Plants buffer locally during regional outages (IoT Edge / Stack Edge)
- ✅ Regional data sovereignty compliance (data stays in geo)
- ⚠️ 3x Event Hubs cost (3 regional clusters)
- ⚠️ Analytics pipeline must merge cross-region data (event ordering)
- ⚠️ Regional hub sizing must handle local peaks independently

## Related

- [ADR-001: CAF Landing Zone](adr-001-caf-landing-zone.md)
- [ADR-002: AKS and KEDA Stream Processing](adr-002-aks-keda-stream-processing.md)