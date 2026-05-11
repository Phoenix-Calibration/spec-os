# Prompt: Import Audit Improvements

Use this prompt when you want to extract "Suggested improvements" from an
audit entry (or a full audit-log) and load them into `improvements-backlog.md`.

---

## How to invoke

Paste this prompt in a new message followed by the audit text:

```
/import-audit

[paste audit-log content here]
```

Or just say: "import audit improvements" and paste the content.

---

## Prompt instructions (for Claude)

The user has pasted audit text below. Follow these steps exactly:

### Step 1 — Parse entries

Scan the pasted text for all audit entries matching the pattern:
```
## Entry — {YYYY-MM-DD HH:MM} — {mode}
```

For each entry found, extract:
- `datetime`: the date and time from the entry header (YYYY-MM-DD HH:MM).
  If an entry has no time (old format `YYYY-MM-DD` only), ask the user for the
  time or use `00:00` as fallback.
- `improvements`: every line under `### Suggested improvements`
  that matches the format:
  `- {target-type}: {target-id} | severity: {low|medium|high} | {description}`

Skip entries that have no `### Suggested improvements` section or where
the section is empty / contains only `{placeholder}` text.

### Step 2 — Ask for project identifier

Ask the user:
> "¿Cuál es el identificador del proyecto fuente? (ej: my-app, proj-x)"

Wait for the answer. Use it as `{project}` in the Source column.

### Step 3 — Read current backlog

Read `improvements-backlog.md` to find the highest existing `IMP-xxx` ID.
Next ID = highest + 1. If the file has no entries yet, start at `IMP-001`.

### Step 4 — Deduplicate

For each extracted improvement, check if an entry with the same
`source date + description` already exists in the backlog. Skip duplicates silently.

### Step 5 — Preview

Show the rows to be inserted:

```
Improvements to insert:

| ID      | Source                  | Target               | Severity | Description          | Status  |
|---------|-------------------------|----------------------|----------|----------------------|---------|
| IMP-001 | 2026-05-11 14:32 / proj-x | skill: spec-os-audit | high     | {description}        | pending |
...

Insert into improvements-backlog.md? [y / n]
```

### Step 6 — Insert

If the user confirms:
- Append the new rows to the table in `improvements-backlog.md`
- Preserve existing rows exactly as-is

Report:
```
Done. {N} improvement(s) added to improvements-backlog.md.
Skipped: {M} duplicate(s).
```
