---
name: spec-os-brainstorm
description: Analyze a business idea or requirement, identify the real problem, propose
  a solution, resolve the Feature in the tracker, and produce origin.md. Use this
  skill when the developer runs /spec-os-brainstorm, wants to start a new feature,
  or has received a context package from /spec-os-explore. Entry point for the feature
  lifecycle in a single project.
---

# /spec-os-brainstorm

## Goal

Turn a raw idea or requirement into a structured `origin.md` with a resolved tracker Feature. Identify the real problem behind the stated request, propose a solution with complexity classification, and give `/spec-os-design` the complete context it needs to write the spec.

## Syntax

```
/spec-os-brainstorm [input]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `input` | No | Free-form description of the idea, requirement, or problem. Can also be a file path to a `{timestamp}-initiative-{slug}-{app}.md` context package from `/spec-os-explore`. If omitted, prompted interactively. |

---

## Step 1 — Tracker Resolution

Check if `spec-os/tracker/` exists. If yes: read `spec-os/tracker/config.yaml` to get tracker type, then read `spec-os/tracker/{type}.md` and apply the Tracker Resolution block. If `spec-os/tracker/` does not exist, skip tracker operations and continue.
Operations used by this skill: search-features, create-feature, add-comment

---

## Step 2 — Receive input

If `input` is a file path: read the initiative context package. Extract:
- Business problem and objective
- Affected app context (this project's slice of the initiative)
- Inter-app dependencies and execution order
- Epic ID if one was created by `/spec-os-explore`

If `input` is free-form text or interactive: collect from developer:
```
What is the idea or requirement?
> _

Is this triggered by a specific user request, business rule, or technical need?
> _

Any known constraints or context I should be aware of?
> _
```

---

## Step 3 — Read project context

Read in parallel:
- `docs/mission.md` — product purpose and audience (if exists)
- `docs/roadmap.md` — strategic roadmap for context (if exists)
- `spec-os/specs/_index.md` — domain list, to identify which domain(s) this might affect
- Recent `origin.md` files — glob: `spec-os/changes/*/origin.md` (read last 3 by modification date) — to spot related or overlapping work

---

## Step 4 — Analyze: real problem vs stated problem

Apply structured analysis. Present to developer:

```
─────────────────────────────────────────────────
Analysis: {one-line title}
─────────────────────────────────────────────────

Input received:
  {verbatim summary of what was described}

Real problem identified:
  {the underlying problem — often different from the stated request}
  Evidence: {what signals this is the real problem}

Proposed solution:
  {what to build — focused on observable behavior, not implementation}
  Why this solves the real problem: {one sentence}

Classification:
  Type: feature | improvement | technical-debt | compliance | integration
  Complexity: simple | medium | complex
  Reason: {one sentence justifying the complexity}

Domain(s) affected: {list from _index.md}

Overlap check: {none | "Possible overlap with {feature-id} — {reason}"}
─────────────────────────────────────────────────
Is this analysis correct? [y / correct / stop]
```

- **y** — proceed to Feature resolution
- **correct** — developer provides corrections; revise and re-present
- **stop** — abandon; write nothing

Wait for developer confirmation before proceeding.

---

## Step 5 — Feature resolution in tracker

Search for an existing Feature in the tracker related to this idea.

Present findings:

```
─────────────────────────────────────────────────
Tracker Feature resolution
─────────────────────────────────────────────────

Search results for "{topic}":
  {found: Feature #{id} — {title} (state: {state})}
  OR
  {no existing Feature found}

Options:
  a) Link to existing Feature #{id} — {title}
  b) Create new Feature: "{proposed title}"
  c) No Feature — work without tracker Feature (solo/untracked)
─────────────────────────────────────────────────
```

Wait for developer choice.

**On link (a):** store `feature-id` from selected Feature.

**On create (b):** create Feature in tracker with:
- Title: `{proposed title}`
- Description: real problem identified + proposed solution (from Step 4)
- Area path / labels: from `spec-os/config.yaml` (area-path field if set)
- Parent Epic: if initiative context provided an Epic ID, link to it
- No Story Points — Features do not carry SP

Store returned `feature-id` and `tracker-url` from the tracker response.

After resolving the Feature (option a or b): add a comment using `add-comment`:
> `"brainstorm analysis: {real problem summary} → {proposed solution summary} (complexity: {level})"`

**On no Feature (c):** `feature-id: none` in origin.md.

---

## Step 6 — Create origin file

If `feature-id` is set: check if a folder matching `F{id}-*` already exists in `spec-os/changes/`.

**If folder exists (adding requirement to existing Feature):**
- Do NOT create a new folder
- Use existing folder: `spec-os/changes/{existing-folder}/`
- File name: `origin-{slug}.md` (alongside existing origin files)
- Report to developer: "Adding to existing feature folder: spec-os/changes/{existing-folder}/"

**If folder does not exist (first requirement for this Feature):**
- Folder name: `F{id}-{cadence}-{slug}/` where cadence is read from field `project.current-cadence` in `spec-os/config.yaml`
- Create folder: `spec-os/changes/{folder}/`
- File name: `origin.md`

If `feature-id: none`: folder `{YYYYMMDD}-{slug}/`, file name: `origin.md`.

Write origin file using the template from `docs/master-plan/04-templates.md`:

```markdown
---
date: {ISO-date}
source: brainstorm-analyze
feature-id: {F{id} | none}
tracker-type: {ado | github | none}
tracker-url: {URL returned by tracker on create/link in Step 5 | none}
complexity: {simple | medium | complex}
---

## Input received
{verbatim summary of what was described — or reference to initiative context package}

## Real problem identified
{the underlying problem}

## Proposed solution
{what to build — observable behavior focus}

## Classification
Type: {feature | improvement | technical-debt | compliance | integration}
Complexity: {simple | medium | complex}
Domain(s): {list}

## Tracker context at time of analysis
Feature: {id} — {title} — {url}
{Epic: {id} — {title} (if from initiative)}
Sprint/Milestone: {current cadence}
{Other related items found during search}

## Pending decisions
{Questions that /spec-os-design will need to resolve, or "none"}

## Resolution notes
{Populated by /spec-os-design when each pending decision is resolved}
```

---

## Step 7 — Report and handoff

```
─────────────────────────────────────────────────
/spec-os-brainstorm complete.

Feature:  {feature-id} — {title}
Tracker:  {URL | none}
Folder:   spec-os/changes/{folder}/
Created:  origin.md

Complexity signal: {simple | medium | complex}
  (This is directional — Story Points set exclusively by /spec-os-plan)

Ready to write the technical spec?
Run /spec-os-design to continue.
─────────────────────────────────────────────────
```

If `skill-handoffs: explicit` (default): stop. Do not invoke `/spec-os-design` automatically.

---

## Rules

- **Complexity is not SP.** `origin.md` carries `complexity: simple | medium | complex` as a directional signal only. Never map it to Story Points directly — that is `/spec-os-plan`'s exclusive job (Decision 19).
- **Feature resolution is mandatory.** `feature-id` must be populated in `origin.md` (or explicitly set to `none`) before handing off to `/spec-os-design`. A missing `feature-id` breaks the entire traceability chain.
- **Real problem analysis is not optional.** The developer described a symptom. Your job is to find the underlying problem. If the stated request IS the real problem, say so explicitly — don't skip the analysis.
- **Never create tasks.md or spec.md.** This skill creates only `origin.md`. All other artifacts are downstream.
- **Overlap check is non-blocking.** Potential overlap with an existing feature is a warning, not a stop. The developer decides whether to continue or merge.

---

## Self-improvement

Watch for these signals:

- **Real problem analysis is consistently wrong** → developer corrects it every time. Either the domain context in `_index.md` is stale, or `docs/mission.md` is missing/outdated. Suggest running `/spec-os-product Update`.
- **Feature search finds no results but features clearly exist** → tracker search query may be too narrow. Consider broader keyword search terms.
- **Developer always chooses "create new Feature"** → tracker organization may not match how work is structured. Consider whether the team is using Features at all in ADO/GitHub.
- **Complexity signal is consistently wrong** → the classification heuristics don't match this project's patterns. Note what "simple" vs "complex" means in context and refine.
