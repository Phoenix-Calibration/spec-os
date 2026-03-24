---
name: spec-os-abandon
description: Close a feature or bug without completing it. Use this skill when the
  developer runs /spec-os-abandon, wants to cancel a feature that is in-progress or
  planned, or needs to formally close a partially-implemented change. Updates tracker,
  releases claimed tasks, and marks the feature folder as abandoned.
---

# /spec-os-abandon

## Goal

Formally close a feature that will not be completed — marking all artifacts as abandoned, releasing any claimed tasks, updating the tracker, and preserving the work done (if any) as a session-log record for future reference.

## Syntax

```
/spec-os-abandon [feature-id] [reason]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | e.g. `F042` — auto-detected if one in-progress feature is unambiguous |
| `reason` | No | One-line reason — prompted interactively if not provided |

---

## Step 1 — Tracker Resolution

Read `.claude/shared/tracker-adapter.md` and apply the Tracker Resolution block.
Operations used by this skill: get-feature, update-status

---

## Step 2 — Locate feature and assess state

Find the feature folder in `spec-os/changes/`. Read `spec.md` and `tasks.md`.

Report current state to developer:

```
─────────────────────────────────────────────────
Feature: {feature-id} — {title}
Status:  {spec.md status field}

Tasks:
  Planned:     {N}
  In-progress: {N} (claimed by: {dev names})
  Done:        {N}
  Total:       {N}

Lessons pending sync: {N}
─────────────────────────────────────────────────
```

If no tasks are in-progress and no work was done (all `planned`): simpler path — just mark as abandoned.

If tasks were started or completed: ask for reason (if not already provided):

```
Reason for abandoning this feature?
(This will be recorded in the tracker and session-log.)
> _
```

---

## Step 3 — Confirm abandonment

```
─────────────────────────────────────────────────
This will:
  - Set spec.md status → abandoned
  - Release all claimed-by fields
  - Update tracker Feature → Closed/Cancelled
  - Write abandon record to session-log.md
  - Sync any pending lessons (if work was done)

Work done so far will be preserved in the feature folder.
It will NOT be deleted or archived here.
(Use /spec-os-clean at release close to archive if desired.)

Confirm abandonment of {feature-id}? [y / n]
─────────────────────────────────────────────────
```

Wait for confirmation. This is a destructive workflow change — the gate is mandatory.

---

## Step 4 — Release claimed tasks

For each task with `status: in-progress` or `claimed-by` set:
- Set `claimed-by: —`
- Set `status: planned` (revert — the task was not completed)

Update `tasks.md`.

---

## Step 5 — Sync pending lessons (if any work was done)

If `session-log.md` has entries (some work was done):
```
There are {N} pending lessons from completed tasks. Sync them before abandoning?
[y / n]
```

On `y`: invoke `/spec-os-sync` for this feature. Lessons from partial work may still be valuable to the knowledge base.

On `n`: mark all pending lessons as `pending: false` with a note: `abandoned — not synced`.

---

## Step 6 — Update artifacts

**spec.md:** Set `status: abandoned`. Add frontmatter field `abandoned-date: {ISO-date}`.

**tasks.md:** Set `status: abandoned`. Add `abandoned-date: {ISO-date}`.

**session-log.md:** Append abandon record:

```markdown
## ABANDONED — {ISO-date}

Reason: {developer-provided reason}
Tasks completed before abandonment: {N}/{total}
Lessons synced: {yes | no — pending discarded}
```

**Tracker User Stories:** ADO does not cascade cancellations automatically. Iterate over all US IDs in the Progress table of `tasks.md` and update each one individually:
```
For each US-id in tasks.md Progress table:
  update-status tracker US {US-id} → Cancelled
  add-comment tracker US {US-id}: "Cancelled — feature {feature-id} abandoned. Reason: {reason}"
```

**Tracker Feature:** Update status to `Closed` (ADO) or `closed` with label `abandoned` (GitHub). Add comment: `Abandoned — {reason}. Partial work in spec-os/changes/{folder}/`.

---

## Step 7 — Report

```
/spec-os-abandon complete.

Feature {feature-id} — {title} is now abandoned.

Artifacts:
  spec-os/changes/{folder}/spec.md     → status: abandoned
  spec-os/changes/{folder}/tasks.md    → status: abandoned
  Tracker: {Feature-ID} → Closed

The folder is preserved. Run /spec-os-clean at release close
to archive it if desired.
```

---

## Rules

- **Confirmation gate is mandatory.** Abandonment cannot be undone easily (tracker state changes are visible to the team). The Step 3 gate is non-negotiable.
- **Preserve, don't delete.** The feature folder stays in `spec-os/changes/`. Deletion or archival is `/spec-os-clean`'s responsibility at release close.
- **Release claimed tasks.** A claimed task with no active session blocks other developers from picking it up. Step 4 always runs.
- **Lessons are not lost.** Even from abandoned features, generalizable lessons belong in the knowledge base. The sync offer in Step 5 exists for this reason.

---

## Self-improvement

Watch for these signals:

- **Features are abandoned frequently at the same stage** → that stage may have friction. Suggest investigating the upstream skill (e.g., if most abandonments happen after `/spec-os-design`, the spec may be too heavyweight for the feature complexity).
- **Abandon reason is always "deprioritized"** → features may be entering the pipeline too early. Consider suggesting a longer brainstorm/design phase before committing.
