# Pipeline Setup — EdgeForge CI/CD

**2+1 stage Azure DevOps pipeline: Validate → Plan → (Approval) → Apply. Terraform + Bicep, Checkov, CAF-aligned.**

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Terraform | ≥ 1.7.5 | Platform infrastructure |
| Bicep CLI | Latest | Workload-level IaC |
| Azure CLI | ≥ 2.60 | Deployment operations |
| Checkov | Latest (Docker) | Infrastructure static analysis |
| Docker | Latest | Checkov runtime |

---

## Step 1: Variable Group

Create in Azure DevOps (Library → Variable groups):

**Name:** `edgeforge-credentials`

| Variable | Description |
|---|---|
| `LandingZoneSubscription` | Target subscription for platform resources |
| `TerraformBackendStorageAccount` | Private Azure Storage for Terraform state |
| `TerraformBackendContainer` | Blob container for state files |
| `KeyVaultName` | Secrets store for AKS credentials, connection strings |

---

## Step 2: Service Connection

Create an **Azure Resource Manager** service connection with **OIDC federation**:

1. Project Settings → Service connections → New → Azure Resource Manager
2. **Workload Identity federation (automatic)**
3. Scope: the management subscription + workload subscriptions
4. **Name:** `EdgeForge-ARM`

---

## Step 3: Environments

| Environment | Purpose | Approval |
|---|---|---|
| `edgeforge-dev` | Dev plan stage | None |
| `edgeforge-prod` | Production apply | Pre-deployment approval |

Setup: Pipelines → Environments → New → add **Approvals and checks**.

---

## Step 4: Create the Pipeline

```bash
az pipelines create \
  --name "edgeforge-ci" \
  --yml-path projects/project-4-edgeforge/pipelines/azure-pipelines.yml \
  --repository "azure-portfolio" \
  --branch main
```

---

## Stage Summary

| Stage | Trigger | What Runs | Gate |
|---|---|---|---|
| **Validate** | PR to main, push to main | `terraform fmt -check`, `terraform validate`, Checkov on Terraform + Bicep | None |
| **Plan** | Push to main | Terraform plan (private backend, OIDC) — multi-region plan published for review | Validate success |
| **Apply** | Manual approval | Terraform apply (CAF-aligned East US + West Europe), AKS/KEDA provisioning | Pre-deployment approval |

---

## Platform + Workload Validation

The pipeline validates both layers:

1. **Platform layer** — Terraform: management groups, policy assignments, networking, identity, logging, Defender, FinOps
2. **Workload layer** — Bicep: AKS + KEDA, Event Hubs, ADLS Gen2, Cosmos DB, private endpoints

Checkov scans both layers for: exposed ports, public storage accounts, missing encryption, overly permissive NSGs, and unencrypted data paths.

---

## Multi-Region Considerations

| Region | Role | Notes |
|---|---|---|
| East US | Primary | Active AKS cluster, Event Hubs, ADLS Gen2 |
| West Europe | Secondary | Passive DR, geo-redundant storage replication |

The plan stage generates diffs for both regions. Apply deploys sequentially (primary → secondary). DR failover is manual and runbook-driven (see `docs/runbooks/`).

---

## Security

- **OIDC federation** — no service principal secrets anywhere in the pipeline
- **CAF-aligned** — deployed into a governed management group hierarchy with Azure Policy enforcement
- **Private AKS** — no public API server; pipeline communicates via private endpoints
- **Multi-region state** — Terraform state stored in geo-redundant, encrypted private storage
- **Production gate** — every apply requires human approval; no automated production changes

---

## First Run

1. Create the pipeline → Validate runs automatically
2. Check Terraform format, validation, and Checkov findings
3. Plan: review multi-region resource diff
4. Approve: production gate triggers sequential apply (East US → West Europe)
