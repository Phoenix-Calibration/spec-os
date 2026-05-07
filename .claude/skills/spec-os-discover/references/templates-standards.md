# Templates — Standards Layer Files

Structural reference for `spec-os/standards/` files. Used by `/spec-os-discover` when proposing content for each standard. Defines the expected sections per file and the `index.yml` schema.

> Note: Only write entries in `index.yml` and only create standard files for the stacks
> declared in `config.yaml`. Do not create files for unused stacks.

---

## Standard file structure

Every standard file documents three layers per section:

- **Current state** — what the codebase actually does today (extracted from code scans)
- **Best practice** — what the rule should be (informed by fetched external sources)
- **Migration path** — concrete steps to close the gap, with effort and risk notes

This structure is mandatory. Never propose a standard that documents only best practices without also capturing current state and a migration path.

---

## `spec-os/standards/index.yml`

```yaml
global:
  naming:
    description: File, class, variable, and database naming conventions
    keywords: [naming, class, variable, file, convention]
  commits:
    description: Commit message format, scope, tracker linking
    keywords: [commit, git, message, branch]
  security:
    description: Security boundaries, credentials, sensitive data rules
    keywords: [security, auth, credentials, secrets, env]
  pr-template:
    description: Pull request body template and checklist
    keywords: [pr, pull-request, review]

backend:
  architecture:
    description: Layered architecture, DDD, CQRS, Clean Architecture patterns
    keywords: [architecture, domain, layer, cqrs, aggregate, repository]
  patterns:
    description: Implementation patterns, dependency injection, SOLID
    keywords: [pattern, solid, di, injection, service, handler]
  testing:
    description: Unit and integration test conventions, coverage requirements
    keywords: [test, unit, integration, coverage, mock]
  error-handling:
    description: Error types, exception patterns, API error responses
    keywords: [error, exception, handling, response, status-code]
  # Stack-specific — include only the entry matching config.yaml stack
  dotnet:
    description: .NET/C# patterns, async, DI, EF Core, Result<T>, exception strategy
    keywords: [dotnet, csharp, net, aspnet, ef, entityframework, linq]
  python:
    description: Python patterns, type hints, async, Pydantic, error handling
    keywords: [python, fastapi, django, sqlalchemy, pydantic, async]
  odoo:
    description: Odoo module patterns, ORM, views, wizards, inheritance
    keywords: [odoo, orm, module, wizard, inherit, manifest]

frontend:
  components:
    description: Component architecture, props, composition patterns
    keywords: [component, react, props, composition, hooks]
  state:
    description: State management, context, local state patterns
    keywords: [state, context, store, reducer, hook]
  testing:
    description: Component tests, e2e, selectors
    keywords: [test, cypress, playwright, data-testid]
  # Stack-specific — include only the entry matching config.yaml stack
  nextjs:
    description: Next.js patterns, App Router, SSR/SSG, data fetching, routing
    keywords: [nextjs, next, ssr, ssg, app-router, pages, server-component]
  react:
    description: React patterns, hooks, state, component composition, performance
    keywords: [react, hooks, component, props, state, context, memo]
```

---

## `spec-os/standards/global/naming.md`

```markdown
# Naming Conventions

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: naming, class, variable, file, convention

## File naming

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Class naming

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Variable naming

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Database naming

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## API endpoint naming

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/global/commits.md`

```markdown
# Commit Conventions

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: commit, git, message, branch

## Commit message format

`{type}({domain}): {description} [{feature-id}-{task-id}]`

Types: feat | fix | refactor | test | docs | chore

## Branch naming

`{type}/{feature-id}-{description}`

## Commit scope

Each commit corresponds to one spec-os task. One task = one atomic commit.

## Tracker linking

Include feature ID and task ID in every commit message.
```

---

## `spec-os/standards/global/security.md`

```markdown
# Security Standards

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: security, auth, credentials, secrets, env

## Credentials

### Current state

### Best practice
Never commit credentials, tokens, API keys, or secrets to any file.
Always use environment variables or a secret management solution.

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Input validation

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Authentication

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Sensitive data handling

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/global/pr-template.md`

```markdown
## Summary
{brief description}

## User Story
{title} — {tracker-url}

## Acceptance Criteria verified
- [x] AC-1: {description}

## Tests
- Unit: {N passing}
- Integration: {N passing}
- Coverage: {%}

## Spec reference
spec-os/changes/{feature}/spec.md
verify-report.md: spec-os/changes/{feature}/verify-report.md

## Files changed
{list from task scopes}
```

---

## `spec-os/standards/backend/architecture.md`

```markdown
# Backend Architecture

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: architecture, domain, layer, cqrs, aggregate, repository

## Layer structure

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Dependency rules

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Domain boundaries

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/backend/patterns.md`

```markdown
# Backend Patterns

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: pattern, solid, di, injection, service, handler

## Dependency injection

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Service patterns

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Handler patterns

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/backend/testing.md`

```markdown
# Backend Testing

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: test, unit, integration, coverage, mock

## Unit test conventions

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Integration test conventions

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Coverage requirements

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Test naming

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/backend/error-handling.md`

```markdown
# Error Handling

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: error, exception, handling, response, status-code

## Exception strategy

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## API error responses

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Logging on errors

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/backend/dotnet.md`

```markdown
# .NET / C# Standards

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: dotnet, csharp, net, aspnet, ef, entityframework, linq

## Async patterns

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Result<T> pattern

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## EF Core conventions

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## DI registration conventions

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/backend/python.md`

```markdown
# Python Standards

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: python, fastapi, django, sqlalchemy, pydantic, async

## Type hints

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Async patterns

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Pydantic usage

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Error handling

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/backend/odoo.md`

```markdown
# Odoo Standards

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: odoo, orm, module, wizard, inherit, manifest

## Module structure

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## ORM patterns

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Inheritance patterns

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## View conventions

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/frontend/components.md`

```markdown
# Frontend Component Standards

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: component, react, props, composition, hooks

## Component architecture

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Props conventions

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Composition patterns

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/frontend/state.md`

```markdown
# State Management

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: state, context, store, reducer, hook

## Local state

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Global state

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Server state

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/frontend/testing.md`

```markdown
# Frontend Testing

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: test, cypress, playwright, data-testid

## Component tests

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## E2E tests

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Test selectors

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/frontend/nextjs.md`

```markdown
# Next.js Standards

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: nextjs, next, ssr, ssg, app-router, pages, server-component

## App Router conventions

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Data fetching

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Server vs Client components

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Routing patterns

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```

---

## `spec-os/standards/frontend/react.md`

```markdown
# React Standards

> Status: {EXTRACTED | DESIGN-DERIVED | EXTRACTED + DESIGN-DERIVED} — {ISO-date}
> Managed by: /spec-os-standard | Keywords: react, hooks, component, props, state, context, memo

## Hook patterns

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Performance (memo, useMemo, useCallback)

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 

## Component patterns

### Current state

### Best practice

### Migration path
Steps:
1. 
Effort: {low | medium | high}
Risk: 
```
