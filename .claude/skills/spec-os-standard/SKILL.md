---
name: spec-os-standard
description: Update an existing standard or create a new one in spec-os/standards/. Use this skill when the developer runs /spec-os-standard, wants to edit, refine, or add a coding convention, asks to update a standard, add a rule, change a convention, or manage the standards files. Also use it when a standard is outdated after a refactor, when /spec-os-discover surfaces a conflict the developer has resolved, or when the developer wants to document a pattern that doesn't exist yet.
---

# /spec-os-standard

## Goal

Update or create a standard in `spec-os/standards/` — the canonical source of project conventions. Every change is proposed to the developer in full before being written.

## Syntax

```
/spec-os-standard [standard-path]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `standard-path` | No | Relative to `spec-os/standards/` (e.g. `backend/testing`) — prompted if omitted |

---

## Step 1 — Identify the target

**If `standard-path` is provided:** resolve it to a file under `spec-os/standards/`. Check whether it exists.

**If omitted:** read `spec-os/standards/index.yml` and ask:

```
Which standard would you like to update or create?

Existing standards:
  global/   naming | commits | security | pr-template
  backend/  architecture | patterns | testing | error-handling | {stack}
  frontend/ components | state | testing | {stack}

Enter a path (e.g. backend/testing) or a new path to create a new standard.
```

---

**If the file does not exist** → CREATE flow (Step 2a)

**If the file exists** → UPDATE flow (Step 2b)

---

## Step 2a — Create a new standard

Gather the information needed before drafting content:

```
Creating: spec-os/standards/{path}.md

Category: global | backend | frontend
Description (one line for index.yml):
Keywords (comma-separated — these drive /spec-os-inject matching):
What should this standard cover? Describe the rules or paste existing conventions.
```

Draft the full standard content from the developer's input. Proceed to Step 3.

---

## Step 2b — Read and display current content

Read the standard file. Show it to the developer before asking what to change — they need to see the current state to give useful direction:

```
Current: spec-os/standards/{path}.md
────────────────────────────────────────
{file content}
────────────────────────────────────────
What would you like to change or add?
```

---

## Step 3 — Draft and propose

Draft the full updated content. Show the complete proposed file — not a diff — so the developer sees exactly what will be written:

```
Proposed: spec-os/standards/{path}.md
────────────────────────────────────────
{full proposed content}
────────────────────────────────────────
Apply? [y / n / edit]
```

- **y** — write
- **n** — cancel
- **edit** — developer provides corrections; revise the draft and show it again before writing

---

## Step 4 — Write

Write the approved content. Update the status header to reflect this session:

```markdown
> Status: UPDATED — {ISO-date}
> Managed by: /spec-os-standard | Keywords: {keywords}
```

For new standards, use `CREATED` instead of `UPDATED`.

---

## Step 5 — Update index.yml if needed

`index.yml` is what makes `/spec-os-inject` work. If keywords changed or this is a new standard, propose the index update:

```
Update spec-os/standards/index.yml?

{diff of what changes — new entry or updated keywords}

[y / n]
```

Write on approval. Do not skip this step — an unindexed standard will never be injected.

---

## Step 6 — Confirm

```
Done.

Written:  spec-os/standards/{path}.md
{If index changed}: Updated: spec-os/standards/index.yml

/spec-os-inject will now include this standard when keywords [{keywords}] are matched.
```

---

## Rules

- **Propose before writing.** The developer must see and approve the full file content before anything is written. This applies even for small changes.
- **Show the complete file, not just the diff.** Diffs are ambiguous — showing the full proposed file makes it clear exactly what will be on disk.
- **Always update index.yml when keywords change.** A standard that isn't indexed won't reach subagents. This is the most common way standards silently stop working.
- **One standard per session.** If the developer wants to update multiple standards, handle them one at a time — a separate full approval cycle for each.
- **Scope discipline.** Only touch `spec-os/standards/` files and `spec-os/standards/index.yml`. Never modify specs, tasks, or source code.

---

## Self-improvement

Standards become more useful over time when they reflect what was actually learned during implementation. Common moments to update a standard:

- After `/spec-os-verify` surfaces a conventions violation → update the relevant standard to prevent recurrence
- After a session-log lesson is tagged as generalizable → consider whether it belongs in a standard
- After a major refactor changes the architectural patterns in use → update `backend/architecture` or `backend/patterns`
- After `/spec-os-discover` surfaces a conflict the developer resolves → update the standard to reflect the canonical decision

These updates are not automatic — the developer initiates them. The pattern here is: implementation reveals a gap → developer notes it → runs `/spec-os-standard` to close it.
