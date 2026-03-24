---
name: spec-os-product
description: Create or update the product documentation layer (docs/). Use this skill
  when the developer runs /spec-os-product, wants to create mission.md and roadmap.md
  from scratch, wants to generate docs from an existing codebase, or needs to update
  existing product documentation. Runs before /spec-os-init — gives the framework
  product context at setup time. Also use when asked to update mission, roadmap, or
  design documentation.
---

# /spec-os-product

## Goal

Own the `docs/` layer entirely. Create or update product documentation — mission, roadmap, and design structure — so that `/spec-os-init` can seed the project configuration with product context and the team has a stable reference for what the product is and why it exists.

## Syntax

```
/spec-os-product [mode]
```

| Argument | Required | Values |
|----------|----------|--------|
| `mode` | No | `initialize` \| `generate` \| `update` — auto-detected if omitted |

---

## Step 1 — Detect mode

If `mode` argument provided, use it directly. Otherwise auto-detect:

1. `docs/mission.md` exists → **UPDATE mode**
2. Project has existing source files (non-empty repo, no `docs/mission.md`) → **GENERATE mode**
3. Otherwise → **INITIALIZE mode**

Report detected mode and reason. Proceed.

---

## INITIALIZE mode

Use when: new project with no existing codebase.

### I.1 — Conversational discovery

Gather product information in a single structured conversation:

```
─────────────────────────────────────────────────
/spec-os-product — Initialize
─────────────────────────────────────────────────
Let's define your product. Answer as much or as little as you know right now.

Product name:
> _

What problem does it solve? (for whom, in what context)
> _

Who are the primary users?
> _

What does success look like for users?
> _

What are the main capabilities you're building? (list them)
> _

What are you explicitly NOT building? (out of scope)
> _

Any known technical or business constraints?
> _
─────────────────────────────────────────────────
```

Wait for developer answers. Incomplete answers are fine — mark gaps as TBD.

### I.2 — Propose docs structure

Present what will be created:

```
─────────────────────────────────────────────────
Proposed docs/ structure:
─────────────────────────────────────────────────
docs/
  mission.md          ← product purpose, users, problem solved
  roadmap.md          ← strategic direction, potential future features
  design/
    README.md         ← index of all design files
    00-overview.md    ← system history, architecture overview, future technical vision (stub)
    01-stack.md       ← technologies, frameworks, versions (stub)
    02-security.md    ← auth, authorization, data protection (stub)
    03-performance.md ← targets, caching strategy, optimization (stub)
    04-metrics.md     ← KPIs, monitoring, alerting (stub)
    05-data-model.md  ← core entities, relationships, value objects (stub)
    06-integrations.md ← external systems, APIs, webhooks (stub)
    07-error-handling.md ← error types, patterns, API responses (stub)
    08-glossary.md    ← domain terminology (stub)
    09-design-system.md ← UI components, palette, typography (stub)
    adr/              ← Architecture Decision Records (empty)
  runbooks/           ← operational runbooks (empty directory)
  manual/             ← user-facing documentation (empty directory)

Create? [y / n]
─────────────────────────────────────────────────
```

### I.3 — Write files

On approval, read all reference templates before writing anything:
- `references/template-mission.md` — structure and sections for `docs/mission.md`
- `references/template-roadmap.md` — structure and sections for `docs/roadmap.md`
- `references/template-design.md` — structure for `docs/design/00-overview.md` and any other design docs
- `references/template-adr.md` — structure for ADRs in `docs/design/adr/` (create when dev adds an ADR)
- `references/template-runbook.md` — structure for runbooks in `docs/runbooks/` (create when dev adds a runbook)

Create files in this order:

1. `docs/mission.md`
2. `docs/roadmap.md`
3. `docs/design/README.md` (index — use template-design.md README section)
4. `docs/design/00-overview.md` (stub — fill with known architecture or mark TBD)
5. `docs/design/01-stack.md` (stub)
6. `docs/design/02-security.md` (stub)
7. `docs/design/03-performance.md` (stub)
8. `docs/design/04-metrics.md` (stub)
9. `docs/design/05-data-model.md` (stub)
10. `docs/design/06-integrations.md` (stub)
11. `docs/design/07-error-handling.md` (stub)
12. `docs/design/08-glossary.md` (stub)
13. `docs/design/09-design-system.md` (stub)
14. `docs/design/adr/` (empty directory — `.gitkeep`)
15. `docs/runbooks/README.md` (folder index — use template-runbook.md README section)
16. `docs/manual/` (empty directory — `.gitkeep`)

Write:

**`docs/mission.md`:**
```markdown
# {Product Name}

## Purpose
{one paragraph: what the product does, for whom, and why}

## Problem solved
{the specific problem this product addresses}

## Primary users
{list of user types with one-line description each}

## Success criteria
{what success looks like for users — observable outcomes}

## Scope
### In scope
{main capabilities being built}

### Out of scope
{explicit exclusions — important for future reference}

## Constraints
{technical, business, or regulatory constraints}

## Status
{active development | maintenance | deprecated}
Last updated: {ISO-date}
```

**`docs/roadmap.md`:**
```markdown
# Roadmap — {Product Name}

> This is a strategic direction document, not a sprint plan.
> Specific features are tracked in spec-os/changes/ and the tracker.

## North star
{the long-term vision — one sentence}

## Current focus
{what the team is building right now — high level}

## Potential future capabilities
{unordered list of capabilities that might be built — not committed}

## Deliberately excluded
{capabilities that have been considered and rejected — with brief reason}

Last updated: {ISO-date}
```

Create stub files and empty directories for `docs/design/`, `docs/runbooks/`, `docs/manual/`, `docs/design/adr/`.

---

## GENERATE mode

Use when: existing codebase with no `docs/mission.md`. Derive documentation from what's already built.

### G.1 — Scan codebase for product signals

Read in parallel:
- `README.md` (root) — usually contains product description
- Any existing files in `docs/` (partial documentation)
- `package.json`, `.csproj`, `pyproject.toml`, or equivalent — project name and description
- Top-level module/namespace names — signal domain structure

### G.1b — Deep technical analysis (Explore subagent)

After the shallow scan, delegate a read-only technical analysis to an Explore subagent:

```
Analyze this codebase and return:
1. Main technology stack (languages, frameworks, versions — infer from config files and imports)
2. Top-level domains or bounded contexts (from namespaces, modules, folder structure)
3. Key external integrations (APIs, databases, services called)
4. Architectural pattern (monolith, layered, event-driven, microservices, etc.)
5. Any notable design patterns used (repository, CQRS, etc.)

Do not modify any files. Return findings only.
```

Merge subagent findings with G.1 results. The subagent's technical depth will populate `00-overview.md` (architecture section), `01-stack.md`, `05-data-model.md`, and `06-integrations.md` stubs with real inferences instead of TBD.

After scanning, assess signal quality:
- If `README.md` is missing or has fewer than 5 meaningful lines → stop and report:
  ```
  ─────────────────────────────────────────────────
  Not enough product signals to generate documentation.

  README.md: {missing | too sparse}

  Options:
    a) Add a README.md with a product description, then re-run
    b) Switch to INITIALIZE mode — answer questions interactively
    c) Let me help you write README.md — I'll collect product info
       and create both README.md and docs/ in one pass
  ─────────────────────────────────────────────────
  ```
  Wait for developer choice. Do not proceed with poor inferences.

  **If developer chooses c):** run the INITIALIZE conversational discovery (step I.1). Use the collected answers to:
  1. Write `README.md` at project root first — concise, developer-facing (product name, one-paragraph purpose, primary users, main capabilities, getting started placeholder)
  2. Then continue with INITIALIZE mode I.2 → I.3 to create the full `docs/` structure

  README.md is a product artifact. Writing it here is within scope when the developer explicitly requests it.

### G.2 — Propose derived content

Present findings to developer:

```
─────────────────────────────────────────────────
/spec-os-product — Generate (from codebase)
─────────────────────────────────────────────────

Inferred from codebase:

Product name:    {inferred from README.md}
Purpose:         {inferred from README.md}
Main domains:    {inferred from codebase analysis}
Stack:           {inferred from codebase analysis}
Architecture:    {inferred from codebase analysis}

Proposed mission.md content:
{full draft}

─────────────────────────────────────────────────
Accept as-is? [y / edit / stop]
```

On `edit`: developer provides corrections. Revise and re-present.

### G.3 — Write files

Read all reference templates before writing (same as INITIALIZE mode — see I.3 for the list).
Follow the same creation order as INITIALIZE mode.

Same structure as INITIALIZE mode. Mark fields that could not be inferred as `TBD — fill in manually`.

---

## UPDATE mode

Use when: `docs/mission.md` exists and needs updating.

### U.1 — Read current state

Read all existing files in `docs/`:
- `docs/mission.md`
- `docs/roadmap.md`
- Any other files in `docs/design/`

If `spec-os/` exists (framework already installed), also read:
- `spec-os/specs/_index.md` — registered domains and their relationships
- `spec-os/specs/{domain}/spec.md` for each domain — understand what's actually been built
- `spec-os/standards/backend/` and `spec-os/standards/frontend/` — confirm real stack in use

Use this additional context to detect stale or inconsistent product docs (e.g., a domain exists in spec-os/specs/ but is not mentioned in mission.md scope).

### U.2 — Identify what needs updating

Ask developer what changed:

```
─────────────────────────────────────────────────
/spec-os-product — Update
─────────────────────────────────────────────────
Current docs found:
  docs/mission.md      (last updated: {date from file})
  docs/roadmap.md      (last updated: {date from file})
  docs/design/{files}

What needs updating?
  a) Mission changed (product purpose, users, scope)
  b) Roadmap update (current focus, future capabilities)
  c) Design doc update (specific file)
  d) Add new design doc or ADR
  e) Full refresh (scan all and propose updates)
─────────────────────────────────────────────────
```

### U.3 — Load relevant reference templates

Before drafting any changes, read the template for each artifact being updated:

| Area selected | Template to read |
|---------------|-----------------|
| a) Mission | `references/template-mission.md` |
| b) Roadmap | `references/template-roadmap.md` |
| c) Design doc update | `references/template-design.md` |
| d) New design doc | `references/template-design.md` → also update `docs/design/README.md` index |
| d) New ADR | `references/template-adr.md` → also update `docs/design/adr/README.md` index |
| e) Full refresh | all templates |

### U.4 — Propose specific changes

For each selected area, read the current content and propose a targeted diff. Do not rewrite the entire file — propose only the sections that need changing.

Present as:
```
─────────────────────────────────────────────────
Proposed update: docs/mission.md — Scope section
─────────────────────────────────────────────────
BEFORE:
{current content}

AFTER:
{proposed content}

Apply? [y / n / edit]
─────────────────────────────────────────────────
```

Wait for approval per section. Never bulk-apply.

### U.5 — Write approved changes

Write only approved sections. Update `Last updated` date in each modified file.

---

## Step 2 (all modes) — Report

```
/spec-os-product complete.

Mode: {initialize | generate | update}

Files written:
  docs/mission.md      {created | updated}
  docs/roadmap.md      {created | updated | unchanged}
  docs/design/         {created | unchanged}

{If spec-os/ does not exist:}
Product documentation ready. Next step: set up the framework.
/spec-os-init will read docs/mission.md to pre-fill project name,
description, and context — run it now to avoid re-entering that info.

Run /spec-os-init to continue.

{If spec-os/ already exists:}
Product documentation updated.
No framework action needed — spec-os is already installed.
```

If `skill-handoffs: explicit` (default): stop. Do not invoke `/spec-os-init` automatically.

---

## Rules

- **Owns docs/ entirely.** This skill creates and modifies `docs/`. Other skills (notably `/spec-os-init`) read `docs/mission.md` but do not write it. Boundaries are strict (Decision 22).
- **May write README.md only on explicit developer request.** When GENERATE mode detects no usable README and the developer chooses option c), this skill writes `README.md` at project root as part of the same pass. This is the only exception to the `docs/`-only boundary.
- **Never touches spec-os/ or .claude/.** Those belong to `/spec-os-init`, `/spec-os-discover`, and `/spec-os-standard`.
- **Propose before writing.** Every INITIALIZE, GENERATE, and UPDATE mode presents content to the developer before writing. No file is written without explicit approval.
- **Stubs are acceptable.** It is better to create a stub with TBD placeholders than to block on incomplete information. Stubs can be updated with UPDATE mode.
- **Roadmap is strategic, not tactical.** Roadmap items are not features with IDs. They are directional signals. Do not add tracker IDs or sprint references to roadmap.md.

---

## Self-improvement

Watch for these signals:

- **Developer frequently updates mission.md after /spec-os-brainstorm** → the initial product definition is too vague. Encourage more specificity in the Purpose and Scope sections at initialization time.
- **GENERATE mode produces very poor inferences** → README/CLAUDE.md are sparse or missing. Suggest the developer add a proper README before running GENERATE.
- **UPDATE mode is never run** → docs are going stale. Consider adding a reminder to CLAUDE.md to run `/spec-os-product update` at major milestones.
