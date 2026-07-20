# PaySecure — Zero-Trust Open Banking API Platform on Azure

## Architecture Diagram

[![IaC](https://img.shields.io/badge/IaC-Terraform-623CE4)]() [![CI/CD](https://img.shields.io/badge/CI%2FCD-Azure%20DevOps-0078D4)]() [![Security](https://img.shields.io/badge/security-private--endpoint--only-success)]() [![Azure](https://img.shields.io/badge/cloud-Microsoft%20Azure-0078D4)]()

> A reference architecture for a regulated financial-services API platform. Partner traffic terminates at Application Gateway WAF v2, reaches APIM in internal mode, and accesses only private backends. Terraform, Azure Policy, Microsoft Entra ID, managed identities, private DNS, and Azure DevOps workload identity federation eliminate public data paths and long-lived deployment secrets.

## Business outcome

A mid-size bank needs PSD2-style account and payment APIs for approved partners without exposing application, data, or management endpoints to the public internet. PaySecure establishes a reusable workload pattern with auditable access, deterministic private DNS, centralized egress control, and policy guardrails.

## Request path

`Partner → Application Gateway WAF v2 → APIM (internal) → private Function App / Web App → private Azure SQL`

Management and outbound path: `spoke workload → UDR → Azure Firewall Premium → approved destinations`. Private Endpoint names resolve through linked Private DNS zones; no workload service has a public network path.

## What this demonstrates

| Area | Evidence in this repository |
|---|---|
| Zero trust | Private endpoints, deny-public-access policy, WAF, mTLS design, least-privilege managed identities |
| Enterprise networking | Hub-spoke, UDR, firewall egress, DNS resolver pattern, gateway/APIM split |
| Delivery maturity | Terraform modules, remote-state design, OIDC pipeline, plan approval and security gates |
| Operability | Correlation IDs, diagnostic settings, Sentinel detections, alerts, runbook and RTO/RPO targets |
| Architect communication | ADRs, threat model, trade-offs, cost levers, interview pack |

## Repository layout

```text
infra/                 Terraform root, modules, environment examples
pipelines/             Azure DevOps validation and promotion pipeline
docs/                  Architecture, threat model, ADRs, diagrams, runbook
interview-prep.md      Senior-level interview questions and answers
```

## Deployment boundary

This is intentionally a **non-deployed reference implementation**. It contains no subscription IDs, tenant IDs, certificates, passwords, API keys, or connection strings. A deployment requires a bank-approved landing zone, DNS/IP plan, certificate process, break-glass procedure, and service connections. See [ARCHITECTURE.md](ARCHITECTURE.md).

## Honest portfolio statement

“Designed a zero-trust financial API reference platform using hub-spoke networking, APIM internal mode, Application Gateway WAF, private endpoints, Terraform modules, Azure Policy guardrails, and OIDC-based Azure DevOps delivery.”

Do not claim that a bank processed production payments on this platform unless you have actually delivered that work.
