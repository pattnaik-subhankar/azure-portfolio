# ☁️ Azure Cloud Solutions Architect — Portfolio

**4 enterprise-grade Azure architecture projects, built end-to-end: IaC, CI/CD, security, compliance, multi-region.**

[![Azure](https://img.shields.io/badge/cloud-Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure)](https://azure.microsoft.com)
[![IaC](https://img.shields.io/badge/IaC-Bicep_+_Terraform-blue?style=for-the-badge)](https://github.com/pattnaik-subhankar/azure-portfolio)
[![Status](https://img.shields.io/badge/portfolio-active-success?style=for-the-badge)]()

---

## 📑 Projects

| # | Project | Domain | Architecture | IaC | Key Principle |
|---|---------|--------|-------------|-----|---------------|
| 1 | [**ShopFlow**](./projects/project-1-shopflow/README.md) | E-Commerce API | [📐 ARCHITECTURE.md](./projects/project-1-shopflow/ARCHITECTURE.md) | Bicep | Azure Well-Architected Framework |
| 2 | [**PaySecure**](./projects/project-2-paysecure/README.md) | Open Banking API | [📐 ARCHITECTURE.md](./projects/project-2-paysecure/ARCHITECTURE.md) | Terraform | Zero-Trust, Private Endpoint-only |
| 3 | [**MediSync**](./projects/project-3-medisync/README.md) | Healthcare Interop | [📐 ARCHITECTURE.md](./projects/project-3-medisync/ARCHITECTURE.md) | Bicep | Event-Driven, PHI-compliant |
| 4 | [**EdgeForge**](./projects/project-4-edgeforge/README.md) | IoT Telemetry | [📐 ARCHITECTURE.md](./projects/project-4-edgeforge/ARCHITECTURE.md) | Terraform + Bicep | CAF-aligned, Multi-Region, AKS + KEDA |

---

## 🏗️ Project Details

### 1. ShopFlow — Enterprise E-Commerce API Platform
[![WAF](https://img.shields.io/badge/Well--Architected-aligned-success)]()
[![IaC](https://img.shields.io/badge/IaC-Bicep-blue)]()
[![Build](https://img.shields.io/badge/build-passing-brightgreen)]()

Scalable e-commerce backend platform designed against Azure Well-Architected Framework pillars: cost optimization, operational excellence, performance efficiency, reliability, and security.

**Highlights:** API Management · App Service · Cosmos DB · Azure SQL · Application Gateway · WAF · Key Vault · CI/CD

### 2. PaySecure — Zero-Trust Open Banking API Platform
[![Security](https://img.shields.io/badge/security-private--endpoint--only-success)]()
[![IaC](https://img.shields.io/badge/IaC-Terraform-623CE4)]()
[![PCI](https://img.shields.io/badge/compliance-PCI_DSS--informed-blue)]()

Secure open banking platform built on zero-trust principles. All services communicate exclusively via private endpoints. PSD2/PCI-DSS compliance posture.

**Highlights:** Private Endpoints · API Management · AKS · Azure Key Vault · WAF · Sentinel · Terraform · Azure DevOps

### 3. MediSync — Event-Driven Patient Data Interoperability Hub
[![Architecture](https://img.shields.io/badge/architecture-event--driven-success)]()
[![IaC](https://img.shields.io/badge/IaC-Bicep-0078D4)]()
[![HIPAA](https://img.shields.io/badge/compliance-PHI--informed-blue)]()

Healthcare data interoperability platform using event-driven patterns. FHIR-compatible, HIPAA-informed security posture with audit logging.

**Highlights:** Azure Event Hubs · FHIR API · Azure Functions · Event Grid · Cosmos DB · Data Factory · Bicep

### 4. EdgeForge — Global IoT Telemetry Platform
[![Platform](https://img.shields.io/badge/platform-CAF--aligned-0078D4)]()
[![IaC](https://img.shields.io/badge/IaC-Terraform_+_Bicep-623CE4)]()
[![Runtime](https://img.shields.io/badge/runtime-AKS_+_KEDA-success)]()

Enterprise-scale IoT platform deployed on a Cloud Adoption Framework-aligned landing zone. Processes streaming telemetry at global scale across multiple Azure regions.

**Highlights:** Azure Landing Zone · AKS + KEDA · IoT Hub · Event Hubs · Cosmos DB · Azure Monitor · Multi-Region · Terraform + Bicep

---

## 🧰 Architecture Patterns Used

- **Zero-Trust Networking:** Private Endpoints, NSGs, no public IPs for data-plane services
- **Event-Driven:** Event Hubs, Event Grid, serverless Functions
- **Well-Architected Framework:** All 5 pillars assessed per project
- **Infrastructure as Code:** Bicep + Terraform, modular, idempotent
- **CI/CD:** Azure DevOps pipelines, GitOps-ready
- **Multi-Region / DR:** Active-Passive, geo-redundant storage
- **CAF Enterprise Landing Zone:** Management groups, policy, identity, connectivity

---

## 📂 Repository Structure

```
azure-portfolio/
├── projects/
│   ├── project-1-shopflow/       ← E-Commerce API Platform
│   │   ├── ARCHITECTURE.md       ← Architecture decision record
│   │   ├── README.md             ← Project overview
│   │   ├── docs/                 ← Supporting documentation
│   │   ├── infra/                ← IaC (Bicep)
│   │   └── pipelines/            ← CI/CD definitions
│   ├── project-2-paysecure/      ← Open Banking API Platform
│   ├── project-3-medisync/       ← Healthcare Interoperability Hub
│   ├── project-4-edgeforge/      ← Global IoT Telemetry Platform
│   └── 00-blueprints.md          ← Cross-project architecture blueprints
├── 00-master-plan.md             ← Portfolio strategy & roadmap
└── 01-resume-analysis.md         ← Resume-to-portfolio mapping
```

---

## 🎯 Target Roles

This portfolio demonstrates competencies aligned with:
- **Azure Solutions Architect** (AZ-305)
- **Azure DevOps Engineer** (AZ-400)
- **Cloud Solution Architect — App Innovation / Data & AI**
- **Site Reliability Engineer** (SRE)

---

*Built with Azure, Bicep, Terraform, and a strong coffee-to-diagram ratio.*
