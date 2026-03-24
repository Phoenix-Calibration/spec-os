---
name: spec-os-plan
description: Decompose a technical spec into User Stories with Acceptance Criteria and atomic implementation tasks. Use this skill when the developer runs /spec-os-plan after /spec-os-design, when the developer is ready to plan implementation, or when /spec-os-implement triggers Update mode during RECONCILE after a spec change.
---

# /spec-os-plan

## Goal

Transform `spec.md` into a concrete `tasks.md` — a sequenced implementation plan with atomic tasks, traceable User Stories in the tracker, and all context fields that `/spec-os-implement` needs to work autonomously.

## Syntax

```
/spec-os-plan [feature-id] [update]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | e.g. `F042` — auto-detected from most recent `spec.md` without `tasks.md` if omitted |
| `update` | No | Invoke Update mode — normally called by `/spec-os-implement` during RECONCILE |

---

## Step 1 — Detect mode

If `update` argument provided → jump to **UPDATE MODE**.

Otherwise: **CREATE MODE** — proceed with steps below.

---

## Step 2 — Locate feature

If `feature-id` provided: find matching folder in `spec-os/changes/`.

If not provided: scan `spec-os/changes/` for the most recent folder containing `spec.md` but no `tasks.md`. Present to dev:

```
Found: spec-os/changes/{folder}/spec.md
Feature: {id} — {title}

Proceeding? [y/n]
```

Wait for confirmation.

---

## Step 3 — Tracker Resolution

Read `.claude/shared/tracker-adapter.md` and apply the Tracker Resolution block.
Operations used by this skill: get-feature, create-us, update-status, get-capacity

Read `spec.md` frontmatter: `feature-id`, `tracker-type`, `tracker-url`, `spec-level`, `domain`, `stack`.

---

## Step 4 — Read spec.md fully

Read the entire `spec.md`:
- Scope (in-scope and out-of-scope boundaries)
- All Requirements with all Scenarios (Given/When/Then)
- Domain model (if full spec)
- Design decisions
- Dependencies
- Definition of Done

**Derive default context-level from spec-level** (applied per task in Step 8):

| spec-level | Default context-level | Elevate to 3 when |
|------------|----------------------|-------------------|
| `lite` | 1 | — |
| `full` | 2 | Cross-repo, API/event contract, security/compliance, high ambiguity |

---

## Step 5 — Define User Stories

Write User Stories. Each US must:
- Represent a deliverable slice of value (not a technical task)
- Have a clear role: "As a {role}, I want {capability} so that {outcome}"
- Have Acceptance Criteria in Given/When/Then format
- Cover at least one happy path and one edge/failure scenario per Requirement

**Sizing — SP scale: 1 / 2 / 3 / 5 / 8 / 13**

| Rule | Action |
|------|--------|
| US SP > 8 | **Split** into smaller US |
| Two US: same role + same files + combined SP ≤ 5 | **Merge** into one US |
| SP 1–2 | Trivial — consider merging with adjacent US unless domain boundary prevents it |

**Story Points are set exclusively by this skill.** `origin.md` carries `complexity` (directional signal only) — never convert it to SP directly.

---

## Step 6 — Propose User Stories to developer

Present all US before creating anything in the tracker:

```
─────────────────────────────────────────────────
Proposed User Stories for F{id} — {title}:
─────────────────────────────────────────────────

US #1 — {title}
  Role: As a {role}, I want {capability} so that {outcome}
  SP:   {n}

  AC-1: {happy path name}
    GIVEN {precondition}
    WHEN  {action}
    THEN  {observable outcome}

  AC-2: {edge case name}
    GIVEN {precondition}
    WHEN  {action}
    THEN  {observable outcome}

US #2 — {title}
  ...
─────────────────────────────────────────────────
Create these User Stories in {tracker}? [y / n / edit]
```

- **y** — create in tracker and proceed to task decomposition
- **n** — stop
- **edit** — adjust SP, split/merge, or revise AC; propose again

Do not proceed to Step 7 until developer confirms.

---

## Step 7 — Create User Stories in tracker

On approval, create each US via the adapter.

**ADO:** `create_work_item(type: "User Story", fields: { title, description, acceptance-criteria, area-path, story-points, parent: feature-id })`

**GitHub:** `create_issue(fields: { title, body (with AC in Given/When/Then), labels: ["user-story"], milestone })`

Store returned US IDs — they go into `tasks.md` section headers and Progress table.

---

## Step 8 — Decompose tasks per User Story

For each US, define atomic implementation tasks.

**Task rules:**
- One task = one agent session = one atomic commit
- One task touches one layer (backend OR frontend — never both)
- Scope is file-level — list specific files or directories
- `done-when` must be verifiable, not vague ("X service returns 200 on valid input" not "implement X service")

**Field-by-field guide:**

| Field | How to set |
|-------|------------|
| `subagent` | `backend` or `frontend` — based on files touched |
| `depends-on` | T-ID of blocking task, or `—` if none |
| `scope` | File paths or directories the task will touch |
| `done-when` | Verifiable criterion — observable behavior or specific test passing |
| `context-level` | From Step 4 default + elevate individually if task is high-risk |
| `test-scope` | Scan the `scope` paths for adjacent test folders or test files matching the stack's naming convention (e.g., `*Tests.cs`, `test_*.py`, `*.test.ts`). If relevant test files exist: list their paths. If none found: `none`. This field is read by `test-writer` before proposing new tests. |
| `doc-impact` | `true` if task touches user-visible UI, user-facing docs, or API contracts visible to consumers; `false` otherwise |
| `claimed-by` | Always `—` — set by `/spec-os-implement` at session start |
| `status` | Always `planned` |
| `lessons-pending` | Always `[]` |

**doc-impact matters:** if every task has `doc-impact: false`, `/spec-os-doc` will never run for this feature. Set it accurately.

---

## Step 9 — Propose tasks.md to developer

```
─────────────────────────────────────────────────
Proposed: spec-os/changes/{folder}/tasks.md
─────────────────────────────────────────────────

{full proposed content}

─────────────────────────────────────────────────
Create tasks.md? [y / n / edit]
```

- **y** — write file
- **n** — stop
- **edit** — developer adjusts scope, done-when, or task order; revise and ask again

---

## Step 10 — Write tasks.md

On approval, write `tasks.md` using the template from `docs/master-plan/04-templates.md`.

Populate the Progress table with all US rows (all `planned`). T-IDs are sequential across the entire feature (T01, T02 ... — not reset per US).

---

## Step 11 — Report and handoff

```
/spec-os-plan complete.

Feature: F{id} — {title}
User Stories: {n} created in {tracker}
  {US-id}: {title} — SP: {n}
  ...
Tasks planned: {total}

spec-os/changes/{folder}/tasks.md created.

Ready to start implementation?
Run /spec-os-implement T01 to begin.
```

If `skill-handoffs: explicit` in `spec-os/config.yaml` (default): stop here. Do not invoke `/spec-os-implement` automatically.

---

## UPDATE MODE

Invoked by `/spec-os-implement` during RECONCILE when `/spec-os-design` Update mode reports tasks affected by a spec change.

### U.1 — Receive affected tasks

`/spec-os-implement` passes: list of affected T-IDs + the spec change (from `spec-delta.md` new entry).

Read current `tasks.md` and the new delta entry in `spec-delta.md`.

### U.2 — Assess impact per affected task

For each affected T-ID, determine:
- **Scope change** → update `scope` and/or `done-when`
- **New behavior required** → draft one or more new tasks
- **Task invalidated** → flag for developer decision (remove or repurpose)
- **US scope exceeded** → propose US split; new US needs tracker entry

### U.3 — Propose adjustments

```
─────────────────────────────────────────────────
Proposed tasks.md adjustments:
─────────────────────────────────────────────────

{T-ID} — {change type: scope update | new task | invalidated}
  Before: {current value}
  After:  {proposed value}
  Reason: {from spec-delta.md trigger}

─────────────────────────────────────────────────
Apply? [y / n / edit]
```

### U.4 — Write changes

On approval:
- Update `tasks.md`
- If US split: create new US in tracker via adapter; update Progress table with new row
- Update `last-updated` in `tasks.md` frontmatter

### U.5 — Return to spec-implement

```
Tasks updated. {n} task(s) modified. New US created: {yes — {US-id} | no}
```

---

## Rules

- **SP is exclusive to this skill.** Never inherit `complexity` from `origin.md` as an SP value. Brainstorm signals direction; spec-plan sets the number.
- **User Stories before tasks.** Always get confirmation on the US list (Step 6) before decomposing into tasks. Rework at the task level is cheaper than rework at the US level.
- **One layer per task.** A task spanning backend and frontend guarantees a mixed commit and breaks resume mode. Split it.
- **claimed-by is always empty.** `/spec-os-implement` sets it at session start. Never pre-fill it.
- **context-level defaults are anchored to spec-level.** Do not defensively set every task to context-level: 3 — it wastes tokens. Elevate only when the specific task justifies it (cross-repo call, security validation, complex domain logic).
- **Never write tasks.md without approval.** Step 9 is mandatory. No exceptions.
- **UPDATE mode never runs silently.** Every adjustment must be proposed and approved before writing.

---

## Self-improvement

Watch for these signals after each session:

- **Developer splits a US during Step 6** → initial decomposition was too coarse. Note the pattern — future US for this type of feature should start finer.
- **Developer adjusts context-level on many tasks** → the default derivation from spec-level may not fit this project. Consider whether project-level defaults in `config.yaml` need adjustment.
- **UPDATE mode invoked repeatedly** → specs are not stable at planning time. Consider suggesting a longer design review on `spec.md` before running `/spec-os-plan`.
- **done-when criteria are vague after approval** → surfaces as FAIL in `/spec-os-verify`. Refine the task decomposition guide for this project's domain.
