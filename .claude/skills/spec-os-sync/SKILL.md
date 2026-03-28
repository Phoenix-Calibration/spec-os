---
name: spec-os-sync
description: Sync pending lessons from session-log.md to the knowledge base and update
  the domain spec with completed feature behavior. Runs automatically after PR creation.
  Also available manually after a completed User Story. No archival.
---

# /spec-os-sync

## Goal

Extract lessons marked `pending: true` from `session-log.md`, write them to `spec-os/specs/knowledge-base.md` with validated tags, and update `spec-os/specs/{domain}/spec.md` to reflect completed feature behavior. Idempotent — safe to run multiple times on the same feature.

## Syntax

```
/spec-os-sync [feature-id] [us-id]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | e.g. `F042` — auto-detected from most recent completed US |
| `us-id` | No | e.g. `US-142` — if omitted, syncs all pending lessons in the feature |

---

## Step 1 — Locate feature and read session log

Find the feature folder in `spec-os/changes/`. Read `session-log.md`.

Collect all lesson entries where `pending: true`. If none found:

```
/spec-os-sync: No pending lessons found for {feature-id}. Nothing to sync.
```

Stop — no work needed.

---

## Step 2 — Filter generalizable lessons

From the collected entries, keep only lessons marked `generalizable: yes`. Skip lessons marked `generalizable: no` — they are task-specific notes, not institutional knowledge.

If all lessons are `generalizable: no`:

```
/spec-os-sync: All pending lessons are task-specific (generalizable: no). Nothing to write to knowledge base.
```

Mark all `pending: true` entries as `pending: false` in session-log.md (they were reviewed — outcome is "not applicable"). Stop.

---

## Step 3 — Validate domain tags

Read `spec-os/specs/_index.md`. For each generalizable lesson, extract or infer the `domain` tag.

For each lesson:
- If domain tag matches an entry in `_index.md` → valid
- If domain tag does not match:
  ```
  Warning: lesson "{title}" has domain tag "{domain}" which is not in _index.md.
  Available domains: {list}
  Assign correct domain? [pick one / skip this lesson]
  ```
  Wait for developer input before writing.

---

## Step 3.5 — Domain spec update

Read in parallel:
- Feature `spec.md` — Requirements and Domain model sections
- Feature `spec-delta.md` — all entries
- `spec-os/specs/{domain}/spec.md` — current domain state

Identify behavioral changes completed in this US that are not yet reflected in the
domain spec:
- New entities or entity states
- New or modified behaviors/transitions
- Behaviors removed or superseded

If no domain-level changes detected → skip to Step 4.

**Classify the change:**

**Additive** (new scenarios, new entity states, new behaviors appended to existing
domain model — no structural reorganization): draft update directly from spec.md
and spec-delta.md content.

**Structural** (new entities, modified domain model shape, cross-domain implications,
or significant reorganization of existing behaviors):
```
US #{id} introduces structural changes to the {domain} domain.
Invoke architect to review domain spec impact before updating? [y/n]
```
If `y`: invoke `.claude/agents/architect` via Agent tool with:
- Current `spec-os/specs/{domain}/spec.md`
- Feature `spec.md` (Requirements + Domain model sections)
- `spec-delta.md` entries for this US
- `docs/design/00-overview.md` and `docs/design/05-data-model.md` (if exist)
- Instruction: propose targeted updates to the domain spec reflecting the
  completed feature behavior. Minimal change — only what the US added or modified.
  Return proposal only — do not write files.

Use architect proposal as the update draft.

**Present proposed update to developer:**
```
─────────────────────────────────────────────────
Proposed update: spec-os/specs/{domain}/spec.md
─────────────────────────────────────────────────
{targeted diff — ADDED / MODIFIED / REMOVED sections}
─────────────────────────────────────────────────
Apply? [y / n / edit]
```

On approval: write updated `spec-os/specs/{domain}/spec.md`.
On `n`: log as skipped in sync report — domain spec not updated for this US.

---

## Step 4 — Write to knowledge base

Read `spec-os/specs/knowledge-base.md`. If the file does not exist, create it with the header before writing:

```markdown
# Knowledge Base — spec-os/specs/knowledge-base.md

Lessons captured from feature sessions. Tagged by stack, domain, layer, and type.
```

For each validated lesson, append a new entry using the knowledge-base entry format:

```markdown
### {lesson title}
- stack: {stack from spec.md frontmatter}
- domain: {validated domain}
- layer: {domain | application | infrastructure | presentation | global}
- type: {pattern | gotcha | anti-pattern | performance | security}
- source: {feature-id}
- date: {ISO-date}

{lesson content — 2-10 lines, generalizable insight only}
```

Write the updated knowledge-base.md.

---

## Step 5 — Mark lessons as synced

In `session-log.md`, update all synced lesson entries: `pending: false`.

This makes the operation idempotent — re-running sync on the same feature will find no pending lessons and exit at Step 1.

---

## Step 6 — Report

```
/spec-os-sync complete.

Lessons synced: {N}
Lessons skipped (not generalizable): {N}
Knowledge base:  spec-os/specs/knowledge-base.md updated
Domain spec:     spec-os/specs/{domain}/spec.md {updated | skipped — no domain changes | skipped — developer declined}

Tip: run /spec-os-audit {feature-id} to capture framework quality signals
from this feature and contribute improvements back to spec-os.
```

---

## Rules

- **Lesson sync + domain spec update.** Archival of completed features is the responsibility of `/spec-os-clean`. Never move or modify folders in `spec-os/changes/`.
- **Idempotent by design.** The `pending: false` flag prevents double-syncing. Running sync twice on the same feature is safe and produces no duplicates.
- **Domain validation is not optional.** A lesson with an invalid domain tag pollutes the knowledge base filter. The Step 3 validation gate exists to preserve knowledge-base integrity.
- **Runs automatically after PR creation.** This is the only automatic (non-gated) invocation in spec-os. It is safe to automate because sync is idempotent and affects only the knowledge base, not source code or spec artifacts.

---

## Self-improvement

Watch for these signals:

- **Domain tag mismatches occur frequently** → `_index.md` domains may not align with how developers think about lessons. Consider refining domain names in the next `/spec-os-init Update` run.
- **Most lessons are `generalizable: no`** → session-log entries may be written too narrowly. The session-log template's lesson guidance could be improved.
- **knowledge-base grows very fast** → lessons may not be specific enough. `/spec-os-clean` should be run more frequently at release close.
