# MediSync — Event-Driven Patient Data Interoperability Hub

## Architecture Diagram

[![IaC](https://img.shields.io/badge/IaC-Bicep-0078D4)]() [![CI/CD](https://img.shields.io/badge/CI%2FCD-Azure%20DevOps-0078D4)]() [![Architecture](https://img.shields.io/badge/architecture-event--driven-success)]() [![Security](https://img.shields.io/badge/PHI-compliance--informed-blue)]()

> A healthcare interoperability reference design that ingests FHIR/HL7-style events from approved systems, separates high-throughput ingestion from ordered clinical workflows, and protects sensitive patient data through private networking, managed identity, customer-managed keys, immutable audit storage, and multi-region recovery.

## Scope and authenticity

This is a **compliance-informed portfolio design**, not a claim of HIPAA certification, clinical validation, production patient-data processing, or medical-device approval. It uses synthetic payloads only. A real deployment requires legal, privacy, security, clinical-safety, and data-governance approval.

## Architecture in one line

`Source systems → APIM + Functions → Event Hubs (high-volume ADT) / Service Bus (ordered workflows) → processors → Cosmos DB + Azure SQL → approved downstream consumers`

## Why this project matters

MediSync demonstrates the next level after secure API modernization: eventing decisions, idempotent processing, PHI-aware controls, observability, retention, and multi-region recovery with explicit RTO/RPO trade-offs.

## Repository layout

```text
infra/             Modular Bicep and environment parameter example
pipelines/         Azure DevOps validation and what-if pipeline
docs/              Diagram, threat model, ADRs, DR and incident runbooks
interview-prep.md  Architect-level discussion prompts and answers
```

## Honest resume statement

“Designed a compliance-informed, event-driven healthcare interoperability reference architecture using Event Hubs, Service Bus, Azure Functions, Cosmos DB, private endpoints, CMK, immutable audit storage, and multi-region DR targets.”

Only use this as a portfolio/design statement unless you have delivered a real healthcare workload.
