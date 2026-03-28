# File Structure

Running `/spec-os-init` creates the following structure in your project:

```
your-project/
│
├── CLAUDE.md                          ← agent identity and rules (thin)
│
├── spec-os/
│   ├── config.yaml                    ← tracker, workflow, and project config
│   ├── version                        ← installed version (e.g. 1.0.0)
│   ├── GETTING-STARTED.md
│   │
│   ├── standards/                     ← how your team builds
│   │   ├── index.yml                  ← keyword → file mapping for smart injection
│   │   ├── global/                    ← naming, commits, security, pr-template
│   │   ├── backend/                   ← architecture, patterns, testing, error-handling
│   │   └── frontend/                  ← components, state, testing (if frontend stack)
│   │
│   ├── specs/                         ← what your system does (source of truth)
│   │   ├── _index.md                  ← domain registry
│   │   ├── knowledge-base.md          ← institutional lessons
│   │   └── {domain}/
│   │       └── spec.md
│   │
│   ├── tracker/                       ← tracker adapter (created by /spec-os-tracker)
│   │   ├── config.yaml                ← type: ado | github | none
│   │   └── ado.md / github.md         ← adapter with MCP mappings and env vars
│   │
│   └── changes/                       ← work in progress (one folder per feature/bug)
│       └── {feature-folder}/
│           ├── origin.md              ← preserved brainstorm (never modified)
│           ├── spec.md                ← technical spec
│           ├── spec-delta.md          ← spec evolution log
│           ├── tasks.md               ← atomic task plan
│           ├── session-log.md         ← agent memory across sessions
│           └── verify-report.md       ← quality gate reports
│
└── .claude/
    ├── agents/                        ← specialist subagents (pre-installed)
    │   ├── backend-dev.md
    │   ├── frontend-dev.md
    │   └── ...
    └── skills/
        └── spec-os-*/                 ← all skill files (pre-installed)
```

## Key Directories

**`spec-os/standards/`** — coding conventions indexed by keyword. `/spec-os-inject` reads this to load only relevant standards per task. Never dump all standards into a prompt.

**`spec-os/specs/`** — source of truth. Describes how your system currently behaves, organized by domain. Updated when features complete via `/spec-os-sync`.

**`spec-os/changes/`** — work in progress. Each feature or bug gets its own self-contained folder. Moved to `spec-os/archive/` by `/spec-os-clean` at release close.

**`spec-os/tracker/`** — tracker adapter. Skills call abstract operations; the adapter resolves the actual MCP call. Not present if tracker type is `none`.

## config.yaml Fields

Key fields in `spec-os/config.yaml`:

```yaml
project:
  name: Equip360
  stack: [dotnet, nextjs]
  domains: [equipment, maintenance, reporting, users]

tracker:
  type: ado           # ado | github | none

workflow:
  skill-handoffs: explicit    # explicit | auto
  max-iterations: 3           # inner loop retry limit
  cadence: sprint             # sprint | milestone | quarter | custom
```

## Glossary

| Term | Definition |
|------|------------|
| **Change** | A feature or bug packaged as a folder under `spec-os/changes/` |
| **Domain** | A bounded area of system behavior (e.g., `equipment`, `auth`) |
| **origin.md** | Permanent record of why a feature was built — created by brainstorm, never modified |
| **spec-delta.md** | Log of spec changes during implementation |
| **Skill** | A `/spec-os-*` command — the orchestration layer, invoked by the developer |
| **Agent** | A specialist subagent (`backend-dev`, `frontend-dev`) — the execution layer |
| **Standards** | Coding conventions in `spec-os/standards/`, injected on demand |
| **Tracker adapter** | The config pattern that makes skills work with any supported tracker |
| **context-level** | How much context `/spec-os-implement` loads for a task (1, 2, or 3) |
| **spec-level** | How detailed a spec needs to be (`lite` or `full`) |

## Next Steps

← [Back to Concepts Overview](00-concepts-overview.md)

- [Getting Started](../Getting%20Started/01-overview.md) — install and create this structure
- [Workflow Overview](../Workflow/01-workflow-overview.md) — start using it
