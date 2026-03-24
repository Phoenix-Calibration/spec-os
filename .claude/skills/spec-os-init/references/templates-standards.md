# Templates — Standards Layer Files

All files under `spec-os/standards/` created by `/spec-os-init`.

> Note: Only write entries in `index.yml` and only create standard files for the stacks
> declared in `config.yaml`. Do not create stub files for unused stacks.

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

> Status: STUB — populate with project-specific conventions
> Managed by: /spec-os-standard | Keywords: naming, class, variable, file, convention

## File naming

## Class naming

## Variable naming

## Database naming

## API endpoint naming
```

---

## `spec-os/standards/global/commits.md`

```markdown
# Commit Conventions

> Status: STUB — populate with project-specific conventions
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

> Status: STUB — populate with project-specific security rules
> Managed by: /spec-os-standard | Keywords: security, auth, credentials, secrets, env

## Credentials

Never commit credentials, tokens, API keys, or secrets to any file.
Always use environment variables or a secret management solution.

## Input validation

## Authentication

## Sensitive data handling
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

> Status: STUB — populate with project-specific architecture rules
> Managed by: /spec-os-standard | Keywords: architecture, domain, layer, cqrs, aggregate, repository

## Layer structure

## Dependency rules

## Domain boundaries
```

---

## `spec-os/standards/backend/patterns.md`

```markdown
# Backend Patterns

> Status: STUB — populate with project-specific patterns
> Managed by: /spec-os-standard | Keywords: pattern, solid, di, injection, service, handler

## Dependency injection

## Service patterns

## Handler patterns
```

---

## `spec-os/standards/backend/testing.md`

```markdown
# Backend Testing

> Status: STUB — populate with project-specific testing conventions
> Managed by: /spec-os-standard | Keywords: test, unit, integration, coverage, mock

## Unit test conventions

## Integration test conventions

## Coverage requirements

## Test naming
```

---

## `spec-os/standards/backend/error-handling.md`

```markdown
# Error Handling

> Status: STUB — populate with project-specific error handling rules
> Managed by: /spec-os-standard | Keywords: error, exception, handling, response, status-code

## Exception strategy

## API error responses

## Logging on errors
```

---

## `spec-os/standards/backend/dotnet.md`

```markdown
# .NET / C# Standards

> Status: STUB — populate with project-specific .NET patterns
> Managed by: /spec-os-standard | Keywords: dotnet, csharp, net, aspnet, ef, entityframework, linq

## Async patterns

## Result<T> pattern

## EF Core conventions

## DI registration conventions
```

---

## `spec-os/standards/backend/python.md`

```markdown
# Python Standards

> Status: STUB — populate with project-specific Python patterns
> Managed by: /spec-os-standard | Keywords: python, fastapi, django, sqlalchemy, pydantic, async

## Type hints

## Async patterns

## Pydantic usage

## Error handling
```

---

## `spec-os/standards/backend/odoo.md`

```markdown
# Odoo Standards

> Status: STUB — populate with project-specific Odoo patterns
> Managed by: /spec-os-standard | Keywords: odoo, orm, module, wizard, inherit, manifest

## Module structure

## ORM patterns

## Inheritance patterns

## View conventions
```

---

## `spec-os/standards/frontend/components.md`

```markdown
# Frontend Component Standards

> Status: STUB — populate with project-specific component patterns
> Managed by: /spec-os-standard | Keywords: component, react, props, composition, hooks

## Component architecture

## Props conventions

## Composition patterns
```

---

## `spec-os/standards/frontend/state.md`

```markdown
# State Management

> Status: STUB — populate with project-specific state patterns
> Managed by: /spec-os-standard | Keywords: state, context, store, reducer, hook

## Local state

## Global state

## Server state
```

---

## `spec-os/standards/frontend/testing.md`

```markdown
# Frontend Testing

> Status: STUB — populate with project-specific frontend test conventions
> Managed by: /spec-os-standard | Keywords: test, cypress, playwright, data-testid

## Component tests

## E2E tests

## Test selectors
```

---

## `spec-os/standards/frontend/nextjs.md`

```markdown
# Next.js Standards

> Status: STUB — populate with project-specific Next.js patterns
> Managed by: /spec-os-standard | Keywords: nextjs, next, ssr, ssg, app-router, pages, server-component

## App Router conventions

## Data fetching

## Server vs Client components

## Routing patterns
```

---

## `spec-os/standards/frontend/react.md`

```markdown
# React Standards

> Status: STUB — populate with project-specific React patterns
> Managed by: /spec-os-standard | Keywords: react, hooks, component, props, state, context, memo

## Hook patterns

## Performance (memo, useMemo, useCallback)

## Component patterns
```
