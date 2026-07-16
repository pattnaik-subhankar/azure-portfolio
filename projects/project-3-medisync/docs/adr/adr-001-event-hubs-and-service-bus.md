# ADR-001: Split high-throughput streams from ordered workflows

**Decision:** use Event Hubs for high-rate clinical event streams and Service Bus sessions for ordered workflow commands.

**Rationale:** the services have different delivery and scaling semantics. This avoids forcing queue-like behavior into streaming infrastructure or using costly queue semantics for all event traffic.

**Consequence:** operations must monitor two messaging planes and developers must document event contract, ordering, idempotency, retry, and DLQ behavior for every flow.
