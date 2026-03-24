# Getting Started

This guide walks you through installing spec-os and running your first workflow. For installation options and the full command list, see the [main README](../README.md).

## How It Works

spec-os adds a structured layer between your tracker (ADO, GitHub) and your code. Every feature goes through a skill chain that keeps you in control at each step:

```text
/spec-os-brainstorm ──► /spec-os-design ──► /spec-os-plan ──► /spec-os-implement ──► /spec-os-verify ──► /spec-os-sync
```

Each skill has a single responsibility. You invoke each one explicitly — nothing runs automatically without your approval.

For bugs, there's a shorter path:

```text
/spec-os-bug ──► /spec-os-implement ──► /spec-os-verify ──► /spec-os-sync
```

## What spec-os Creates

Running `/spec-os-init` creates this structure in your project:

```
your-project/
│
├── CLAUDE.md                          ← agent identity and rules (thin)
│
├── spec-os/
│   ├── config.yaml                    ← tracker, workflow, project config
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
│   └── changes/                       ← work in progress
│       └── {feature-folder}/
│           ├── origin.md              ← preserved brainstorm (never deleted)
│           ├── spec.md                ← technical spec
│           ├── spec-delta.md          ← spec evolution log
│           ├── tasks.md               ← atomic task plan
│           ├── session-log.md         ← agent memory across sessions
│           └── verify-report.md       ← quality gate reports
│
└── .claude/
    ├── agents/
    │   ├── backend-dev.md             ← backend specialist subagent
    │   └── frontend-dev.md            ← frontend specialist subagent
    └── skills/
        └── spec-os-*/                 ← all skill files
```

**Two key directories in `spec-os/`:**

- **`specs/`** — source of truth. Describes how your system currently behaves, organized by domain. Updated when features complete.
- **`changes/`** — work in progress. Each feature or bug gets its own folder with all artifacts. Moved to `spec-os/archive/` by `/spec-os-clean` at release close.

## Step 1 — Run /spec-os-init

Run this from any Claude Code session in your project:

```text
You: /spec-os-init

AI:  Detecting mode...
     No spec-os/ folder found. Mode: INITIALIZE

     Project name:
     Description (one sentence):
     Stack: dotnet | python | odoo | nextjs | react | other
     Tracker type: ado | github
     Cadence format: sprint | milestone | quarter | custom

You: Equip360 | Industrial equipment management system | dotnet + nextjs | ado | sprint

AI:  ADO organization URL:
     ADO project name:
     Repo name (as in git remote):

You: https://dev.azure.com/company | Equip360 | equip360-api

AI:  What are the bounded domains of this project?
     Examples: auth, billing, reporting

You: equipment, maintenance, reporting, users

AI:  Will create:
     spec-os/config.yaml
     spec-os/standards/  (global + dotnet + nextjs stubs)
     spec-os/specs/       (4 domain stubs)
     .claude/agents/      (backend-dev, frontend-dev)
     CLAUDE.md
     Proceed? [y/n]

You: y

AI:  spec-os v1.0.0 installed.

     Next steps:
     1. Review spec-os/config.yaml — verify tracker credentials
     2. Run /spec-os-discover to extract standards from your codebase
     3. Fill spec-os/specs/{domain}/spec.md with known system behavior
     4. When ready: /spec-os-brainstorm or /spec-os-bug
```

## Step 2 — Configure your tracker

Open `spec-os/config.yaml` and fill in your tracker credentials:

```yaml
tracker:
  repos:
    - name: equip360-api
      type: ado
      organization: https://dev.azure.com/company
      project: Equip360
```

## Step 3 — Populate your standards

Standards start as stubs. Run `/spec-os-discover` to extract your actual conventions from the codebase:

```text
You: /spec-os-discover

AI:  Scanning codebase...
     Found patterns in 47 files.

     Proposed: spec-os/standards/backend/architecture.md
     - Clean Architecture with Domain/Application/Infrastructure layers
     - Repository pattern for data access
     Approve? [y/n]
```

Or edit the stubs manually in `spec-os/standards/`.

## Step 4 — Start your first feature

```text
You: /spec-os-brainstorm
```

From here, the skill chain guides you through the rest. See [Workflows](workflows.md) for common patterns.

## Adopting in an existing project

If your project already has code, `/spec-os-init` detects this and enters Adopt mode:

```text
You: /spec-os-init

AI:  Detecting mode...
     Existing source files found. Mode: ADOPT

     Codebase analysis:
       Detected stack: dotnet + nextjs
       Domain candidates: Equipment (14 files), Maintenance (8 files), Auth (6 files)
       Existing CLAUDE.md: found

     Proposed domains:
       - equipment: Equipment.cs, EquipmentService.cs, ...
       - maintenance: MaintenanceRecord.cs, ...
       - auth: AuthController.cs, ...
     Confirm or adjust?
```

Adopt mode seeds domain spec stubs from what it finds in your code — entities, patterns, and behaviors observed in the existing implementation.

## Next Steps

- [Concepts](concepts.md) — understand the 4-layer architecture and key ideas
- [Skills](skills.md) — full reference for every `/spec-os-*` skill
- [Workflows](workflows.md) — patterns for features, bugs, and cross-repo work
