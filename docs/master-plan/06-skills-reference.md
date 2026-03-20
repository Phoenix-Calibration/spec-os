# Spec-OS: Skills Reference

Complete reference for all `/spec-os-*` skills. For workflow patterns and when to use each skill, see [05-skills-chain.md](05-skills-chain.md).

---

## Quick Reference

### Portfolio Skills — Cross-Repo (Claude Desktop personal skill)

| Skill | Purpose |
|-------|---------|
| `/spec-os-explore` | Analyze a business initiative across multiple apps → generate context packages per app |

### Primary Skills — Main Workflow

| Skill | Purpose |
|-------|---------|
| `/spec-os-brainstorm` | Analyze an idea or requirement → create origin.md |
| `/spec-os-bug` | Analyze a bug → route to simple or complex path |
| `/spec-os-init` | Initialize, adopt, or update spec-os in a project |
| `/spec-os-create` | Create technical spec from origin.md |
| `/spec-os-plan` | Decompose spec into User Stories and tasks |
| `/spec-os-implement` | Execute one task (one session) |
| `/spec-os-verify` | Quality gate per User Story |

### Secondary Skills — Support & Maintenance

| Skill | Purpose |
|-------|---------|
| `/spec-os-discover` | Scan codebase and extract coding standards |
| `/spec-os-inject` | Load relevant standards for the current task |
| `/spec-os-standard` | Update an existing standard |
| `/spec-os-doc` | Update user documentation (conditional on ux-impact) |
| `/spec-os-sync` | Sync lessons to knowledge-base (always last in chain) |
| `/spec-os-abandon` | Close a feature without completing it |
| `/spec-os-prune` | Clean up outdated entries from knowledge-base |

---

## Skill Reference

---

### `/spec-os-explore`

Analyze a business initiative or requirement that spans multiple applications. Generates a master initiative file and one context package per affected app. Personal skill — installed in Claude Desktop, not in individual repos.

**Syntax:**
```
/spec-os-explore [initiative description]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `initiative description` | No | Brief description of the initiative (prompted if not provided) |

**What it does:**
- Opens an exploratory conversation about the business initiative
- Reads tracker context across all configured repos (active features, epics, capacity)
- Identifies which apps/systems are affected and how
- Maps inter-app dependencies and suggests execution order
- Optionally creates an Epic in ADO/GitHub if the initiative warrants one (dev confirms — not always needed)
- Generates output files in Claude Desktop project files:
  - `{YYYYMMDD-HHmm}-initiative-{slug}.md` — master cross-app view
  - `{YYYYMMDD-HHmm}-initiative-{slug}-{app}.md` — one context package per affected app
- Notifies developer to run `/spec-os-brainstorm` in each affected repo, passing the corresponding context package

**Output files are not `origin.md`.** They are context packages — input for `/spec-os-brainstorm` in each project. Brainstorm does the deep per-project analysis and produces the authoritative `origin.md`.

**Example:**
```
You: /spec-os-explore

AI:  What business initiative would you like to analyze?

You: We need to migrate equipment data from the legacy ERP to the new portal
     and keep both in sync during the transition period.

AI:  Analyzing across repos: erp, portal, shared-services...
     Reading tracker context...

     Initiative: Equipment data migration — ERP to Portal
     Systems affected: erp (source), portal (target), shared-services (sync layer)

     Inter-app dependencies:
     → shared-services must expose sync API before portal can consume it
     → erp export endpoint needed before shared-services can read data
     Suggested order: erp → shared-services → portal

     Create Epic in ADO for this initiative? [y/n]

You: y

AI:  Created Epic E12: "Equipment data migration — ERP to Portal"

     Generating initiative files...

     Created:
     20260320-1430-initiative-equipment-migration.md
     20260320-1430-initiative-equipment-migration-erp.md
     20260320-1430-initiative-equipment-migration-shared-services.md
     20260320-1430-initiative-equipment-migration-portal.md

     Next steps:
     1. Open erp repo → /spec-os-brainstorm with 20260320-1430-initiative-equipment-migration-erp.md
     2. Open shared-services repo → /spec-os-brainstorm with ...shared-services.md
     3. Open portal repo → /spec-os-brainstorm with ...portal.md
```

**Tips:**
- Install as `~/.claude/skills/spec-os-explore/` in Claude Desktop
- The master file is your holistic reference — keep it. The per-app files are consumed by each project's brainstorm.
- Timestamp-first naming groups all files from the same initiative session when sorted by name
- The Epic in ADO is optional — not every initiative is large enough to warrant one

---

### `/spec-os-brainstorm`

Analyze an idea or requirement, identify the real problem, and create `origin.md` as the strategic record.

**Syntax:**
```
/spec-os-brainstorm [description]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `description` | No | Brief description of the idea or problem (prompted if not provided) |

**What it does:**
- Opens an exploratory conversation to understand the idea in depth
- Reads `spec-os/config.yaml` to identify tracker type
- Consults tracker for relevant context (active features, capacity, related items)
- Identifies the real problem behind the stated request
- Classifies the request (feature, maintenance, bug, spike)
- Assigns a complexity signal (simple | medium | complex) — not Story Points
- **Feature resolution:** searches tracker for an existing related Feature
  - If found → proposes linking → dev confirms → `feature-id` stored in `origin.md`
  - If not found → proposes creating a new Feature → dev confirms → creates it (title, description, area path — no SP) → `feature-id` stored in `origin.md`
- Creates `origin.md` with full strategic context and resolved `feature-id`
- Notifies developer and proposes handoff to `/spec-os-create`

**SP is not estimated here.** Story Points are the exclusive responsibility of `/spec-os-plan`, which has the full spec and AC context needed to size accurately.

**Example:**
```
You: /spec-os-brainstorm

AI:  What idea or requirement would you like to analyze?

You: We need to send email notifications when equipment status changes

AI:  Analyzing...
     Reading tracker context (ADO)...

     Real problem: Operations team has no visibility into equipment state
     changes — they discover issues reactively, after delays.

     Proposed solution: Event-driven email notifications on status change,
     configurable per equipment type and recipient role.

     Classification: Feature | Complexity: medium

     Searching for related Feature in ADO...
     No matching Feature found.

     Create Feature in ADO?
     Title: "Equipment status email notifications"
     Description: "Operators need visibility into equipment state changes..." [y/n]

You: y

AI:  Created Feature F042 in ADO.

     Created: spec-os/changes/F042-S24-equipment-notifications/origin.md

     Ready to create the technical spec?
     Run /spec-os-create to continue.
```

**Tips:**
- Run from Claude Desktop (personal skill) — it's the entry point before any session
- Also available as `~/.claude/skills/spec-os-brainstorm/` for cross-project use
- The `origin.md` it creates is never modified or deleted — it's the permanent record of intent

---

### `/spec-os-bug`

Analyze a bug and route it to either a simple or complex resolution path.

**Syntax:**
```
/spec-os-bug [bug-id]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `bug-id` | No | Tracker Bug ID (ADO or GitHub issue number — prompted if not provided) |

**What it does:**
- Reads tracker bug via adapter (title, description, repro steps, severity)
- Classifies as simple or complex based on scope and root cause clarity
- **Simple path:** creates minimal feature folder (`B{ID}-{name}/`) with `spec.md` + single-task `tasks.md` → notifies dev → handoff to `/spec-os-implement`
- **Complex path:** creates `analysis.md` with deep investigation → notifies dev to review → dev invokes `/spec-os-create` → full spec-plan-implement path

**Simple vs Complex routing:**
| Condition | Route |
|-----------|-------|
| Root cause clear, single file scope, fix < 2h | Simple |
| Multiple root causes, cross-layer, requires design decision | Complex |
| Requires changes to spec.md or domain model | Complex |

**Example:**
```
You: /spec-os-bug 1847

AI:  Reading bug #1847: "Null reference on equipment export when no results"

     Root cause: Export handler doesn't guard against empty result set.
     Scope: Single file — EquipmentExportHandler.cs
     Estimated fix: 30 minutes

     Classification: SIMPLE

     Created: spec-os/changes/B1847-equipment-export-null/
       spec.md  (bug context + expected behavior)
       tasks.md (T01: add null guard in EquipmentExportHandler)

     Ready to implement?
     Run /spec-os-implement T01 to fix the bug.
```

---

### `/spec-os-init`

Initialize spec-os in a new project, adopt it in an existing project, or update an existing installation.

**Syntax:**
```
/spec-os-init [mode]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `mode` | No | `initialize` \| `adopt` \| `update` (detected automatically if not provided) |

**Modes:**

**Initialize** — new project, no existing code:
- Creates complete `spec-os/` structure
- Asks developer to declare domains → creates `spec-os/specs/_index.md` + stubs
- Creates `.claude/CLAUDE.md` (thin template)
- Creates `.claude/skills/spec-os-*/SKILL.md` for all skills
- Creates `docs/` structure (design, domains, runbooks, manual)
- Creates `spec-os/version` with current version

**Adopt** — existing project:
- Scans codebase to identify bounded contexts, modules, namespaces
- Proposes domain list → dev confirms/edits
- Creates `spec-os/` structure + domain stubs seeded from existing code
- Generates specialist subagents (backend-dev, frontend-dev) via Skill Creator based on detected stack
- Does NOT modify existing CLAUDE.md — proposes a replacement for dev approval

**Update** — spec-os already installed, new version available:
- Reads `spec-os/version` to detect current version
- Shows changelog between installed and current version
- Updates skills and config schema
- Can add new domains to `_index.md`

**Example:**
```
You: /spec-os-init

AI:  Detecting mode... No spec-os/ folder found.
     Mode: INITIALIZE

     What domains does this project have?
     (e.g., equipos, facturacion, auth, reportes)

You: equipos, mantenimiento, reportes, usuarios

AI:  Creating spec-os structure...
     Creating domain stubs...
     Creating skills...

     Created:
     spec-os/config.yaml
     spec-os/version (1.0.0)
     spec-os/standards/ (global, backend, frontend)
     spec-os/specs/_index.md (4 domains)
     spec-os/specs/equipos/spec.md
     spec-os/specs/mantenimiento/spec.md
     spec-os/specs/reportes/spec.md
     spec-os/specs/usuarios/spec.md
     .claude/CLAUDE.md
     .claude/skills/spec-os-*/ (14 skills)

     Next: Fill in spec-os/config.yaml with your tracker details.
```

---

### `/spec-os-create`

Create the technical specification for a feature, starting from `origin.md` or a tracker Feature ID.

**Syntax:**
```
/spec-os-create [feature-id]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | Tracker Feature ID (reads from origin.md if not provided) |

**What it does:**
- Reads `origin.md` from the changes folder (or asks for tracker Feature ID)
- Reads tracker Feature via adapter (full context, AC, linked items)
- Reads `docs/design/00-overview.md` + domain design file
- **Guards:** validates domain exists in `spec-os/specs/_index.md` — stops if not found
- **Guards:** checks for conflicts in `spec-os/changes/` (same feature already in progress)
- Creates feature folder with: `spec.md`, `spec-delta.md` (empty), `session-log.md` (empty), `verify-report.md` (empty)
- Preserves `origin.md` as-is
- Notifies dev → proposes handoff to `/spec-os-plan`

**Update mode** (invoked by `/spec-os-implement` during RECONCILE):
- Reads current `spec.md` + proposed change from implementation discovery
- Proposes formal delta entry for dev approval
- On approval: writes `spec.md` update + `spec-delta.md` entry
- Returns list of tasks affected by the change

**Example:**
```
You: /spec-os-create

AI:  Reading origin.md from F042-S24-equipment-notifications/...
     Reading Feature F042 from ADO...
     Reading docs/design/03-equipment-domain.md...

     Domain: equipos — found in _index.md. OK.
     No conflicts in changes/. OK.

     Creating spec...

     Created: spec-os/changes/F042-S24-equipment-notifications/
       spec.md        (technical spec)
       spec-delta.md  (empty — ready for evolution tracking)
       session-log.md (empty)
       verify-report.md (empty)

     Ready to plan?
     Run /spec-os-plan to decompose into User Stories and tasks.
```

---

### `/spec-os-plan`

Decompose the technical spec into User Stories with Acceptance Criteria and atomic tasks.

**Syntax:**
```
/spec-os-plan [feature-id]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | Feature folder name (inferred from context if not provided) |

**What it does:**
- Reads `spec.md` fully
- Defines User Stories with AC in Given/When/Then format (including edge cases)
- Applies sizing rules: SP scale 1/2/3/5/8/13, split if SP > 8 or two distinct outcomes, merge if same role/goal + combined SP ≤ 5 + same files
- Creates US in tracker via adapter
- Generates `tasks.md` with all fields per task: `subagent`, `depends-on`, `scope`, `done-when`, `context-level`, `ux-impact`, `claimed-by`, `status`, `lessons-pending`
- Notifies dev → proposes handoff to `/spec-os-implement` T01

**Update mode** (invoked by `/spec-os-implement` during RECONCILE):
- Reads `tasks.md` + list of affected tasks from `/spec-os-create` Update
- Proposes specific adjustments: scope changes, done-when updates, new tasks, US splits
- On dev approval: updates `tasks.md` + creates new US in tracker if split occurred

**Example:**
```
You: /spec-os-plan

AI:  Reading spec.md for F042...

     Defining User Stories:
     US-1: As an operator, I want to receive email when equipment changes status
           AC-1: Given equipment status changes, When I am subscribed to that type,
                 Then I receive an email within 5 minutes
           AC-2: Given notification fails, When retry exhausted, Then event is logged
           SP: 5

     US-2: As an admin, I want to configure notification subscriptions per role
           SP: 3

     Created US-142 and US-143 in ADO.

     Generated tasks.md (US-1: T01-T03, US-2: T04-T05)

     Ready to implement?
     Starting with T01 — /spec-os-implement T01
```

---

### `/spec-os-implement`

Execute one task. One session per task, one atomic commit per task.

**Syntax:**
```
/spec-os-implement [task-id]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `task-id` | No | Task ID from tasks.md (e.g. T01 — prompted if multiple in progress) |

**What it does:**

```
INIT:
  Resolve tracker config from spec-os/config.yaml
  Check claimed-by: if already claimed by another dev -> stop
  Assign claimed-by: {current dev}
  Check task status:
    if in-progress -> RESUME MODE (load session-log entry for this task)
    if planned -> normal start

LOAD: Context by tier (1 always; 2-3 per task's context-level)

STANDARDS: Invoke /spec-os-inject with task keywords and subagent type

CONFIRM: Identify specialist (backend-dev or frontend-dev)
         Notify dev -> wait for approval [HANDOFF]

EXECUTE: Invoke specialist subagent

RECONCILE:
  1. git diff -- spec.md: if changed -> propose /spec-os-create Update [HANDOFF]
  2. Reasoning check: "Did implementation reveal anything undocumented in spec.md?"
     if yes -> propose /spec-os-create Update [HANDOFF]
     if tasks affected -> propose /spec-os-plan Update [HANDOFF]

COMMIT: Atomic commit

UPDATE: tasks.md status (in-progress -> done) + lessons-pending

LOG: Write session-log.md entry

IF US complete:
  -> /spec-os-verify [HANDOFF]
ELSE:
  Notify dev of next task
```

**Resume mode:** If invoked with a task that has `status: in-progress`, automatically loads the previous `session-log.md` entry for that task as additional context and continues from the last known state.

**Example:**
```
You: /spec-os-implement T01

AI:  Task T01: Implement NotificationDispatcher service

     claimed-by: ivan (assigned)
     Context: Tier 2
     Subagent: backend-dev

     Loading standards for: dotnet, domain-events, email...
     Loaded: architecture.md, patterns.md

     Identified specialist: backend-dev
     Proceeding with backend-dev. Confirm? [y/n]

You: y

AI:  [Executes backend-dev subagent]
     [Creates NotificationDispatcher.cs, registers in DI, adds unit tests]

     Reconciling spec...
     No spec.md changes detected.

     Committing: "feat(equipos): add NotificationDispatcher service [F042-T01]"

     T01 done. Next: T02 — Create email template renderer
     Run /spec-os-implement T02
```

---

### `/spec-os-verify`

Quality gate for a User Story. Verifies AC coverage, tests, conventions, and Definition of Done.

**Syntax:**
```
/spec-os-verify [us-id]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `us-id` | No | User Story ID (inferred from current feature context if not provided) |

**What it does:**
- Reads DoD from `spec.md`, AC from tracker, `done-when` from all tasks, `spec-delta.md`
- Runs local tests (`dotnet test`, `pytest`, `npm test` — based on stack in config)
- Checks: AC coverage, test results, scope compliance, conventions, placeholders, DoD completeness
- Writes `verify-report.md` entry with full results
- **PASS:** creates PR using `pr-template.md`, updates tracker US to `in-review`, notifies dev → handoff to `/spec-os-doc` (if ux-impact) then `/spec-os-sync`
- **FAIL simple:** notifies dev with specific issues → handoff to `/spec-os-implement`
- **FAIL complex:** deep diagnosis → enriched context → notifies dev → handoff to `/spec-os-implement`

**Example:**
```
You: /spec-os-verify

AI:  Verifying US-142 (equipment notifications)...

     AC Coverage:       3/3
     Unit tests:        passing (12 tests)
     Integration tests: passing (3 tests)
     Coverage:          87% (minimum: 80%)
     Scope compliance:  clean
     Conventions:       clean
     Placeholders:      none
     DoD:               complete

     Result: PASS

     Created PR #89: "feat(equipos): equipment status email notifications [US-142]"
     Updated ADO US-142 to in-review

     US-142 has ux-impact tasks. Run /spec-os-doc to update user documentation.
```

---

### `/spec-os-discover`

Scan the codebase and extract coding conventions into structured standards files.

**Syntax:**
```
/spec-os-discover [category]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `category` | No | `global` \| `backend` \| `frontend` (scans all if not provided) |

**What it does:**
- Scans codebase for patterns: naming conventions, error handling, test structure, component patterns
- Identifies implicit standards not yet documented
- Proposes new or updated standards files with specific content
- Dev reviews and approves each proposed standard
- Writes to `spec-os/standards/{category}/{name}.md`
- Updates `spec-os/standards/index.yml` with new entries

**Tips:**
- Run during `/spec-os-init` Adopt mode to bootstrap standards from existing code
- Run periodically as the codebase evolves to capture new patterns
- Good for onboarding: surfaces tribal knowledge into documented standards

---

### `/spec-os-inject`

Load only the standards relevant to the current task. Called internally by `/spec-os-implement`.

**Syntax:**
```
/spec-os-inject [keywords] [subagent-type]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `keywords` | Yes | Task keywords for matching against index.yml |
| `subagent-type` | Yes | `backend` \| `frontend` — filters category |

**What it does:**
- Reads `spec-os/standards/index.yml`
- Matches `keywords` against each standard's keyword list
- Returns content of matched standards files only
- Filters by `subagent-type` to avoid loading irrelevant standards

**Tips:**
- Not typically invoked directly — `/spec-os-implement` calls it automatically
- Replaces the "load all of CLAUDE.md" approach with targeted loading

---

### `/spec-os-standard`

Update an existing standard or create a new one with developer guidance.

**Syntax:**
```
/spec-os-standard [standard-path]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `standard-path` | No | Path relative to `spec-os/standards/` (e.g. `backend/testing`) |

**What it does:**
- If standard exists: reads current content, proposes specific updates, dev approves, writes
- If standard is new: creates file with proper structure, dev reviews content, writes
- Updates `index.yml` if keywords change
- Records what changed and why (similar to spec-delta concept but for standards)

---

### `/spec-os-sync`

Sync pending lessons from session logs to knowledge-base. Always the last skill in the chain.

**Syntax:**
```
/spec-os-sync [feature-id]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | Feature folder name (inferred from context if not provided) |

**What it does:**
- Extracts lessons marked `pending: true` from `session-log.md`
- Validates domain tags against `spec-os/specs/_index.md`
- Proposes formatted entries for `knowledge-base.md` with proper tags
- Dev approves additions
- Writes to `knowledge-base.md`
- Marks lessons as synced in session-log
- Checks archival: asks dev to confirm if Feature is done in tracker → moves to `changes/archive/`

**Tips:**
- Only runs after `/spec-os-verify` PASS — never after FAIL
- The archival check is the only moment when the feature folder moves to archive
- `/spec-os-prune` is the companion skill for cleaning up stale knowledge-base entries

---

### `/spec-os-abandon`

Close a feature without completing it. Preserves all artifacts for historical reference.

**Syntax:**
```
/spec-os-abandon [feature-id]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | Feature folder name (prompted if not provided) |

**What it does:**
- Asks dev for abandonment reason
- Updates `spec.md` status to `abandoned`
- Updates tracker Feature/US status to cancelled via adapter
- Moves feature folder to `changes/archive/{date}-abandoned-{name}/`
- Does NOT run `/spec-os-sync` (no lessons from an abandoned feature unless dev requests)

---

### `/spec-os-doc`

Update user-facing documentation for a completed User Story. Conditional — only runs if US has `ux-impact: true`.

**Syntax:**
```
/spec-os-doc [us-id]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `us-id` | No | User Story ID (inferred from context if not provided) |

**What it does:**
- Reads US from tracker
- Identifies affected sections in `docs/manual/{domain}.md`
- Proposes specific documentation updates
- Dev approves
- Writes updated documentation
- Notifies dev → handoff to `/spec-os-sync`

---

### `/spec-os-prune`

Clean up outdated or superseded entries from `knowledge-base.md`.

**Syntax:**
```
/spec-os-prune [domain]
```

**Arguments:**
| Argument | Required | Description |
|----------|----------|-------------|
| `domain` | No | Domain tag to prune (prunes all domains if not provided) |

**What it does:**
- Reads `knowledge-base.md`
- Identifies entries that are outdated (patterns no longer used, superseded decisions, stale gotchas)
- Proposes specific removals or updates with rationale
- Dev approves each change
- Writes updated `knowledge-base.md`

**Tips:**
- Run periodically (e.g. after major refactors or architecture changes)
- Focus on `type: anti-pattern` and `type: gotcha` entries — these become stale fastest
- Pair with `/spec-os-discover` to replace stale standards with updated ones
