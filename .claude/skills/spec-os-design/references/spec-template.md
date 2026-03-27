---
feature-id: F{ID}
tracker-type: ado | github
tracker-url: {full URL}
cadence: {sprint/milestone identifier}
status: planned | in-progress | in-review | done | abandoned
domain: {domain-name}
stack: dotnet | odoo | nextjs | python | other
cross-repo: false | true
spec-level: lite | full
spec-os-version: {version}
created: {ISO-date}
last-updated: {ISO-date}
sources: [origin.md]
---

## Tracker references
| Type | ID | Title | URL |
|------|----|-------|-----|

## Scope

### In scope

### Out of scope

## Requirements

> Spec rules: describe observable behavior only — inputs, outputs, states, transitions.
> Do not include class names, library choices, or implementation steps (those belong in tasks.md).
> Use RFC 2119 keywords to communicate requirement strength:
> MUST / SHALL = absolute | SHOULD = recommended, exceptions exist | MAY = optional

### Requirement: {name}
The system MUST | SHOULD | MAY {observable behavior}.

#### Scenario: {happy path name}
- GIVEN {precondition}
- WHEN {action}
- THEN {observable outcome}

#### Scenario: {edge case or failure name}
- GIVEN {precondition}
- WHEN {action}
- THEN {observable outcome}

## Domain model
{Entities, states, and transitions visible at the domain boundary.
Not DB schema — domain concepts and their valid states/transitions.}

## Design decisions
{Architectural decisions that affect observable contracts: API shape, event schema,
integration points. Not internal implementation choices.}

## Dependencies

## Definition of Done
- [ ] All tasks in tasks.md completed
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] All AC verified by /spec-os-verify
- [ ] PR created and linked to each US
- [ ] Tracker US status updated to in-review
- [ ] /spec-os-doc invoked (if doc-impact tasks exist)
