# EdgeForge — Global IoT Telemetry Platform on an Enterprise Azure Landing Zone

[![IaC](https://img.shields.io/badge/IaC-Terraform%20%2B%20Bicep-623CE4)]() [![Platform](https://img.shields.io/badge/platform-CAF--aligned-0078D4)]() [![Runtime](https://img.shields.io/badge/runtime-private%20AKS%20%2B%20KEDA-success)]() [![Architecture](https://img.shields.io/badge/architecture-multi--region-blue)]()

> An architect-level reference design for a manufacturer operating forty plants across three regions. EdgeForge combines a reusable enterprise landing zone with a private, multi-region IoT workload for telemetry ingestion, stream processing, and governed analytics.

## Authenticity boundary

This project is a portfolio architecture—not a claim that a manufacturer, plant, or medical/industrial control system runs on it. The edge narrative is informed by Azure Stack Edge/Data Box experience and is intended to be technically defensible in an architecture interview.

## Two-layer architecture

1. **Platform layer:** management groups, subscription model, Azure Policy, identity, networking, logging, Defender, and FinOps guardrails.
2. **Workload layer:** plant edge ingestion → regional Event Hubs → private AKS stream processing with KEDA → ADLS Gen2 bronze/silver/gold → governed API/data products.

## Portfolio statement

“Designed a CAF-aligned, multi-region IoT telemetry reference platform with policy-as-code governance, private AKS/KEDA stream processing, Event Hubs ingestion, ADLS Gen2 data zoning, centralized observability, and FinOps controls.”

Use that as a design/portfolio statement only.
