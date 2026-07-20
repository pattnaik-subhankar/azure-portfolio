# ADR-003: PHI Protection — CMK Encryption and Immutable Audit

**Status:** Accepted
**Date:** 2026-07-18
**Author:** Subhankar Pattnaik

## Context

MediSync processes protected health information (PHI) requiring HIPAA-informed controls: encryption at rest with customer-managed keys, immutable audit logs, access review trails, and data residency compliance across regions.

## Decision

Use Customer-Managed Keys (CMK) in Azure Key Vault Premium (HSM-backed) for Cosmos DB and Azure Storage. Enable immutable blob storage with time-based retention for audit logs. Implement RBAC with least privilege for all data access — no shared keys or storage account keys in use.

## Alternatives Considered

1. **Platform-Managed Keys (PMK):** Default, simplest. But PHI data requires provable key control — PMK doesn't satisfy compliance audit requirements.
2. **Dedicated HSM appliance (on-prem):** Maximum control but adds physical infrastructure, connectivity, and latency. Overkill for cloud-native PHI handling.
3. **Double encryption (platform + customer):** Extra security but Azure PaaS support is limited; adds cost without proportional benefit when CMK is already in place.

## Consequences

- ✅ Provable key control for compliance audits
- ✅ Immutable audit trail with retention policy enforcement
- ✅ HSM-backed keys meet FIPS 140-2 Level 2+
- ⚠️ Key rotation requires planning — expired keys block data access
- ⚠️ CMK adds slight latency to cryptographic operations
- ⚠️ Key Vault Premium incurs higher cost than Standard tier

## Related

- [ADR-001: Event Hubs and Service Bus Split](adr-001-event-hubs-and-service-bus.md)
- [ADR-002: Cosmos DB Partitioning](adr-002-cosmos-partitioning-and-consistency.md)
- [ADR-004: Multi-Region DR](adr-004-multi-region-dr.md)