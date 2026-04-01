---
name: spec-os-design
description: Write the technical spec for a feature from brief.md. Use this skill when the developer runs /spec-os-design, is ready to turn a brainstormed idea into a formal specification, or when /spec-os-implement triggers Update mode during RECONCILE to record spec changes discovered during implementation.
---

# /spec-os-design

## Goal

Transform `brief.md` into a formal `spec.md` — the observable behavior contract that drives implementation. Preserve all strategic reasoning from `brief.md` unchanged.

## Syntax

```
/spec-os-design [feature-id] [update]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | e.g. `F042` — auto-detected from most recent `brief.md` without `spec.md` if omitted |
| `update` | No | Invoke Update mode — normally called by `/spec-os-implement` during RECONCILE |

---

## Step 1 — Detect mode

If `update` argument provided → jump to **UPDATE MODE**.

Otherwise: auto-detect in Step 2 based on folder state.

---

## Step 2 — Locate feature folder and detect mode

If `feature-id` provided: find matching folder in `spec-os/changes/` (folder name starts with `{feature-id}`).

If not provided: scan `spec-os/changes/` for the most recent folder containing `brief.md` or `origin-*.md` files. Present to dev:

```
Found: spec-os/changes/{folder}/
Feature: {id} — {title from brief.md}

Proceeding with this feature? [y/n]
```

Wait for confirmation. Then detect mode based on folder state:

- **No `spec.md` in folder** → **CREATE MODE** — continue with Step 3.
- **`spec.md` exists AND unincorporated `origin-*.md` files found** (files not listed in `spec.md` frontmatter `sources:`) → **EXTEND MODE** — jump to EXTEND MODE section.
- **`spec.md` exists, no unincorporated origins** → stop:
  ```
  spec.md is up to date for this feature.
  Use /spec-os-design update if implementation revealed undocumented behavior.
  ```

---

## Step 3 — Tracker Resolution

Check if `spec-os/tracker/` exists. If yes: read `spec-os/tracker/config.yaml` to get tracker type, then read `spec-os/tracker/{type}.md` and apply the Tracker Resolution block. If `spec-os/tracker/` does not exist, skip tracker operations and continue.
Operations used by this skill: get-feature, update-status

Read `brief.md`. Extract `feature-id`, `tracker-type`, `tracker-url`. Fetch the Feature from the tracker. Extract: title, description, area path / labels.

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
Read domain from brief.md (or ask developer if not present).
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
- `docs/design/00-overview.md` — system architecture (if exists)
- `docs/design/01-stack.md` — authoritative stack and available technologies (if exists)
- `docs/design/05-data-model.md` — core entities and relationships (if exists; directly informs Domain model section of full specs)
- `spec-os/specs/{domain}/spec.md` — domain spec, known entities and behaviors
- `brief.md` (or all unincorporated `origin-*.md` in EXTEND mode) — pay particular attention to **Pending decisions** section

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

Using context from Steps 3–6, draft `spec.md`. Use the template from `.claude/skills/spec-os-design/references/spec-template.md`. Use the template from `.claude/skills/spec-os-design/references/spec-delta-template.md` when creating `spec-delta.md` in Step 9.

**For full specs with context-level 3** (cross-repo, security, high ambiguity): before drafting `## Domain model` and `## Design decisions`, offer to invoke the architect agent:
```
This is a complex spec (context-level 3). Invoke architect agent for Domain model and Design decisions sections? [y/n]
```
If `y`: invoke `/spec-os-inject` with keywords: architecture patterns backend → get `standards-paths` (list of file paths). Then invoke `.claude/agents/architect` with: brief.md content, approved design context (00-overview, 01-stack, 05-data-model), pending decisions list, standards-paths (if available). Instruction: propose Domain model additions and Design decisions resolutions. Gate each section with developer before incorporating into the draft.

**Pending decisions from brief.md:** resolve each one in the `## Design decisions` section of `spec.md`. Each resolution is permanent in the spec. Add a `## Resolution notes` entry in `brief.md` only if that section is currently empty.

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

On approval, create both files in the feature folder:

1. `spec.md` — the approved draft. Set frontmatter `sources: [brief.md]` to track which origin files have been incorporated.
2. `spec-delta.md` — header only, empty body (ready for evolution tracking)

Then invoke `update-status` on the tracker Feature to mark it as "Spec ready" (if tracker is configured).

`brief.md` is **not modified**. Add `## Resolution notes` to it only if that section was empty and pending decisions existed.

Note: `session-log.md` is created by `/spec-os-implement` at the start of its first session. `verify-report.md` is created by `qa-engineer` during `/spec-os-verify`. Each skill owns its own artifact.

---

## Step 10 — Report and handoff

```
/spec-os-design complete.

Created:
  spec-os/changes/{folder}/spec.md          (spec-level: {lite | full})
  spec-os/changes/{folder}/spec-delta.md    (empty)

Feature: {id} — {title}
Domain:  {domain}

Ready to decompose into tasks?
Run /spec-os-plan to continue.
```

If `skill-handoffs: explicit` in `spec-os/config.yaml` (default): stop here. Do not invoke `/spec-os-plan` automatically.

---

## EXTEND MODE

Use when: feature folder already has `spec.md` and new `origin-{slug}.md` files were added by `/spec-os-brainstorm` (not yet listed in `spec.md` frontmatter `sources:`).

### E.1 — Identify unincorporated origins

Read `spec.md` frontmatter `sources:` list. Read all `origin-*.md` files in the folder. Identify files not in the sources list — these are the new requirements to incorporate.

### E.2 — Read design context

Same as CREATE MODE Step 5 — read `docs/design/` files and domain spec in parallel.

### E.3 — Analyze new requirements

For each unincorporated origin file, identify which sections of `spec.md` need extension:
- New requirements → `## Requirements`
- New entities or relationships → `## Domain model`
- New architectural choices → `## Design decisions`

Present analysis:

```
─────────────────────────────────────────────────
Extending spec.md with: {origin-slug.md}
─────────────────────────────────────────────────
New requirements:    {N}
Domain model adds:   {entities or "none"}
Design decisions:    {new decisions or "none"}

Proceed? [y/n]
─────────────────────────────────────────────────
```

### E.4 — Draft and propose extensions

Draft additions to each relevant section. Present as targeted diff:

```
─────────────────────────────────────────────────
Proposed extension: spec-os/changes/{folder}/spec.md
─────────────────────────────────────────────────
## Requirements — adding:
{new requirement text with RFC 2119}

## Domain model — adding:
{new entity or relationship — if applicable}
─────────────────────────────────────────────────
Apply? [y / n / edit]
─────────────────────────────────────────────────
```

### E.5 — Write changes

On approval:
- Append new content to the relevant sections of `spec.md`
- Add the newly incorporated origin file(s) to `sources:` in `spec.md` frontmatter
- Update `last-updated` in `spec.md` frontmatter
- Append entry to `spec-delta.md`: trigger `extend`, sources added, sections modified
- Invoke `update-status` on tracker Feature (if configured)

### E.6 — Report

```
/spec-os-design (extend) complete.

Extended:  spec-os/changes/{folder}/spec.md
Sources:   {origin-slug.md} added
Sections:  {Requirements | Domain model | Design decisions}

Run /spec-os-plan to update the task breakdown.
```

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

- **Never invent requirements.** Only document what the Feature + `brief.md` + design context establish. If something is unclear, ask — don't assume.
- **brief.md is immutable.** Never modify it except to fill an empty `## Resolution notes` section.
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
