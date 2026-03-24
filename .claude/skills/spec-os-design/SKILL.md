---
name: spec-os-design
description: Write the technical spec for a feature from origin.md. Use this skill when the developer runs /spec-os-design, is ready to turn a brainstormed idea into a formal specification, or when /spec-os-implement triggers Update mode during RECONCILE to record spec changes discovered during implementation.
---

# /spec-os-design

## Goal

Transform `origin.md` into a formal `spec.md` — the observable behavior contract that drives implementation. Preserve all strategic reasoning from `origin.md` unchanged.

## Syntax

```
/spec-os-design [feature-id] [update]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | e.g. `F042` — auto-detected from most recent `origin.md` without `spec.md` if omitted |
| `update` | No | Invoke Update mode — normally called by `/spec-os-implement` during RECONCILE |

---

## Step 1 — Detect mode

If `update` argument provided → jump to **UPDATE MODE**.

Otherwise: **CREATE MODE** — proceed with steps below.

---

## Step 2 — Locate feature folder

If `feature-id` provided: find matching folder in `spec-os/changes/` (folder name starts with `{feature-id}`).

If not provided: scan `spec-os/changes/` for the most recent folder containing `origin.md` but no `spec.md`. Present to dev:

```
Found: spec-os/changes/{folder}/origin.md
Feature: {id} — {title from origin.md}

Proceeding with this feature? [y/n]
```

Wait for confirmation.

---

## Step 3 — Tracker Resolution

Read `.claude/shared/tracker-adapter.md` and apply the Tracker Resolution block.
Operations used by this skill: get-feature, create-feature, update-status

Read `origin.md`. Extract `feature-id`, `tracker-type`, `tracker-url`. Fetch the Feature from the tracker. Extract: title, description, area path / labels.

---

## Step 4 — Validate guards

Check all three. Stop on first failure.

**Guard 1 — docs/design/ exists:**
```
If docs/design/ not found:
  Stop. "docs/design/ not found.
  Run /spec-os-product first to create product documentation."
```

**Guard 2 — domain exists in _index.md:**
```
Read spec-os/specs/_index.md.
Read domain from origin.md (or ask developer if not present).
If domain not in _index.md:
  Stop. "Domain '{domain}' not found in spec-os/specs/_index.md.
  Run /spec-os-init update to add the domain first."
```

**Guard 3 — no conflicting feature in progress:**
```
Scan spec-os/changes/ for other folders with same domain and status: in-progress.
If found: report the conflict and ask developer whether to proceed.
(This is a warning, not a hard stop — developer decides.)
```

---

## Step 5 — Read design context

Read in parallel:
- `docs/design/00-overview.md` (system architecture — if exists)
- `spec-os/specs/{domain}/spec.md` (domain spec — known entities and behaviors)
- `origin.md` fully — pay particular attention to **Pending decisions** section

This context informs the scope boundaries, domain model, and design decision sections of `spec.md`.

---

## Step 6 — Determine spec-level

Apply this table:

| Condition | spec-level | context-level hint |
|-----------|------------|-------------------|
| Bug fix, single-file scope, no behavior contract change | `lite` | 1 |
| Internal refactor, no observable behavior change | `lite` | 1 |
| New feature, bounded scope, single domain | `full` | 2 |
| Cross-repo change, API/event contract, migration | `full` | 3 |
| Security, privacy, or compliance impact | `full` | 3 |
| High ambiguity — likely to cause expensive rework if wrong | `full` | 3 |

**lite spec:** Scope + 1–3 Requirements with scenarios. No Domain model section.

**full spec:** all sections — Scope, Requirements (RFC 2119), Domain model, Design decisions.

Propose to developer:

```
Spec-level: {lite | full}
Reason: {one line}

Confirm? [y / change]
```

Wait for confirmation before drafting.

---

## Step 7 — Draft spec.md

Using context from Steps 3–6, draft `spec.md`. Use the template from `docs/master-plan/04-templates.md`.

**Pending decisions from origin.md:** resolve each one in the `## Design decisions` section of `spec.md`. Each resolution is permanent in the spec. Add a `## Resolution notes` entry in `origin.md` only if that section is currently empty.

**RFC 2119 in requirements:**
- `MUST` / `SHALL` = absolute requirement — verify FAIL if not met
- `SHOULD` = recommended, exceptions exist — verify WARNING if not met
- `MAY` = optional — not checked by verify

**Scope discipline:** document observable behavior only — inputs, outputs, states, transitions. No class names, library choices, or implementation steps. Those belong in `tasks.md`.

---

## Step 8 — Propose spec.md to developer

```
─────────────────────────────────────────────────
Proposed: spec-os/changes/{folder}/spec.md
─────────────────────────────────────────────────

{full proposed content}

─────────────────────────────────────────────────
Create this spec? [y / n / edit]
```

- **y** — write as proposed
- **n** — stop, do not create any files
- **edit** — developer provides corrections; revise and ask again before writing

---

## Step 9 — Create files

On approval, create all four files in the feature folder:

1. `spec.md` — the approved draft (status: planned)
2. `spec-delta.md` — header only, empty body (ready for evolution tracking)
3. `session-log.md` — header only, empty body (ready for implement)
4. `verify-report.md` — header only, empty body (ready for verify)

Use headers from `docs/master-plan/04-templates.md`.

`origin.md` is **not modified**. Add `## Resolution notes` to it only if that section was empty and pending decisions existed.

---

## Step 10 — Report and handoff

```
/spec-os-design complete.

Created:
  spec-os/changes/{folder}/spec.md          (spec-level: {lite | full})
  spec-os/changes/{folder}/spec-delta.md    (empty)
  spec-os/changes/{folder}/session-log.md   (empty)
  spec-os/changes/{folder}/verify-report.md (empty)

Feature: {id} — {title}
Domain:  {domain}

Ready to decompose into tasks?
Run /spec-os-plan to continue.
```

If `skill-handoffs: explicit` in `spec-os/config.yaml` (default): stop here. Do not invoke `/spec-os-plan` automatically.

---

## UPDATE MODE

Invoked by `/spec-os-implement` during RECONCILE when:
- `git diff` shows `spec.md` was modified by the developer, OR
- Implementation revealed behavior undocumented in `spec.md`

### U.1 — Receive proposed change

`/spec-os-implement` passes: the proposed spec change + trigger reason (edge case found | PO clarification | technical constraint).

Read current `spec.md` and `spec-delta.md`.

### U.2 — Draft delta entry and spec update

Draft both:
1. The modified/added section in `spec.md` (minimal change — only what changed)
2. A new entry in `spec-delta.md` with: trigger, ADDED/MODIFIED/REMOVED sections, tasks affected

### U.3 — Propose to developer

```
─────────────────────────────────────────────────
Proposed spec change:
─────────────────────────────────────────────────
spec.md — section: {Requirements | Domain model | Design decisions}

  was: {original text}
  now: {updated text}

spec-delta.md — new entry:
{full delta entry}

Tasks affected: {T-IDs | none}

Apply? [y / n / edit]
─────────────────────────────────────────────────
```

Wait for approval. Never apply silently.

### U.4 — Write changes

On approval:
- Write updated `spec.md`
- Append new entry to `spec-delta.md`
- Update `last-updated` in `spec.md` frontmatter

### U.5 — Return to spec-implement

```
Spec updated. Tasks affected: {list | none}
```

If tasks are affected → `/spec-os-implement` will invoke `/spec-os-plan` Update mode next.

---

## Rules

- **Never invent requirements.** Only document what the Feature + `origin.md` + design context establish. If something is unclear, ask — don't assume.
- **origin.md is immutable.** Never modify it except to fill an empty `## Resolution notes` section.
- **Never write without approval.** Step 8 is mandatory. No exceptions.
- **lite spec is not an incomplete spec.** It is deliberately scoped. Do not add Domain model sections to lite specs — that adds noise without adding verifiability.
- **RFC 2119 discipline.** Every requirement sentence must use one keyword. No requirement without at least one scenario. No scenario without observable, verifiable outcomes.
- **Guard 3 is a conversation, not a blocker.** Two features sharing a domain is worth flagging — the developer may have a valid reason to proceed.
- **UPDATE mode never runs silently.** Every spec change during RECONCILE must be proposed and approved. Implementation is never the source of truth over the spec without developer confirmation.

---

## Self-improvement

Watch for these signals after each session:

- **Developer edits substantially during Step 8** → draft quality may be low for this feature type. Note which sections needed most revision.
- **Guard 1 or 2 fires unexpectedly** → project setup may be incomplete. Report as a Suggested Improvement.
- **Developer frequently overrides spec-level** → the classification criteria may need tuning for this project's patterns.
- **UPDATE mode invoked many times on one feature** → spec was written too early or with insufficient context. Consider suggesting a longer design conversation before writing spec.md next time.
