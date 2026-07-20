# ADR-001: Enterprise Landing Zone — CAF-Aligned Management Groups

**Status:** Accepted
**Date:** 2026-07-18
**Author:** Subhankar Pattnaik

## Context

EdgeForge must support 40+ plant workloads across 3 continents with consistent governance, cost management, and security posture. A flat subscription model would create policy sprawl, inconsistent RBAC, and unmanageable cost allocation as the platform scales.

## Decision

Adopt Cloud Adoption Framework (CAF) enterprise-scale landing zone with a management group hierarchy:

```
Root
├── Platform (connectivity, identity, management)
│   ├── Connectivity (hub VNets, firewalls, VPN/ER)
│   ├── Identity (Entra ID, PIM)
│   └── Management (Log Analytics, Sentinel, automation)
├── Landing Zones
│   ├── Production (3 regional subscriptions)
│   ├── Non-Production (dev/test/staging)
│   └── Sandbox (innovation, proof-of-concepts)
└── Decommissioned (quarantine before deletion)
```

Policy-as-code via Azure Policy initiatives at management group level with deny/DINE/audit effects. Subscription vending via Terraform module with standardized blueprint.

## Alternatives Considered

1. **Single subscription for all workloads:** Simplest but no isolation boundary — blast radius too large, cost tracking impossible at scale.
2. **Subscription per plant:** Maximum isolation but management overhead for 40+ subscriptions is operationally unsustainable without full automation.
3. **Tag-based governance only:** Tags are advisory — can't enforce. Policy at management group level provides hard guardrails.

## Consequences

- ✅ Governance scales to 100+ workloads without additional policy configuration
- ✅ Cost allocation per workload via subscription boundaries
- ✅ Security boundaries between production and non-production
- ⚠️ Cross-subscription networking requires hub-spoke or VWAN
- ⚠️ Initial setup complexity — one-time cost amortized across all future workloads
- ⚠️ Subscription vending must be fully automated to avoid ticket-based provisioning

## Related

- [ADR-002: AKS and KEDA Stream Processing](adr-002-aks-keda-stream-processing.md)
- [ADR-004: Policy-as-Code Rollout](adr-004-policy-as-code-rollout.md)