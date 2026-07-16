# ADR-001: Use Application Gateway WAF v2 in front of APIM internal mode

**Status:** Accepted for this reference design.

**Decision:** expose only Application Gateway WAF v2 to partners and deploy APIM in internal mode.

**Context:** the platform needs a web application firewall at the public boundary and API-specific governance without a public API gateway endpoint.

**Consequences:** improved separation of trust boundaries and API controls; added cost, latency, subnet sizing, certificate, routing, and private DNS complexity. A simpler APIM external-mode deployment is not selected because it does not meet the stated private-backend boundary.
