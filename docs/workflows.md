# Workflows

Common patterns for working with spec-os. For full skill documentation, see [Skills](skills.md).

## The full feature workflow

The standard path from idea to merged PR:

```
/spec-os-brainstorm
       │  creates origin.md + Feature in tracker
       ▼
/spec-os-design
       │  creates spec.md + empty artifacts
       ▼
/spec-os-plan
       │  creates tasks.md + User Stories in tracker
       ▼
/spec-os-implement T01
       │  executes task → commits
       ▼
/spec-os-implement T02 ... Tn
       │  one session per task
       ▼
/spec-os-verify
       │  quality gate → creates PR
       ▼
/spec-os-doc        ← only if any task has doc-impact: true
       │
       ▼
/spec-os-sync       ← always last
```

Each `→` is a developer confirmation. Nothing advances silently.

---

## New feature

**When:** you have an idea, a requirement from a stakeholder, or a feature request from the tracker.

```text
You: /spec-os-brainstorm

AI:  What idea would you like to analyze?

You: We need to track equipment calibration expiry dates and alert
     maintenance teams 30 days before expiry.

AI:  Real problem: maintenance teams miss calibration deadlines because
     there is no proactive notification — they discover issues reactively
     during audits.

     Proposed solution: calibration expiry tracking per equipment, with
     configurable alert thresholds and notification routing by equipment type.

     Classification: Feature | Complexity: medium

     Searching ADO... not found.
     Create Feature "Calibration expiry tracking and alerts"? [y/n]

You: y

AI:  Feature F051 created.
     Created: spec-os/changes/F051-S25-calibration-alerts/origin.md
     Run /spec-os-design to continue.
```

From here follow the full chain above.

---

## Bug fix

**When:** a bug is reported in your tracker.

### Simple path (most bugs)

```text
You: /spec-os-bug 1847

AI:  Reading bug #1847: "Null reference on equipment export when no results"
     Root cause: ExportHandler doesn't guard against empty result set.
     Scope: single file — EquipmentExportHandler.cs
     Estimated fix: < 30 minutes
     Classification: SIMPLE

     Created: spec-os/changes/B1847-equipment-export-null/
       spec.md   (bug context + expected behavior)
       tasks.md  (T01: add null guard)

     Ready to implement?
     Run /spec-os-implement T01.
```

### Complex path

```text
You: /spec-os-bug 1902

AI:  Reading bug #1902: "Equipment readings show stale data after status change"
     Root causes: multiple (cache invalidation + event ordering race condition)
     Cross-layer: cache, domain events, read model
     Classification: COMPLEX

     Created: spec-os/changes/B1902-stale-readings/analysis.md
     Review analysis.md, then run /spec-os-design to write the spec.
```

---

## Cross-repo initiative

**When:** a business requirement affects multiple applications.

This workflow requires `/spec-os-explore` installed as a personal skill in Claude Desktop (`~/.claude/skills/spec-os-explore/`).

```text
[In Claude Desktop]
You: /spec-os-explore

AI:  What initiative would you like to analyze?

You: We need to migrate equipment data from the legacy ERP to the new portal
     and keep both in sync during the transition period.

AI:  Analyzing repos: erp, portal, shared-services...

     Systems affected: erp (source) → shared-services (sync) → portal (target)
     Suggested order: erp → shared-services → portal

     Create Epic in ADO for this initiative? [y/n]

You: y

AI:  Created Epic E12: "Equipment data migration"

     Generated:
     20260322-1430-initiative-equipment-migration.md
     20260322-1430-initiative-equipment-migration-erp.md
     20260322-1430-initiative-equipment-migration-shared-services.md
     20260322-1430-initiative-equipment-migration-portal.md

     Next: open each repo and run /spec-os-brainstorm with the corresponding file.
```

Then in each project repo:

```text
[In erp repo]
You: /spec-os-brainstorm 20260322-1430-initiative-equipment-migration-erp.md

AI:  Reading initiative context for erp...
     [deep per-project analysis]
     Created Feature F088 (under Epic E12).
     Created: spec-os/changes/F088-S25-equipment-migration-erp/origin.md
```

---

## Resuming an interrupted session

**When:** a session was cut short mid-task.

Just re-invoke the same task:

```text
You: /spec-os-implement T03

AI:  T03 status: in-progress (claimed by: ivan)
     Loading previous session context...
     Last known state: created NotificationSubscription entity,
                       DI registration pending.
     Continuing from last known state.
```

spec-os detects the `in-progress` status, loads the previous session-log entry for that task, and continues from where it stopped.

---

## Handling a spec change during implementation

**When:** implementation reveals something not captured in the spec.

`/spec-os-implement` checks for this automatically during RECONCILE after each task. You don't need to invoke anything manually:

```text
AI:  [after executing T04]

     Reconciling spec...
     Discovery: equipment cannot receive notifications while in 'decommissioned' state.
     This constraint is not in spec.md.

     Propose spec update?
     ADDED: "Equipment MUST NOT receive notifications when status is decommissioned."
     Approve? [y/n]

You: y

AI:  Updated spec.md and wrote spec-delta.md entry.
     Tasks affected: T05 (add status guard in dispatcher)
     Propose tasks.md update for T05? [y/n]

You: y

AI:  Updated T05 scope. Proceeding.
```

---

## Adding a new domain mid-project

**When:** the project grows into a new area not declared at init time.

```text
You: /spec-os-init update

AI:  Installed version: 1.0.0
     Current domains: equipment, maintenance, reporting, users

     New domains to add:

You: integrations

AI:  Created:
     spec-os/specs/integrations/spec.md  (stub)
     Updated: spec-os/specs/_index.md
```

---

## Updating a standard

**When:** the team agrees on a new convention or existing one needs updating.

```text
You: /spec-os-standard backend/error-handling

AI:  Reading current spec-os/standards/backend/error-handling.md...

     Proposed update:
     ADD: "Domain exceptions MUST extend DomainException base class.
           Infrastructure exceptions MUST NOT propagate to domain layer."
     Approve? [y/n]

You: y

AI:  Updated error-handling.md. index.yml keywords unchanged.
```

---

## Abandoning a feature

**When:** a feature is cancelled or deprioritized before completion.

```text
You: /spec-os-abandon F042

AI:  Abandonment reason?

You: Cancelled by PO — requirements changed, will be re-evaluated next quarter.

AI:  Updated spec.md status → abandoned.
     Updated ADO Feature F042 → Cancelled.
     Folder remains in spec-os/changes/ — run /spec-os-clean at release close to archive.

     Note: /spec-os-sync was not run — no lessons were synced.
```

---

## Decision table: which skill to start with?

| Situation | Start with |
|-----------|------------|
| New idea or requirement | `/spec-os-brainstorm` |
| Bug reported in tracker | `/spec-os-bug {id}` |
| Initiative spanning multiple repos | `/spec-os-explore` (Claude Desktop) |
| New project setup | `/spec-os-product` then `/spec-os-init` |
| Existing project, no spec-os yet | `/spec-os-init` (Adopt mode) |
| Adding new domains | `/spec-os-init update` |
| Standards are stale or missing | `/spec-os-discover` |
| Knowledge base has outdated entries | `/spec-os-clean` |

---

## Next Steps

- [Getting Started](getting-started.md) — install and first walkthrough
- [Concepts](concepts.md) — architecture and key ideas
- [Skills](skills.md) — full reference for every skill
