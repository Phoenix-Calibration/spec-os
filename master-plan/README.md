# Spec-OS: Master Plan
**Version:** 0.1-design | **Status:** Ready for implementation | **Updated:** 2026-03-19

---

## How to Use This Documentation

This folder contains the complete design context for spec-os. Each file covers a specific area. A new session should read in this order:

1. This README — orientation and current status
2. [01-context.md](01-context.md) — why spec-os exists, research base, strategic decision
3. [02-architecture.md](02-architecture.md) — 4 layers + complete file structure
4. [03-decisions.md](03-decisions.md) — all design decisions (1–18) + resolved gaps
5. [05-skills-chain.md](05-skills-chain.md) — skill inventory + full workflow chain
6. [08-workflows.md](08-workflows.md) — user-facing workflow patterns and UX contract
7. [07-roadmap.md](07-roadmap.md) — implementation phases

Read [04-templates.md](04-templates.md) and [06-skills-reference.md](06-skills-reference.md) as reference when implementing specific files or skills.

**All gaps in the original design are resolved. The plan is ready for Phase 1 implementation.**

---

## Document Index

| File | Contents | When to read |
|------|----------|--------------|
| [01-context.md](01-context.md) | What is spec-os, 4 frameworks analyzed, strategic decision, DevCanvas preservation list | Orientation — read once |
| [02-architecture.md](02-architecture.md) | 4-layer architecture, complete project file structure | Primary implementation reference |
| [03-decisions.md](03-decisions.md) | 18 design decisions with rationale, 8 resolved gaps | Before implementing any skill |
| [04-templates.md](04-templates.md) | File templates: config.yaml, index.yml, spec.md, tasks.md, session-log.md, spec-delta.md, origin.md, verify-report.md | Copy-paste reference |
| [05-skills-chain.md](05-skills-chain.md) | Tracker adapter pattern, 3-tier context loading, skills inventory, full skill chain | Workflow reference |
| [06-skills-reference.md](06-skills-reference.md) | Complete skill documentation: syntax, arguments, examples, tips | Day-to-day operational reference |
| [07-roadmap.md](07-roadmap.md) | 5-phase implementation roadmap, DevCanvas vs spec-os comparison | Planning reference |
| [08-workflows.md](08-workflows.md) | User-facing workflow guide: patterns, examples, decision tables, best practices | Before implementing any skill — defines the UX contract |

---

## Current Status

| Area | Status |
|------|--------|
| Design decisions | All resolved (18 decisions) |
| Gaps | All resolved (A–H) |
| Skills naming | `/spec-os-*` prefix, skills format |
| Implementation | Not started — Phase 1 pending |
| Skills reference doc | Structure defined, content pending |

---

## How to Start Implementation

Tell the new Claude Code session:

> "Lee `docs/master-plan/README.md` para orientarte, luego lee `docs/master-plan/03-decisions.md` y `docs/master-plan/05-skills-chain.md`.
> Todos los gaps están resueltos. Inicia con la Fase 1 del roadmap en `docs/master-plan/07-roadmap.md`."

---

## Framework Knowledge Base Locations

| Framework | Location | Key contribution to spec-os |
|-----------|----------|-----------------------------|
| OpenSpec | `Knowlede Base/openspec/` | Delta specs, changes/ structure, archive pattern |
| LIDR Academy | Analyzed via GitHub | Feedback loop, plan-only agents, role boundaries |
| Agent OS | `Knowlede Base/agent os/` | standards/ layer, index.yml, discover/inject pattern |
| DevCanvas | `Knowlede Base/devcanva/` | Full workflow, session memory, quality gate, sizing rules |
