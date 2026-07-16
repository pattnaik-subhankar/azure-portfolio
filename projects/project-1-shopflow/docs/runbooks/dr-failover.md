# ShopFlow — DR Failover Runbook

**RTO:** 4 hours · **RPO:** 15 minutes
**Platform:** Bicep IaC (environment redeployment) + SQL failover group

## Decision Matrix

| Failure Scope | Action | RTO |
|--------------|--------|-----|
| Single component (Function app, APIM) | Redeploy from pipeline | <30 min |
| SQL primary region outage | Failover group auto-switches | <1 min |
| Full region outage (Central India) | Deploy Bicep to DR region (South India) via pipeline | <2h |
| Service Bus region loss | In-flight messages lost; intake returns 503 → clients retry | Immediate mitigation |

## Step-by-Step: Full Region Failover

### 1. Assess (0–5 min)
```bash
# Check Azure Service Health for Central India
az monitor activity-log list --resource-provider "Microsoft.Compute" \
  --max-events 5 --query "[?eventTimeStamp > '2026-07-16T00:00:00']"
```
Confirm: widespread outage vs isolated component.

### 2. SQL Failover (if not auto-failed)
```bash
az sql failover-group update \
  -g rg-shopflow-prod \
  --server sql-shopflow-prod-<hash> \
  -n fg-shopflow-prod \
  --failover-type Manual
```

### 3. Redeploy IaC to DR Region
```bash
# Update pipeline variable or run manually:
az deployment group create \
  -g rg-shopflow-prod-dr \
  -f infra/main.bicep \
  -p @infra/main.prod-dr.bicepparam \
  --target-region southindia
```

### 4. Update Front Door Origin
```bash
az afd origin update \
  --profile-name afd-shopflow-prod \
  --origin-group-name og-apim-prod \
  --origin-name apim-dr-origin \
  --host-name apim-shopflow-prod-dr.<hash>.azure-api.net
```

### 5. Verify
- Synthetic order submission test
- Monitor queue drain rate
- Confirm DLQ empty
- Check partner webhook delivery

### 6. Failback (post-outage)
1. Deploy to primary region
2. Verify in isolation
3. Swap Front Door origin back
4. Monitor for duplicate/late messages

## Known Gaps
- Service Bus Standard: in-flight messages region-local → accepted risk; upgrade path = Premium geo-DR
- Logic App Standard: stateful runs lost during region failover → use persistent storage checkpoints for critical workflows
