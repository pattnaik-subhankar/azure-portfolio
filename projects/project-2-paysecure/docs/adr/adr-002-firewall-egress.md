# ADR-002: Firewall Egress — Azure Firewall Premium vs NVA

**Status:** Accepted
**Date:** 2026-07-18
**Author:** Subhankar Pattnaik

## Context

PaySecure's zero-trust architecture requires all egress traffic from the spoke VNet to be inspected and routed through a central security appliance. The platform must log all outbound connections, enforce FQDN-based rules, and support TLS inspection for regulatory audit.

## Decision

Deploy Azure Firewall Premium in the hub VNet. Force-tunnel all spoke egress through the firewall via route tables (0.0.0.0/0 → firewall private IP). Use FQDN-based rules for allowed API endpoints and service tags for Azure PaaS.

## Alternatives Considered

1. **Third-party NVA (Palo Alto / Fortinet):** Richer rule sets, but adds licensing cost, VM management, and HA complexity disproportionate to this design.
2. **NSG-only egress:** Simpler but lacks FQDN filtering and TLS inspection — insufficient for open-banking compliance.
3. **Azure Firewall Standard:** Works for basic egress but lacks TLS inspection and IDPS — Premium chosen for compliance depth.

## Consequences

- ✅ Centralized egress inspection with FQDN rules
- ✅ Native integration with Azure Monitor for flow logs
- ⚠️ ~45 min deployment time (plan accordingly for DR scenarios)
- ⚠️ Per-GB processing cost — monitor log volume from noisy services
- ⚠️ Firewall is a single-region resource; multi-region DR needs separate instances

## Related

- [ADR-001: WAF and Internal APIM](adr-001-waf-and-internal-apim.md)
- [ADR-003: Terraform and OIDC](adr-003-terraform-and-oidc.md)