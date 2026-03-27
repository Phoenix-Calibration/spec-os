# Spec-OS: Architecture & File Structure

---

## 1. Core Architecture: 4 Independent Layers

```
+-------------------------------------------------------------+
|                    SPEC-OS                                  |
|                                                             |
|  LAYER 1: Standards    LAYER 2: Specs    LAYER 3: Workflow  |
|  "How we build"        "What we build"   "How we execute"   |
|  (Agent OS pattern)    (OpenSpec pat.)   (DevCanvas DNA)    |
|       |                     |                  |            |
|       +---------------------+------------------+            |
|                             |                               |
|                    LAYER 4: Tracker Adapter                  |
|                    "With whom we coordinate"                 |
|                    (ADO | GitHub | Linear | Jira)            |
+-------------------------------------------------------------+
```

### Layer 1: Standards — How We Build

Extracted from CLAUDE.md into a dedicated, indexed, discoverable layer.

- `spec-os/standards/index.yml` — keyword-to-file mapping for smart injection
- `spec-os/standards/{category}/{standard}.md` — concise, declarative rules
- Skills: `/spec-os-discover`, `/spec-os-inject`, `/spec-os-standard`
- CLAUDE.md becomes thin — only project identity and pointers

### Layer 2: Specs — What We Build

Combines OpenSpec's delta tracking with DevCanvas's technical depth.

- `spec-os/specs/{domain}/spec.md` — source of truth for current system behavior
- `spec-os/changes/{feature-folder}/` — in-progress work with full artifact set
- `spec-delta.md` — formal tracking of spec evolution within a feature
- `origin.md` — preserved brainstorm reasoning (never deleted)

### Layer 3: Workflow & Memory — How We Execute

DevCanvas's skill chain, preserved and optimized.

- Skill chain: `/spec-os-brainstorm` → `/spec-os-design` → `/spec-os-plan` → `/spec-os-implement` → `/spec-os-verify` → `/spec-os-doc`
- Same session model: one task = one session = one atomic commit
- Lazy context loading with 3 tiers (replaces fixed 7-file startup)
- `/spec-os-sync` lazy (per US completion, not per task)
- `session-log.md` enriched with spec change references and pending lessons

### Layer 4: Tracker Adapter — With Whom We Coordinate

New layer. Makes every skill tracker-agnostic.

- `spec-os/config.yaml` declares tracker type per repo
- Skills call abstract operations (`tracker.get-feature`, `tracker.create-us`, etc.)
- Adapter resolves which MCP to call based on config
- Supports: ADO, GitHub, and per-repo overrides

---

## 2. Complete File Structure

```
[project-root]/
|
+-- spec-os/                           <- FRAMEWORK LAYER
|   +-- config.yaml                    <- tracker, workflow, project metadata
|   +-- version                        <- spec-os semver string (e.g. 1.0.0)
|   +-- GETTING-STARTED.md             <- how to use spec-os in this project
|   |
|   |
|   +-- standards/                     <- LAYER 1: How we build
|   |   +-- index.yml                  <- keyword -> file mapping
|   |   +-- global/
|   |   |   +-- naming.md
|   |   |   +-- commits.md
|   |   |   +-- security.md
|   |   |   +-- pr-template.md
|   |   +-- backend/
|   |   |   +-- architecture.md
|   |   |   +-- patterns.md
|   |   |   +-- testing.md
|   |   |   +-- error-handling.md
|   |   |   +-- {stack}.md             <- stack-specific: dotnet.md | python.md | odoo.md
|   |   +-- frontend/
|   |       +-- components.md
|   |       +-- state.md
|   |       +-- testing.md
|   |       +-- {stack}.md             <- stack-specific: nextjs.md | react.md
|   |
|   +-- specs/                         <- LAYER 2: Source of truth
|   |   +-- _index.md                  <- domains list + relationships (authoritative registry)
|   |   +-- knowledge-base.md          <- institutional lessons (tagged, cross-domain)
|   |   +-- {domain}/
|   |       +-- spec.md
|   |
|   +-- changes/                       <- LAYER 3: Work in progress
|       +-- {feature-folder}/          <- F{ID}-{cadence}-{name}/ or B{ID}-{name}/ for bugs
|       |   +-- origin.md              <- preserved brainstorm (never deleted, never modified)
|       |   +-- spec.md                <- technical spec (owned by /spec-os-design)
|       |   +-- spec-delta.md          <- formal spec evolution log (owned by /spec-os-design)
|       |   +-- tasks.md               <- atomic execution plan (owned by /spec-os-plan)
|       |   +-- session-log.md         <- agent memory across sessions
|       |   +-- verify-report.md       <- quality gate reports (written by /spec-os-verify)
|
+-- spec-os/archive/                       <- archived features (moved here by /spec-os-clean)
|   +-- {YYYY-MM-DD}-{feature}/
|
+-- docs/                              <- PRODUCT DOCUMENTATION (stable, rarely changes)
|   +-- mission.md                     <- product purpose, audience, problem solved
|   +-- roadmap.md                     <- strategic north star, potential future features
|   +-- design/
|   |   +-- 00-overview.md through 09-design-system.md
|   |   +-- adr/
|   +-- runbooks/
|   +-- manual/
|
+-- CLAUDE.md                          <- thin: identity + pointers only (project root)
|
+-- .claude/
    +-- agents/                        <- native Claude Code subagents (executors, not entry points)
    |   +-- backend-dev.md             <- YAML frontmatter + system prompt (tool-restricted)
    |   +-- frontend-dev.md            <- YAML frontmatter + system prompt (tool-restricted)
    +-- shared/                        <- shared resources read dynamically by skills at runtime
    |   +-- tracker-adapter.md         <- single source of truth for tracker MCP mappings
    +-- skills/
        +-- spec-os-product/           <- /spec-os-product (also ~/.claude/skills/)
        |   +-- SKILL.md
        +-- spec-os-brainstorm/        <- /spec-os-brainstorm (also ~/.claude/skills/)
        |   +-- SKILL.md
        +-- spec-os-init/              <- /spec-os-init
        |   +-- SKILL.md
        +-- spec-os-discover/          <- /spec-os-discover  NEW
        |   +-- SKILL.md
        +-- spec-os-inject/            <- /spec-os-inject    NEW
        |   +-- SKILL.md
        +-- spec-os-standard/          <- /spec-os-standard  NEW
        |   +-- SKILL.md
        +-- spec-os-design/            <- /spec-os-design    owns spec.md + spec-delta.md
        |   +-- SKILL.md
        +-- spec-os-plan/              <- /spec-os-plan      owns tasks.md
        |   +-- SKILL.md
        +-- spec-os-implement/         <- /spec-os-implement
        |   +-- SKILL.md
        +-- spec-os-verify/            <- /spec-os-verify
        |   +-- SKILL.md
        +-- spec-os-abandon/           <- /spec-os-abandon   NEW
        |   +-- SKILL.md
        +-- spec-os-bug/               <- /spec-os-bug
        |   +-- SKILL.md
        +-- spec-os-doc/               <- /spec-os-doc
        |   +-- SKILL.md
        +-- spec-os-sync/              <- /spec-os-sync
        |   +-- SKILL.md
        +-- spec-os-clean/             <- /spec-os-clean     (renamed from spec-os-prune)
            +-- SKILL.md
```
