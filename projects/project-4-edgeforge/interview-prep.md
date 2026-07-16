# EdgeForge — Architect Interview Pack

## Explain the landing zone versus workload separation.

The landing zone is the reusable governed platform: management groups, subscriptions, identity, connectivity, policy, logging, and cost controls. The workload is a tenant of that platform. This separation prevents every team from rebuilding guardrails and avoids the platform team becoming the application release bottleneck.

## Why AKS rather than Functions?

For sustained, containerized stream processing that needs explicit consumer scaling, resource isolation, workload identity, and potentially custom libraries, AKS can be justified. I would still quantify operational maturity, event volume, SLOs, and team ownership; Functions is simpler for lower-complexity processors.

## What does KEDA solve?

KEDA converts event-driven signals such as Event Hubs consumer lag into scaling decisions. I still set resource requests/limits, max replicas, partitions, checkpoint behavior, and downstream protections. Scaling consumers beyond partition count does not improve a single consumer group indefinitely.

## How do you secure OT/IT integration?

I preserve the trust boundary: the edge gateway initiates controlled outbound communication, device identities are governed, cloud workloads do not directly control equipment, and OT security approves protocols and remote access. Azure architecture cannot substitute for industrial safety controls.

## What would make you choose vWAN?

I would consider vWAN when the global branch/plant footprint, connectivity diversity, and operational scale justify managed transit. For a smaller controlled footprint, hub-spoke with Firewall and clear routing may be easier to reason about. The decision is cost, scale, skills, and operating model—not a universal best practice.
