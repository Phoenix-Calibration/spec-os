# Concepts

This guide explains the core ideas behind spec-os and how they fit together. For practical usage, see [Getting Started](getting-started.md) and [Workflows](workflows.md).

## Philosophy

```
→ developer-controlled  — you invoke each skill, nothing runs silently
→ tracker-agnostic      — ADO, GitHub, or any supported tracker via config
→ standards as code     — conventions live in indexed files, not in prompts
→ spec before code      — observable behavior documented before implementation
→ context-efficient     — load only what each task actually needs
→ brownfield-first      — designed for existing codebases, not just greenfield
```

## The 4-Layer Architecture

spec-os organizes everything into four independent layers. Each layer has a clear owner and a specific role.

```
+-------------------------------------------------------------+
|                         SPEC-OS                             |
|                                                             |
|  LAYER 1: Standards    LAYER 2: Specs    LAYER 3: Workflow  |
|  "How we build"        "What we build"   "How we execute"   |
|                                                             |
|       +---------------------+------------------+            |
|                             |                               |
|                    LAYER 4: Tracker Adapter                 |
|                    "With whom we coordinate"                |
|                (ADO | GitHub | Linear | Jira)               |
+-------------------------------------------------------------+
```

### Layer 1 — Standards: How We Build

Coding conventions extracted from your codebase into indexed, discoverable files.

- `spec-os/standards/index.yml` — maps keywords to standard files
- `spec-os/standards/{category}/{name}.md` — concise, declarative rules
- Skills: `/spec-os-discover` (extract), `/spec-os-inject` (load on demand), `/spec-os-standard` (update)

Instead of loading all conventions into every prompt, `/spec-os-inject` reads the task's keywords and loads only the relevant standards. A task about `.NET error handling` loads `error-handling.md` and `dotnet.md`, not everything.

### Layer 2 — Specs: What We Build

Observable system behavior documented in two places:

- `spec-os/specs/{domain}/spec.md` — source of truth for current behavior, organized by domain
- `spec-os/changes/{feature}/spec.md` — in-progress spec for a feature being built, owned by `/spec-os-design`

Specs describe **observable behavior only** — inputs, outputs, states, and transitions. Not class names, library choices, or implementation steps.

### Layer 3 — Workflow: How We Execute

The skill chain that takes a feature from idea to merged PR:

```
/spec-os-brainstorm ──► /spec-os-design ──► /spec-os-plan
                                                   │
         /spec-os-sync ◄── /spec-os-doc ◄── /spec-os-verify ◄── /spec-os-implement
```

Each skill owns specific artifacts:

| Skill | Owns |
|-------|------|
| `/spec-os-brainstorm` | `origin.md` |
| `/spec-os-design` | `spec.md`, `spec-delta.md` |
| `/spec-os-plan` | `tasks.md` |
| `/spec-os-implement` | code, session-log.md |
| `/spec-os-verify` | `verify-report.md`, PR |
| `/spec-os-doc` | `docs/manual/{domain}.md` |
| `/spec-os-sync` | `specs/knowledge-base.md` |

### Layer 4 — Tracker Adapter: With Whom We Coordinate

Every skill that needs tracker access reads `spec-os/config.yaml` to find the right adapter:

```yaml
tracker:
  repos:
    - name: my-repo
      type: ado          # → uses Azure DevOps MCP
    - name: other-repo
      type: github       # → uses GitHub MCP
```

Skills call abstract operations (`create-feature`, `create-us`, `update-status`). The adapter resolves which MCP to call. Adding a new tracker means a new adapter entry in config — zero skill changes.

## Key Concepts

### Changes

A change is a feature or bug packaged as a folder under `spec-os/changes/`. Each change is self-contained:

```
spec-os/changes/F042-S24-equipment-notifications/
├── origin.md        ← why we're building this (from brainstorm, never modified)
├── spec.md          ← what we're building (behavior contract)
├── spec-delta.md    ← how the spec evolved during implementation
├── tasks.md         ← atomic execution plan with User Stories
├── session-log.md   ← agent memory across sessions
└── verify-report.md ← quality gate results
```

The folder name format is `F{id}-{cadence}-{slug}` for features, `B{id}-{slug}` for bugs.

When a feature is complete: `/spec-os-clean` archives the folder to `spec-os/archive/`.

### origin.md

The permanent record of why a feature was built. Created by `/spec-os-brainstorm`, never modified afterward.

Contains: original input, real problem identified, proposed solution, feature ID from tracker, complexity signal, pending decisions at brainstorm time, and resolution notes added by `/spec-os-create`.

### spec-delta.md

Every time `spec.md` changes during implementation, `/spec-os-design` Update mode writes a delta entry:

```markdown
## Delta — T05 — 2026-03-15

### MODIFIED
- Equipment.Status: added 'calibration-pending' state
  Reason: edge case discovered during AC
  Tasks affected: T06, T07
```

This answers "why does the spec look different from the original brainstorm?" — without losing history.

### Lazy context loading (3 tiers)

Each task in `tasks.md` declares a `context-level`. `/spec-os-implement` loads context accordingly:

```
TIER 1 (always, ~1KB):
  CLAUDE.md identity section + task definition + spec.md frontmatter only

TIER 2 (most tasks, +10-20KB):
  Relevant standards via /spec-os-inject + domain spec + prior session log

TIER 3 (complex tasks, +20-40KB):
  Full spec.md + knowledge-base.md (filtered) + ADRs referenced in spec
```

Tier 1 is for simple bug fixes. Tier 3 is for cross-repo API contracts and migrations. Default is Tier 2.

### Approval gates

Every skill-to-skill handoff requires developer confirmation by default (`skill-handoffs: explicit` in config). No skill passes to the next silently.

The full handoff map:

```
/spec-os-brainstorm  →  /spec-os-design      [dev confirms]
/spec-os-design      →  /spec-os-plan        [dev confirms]
/spec-os-plan        →  /spec-os-implement   [dev confirms]
/spec-os-implement   →  /spec-os-verify      [dev confirms, on US complete]
/spec-os-verify      →  /spec-os-doc         [dev confirms, if ux-impact]
/spec-os-doc         →  /spec-os-sync        [dev confirms]
/spec-os-verify      →  /spec-os-sync        [dev confirms, if no ux-impact]
```

This can be relaxed to `skill-handoffs: auto` in `config.yaml` once you trust the workflow.

### Specialists (agents)

`/spec-os-implement` does not write code directly. It delegates to a specialist subagent defined in `.claude/agents/`:

- `backend-dev` — handles backend tasks (Read, Edit, Write, Bash, Grep, Glob)
- `frontend-dev` — handles frontend tasks, with accessibility rules added

Specialists are native Claude Code subagents with enforced tool restrictions. `/spec-os-implement` controls when to invoke them and what context to pass. Skills remain the orchestrators.

### knowledge-base.md

Institutional lessons accumulated over time in `spec-os/specs/knowledge-base.md`. Every lesson is tagged:

```
stack:  [dotnet, odoo, nextjs, python, general]
domain: validated against spec-os/specs/_index.md
layer:  [domain, application, infrastructure, presentation, global]
type:   [pattern, gotcha, anti-pattern, performance, security]
```

Written by `/spec-os-sync` after each User Story completes. Cleaned up by `/spec-os-clean`.

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

### Spec levels

| Condition | spec-level | context-level |
|-----------|-----------|---------------|
| Bug fix, single-file, no behavior change | `lite` | 1 |
| New feature, bounded scope, single domain | `full` | 2 |
| Cross-repo, API/event contract, migration | `full` | 3 |
| Security, privacy, or compliance impact | `full` | 3 |

Use the lightest level that still makes the change verifiable.

## ADO / GitHub Hierarchy

spec-os maps to your tracker's work item hierarchy:

```
Epic                ← /spec-os-explore creates (optional, cross-repo initiatives)
  Feature           ← /spec-os-brainstorm creates (one per project)
    User Story      ← /spec-os-plan creates (one or more per feature)
      Task          ← /spec-os-implement executes (one per session)
```

Story Points are the exclusive responsibility of `/spec-os-plan` — it has the full spec and AC needed to size accurately. `/spec-os-brainstorm` sets a `complexity: simple | medium | complex` signal, not SP.

## Glossary

| Term | Definition |
|------|------------|
| **Change** | A feature or bug packaged as a folder under `spec-os/changes/` |
| **Domain** | A bounded area of system behavior (e.g., `equipment`, `auth`) |
| **origin.md** | Permanent record of why a feature was built — created by brainstorm, never modified |
| **spec-delta.md** | Log of spec changes during implementation |
| **Skill** | A `/spec-os-*` command — the orchestration layer, invoked by the developer |
| **Agent** | A specialist subagent (`backend-dev`, `frontend-dev`) — the execution layer, invoked by a skill |
| **Standards** | Coding conventions in `spec-os/standards/`, injected on demand by `/spec-os-inject` |
| **Tracker adapter** | The config pattern that makes skills work with any supported tracker |
| **context-level** | How much context `/spec-os-implement` loads for a task (1, 2, or 3) |
| **spec-level** | How detailed a spec needs to be (`lite` or `full`) |
| **US completion** | When all tasks in a User Story are done — triggers verify → doc → sync chain |

## Next Steps

- [Getting Started](getting-started.md) — install and run your first workflow
- [Skills](skills.md) — full reference for every `/spec-os-*` skill
- [Workflows](workflows.md) — patterns for features, bugs, and cross-repo work
