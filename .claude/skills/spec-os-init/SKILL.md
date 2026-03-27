---
name: spec-os-init
description: Install spec-os in a new project, adopt it in an existing one, or update an installed version. Use this skill when the developer runs /spec-os-init, wants to set up spec-os in a project for the first time, is adding spec-os to an existing codebase mid-development, wants to add new domains, or needs to update the spec-os configuration. Also use it when the developer asks to initialize, install, or set up the spec-os framework.
---

# /spec-os-init

## Goal

Create the complete `spec-os/` structure, domain specs, and `CLAUDE.md` — everything a project needs to start using the spec-os workflow. Tracker setup is delegated to `/spec-os-tracker` (invoked at the end if a tracker is declared). Agent files come with the framework installation and are not created by this skill.

## Syntax

```
/spec-os-init [mode]
```

| Argument | Required | Values |
|----------|----------|--------|
| `mode` | No | `initialize` \| `adopt` \| `update` — auto-detected if omitted |

---

## Step 1 — Detect mode

If `mode` argument provided, use it directly. Otherwise auto-detect:

1. `spec-os/version` exists → **UPDATE mode**
2. `spec-os/` directory exists but no `version` file → **INITIALIZE mode** (incomplete prior install)
3. Project has existing source files (non-empty repo) → **ADOPT mode**
4. Otherwise → **INITIALIZE mode**

Report detected mode and reason. Proceed.

---

## INITIALIZE mode

Use when: new project, no existing codebase.

### I.1 — Optional: read product context

Check and read in order:

1. `docs/mission.md` — if exists: extract project name and description.
2. `docs/roadmap.md` — if exists: extract domain candidates and cadence format.
   Cadence heuristic: sprint references (e.g., "Sprint 23") → `sprint`; version milestones (e.g., "v1.0") → `milestone`; unclear → leave blank and ask in I.2.
3. `docs/design/01-stack.md` — if exists: use as authoritative stack source (takes priority over any stack extracted from roadmap.md).

Report what was found:
```
Product context detected:
  Project name:    {value | not found}
  Description:     {value | not found}
  Stack:           {value | not found}
  Cadence:         {value | not found}
  Domains:         {list | not found}
```

### I.2 — Confirm project information

If fields were detected in I.1, present them for confirmation — include only blanks for fields not found:

```
Detected configuration — confirm or correct:
  Project name:    {value | blank}
  Description:     {value | blank}
  Stack:           {value | blank}
  Tracker:         {ado | github | none}   ← always ask, not in docs/
  Cadence format:  {value | blank}
```

Wait for confirmation or corrections before proceeding.

### I.3 — Note tracker for handoff

If tracker selected (not `none`): record the declared type. Tracker connection details (org URL, project name, repo) are collected by `/spec-os-tracker` at I.7 — not by this skill.

If `none` selected: skip. No tracker module will be created.

### I.4 — Confirm or collect domains

If domains were detected from `docs/roadmap.md`:
```
Detected domains: {list}
Add, remove, or rename? Confirm or provide adjustments.
```

If no domains detected:
```
What are the bounded domains of this project?
Examples: equipment, billing, auth, reporting, users
Enter as a comma-separated list.
```

Wait for response.

### I.4b — Optional: architect consultation for domain specs

If `docs/design/` exists with at least `00-overview.md` or `05-data-model.md`:

```
docs/design/ context available.
Invoke architect to produce richer domain specs instead of empty stubs? [y/n]
```

If `y`: invoke `.claude/agents/architect` via Agent tool with:
- Confirmed domain list (from I.4)
- `docs/design/00-overview.md` content (if exists)
- `docs/design/01-stack.md` content (if exists)
- `docs/design/05-data-model.md` content (if exists)
- `docs/mission.md` content (if exists)
- Instruction: for each declared domain, propose the initial content of its
  `spec-os/specs/{domain}/spec.md` — entities, states, and behaviors observable
  at the domain boundary. Return one proposal per domain. Do not write files.

Store result as `domain-specs-content`. Used in I.6 in place of empty stubs.

If `n` or `docs/design/` not available: I.6 creates empty stubs as normal.

---

### I.5 — Propose full structure

Present the complete list of files to create. Wait for confirmation before writing anything.

```
Will create:

spec-os/config.yaml
spec-os/version
spec-os/GETTING-STARTED.md
spec-os/specs/_index.md
spec-os/specs/{domain}/spec.md   (one per domain)
spec-os/specs/knowledge-base.md
spec-os/changes/  (empty)
spec-os/archive/  (empty)
CLAUDE.md  (thin template — replaces or creates)

Note: spec-os/standards/ is created by /spec-os-discover — run it after init
to build standards from your codebase and/or docs/design/.
Note: .claude/agents/ come with the framework installation — not created by init.

Proceed? [y/n]
```

### I.6 — Create files

On confirmation, read both reference files before writing anything:
- `references/templates-structure.md` — `version`, `config.yaml`, `CLAUDE.md`, `GETTING-STARTED.md`
- `references/templates-specs.md` — domain spec stubs, `knowledge-base.md`

Create all files in this order:

1. `spec-os/version`
2. `spec-os/config.yaml`
3. `spec-os/specs/_index.md`
4. `spec-os/specs/{domain}/spec.md` — one per declared domain
   (use `domain-specs-content` from I.4b if architect was invoked; otherwise empty stub)
5. `spec-os/specs/knowledge-base.md`
6. `spec-os/changes/.gitkeep`
7. `spec-os/archive/.gitkeep`
8. `spec-os/GETTING-STARTED.md`
9. `CLAUDE.md`

### I.7 — Report and next steps

```
spec-os v1.0.0 installed.

Created:
  spec-os/config.yaml         ← cadence and workflow settings
  spec-os/specs/              ← {N} domain stubs — fill with known system behavior
  CLAUDE.md                   ← verify project identity section

Next steps:
  1. {if tracker declared} Run /spec-os-tracker to configure tracker access [confirm to proceed]
  2. Run /spec-os-discover to create standards from your codebase and/or docs/design/
  3. Fill spec-os/specs/{domain}/spec.md with known system behavior
  4. When ready: /spec-os-brainstorm or /spec-os-bug
```

If tracker was declared and developer confirms step 1: invoke `/spec-os-tracker` passing the declared tracker type as context.

---

## ADOPT mode

Use when: existing project, adopting spec-os mid-development.

### A.1 — Scan codebase

Read in parallel (if they exist):
- `docs/mission.md` — project description
- `docs/roadmap.md` — domain candidates, cadence format
- `docs/design/01-stack.md` — authoritative stack (takes priority over roadmap.md)
- `docs/design/05-data-model.md` — core entities → additional domain candidates
- `docs/design/00-overview.md` — bounded contexts → additional domain candidates
- `CLAUDE.md` — read if present, do NOT modify yet

Then delegate technical codebase analysis to an Explore subagent:

```
Analyze this codebase and return:
1. Main technology stack (languages, frameworks, versions)
2. Top-level domains or bounded contexts (namespaces, modules, folder structure)
3. Architectural pattern (monolith, layered, etc.)
4. Core data entities (from class names, DB tables, model files)

Do not modify any files. Return findings only.
```

Merge Explore findings with docs/ readings (docs/ takes priority when both have stack/domain signals).

Report findings:
```
Codebase analysis:
  Detected stack:    {stack(s) — source: 01-stack.md | codebase | roadmap.md}
  Domain candidates: {list with reason}
  Existing CLAUDE.md:       found | not found
  Existing docs/mission.md: found | not found
  Existing docs/roadmap.md: found | not found
  Existing docs/design/:    found | not found
```

### A.2 — Propose domain list

```
Proposed domains:
  - {domain-1}: {reason — namespace/module found}
  - {domain-2}: {reason}

Add, remove, or rename? Confirm or provide adjustments.
```

Wait for confirmation/edits.

### A.3 — Collect remaining configuration

Same as Initialize steps I.2 and I.3 (tracker selection, cadence, and handoff note).

### A.4 — Propose structure

Same as Initialize step I.5, with additional note:
```
Note: If CLAUDE.md already exists, a replacement will be proposed for your
approval — current CLAUDE.md will NOT be modified without explicit approval.
```

### A.5 — Create files

Same as Initialize step I.6 with two differences:

**For `CLAUDE.md`:** if existing file found:
1. Read it
2. Propose the new thin template as a replacement
3. Highlight what would be removed
4. Wait for explicit approval before writing. On `n`: keep existing CLAUDE.md unchanged and continue.

**For domain spec stubs:** offer architect consultation before writing:

```
Codebase analysis complete. Invoke architect to produce richer domain specs
using Explore findings + docs/? [y/n]
```

If `y`: invoke `.claude/agents/architect` via Agent tool with:
- Confirmed domain list
- Explore subagent full findings (A.1)
- `docs/design/00-overview.md`, `01-stack.md`, `05-data-model.md` content (if exist)
- `docs/mission.md` content (if exists)
- Instruction: for each declared domain, propose initial content for
  `spec-os/specs/{domain}/spec.md` derived from codebase analysis and docs.
  Flag what is inferred vs confirmed. Return one proposal per domain — do not write files.

Gate each domain spec proposal with the developer before writing.

If `n`: seed each `spec-os/specs/{domain}/spec.md` from the Explore findings only:
- Known entities from the domain (class names, DB tables, module structure)
- Observed behaviors from comments, README, or tests

In both cases, mark all content: `# STUB — review and complete with actual behavior`

### A.6 — Report

Same as Initialize step I.7.

---

## UPDATE mode

Use when: spec-os is already installed.

### U.1 — Read current version

Read `spec-os/version`. Report:
```
Installed version: {current}
Latest version: 1.0.0
```

If same version: "Do you want to add new domains or refresh configuration?"

### U.2 — Determine scope

```
What would you like to update?
1. Add new domains
2. Update config.yaml schema
3. Add a new stack (creates missing standards stubs for backend or frontend)
4. All of the above
```

### U.3 — Add new domains

If selected:
```
Current domains: {list from _index.md}
New domains to add:
```

Wait for input.

If `docs/design/` exists with content: offer architect consultation (same as I.4b)
before creating the new domain specs. If architect invoked: use its proposals.
Otherwise: create stubs from `references/templates-specs.md`.

Update `spec-os/specs/_index.md`.

### U.3b — Add new stack

If selected: ask which stack to add (backend or frontend, then which language/framework). Create only the missing stubs using the same templates as I.6. Update `spec-os/standards/index.yml` to include the new stack entries.

```
Stack to add:
  Type:       backend | frontend
  Framework:  {dotnet | python | odoo | nextjs | react | ...}
```

Wait for input. Propose the list of files to create before writing. On confirmation, create stubs.

### U.4 — Update config schema

If selected: read current `config.yaml`. Propose additions for new fields in the current version. Dev approves before writing.

### U.5 — Write version

Write `1.0.0` to `spec-os/version`.

---

## Rules

- **Propose before creating.** Always show the full file list (step I.5 / A.4) and wait for an explicit "y" before writing any file. A partial install — where only some files were created — is harder to debug than no install at all.
- **Never overwrite CLAUDE.md without explicit approval.** In ADOPT mode the existing CLAUDE.md may contain rules the team depends on. Always read it, show the proposed replacement, and highlight what would be removed before touching it.
- **Only create standard files for stacks in use.** Writing `dotnet.md` into a Next.js-only project adds noise to `/spec-os-inject` matches and creates false confidence. Stick to the stacks declared in the developer's answers — never create stubs for stacks not in use.
- **Never write credentials to any config file.** Organization URLs and project names are safe; authentication tokens and PATs are not. Leave auth fields as `{placeholder}` with a comment pointing the developer to their secret management solution.
- **Domain spec stubs are seeds, not specs.** In ADOPT mode, extracted content is marked `STUB` explicitly. The developer must verify and complete it. Never present extracted stubs as authoritative or complete system documentation.
- **One mode per session.** If the developer asks to initialize and add a domain in the same breath, complete the primary mode first, then guide them to `/spec-os-init update`. Mixing modes mid-run creates inconsistent state.
- **Never write to `docs/`.** Product documentation is owned exclusively by `/spec-os-product` (Decision 22). This skill reads `docs/` for context only — it never creates, modifies, or deletes files there.
- **Never write to `spec-os/tracker/`.** Tracker module setup is owned exclusively by `/spec-os-tracker` (Decision 24). This skill records the declared tracker type and hands off — it never creates files in `spec-os/tracker/`.

---

## Self-improvement

After a successful installation, watch for these signals that templates or detection logic need refinement:

- **Developer immediately modifies a generated file** → the template content may be off for this type of project. Note which file and what changed — if the pattern recurs across projects, update the relevant `references/templates-*.md` file.
- **Developer rejects a proposed domain in ADOPT mode** → the detection heuristic (which namespace/module led to that suggestion) may be too broad. Note the false-positive signal.
- **Developer needs a stack not in the current template set** (e.g., Ruby, Go, Java) → guide them to create a new standard stub manually via `/spec-os-standard`. Log it as a gap — when enough projects hit the same missing stack, it warrants adding a new template.

These observations are not saved automatically. If a pattern repeats across enough runs to constitute real framework debt, raise it as a `Suggested Improvement` and the framework maintainer can update the reference templates.
