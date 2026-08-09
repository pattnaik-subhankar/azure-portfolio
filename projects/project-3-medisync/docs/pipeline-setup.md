# Pipeline Setup — MediSync CI/CD

**2+1 stage Azure DevOps pipeline: Validate → WhatIf Dev → (Approval) → Prod. Bicep, PSRule, PHI-compliance scanning.**

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Azure CLI | ≥ 2.60 | Bicep build + what-if deployment |
| Bicep CLI | Latest | IaC compilation |
| PSRule for Azure | Latest | Well-Architected compliance + PHI-aware rules |
| CredScan (optional) | Latest | Secret / PHI leak detection |

---

## Step 1: Variable Group

Create in Azure DevOps (Library → Variable groups):

**Name:** `medisync-credentials`

| Variable | Description |
|---|---|
| `KeyVaultName` | Azure Key Vault containing connection strings, FHIR endpoint keys |
| `AuditStorageAccount` | Immutable blob storage for audit logs |

---

## Step 2: Service Connection

Create an **Azure Resource Manager** service connection with **OIDC federation**:

1. Project Settings → Service connections → New → Azure Resource Manager
2. **Workload Identity federation (automatic)**
3. Scope to the healthcare landing zone subscription
4. **Name:** `MediSync-ARM`

---

## Step 3: Environments

| Environment | Purpose | Approval |
|---|---|---|
| `medisync-dev` | Dev WhatIf stage | None |
| `medisync-prod` | Production | Pre-deployment approval |

Setup: Pipelines → Environments → New → add **Approvals and checks**.

---

## Step 4: Create the Pipeline

```bash
az pipelines create \
  --name "medisync-ci" \
  --yml-path projects/project-3-medisync/pipelines/azure-pipelines.yml \
  --repository "azure-portfolio" \
  --branch main
```

---

## Stage Summary

| Stage | Trigger | What Runs | Gate |
|---|---|---|---|
| **Validate** | PR to main, push to main | Bicep build, PSRule WAF + PHI rule check, secret scanning | None |
| **WhatIf Dev** | Push to main | `az deployment group what-if` with OIDC — shows resource diff without deploying | Validate success |
| **Prod** | Manual | Bicep what-if → human review → deploy with CMK, private endpoints, immutable audit | Pre-deployment approval |

---

## PHI Compliance Checks

Added gates specific to healthcare workloads:

1. **PSRule with PHI-focused rules** — checks for encryption at rest (CMK), audit logging enabled, private endpoints for data services
2. **Secret scanning** — zero-tolerance for connection strings, FHIR endpoint keys, or patient identifiers in pipeline logs
3. **Immutable storage** — verifies audit storage is configured with legal hold / immutability policies

---

## Security Notes

- **OIDC federation** — no secrets in the pipeline definition
- **Customer-managed keys** — deployed resources use CMK; Key Vault is the single source of truth
- **Private endpoints** — no Cosmos DB or SQL instance has a public endpoint
- **PHI-in-log = release blocker** — any potential PHI pattern in logs fails the validate stage

---

## First Run

1. Create pipeline → Validate stage triggers automatically
2. Review Bicep build output and PSRule findings
3. WhatIf Dev: inspect the deployment diff
4. Approve prod when the WhatIf output is clean and audit controls are confirmed
