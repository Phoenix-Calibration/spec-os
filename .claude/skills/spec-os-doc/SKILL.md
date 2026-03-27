---
name: spec-os-doc
description: Update user-facing documentation after a User Story passes verification. Use this skill when /spec-os-verify routes to doc update (any task in the US has doc-impact true), or when the developer runs /spec-os-doc manually. Updates docs/manual/{domain}.md based on spec.md and tracker US.
---

# /spec-os-doc

## Goal

Update `docs/manual/{domain}.md` to reflect the new or changed behavior documented in a verified User Story. Only invoked when at least one task in the US has `doc-impact: true`.

## Syntax

```
/spec-os-doc [feature-id] [us-id]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | e.g. `F042` — auto-detected from most recent verified US |
| `us-id` | No | e.g. `US-142` — auto-detected if one US was just verified |

---

## Step 0 — Tracker Resolution

Check if `spec-os/tracker/` exists. If yes: read `spec-os/tracker/config.yaml` to get tracker type, then read `spec-os/tracker/{type}.md` and apply the Tracker Resolution block. If `spec-os/tracker/` does not exist, skip tracker operations and continue.
Operations used by this skill: get-us

---

## Step 1 — Locate feature and read context

Find the feature folder. Read:
- `spec.md` — Requirements and Scenarios with `doc-impact` context
- `tasks.md` — identify tasks with `doc-impact: true` and their scope
- `spec-delta.md` — any spec changes since last doc update
- Tracker US — title, AC, description
- `verify-report.md` — last PASS entry (confirms US was verified)

**Guard — verify-report must show PASS:**
```
If latest verify-report entry for this US is not PASS:
  Stop. "US #{id} has not passed /spec-os-verify. Run verify first."
```

---

## Step 2 — Locate manual file

Read domain name from `spec.md` frontmatter. Read `spec-os/specs/_index.md` to validate the domain exists.

Check if `docs/manual/{domain}.md` exists:
- If exists: read it fully
- If not exists: will create it with a standard header

---

## Step 3 — Identify doc-impact scope

From tasks with `doc-impact: true`, determine what changed:
- New feature behavior (new section needed)
- Changed behavior (existing section needs update)
- New API contract or permission change (new note or callout)
- Removed behavior (section to mark deprecated or remove)

Read the relevant Requirements and Scenarios from spec.md to understand the exact behavior to document.

---

## Step 4 — Draft documentation update

Draft the changes to `docs/manual/{domain}.md`:
- Use plain language — this is end-user or integrating-team documentation, not spec language
- No RFC 2119 keywords (`MUST`, `SHOULD`) in the manual — use direct statements
- Include: what the feature does, how to use it, edge cases that users need to know about
- Do not include implementation details or internal architecture

Present to developer:

```
─────────────────────────────────────────────────
Proposed doc update: docs/manual/{domain}.md
─────────────────────────────────────────────────

Section: {section name}
Change:  {new | updated | removed}

{proposed content}

─────────────────────────────────────────────────
Apply? [y / n / edit]
```

Wait for approval. Never write documentation without developer confirmation.

---

## Step 5 — Write documentation

On approval, write the updated `docs/manual/{domain}.md`.

If the file did not exist, create it with header:
```markdown
# {domain} — User Guide

> Last updated: {ISO-date} by /spec-os-doc
> Source: spec-os/changes/{feature}/spec.md

---
```

---

## Step 6 — Report and handoff

```
/spec-os-doc complete.

Updated: docs/manual/{domain}.md
US:      #{id} — {title}
```

`/spec-os-sync` was already invoked by `/spec-os-verify` when the PR was created (Decision 27). No further handoffs are needed from this skill.

---

## Rules

- **Only invoked on doc-impact: true.** Never run this skill for a US where all tasks have `doc-impact: false`. The field exists precisely to avoid unnecessary documentation work.
- **verify-report PASS is a hard prerequisite.** Documenting unverified behavior risks writing incorrect documentation. The guard in Step 1 is non-negotiable.
- **Plain language, not spec language.** The manual is for users and integrating teams — not for spec review. RFC 2119 keywords, Given/When/Then format, and domain model notation do not belong here.
- **Never write without approval.** Step 4 is mandatory. Documentation errors are visible to end users.

---

## Self-improvement

Watch for these signals:

- **Developer edits substantially during Step 4** → the draft quality may be too spec-like. Try to write more conversationally and focus on user actions and outcomes.
- **doc-impact: true is set on almost every task** → the field may be overused. Remind developers in `/spec-os-plan` guidance that `doc-impact` covers only user-observable changes, not all backend work.
- **docs/manual/ files grow unmanaged** → consider adding a `/spec-os-clean` pass on docs/ in a future roadmap cycle.
