# ShopFlow — Scalability & Backpressure Matrix

> Documented per-tier limits and failure modes. This table is a key interview artifact.

## Tier-by-Tier Burst Behavior

| Tier | Service | Burst Mechanism | Limit | Backpressure Signal | Failure Mode |
|------|---------|----------------|-------|---------------------|-------------|
| Edge | Front Door | Anycast routing + edge cache | No hard limit | — | Cascades to APIM |
| API | APIM v2 Standard | Rate-limit policy per subscription key | 50 req/s per key (configurable) | `429 Too Many Requests` to client | Graceful rejection |
| Compute | Functions Premium EP1 | Auto-scale, max 20 instances | 20 instances × 4 cores × ~10 req/s = ~800 req/s | Queue depth increases | Requests wait; p95 rises |
| Messaging | Service Bus Standard | Partitioned queue (16 partitions) | ~1,000 msg/s sustained | Queue length grows | Accepts all; no backpressure to producer |
| Compute | Fulfillment Processor | MaxConcurrentCalls = 16 | ~16 orders/s | DLQ messages on timeout | Slow fulfillment, not lost orders |
| Data | Azure SQL GP (2 vCore) | 200 DTU pool | ~2,500 batch writes/min | DTU >80% alert | Connection pool exhaustion → processor slows |

## Load-Leveling Flow

```
Client burst (2000/min) → APIM (rate-limits excess to 429) → Functions (scales to 20 instances) → Queue (absorbs all) → Processor (drains at ~16/s)
                                                                                     ↓
                                                                    Queue depth = buffer (minutes of orders)
                                                                                     ↓
                                                                    When burst ends, queue drains naturally
```

## Scale-Up Triggers (if organic growth exceeds design)

1. **SQL:** GP → Hyperscale (auto scale-out for reads) → split hot paths to Cosmos DB
2. **Service Bus:** Standard → Premium (dedicated throughput, geo-DR)
3. **APIM:** Standard v2 scale units → Premium v2 (multi-region)
4. **Functions:** EP2 plan → consider AKS for 10+ microservice co-location
