# Runbook: Private endpoint DNS triage

1. Capture the caller, target FQDN, resolved IP, UTC time, correlation ID, and subscription/VNet.
2. From the caller's network context, resolve the service FQDN. Expected result is the private endpoint address, not a public address.
3. Verify the required `privatelink` Private DNS zone, VNet link, private endpoint zone group, and hybrid DNS forwarder path.
4. Confirm UDR/firewall rules only after DNS resolution is correct; do not open broad egress as a workaround.
5. Validate TLS SNI/hostname against the service FQDN, inspect APIM/backend logs, and record the root cause.
6. Add a post-deployment DNS smoke test to prevent recurrence.
