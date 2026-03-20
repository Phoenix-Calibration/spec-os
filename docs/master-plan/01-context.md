# Spec-OS: Context & Strategic Foundation

---

## 1. What Is Spec-OS

Spec-OS is a **universal, tracker-agnostic, AI-evolution-resilient Specification Driven Development framework** designed to be the definitive system for AI-assisted development across any tech stack, any project management tool, and any AI coding assistant.

**It is not a patch. It is not a wrapper. It is a new foundation.**

### The Team Context

- Small dev team using Claude Code as primary AI coding agent
- Projects span: .NET/Clean Architecture/CQRS, Odoo (Python), Next.js, Python services
- Work items tracked in: **Azure DevOps (ADO)** and **GitHub** (different repos use different trackers)
- Some repos in ADO, some in GitHub organization

### The Goal

A framework that is:
- **Perfect:** complete workflow from idea to production
- **Efficient:** minimal token waste, lazy context loading
- **Easy to use:** 3 entry points, everything else is automatic
- **Easy to maintain:** modular layers, each independently evolvable
- **Scalable with AI evolution:** tracker-agnostic, tool-agnostic, context-tier adaptable

---

## 2. Research Foundation: 4 Frameworks Analyzed

### 2.1 OpenSpec (Fission-AI)
**What it is:** Formal SDD framework. Specs as behavior contracts with delta tracking.

**Key concepts carried forward:**
- **Delta specs** (`ADDED/MODIFIED/REMOVED`) — the best mechanism for spec evolution in brownfield projects
- **`changes/` folder per feature** — self-contained with all artifacts
- **`specs/` as source of truth** — describes current system behavior by domain
- **Archive with history** — completed changes move to `archive/` with date prefix, full context preserved

**Not taken:** The CLI dependency, the rigid skill format, the single built-in schema

### 2.2 LIDR Academy (ai-specs repo)
**What it is:** Ticket-driven autonomous development framework. Custom workflow on top of standards.

**Key concepts carried forward:**
- **Plan-before-code is non-negotiable** — hard separation of planning agent vs execution skill
- **Feedback loop for evolving standards** — AI proposes rule changes, human approves explicitly
- **Sub-agents with role boundaries** — planning agent has read-only tools, execution skill has write tools

**Not taken:** The Jira-specific MCP dependency, the symlink complexity

### 2.3 Agent OS (Brian Casel / Builder Methods)
**What it is:** Standards management system. Discovers, indexes, and injects coding conventions.

**Key concepts carried forward:**
- **`standards/` as a separate layer** from CLAUDE.md (standards are not workflow rules)
- **`index.yml` for smart matching** — maps keywords/domains to relevant standard files, avoiding bulk loading
- **`/discover-standards`** — scans codebase, extracts tribal knowledge, proposes standards files
- **`/inject-standards`** — loads only the relevant standards for the current task
- **Standards vs Skills distinction** — declarative (what) vs procedural (how)

**Not taken:** The two-tier global/local installation (everything stays in the project repo)

### 2.4 DevCanvas (Primary Base)
**What it is:** The most complete of the 4. Full pipeline: idea → tracker → spec → plan → implement → verify → docs → memory.

**What DevCanvas does that no other framework does:**
- Tracker as single source of truth with zero local duplication
- `session-log.md` as agent memory across sessions
- `knowledge-base.md` for institutional learning
- One task = one session = one atomic commit discipline
- 3 entry points only (brainstorm, bug-analyze, project-init)
- Story Points sizing rules with explicit split/merge criteria
- `spec-verify` with full PASS/FAIL cycle and correction loop
- Bug routing: simple vs complex paths
- Cross-repo coordination via tracker
- Maintenance feature concept (cadence-based)

**DevCanvas gaps fixed in spec-os:**
1. ADO hardcoded in every skill — not tracker-agnostic
2. Session startup loads 7 files unconditionally — no lazy loading
3. `knowledge-sync` queries ADO after every task (eager) — should be lazy
4. `spec.md` evolution is invisible — no delta tracking
5. `brainstorm-output.md` deleted after `spec-create` — strategic reasoning lost
6. `CLAUDE.md` too fat — mixes identity, conventions, rules, and skills list
7. No `standards/` layer — conventions buried in CLAUDE.md, get stale
8. No formal mechanism to evolve CLAUDE.md / standards
9. `doc-update` invoked always, even for pure-backend tasks with no UX change
10. `knowledge-sync` has no pruning — grows unbounded
11. No `blocked` task status
12. No `spec-abandon` flow
13. No spec evolution tracking when spec.md changes mid-feature
14. No PR template specification
15. `spec-verify` quality report is ephemeral (chat only, not persisted)
16. No version field — Update mode detection is fragile
17. Parallel developers on same feature create race conditions on tasks.md/session-log.md
18. ADO + GitHub dual tracker not addressed
19. `_registry.md` as flat file — doesn't scale beyond ~200 features
20. Cadence naming is org-specific, not universal

---

## 3. The Strategic Decision

### Why NOT surgical refactor of DevCanvas

DevCanvas has ADO baked into the DNA of every skill prompt. Making it tracker-agnostic requires touching every single skill. The 7-file startup is architectural, not patcheable. The monolithic skill chain makes independent evolution hard. The result would be "DevCanvas with patches" — still fragile against the next AI evolution wave.

### Why NOT from-scratch synthesis

Risk of losing DevCanvas's battle-tested workflow logic. The session memory model, the sizing rules, the PASS/FAIL cycle — these took real-world iteration to get right. "From scratch" frequently means rediscovering what already works, painfully.

### The Chosen Path: "Foundation First"

**Rebuild the foundation with modular architecture. Preserve all workflow logic from DevCanvas.**

- DevCanvas's workflow wisdom → preserved 100%
- Structural problems → fixed at the architectural level
- Missing capabilities → added as proper layers, not patches
- The result: a coherent framework, not a collection of fixes

**The guiding principle for evolution:** Each layer must be independently replaceable without touching the others.

---

## 4. What Is Preserved Exactly from DevCanvas

Zero changes to these:

1. Session model: one task = one session = one atomic commit
2. Three entry points (brainstorm, bug-analyze, project-init)
3. Story Points sizing rules and SP scale (1/2/3/5/8/13)
4. spec-verify PASS/FAIL cycle with correction loop
5. Bug routing: simple vs complex
6. Maintenance feature concept per cadence
7. project-init three modes (Initialize / Adopt / Update)
8. Cross-repo coordination via tracker
9. session-log.md concept (enriched)
10. knowledge-base.md concept (tagged)
11. Specialist subagents created by project-init via Skill Creator
12. spec-verify reading AC from tracker (no local duplication)
13. "Always notify before handoff" principle
14. "Always propose before applying" principle
15. "Max 3 clarifying questions at a time" principle
16. docs/design/ base files 00-09
17. docs/domains/ bounded context descriptions
18. docs/runbooks/ operational procedures
19. docs/manual/ auto-updated by doc-update
20. ADR format in docs/design/adr/
21. Security boundaries in CLAUDE.md
22. Environment check (Step 0) in every skill
23. brainstorm-analyze as personal skill in ~/.claude/skills/
24. US sizing rules: split when SP > 8 or two distinct outcomes
25. US merge rules: same role/goal + combined SP <= 5 + same files
