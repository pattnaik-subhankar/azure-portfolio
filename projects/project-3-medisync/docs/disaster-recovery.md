# Disaster Recovery Plan and Recovery Matrix

The RTO/RPO targets below are design targets pending business-impact analysis, contract obligations, and recovery testing. Recovery is an application-and-data procedure, not simply a portal failover.

| Component | Failure strategy | Target RTO | Target RPO | Validation |
|---|---|---:|---:|---|
| APIM/Functions | Re-deploy approved IaC to paired region; switch approved ingress | 1h | 5m | scripted redeploy and synthetic API test |
| Event Hubs | Fail producer/consumer configuration through approved alias/runbook; replay retained events | 1h | 5m | producer failover and checkpoint/replay test |
| Service Bus | Geo-DR namespace alias and workflow reconciliation | 1h | 5m | session/DLQ reconciliation exercise |
| Cosmos DB | selected single-write failover or multi-region pattern | 1h | 5m | regional failover, consistency and conflict test |
| Azure SQL | failover group/backup restore based on approved SKU | 4h | 15m | restore and application reconciliation |
| Audit Blob | geo-redundant storage and immutability policy validation | 4h | 15m | read/retention evidence test |

## Exercise cadence

Run quarterly tabletop scenarios and at least annual controlled technical exercises. Capture recovery timing, data reconciliation, ownership gaps, and corrective actions. Never exercise with production PHI unless the healthcare organization approves the test plan.
