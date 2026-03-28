# Workflow Phases

spec-os organizes the feature lifecycle into two phases with distinct ownership, plus a setup phase and a framework quality phase.

## The Phase Model

```
PHASE 0 — Setup (once per project)
PHASE 1 — Design (Team Lead / Product Owner, per feature)
PHASE 2 — Implementation (Developer, per feature)
PHASE 3 — Framework quality (post-session)
```

This separation is intentional: a developer can start Phase 2 without knowing anything about how the feature was designed. They only need `tasks.md`.

## Phase 1 — Design

Owned by the **Team Lead or Product Owner**. Produces all artifacts the developer needs.

```
/spec-os-brainstorm ──► /spec-os-design ──► /spec-os-plan
```

| Skill | Produces |
|-------|----------|
| `/spec-os-brainstorm` | `origin.md` — the permanent record of why |
| `/spec-os-design` | `spec.md` — the behavior contract |
| `/spec-os-plan` | `tasks.md` — the atomic execution plan + User Stories in tracker |

## Phase 2 — Implementation

Owned by the **Developer**. Consumes `tasks.md` and executes.

```
/spec-os-implement ──► /spec-os-verify ──► /spec-os-doc ──► /spec-os-sync
```

| Skill | Does |
|-------|------|
| `/spec-os-implement` | Executes one task per session, one commit |
| `/spec-os-verify` | Quality gate per User Story → creates PR |
| `/spec-os-doc` | Updates user documentation (if `doc-impact: true`) |
| `/spec-os-sync` | Syncs lessons to knowledge base |

## Approval Gates

Every skill-to-skill handoff requires developer confirmation by default (`skill-handoffs: explicit` in `config.yaml`). No skill passes to the next silently.

```
/spec-os-brainstorm  →  /spec-os-design      [dev confirms]
/spec-os-design      →  /spec-os-plan        [dev confirms]
/spec-os-plan        →  /spec-os-implement   [dev confirms]
/spec-os-implement   →  /spec-os-verify      [dev confirms, on US complete]
/spec-os-verify      →  /spec-os-doc         [dev confirms, if doc-impact]
/spec-os-doc         →  /spec-os-sync        [dev confirms]
/spec-os-verify      →  /spec-os-sync        [dev confirms, if no doc-impact]
```

Set `skill-handoffs: auto` in `config.yaml` to relax this once you trust the workflow.

## Specialists (Agents)

`/spec-os-implement` does not write code directly. It delegates to a specialist subagent defined in `.claude/agents/`:

- `backend-dev` — handles backend tasks (Read, Edit, Write, Bash, Grep, Glob)
- `frontend-dev` — handles frontend tasks, with accessibility rules added

Specialists are native Claude Code subagents with enforced tool restrictions. `/spec-os-implement` controls when to invoke them and what context to pass.

## Lazy Context Loading

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

## Tracker Hierarchy

spec-os maps to your tracker's work item hierarchy:

```
Epic                ← /spec-os-explore creates (optional, cross-repo initiatives)
  Feature           ← /spec-os-brainstorm creates (one per project)
    User Story      ← /spec-os-plan creates (one or more per feature)
      Task          ← /spec-os-implement executes (one per session)
```

Story Points are the exclusive responsibility of `/spec-os-plan`. `/spec-os-brainstorm` sets a `complexity: simple | medium | complex` signal — not SP.

## Next Steps

← [Back to Architecture](01-architecture.md)

- [File Structure](05-file-structure.md) — what spec-os creates on disk
- [Workflow Overview](../Workflow/01-workflow-overview.md) — the full flow with examples
