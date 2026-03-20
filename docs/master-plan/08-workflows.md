# Spec-OS: Workflows

User-facing guide. For skill internals, see [05-skills-chain.md](05-skills-chain.md). For skill syntax and arguments, see [06-skills-reference.md](06-skills-reference.md).

---

## Philosophy: Explicit Gates, Traceable Decisions

Spec-os does not progress automatically between skills. Every skill-to-skill transition is an explicit handoff that pauses and waits for developer confirmation. This is intentional.

```text
Traditional (automatic):

  plan ──────────────► implement ──────────────► done
                           │
                   "AI decided to continue"

Spec-OS (explicit gates):

  brainstorm ──[dev ok?]──► create ──[dev ok?]──► plan ──[dev ok?]──► implement ...
```

**What this means in practice:**

- No skill invokes the next one silently. You always know what is about to happen.
- Every spec change during implementation is proposed, not applied. You approve before anything is written.
- The quality gate (verify → doc → sync) runs as a block only after you confirm each step.
- If something doesn't look right, you can stop at any gate without orphaned state.

Experienced developers can set `skill-handoffs: auto` in `spec-os/config.yaml` to reduce confirmation prompts. The default for v1 is `explicit`.

---

## Entry Points

There are three ways to start a session. Pick based on what you have:

| Situation | Entry point |
|-----------|-------------|
| New idea, requirement, or business request | `/spec-os-brainstorm` |
| Bug reported in tracker (ADO issue, GitHub issue) | `/spec-os-bug [id]` |
| Setting up spec-os in a project | `/spec-os-init` |

All other skills (`/spec-os-create`, `/spec-os-plan`, `/spec-os-implement`, etc.) are reached via handoffs from these entry points — or invoked directly if you are continuing a session that was interrupted.

---

## Workflow Patterns

### Standard Feature

The most common path. You have an idea or a business requirement and need to take it from concept to merged PR.

```text
/spec-os-brainstorm
    └──[dev ok?]──► /spec-os-create
                        └──[dev ok?]──► /spec-os-plan
                                            └──[dev ok?]──► /spec-os-implement T01
                                                                └── T02, T03... (one session each)
                                                                    └──[US done]──► /spec-os-verify
                                                                                        └── PASS ──► /spec-os-doc (if ux-impact)
                                                                                                         └──► /spec-os-sync
```

**Example session:**

```text
You: /spec-os-brainstorm

AI:  What idea or requirement would you like to analyze?

You: We need email notifications when equipment status changes.

AI:  Analyzing...
     Reading tracker context (ADO)...

     Real problem: Operations team discovers equipment issues reactively,
     after delays. No visibility into status transitions.

     Proposed solution: Event-driven email notifications on status change,
     configurable per equipment type and recipient role.

     Classification: Feature | Effort: 5 SP

     Created: spec-os/changes/F042-S24-equipment-notifications/origin.md

     Ready to create the technical spec?
     Run /spec-os-create to continue.

You: /spec-os-create

AI:  Reading origin.md...
     Reading Feature F042 from ADO...
     Reading docs/design/03-equipment-domain.md...

     Domain: equipos — found in _index.md. OK.
     No conflicts in changes/. OK.

     Creating spec...
     Created spec.md, spec-delta.md, session-log.md, verify-report.md

     Ready to plan?
     Run /spec-os-plan to decompose into User Stories.

You: /spec-os-plan

AI:  Reading spec.md...

     US-1: As an operator, receive email when equipment status changes
           SP: 5 | Tasks: T01-T03

     US-2: As an admin, configure notification subscriptions per role
           SP: 3 | Tasks: T04-T05

     Created US-142, US-143 in ADO.
     Generated tasks.md.

     Ready to implement?
     Starting with T01 — run /spec-os-implement T01

You: /spec-os-implement T01

AI:  T01: Implement NotificationDispatcher service
     claimed-by: ivan | Context: Tier 2 | Subagent: backend-dev

     Loading standards: dotnet, domain-events, email...

     Identified specialist: backend-dev. Confirm? [y/n]

You: y

AI:  [Creates NotificationDispatcher.cs, DI registration, unit tests]

     Reconciling spec... No changes detected.
     Committing: "feat(equipos): add NotificationDispatcher service [F042-T01]"

     T01 done. Next: T02 — Create email template renderer
     Run /spec-os-implement T02
```

**Best for:** Features with clear requirements, tracker-backed, needing full spec and plan lifecycle.

---

### Bug Fix — Simple Path

Bug with a clear root cause and narrow scope. Spec-os creates the minimal folder and routes directly to implement.

```text
/spec-os-bug [id]
    └── SIMPLE ──► creates B{ID}-{name}/spec.md + tasks.md (T01 only)
                        └──[dev ok?]──► /spec-os-implement T01
                                            └──[US done]──► /spec-os-verify
                                                                └── PASS ──► /spec-os-sync
```

Note: `/spec-os-doc` is skipped on bug fixes (no `ux-impact` by default).

**Example session:**

```text
You: /spec-os-bug 1847

AI:  Reading bug #1847: "Null reference on equipment export when no results"

     Root cause: Export handler doesn't guard against empty result set.
     Scope: Single file — EquipmentExportHandler.cs
     Estimated fix: 30 minutes

     Classification: SIMPLE

     Created: spec-os/changes/B1847-equipment-export-null/
       spec.md  (bug context + expected behavior)
       tasks.md (T01: add null guard in EquipmentExportHandler)

     Ready to implement?
     Run /spec-os-implement T01

You: /spec-os-implement T01

AI:  [Adds null guard, updates unit test]

     Committing: "fix(equipos): guard against empty result in export [B1847-T01]"

     US complete. Run /spec-os-verify to close this bug.
```

**Best for:** Bugs with clear root cause, single-file scope, fix under 2 hours.

---

### Bug Fix — Complex Path

Bug that requires design decisions, touches multiple layers, or reveals a gap in the domain model.

```text
/spec-os-bug [id]
    └── COMPLEX ──► creates analysis.md
                        └── dev reviews
                            └──► /spec-os-create (manual)
                                     └──► /spec-os-plan
                                              └──► /spec-os-implement (full path)
```

**Example session:**

```text
You: /spec-os-bug 1901

AI:  Reading bug #1901: "Equipment calibration status not reflected in reports"

     Investigation:
     - Report query bypasses domain model, reads status directly from DB
     - Calibration-pending state introduced in F038 but report not updated
     - Fix requires: updating query + possibly adding state to domain spec

     Multiple root causes, cross-layer impact, design decision required.

     Classification: COMPLEX

     Created: spec-os/changes/B1901-calibration-report-sync/analysis.md

     Review analysis.md and run /spec-os-create when ready to spec the fix.
```

**Best for:** Bugs that reveal architectural gaps, require domain model changes, or touch 3+ files across layers.

---

### Interrupted Session — Resume Mode

Session was cut short mid-task. The task is `status: in-progress` in tasks.md. Just re-invoke implement with the same task ID.

```text
/spec-os-implement T02   ← same task ID as before
    └── INIT detects status: in-progress
        └── loads session-log.md entry for T02 as additional context
            └── continues from last known state
```

**Example session:**

```text
You: /spec-os-implement T02

AI:  T02: Create email template renderer
     Status: in-progress — resuming previous session.

     Loading session-log entry for T02...
     Last state: EmailTemplateRenderer.cs created, Razor template pending.

     Continuing from: implement Razor template for status-change email.
```

No special command. No lost context. Re-invoke the same task, spec-os picks up where it left.

---

### Parallel Developers

Two developers working on the same feature simultaneously. Spec-os uses the `claimed-by` field to prevent collisions.

```text
Developer A:                          Developer B:
/spec-os-implement T01 ──► claimed    /spec-os-implement T02 ──► claimed
    └── works on T01                      └── works on T02 (different task)

If B tries T01:
/spec-os-implement T01
    └── INIT: claimed-by: ivan — STOP
        "T01 is claimed by ivan. Check tasks.md before proceeding."
```

**Convention:** Always check `tasks.md` before starting a task in a shared feature. The `claimed-by` field is the source of truth.

`session-log.md` auto-merges concurrent writes because each task has a unique section header (`## T{NN}`). Git resolves parallel appends cleanly.

---

### Spec Evolves During Implementation — RECONCILE

Sometimes implementation reveals that the spec is incomplete or wrong. Spec-os handles this explicitly via the RECONCILE step after each task execution.

```text
/spec-os-implement T02
    └── EXECUTE: backend-dev subagent
        └── RECONCILE:
              check 1: git diff -- spec.md
                  └── if changed: propose /spec-os-create Update [dev approves]
              check 2: "Did implementation reveal anything undocumented?"
                  └── if yes: propose /spec-os-create Update [dev approves]
                      └── if tasks affected: propose /spec-os-plan Update [dev approves]
```

**Example session:**

```text
AI:  [Executes T02]

     Reconciling spec...
     Reasoning check: Implementation revealed that equipment in
     'calibration-pending' state must block notification dispatch.
     This business rule is not in spec.md.

     Proposed spec addition:
     "Equipment in calibration-pending state: notifications suppressed
     until state resolves. Reason: discovered during T02 implementation."

     Update spec.md with this delta? [y/n]

You: y

AI:  Updated spec.md.
     Written delta entry in spec-delta.md.

     Tasks affected: T03 (add suppression check in dispatcher).
     Update tasks.md scope for T03? [y/n]

You: y

AI:  Updated T03 scope.
     Committing T02: "feat(equipos): email template renderer [F042-T02]"
```

The spec evolves. The delta is recorded. Tasks are adjusted. Nothing happens silently.

---

## US Completion Block

When all tasks of a User Story are done, spec-os runs a fixed sequence. Each step requires dev confirmation.

```text
All tasks done
    └──[dev ok?]──► /spec-os-verify
                        ├── PASS ──► creates PR + updates tracker to in-review
                        │               └──[dev ok?]──► /spec-os-doc   (only if ux-impact: true)
                        │                                    └──[dev ok?]──► /spec-os-sync
                        └── FAIL ──► /spec-os-sync does NOT run
                                         └──[dev ok?]──► /spec-os-implement (fix tasks)
```

**Why this order matters:**

- `/spec-os-sync` never runs after a FAIL — you don't sync lessons from a US that didn't pass the quality gate
- `/spec-os-doc` only runs if at least one task in the US has `ux-impact: true`
- `/spec-os-sync` is always last — it is the archival checkpoint

---

## When to Update vs Start a New Feature

A common question: when does new work go into the existing feature folder, and when should it be a new `/spec-os-brainstorm`?

**Update the existing feature (via RECONCILE or spec-create Update mode) when:**

- Same intent, refined execution
- Implementation revealed a gap in the current spec
- Scope narrows for MVP — the rest comes later in this same feature
- Business rule clarified by PO during implementation

**Start a new feature when:**

- Intent fundamentally changed — different problem being solved
- Scope expanded into clearly separate functionality
- The current US can be marked done independently
- The new work would make the current spec misleading

```text
"Add notification for calibration-pending too" during F042:
    → same domain, same feature, discovered during implementation
    → RECONCILE: update spec + tasks

"Build a full notification preferences center for users":
    → separate product decision, different US owner, different scope
    → /spec-os-brainstorm → new feature folder
```

---

## Best Practices

### One task per session

`/spec-os-implement` is designed for one task. One commit, one session-log entry, one specialist subagent. If a task feels too large, stop — return to `/spec-os-plan` and split it.

### Read tasks.md before claiming

In shared features, check `claimed-by` before starting any task. Collision detection stops you, but it's cleaner to avoid it.

### Check verify-report.md after FAIL

`/spec-os-verify` writes a persistent `verify-report.md` in the feature folder. If a FAIL is complex, read the report before re-invoking implement — it has the diagnosis.

### Run `/spec-os-discover` when standards feel stale

Standards in `spec-os/standards/` are only as current as the codebase. After major refactors, run `/spec-os-discover` to surface what the current codebase actually does.

### Use `/spec-os-abandon` — don't delete manually

If a feature is cancelled, run `/spec-os-abandon`. It updates tracker status, moves the folder to `changes/archive/`, and preserves `origin.md` for historical context. Deleting the folder manually leaves orphaned tracker items.

---

## Quick Reference

| Situation | Skill |
|-----------|-------|
| New idea or requirement | `/spec-os-brainstorm` |
| Bug from tracker | `/spec-os-bug [id]` |
| Set up spec-os | `/spec-os-init` |
| Create spec from origin.md | `/spec-os-create` |
| Decompose spec into tasks | `/spec-os-plan` |
| Implement one task | `/spec-os-implement [task-id]` |
| Resume interrupted task | `/spec-os-implement [same task-id]` |
| Quality gate for a US | `/spec-os-verify` |
| Update user docs | `/spec-os-doc` |
| Sync lessons to knowledge-base | `/spec-os-sync` |
| Cancel a feature cleanly | `/spec-os-abandon` |
| Extract standards from codebase | `/spec-os-discover` |
| Evolve an existing standard | `/spec-os-standard` |
| Clean stale knowledge-base entries | `/spec-os-prune` |
