# ADR-005: Identity — Managed Identity vs Service Principal

**Status:** Accepted
**Date:** 2026-07-16
**Author:** Subhankar Pattnaik

## Context

ShopFlow's compute resources (Functions, Logic Apps) must authenticate to Azure SQL, Service Bus, Key Vault, and Blob Storage. Shared secrets and connection strings in configuration create a credential rotation burden and are a security risk.

## Decision

Use system-assigned Managed Identity for all Azure-to-Azure authentication. Eliminate all connection strings containing secrets. Use Key Vault references in App Configuration for non-secret settings only.

## Alternatives Considered

1. **Service Principals with secrets:** Works but requires credential rotation, secret storage, and increases attack surface.
2. **User-assigned Managed Identity:** Useful for shared identity across resources but adds management overhead without benefit for single-resource patterns.
3. **Connection strings in Key Vault:** Moves the secret but doesn't eliminate it; still requires rotation.

## Consequences

- ✅ Zero secrets in configuration or code
- ✅ Automatic credential rotation (Azure-managed)
- ✅ RBAC alignment — each resource gets exactly the permissions it needs
- ⚠️ Some legacy services (e.g., on-prem connectors) may not support Managed Identity
- ⚠️ Cross-tenant scenarios require additional setup

## Related

- [ADR-001: Queue-Based Load Leveling](adr-001-load-leveling.md)
- [ADR-002: Compute Choice](adr-002-compute-choice.md)