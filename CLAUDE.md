# CLAUDE.md — spec-os

## Identity

Project: spec-os
Description: AI-assisted development framework combining standards management, spec tracking, and workflow skills for Claude Code
Stack: markdown / framework (stack-agnostic)
Tracker: N/A — this is the framework source repo
Standards: docs/ (framework documentation)
Framework: spec-os v1.0.0 (this repo IS the framework)

## Agent behavior (immutable rules)

- Think before responding — analyze the full request first
- Never fabricate — if uncertain, say so and ask
- Max 3 clarifying questions at a time, one per topic
- Always propose before applying — wait for approval
- Document gaps as Suggested Improvements, never self-apply
- When modifying SKILL.md files — read the corresponding design decisions in master-plan/ first

## Security boundaries

- Never write credentials, tokens, or secrets to any file
- Never execute destructive git operations without explicit approval

## This repo's structure

- `docs/` — user-facing framework documentation (concepts, getting started, skills, workflows)
- `master-plan/` — internal design documentation (source of truth for all decisions)
- `.claude/skills/` — skill source files (SKILL.md per skill)
- `Knowledge Base/` — reference frameworks analyzed during design (read-only)

## Development workflow

This repo uses standard git workflow — no spec-os tracking for self-development.
Design decisions are finalized in master-plan/03-decisions.md.

## Entry points

- Phase 1 (Foundation): /spec-os-init skill
- Phase 2 (Standards layer): /spec-os-discover, /spec-os-inject, /spec-os-standard
- Phase 3 (Spec lifecycle): /spec-os-create, /spec-os-plan
- Phase 4 (Workflow): /spec-os-implement, /spec-os-verify, /spec-os-sync, /spec-os-doc, /spec-os-bug, /spec-os-abandon, /spec-os-prune
- Phase 5 (Personal skills): /spec-os-brainstorm, /spec-os-explore, /spec-os-product
