# Runbook: Event replay and dead-letter handling

1. Open an incident with a correlation ID and confirm that no PHI is added to the ticket body.
2. Identify source, contract version, event ID, partition/session, timestamp, and failure category from protected telemetry.
3. Stop or throttle only the affected consumer when safe; preserve the original event and DLQ metadata.
4. Fix the contract/processor defect and test against synthetic data. Do not edit production messages manually.
5. Replay a bounded, idempotent event range or resubmit the approved DLQ message through the audited tool.
6. Reconcile resulting state, document any duplicates/compensations, and tune alerting or schema validation.
