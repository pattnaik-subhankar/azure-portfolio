# Pipeline Setup — ShopFlow CI/CD

**3-stage Azure DevOps pipeline: Build → Deploy Dev → Manual Approval → Deploy Prod.**

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Azure CLI | ≥ 2.60 | Infrastructure deployment |
| Bicep CLI | Latest | IaC compilation |
| .NET SDK | 8.x | Code build & test |
| PSRule for Azure | Latest | Well-Architected compliance checks |
| Newman (Postman CLI) | Latest | Smoke tests |

Install:

```bash
az upgrade
az bicep install
dotnet tool install -g Microsoft.PowerShell.ConsoleGuiTools  # for PSRule
npm install -g newman
```

---

## Step 1: Variable Group

Create a variable group in Azure DevOps (Library → Variable groups):

**Name:** `shopflow-credentials`

Link to Azure Key Vault (recommended) or add variables directly:

| Variable | Description |
|---|---|
| `KeyVaultName` | Azure Key Vault name (secrets: connection strings, API keys) |

If not using Key Vault, add individual secrets as **secret** variables.

---

## Step 2: Service Connection

Create an **Azure Resource Manager** service connection with **OIDC (Workload Identity Federation)**:

1. Azure DevOps → Project Settings → Service connections → New service connection
2. Select **Azure Resource Manager**
3. Choose **Workload Identity federation (automatic)**
4. Scope to the subscription containing `rg-shopflow-dev` and `rg-shopflow-prod`
5. **Name:** `ShopFlow-ARM`

No secrets, no service principal keys. The pipeline authenticates via federation.

---

## Step 3: Environment Approval Gate

Create a production environment in Azure DevOps with a pre-deployment approval:

1. Pipelines → Environments → **New environment**
2. **Name:** `ShopFlow-Production`
3. Add **Approvals and checks** → **Approvals**
4. Set minimum approvers: **1** (or more for team workflows)

This gate triggers between the Dev and Prod stages. No code deploys to production without an approved reviewer.

---

## Step 4: Create the Pipeline

```bash
# From the repo root
az pipelines create \
  --name "shopflow-ci" \
  --yml-path projects/project-1-shopflow/pipelines/azure-pipelines.yml \
  --repository "azure-portfolio" \
  --branch main
```

Or in the Azure DevOps UI:

1. Pipelines → New Pipeline → Azure Repos Git
2. Select the `azure-portfolio` repository
3. Choose **Existing Azure Pipelines YAML file**
4. Path: `projects/project-1-shopflow/pipelines/azure-pipelines.yml`
5. **Save and run**

---

## Stage Summary

| Stage | Trigger | What Runs | Gate |
|---|---|---|---|
| **Build** | PR to main, push to main | Bicep lint, PSRule WAF check, .NET build + unit tests | None |
| **Dev Deploy** | Push to main, PR merge | Bicep what-if → deploy infra → deploy 3 Function Apps → Newman smoke tests | Build success |
| **Prod Deploy** | Manual approval | Same as dev, targeting prod resources | Pre-deployment approval on `ShopFlow-Production` environment |

---

## What the pipeline validates

1. **Bicep compiles** — catches IaC errors before deployment
2. **PSRule for Azure** — checks infrastructure against Well-Architected Framework (security, reliability, cost)
3. **Unit tests** — .NET test suite for business logic
4. **Bicep what-if** — shows deployment diff before touching any resource
5. **Newman smoke tests** — verifies orders/catalog/fulfillment APIs respond correctly post-deployment

---

## First run

1. Run the pipeline manually from Azure DevOps
2. The Build stage runs automatically
3. Dev Deploy follows: verify `func-shopflow-*-dev` are healthy
4. Approve the production gate manually
5. Prod Deploy completes: verify `func-shopflow-*-prod`

---

## Debugging

| Symptom | Check |
|---|---|
| Bicep validation fails | `az bicep build --file infra/main.bicep` locally |
| PSRule failures | Review rule output; most failures are security/cost recommendations |
| Deployment fails | Check `rg-shopflow-dev` exists; verify bicepparam files have valid values |
| Function deploy fails | Verify app name matches `func-shopflow-*-dev`; check OIDC federation |
| Smoke tests fail | Run `newman run` locally against the deployed Function App URLs |

---

## Security Notes

- **No secrets in YAML** — all credentials come from the `shopflow-credentials` variable group (Key Vault-backed)
- **OIDC federation** — no service principal secrets; the pipeline authenticates using workload identity
- **Managed identities** — deployed Functions use system-assigned managed identities; no keys or connection strings in app settings
- **Pre-deployment approval** — production requires a human reviewer; no automated prod deploys
