# Spec-OS: File Templates

Copy-paste reference for all spec-os managed files.

---

## spec-os/config.yaml

```yaml
spec-os-version: "1.0.0"

project:
  name: {project-name}
  description: {one-sentence description}
  stack: dotnet | odoo | nextjs | python | other
  cadence-format: sprint  # sprint | milestone | quarter | custom

tracker:
  default: ado
  repos:
    - name: {repo-name}
      type: ado
      organization: {https://dev.azure.com/org}
      project: {ado-project-name}
    - name: {other-repo}
      type: github
      org: {github-org}
      repo: {repo-name}

workflow:
  approval-gates:
    skill-handoffs: explicit    # explicit | auto
    spec-changes: explicit
    destructive-actions: explicit
    pr-creation: explicit
  context:
    default-tier: 2
  knowledge-sync:
    trigger: us-completion
  doc-update:
    require-ux-impact: true
```

---

## spec-os/standards/index.yml

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
```

---

## spec-os/changes/{feature}/spec.md

```markdown
---
feature-id: F{ID}
tracker-type: ado | github
tracker-url: {full URL}
cadence: {sprint/milestone identifier}
status: planned | in-progress | in-review | done | abandoned
domain: {domain-name}
stack: dotnet | odoo | nextjs | python | other
cross-repo: false | true
spec-os-version: {version}
created: {ISO-date}
last-updated: {ISO-date}
---

## Tracker references
| Type | ID | Title | URL |
|------|----|-------|-----|

## Design decisions

## Data model

## Implementation scope

## Dependencies

## Definition of Done
- [ ] All tasks in tasks.md completed
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] All AC verified by /spec-os-verify
- [ ] PR created and linked to each US
- [ ] Tracker US status updated to in-review
- [ ] /spec-os-doc invoked (if ux-impact tasks exist)
```

---

## spec-os/changes/{feature}/tasks.md

```markdown
---
feature-id: F{ID}
cadence: {identifier}
status: planned | in-progress | done
last-updated: {ISO-date}
---

## Progress
| US | Title | SP | Status | Tasks |
|----|-------|----|--------|-------|

---

## US #{id} — {title}

### T{NN} — {task title}
- subagent: backend | frontend
- depends-on: — | T{NN}
- scope: {file paths}
- done-when: {verifiable criterion}
- context-level: 1 | 2 | 3
- ux-impact: true | false
- claimed-by: —
- status: planned | in-progress | blocked | done
- blocked-reason: {if blocked}
- lessons-pending: []
```

---

## spec-os/changes/{feature}/session-log.md

```markdown
# Session Log — F{ID}

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

---

## spec-os/changes/{feature}/spec-delta.md

```markdown
# Spec Delta Log — F{ID}

---

## Delta — {Task-ID} — {ISO-date}

### Trigger
{edge case found | PO clarification | technical constraint}

### ADDED
- {what}: {why}
  Tasks affected: {T-IDs} | none

### MODIFIED
- {what} (was: {original}) -> (now: {updated})
  Reason: {why}
  Tasks affected: {T-IDs} | none

### REMOVED
- {what}: {why}
  Tasks affected: {T-IDs} | none

### Developer notified: yes | no
```

---

## spec-os/changes/{feature}/origin.md

```markdown
---
date: {ISO-date}
source: brainstorm-analyze
feature-id: F{ID}
tracker-type: ado | github
tracker-url: {full URL to Feature}
complexity: simple | medium | complex
---

## Input received

## Real problem identified

## Proposed solution

## Classification

## Tracker context at time of analysis

## Pending decisions

## Resolution notes
{Added by /spec-os-create — how each pending decision was resolved}
```

---

## spec-os/changes/{feature}/verify-report.md

```markdown
# Verify Report — US #{id}

---

## Cycle {N} — {ISO-date} — Result: PASS | FAIL

AC Coverage:       {n}/{total}
Unit tests:        {passing | failing} ({N} tests)
Integration tests: {passing | failing} ({N} tests)
Coverage:          {%} (minimum: {%})
Scope compliance:  clean | violations
Conventions:       clean | violations
Placeholders:      none | found
DoD:               complete | incomplete

### Issues (if FAIL)
- {issue}: {file reference} — {expected vs actual}

### Recommendation
{specific guidance on where to look and what to fix}
```

---

## spec-os/standards/global/pr-template.md

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

## spec-os/specs/_index.md

```markdown
# Domain Index

List of all domains in this project. Maintained by /spec-os-init.
Add new domains by running /spec-os-init Update.

| Domain | Description | Spec file | Status |
|--------|-------------|-----------|--------|
| {domain} | {one-line description} | specs/{domain}/spec.md | active |
```
