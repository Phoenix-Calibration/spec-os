# Session Log Template

Use this template to write a new entry in `spec-os/changes/{feature}/session-log.md`.
Create the file if it does not exist (first task of the feature).

---

## File header (first entry only)

```markdown
# Session Log — F{ID}
```

---

## Entry template

```markdown
---

## {Task-ID} — {ISO-date}

### What was done

### Decisions made
- {Decision}: {reason} -> impacts: {T-IDs if any}

### Spec changes
{none | -> see spec-delta.md entry for this session}

### Blockers found
- {blocker}: {resolution | pending}

### Lessons (generalizable: yes | no)
- {lesson} [pending: true]

### Context for {Next-Task-ID}
Specific facts: file paths, registered services, discovered constraints.
5-20 lines. This is the most critical field.

### Verify result
{not-run | pending | passed | failed}
```
