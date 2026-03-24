# Spec-OS: Design Decisions & Resolved Gaps

---

## 5. Key Design Decisions

### Decision 1: Tracker Adapter Pattern

**Problem:** ADO hardcoded in every skill
**Solution:** `spec-os/config.yaml` declares tracker type. Each skill reads config and uses the appropriate MCP.

```yaml
tracker:
  default: ado
  repos:
    - name: {repo-name}
      type: ado
      organization: https://dev.azure.com/{org}
      project: {ado-project-name}
    - name: {other-repo}
      type: github
      org: {github-org}
      repo: {repo-name}
```

**How skills use it:** Each skill includes a "Tracker resolution" step: read `spec-os/config.yaml`, identify current repo name, use the matching tracker config. If `type: ado` → Azure DevOps MCP. If `type: github` → GitHub MCP.

**Future-proofing:** New tracker = new adapter section in config. Zero skill changes.

---

### Decision 2: Lazy Context Loading (3 Tiers)

**Problem:** 7-file fixed startup wastes tokens even for trivial tasks
**Solution:** Each task declares its `context-level` in `tasks.md`. `/spec-os-implement` loads accordingly.

```
TIER 1 (always, ~1KB):
  - CLAUDE.md identity section only (first 20 lines)
  - Task definition from tasks.md (one task section)
  - spec.md frontmatter only

TIER 2 (most tasks, +10-20KB):
  - Relevant standards via /spec-os-inject (using index.yml)
  - Domain spec from spec-os/specs/{domain}/
  - session-log.md entry for depends-on task only

TIER 3 (complex tasks, +20-40KB):
  - Full spec.md (or specific sections)
  - spec-os/specs/knowledge-base.md filtered by domain + stack tags
  - Relevant ADRs from docs/design/adr/ if referenced in spec.md
```

**Who sets context-level:** `/spec-os-plan` sets it during task decomposition based on task complexity. Default is tier 2.

---

### Decision 3: spec-delta.md for Spec Evolution

**Problem:** When spec.md changes during implementation, there's no record of what changed and why
**Solution:** A dedicated `spec-delta.md` file in each change folder, updated by `/spec-os-create` Update mode whenever spec.md is modified.

```markdown
## Delta — T05 — 2026-03-15

### MODIFIED
- Equipment.Status field: added 'calibration-pending' state
  Reason: edge case discovered in AC that wasn't modeled
  Tasks affected: T06 (scope change), T07 (tests need update)

### ADDED
- Business rule: equipment cannot be assigned while calibration-pending
  Reason: PO clarified during T04 session
  Tasks affected: T07 (add validation logic)
```

---

### Decision 4: origin.md — Preserve Strategic Reasoning

**Problem:** `brainstorm-output.md` is deleted after `spec-create` — the "why we built this" is lost
**Solution:** Rename to `origin.md`, keep it permanently in the feature folder. Never modified after creation.

`origin.md` contains: original problem statement, real problem identified, proposed solution, classification, effort estimate, tracker context at time of analysis, pending decisions, resolution notes.

---

### Decision 5: knowledge-sync Lazy Trigger

**Problem:** `knowledge-sync` queries tracker for ALL active features after EVERY task
**Solution:**
- After each task: lessons marked `pending: true` in session-log.md
- `/spec-os-sync` runs at US completion only (when all tasks of a US are done)
- Archival check only runs when developer explicitly confirms a US is done
- Reduces tracker queries from O(tasks × features) to O(US completions)

---

### Decision 6: CLAUDE.md Becomes Thin

**Problem:** CLAUDE.md mixes project identity, coding conventions, security rules, agent behavior, and skill inventory
**Solution:** CLAUDE.md keeps only project identity and pointers. Everything else moves to its proper layer.

```markdown
# CLAUDE.md — [Project Name]

## Identity
Project: {name}
Description: {one sentence}
Stack: {stack}
Tracker: see spec-os/config.yaml
Standards: spec-os/standards/index.yml
Framework: spec-os v{version}

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
[keep here — identity-level, non-negotiable]

## Entry points
- New idea/requirement: `/spec-os-brainstorm`
- Bug to fix: `/spec-os-bug` with tracker Bug ID
- New project or adoption: `/spec-os-init`
```

All coding conventions → `spec-os/standards/`
Commit conventions → `spec-os/standards/global/commits.md`

---

### Decision 7: Configurable Approval Gates

**Problem:** 5-6 explicit gates per feature is friction for experienced developers
**Solution:** Configurable in `spec-os/config.yaml`

```yaml
workflow:
  approval-gates:
    skill-handoffs: explicit    # explicit | auto
    spec-changes: explicit      # always explicit
    destructive-actions: explicit
    pr-creation: explicit
```

---

### Decision 8: spec-verify Report Persisted

**Problem:** Quality report is ephemeral — only in chat, lost after session
**Solution:** `/spec-os-verify` writes a `verify-report.md` in the feature folder after each verification cycle.

---

### Decision 9: doc-update Conditional Invocation

**Problem:** `doc-update` always runs even for backend tasks with no observable user-facing change
**Solution:** `/spec-os-plan` marks tasks with `doc-impact: true | false`. `/spec-os-verify` only invokes `/spec-os-doc` if at least one task in the US has `doc-impact: true`.

`doc-impact: true` applies to: UI/UX changes, API contract changes visible to consumers, business rule changes observable by users, permission or role changes. Not limited to visual UI — any change an end user or integrating team needs to know about.

---

### Decision 10: Universal Cadence Naming

**Problem:** `4M1` cadence format is org-specific
**Solution:** Configurable in `spec-os/config.yaml`

```yaml
project:
  cadence-format: sprint    # sprint | milestone | quarter | custom
```

---

### Decision 11: All Skill Handoffs Explicit by Default

**Problem:** Automatic handoffs between skills skip developer validation — critical in v1 where workflow is being validated.
**Solution:** `skill-handoffs: explicit` is the default in `config.yaml`. Every skill-to-skill transition pauses and notifies the developer before proceeding.

Complete handoff map (all require dev confirmation in v1):
- `/spec-os-brainstorm` → `/spec-os-design`
- `/spec-os-bug` → `/spec-os-implement` (simple path)
- `/spec-os-design` → `/spec-os-plan`
- `/spec-os-plan` → `/spec-os-implement` T01
- `/spec-os-implement` → `/spec-os-verify` (on US complete)
- `/spec-os-verify` → `/spec-os-doc` (on PASS + doc-impact)
- `/spec-os-verify` → `/spec-os-implement` (on FAIL)
- `/spec-os-doc` → `/spec-os-sync` (always last, always explicit)

`/spec-os-design` Update mode and `/spec-os-plan` Update mode (invoked during RECONCILE) are also explicit — they propose changes and wait for dev approval before writing.

---

### Decision 12: spec-implement Resume Mode

**Problem:** If a session is interrupted mid-task, there is no defined re-entry point.
**Solution:** Resume mode built into `/spec-os-implement` INIT step. If task `status: in-progress` → load session-log.md entry for that task as additional context → continue from last known state. Developer re-invokes `/spec-os-implement` with the same task ID.

---

### Decision 13: US Completion Order — verify → doc → sync

**Problem:** knowledge-sync was triggered before spec-verify — syncing lessons from a US that hadn't passed the quality gate yet.
**Solution:** Fixed order on US completion:
1. `/spec-os-verify` (quality gate)
2. `/spec-os-doc` (if ux-impact: true) — only if PASS
3. `/spec-os-sync` (always last) — only if PASS

If `/spec-os-verify` FAIL: `/spec-os-sync` does NOT run. Lessons stay `pending: true` in session-log until next attempt.

---

### Decision 14: Bug Simple Path — Minimal Feature Folder

**Problem:** `/spec-os-bug` simple path routed directly to `/spec-os-implement`, which expects spec.md and tasks.md to exist.
**Solution:** `/spec-os-bug` creates a minimal feature folder before handing off:
- `changes/B{ID}-{name}/spec.md` — bug ID, description, reproduction steps, expected behavior
- `changes/B{ID}-{name}/tasks.md` — single T01 task with scope and done-when

`/spec-os-implement` runs normally — unaware of the bug vs feature distinction. The "simple" path is simple because `/spec-os-bug` replaces `/spec-os-create` + `/spec-os-plan` with a streamlined version. No US definition, no sizing, no formal AC.

Complex bugs: `/spec-os-bug` creates `analysis.md` → dev reviews → `/spec-os-create` → `/spec-os-plan` → `/spec-os-implement` (full path).

---

### Decision 15: Task Claiming for Parallel Development

**Problem:** tasks.md and session-log.md have write conflicts when 2+ developers work simultaneously on the same feature.
**Solution:** `claimed-by` field per task. `/spec-os-plan` generates it empty. `/spec-os-implement` assigns it in the INIT step.

```markdown
### T01 — {task title}
- claimed-by: —        <- empty when generated by spec-plan
- status: planned
```

`session-log.md` tolerates auto-merge because each task has a unique section header (`## T{NN}`). Git resolves concurrent appends automatically.

**Convention:** Developers must check `tasks.md` before claiming a task to avoid collisions.

---

### Decision 16: project-init as Owner of Domain Specs

**Problem:** `spec-os/specs/{domain}/spec.md` files need to exist before `/spec-os-design` runs, but had no defined creation mechanism.
**Solution:** `/spec-os-init` is the sole owner of domain spec creation across all three modes.

- **Initialize:** dev declares domains → creates `_index.md` + stubs per domain
- **Adopt:** scans codebase (namespaces, modules, bounded contexts) → proposes domain list → dev confirms → creates `_index.md` + stubs seeded from existing code
- **Update:** adds new domains post-adoption

`/spec-os-design` has a hard guard: validates domain exists in `_index.md`. If not → stops with clear instruction to run `/spec-os-init Update`.

---

### Decision 17: knowledge-base Tag Schema with _index.md Validation

**Problem:** `spec-os/specs/knowledge-base.md` needs tags for smart filtering, but free-form domain tags risk inconsistency.
**Solution:** Fixed global schema with `domain` tag validated against `spec-os/specs/_index.md`.

```
stack:  [dotnet, odoo, nextjs, python, general]
domain: validated against spec-os/specs/_index.md
layer:  [domain, application, infrastructure, presentation, global]
type:   [pattern, gotcha, anti-pattern, performance, security]
```

`/spec-os-sync` validates domain tag exists in `_index.md` before writing to `spec-os/specs/knowledge-base.md`. No separate configuration needed — the domain registry already exists.

---

### Decision 18: spec-evolve Eliminated — spec-create and spec-plan Own Their Artifacts

**Problem:** spec-evolve was a middleman skill with no clear ownership — it updated spec.md (owned by spec-create) and affected tasks.md (owned by spec-plan).
**Solution:** Each skill owns its artifact across its full lifecycle, including updates.

- **`/spec-os-design`** owns spec.md + spec-delta.md for the entire feature lifecycle (create + update)
- **`/spec-os-plan`** owns tasks.md for the entire feature lifecycle (create + update)
- **`/spec-os-implement`** orchestrates via a RECONCILE step after each EXECUTE:
  1. `git diff` check on spec.md — if changed by dev → invokes `/spec-os-design` Update mode
  2. Reasoning check — "Did implementation reveal anything undocumented in spec.md?" → invokes `/spec-os-design` Update mode if yes
  3. If spec change affects tasks → invokes `/spec-os-plan` Update mode

Both Update modes are dev-assisted: they propose changes, dev approves before writing. Neither runs silently.

---

### Decision 19: Brainstorm Owns Feature Resolution in Tracker — SP Owned Exclusively by spec-plan

**Problem:** No skill was responsible for creating or linking a Feature in the tracker. The `feature-id` chain (origin.md → spec.md → tasks.md) could start empty if the Feature didn't exist yet, breaking the link when `/spec-os-plan` creates User Stories in ADO. Additionally, `/spec-os-brainstorm` estimated SP, creating a second estimation source that conflicted with `/spec-os-plan`'s authoritative sizing.

**Solution — Feature resolution:**

`/spec-os-brainstorm` is responsible for resolving the tracker Feature before creating `origin.md`:

1. Search for an existing Feature in ADO/GitHub related to the analyzed idea
2. If found → propose linking to it → dev confirms → `feature-id` stored in `origin.md`
3. If not found → propose creating a new Feature → dev confirms → create it → `feature-id` stored in `origin.md`

Feature created in ADO contains: title, description (real problem + proposed solution), area path (from config.yaml). No SP — Features do not carry Story Points in ADO.

**Solution — SP ownership:**

Story Points are the exclusive responsibility of `/spec-os-plan`. It is the only skill with the full context needed to estimate accurately: complete `spec.md`, AC in Given/When/Then, sizing rules (1/2/3/5/8/13).

`/spec-os-brainstorm` replaces `effort-estimate` with `complexity: simple | medium | complex` in `origin.md` — a non-binding directional signal, not a commitment.

```yaml
# origin.md — complexity signal only
complexity: simple | medium | complex

# tasks.md — authoritative SP, set by /spec-os-plan
## US #142 — title
SP: 5
```

**Result:** `feature-id` is always populated in `origin.md` before `/spec-os-create` runs. SP has a single source of truth. No manual step required between brainstorm and create.

---

### Decision 20: spec-os-explore — Cross-Repo Initiative Analysis

**Problem:** Business initiatives often span multiple applications or systems. No skill existed to analyze an initiative holistically across repos before distributing work to individual project teams. Starting from `/spec-os-brainstorm` inside a single repo loses the cross-system view.

**Solution:** A new personal skill `spec-os-explore`, installed in Claude Desktop (`~/.claude/skills/spec-os-explore/`), operating at the portfolio level above individual repos.

**Scope:**
- Connects to multiple repos and their trackers via config
- Analyzes a business initiative or requirement across all affected systems
- Identifies inter-app dependencies and execution order
- Generates a master initiative file + one context package per affected app
- Optionally creates an Epic in ADO/GitHub when the initiative warrants one (not always)

**Output file naming — timestamp first:**

```
{YYYYMMDD-HHmm}-initiative-{slug}.md              ← master (cross-app view)
{YYYYMMDD-HHmm}-initiative-{slug}-{app}.md        ← one per affected app

Example:
20260320-1430-initiative-equipment-migration.md
20260320-1430-initiative-equipment-migration-erp.md
20260320-1430-initiative-equipment-migration-portal.md
```

Timestamp-first naming groups all files from the same session chronologically when sorted by name.

**Where files live:** Claude Desktop project files. Not in any individual repo.

**Handoff:** Developer takes each `{timestamp}-initiative-{slug}-{app}.md` and passes it to the corresponding repo's `/spec-os-brainstorm`. Brainstorm uses it as additional context, does deep per-project analysis, resolves the Feature in ADO (under the Epic if one was created), and produces the authoritative `origin.md`.

**ADO hierarchy this enables:**

```
Epic                ← spec-os-explore creates (optional — when initiative warrants it)
  Feature-App1      ← /spec-os-brainstorm App1 creates (Decision 19)
  Feature-App2      ← /spec-os-brainstorm App2 creates (Decision 19)
    User Story      ← /spec-os-plan creates
      Task          ← /spec-os-implement executes
```

**Relationship to spec-os-brainstorm:**

`spec-os-explore` outputs are *context packages*, not `origin.md`. The `{timestamp}-initiative-{slug}-{app}.md` files are input to brainstorm, which produces the authoritative `origin.md` per project. The two skills are complementary, not overlapping.

---

### Decision 21: Progressive Rigor — spec-level Tied to context-level

**Problem:** `context-level` in tasks.md controlled how much context Claude loads at implementation time, but there was no explicit criterion for when a feature needs a lite vs full spec. `/spec-os-plan` assigned context-level without a documented rationale.

**Solution:** Introduce `spec-level: lite | full` in `spec.md` frontmatter (set by `/spec-os-create`) and tie it explicitly to `context-level` (set by `/spec-os-plan`). Use the lightest spec level that still makes the change verifiable.

```
spec-level: lite  →  context-level: 1
spec-level: full  →  context-level: 2 or 3
```

**Criteria for spec-level assignment (used by `/spec-os-design`):**

| Condition | spec-level |
|-----------|-----------|
| Bug fix, single-file scope, no behavior contract change | lite |
| Internal refactor with no observable behavior change | lite |
| New feature, bounded scope, single domain | full (context-level: 2) |
| Cross-repo change, API/event contract, migration | full (context-level: 3) |
| Security, privacy, or compliance impact | full (context-level: 3) |
| High ambiguity — likely to cause expensive rework if wrong | full (context-level: 3) |

**What lite spec means in practice:**
- `spec.md` has Scope + 1-3 Requirements with scenarios
- No Domain model section needed
- `/spec-os-verify` checks observable behavior against scenarios only

**What full spec means in practice:**
- `spec.md` has all sections: Scope, Requirements (with RFC 2119), Domain model, Design decisions
- `/spec-os-verify` checks all sections including domain model consistency
- context-level: 3 also loads ADRs and full spec-os/specs/knowledge-base.md filter

**RFC 2119 keywords apply in both levels:**
`MUST`/`SHALL` = absolute requirement (FAIL if not met in verify)
`SHOULD` = recommended (WARNING if not met in verify)
`MAY` = optional (not checked by verify)

---

### Decision 22: spec-os-product Owns docs/ — Runs Before spec-os-init

**Problem:** `/spec-os-init` mixed framework scaffolding (`spec-os/`, `.claude/`) with product documentation creation (`docs/`), two responsibilities with fundamentally different triggers, update cycles, and analysis requirements. Product docs require business thinking; framework setup requires technical configuration.

**Solution:** Extract product documentation into a dedicated skill `/spec-os-product` that runs before `/spec-os-init`, giving the framework product context at setup time.

**Setup order:**
```
/spec-os-product → /spec-os-init → ready for /spec-os-brainstorm
```

**Responsibility split:**

| Skill | Owns | Does NOT touch |
|-------|------|----------------|
| `/spec-os-product` | `docs/` entirely: mission.md, roadmap.md, design/, runbooks/, manual/ | spec-os/, .claude/ |
| `/spec-os-init` | `spec-os/` + `.claude/` entirely | docs/ |
| `/spec-os-discover` + `/spec-os-standard` | `spec-os/standards/` | everything else |

**How spec-os-init uses product context:**
- Reads `docs/mission.md` to seed project description in `config.yaml` and `CLAUDE.md` (optional — continues without it)
- Adopt mode: reads `mission.md` to better identify domain boundaries from product context

**spec-os-product modes:**
- **Initialize:** conversational → generates `mission.md` + `roadmap.md` + `docs/` structure from scratch
- **Generate:** scans existing codebase and docs → proposes content → dev approves
- **Update:** reads existing docs → proposes specific section updates → dev approves

**Guard added to spec-os-design:**
Validates `docs/design/` exists before creating spec. Stops if not found and instructs dev to run `/spec-os-product` first. Consistent with the domain guard pattern (Decision 16).

---

### Decision 23: Specialist Subagents as Native Claude Code Agents + Stack-Specific Standards

**Problem:** Specialists (`backend-dev`, `frontend-dev`) were organized as nested SKILL.md files inside `.claude/skills/spec-os-implement/specialists/`. Claude Code skill discovery is flat — nested skills are not reliably discovered. Additionally, specialist knowledge was hardcoded in SKILL.md files, outside the standards management system (`/spec-os-discover`, `/spec-os-standard`).

**Solution — Two-part change:**

**Part 1 — Specialists move to `.claude/agents/`:**
Native Claude Code subagent definitions (Markdown + YAML frontmatter). Read and invoked by `/spec-os-implement` using the Agent tool. Never registered as invocable skills — they are executors, not entry points. Skills remain the orchestrators.

```
.claude/agents/
├── backend-dev.md    ← native subagent: YAML frontmatter + system prompt
└── frontend-dev.md   ← native subagent: YAML frontmatter + system prompt
```

`.claude/agents/{type}.md` YAML frontmatter:
```yaml
---
name: backend-dev
description: Backend specialist invoked by /spec-os-implement. Not for direct use.
tools: Read, Edit, Write, Bash, Grep, Glob
model: sonnet
---
```

Body contains:
- Agent identity and role
- Universal behavioral rules (scope, commits, propose before implement)
- Instruction to apply injected standards as execution constraints
- Does NOT contain stack-specific knowledge

**Why `.claude/agents/` over `spec-os/agents/`:**
- Native Claude Code path — `tools` and `model` fields are enforced by the platform
- Tool restriction: agents cannot use Agent tool (no nested subagents) — enforced natively
- Discoverable via `/agents` command
- Version-controlled alongside skills in `.claude/`

**Skills remain orchestrators (v1 philosophy):** `/spec-os-implement` (skill) controls all approval gates, context loading, and handoffs. Agents are executors with no decision authority over the workflow.

**Part 2 — Stack-specific knowledge moves to standards:**

```
spec-os/standards/
├── backend/
│   ├── architecture.md    ← existing
│   ├── patterns.md        ← existing
│   ├── testing.md         ← existing
│   ├── error-handling.md  ← existing
│   ├── dotnet.md          ← NEW — stack-specific
│   ├── python.md          ← NEW — stack-specific
│   └── odoo.md            ← NEW — stack-specific
└── frontend/
    ├── components.md      ← existing
    ├── state.md           ← existing
    ├── testing.md         ← existing
    ├── nextjs.md          ← NEW — stack-specific
    └── react.md           ← NEW — stack-specific
```

Managed by `/spec-os-discover` (scan) and `/spec-os-standard` (update) like all other standards.

**How `/spec-os-implement` uses this:**
```
LOAD:   /spec-os-inject → loads standards matching task keywords + stack from spec.md
AGENT:  invokes .claude/agents/{backend-dev | frontend-dev} via Agent tool
        passes injected standards as additional context
        agent executes task in isolated context with restricted tool access
```

**`/spec-os-init` creates:**
- `.claude/agents/backend-dev.md` and `frontend-dev.md` (always, with YAML frontmatter)
- Stack-specific standard stubs based on `stack` field in `config.yaml`

**Result:** Subagents are native Claude Code agents with enforced tool restrictions and model selection. Knowledge managed through standards. Skills remain the explicit orchestrators that developers invoke. `/spec-os-inject` gains stack-awareness by also reading `stack` from `spec.md` frontmatter.

---

## 9. Resolved Gaps

### Gap A — Multi-Developer Parallel Work [RESOLVED]

**Decision:** Task claiming — `claimed-by: {dev}` field in each task. See Decision 15.

### Gap B — Domain Specs Initial Creation [RESOLVED]

**Decision:** `/spec-os-init` is sole owner. See Decision 16.

### Gap C — knowledge-base Tagging Schema [RESOLVED]

**Decision:** Fixed global schema, domain validated against `_index.md`. See Decision 17.

### Gap D — Migration Path from DevCanvas [NOT APPLICABLE]

No migration needed. Team has no projects running on DevCanvas. Existing projects use `/spec-os-init` Adopt mode.

### Gap E — Sprint Review / Retrospective [DESCARTADO]

Out of scope permanently. Sprint management lives in the tracker (ADO, GitHub). Any sprint information in spec-os is informational only.

### Gap F — PR Template Content [RESOLVED]

Screenshots excluded. Template is 100% auto-generated by `/spec-os-verify`. See template in [04-templates.md](04-templates.md).

### Gap G — spec-os Version Tracking [RESOLVED]

`spec-os/version` file with semver (e.g. `1.0.0`). `/spec-os-init` Update mode reads it to detect installed version.

### Gap H — CI/CD Integration [RESOLVED]

Local test execution for v1. `/spec-os-verify` runs project test commands (`dotnet test`, `pytest`, `npm test`) directly. CI integration is a future enhancement.

---

### Decision 24: Inner Loop per Task in spec-os-implement

**Problem:** No validation cycle existed between implementation and commit. Dev-agent could commit broken code with no automated feedback before the developer reviewed.

**Solution:** An inner loop wraps each EXECUTE phase:

```
test-writer proposes test gaps [gate: dev approves]
dev-agent implements code + approved tests → commits
test-runner runs unit tests
  PASS → exit loop
  FAIL → dev-agent corrects → loop
  max-iterations exhausted → [gate: dev decides]
```

`max-iterations` is configurable in `config.yaml` under `implement.max-iterations` (default: 3). dev-agent performs the commit as the last step of its own EXECUTE — the skill does not commit on its behalf.

---

### Decision 25: test-writer Bounded by spec.md

**Problem:** Unconstrained test generation produces redundant tests and inflates scope without adding coverage value.

**Solution:** test-writer operates under two constraints:

1. **Audit first** — reads existing test files declared in `test-scope` field of tasks.md before proposing anything
2. **One test per gap** — maximum one test per AC scenario that has no prior coverage

Before writing a single line, test-writer proposes a list with justification per test (which AC scenario it covers, why existing tests don't cover it). Developer approves the list [gate] before any test is written.

`test-scope` is a new field in `tasks.md`, set by `/spec-os-plan`, that lists existing test files relevant to the task (or `none`).

---

### Decision 26: spec-reconciler as Read-Only Agent

**Problem:** RECONCILE logic inside `/spec-os-implement` was complex and required file analysis that benefited from an isolated, focused context. Mixing reconciliation reasoning with orchestration reasoning in the same session degraded quality.

**Solution:** RECONCILE is delegated to a dedicated `spec-reconciler` agent with tool restriction: Read, Grep, Glob only. It cannot write anything.

spec-reconciler runs after the inner loop exits (PASS), before REVIEW. It checks:
1. `git diff -- spec.md` — did the developer modify spec.md directly?
2. Reasoning scan — does the implementation reveal behavior undocumented in spec.md?

Results are returned to `/spec-os-implement`, which owns all gates and handoffs.

**Standalone mode:** `/spec-os-implement reconcile [task-id]` — runs only RECONCILE on a completed task (useful when dev suspects drift after the session).

**Unclaim mode:** `/spec-os-implement unclaim [task-id]` — releases `claimed-by` field. Use when a developer abandons a task mid-session without completing it.

---

### Decision 27: /spec-os-sync Runs at PR Creation

**Problem:** sync was triggered at US completion, but the natural sync moment is when the PR is created — work is done and validated.

**Solution:** `/spec-os-sync` runs automatically after verify PASS + PR created. It is:
- **Lesson sync only** — reads lessons with `pending: true` from session-log.md, writes to knowledge-base.md
- **Idempotent** — skips lessons already marked `pending: false`
- **No archival** — archival responsibility moved entirely to `/spec-os-clean` (Decision 28)

---

### Decision 28: Archival Moves to /spec-os-clean

**Problem:** `/spec-os-sync` mixed two concerns: lesson sync (happens after every US) and feature archival (happens at release close). Different triggers, different frequencies, different risk levels.

**Solution:** `/spec-os-clean` owns both maintenance responsibilities:
1. **Knowledge-base cleanup** — scans `spec-os/specs/knowledge-base.md` for obsolete, contradictory, or superseded entries; proposes removals or updates [gate]
2. **Feature archival** — moves completed features from `spec-os/changes/` to `spec-os/archive/` at sprint/release close [gate]

Developer runs `/spec-os-clean` manually at the end of a release cycle. Not part of the daily workflow. Previous name `spec-os-prune` was renamed to `spec-os-clean` for clarity.

---

### Decision 29: code-reviewer Agent Eliminated

**Problem:** A `code-reviewer` agent was considered to provide automated code review before COMMIT.

**Decision:** Not implemented. The conventions check in `/spec-os-verify` (standards compliance against `spec-os/standards/`) already covers automated review of coding conventions. Architectural and business-logic judgment belongs to the human reviewer in the PR. Adding a code-reviewer agent between EXECUTE and COMMIT would add latency without adding value that either the standards check or the human reviewer doesn't already provide.

---

### Decision 30: T{NN} Tasks No Se Crean en el Tracker Externo

**Problem:** Ambigüedad sobre si las tareas T{NN} de `tasks.md` debían crearse como work items en ADO/GitHub, generando riesgo de dos fuentes de verdad.

**Decision — Modelo A: tasks.md es el único tracker de tareas:**

Los T{NN} de `tasks.md` son el tracker de implementación de spec-os. No se crean como Task work items en ADO/GitHub. El tracker externo trackea solo a nivel de US (y superiores).

**Razones:** dos fuentes de verdad generan desincronización; los ADO Tasks raramente se usan en la práctica; los campos de spec-os no mapean limpiamente a ADO Tasks.

**Única concesión de visibilidad:** `/spec-os-implement` INIT agrega un comentario al tracker US cuando reclama una tarea: `"T{NN} in progress — {title} — {dev}"`. No crea un Task work item.

`config.yaml` reserva `tracker.create-tasks: false` para v2.

---

### Status Lifecycle — Quién Actualiza Qué

**tasks.md por tarea:**

| Estado | Responsable | Momento |
|--------|-------------|---------|
| `planned` | `/spec-os-plan` | Al crear |
| `in-progress` + `claimed-by: {dev}` | `/spec-os-implement` INIT | Al reclamar |
| `done` + `claimed-by: —` | `/spec-os-implement` LOG | Al completar |
| `abandoned` | `/spec-os-abandon` | Al abandonar |

**spec.md status (frontmatter):**

| Estado | Responsable | Momento |
|--------|-------------|---------|
| `planned` | `/spec-os-design` | Al crear |
| `in-progress` | `/spec-os-implement` INIT | Solo cuando es la primera tarea del feature (spec.md status = planned) |
| `in-review` | `/spec-os-verify` PASS | Antes de crear el PR |
| `done` | `/spec-os-clean` | Durante archival |
| `abandoned` | `/spec-os-abandon` | Al abandonar |

**tasks.md status global (frontmatter):** se mueve en sync con spec.md — mismo dueño y momento.

**Tracker User Story:**

| Estado | Responsable | Momento |
|--------|-------------|---------|
| New | `/spec-os-plan` | Al crear en tracker |
| Active | `/spec-os-implement` INIT | Primera tarea del feature (ningún task done previo) |
| In Review | `/spec-os-verify` PASS | Al crear el PR |
| Done/Closed | `/spec-os-clean` | Durante archival (valida PR mergeado) |
| Cancelled | `/spec-os-abandon` | Explícitamente cada US hijo |

**Tracker Feature:**

| Estado | Responsable | Momento |
|--------|-------------|---------|
| Active | `/spec-os-brainstorm` | Al crear |
| Done/Closed | `/spec-os-clean` | Durante archival |
| Cancelled | `/spec-os-abandon` | Al abandonar |

**Tracker Bug:**

| Estado | Responsable | Momento |
|--------|-------------|---------|
| (fetched) | `/spec-os-bug` | Al triagear |
| Resolved/Closed | `/spec-os-verify` PASS | Cuando feature-id empieza con `B` |
