# ADR-003: IaC Choice — Terraform with OIDC Federation

**Status:** Accepted
**Date:** 2026-07-18
**Author:** Subhankar Pattnaik

## Context

PaySecure requires infrastructure-as-code with state locking, module composition, and multi-environment support. The platform must not store service principal secrets in CI/CD pipelines.

## Decision

Use Terraform with remote state (Azure Storage) and OIDC federation for GitHub Actions authentication. Organize as modules: network-hub, network-spoke, apim, app, data, security. Use workspaces or directory-based environments.

## Alternatives Considered

1. **Bicep:** Resume-native and simpler for Azure-only deployments. But lacks multi-cloud readiness and the module ecosystem PaySecure benefits from.
2. **ARM templates:** No state management, harder to compose, and verbose. Rejected for all new work.
3. **Terraform with service principal secrets:** Works but requires secret rotation and storage — OIDC eliminates this risk entirely.

## Consequences

- ✅ No service principal secrets in pipelines (OIDC federation)
- ✅ Remote state with locking prevents concurrent deployment conflicts
- ✅ Module composition enables reuse across spoke environments
- ⚠️ Terraform state file contains all resource config — protect with RBAC
- ⚠️ Provider version pinning needed to prevent breaking changes

## Related

- [ADR-001: WAF and Internal APIM](adr-001-waf-and-internal-apim.md)
- [ADR-002: Firewall Egress](adr-002-firewall-egress.md)
- [ADR-004: mTLS and Managed Identity](adr-004-mtls-and-managed-identity.md)