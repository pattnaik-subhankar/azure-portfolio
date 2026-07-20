# ADR-004: Policy-as-Code Rollout Strategy

**Status:** Accepted
**Date:** 2026-07-18
**Author:** Subhankar Pattnaik

## Context

EdgeForge's CAF-aligned landing zone requires 40+ Azure Policy definitions to govern networking, security, cost, and compliance across 3 management groups and 5+ subscriptions. Manual policy assignment doesn't scale and introduces drift between environments.

## Decision

Define all policies as code (Terraform `azurerm_policy_definition` and `azurerm_policy_assignment` resources). Use three effects by severity: `audit` for informational, `auditIfNotExists` for monitoring gaps, `deny` for hard security boundaries (e.g., public endpoints, storage account keys). Roll out via CI/CD pipeline: plan → approve → apply.

Policy categories:
| Category | Effect | Example |
|---|---|---|
| Network | Deny | No public IPs on NICs |
| Security | Deny | Require HTTPS only |
| Compliance | Audit | Diagnostic settings enabled |
| Cost | Deny | Allowed VM SKUs only |
| Tags | Deny (DINE) | Require cost center tag |

## Alternatives Considered

1. **Manual policy assignment in Azure Portal:** Quick to start but drifts immediately — no version control, no approval gates.
2. **Azure Blueprints:** Comprehensive but deprecated in favor of deployment stacks; policies as code is the strategic path.
3. **Policy as code with Bicep:** Works for Azure-native but Terraform chosen for multi-environment state management and module composition.

## Consequences

- ✅ 40+ policies version-controlled and auditable
- ✅ Deny policies provide hard guardrails (no drift possible)
- ✅ Audit policies flag non-compliance without blocking
- ⚠️ Policy rollout across 5+ subscriptions requires pipeline orchestration
- ⚠️ DINE (DeployIfNotExists) policies need managed identity with Contributor at scope
- ⚠️ Exemptions must be documented — "policy-as-code" means "exemptions as code" too

## Related

- [ADR-001: CAF Landing Zone](adr-001-caf-landing-zone.md)
- [ADR-002: AKS and KEDA Stream Processing](adr-002-aks-keda-stream-processing.md)