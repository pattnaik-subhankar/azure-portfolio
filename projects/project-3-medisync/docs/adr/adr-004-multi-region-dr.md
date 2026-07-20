# ADR-004: Multi-Region Disaster Recovery Strategy

**Status:** Accepted
**Date:** 2026-07-18
**Author:** Subhankar Pattnaik

## Context

MediSync must survive a full Azure region failure with defined RTO/RPO targets. The platform spans Event Hubs, Service Bus, Cosmos DB, Azure SQL, Functions, and APIM — each with different DR capabilities and recovery patterns.

## Decision

Target RTO: 1 hour, RPO: 5 minutes. Implement per-component DR strategy:

| Component | DR Pattern | Recovery Mechanism |
|---|---|---|
| Cosmos DB | Multi-region (single write) | Automatic failover to paired region |
| Event Hubs | Geo-DR alias | Manual failover of alias pointer |
| Service Bus | Geo-DR Premium | Paired namespace with alias |
| Azure SQL | Auto-failover groups | Geo-replicated with read replicas |
| Functions | Active-passive | Redeploy from IaC in DR region |
| APIM | Active-passive | Backup/restore or redeploy |

Document trade-off: Cosmos DB multi-region writes would reduce RPO to near-zero but introduces conflict resolution complexity — rejected for initial design.

## Alternatives Considered

1. **Active-active all components:** Best RPO/RTO but 2x cost, conflict resolution complexity, and operational overhead disproportionate to MediSync's scale.
2. **Backup/restore only (no warm standby):** Cheapest but RTO measured in hours/days — unacceptable for healthcare data availability.
3. **Single-region deployment + cold DR scripts:** RTO >4h — fails business requirement.

## Consequences

- ✅ Defined RTO/RPO matrix per component
- ✅ Cosmos DB failover is transparent to application
- ⚠️ Event Hubs failover is manual (operator runbook needed)
- ⚠️ DR region capacity must be pre-provisioned or guaranteed
- ⚠️ DR drills required quarterly to validate runbooks

## Related

- [ADR-001: Event Hubs and Service Bus Split](adr-001-event-hubs-and-service-bus.md)
- [ADR-002: Cosmos DB Partitioning](adr-002-cosmos-partitioning-and-consistency.md)
- [ADR-003: PHI Protection](adr-003-phi-protection-cmk-and-audit.md)