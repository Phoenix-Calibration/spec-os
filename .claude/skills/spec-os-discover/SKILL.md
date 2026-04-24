---
name: spec-os-discover
description: Create and populate spec-os/standards/ with real coding conventions. Use this skill when the developer runs /spec-os-discover, wants to build standards after /spec-os-init, wants to refresh standards after a major refactor, or asks to discover, extract, or document existing coding patterns or conventions in the project. Can bootstrap standards from docs/design/ when no codebase exists yet. Also use it when the developer wants to replace or update existing standards with actual project conventions.
---

# /spec-os-discover

## Goal

Create and populate `spec-os/standards/` with conventions grounded in reality — extracted from code or derived from design decisions, never invented. Every proposed standard requires developer approval before being written.

## Syntax

```
/spec-os-discover [category]
```

| Argument | Required | Values |
|----------|----------|--------|
| `category` | No | `global` \| `backend` \| `frontend` — scans all if omitted |

---

## Step 1 — Verify prerequisites and detect sources

Check `spec-os/config.yaml` exists. If not found:
```
spec-os/ not found. Run /spec-os-init first.
```

Read `spec-os/config.yaml` to confirm the project stack.

If `docs/design/01-stack.md` exists: read it for authoritative stack detail (frameworks, versions, libraries). Use this to determine which stack-specific standard files apply (e.g., `backend/dotnet.md` vs `backend/python.md`). Takes priority over the `stack` field in config.yaml.

Detect available sources:
- **Code source:** check if source files exist in the repo beyond `spec-os/` (non-empty codebase)
- **Design source:** check if `docs/design/` exists; if so, note which base files are present (`00-overview.md`, `01-stack.md`, etc.)

If `spec-os/standards/` does not exist: create the directory. It will be populated as standards are approved.

Report:
```
Scope:   {global | backend | frontend | all}
Stack:   {stack from config.yaml}
Sources:
  Code:    {found — scanning {N} source files | not found}
  Design:  {found — {list of docs/design/ base files present} | not found}
```

If code source detected: delegate an initial structural survey to an Explore subagent before running per-standard scans:

```
Analyze this codebase and return:
1. Folder structure and top-level organization
2. Main technology stack (languages, frameworks, versions)
3. General naming conventions observed (files, classes, functions, variables)
4. Dominant architectural patterns (layered, feature-based, etc.)
5. Any notable code patterns or idioms used consistently

Do not modify any files. Return findings only.
```

Use Explore findings to calibrate subsequent Glob/Grep scans in Step 2 — target the right directories and file types instead of scanning broadly.

If neither source found:
```
No code or design documents found.
Standards can still be created manually with /spec-os-standard.
Proceed anyway? [y/n]
```

---

## Step 2 — Gather evidence per standard

For each standard in scope, gather evidence from all available sources before proposing content.

**From code** (if code source detected): use `Glob` and `Grep` to find demonstrably used patterns. For detailed scan strategies per standard file, read `references/scan-patterns.md`.

**From `docs/design/`** (if design source detected): read the mapped file(s) for each standard:

| Standard | Design file(s) to read |
|----------|------------------------|
| `global/naming.md` | `08-glossary.md` |
| `global/security.md` | `02-security.md` |
| `backend/architecture.md` | `00-overview.md`, `05-data-model.md`, `06-integrations.md` |
| `backend/patterns.md` | `00-overview.md`, `03-performance.md` |
| `backend/error-handling.md` | `07-error-handling.md` |
| `backend/testing.md` | `01-stack.md` |
| `backend/{stack}.md` | `01-stack.md` |
| `frontend/components.md` | `09-design-system.md` |
| `frontend/state.md` | `01-stack.md` |
| `frontend/{framework}.md` | `01-stack.md` |

Also read any ADRs in `docs/design/adr/` relevant to the standard being populated.

**Key principle:** if mixed or inconsistent patterns are found across sources, surface both — never silently pick one. The developer decides which is canonical.

---

## Step 3 — Propose one standard at a time

For each standard file in scope, present the proposed content to the developer. Process each file individually — batching multiple proposals creates confusion about what is being approved. For the expected section structure of each standard file, read `references/templates-standards.md`.

```
─────────────────────────────────────────────────
Standard: spec-os/standards/{category}/{file}.md
─────────────────────────────────────────────────

{full proposed content}

─────────────────────────────────────────────────
Write this standard? [y / n / edit]
```

- **y** — write as proposed
- **n** — skip, no file created
- **edit** — developer provides corrections; apply and ask again before writing

If the file already exists with content: present a diff-style proposal and ask: "Update with new findings? [y / n / edit]"

---

## Step 4 — Write approved standards

Write each approved file. Use a status header that reflects the evidence source:

```markdown
> Status: EXTRACTED — {ISO-date}        (from code scan)
> Status: DESIGN-DERIVED — {ISO-date}   (from docs/design/ only)
> Status: EXTRACTED + DESIGN-DERIVED — {ISO-date}  (from both)
> Managed by: /spec-os-standard | Keywords: {comma-separated keywords}
```

After writing each file, add or update its entry in `spec-os/standards/index.yml`.

---

## Step 4.5 — Fill docs/design/ stubs (if any)

If `docs/design/` exists: check which stub files still contain `TBD` markers:
- `docs/design/03-performance.md`
- `docs/design/04-metrics.md`
- `docs/design/06-integrations.md`
- `docs/design/07-error-handling.md`
- `docs/design/08-glossary.md`

For each stub found, determine if evidence gathered in Steps 1–4 can fill it:

| Stub file | Can fill if... |
|---|---|
| `06-integrations.md` | External dependencies found (package.json, .csproj, imports) |
| `07-error-handling.md` | Error handling patterns found in codebase |
| `08-glossary.md` | Domain terms identified in code, specs, or docs |
| `03-performance.md` | Performance targets or SLAs found in docs/design/ |
| `04-metrics.md` | KPIs or metrics found in docs/mission.md or roadmap.md |

For each fillable stub, present proposal and gate with developer:

```
─────────────────────────────────────────────────
Design stub: docs/design/{file}
─────────────────────────────────────────────────
{proposed content based on discovered evidence}
─────────────────────────────────────────────────
Write? [y / n / edit]
```

Write approved content. Add status header (`EXTRACTED` or `DESIGN-DERIVED`) matching the evidence source.
Stubs with no available evidence: skip — list in Step 5 report as "no evidence found."

---

## Step 5 — Report

```
/spec-os-discover complete.

Created:      {list of new files written}
Updated:      {list of existing files updated}
Not created:  {list skipped — no evidence found}
Conflicts:    {inconsistencies surfaced — need developer resolution}

Design stubs filled:    {list | none}
Design stubs pending:   {list — no evidence found | none}

Next: refine individual standards with /spec-os-standard
```

---

## Rules

- **Never invent conventions.** Only write what the code demonstrates. If you can't point to specific files as evidence, don't propose it.
- **Never write without approval.** One "y" per file. No exceptions.
- **Surface conflicts explicitly.** Mixed patterns are common in real codebases. Naming them is more useful than hiding them.
- **Scope discipline.** Only touch files under `spec-os/standards/`. Never modify source code, specs, or any other file.
- **Fail gracefully on missing evidence.** If no clear pattern is found for a category, say so and leave the file as STUB.

---

## Self-improvement

After each discovery session, the final report surfaces:
- Standards where the developer resolved a conflict → the resolution becomes the canonical rule (update the standard with `/spec-os-standard` if not already reflected)
- Categories with no evidence found → flag for the developer to fill manually or address in a future session
- Patterns found that have no corresponding standard file → suggest creating one with `/spec-os-standard`

These notes are not saved automatically — if the developer wants to capture them, they can run `/spec-os-standard` to write a new or updated standard immediately.
