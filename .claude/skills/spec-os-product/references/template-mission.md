# Template — docs/mission.md

Use this template when creating or regenerating `docs/mission.md`.
Replace all `{placeholders}` with actual content. Mark gaps as `TBD — fill in manually`.

---

```markdown
# {Product Name}

## Purpose
{One paragraph: what the product does, for whom, and in what context.
Focus on the outcome for the user, not on the technology.}

## Problem solved
{The specific problem this product addresses. Be concrete — avoid generic statements
like "improves efficiency". Describe the friction or gap that existed before this product.}

## Primary users
{List of user types, one per line, with a one-line description of their role and context.}

- **{Role 1}** — {who they are and what they need from the product}
- **{Role 2}** — {who they are and what they need from the product}

## Success criteria
{What success looks like for users — observable outcomes, not internal metrics.
Each criterion should be verifiable from the user's perspective.}

- {Observable outcome 1}
- {Observable outcome 2}

## Success metrics
{Concrete, measurable KPIs that indicate the product is achieving its purpose.
Derived from docs/market-research.md — Measurable outcomes section.
Each metric must have a baseline and a realistic target.}

| KPI | Baseline | Target | Timeframe | How to measure |
|-----|----------|--------|-----------|----------------|
| {metric name} | {current state or "not yet measured"} | {realistic target} | {3 / 6 / 12 months} | {measurement method} |

## Scope

### In scope
{Main capabilities being built. Use a short list — this is not a feature backlog.
Each item should represent a capability the user can actually use.}

- {Capability 1}
- {Capability 2}

### Out of scope
{Explicit exclusions — capabilities that have been considered and deliberately excluded.
This is as important as the in-scope list. It prevents scope creep and aligns expectations.}

- {Excluded capability 1} — {brief reason}
- {Excluded capability 2} — {brief reason}

## Constraints
{Technical, business, or regulatory constraints that shape how the product is built.
These are non-negotiable boundaries, not preferences.}

- {Constraint 1}
- {Constraint 2}

## Status
{active development | maintenance | deprecated}
Last updated: {ISO-date}
```
