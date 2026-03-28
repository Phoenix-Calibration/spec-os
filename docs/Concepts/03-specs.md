# Specs

Specs are the answer to "what does this system do?" They describe observable behavior — inputs, outputs, states, and transitions — before any code is written.

## Two Kinds of Specs

**Domain specs** — source of truth for current system behavior, organized by domain:
```
spec-os/specs/{domain}/spec.md
```
Updated by `/spec-os-sync` after each feature completes.

**Feature specs** — in-progress spec for a feature being built:
```
spec-os/changes/{feature}/spec.md
```
Created and owned by `/spec-os-design` for the full feature lifecycle.

## The Changes Folder

Every feature or bug gets a self-contained folder under `spec-os/changes/`:

```
spec-os/changes/F042-S24-equipment-notifications/
├── origin.md        ← why we're building this (never modified)
├── spec.md          ← what we're building (behavior contract)
├── spec-delta.md    ← how the spec evolved during implementation
├── tasks.md         ← atomic execution plan with User Stories
├── session-log.md   ← agent memory across sessions
└── verify-report.md ← quality gate results
```

Folder name format: `F{id}-{cadence}-{slug}` for features, `B{id}-{slug}` for bugs.

When a feature is complete: `/spec-os-clean` archives the folder to `spec-os/archive/`.

## origin.md

The permanent record of why a feature was built. Created by `/spec-os-brainstorm`, **never modified** afterward.

Contains: original input, real problem identified, proposed solution, feature ID from tracker, complexity signal, and pending decisions at brainstorm time.

## spec-delta.md

Every time `spec.md` changes during implementation, `/spec-os-design` Update mode writes a delta entry:

```markdown
## Delta — T05 — 2026-03-15

### MODIFIED
- Equipment.Status: added 'calibration-pending' state
  Reason: edge case discovered during AC
  Tasks affected: T06, T07
```

This answers "why does the spec look different from the original brainstorm?" without losing history.

## Spec Format

A spec describes observable behavior using requirements and scenarios:

```markdown
## Requirements

### Requirement: Equipment status change
The system MUST emit a notification event when equipment status changes.

#### Scenario: Status changes to maintenance
- GIVEN equipment is active
- WHEN status changes to maintenance
- THEN a NotificationRequested event is published
- AND the event contains equipment ID, previous status, and new status

#### Scenario: No notification for same-state update
- GIVEN equipment is in maintenance
- WHEN status is set to maintenance again
- THEN no event is published
```

**RFC 2119 keywords** communicate requirement strength:
- `MUST` / `SHALL` — absolute requirement (verify FAIL if not met)
- `SHOULD` — recommended, exceptions exist (verify WARNING if not met)
- `MAY` — optional (not checked by verify)

## Spec Levels

| Condition | spec-level | context-level |
|-----------|-----------|---------------|
| Bug fix, single-file, no behavior change | `lite` | 1 |
| New feature, bounded scope, single domain | `full` | 2 |
| Cross-repo, API/event contract, migration | `full` | 3 |
| Security, privacy, or compliance impact | `full` | 3 |

Use the lightest level that still makes the change verifiable.

## Next Steps

← [Back to Architecture](01-architecture.md)

- [Workflow Phases](04-workflow-phases.md) — how specs are created and used in the skill chain
- [Skills Reference: /spec-os-design](../Workflow/06-skills-reference.md#spec-os-design)
