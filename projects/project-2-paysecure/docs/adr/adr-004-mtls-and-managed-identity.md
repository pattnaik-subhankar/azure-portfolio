# ADR-004: Partner Auth — mTLS + Managed Identity Hybrid

**Status:** Accepted
**Date:** 2026-07-18
**Author:** Subhankar Pattnaik

## Context

PaySecure exposes APIs to banking partners with two distinct trust models: external partners (mTLS + OAuth2 client credentials) and internal Azure services (Managed Identity). A single auth strategy doesn't fit both.

## Decision

Use mTLS with client certificate validation at Application Gateway for external partners, combined with Entra ID OAuth2 client credentials at APIM for API-level authorization. Internal Azure services authenticate via system-assigned Managed Identity. APIM validates JWT tokens and maps claims to backend operations.

## Alternatives Considered

1. **API key only:** Simple but not regulatory-grade — no identity binding, no revocation granularity.
2. **OAuth2 without mTLS:** Strong at API layer but misses transport-layer trust — man-in-the-middle vector remains.
3. **Mutual TLS only:** Secures transport but doesn't provide per-operation authorization granularity.

## Consequences

- ✅ Defense in depth: transport-layer (mTLS) + application-layer (OAuth2)
- ✅ No shared secrets for internal services (Managed Identity)
- ⚠️ Certificate lifecycle management (renewal, revocation) requires automation
- ⚠️ APIM must validate client certificate thumbprints against partner registry
- ⚠️ Onboarding new partners requires certificate exchange process

## Related

- [ADR-001: WAF and Internal APIM](adr-001-waf-and-internal-apim.md)
- [ADR-002: Firewall Egress](adr-002-firewall-egress.md)