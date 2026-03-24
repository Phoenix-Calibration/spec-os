---
name: spec-os-init
description: Install spec-os in a new project, adopt it in an existing one, or update an installed version. Use this skill when the developer runs /spec-os-init, wants to set up spec-os in a project for the first time, is adding spec-os to an existing codebase mid-development, wants to add new domains, or needs to update the spec-os configuration. Also use it when the developer asks to initialize, install, or set up the spec-os framework.
---

# /spec-os-init

## Goal

Create the complete `spec-os/` structure, standards stubs, domain specs, agent files, and `CLAUDE.md` — everything a project needs to start using the spec-os workflow.

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

Check if `docs/mission.md` exists.
- If yes: read it. Extract project name, description, and purpose to pre-fill I.2.
- If no: skip.

### I.2 — Collect project information

Ask the developer in a single request:

```
Project name:
Description (one sentence):
Stack (all that apply): dotnet | python | odoo | nextjs | react | other
Tracker type: ado | github
Cadence format: sprint | milestone | quarter | custom
```

### I.3 — Collect tracker configuration

Ask based on tracker type selected.

**If ado:**
```
ADO organization URL: https://dev.azure.com/{org}
ADO project name:
Repo name (as it appears in git remote):
```

**If github:**
```
GitHub organization:
GitHub repo name:
```

### I.4 — Collect domains

```
What are the bounded domains of this project?
Examples: equipment, billing, auth, reporting, users
Enter as a comma-separated list.
```

Wait for response.

### I.5 — Propose full structure

Present the complete list of files to create. Wait for confirmation before writing anything.

```
Will create:

spec-os/config.yaml
spec-os/version
spec-os/GETTING-STARTED.md
spec-os/standards/index.yml
spec-os/standards/global/  (naming, commits, security, pr-template)
spec-os/standards/backend/  (architecture, patterns, testing, error-handling, {stack})
spec-os/standards/frontend/  (components, state, testing, {stack})   [if frontend stack]
spec-os/specs/_index.md
spec-os/specs/{domain}/spec.md   (one per domain)
spec-os/specs/knowledge-base.md
spec-os/changes/  (empty)
.claude/agents/backend-dev.md
.claude/agents/frontend-dev.md
CLAUDE.md  (thin template — replaces or creates)

Proceed? [y/n]
```

### I.6 — Create files

On confirmation, read all four reference files before writing anything:
- `references/templates-structure.md` — `version`, `config.yaml`, `CLAUDE.md`, `GETTING-STARTED.md`
- `references/templates-standards.md` — `standards/index.yml` + all standard file stubs
- `references/templates-specs.md` — domain spec stubs, `knowledge-base.md`, agent files
- `references/agent-creation-guide.md` — complete guide: all frontmatter fields, spec-os patterns, system prompt structure (apply when writing `.claude/agents/`)

Create all files in this order:

1. `spec-os/version`
2. `spec-os/config.yaml`
3. `spec-os/standards/index.yml` — only include entries for stacks in use
4. `spec-os/standards/global/naming.md`
5. `spec-os/standards/global/commits.md`
6. `spec-os/standards/global/security.md`
7. `spec-os/standards/global/pr-template.md`
8. `spec-os/standards/backend/architecture.md`
9. `spec-os/standards/backend/patterns.md`
10. `spec-os/standards/backend/testing.md`
11. `spec-os/standards/backend/error-handling.md`
12. Stack-specific backend: `spec-os/standards/backend/{dotnet|python|odoo}.md`
13. If frontend stack selected:
    - `spec-os/standards/frontend/components.md`
    - `spec-os/standards/frontend/state.md`
    - `spec-os/standards/frontend/testing.md`
    - `spec-os/standards/frontend/{nextjs|react}.md`
14. `spec-os/specs/_index.md`
15. `spec-os/specs/{domain}/spec.md` — one per declared domain
16. `spec-os/specs/knowledge-base.md`
17. `spec-os/changes/.gitkeep`
18. `spec-os/archive/.gitkeep`
19. `.claude/agents/backend-dev.md`
20. `.claude/agents/frontend-dev.md`
21. `spec-os/GETTING-STARTED.md`
22. `CLAUDE.md`

### I.7 — Report and next steps

```
spec-os v1.0.0 installed.

Created:
  spec-os/config.yaml         ← fill in tracker credentials if not set
  spec-os/standards/          ← {N} standards stubs — run /spec-os-discover to populate
  spec-os/specs/              ← {N} domain stubs — fill with known system behavior
  .claude/agents/             ← backend-dev and frontend-dev (native Claude Code subagents)
  CLAUDE.md                   ← verify project identity section

Next steps:
  1. Review spec-os/config.yaml — verify tracker details and cadence
  2. Run /spec-os-discover to extract coding standards from your codebase
  3. Fill spec-os/specs/{domain}/spec.md with known system behavior
  4. When ready: /spec-os-brainstorm or /spec-os-bug
```

---

## ADOPT mode

Use when: existing project, adopting spec-os mid-development.

### A.1 — Scan codebase

Scan the project to identify:
- **Namespaces / modules / packages** → domain candidates
- **Technology stack** → confirms or refines stack selection
- **Existing `CLAUDE.md`** → read if present, do NOT modify yet
- **Existing `docs/mission.md`** → read if present

Report findings:
```
Codebase analysis:
  Detected stack: {stack(s)}
  Domain candidates (from namespaces/modules): {list with reason}
  Existing CLAUDE.md: found | not found
  Existing docs/mission.md: found | not found
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

Same as Initialize steps I.2 and I.3 (tracker and cadence details).

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
4. Wait for explicit approval before writing

**For domain spec stubs:** seed each `spec-os/specs/{domain}/spec.md` with content extracted from the scan:
- Known entities from the domain (from class names, DB tables, module structure)
- Observed behaviors from comments, README, or tests
- Mark all content: `# STUB — review and complete with actual behavior`

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
3. Both
```

### U.3 — Add new domains

If selected:
```
Current domains: {list from _index.md}
New domains to add:
```

Wait for input. Create stubs (template in `references/templates-specs.md`). Update `spec-os/specs/_index.md`.

### U.4 — Update config schema

If selected: read current `config.yaml`. Propose additions for new fields in the current version. Dev approves before writing.

### U.5 — Write version

Write `1.0.0` to `spec-os/version`.

---

## Rules

- **Propose before creating.** Always show the full file list (step I.5 / A.4) and wait for an explicit "y" before writing any file. A partial install — where only some files were created — is harder to debug than no install at all.
- **Never overwrite CLAUDE.md without explicit approval.** In ADOPT mode the existing CLAUDE.md may contain rules the team depends on. Always read it, show the proposed replacement, and highlight what would be removed before touching it.
- **Only create standard files for stacks in use.** Writing `dotnet.md` into a Next.js-only project adds noise to `/spec-os-inject` matches and creates false confidence. Stick to the stacks declared in the developer's answers — never create stubs for stacks not in use.
- **Never write credentials to config.yaml.** Organization URLs and project names are safe; authentication tokens and PATs are not. Leave auth fields as `{placeholder}` with a comment pointing the developer to their secret management solution.
- **Domain spec stubs are seeds, not specs.** In ADOPT mode, extracted content is marked `STUB` explicitly. The developer must verify and complete it. Never present extracted stubs as authoritative or complete system documentation.
- **One mode per session.** If the developer asks to initialize and add a domain in the same breath, complete the primary mode first, then guide them to `/spec-os-init update`. Mixing modes mid-run creates inconsistent state.

---

## Self-improvement

After a successful installation, watch for these signals that templates or detection logic need refinement:

- **Developer immediately modifies a generated file** → the template content may be off for this type of project. Note which file and what changed — if the pattern recurs across projects, update the relevant `references/templates-*.md` file.
- **Developer rejects a proposed domain in ADOPT mode** → the detection heuristic (which namespace/module led to that suggestion) may be too broad. Note the false-positive signal.
- **Developer needs a stack not in the current template set** (e.g., Ruby, Go, Java) → guide them to create a new standard stub manually via `/spec-os-standard`. Log it as a gap — when enough projects hit the same missing stack, it warrants adding a new template.

These observations are not saved automatically. If a pattern repeats across enough runs to constitute real framework debt, raise it as a `Suggested Improvement` and the framework maintainer can update the reference templates.
