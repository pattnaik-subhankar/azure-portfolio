# MediSync — Interview Readiness Pack

## Why Event Hubs and Service Bus together?

Event Hubs is optimized for high-throughput append-only streams, replay, and independent consumer groups. Service Bus provides queues/topics, DLQ, duplicate detection, and sessions for workflows that need ordered handling. I would choose based on delivery semantics and processing behavior, not use Event Hubs as a universal queue.

## How do you avoid duplicate patient-event processing?

Producers include a stable event ID and correlation ID. The processor writes an idempotency record keyed by event ID before applying side effects, uses Service Bus duplicate detection where applicable, and makes downstream writes/upserts idempotent. Retries are safe only when the entire chain has defined idempotency.

## What is the Cosmos DB partition strategy?

Start from access patterns and distribution. A patient ID can support patient-centric queries but risks hot partitions for high-activity patients; an encounter or tenant-plus-time bucket can distribute load but complicate reads. I measure cardinality, item size, RU profile, and query paths before choosing. The portfolio deliberately documents the decision rather than inventing one universal key.

## Explain Geo-DR versus data replication for Event Hubs.

Geo-DR provides an alias and replicates namespace metadata; it is not a replica of the event stream. Recovery needs documented producer failover, consumer checkpoint/replay behavior, retention strategy, and acceptable data-loss window.

## What does “HIPAA-informed” mean here?

The design applies common safeguards—minimum necessary access, encryption, audit, private networking, retention, and incident response—but does not claim compliance. Compliance depends on the organization, contracts, policies, evidence, region, operations, and formal assessment.
