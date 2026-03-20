# DevCanvas
## Spec-Driven Development Framework — Implementation Guide for Claude Code

> **Instructions for Claude Code**: This document defines the complete DevCanvas standard for creating and managing software projects. Your job is to implement this system exactly as described. Where you identify gaps, ambiguities, or improvements, document them in a `## Suggested Improvements` section at the end of each artifact you create — do not deviate from the spec without explicit approval. Always propose before applying. Wait for approval before making changes.

---

## 1. Purpose

DevCanvas is a universal, reusable development framework that combines Spec-Driven Development (SDD) with Scrum methodology, Azure DevOps (ADO) as source of truth, and Claude Code as the primary execution agent.

This framework applies to any software project regardless of stack:
- .NET / Clean Architecture / CQRS
- Odoo custom modules (Python)
- Next.js applications
- Python services
- Any other stack

---

## 2. Core Principles

1. **ADO is the single source of truth** for all management data: Features, User Stories, Acceptance Criteria, Story Points, Bugs, Tasks, Sprint status.
2. **Local files are the execution layer** — they contain only what ADO cannot: technical design, execution plans, and agent memory.
3. **No duplication** — if information exists in ADO, it is never copied locally. The agent reads ADO via MCP when needed.
4. **One session per task** — each Claude Code session implements exactly one task, producing one atomic commit.
5. **Skills are autonomous** — each Skill knows what to do next and invokes the next Skill automatically.
6. **ADO work items are created by the agent** — humans define the problem, the agent creates the structured artifacts.
7. **Always notify before handoff** — no Skill passes to the next silently. Developer is always informed.
8. **Always propose before applying** — wait for developer approval before making changes.

---

## 3. Repository Structure

Every project using DevCanvas must have the following structure. Skills rely on these exact paths.

```
[project-root]/
├── .claude/
│   ├── CLAUDE.md
│   └── skills/
│       ├── brainstorm-analyze/
│       │   └── SKILL.md
│       ├── project-init/
│       │   └── SKILL.md
│       ├── spec-create/
│       │   └── SKILL.md
│       ├── spec-plan/
│       │   └── SKILL.md
│       ├── spec-implement/
│       │   ├── SKILL.md
│       │   └── specialists/
│       │       ├── backend-dev/
│       │       │   └── SKILL.md
│       │       └── frontend-dev/
│       │           └── SKILL.md
│       ├── spec-verify/
│       │   └── SKILL.md
│       ├── bug-analyze/
│       │   └── SKILL.md
│       ├── doc-update/
│       │   └── SKILL.md
│       └── knowledge-sync/
│           └── SKILL.md
├── docs/
│   ├── README.md
│   ├── GETTING-STARTED.md
│   ├── ROADMAP.md
│   ├── _registry.md
│   ├── knowledge-base.md
│   ├── design/
│   │   ├── README.md
│   │   ├── 00-overview.md
│   │   ├── 01-stack.md
│   │   ├── 02-security.md
│   │   ├── 03-performance.md
│   │   ├── 04-metrics.md
│   │   ├── 05-data-model.md
│   │   ├── 06-integrations.md
│   │   ├── 07-error-handling.md
│   │   ├── 08-glossary.md
│   │   ├── 09-design-system.md
│   │   └── adr/
│   │       └── README.md
│   ├── domains/
│   │   └── README.md
│   ├── specs/
│   │   ├── README.md
│   │   └── archive/
│   │       └── README.md
│   ├── bugs/
│   │   ├── README.md
│   │   └── archive/
│   │       └── README.md
│   ├── runbooks/
│   │   └── README.md
│   └── manual/
│       └── README.md
└── brainstorm-output.md        ← Temporary, created by personal brainstorm-analyze
```

### 3.1 Feature folder structure

```
docs/specs/F{ADO-ID}-{year}-{cadence}-{name}/
├── spec.md
├── tasks.md
└── session-log.md
```

### 3.2 Bug folder structure

```
docs/bugs/B{ADO-ID}-{short-description}/
└── analysis.md       ← Only for complex bugs
```

---

## 4. Naming Conventions

### 4.1 Feature folders
```
F{ADO-Feature-ID}-{year}-{cadence}-{kebab-name}

Examples:
  F1042-2026-4M1-equipment-management/
  F1055-2026-4M1-calibration-records/
  F1099-2026-4M1-mantenimiento-calsys/
```

- `F` prefix identifies this as a Feature
- ADO Feature ID enables direct MCP lookup from folder name
- Year + cadence provides temporal context (4M1 = 4-month period, January)
- Name is kebab-case, descriptive, concise

### 4.2 Bug folders
```
B{ADO-Bug-ID}-{short-kebab-description}

Examples:
  B2041-null-ref-equipment/
  B2089-date-format-certificate/
```

### 4.3 ADR files
```
{sequential-number}-{kebab-title}.md

Examples:
  001-clean-architecture.md
  002-cqrs-mediatr.md
```

### 4.4 Design folder files
- Base files: `00-` through `09-` — guaranteed to exist, never renamed or deleted
- Dynamic files: `10-` and above — created by agent when justified, must include a one-line reason in the file header

---

## 5. CLAUDE.md Structure

Each project's CLAUDE.md must contain these sections exactly.

```markdown
# CLAUDE.md — [Project Name]

## Identity
Project: {name}
Project description: {brief description of what the project does}
Stack: {stack}
ADO Organization: {url}
ADO Project: {name}
GitHub Org: {url if applicable}
Standards: DevCanvas

## Agent behavior rules
- Think carefully before responding — analyze the full request first
- If you are not certain about something, say so — never fabricate or assume
- When something is unclear, ask clarifying questions — maximum 3 at a time,
  one per topic
- Keep responses concise unless detail is explicitly requested
- Always propose before applying — wait for approval before making changes
- If you detect a gap or improvement, document it under Suggested Improvements —
  never apply without approval
- One task per session — never implement beyond the assigned task scope
- If spec.md and existing code contradict, ask before deciding
- Never modify files outside the scope defined in tasks.md
- Always notify the developer before invoking the next Skill in the chain

## Security boundaries
Never read, modify, or reference:
- .env files or any file containing credentials
- appsettings.Production.json or any production config
- Azure Key Vault references or secret files
- SSL certificates or private keys
- Any file outside the repository

If you encounter sensitive data: stop immediately, notify developer,
wait for instructions. Never log or copy sensitive content.

## Project conventions
{Stack-specific naming rules, file organization, class structure}

## Patterns in use
{Which patterns are active and how they apply in this project specifically}

## What to never do
{Anti-patterns, rejected approaches, known pitfalls in this codebase}

## Testing conventions
{Unit vs integration, naming conventions, what must always be tested}

## Commit conventions
{Format, scope, ADO work item linking}
Example: T03: Endpoint POST /api/equipment [#1043]

## Skills available
- brainstorm-analyze: analyze requirements and classify work
- project-init: initialize DevCanvas structure
- spec-create: generate spec.md from ADO Feature ID
- spec-plan: define US in ADO, generate tasks.md
- spec-implement: implement tasks with specialist subagents
- spec-verify: verify DoD and AC before PR
- bug-analyze: analyze and route bug fixes
- doc-update: update user manual after US completion
- knowledge-sync: consolidate lessons and archive completed features

## MCP connections
- Azure DevOps: {org}/{project}
- GitHub: {org if applicable}
```

---

## 6. File Specifications

### 6.1 `docs/GETTING-STARTED.md`

```markdown
# Getting Started with DevCanvas

## Prerequisites
- Claude Code installed and configured
- Azure DevOps access to {org}/{project}
- GitHub access to {org} (if applicable)
- MCPs configured (see below)

## MCP Setup

### Azure DevOps MCP
Installation: {command or link}
Configuration:
  organization: {url}
  project: {name}

### GitHub MCP (if applicable)
Installation: {command or link}
Configuration:
  org: {name}

## How this project works

This project uses DevCanvas — a Spec-Driven Development framework
where Claude Code manages the full development lifecycle through Skills.

Three entry points — this is all you need to know to start:

| Situation                           | Action                                    |
|-------------------------------------|-------------------------------------------|
| I have an idea, complaint, or requirement | Run brainstorm-analyze in Claude Desktop |
| I have an ADO Bug ID to fix         | Run bug-analyze with the Bug ID           |
| Setting up a new or existing project | Run project-init                          |

Everything else executes automatically through Skill handoffs.

## Key files

| File                          | Purpose                                    |
|-------------------------------|--------------------------------------------|
| .claude/CLAUDE.md             | Agent rules and project conventions        |
| docs/design/00-overview.md   | What this project is and why it exists     |
| docs/ROADMAP.md               | What we are building and when              |
| docs/_registry.md             | Active features and bugs (local index)     |
| docs/knowledge-base.md       | Lessons learned across all features        |

## Full documentation
See docs/README.md for the complete structure explanation.
```

### 6.2 `docs/README.md`

```markdown
# docs/

Project documentation and execution artifacts.

## Structure

| Folder/File        | Purpose                                              | Audience       |
|--------------------|------------------------------------------------------|----------------|
| design/            | Architecture, technical decisions, domain design     | Human + Agent  |
| domains/           | Functional area descriptions and relationships       | Human + Agent  |
| specs/             | Technical specs and execution plans per feature      | Agent primary  |
| bugs/              | Bug investigation and fix plans                      | Agent primary  |
| runbooks/          | Operational procedures (deploy, test, debug, build)  | Human + Agent  |
| manual/            | User-facing documentation, auto-updated by agent     | Human primary  |
| GETTING-STARTED.md | Onboarding guide for new developers                  | Human          |
| ROADMAP.md         | Strategic milestones and feature planning            | Human + Agent  |
| _registry.md       | Local index of specs and bugs folders                | Agent primary  |
| knowledge-base.md  | Consolidated lessons learned across all features     | Agent primary  |

## Source of Truth

Azure DevOps contains: Features, User Stories, Acceptance Criteria,
Story Points, Bugs, Sprint assignments, and all status tracking.

Local files contain: Technical design decisions, execution plans,
agent memory, operational documentation, and user manuals.

Never duplicate ADO information locally.
```

### 6.3 `docs/ROADMAP.md`

```markdown
# Roadmap — [Project Name]

## Cadences

### {year} {cadence} — {month range}
| ADO ID | Feature                    | Status      |
|--------|----------------------------|-------------|
| F{id}  | {title}                    | {status}    |

## Maintenance Features

Each cadence has a dedicated maintenance feature per system.
Minor improvements and isolated US are added here.

| Cadence   | System    | ADO ID |
|-----------|-----------|--------|
| {cadence} | {system}  | F{id}  |
```

### 6.4 `docs/_registry.md`

```markdown
# Local Registry
last-updated: {ISO-datetime}

## Specs

| ID     | Path                                              | Archived |
|--------|---------------------------------------------------|----------|
| F{id}  | specs/F{id}-{year}-{cadence}-{name}/              | no       |
| F{id}  | specs/archive/F{id}-{year}-{cadence}-{name}/      | yes      |

## Bugs

| ID     | Path                                        | Has analysis | Archived |
|--------|---------------------------------------------|--------------|----------|
| B{id}  | bugs/B{id}-{description}/                   | yes          | no       |
| B{id}  | bugs/archive/B{id}-{description}/           | no           | yes      |
```

Rules:
- Only tracks what exists locally — not all ADO work items
- `Has analysis` = yes only if `analysis.md` file exists
- Never include SP, status, or sprint — those come from ADO via MCP
- Updated by `spec-create` when creating a feature folder
- Updated by `bug-analyze` when creating a bug folder
- Updated by `knowledge-sync` when archiving completed features or bugs

### 6.5 `docs/knowledge-base.md`

```markdown
# Knowledge Base
last-updated: {ISO-datetime}

## {Stack/Domain Category}

### {Technology or Pattern}
- {Lesson learned}
- Source: {Feature-ID} {Task-ID} — {date}
```

### 6.6 `docs/design/README.md`

```markdown
# design/

Technical, functional, and visual design of the solution.

## Base files (always exist, never renamed or deleted)

| File                | Content                                          |
|---------------------|--------------------------------------------------|
| 00-overview.md      | Project purpose, users, history, future vision   |
| 01-stack.md         | Technologies, frameworks, versions               |
| 02-security.md      | Auth, authorization, data protection             |
| 03-performance.md   | Targets, caching strategy, optimization          |
| 04-metrics.md       | KPIs, monitoring, alerting                       |
| 05-data-model.md    | Core entities, relationships, value objects      |
| 06-integrations.md  | External systems, APIs, webhooks                 |
| 07-error-handling.md| Error types, patterns, API responses             |
| 08-glossary.md      | Domain terminology with precise definitions      |
| 09-design-system.md | UI components, palette, typography, patterns     |

## Dynamic files (agent creates when justified)
Files 10- and above. Agent must include a one-line justification
in the file header. Follow same naming: {number}-{kebab-title}.md

## adr/ subfolder
Architecture Decision Records. One file per significant decision.
See adr/README.md for format.

## Agent instructions
When generating a spec.md:
1. Always read 00-overview.md
2. Read the relevant domain file from domains/
3. Read only files relevant to the feature
4. Do NOT load all files — only what is relevant
5. Never contradict an accepted ADR without flagging it
```

### 6.7 `docs/domains/README.md`

```markdown
# domains/

Describes the major functional areas of the system.

## What is a domain file?
One .md file per functional area describing:
- What this area is responsible for
- Core entities it owns
- How it communicates with other domains
- Key business rules and constraints
- What it must NOT do (boundaries)

## Naming
{domain-name}.md — kebab-case

## Template

---
domain: {name}
---

## Responsibility
## Core entities
## Relationships
## Business rules
## Boundaries

## Agent instructions
Read this file before reading spec.md for any feature in this domain.
Respect boundaries — if the feature crosses domain lines, document it
in spec.md under Design Decisions.
```

### 6.8 `docs/specs/README.md`

```markdown
# specs/

Technical specifications and execution plans for features.

## What goes here
One folder per feature: F{ADO-ID}-{year}-{cadence}-{name}/

Each folder contains:
- spec.md — technical design
- tasks.md — atomic execution plan
- session-log.md — agent memory across sessions

## What does NOT go here
- User Stories → ADO
- Acceptance Criteria → ADO
- Story Points → ADO
- Bugs → docs/bugs/

## archive/
Completed features are moved here by knowledge-sync after
all US are done in ADO and developer confirms archival.

## Maintenance features
F{ID}-{year}-{cadence}-mantenimiento-{system}/ folders accumulate
US throughout the cadence. Do not create a new folder per minor
improvement — add to the existing maintenance feature.

## Agent instructions
Before creating a new feature folder:
1. Check _registry.md for existing local folders
2. For minor improvements, check for active maintenance feature locally
3. If not local, query ADO via MCP for active maintenance features
4. Only create new maintenance feature if none exists for this cadence
Never scan archive/ unless explicitly requested.
```

### 6.9 `docs/bugs/README.md`

```markdown
# bugs/

Bug investigation artifacts for complex bugs only.

## When is a folder created here?
Only when bug-analyze determines the bug is COMPLEX:
- Affects 3+ files or layers
- Root cause not immediately obvious
- Fix requires multiple sessions
- Touches external integrations

Simple bugs are resolved in memory — no local folder created.

## archive/
Resolved bugs are moved here by knowledge-sync after
Bug status in ADO is done and developer confirms archival.

## Agent instructions
After resolving any bug:
1. Update Bug status in ADO via MCP
2. If complex: update analysis.md with resolution notes
3. Invoke knowledge-sync — it will detect and archive if done
4. Invoke doc-update if user-facing behavior changed
```

### 6.10 `docs/specs/archive/README.md`

```markdown
# specs/archive/

Completed features. Moved here by knowledge-sync after all US
are done in ADO and developer confirms.

## Agent instructions
Never scan this folder during normal operations.
Only read contents if developer explicitly requests historical context.
```

### 6.11 `docs/bugs/archive/README.md`

```markdown
# bugs/archive/

Resolved complex bugs. Moved here by knowledge-sync after
Bug status in ADO is done and developer confirms.

## Agent instructions
Never scan this folder during normal operations.
Only read contents if developer explicitly requests historical context.
```

### 6.12 `docs/runbooks/README.md`

```markdown
# runbooks/

Operational procedures for development workflows.

## Suggested files (create as needed)
- deployment.md
- testing.md
- debugging.md
- build.md
- database-migration.md
- rollback.md

## Format

---
runbook: {name}
last-updated: {date}
applies-to: {project or all}
---

## Purpose
## Prerequisites
## Steps
## Verification
## Rollback

## Agent instructions
Read relevant runbook before executing operational tasks.
```

### 6.13 `docs/manual/README.md`

```markdown
# manual/

User-facing documentation. Auto-updated by doc-update after
each User Story is completed.

## Agent instructions (doc-update)
1. Identify which manual file corresponds to the US domain
2. If file does not exist, create it
3. Add or update only the section for the completed US
4. Write in clear, non-technical language for end users
5. Include: what it does, how to use it, expected results
6. Do NOT include technical details, code, or architecture decisions
```

### 6.14 `docs/design/adr/README.md`

```markdown
# adr/ — Architecture Decision Records

## When to create an ADR
- Choosing a framework or library
- Defining a cross-cutting pattern
- Rejecting a reasonable alternative
- Making a hard-to-reverse decision

## Naming
{number}-{kebab-title}.md

## Template

---
adr: {number}
title: {title}
date: {date}
status: accepted | deprecated | superseded-by: ADR-{number}
---

## Context
## Decision
## Reasoning
## Alternatives considered
## Consequences

## Agent instructions
Read relevant ADRs before proposing technical approaches in spec.md.
Never propose an approach that contradicts an accepted ADR without
flagging it explicitly under Suggested Improvements.
```

---

## 7. Core File Templates

### 7.1 `spec.md`

```markdown
---
feature-id: F{ADO-ID}
ado-feature-id: {numeric-id}
ado-url: {full-ADO-url}
milestone: {year}-{cadence}
sprint: S{N}-{year}
status: planned | in-progress | in-review | done
domain: {domain-name}
stack: dotnet | odoo | nextjs | python | other
cross-repo: false | true
spec-owner: {repo-name}     # only if cross-repo: true
---

## ADO references

| Type    | ID     | Title                | URL   |
|---------|--------|----------------------|-------|
| Feature | #{id}  | {title}              | {url} |
| US      | #{id}  | {title}              | {url} |

## Design decisions

Technical decisions specific to this feature.
What patterns to use, what to avoid, and why.
Agent reads this before writing a single line of code.

## Data model

New or modified entities, relationships, value objects.
Agent does NOT infer this from the codebase — reads it here.

## Implementation scope

Which layers and files this feature touches.
What projects in the solution are involved.
Prevents the agent from guessing where to work.

## Dependencies

Features or external systems this feature needs or could break.
Agent verifies this before implementing.

## Definition of Done

Technical completion criteria — distinct from ADO acceptance criteria.

- [ ] All tasks in tasks.md completed
- [ ] Unit tests passing with sufficient coverage
- [ ] Integration tests passing
- [ ] All AC from ADO verified by spec-verify
- [ ] PR created and linked to each US
- [ ] ADO US status updated to in-review
- [ ] doc-update invoked
```

If `cross-repo: true`, add:

```markdown
## Cross-repo dependencies

| Repo        | US IDs       | tasks.md path |
|-------------|--------------|---------------|
| {repo-name} | #{id}, #{id} | {path}        |
| {repo-name} | #{id}        | local         |
```

### 7.2 `tasks.md`

```markdown
---
feature-id: F{ADO-ID}
sprint: S{N}-{year}
status: planned | in-progress | done
last-updated: {ISO-date}
---

## Progress

| US     | Title   | SP  | Status  | Tasks completed |
|--------|---------|-----|---------|-----------------|
| #{id}  | {title} | {n} | planned | 0/{total}       |
| Total  |         | {n} |         | 0/{total}       |

---

## US #{id} — {title}

### T{NN} — {task title}
- subagent: backend | frontend
- depends-on: — | T{NN}
- scope: {comma-separated file or folder paths}
- done-when: {specific, verifiable criterion}
- status: planned | in-progress | done

---
```

**Agent instructions for tasks.md:**
- Update task `status` immediately after completion
- Update `Tasks completed` count in Progress table after each task
- Update US `Status` in Progress table when all its tasks are done
- Each task = one session = one atomic commit
- Never implement multiple tasks in one session

### 7.3 `session-log.md`

```markdown
# Session Log — F{ADO-ID}

---

## {Task-ID} — {ISO-date}

### What was done
Brief description of what was implemented.

### Decisions made
- {Decision}: {reason}

### Problems encountered
- {Problem}: {solution applied}

### Lessons learned
- {Lesson} — generalizable? yes/no

### Context for next session
Key facts the next agent session needs before starting.
Specific file paths, registered services, existing patterns found.
```

**Agent instructions:**
- Write entry after EVERY session, before the commit
- Keep entries concise — 5-15 lines total
- `Context for next session` is the most critical field — be specific
- If lesson is generalizable: knowledge-sync will extract it to knowledge-base.md

### 7.4 `analysis.md` (complex bugs only)

```markdown
---
bug-id: B{ADO-ID}
ado-id: {numeric-id}
ado-url: {full-ADO-url}
feature-id: {F-ID | standalone}
status: investigating | planned | in-progress | done
complexity: complex
created: {ISO-date}
last-updated: {ISO-date}
---

## Problem statement
Precise technical description of what fails, when, and under
what conditions.

## Root cause
Updated as investigation progresses — may be incomplete initially.

## Affected scope
- {file-path-1}
- {file-path-2}

## Fix plan

### Step {NN} — {description}
- status: planned | in-progress | done
- done-when: {verifiable criterion}
- session-note: {what happened in this session}

## Investigation log
- {ISO-date}: {finding}

## Session notes

### Step {NN} — {ISO-date}
- What was done
- Decisions made
- Problems encountered
- Context for next session
```

---

## 8. Skills Specification

### 8.1 Personal Skill — `~/.claude/skills/brainstorm-analyze/SKILL.md`

```markdown
---
name: brainstorm-analyze
description: Analyze any input (user complaint, idea, requirement, email)
             to classify it and decide which repo owns the spec. Use when
             you receive an unstructured requirement, feedback, or idea
             and need to determine what to build and where.
---

## Purpose
Strategic analysis skill. Operates with visibility across all repos
and ADO projects via MCP. Produces brainstorm-output.md in the owner repo.

## Step 0 — Environment check
Verify ADO MCP connection before proceeding.
If unavailable: stop, report "ADO MCP connection unavailable".

## Process

### Step 1 — Understand the real problem
Do not take the input at face value.
Ask: what is the user actually experiencing?
What workflow is broken or missing?

### Step 2 — Propose solution
Define the solution clearly before classifying.

### Step 3 — Consult ADO (mandatory)
Before classifying, query ADO via MCP:
- Are there active Features where this fits?
- Are there active maintenance Features for this cadence?
- What is the current sprint capacity?

This prevents creating unnecessary new Features when
an existing one already covers the work.

### Step 4 — Classify

| Classification      | Criteria                                             |
|---------------------|------------------------------------------------------|
| New Feature         | Requires new spec.md, multiple US, significant work  |
| Maintenance US      | Single US, fits in existing maintenance feature      |
| Minor improvement   | Small change, single US, no new domain concepts      |
| Discard             | Not actionable, duplicate, or out of scope           |

### Step 5 — Estimate effort
New Feature: high / medium / low (not SP — no US defined yet)
Maintenance US or Minor: rough SP estimate (1, 2, 3, 5, 8)

### Step 6 — Decide spec owner (New Feature only)
Query all repos via MCP. Evaluate:
- Where does the primary business logic live?
- Which repo has more entities, layers, or services involved?
- Which team owns the most US?

If work is balanced: default to CalSystem repo.
If uncertain: ask the developer before deciding.

### Step 7 — Generate brainstorm-output.md
Write file to root of owner repo.

## brainstorm-output.md format

---
date: {ISO-date}
source: brainstorm-analyze (personal)
status: pending-review
---

## Input received
{verbatim or summarized input}

## Real problem
{what is actually broken or missing}

## Proposed solution
{clear description of what should be built}

## Classification
{New Feature | Maintenance US | Minor improvement | Discard}

## Spec owner
Recommended repo: {repo-name}
Reason: {1-2 sentence justification}

## Work distribution
| Repo   | Responsibility    | Weight |
|--------|-------------------|--------|
| {repo} | {responsibility}  | {%}    |

## Effort estimate
{high/medium/low for Feature; SP number for US/Minor}

## ADO context consulted
- Active maintenance features: {found/not found}
- Sprint capacity: {available/limited}
- Existing related features: {found: F{id} | none}

## Pending decisions
- {Question that spec-create or spec-plan must resolve}

## Handoff
Notify developer:
"Analysis complete. brainstorm-output.md created in {repo}.
Run spec-create in that repo to continue."
```

### 8.2 `project-init/SKILL.md`

```markdown
---
name: project-init
description: Initialize, adopt, or update DevCanvas in any repository.
             Use when setting up a new project from scratch, adopting
             DevCanvas in an existing codebase, or updating DevCanvas
             to the latest version in a project that already uses it.
---

## Purpose
Three modes of operation — detected automatically:

| Mode       | When                                           | Behavior                          |
|------------|------------------------------------------------|-----------------------------------|
| Initialize | Repo exists but no DevCanvas structure found   | Create everything from scratch    |
| Adopt      | Existing project with code but no DevCanvas    | Add DevCanvas without touching existing files |
| Update     | Project already has DevCanvas                  | Update outdated files only        |

## Step 0 — Environment check
Verify the target repository is accessible before proceeding.
If not accessible: stop and report clearly.

## Step 1 — Detect mode

Check for presence of:
- `.claude/CLAUDE.md` → DevCanvas already installed
- `docs/` folder → partial structure may exist
- Source code files (src/, app/, models/, etc.) → existing project

Decision logic:
- No `.claude/CLAUDE.md` AND no source code → Mode: Initialize
- No `.claude/CLAUDE.md` AND source code exists → Mode: Adopt
- `.claude/CLAUDE.md` exists → Mode: Update

Notify developer:
"Detected mode: {mode}
{brief description of what will happen}
Proceeding to gather information."

---

## Mode: Initialize — new project from scratch

### Step 2 — Gather project information
Ask developer (maximum 3 questions at a time):
- Project name and one-sentence description
- Stack (dotnet | odoo | nextjs | python | other)
- ADO organization URL + project name
- GitHub org (if applicable)

### Step 3 — Create full structure
Create all folders and files as defined in Section 3.
Use exact README.md content from Section 6.
Leave docs/design/ base files (00-09) with header only:
`# {filename} — fill with project-specific content`

### Step 4 — Create CLAUDE.md
Generate .claude/CLAUDE.md using Section 5 structure
with gathered project values filled in.

### Step 5 — Create specialist Skills
Ask developer which specialists this project needs:

Implementation specialists (under spec-implement/specialists/):
  - backend-dev?
  - frontend-dev?

Note: spec-verify handles all quality verification independently —
no qa specialist needed.

For each confirmed specialist:
  Read Skill Creator: /mnt/skills/examples/skill-creator/SKILL.md
  Generate SKILL.md following that standard
  Fill with stack-specific technical expertise

### Step 6 — Initialize registry and knowledge-base
Create docs/_registry.md with empty structure.
Create docs/knowledge-base.md with empty structure.

### Step 7 — Report and next steps
List all created files.
Notify developer:
"DevCanvas initialized for {project-name}.
Next steps:
1. Fill docs/design/00-overview.md with project context
2. Fill docs/design/ base files (01-09) with project-specific content
3. Run brainstorm-analyze in Claude Desktop for your first feature
   or spec-create if you already have an ADO Feature ID"

---

## Mode: Adopt — existing project without DevCanvas

### Step 2 — Analyze existing codebase
Read existing files to infer:
- Stack and frameworks in use
- Naming conventions already established
- Folder structure patterns
- Any existing documentation

Do NOT modify any existing files.

### Step 3 — Gather missing information
Ask developer only for what cannot be inferred:
- Project name and description (if no README.md found)
- ADO organization URL + project name
- GitHub org (if applicable)
- Confirm inferred stack: "I detected {stack} — is that correct?"

### Step 4 — Present adoption plan
Show developer exactly what will be created and confirm
nothing existing will be touched:
"I will create:
  {list of new files and folders}
I will NOT modify:
  {list of existing files detected}
Proceed?"
Wait for approval.

### Step 5 — Create DevCanvas structure
Create all DevCanvas files and folders.
Pre-fill CLAUDE.md conventions based on patterns found in existing code.
Fill docs/design/00-overview.md with what was inferred from the codebase.
Leave other docs/design/ base files with headers only.

### Step 6 — Create specialist Skills
Same as Initialize Step 5.
Use detected stack to generate stack-specific specialist content.

### Step 7 — Initialize registry and knowledge-base
Same as Initialize Step 6.

### Step 8 — Report and next steps
Notify developer:
"DevCanvas adopted for {project-name}.
Pre-filled from existing codebase:
  - CLAUDE.md conventions (verify and adjust as needed)
  - docs/design/00-overview.md (verify accuracy)
Next steps:
1. Review and adjust .claude/CLAUDE.md — especially Project conventions
2. Fill remaining docs/design/ base files
3. Run brainstorm-analyze or spec-create for your first feature"

---

## Mode: Update — project already using DevCanvas

### Step 2 — Compare versions
Read existing .claude/CLAUDE.md to detect current DevCanvas version.
Compare existing Skills against the template.
Identify:
- Missing files or folders
- Outdated SKILL.md files (structure changed)
- New Skills added in current version not present in project

### Step 3 — Present update plan
Show developer exactly what needs updating:
"Changes detected:
  New: {list of files to create}
  Outdated: {list of files to update}
  Up to date: {list — no changes needed}

Your project-specific content (CLAUDE.md conventions,
docs/design/ content, specs/, bugs/) will NOT be touched.
Proceed?"
Wait for approval.

### Step 4 — Apply updates
Create missing files.
Update outdated SKILL.md files — preserve any project-specific
customizations found in existing Skills.
Never overwrite docs/design/, docs/specs/, docs/bugs/,
docs/manual/, or docs/domains/.

### Step 5 — Report
Notify developer:
"DevCanvas updated for {project-name}.
{N} files created, {N} files updated.
Review changes and verify specialist Skills still match your stack."

## Handoff
No automatic handoff. Instructs developer on next steps.
```

### 8.3 `spec-create/SKILL.md`

```markdown
---
name: spec-create
description: Generate a spec.md for a feature from an ADO Feature ID or
             from a brainstorm-output.md. Use when starting work on a new
             feature or when brainstorm-analyze has produced an output file.
---

## Step 0 — Environment check
1. Verify ADO MCP connection
2. Verify docs/design/00-overview.md exists
3. Verify docs/specs/ exists
If any check fails: stop and report clearly.

## Process

### Step 1 — Check for brainstorm-output.md
If brainstorm-output.md exists in project root:
  Read it as starting context. Note pending decisions.
If not: ask developer for ADO Feature ID.

### Step 2 — Read ADO Feature
Query ADO via MCP: get Feature #{id}
Extract: title, description, linked User Stories if any.

### Step 3 — Read technical context
Always read:
- docs/design/00-overview.md
- docs/domains/{relevant-domain}.md

Read if relevant:
- docs/design/05-data-model.md (if feature touches data)
- docs/design/06-integrations.md (if feature touches external systems)
- Relevant ADRs from docs/design/adr/

### Step 4 — Conflict check
Read docs/_registry.md — get all active features.
For each active feature, read its spec.md Implementation scope.
Compare with proposed scope for this feature.
If overlap detected: report to developer before proceeding.

### Step 5 — Resolve pending decisions
If brainstorm-output.md has pending decisions, resolve them now.
Document resolutions in spec.md under Design Decisions.

### Step 6 — Generate spec.md
Create folder: docs/specs/F{id}-{year}-{cadence}-{name}/
Create spec.md using template from Section 7.1.
Create session-log.md (empty, with header only).

### Step 7 — Update _registry.md
Add new entry to Specs table with archived: no.

### Step 8 — Delete brainstorm-output.md
If it existed, delete it now.

### Step 9 — Notify and handoff
Notify developer:
"spec.md created for F{id}. Invoking spec-plan to define
User Stories and generate tasks.md."
Invoke spec-plan.
```

### 8.4 `spec-plan/SKILL.md`

```markdown
---
name: spec-plan
description: Analyze a spec.md, define User Stories with Story Points,
             create them in ADO linked to the Feature, and generate tasks.md.
             Use after spec-create completes or when adding US to a
             maintenance feature.
---

## Step 0 — Environment check
1. Verify ADO MCP connection
2. Verify spec.md exists for this feature
If any check fails: stop and report clearly.

## Process

### Step 1 — Read spec.md
Load spec.md. Identify domain, implementation scope,
dependencies, and Definition of Done.

### Step 2 — Read ADO Feature
Query ADO via MCP. Check if US already exist.
If US exist: use them, do not create duplicates.

### Step 3 — Define User Stories
For each distinct user-facing capability in the spec,
define a US: "As a {role}, I want {action} so that {benefit}"

For each US, define:
- AC: happy path cases (Given/When/Then format)
- AC: edge cases — think through:
  - Null or empty data scenarios
  - Boundary values
  - External system failures
  - Permission and authorization cases
  - Concurrent access scenarios
- Convert relevant edge cases into explicit AC

### Step 4 — Apply US sizing rules

Split a US if ANY of these is true:
- Estimated SP > 8
- It has two distinct user-facing outcomes
- It can be delivered and tested independently in parts
- It touches more than 2 unrelated layers simultaneously
- done-when has more than 4 independent conditions

Merge two ideas into one US if ALL of these are true:
- Same user role and goal
- Cannot be tested independently
- Combined SP estimate is 5 or less
- Touch exactly the same files and layers

Story Points scale:
| SP | Meaning                    |
|----|----------------------------|
| 1  | Trivial, < 2h              |
| 2  | Simple, half day           |
| 3  | Moderate, ~1 day           |
| 5  | Complex, 2-3 days          |
| 8  | Very complex, ~1 week      |
| 13 | Epic — must split first    |

### Step 5 — Create US in ADO
For each US: create in ADO via MCP, link to Feature,
set SP, set Sprint if known, add full AC including edge cases.
Update spec.md ADO references table.

### Step 6 — Define tasks per US
Break each US into atomic tasks.
Each task = one Claude Code session = one commit.

Per task define:
- subagent: which specialist implements this
- depends-on: prerequisite tasks
- scope: specific file paths — no vague "and other files"
- done-when: verifiable criterion the agent can check

### Step 7 — Generate tasks.md
Create tasks.md using template from Section 7.2.

### Step 8 — Notify and handoff
Notify developer:
"tasks.md generated for F{id}. {N} User Stories created in ADO
with {total SP} total SP. Ready to implement.
Invoking spec-implement for first task: T01 of US #{id}."
Invoke spec-implement.
```

### 8.5 `spec-implement/SKILL.md`

```markdown
---
name: spec-implement
description: Implement a single task from tasks.md. One session, one task,
             one atomic commit. Use when executing a specific task ID from
             a feature or bug fix plan.
---

## Purpose
Single-responsibility implementation. One task per session.
Delegates to specialist subagents for technical execution.

## Inputs
- Feature ID (e.g., F1042) or Bug ID (e.g., B2041)
- Task ID (e.g., T03)

## Step 0 — Environment check
1. Verify spec.md and tasks.md exist
2. Verify session-log.md exists
3. Verify depends-on tasks are all marked done in tasks.md
If preconditions not met: stop and report clearly.

## Session initialization (read in this order)
1. .claude/CLAUDE.md
2. docs/design/00-overview.md
3. docs/domains/{domain from spec.md}.md
4. docs/specs/{feature-folder}/spec.md
5. docs/specs/{feature-folder}/tasks.md — target task section only
6. docs/specs/{feature-folder}/session-log.md — depends-on entries only
7. docs/knowledge-base.md — filtered by domain and stack

For bugs: replace steps 4-6 with docs/bugs/{bug-folder}/analysis.md

## Process

### Step 1 — Identify specialist
Determine which specialist should implement this task:
- backend task → backend-dev
- frontend task → frontend-dev

Notify developer:
"Task {T-ID}: {title}
Specialist: {specialist-name}
Scope: {files}
Shall I proceed?"
Wait for confirmation.

### Step 2 — Invoke specialist
Invoke specialist as subagent with:
- Task definition from tasks.md
- Relevant sections from spec.md
- Context from session-log.md

### Step 3 — Receive and validate result
Specialist returns implementation.
Verify done-when criteria are met before proceeding.

### Step 4 — Atomic commit
Commit with format:
{task-id}: {task-title} [#{ADO-US-id}]
Example: T03: Endpoint POST /api/equipment [#1043]

### Step 5 — Update tasks.md
Mark task status as done.
Update Tasks completed count in Progress table.

### Step 6 — Write session-log.md entry
Write entry for this task.
Be specific in "Context for next session".

### Step 7 — Notify and handoff to knowledge-sync
Notify developer:
"Task {T-ID} complete and committed.
Invoking knowledge-sync."
Invoke knowledge-sync.

### Step 8 — Check US completion
Are all tasks for this US now done?
  No → Notify developer:
       "Next task: {T-ID} — {title}. Run spec-implement when ready."
  Yes → Notify developer:
        "All tasks for US #{id} complete.
         Invoking spec-verify."
        Invoke spec-verify.

## Handoff chain
spec-implement → knowledge-sync → (if US done) spec-verify
```

### 8.6 `spec-verify/SKILL.md`

```markdown
---
name: spec-verify
description: Verify that all Acceptance Criteria and Definition of Done
             are met for a completed User Story before creating a PR.
             Reads DoD and AC directly, executes technical verification,
             and manages the full PASS/FAIL cycle. Invoked automatically
             by spec-implement when all tasks of a US are done.
---

## Purpose
Complete quality gate between implementation and PR creation.
Owns the full verification cycle — reads requirements, executes
technical checks, produces the quality report, and decides PASS/FAIL.
No specialist delegation — single responsibility end to end.

## Inputs
- Feature ID
- US ID to verify

## Step 0 — Environment check
1. Verify ADO MCP connection
2. Verify spec.md and tasks.md exist
3. Verify all tasks for this US are marked done in tasks.md
If any check fails: stop and report clearly.

## Process

### Step 1 — Read verification inputs
- DoD from spec.md
- AC (including edge cases) from ADO via MCP for US #{id}
- Implementation scope from spec.md
- Done-when criteria from all tasks of this US in tasks.md
- Testing conventions from .claude/CLAUDE.md

### Step 2 — Execute technical verification
Check each item systematically:

**AC coverage**
For each AC from ADO: verify it is implemented in the codebase.
Check happy path and all edge cases.

**Test verification**
Run unit tests — verify all pass.
Run integration tests — verify all pass.
Check coverage meets the minimum defined in CLAUDE.md.
Verify tests actually cover the AC — not just passing by coincidence.

**Scope compliance**
Verify no files were modified outside the scope defined in spec.md.

**Code conventions**
Verify code follows patterns defined in .claude/CLAUDE.md.
Check for TODO, placeholder, or commented-out code.

**Definition of Done**
Verify every item in spec.md DoD is satisfied.

### Step 3 — Produce quality report

## Quality gate — US #{id}

AC coverage:       {n}/{total} AC verified
Edge cases:        {covered | gaps: list}
Unit tests:        {passing | failing} ({n} tests)
Integration tests: {passing | failing} ({n} tests)
Test coverage:     {meets minimum | below minimum}
Scope compliance:  {clean | violations: list}
Conventions:       {clean | violations: list}
Placeholders:      {none | found: list}
DoD:               {complete | incomplete: list}

Result: PASS | FAIL
Issues: {detailed list if FAIL}

### Step 4a — PASS
Notify developer:
"US #{id} — Quality gate PASSED.
{n}/{n} AC verified, all tests passing.
Creating PR and updating ADO."

Create PR linked to US #{id}.
Update US status in ADO to in-review.
Invoke doc-update.

### Step 4b — FAIL (simple)
A failure is simple when:
- The cause is immediately clear from test output
- Only 1-2 files are involved
- The fix is obvious from the error message

Notify developer:
"US #{id} — Quality gate FAILED.
Issues found:
{detailed list of issues with file references}
Returning to spec-implement for corrections.
Approve to proceed?"
Wait for developer confirmation.
Pass to spec-implement:
  - List of failed issues
  - Relevant file paths
  - Expected vs actual behavior per AC

### Step 4c — FAIL (complex)
A failure is complex when ANY of these is true:
- Multiple tests failing with unclear root cause
- Stack trace points to a dependency or indirect file
- Coverage gap but unclear which AC is uncovered
- Convention violation requiring architectural refactoring
- Error only reproducible under specific conditions

Before handing off to spec-implement, perform deeper diagnosis:

1. Read affected files from implementation scope
2. Read session-log.md — last entry of the failed task
3. Analyze stack traces and test output in detail
4. Cross-reference failing tests against AC from ADO
5. Identify the root cause or narrow it down as much as possible

Generate enriched failure context:

## Failure context — US #{id}

Failure type: complex
Root cause: {identified cause | best hypothesis if uncertain}
Confidence: {high | medium | low}

Affected files:
- {file-path}: {what is wrong here}

Failing tests:
- {test-name}: {why it fails, not just that it fails}

AC not satisfied:
- AC-{n}: {description} — {why it is not met}

Recommended fix approach:
{specific guidance on where to look and what to change}

Additional context from session-log:
{relevant decisions or notes from the implementation session}

Notify developer:
"US #{id} — Quality gate FAILED (complex issue).
Root cause identified: {brief description}
Enriched context prepared for spec-implement.
Approve to proceed with corrections?"
Wait for developer confirmation.
Pass enriched failure context to spec-implement.

### Step 5 — Cycle until PASS
spec-implement corrects → spec-verify re-runs → repeat until PASS.
Each cycle: spec-verify re-reads the updated code and re-runs all checks.
Context accumulates across cycles — session-log.md grows with each attempt.

## Handoff chain
spec-verify (PASS) → doc-update
spec-verify (FAIL) → spec-implement → spec-verify (cycle)
```

### 8.7 `bug-analyze/SKILL.md`

```markdown
---
name: bug-analyze
description: Analyze a Bug from ADO, determine complexity, and either fix
             it directly or create an analysis.md and fix plan. Use when
             given an ADO Bug ID to work on.
---

## Step 0 — Environment check
1. Verify ADO MCP connection
2. Verify docs/bugs/ exists
If any check fails: stop and report clearly.

## Process

### Step 1 — Read Bug from ADO
Query ADO via MCP: get Bug #{id}
Extract: title, description, repro steps, stack trace.

### Step 2 — Read technical context
- .claude/CLAUDE.md
- docs/design/00-overview.md
- If bug relates to a feature: read that feature's spec.md

### Step 3 — Investigate codebase
Determine:
- How many files are affected?
- Is root cause immediately clear?
- Does fix require multiple sessions?
- Does it touch external integrations?

### Step 4 — Classify complexity

Simple — ALL must be true:
- 1-2 files affected
- Root cause clear after initial analysis
- Fix completable in one session
- No external integration impact

Complex — ANY is true:
- 3+ files or layers affected
- Root cause unclear
- Fix requires multiple sessions
- Touches external systems

### Step 5a — Simple path
Notify developer:
"Bug #{id}: {title}
Complexity: Simple
Root cause: {description}
Fix plan: {brief description}
Proceed?"
Wait for confirmation.
Invoke spec-implement directly.

### Step 5b — Complex path
Create folder: docs/bugs/B{id}-{description}/
Create analysis.md using template from Section 7.4.
Update docs/_registry.md Bugs table.

Notify developer:
"Bug #{id}: {title}
Complexity: Complex — analysis.md created.
Root cause: {known/investigating}
Fix plan: {N} steps
Proceeding with Step 01."
Invoke spec-implement with Step 01.

## Handoff chain
Simple: bug-analyze → spec-implement → knowledge-sync → doc-update (if UX changed)
Complex: bug-analyze → spec-implement → knowledge-sync → doc-update (if UX changed)
```

### 8.8 `doc-update/SKILL.md`

```markdown
---
name: doc-update
description: Update the user manual in docs/manual/ after a User Story
             is completed. Single responsibility: user documentation only.
             Invoked automatically by spec-verify after PR creation.
---

## Purpose
Keep docs/manual/ current after every completed User Story.
Writes in user-facing language, not technical.

## Process

### Step 1 — Read US from ADO
Query ADO via MCP: get User Story #{id}
Understand what the user can now do.

### Step 2 — Read spec.md domain
Identify which manual file to update.

### Step 3 — Update manual
Map domain → docs/manual/{domain}.md
If file does not exist: create it.
Add or update only the section for this US.
Write for end users — no technical jargon, no code.
Include: what it does, how to use it, what to expect.

### Step 4 — No handoff
doc-update is always the last step in the chain.
Notify developer:
"docs/manual/{domain}.md updated for US #{id}.
Feature work complete."
```

### 8.9 `knowledge-sync/SKILL.md`

```markdown
---
name: knowledge-sync
description: Extract generalizable lessons from the latest session-log.md
             entry, update knowledge-base.md, and check for completed
             features to archive. Invoked automatically by spec-implement
             after every session.
---

## Purpose
Two responsibilities:
1. Build institutional memory from session logs
2. Detect and archive completed features and bugs

## Process

### Step 1 — Extract lessons
Read latest session-log.md entry.
For each item in "Lessons learned":
  Is this generalizable to other features? yes/no
  If yes: proceed to Step 2.
  If no: skip.

### Step 2 — Update knowledge-base.md
Determine category: stack/technology, pattern, integration, cross-system.
Check for duplicate or similar existing entry.
If similar exists: add source reference to existing entry.
If new: add entry with source reference.

### Step 3 — Check for completed features
Compare docs/_registry.md active specs vs ADO:
For each feature with archived: no in _registry.md:
  Query ADO via MCP: get Feature #{id} status
  If status = done in ADO:
    Notify developer:
    "Feature F{id} is done in ADO.
     Archive local spec folder? (yes/no)"
    If confirmed: move folder to docs/specs/archive/
                  update _registry.md archived: yes

### Step 4 — Check for resolved bugs
Same logic for bugs:
For each bug with archived: no in _registry.md:
  Query ADO via MCP: get Bug #{id} status
  If status = done:
    Notify developer:
    "Bug B{id} is resolved in ADO.
     Archive local bug folder? (yes/no)"
    If confirmed: move folder to docs/bugs/archive/
                  update _registry.md archived: yes

## Handoff
knowledge-sync never invokes another Skill automatically.
```

---

## 9. Specialist Skills

Specialist Skills live under `spec-implement/specialists/` and are invoked as subagents. They are created by `project-init` using the Skill Creator standard from Anthropic.

### 9.1 Structure

```
spec-implement/
  specialists/
    backend-dev/
      SKILL.md    ← generated by project-init using Skill Creator
    frontend-dev/
      SKILL.md    ← generated by project-init using Skill Creator
```

### 9.2 Specialist responsibilities

**backend-dev**
- Implement domain entities, application commands/queries, infrastructure
- Write unit tests for all implemented code
- Follow patterns defined in CLAUDE.md and spec.md
- Cover all AC and edge cases defined in ADO with tests

**frontend-dev**
- Implement UI components, pages, forms
- Write component tests
- Follow design system from docs/design/09-design-system.md

**spec-verify (not a specialist — full Skill)**
- Owns the complete quality gate — no delegation
- Reads DoD and AC directly from spec.md and ADO
- Executes all technical verification independently
- Produces quality report with PASS/FAIL
- Manages correction cycle with spec-implement

### 9.3 How project-init creates specialists

```
project-init asks developer which specialists are needed:
  - backend-dev?
  - frontend-dev?
        ↓
For each confirmed specialist:
  Read /mnt/skills/examples/skill-creator/SKILL.md
  Follow Skill Creator standard to generate SKILL.md
  Fill with stack-specific technical expertise
  Place in spec-implement/specialists/{name}/
```
  Fill with stack-specific technical expertise
  Place in correct folder under parent Skill
```

---

## 10. Complete Workflow

### 10.1 New Feature flow

```
Developer has: idea, complaint, or requirement
        ↓
[Claude Desktop]
brainstorm-analyze (personal ~/.claude/skills/)
  Consults ADO for active features and capacity
  Analyzes problem and solution
  Classifies: New Feature
  Decides spec owner repo
  Creates brainstorm-output.md in owner repo
  Notifies developer
        ↓
[Claude Code — owner repo]
spec-create
  Reads brainstorm-output.md
  Reads ADO Feature via MCP
  Reads docs/design/ context
  Runs conflict check
  Generates spec.md + empty session-log.md
  Updates _registry.md
  Deletes brainstorm-output.md
  Notifies developer → invokes spec-plan
        ↓
spec-plan
  Reads spec.md
  Defines US with AC (happy path + edge cases)
  Applies sizing rules — splits if SP > 8
  Creates US in ADO via MCP
  Generates tasks.md
  Notifies developer → invokes spec-implement (T01)
        ↓
spec-implement [one session per task]
  Reads context (CLAUDE.md + design + spec + task + log + knowledge)
  Identifies specialist → notifies developer → waits confirmation
  Invokes specialist subagent
  Atomic commit
  Updates tasks.md
  Writes session-log.md
  Notifies developer → invokes knowledge-sync
        ↓
knowledge-sync
  Extracts lessons → updates knowledge-base.md
  Checks for completed features/bugs → archives if confirmed
        ↓
[If all tasks of US are done]
spec-implement notifies developer → invokes spec-verify
        ↓
spec-verify
  Reads DoD from spec.md + AC from ADO
  Executes full technical verification
  Produces quality report
        ↓
PASS → notifies developer
       Creates PR linked to US
       Updates US status in ADO to in-review
       Invokes doc-update
        ↓
FAIL → notifies developer
       Returns to spec-implement for corrections
       Cycles until PASS
        ↓
doc-update
  Updates docs/manual/{domain}.md
  Notifies developer — chain complete
```

### 10.2 Maintenance US / Minor improvement flow

```
brainstorm-analyze (personal)
  Consults ADO — finds active maintenance feature
  Classifies: Maintenance US or Minor improvement
  Notifies developer
        ↓
[Claude Code]
Check _registry.md for active maintenance feature
  Found locally → spec-plan adds US to existing tasks.md
  Not local → query ADO via MCP
    Found in ADO → create local folder, generate tasks.md
    Not found → create maintenance Feature in ADO first
        ↓
spec-plan → spec-implement → knowledge-sync → spec-verify → doc-update
```

### 10.3 Bug flow

```
Bug created in ADO
        ↓
Developer: "work on bug #2041"
        ↓
bug-analyze
  Reads Bug from ADO
  Investigates codebase
  Notifies developer with complexity and plan
  Waits for confirmation
        ↓
Simple → spec-implement (one session)
         → knowledge-sync → doc-update (if UX changed)
         → updates Bug in ADO

Complex → creates analysis.md
          → spec-implement (step by step)
          → knowledge-sync → doc-update (if UX changed)
          → updates Bug in ADO
```

### 10.4 Cross-repo feature flow

```
brainstorm-analyze (personal) determines spec owner
        ↓
[Claude Code — owner repo]
spec-create → spec-plan (creates ALL US in ADO)
spec-implement (owner repo tasks only)
        ↓
[Claude Code — secondary repo]
spec-plan (reads same Feature from ADO, generates tasks.md for its US only)
spec-implement (secondary repo tasks only)
        ↓
Both repos: independent sessions, independent PRs per US
ADO is the coordination point between repos
```

---

## 11. Session Model

| Unit       | Sessions   | Commits         | PR    |
|------------|------------|-----------------|-------|
| Task       | 1 session  | 1 atomic commit | —     |
| User Story | N sessions | N commits        | 1 PR  |
| Feature    | N sessions | N commits        | N PRs |

**Session startup sequence (spec-implement):**
1. .claude/CLAUDE.md
2. docs/design/00-overview.md
3. docs/domains/{domain}.md
4. spec.md
5. tasks.md — target task section only
6. session-log.md — depends-on entries only
7. knowledge-base.md — filtered by domain + stack

**Session close sequence (spec-implement):**
1. Verify done-when criteria
2. Atomic commit
3. Update tasks.md
4. Write session-log.md entry
5. Invoke knowledge-sync
6. If US complete → invoke spec-verify

---

## 12. Skills Inventory

| Skill              | Location                    | Invoked by                   | Invokes                         |
|--------------------|-----------------------------|------------------------------|---------------------------------|
| brainstorm-analyze | ~/.claude/skills/           | Developer                    | Notifies developer for spec-create |
| brainstorm-analyze | .claude/skills/             | Developer (optional)         | spec-create                     |
| project-init       | .claude/skills/             | Developer                    | Nothing (instructs developer)   |
| spec-create        | .claude/skills/             | Developer / brainstorm       | spec-plan                       |
| spec-plan          | .claude/skills/             | spec-create / Developer      | spec-implement                  |
| spec-implement     | .claude/skills/             | spec-plan / Developer        | knowledge-sync → spec-verify    |
| spec-verify        | .claude/skills/             | spec-implement               | doc-update / spec-implement     |
| bug-analyze        | .claude/skills/             | Developer                    | spec-implement                  |
| doc-update         | .claude/skills/             | spec-verify                  | Nothing (end of chain)          |
| knowledge-sync     | .claude/skills/             | spec-implement               | Nothing (end of chain)          |
| backend-dev        | spec-implement/specialists/ | spec-implement               | Nothing (returns to parent)     |
| frontend-dev       | spec-implement/specialists/ | spec-implement               | Nothing (returns to parent)     |

---

## 13. Developer Entry Points

| Situation                                | Action                               |
|------------------------------------------|--------------------------------------|
| I have an idea, complaint, or requirement | Run brainstorm-analyze (Claude Desktop) |
| I have an ADO Bug ID to fix              | Run bug-analyze with the Bug ID      |
| Setting up a new or existing project     | Run project-init                     |

Everything else executes automatically through Skill handoffs.

---

## 14. Implementation Instructions for Claude Code

You are reading this document because you have been asked to implement
DevCanvas in a repository.

### What to do

1. Run project-init logic to create the complete structure
2. Create all SKILL.md files with exact content from Section 8
3. Create all README.md files with exact content from Section 6
4. Create docs/GETTING-STARTED.md, docs/ROADMAP.md,
   docs/_registry.md, docs/knowledge-base.md with initial structure
5. Create .claude/CLAUDE.md with project-specific content
6. Ask developer which specialists to create, then use Skill Creator
   to generate them correctly
7. Leave docs/design/00-09 files with headers only —
   content is project-specific

### What NOT to do

- Do not invent conventions not defined in this document
- Do not add fields to templates without flagging as improvement
- Do not create files or folders not defined here
- Do not modify the Skills chain without flagging as improvement
- Do not proceed with any step without notifying developer first

### After implementing

Add this section at the end of this document:

## Suggested Improvements — {date}

Format each item as:
- **Area**: {section or file}
- **Observation**: {what you noticed}
- **Suggestion**: {what you recommend}
- **Priority**: high | medium | low
