---
name: spec-os-sync
description: Sync pending lessons from session-log.md to the project knowledge base.
  Use this skill when /spec-os-verify has created a PR (runs automatically as part of
  that flow), or when the developer runs /spec-os-sync manually to sync lessons from a
  completed User Story. Lesson sync only — no archival.
---

# /spec-os-sync

## Goal

Extract lessons marked `pending: true` from `session-log.md` and write them to `spec-os/specs/knowledge-base.md` with validated tags. Idempotent — safe to run multiple times on the same feature.

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
Knowledge base: spec-os/specs/knowledge-base.md updated
```

---

## Rules

- **Lesson sync only.** Archival of completed features is the responsibility of `/spec-os-clean`. Never move or modify folders in `spec-os/changes/`.
- **Idempotent by design.** The `pending: false` flag prevents double-syncing. Running sync twice on the same feature is safe and produces no duplicates.
- **Domain validation is not optional.** A lesson with an invalid domain tag pollutes the knowledge base filter. The Step 3 validation gate exists to preserve knowledge-base integrity.
- **Runs automatically after PR creation.** This is the only automatic (non-gated) invocation in spec-os. It is safe to automate because sync is idempotent and affects only the knowledge base, not source code or spec artifacts.

---

## Self-improvement

Watch for these signals:

- **Domain tag mismatches occur frequently** → `_index.md` domains may not align with how developers think about lessons. Consider refining domain names in the next `/spec-os-init Update` run.
- **Most lessons are `generalizable: no`** → session-log entries may be written too narrowly. The session-log template's lesson guidance could be improved.
- **knowledge-base grows very fast** → lessons may not be specific enough. `/spec-os-clean` should be run more frequently at release close.
