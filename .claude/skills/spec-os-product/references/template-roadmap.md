# Template — docs/roadmap.md

Use this template when creating or regenerating `docs/roadmap.md`.
Replace all `{placeholders}` with actual content. Mark gaps as `TBD — fill in manually`.

This is a **strategic direction document**, not a sprint plan or feature backlog.
Specific features are tracked in `spec-os/changes/` and the tracker.

---

```markdown
# Roadmap — {Product Name}

> This is a strategic direction document, not a sprint plan.
> Specific features are tracked in spec-os/changes/ and the tracker.

## North star
{The long-term vision in one sentence. Where does this product want to be in 2–3 years?
This should be ambitious but directionally stable — it should not change with every sprint.}

## Current focus
{What the team is building right now, at a high level. This section changes most frequently.
Describe themes or capabilities, not specific tasks. Each item must have an expected outcome.}

| Theme / Capability | Expected outcome | KPI | Target |
|---|---|---|---|
| {Current theme 1} | {what changes for users if this succeeds} | {metric} | {target} |
| {Current theme 2} | {what changes for users if this succeeds} | {metric} | {target} |

## Potential future capabilities
{Unordered list of capabilities that might be built — not committed, not prioritized.
Each item includes the outcome it would produce if built.
Remove items that are formally rejected.}

- {Possible future capability 1} → *expected outcome: {what it would change}*
- {Possible future capability 2} → *expected outcome: {what it would change}*
- {Possible future capability 3} → *expected outcome: {what it would change}*

## Deliberately excluded
{Capabilities that have been considered and formally rejected — with a brief reason.
This section prevents the same ideas from being re-proposed repeatedly.}

- {Excluded capability 1} — {reason: out of scope, solved by another tool, too complex, etc.}
- {Excluded capability 2} — {reason}

Last updated: {ISO-date}
```
