# Phase 1 — Resume Analysis & Architect Readiness Report

**Candidate:** Subhankar Pattnaik — Senior Azure PaaS Engineer, LTIMindtree (6+ yrs)
**Target roles:** Senior Azure Engineer → Azure Solution Architect → Cloud Architect / Technical Lead

---

## 1. Strongest Technical Skills (defensible in interviews today)

| Tier | Skills | Evidence from resume |
|------|--------|---------------------|
| **S — Deep, daily-driver** | Azure PaaS (APIM, Functions, Logic Apps, Web Apps, Batch), IaC (ARM, Bicep, Terraform), Azure Policy incl. DINE, Azure DevOps CI/CD, PowerShell/CLI | Architected + deployed production PaaS solutions; automated incremental deployments; custom policies for governance |
| **A — Strong, production-proven** | Azure networking (VNet, NSG, DNS, Firewall, Private Endpoints, VPN GW), Entra ID, Azure SQL, Storage (Blob/Table/Files) | Escalation-engineer depth: Sev-A/B networking + DNS + firewall incidents for global Microsoft clients |
| **B — Working knowledge** | AKS/Kubernetes, Docker, hybrid storage (StorSimple, Stack Edge, DataBox), Azure Monitor, ITIL | Troubleshot AKS cluster deployments; managed hybrid storage implementations |

**Hidden differentiator most candidates lack:** Sev-A/B escalation experience with Microsoft Product Group. You've seen how Azure *fails* at enterprise scale — that's architect gold. We will weaponize this in every project narrative ("designed for the failure modes I spent 2.5 years firefighting").

## 2. What recruiters/hiring managers value most (for your target roles)

1. **AZ-305-level design vocabulary** — Well-Architected Framework (WAF) pillars, Cloud Adoption Framework (CAF), landing zones
2. **IaC at scale** — Terraform modules, Bicep, policy-as-code → you already have this, it needs public proof
3. **Zero-trust networking** — hub-spoke, private endpoints, no public ingress → you have the components, need the *design* story
4. **Multi-region HA/DR thinking** — RTO/RPO decisions, active-passive vs active-active
5. **Cost consciousness (FinOps)** — architects who talk cost win offers
6. **Public artifacts** — GitHub, portfolio, diagrams. Right now you have **zero public proof** — this is the single biggest fixable gap.

## 3. Gaps blocking Solution Architect interviews

| Gap | Severity | Fix |
|-----|----------|-----|
| Only AZ-900 certified | 🔴 Critical | AZ-104 → AZ-305 (the SA cert). AZ-104 is ~4-6 wks for you given experience |
| No public portfolio/GitHub | 🔴 Critical | This entire program (Phases 2-4) |
| Resume verbs skew support/escalation, not design ownership | 🟠 High | Reframe + projects give you real design artifacts to point at |
| No messaging/eventing depth on paper (Service Bus, Event Hubs, Event Grid) | 🟠 High | Projects 1 & 3 build this — natural extension of Logic Apps/Functions work |
| No Cosmos DB / data platform story | 🟡 Medium | Project 3 (Healthcare) introduces it in a learnable, honest scope |
| No landing zone / management group / CAF experience | 🟠 High | Project 4 capstone |
| No Key Vault / Defender / Sentinel security narrative | 🟡 Medium | Woven into Projects 2-4 |
| AKS is "troubleshot," not "designed" | 🟡 Medium | Project 4 gives a designed AKS workload |

**What is NOT a gap:** IaC, CI/CD, PaaS depth, networking troubleshooting, governance. These are ahead of most SA candidates. The problem is *proof and framing*, not skill.

## 4. Where practical projects add maximum value

Priority order:
1. **Zero-trust API platform** (private endpoints, APIM internal mode, hub-spoke) — directly monetizes your networking escalation scars
2. **Event-driven integration** (Service Bus/Event Hubs) — fills the biggest technical hole cheaply
3. **Landing zone + policy-as-code at scale** — converts your DINE/custom-policy work into CAF/enterprise vocabulary
4. **Multi-region DR design** — gives you the RTO/RPO conversation every SA interview requires

## 5. Learning Roadmap (parallel to project builds)

| Window | Focus | Output |
|--------|-------|--------|
| Weeks 1-4 | AZ-104 prep (you know ~70% already) + Project 1 build | AZ-104 booked; ShopFlow repo live |
| Weeks 5-8 | WAF + CAF study (MS Learn architecture paths) + Project 2 | PaySecure repo; can whiteboard hub-spoke cold |
| Weeks 9-12 | AZ-305 prep + Project 3 | MediSync repo; Event Hubs/Cosmos working knowledge |
| Weeks 13-16 | AZ-305 exam + Project 4 capstone + portfolio site launch | AZ-305 certified; EdgeForge repo; site live |
| Ongoing | 1 blog post per project (case-study format) | Technical blog section populated |

**Certification path: AZ-104 → AZ-305.** Skip AZ-400 for now (your resume already proves DevOps; AZ-305 changes interview outcomes, AZ-400 doesn't).

## 6. Resume reframing notes (for later revision)

- "Troubleshot and resolved" → keep, but add design-ownership bullets from portfolio projects (clearly labeled as portfolio/lab work — honest, and interviewers respect it)
- Add "Architected zero-trust API platform (portfolio): hub-spoke, private endpoints, APIM internal mode…" style bullets in a **Projects** section
- Fix typo-level issues: award years look odd ("2022, 2026" for three consecutive months) — verify and clean
- Quantify: "reducing manual deployment effort" → add % or hours/week if defensible
