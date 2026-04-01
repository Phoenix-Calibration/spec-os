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

**Note — EXTEND mode post-planning:** if the feature already has `tasks.md`
(spec was extended via `/spec-os-design extend` after planning), auto-detect
will not find it here. Run `/spec-os-plan {feature-id} update` explicitly to
adjust the existing tasks.md for the new origins.

---

## Step 3 — Tracker Resolution

Check if `spec-os/tracker/` exists. If yes: read `spec-os/tracker/config.yaml` to get tracker type, then read `spec-os/tracker/{type}.md` and apply the Tracker Resolution block. If `spec-os/tracker/` does not exist, skip tracker operations and continue.
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

## Step 4.5 — Optional specialist consultations

Based on what was read in Step 4, offer specialist consultations before decomposition.
Each is optional and gated — never automatic.

**Frontend scope detected** (spec.md scope includes UI components, user interactions,
or pages AND `docs/design/09-design-system.md` exists):
```
This feature has significant frontend scope.
Invoke ui-ux-designer to clarify component boundaries before decomposing tasks? [y/n]
```
If `y`: invoke `.claude/agents/ui-ux-designer` via Agent tool with:
- spec.md scope and requirements (frontend-relevant sections only)
- `docs/design/09-design-system.md` content
- `docs/design/01-stack.md` content (frontend stack)
- Instruction: identify which UI components need to be built or modified, their
  boundaries, and any ordering constraints. Return findings only — do not write files.

Store result as `ui-context`.

**Context-level 3 detected** (cross-repo, API/event contract, security/compliance,
or high ambiguity — derived from spec.md Design decisions or Dependencies sections):
```
This feature has cross-cutting or high-complexity scope (context-level 3).
Invoke architect to clarify API boundaries and layer dependencies before decomposing tasks? [y/n]
```
If `y`: invoke `.claude/agents/architect` via Agent tool with:
- spec.md full content
- `docs/design/00-overview.md` content (if exists)
- `docs/design/01-stack.md` content (if exists)
- Instruction: identify API boundaries, layer dependencies, and task ordering
  constraints relevant to decomposition. Return findings only — do not write files.

Store result as `arch-context`.

Both consultations are independent — either, both, or neither may be invoked.
Pass whatever was collected (`ui-context`, `arch-context`) to project-manager in Step 5.

---

## Step 5 — Inject standards and invoke project-manager

If `spec-os/standards/` exists: invoke `/spec-os-inject` with keywords derived
from the feature domain and stack. Store result as `standards-paths` (list of file paths).

Read `references/tasks-template.md` — pass as `tasks-template` to the agent.

Invoke `.claude/agents/project-manager` via Agent tool in Modo Descomposición with:
- `spec.md` full content (from Step 4)
- `spec-level`: from spec.md frontmatter
- `stack`: from spec.md frontmatter (or `docs/design/01-stack.md` if available)
- `tracker-capacity`: SP available in current sprint/milestone (from `get-capacity`
  tracker operation — pass `null` if tracker not configured)
- `standards-paths`: standards-paths (if available)
- `ui-context`: ui-ux-designer findings (if collected in Step 4.5)
- `arch-context`: architect findings (if collected in Step 4.5)
- `tasks-template`: content of `references/tasks-template.md`
- Instruction: propose User Stories with AC and atomic tasks in CREATE mode.
  Return structured proposal only — do not write any files.

---

## Step 6 — Propose User Stories to developer

Present the project-manager proposal:

```
─────────────────────────────────────────────────
Proposed User Stories for F{id} — {title}:
─────────────────────────────────────────────────

{project-manager proposal — US list with SP and AC}

─────────────────────────────────────────────────
Create these User Stories in {tracker}? [y / n / edit]
```

- **y** — create in tracker and proceed to task decomposition
- **n** — stop
- **edit** — relay developer feedback to project-manager, re-invoke, present again

Do not proceed to Step 7 until developer confirms.

---

## Step 7 — Create User Stories in tracker

On approval, create each US via the adapter.

**ADO:** `create_work_item(type: "User Story", fields: { title, description, acceptance-criteria, area-path, story-points, parent: feature-id })`

**GitHub:** `create_issue(fields: { title, body (with AC in Given/When/Then), labels: ["user-story"], milestone })`

Store returned US IDs — they go into `tasks.md` section headers and Progress table.

---

## Step 8 — Propose tasks.md to developer

Present the task breakdown from the project-manager proposal:

```
─────────────────────────────────────────────────
Proposed: spec-os/changes/{folder}/tasks.md
─────────────────────────────────────────────────

{full proposed content — tasks per US with all fields populated}

─────────────────────────────────────────────────
Create tasks.md? [y / n / edit]
```

- **y** — write file
- **n** — stop
- **edit** — relay developer feedback to project-manager, re-invoke for the
  affected US/tasks, present revised proposal

**Fields set by this skill (not by project-manager):**
- `claimed-by`: always `—`
- `status`: always `planned`
- `lessons-pending`: always `[]`
- `blocked-reason`: omitted unless task is pre-blocked

---

## Step 10 — Write tasks.md

On approval, write `tasks.md` using the template from `references/tasks-template.md`.

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

### U.2 — Invoke project-manager in Ajuste mode

Invoke `.claude/agents/project-manager` via Agent tool in Modo Ajuste with:
- `tasks.md` current content
- `spec-delta.md` new entry (trigger, ADDED/MODIFIED/REMOVED, tasks affected)
- Instruction: assess impact per affected task and return proposed adjustments
  as Before/After diff. Do not write any files.

project-manager returns a structured diff per affected T-ID with one of:
- **Scope change** → updated `scope` and/or `done-when`
- **New behavior required** → one or more new tasks
- **Task invalidated** → flagged for developer decision (remove or repurpose)
- **US scope exceeded** → proposed US split; new US needs tracker entry

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

- **SP is exclusive to this skill.** Never inherit `complexity` from `brief.md` as an SP value. Brainstorm signals direction; spec-plan sets the number.
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
