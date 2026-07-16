# Data Design and PHI Boundaries

## Event envelope

Every event uses a versioned envelope with an opaque `eventId`, opaque `correlationId`, producer identity, schema version, event time, routing classification, and payload reference. Logs capture only the opaque identifiers and technical outcome. The payload is never copied into diagnostic logs or tickets.

## Storage responsibilities

| Store | Responsibility | Not used for |
|---|---|---|
| Event Hubs | short-retention, high-rate ingress and replay window | ordered business workflow or permanent system of record |
| Service Bus | commands needing sessions, DLQ, retry and duplicate detection | high-volume analytics stream |
| Cosmos DB | event envelope and derived query view | unrestricted reporting or raw audit archive |
| Azure SQL | curated relational reporting/operational tables | raw variable-shape event ingestion |
| Immutable Blob | controlled audit export/evidence retention | active transactional query path |

## Privacy controls to prove before production

- Synthetic data only in development and automated tests.
- A data dictionary identifies PHI/PII fields, legal basis, retention, owner, and permitted consumers.
- De-identification or tokenization is designed before analytics copies are created.
- Access is granted to groups, time-bound where privileged, and reviewed regularly.
- Deletion, correction, legal-hold, and retention procedures are owned by the healthcare organization and tested against the data architecture.
