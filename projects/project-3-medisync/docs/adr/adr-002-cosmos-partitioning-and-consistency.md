# ADR-002: Make partitioning and consistency workload decisions

**Status:** Accepted as a decision framework; final values require measured event and query profiles.

**Decision:** store the immutable event envelope separately from derived clinical views. Start evaluation with `tenantId` plus a bounded time/encounter-oriented dimension rather than assuming `patientId` is universally safe. Use session consistency unless a specific read-after-write workflow proves a stronger model is necessary.

**Context:** a patient-only key is convenient for reads but can create hot logical partitions for high-activity patients or batch imports. Strong consistency reduces availability/latency options across regions. Multi-region writes introduce conflict resolution and operational complexity.

**Consequences:** validate RU consumption, partition skew, item size, cross-partition queries, and regional latency using synthetic data. The solution team must document every consumer's ordering and read-after-write requirement before selecting multi-region writes or a stronger consistency level.
