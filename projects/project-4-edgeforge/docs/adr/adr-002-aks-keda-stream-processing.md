# ADR-002: Stream Processing — AKS with KEDA vs Azure Stream Analytics

**Status:** Accepted
**Date:** 2026-07-18
**Author:** Subhankar Pattnaik

## Context

EdgeForge ingests telemetry from 40 plants at ~500 events/sec per plant (20,000 events/sec aggregate). Stream processors must normalize, enrich, and route telemetry to the ADLS medallion architecture (bronze/silver/gold). The processing pipeline requires custom enrichment logic (plant metadata, sensor calibration, anomaly scoring) that exceeds the capabilities of declarative stream processing.

## Decision

Use Azure Kubernetes Service (AKS) with KEDA (Kubernetes Event-Driven Autoscaling) for stream processing. KEDA scales pod replicas based on Event Hubs partition count, ensuring one processor per partition for ordered processing. Workload identity (Entra ID for pods) for Event Hubs and ADLS authentication.

## Alternatives Considered

1. **Azure Stream Analytics (ASA):** Low-code, managed. But custom enrichment (sensor calibration libraries, plant-specific anomaly models) requires JavaScript UDFs — not production-grade for complex logic.
2. **Azure Functions (Event Hubs trigger):** Simpler than AKS but batch processing per partition has scaling ceiling; cost per event at 20K/sec exceeds AKS after steady-state volume.
3. **Spark on Databricks:** Full analytics capability but overkill for stream normalization — adds cluster startup latency and cost for real-time path.

## Consequences

- ✅ Full control over processing logic (Python/Go containers)
- ✅ KEDA scales to zero during plant downtime — cost-efficient
- ✅ Workload identity eliminates Event Hubs connection strings
- ⚠️ AKS cluster management overhead (node pools, upgrades, monitoring)
- ⚠️ Pod startup latency must stay under partition checkpoint timeout
- ⚠️ Requires container image pipeline separate from stream pipeline

## Related

- [ADR-001: CAF Landing Zone](adr-001-caf-landing-zone.md)
- [ADR-003: Active-Active Ingestion](adr-003-active-active-ingestion.md)
- [ADR-004: Policy-as-Code Rollout](adr-004-policy-as-code-rollout.md)