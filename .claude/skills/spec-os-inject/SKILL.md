---
name: spec-os-inject
description: Load only the standards relevant to the current task from spec-os/standards/ and return their content for injection into a subagent's context. Called internally by /spec-os-implement — not typically invoked directly by the developer. Use this skill when an implementation session needs to inject standards context before delegating to a backend-dev or frontend-dev subagent, or whenever task-relevant standards need to be loaded based on keywords and stack.
---

# /spec-os-inject

## Goal

Return the content of only the standard files relevant to the current task — keeping subagent context lean and focused rather than loading every standard regardless of relevance.

## Syntax

```
/spec-os-inject [keywords] [subagent-type]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `keywords` | Yes | Space-separated task keywords (e.g. `dotnet testing error-handling`) |
| `subagent-type` | No | `backend` \| `frontend` — scopes matching to the relevant category |

This skill does not write anything. It reads and returns.

---

## Step 1 — Read the index

Read `spec-os/standards/index.yml`.

If not found, return immediately:

```
[spec-os-inject] spec-os/standards/index.yml not found — no standards injected.
Ensure /spec-os-init has been run in this project.
```

---

## Step 2 — Enrich keywords with stack

Read `spec-os/config.yaml` to get the `project.stack` field. Add the stack value as an implicit keyword so that stack-specific standards are always included without the caller having to remember to pass them.

For example: if `stack: dotnet`, the keyword `dotnet` is added to the match set even if not explicitly provided.

If the active feature folder is known (from context), also read that feature's `spec.md` frontmatter for its `stack` field — this overrides the project-level default if different.

---

## Step 3 — Match keywords against index

For each entry in `index.yml`, check whether any keyword in the enriched set appears in that entry's `keywords` list (case-insensitive).

Apply subagent-type filter — this prevents injecting irrelevant standards into a specialized agent's context:

| subagent-type | Include categories |
|---------------|--------------------|
| `backend` | `global` + `backend` |
| `frontend` | `global` + `frontend` |
| (omitted) | all categories |

---

## Step 4 — Load matched files

Read each matched standard file from disk. If a file is missing (exists in index but not on disk — e.g., still at STUB stage), skip it and note it:

```
[spec-os-inject] Warning: spec-os/standards/{path} referenced in index but not found on disk — skipping.
```

---

## Step 5 — Return injected content

Return all matched content concatenated, with clear section separators so the receiving subagent can parse the boundaries:

```
## Injected Standards

### {category}/{standard}
> Keywords matched: {which keywords triggered this file}

{full file content}

---

### {category}/{standard}
> Keywords matched: {which keywords triggered this file}

{full file content}

---
```

If no files matched:

```
[spec-os-inject] No matching standards for keywords: {keywords}
Standards will not be injected into this session.
```

---

## Rules

- **Read-only.** Never write, modify, or create files.
- **Return full content.** Do not summarize or truncate standard file contents — the subagent needs complete rules to apply them correctly.
- **Always include stack keywords.** A task about testing in a .NET project should get `backend/testing` AND `backend/dotnet`, even if the caller only passed `testing`.
- **Fail gracefully.** Missing files are warnings, not errors. Proceed with whatever can be loaded.
- **Stay fast.** This skill is called at the start of every implementation session — keep reads minimal and return promptly.

---

## Self-improvement

`/spec-os-inject` is only as useful as the standards it injects. After an implementation session, if the developer notices that relevant standards were missing or the wrong standards were loaded:
- Missing standards → run `/spec-os-standard` to create them, or `/spec-os-discover` to extract them
- Wrong keyword mapping → run `/spec-os-standard {standard-path}` to update the `keywords` field, then update `index.yml`
- Wrong subagent-type filter → report as a suggested improvement on the feature session log
