---
name: spec-os-discover
description: Scan a codebase and extract real coding conventions into spec-os standards files. Use this skill when the developer runs /spec-os-discover, wants to populate standard stubs after /spec-os-init, wants to refresh standards after a major refactor, or asks to discover, extract, or document existing coding patterns or conventions in the project. Also use it when standards files are still marked as STUB and the developer wants to replace them with actual project conventions.
---

# /spec-os-discover

## Goal

Populate `spec-os/standards/` with the conventions that actually exist in the codebase — not invented rules. Every proposed standard requires developer approval before being written.

## Syntax

```
/spec-os-discover [category]
```

| Argument | Required | Values |
|----------|----------|--------|
| `category` | No | `global` \| `backend` \| `frontend` — scans all if omitted |

---

## Step 1 — Verify prerequisites

Read `spec-os/standards/index.yml`. If not found, stop:

```
spec-os/standards/index.yml not found.
Run /spec-os-init first to install the spec-os framework.
```

Also read `spec-os/config.yaml` to confirm the project stack. Report:

```
Scope: {global | backend | frontend | all}
Stack: {stack from config.yaml}
Standards to scan: {list of files from index.yml matching scope}
```

---

## Step 2 — Scan codebase

Scan the codebase to find patterns that are demonstrably used — not patterns you think should be used. Use `Glob` and `Grep` to gather evidence.

For detailed scan strategies per standard file (what to grep for, which files to examine, what signals to look for), read `references/scan-patterns.md`.

**Key principle:** if the codebase contains mixed or inconsistent patterns, surface both — never silently pick one. The developer decides which is canonical.

---

## Step 3 — Propose one standard at a time

For each standard file in scope, present the proposed content to the developer. Process each file individually — batching multiple proposals creates confusion about what is being approved.

```
─────────────────────────────────────────────────
Standard: spec-os/standards/{category}/{file}.md
─────────────────────────────────────────────────

{full proposed content}

─────────────────────────────────────────────────
Write this standard? [y / n / edit]
```

- **y** — write as proposed
- **n** — skip, leave as STUB
- **edit** — developer provides corrections; apply and ask again before writing

If the file already has content (not STUB): present a diff-style proposal instead of a full replacement and ask: "Update with extracted patterns? [y / n / edit]"

---

## Step 4 — Write approved standards

Write each approved file. Replace the STUB status header with:

```markdown
> Status: EXTRACTED — {ISO-date}
> Managed by: /spec-os-standard | Keywords: {from index.yml}
```

Preserve any content the developer already wrote above the STUB marker.

---

## Step 5 — Report

```
/spec-os-discover complete.

Updated:   {list of files written}
Skipped:   {list of files left as STUB}
Gaps:      {patterns not found — no content extracted}
Conflicts: {inconsistencies found — need developer resolution}

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
