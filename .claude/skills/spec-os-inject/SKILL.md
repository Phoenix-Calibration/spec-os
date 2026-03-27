---
name: spec-os-inject
description: Match standards relevant to the current task from spec-os/standards/ and return their file paths for injection into a subagent's context. Called internally by /spec-os-implement — not typically invoked directly by the developer. Use this skill when an implementation session needs to inject standards context before delegating to a backend-dev or frontend-dev subagent, or whenever task-relevant standards need to be selected based on keywords and stack.
---

# /spec-os-inject

## Goal

Return the file paths of only the standard files relevant to the current task. The dev-agent reads them directly — content never transits through the orchestration context, keeping it lean.

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

## Step 2 — Enrich keywords with stack and domain

Read `spec-os/config.yaml` to get the `project.stack` field. Add the stack value as an implicit keyword so that stack-specific standards are always included without the caller having to remember to pass them.

For example: if `stack: dotnet`, the keyword `dotnet` is added to the match set even if not explicitly provided.

If the active feature folder is known (from context), also read that feature's `spec.md` frontmatter for:
- `stack` field — overrides the project-level default if different
- `domain` field — add it as an implicit keyword so that domain-specific standards (e.g., `backend/equipment.md`) are always included when working on that domain

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

## Step 4 — Verify matched files exist

For each matched entry, check whether the standard file exists on disk. If a file is missing (exists in index but not on disk — e.g., still at STUB stage), skip it and note it:

```
[spec-os-inject] Warning: spec-os/standards/{path} referenced in index but not found on disk — skipping.
```

Do not read file contents.

---

## Step 5 — Return matched file paths

Return the list of matched file paths so the receiving dev-agent can read them directly:

```
## Injected Standards — File Paths

- spec-os/standards/{category}/{standard}.md  (matched: {keywords})
- spec-os/standards/{category}/{standard}.md  (matched: {keywords})
```

If no files matched:

```
[spec-os-inject] No matching standards for keywords: {keywords}
standards-paths: none
```

---

## Rules

- **Read-only.** Never write, modify, or create files.
- **Return file paths only.** Do not read or return file contents — the dev-agent reads them directly. This keeps the orchestration context lean.
- **Always include stack keywords.** A task about testing in a .NET project should get `backend/testing` AND `backend/dotnet`, even if the caller only passed `testing`.
- **Fail gracefully.** Missing files are warnings, not errors. Proceed with whatever can be loaded.
- **Stay fast.** This skill is called at the start of every implementation session — keep reads minimal and return promptly.

---

## Self-improvement

`/spec-os-inject` is only as useful as the standards it injects. After an implementation session, if the developer notices that relevant standards were missing or the wrong standards were loaded:
- Missing standards → run `/spec-os-standard` to create them, or `/spec-os-discover` to extract them
- Wrong keyword mapping → run `/spec-os-standard {standard-path}` to update the `keywords` field, then update `index.yml`
- Wrong subagent-type filter → report as a suggested improvement on the feature session log
