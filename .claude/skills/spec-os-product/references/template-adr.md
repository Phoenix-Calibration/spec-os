# Template — docs/design/adr/{NNN}-{slug}.md

Use this template when creating an Architecture Decision Record (ADR).

ADRs document significant architectural decisions — choices that are hard to reverse,
affect multiple systems or teams, or establish patterns that will be followed going forward.
They are not for implementation details or task-level choices.

## Naming convention

```
docs/design/adr/
  001-{slug}.md     ← sequential numbering, zero-padded to 3 digits
  002-{slug}.md
  ...
```

Slug is a short kebab-case description of the decision topic.
Example: `001-use-event-sourcing.md`, `002-authentication-strategy.md`

## When to write an ADR

- Choosing between two or more viable technical approaches
- Deciding to adopt a new framework, library, or service
- Establishing a pattern that will be followed across the codebase
- Making a trade-off that accepts known downsides
- Superseding a previous architectural decision

## Template

```markdown
# ADR-{NNN} — {Title}

> Status: {proposed | accepted | superseded | deprecated}
> Date: {ISO-date}
> Supersedes: {ADR-NNN — link, if applicable}
> Superseded by: {ADR-NNN — link, if applicable}

## Context
{The situation, problem, or constraint that requires a decision.
What is the current state? What forces are at play?
What makes this decision necessary now?}

## Decision
{The decision made — stated clearly and unambiguously.
Use active voice: "We will use X" not "X will be used".}

## Options considered

### Option A — {Name}
{Description of the option.}

**Pros:**
- {advantage}

**Cons:**
- {disadvantage}

### Option B — {Name}
{Description of the option.}

**Pros:**
- {advantage}

**Cons:**
- {disadvantage}

## Rationale
{Why this option was chosen over the alternatives.
Be honest about trade-offs accepted. Future readers need to understand
what was known and prioritized at decision time.}

## Consequences
{What changes as a result of this decision.
Include both positive outcomes and accepted trade-offs or known limitations.}

### Positive
- {expected benefit}

### Negative / trade-offs accepted
- {known downside or limitation}

## References
- {Link to relevant issue, PR, discussion, or external resource}
```

---

## adr/README.md

This file is the index for the `adr/` subfolder. Create it when initializing the design folder.

```markdown
# adr/

Architecture Decision Records for {Product Name}.
One file per significant architectural decision.

## Naming convention

{NNN}-{kebab-title}.md — sequential, zero-padded to 3 digits.

Examples:
  001-clean-architecture.md
  002-cqrs-mediatr.md
  003-authentication-strategy.md

## Status values

| Status | Meaning |
|--------|---------|
| `proposed` | Under discussion — not yet adopted |
| `accepted` | In effect — the system follows this decision |
| `superseded` | Replaced by a newer ADR (link to successor in the file) |
| `deprecated` | No longer applicable — kept for historical context |

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| — | — | — | — |

## Agent instructions

- Never contradict an accepted ADR without flagging it explicitly to the developer
- If an implementation decision conflicts with an accepted ADR: stop and report before proceeding
- When a new ADR file is created: add a row to the Index table above
- When an ADR is superseded: update its status here and add `Superseded by` to the old file
```
