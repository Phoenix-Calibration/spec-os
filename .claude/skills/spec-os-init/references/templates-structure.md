# Templates — Project Structure Files

Top-level project files created by `/spec-os-init`.

---

## `spec-os/version`

```
1.0.0
```

---

## `spec-os/config.yaml`

```yaml
project:
  name: {project-name}
  description: {one-sentence description}
  stack: {stack}              # dotnet | python | odoo | nextjs | react | other
  cadence-format: sprint      # sprint | milestone | quarter | custom

tracker:
  default: {ado | github | none}    # connection details managed by /spec-os-tracker in spec-os/tracker/

workflow:
  approval-gates:
    skill-handoffs: explicit    # explicit | auto
    spec-changes: explicit      # always explicit
    destructive-actions: explicit
    pr-creation: explicit
  context:
    default-tier: 2             # 1 | 2 | 3
  knowledge-sync:
    trigger: us-completion      # runs after each US, not each task
  doc-update:
    require-ux-impact: true     # /spec-os-doc only runs if ux-impact: true on any task
```

---

## `CLAUDE.md`

```markdown
# CLAUDE.md — {project-name}

## Identity

Project: {project-name}
Description: {one-sentence description}
Stack: {stack}
Tracker: see spec-os/tracker/
Standards: spec-os/standards/index.yml
## Agent behavior (immutable rules)

- Think before responding — analyze the full request first
- Never fabricate — if uncertain, say so and ask
- Max 3 clarifying questions at a time, one per topic
- Always propose before applying — wait for approval
- One task per session — never exceed scope in tasks.md
- If spec.md and code contradict — stop and ask
- Notify developer before any skill handoff
- Document gaps as Suggested Improvements, never self-apply

## Security boundaries

- Never write credentials, tokens, or secrets to any file
- Never execute destructive git operations without explicit approval
- Never modify files outside the task scope declared in tasks.md

## Entry points

- New idea/requirement: /spec-os-brainstorm
- Bug to fix: /spec-os-bug with tracker Bug ID
- New project setup: /spec-os-product then /spec-os-init
```

---

## `spec-os/GETTING-STARTED.md`

```markdown
# Getting Started with spec-os

## Key files

- `spec-os/config.yaml` — tracker and workflow configuration
- `spec-os/specs/` — domain behavior specs (source of truth)
- `spec-os/standards/` — coding conventions and patterns
- `spec-os/changes/` — work in progress (features and bugs)
- `CLAUDE.md` — agent identity and rules

## Workflow

### New feature
1. `/spec-os-brainstorm` — analyze the idea, create brief.md
2. `/spec-os-design` — write the technical spec
3. `/spec-os-plan` — decompose into User Stories and tasks
4. `/spec-os-implement T01` — execute one task per session
5. `/spec-os-verify` — quality gate when US is complete
6. `/spec-os-sync` — sync lessons to knowledge base (always last)

### Bug fix
1. `/spec-os-bug {tracker-id}` — analyze and route (simple or complex path)

### Cross-repo initiative
1. Use `/spec-os-explore` in Claude Desktop (personal skill)

## Maintenance

- `/spec-os-discover` — extract standards from codebase
- `/spec-os-standard` — update a standard
- `/spec-os-clean` — clean up outdated knowledge-base entries and archive completed features
- `/spec-os-init update` — add new domains or update installation
```
