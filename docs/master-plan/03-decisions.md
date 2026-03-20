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
  - knowledge-base.md filtered by domain + stack tags
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

**Problem:** `doc-update` always runs even for pure-backend tasks with no UX change
**Solution:** `/spec-os-plan` marks tasks with `ux-impact: true | false`. `/spec-os-verify` only invokes `/spec-os-doc` if at least one task in the US has `ux-impact: true`.

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
- `/spec-os-brainstorm` → `/spec-os-create`
- `/spec-os-bug` → `/spec-os-implement` (simple path)
- `/spec-os-create` → `/spec-os-plan`
- `/spec-os-plan` → `/spec-os-implement` T01
- `/spec-os-implement` → `/spec-os-verify` (on US complete)
- `/spec-os-verify` → `/spec-os-doc` (on PASS + ux-impact)
- `/spec-os-verify` → `/spec-os-implement` (on FAIL)
- `/spec-os-doc` → `/spec-os-sync` (always last, always explicit)

`/spec-os-create` Update mode and `/spec-os-plan` Update mode (invoked during RECONCILE) are also explicit — they propose changes and wait for dev approval before writing.

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

**Problem:** `spec-os/specs/{domain}/spec.md` files need to exist before `/spec-os-create` runs, but had no defined creation mechanism.
**Solution:** `/spec-os-init` is the sole owner of domain spec creation across all three modes.

- **Initialize:** dev declares domains → creates `_index.md` + stubs per domain
- **Adopt:** scans codebase (namespaces, modules, bounded contexts) → proposes domain list → dev confirms → creates `_index.md` + stubs seeded from existing code
- **Update:** adds new domains post-adoption

`/spec-os-create` has a hard guard: validates domain exists in `_index.md`. If not → stops with clear instruction to run `/spec-os-init Update`.

---

### Decision 17: knowledge-base Tag Schema with _index.md Validation

**Problem:** knowledge-base.md needs tags for smart filtering, but free-form domain tags risk inconsistency.
**Solution:** Fixed global schema with `domain` tag validated against `spec-os/specs/_index.md`.

```
stack:  [dotnet, odoo, nextjs, python, general]
domain: validated against spec-os/specs/_index.md
layer:  [domain, application, infrastructure, presentation, global]
type:   [pattern, gotcha, anti-pattern, performance, security]
```

`/spec-os-sync` validates domain tag exists in `_index.md` before writing. No separate configuration needed — the domain registry already exists.

---

### Decision 18: spec-evolve Eliminated — spec-create and spec-plan Own Their Artifacts

**Problem:** spec-evolve was a middleman skill with no clear ownership — it updated spec.md (owned by spec-create) and affected tasks.md (owned by spec-plan).
**Solution:** Each skill owns its artifact across its full lifecycle, including updates.

- **`/spec-os-create`** owns spec.md + spec-delta.md for the entire feature lifecycle (create + update)
- **`/spec-os-plan`** owns tasks.md for the entire feature lifecycle (create + update)
- **`/spec-os-implement`** orchestrates via a RECONCILE step after each EXECUTE:
  1. `git diff` check on spec.md — if changed by dev → invokes `/spec-os-create` Update mode
  2. Reasoning check — "Did implementation reveal anything undocumented in spec.md?" → invokes `/spec-os-create` Update mode if yes
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
