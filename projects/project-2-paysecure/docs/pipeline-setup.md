# Pipeline Setup — PaySecure CI/CD

**2+1 stage Azure DevOps pipeline: Validate → Plan Dev → (Manual Approval) → Prod. Terraform, Checkov, OIDC.**

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Terraform | ≥ 1.7.5 | Infrastructure provisioning |
| Azure CLI | ≥ 2.60 | Terraform backend + plan execution |
| Checkov | Latest (Docker) | Infrastructure security scanning |
| Docker | Latest | Checkov runtime |

---

## Step 1: Variable Group

Create in Azure DevOps (Library → Variable groups):

**Name:** `paysecure-credentials`

| Variable | Description |
|---|---|
| `TerraformBackendStorageAccount` | Private Azure Storage account for Terraform state |
| `TerraformBackendContainer` | Blob container name |
| `TerraformBackendKey` | State file key (e.g., `paysecure.tfstate`) |

All values backed by Azure Key Vault. Never store access keys in variable groups.

---

## Step 2: Service Connection

Create an **Azure Resource Manager** service connection with **OIDC federation**:

1. Project Settings → Service connections → New → Azure Resource Manager
2. Select **Workload Identity federation (automatic)**
3. Scope to the hub subscription
4. **Name:** `PaySecure-ARM`

This is the only credential the pipeline needs. Zero secrets, zero keys.

---

## Step 3: Environments

Create two environments in Azure DevOps:

| Environment | Purpose | Approval |
|---|---|---|
| `paysecure-dev` | Dev plan stage | None (auto) |
| `paysecure-prod` | Production deployment | Pre-deployment approval required |

Setup: Pipelines → Environments → New environment → add **Approvals and checks**.

---

## Step 4: Create the Pipeline

```bash
az pipelines create \
  --name "paysecure-ci" \
  --yml-path projects/project-2-paysecure/pipelines/azure-pipelines.yml \
  --repository "azure-portfolio" \
  --branch main
```

---

## Stage Summary

| Stage | Trigger | What Runs | Gate |
|---|---|---|---|
| **Validate** | PR to main, push to main | `terraform fmt -check`, `terraform validate`, Checkov static analysis | None |
| **Plan Dev** | Push to main (not PR) | Terraform init (private backend) → terraform plan — diff only, no apply | Validate success |
| **Prod** | Manual | Terraform plan → manual review → apply (OIDC, private storage backend) | Pre-deployment approval |

---

## Security

- **Zero-trust pipeline** — OIDC federation, no service principal secrets, no client secrets in YAML
- **Terraform state** — stored in a private Azure Storage account with deny-public-access
- **Checkov** — scans for exposed secrets, overly permissive NSGs, missing encryption, public endpoints
- **Private endpoints only** — all backend services are private; the pipeline authenticates via managed identity / workload federation
- **Production gate** — every production plan requires human approval in Azure DevOps Environments

---

## First Run

1. Create the pipeline from YAML
2. Build triggers on first push to main
3. Validate stage: confirm Terraform compiles and Checkov passes
4. Plan Dev: review the plan output for unexpected resource changes
5. Approve production gate manually when ready
