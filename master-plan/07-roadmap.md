# Spec-OS: Implementation Roadmap

---

## 1. Implementation Roadmap

### Phase 1 — Foundation (enables everything else)

1. Write `spec-os/config.yaml` complete schema + validation rules
2. Write tracker adapter pattern (the instruction block for every skill)
3. Create thin `CLAUDE.md` template
4. Write `/spec-os-init` skill (all 3 modes: Initialize, Adopt, Update)
5. Create `spec-os/` directory READMEs

**Deliverable:** Runnable `/spec-os-init` that creates complete spec-os structure including domain specs.

---

### Phase 2 — Standards Layer

1. Write `/spec-os-discover` skill
2. Write `/spec-os-inject` skill
3. Write `/spec-os-standard` skill
4. Create initial standard files (global, backend, frontend)
5. Populate `index.yml`

**Deliverable:** Standards layer operational. `/spec-os-inject` replaces CLAUDE.md bulk loading.

---

### Phase 3 — Spec Lifecycle Layer

1. Write `/spec-os-create` skill (origin.md, spec-delta.md, Update mode, domain guard against `_index.md`)
2. Write `/spec-os-plan` skill (context-level, ux-impact, claimed-by, Update mode)

**Deliverable:** Spec and plan evolution tracked and assisted. Strategic reasoning preserved.

---

### Phase 4 — Workflow

1. Write `/spec-os-implement` skill (3-tier loading, resume mode, RECONCILE step, orchestrates create/plan Update)
2. Write `/spec-os-sync` skill (lazy, per US, always last)
3. Write `/spec-os-verify` skill (verify-report, conditional doc)
4. Write `/spec-os-abandon` skill
5. Write `/spec-os-prune` skill
6. Write `/spec-os-doc` skill
7. Update all skills with tracker adapter pattern
8. Write `/spec-os-bug` skill (simple path creates minimal folder)

**Deliverable:** All workflow skills operational for spec-os.

---

### Phase 5 — Template Repository & Validation

1. Create spec-os template repository
2. Validate all skills in a real project
3. Write GETTING-STARTED.md
4. Write `/spec-os-brainstorm` personal skill (also in `~/.claude/skills/spec-os-brainstorm/`) — includes Feature resolution in tracker (Decision 19)
5. Write `/spec-os-explore` personal skill (`~/.claude/skills/spec-os-explore/`) — cross-repo initiative analysis, initiative file generation, optional Epic creation in ADO (Decision 20)

**Deliverable:** spec-os template repository ready for team adoption.

---

## 2. DevCanvas vs Spec-OS Comparison

| Aspect | DevCanvas | Spec-OS |
|--------|-----------|---------|
| Tracker | ADO only | ADO, GitHub, Linear, Jira via config.yaml |
| Context loading | 7 files fixed | 3 tiers, lazy, declared per task |
| Spec evolution | Invisible | spec-delta.md per session, tracked by /spec-os-create |
| Plan evolution | No mechanism | /spec-os-plan Update mode, assisted |
| knowledge-sync | After every task, ADO eager | After each US, lazy, always last |
| brainstorm-output | Deleted | Preserved as origin.md forever |
| Standards | In CLAUDE.md, stale | Separate standards/ with index.yml |
| CLAUDE.md | Fat | Thin: identity + pointers |
| Multi-tracker | Not supported | Native via config.yaml |
| Approval gates | Always explicit | Configurable (explicit by default in v1) |
| spec-verify report | Ephemeral | Persisted in verify-report.md |
| Abandoned features | No process | /spec-os-abandon skill |
| Standards evolution | No mechanism | /spec-os-standard skill |
| Standards discovery | No mechanism | /spec-os-discover skill |
| doc-update | Always | Conditional on ux-impact |
| knowledge-base health | Grows unbounded | /spec-os-prune skill |
| Version tracking | None | spec-os/version file (semver) |
| Domain behavior specs | No | spec-os/specs/{domain}/ |
| Session resumption | No defined mechanism | Resume mode in /spec-os-implement |
| Skill naming | Varies | Consistent /spec-os-* prefix |
| Parallel developers | Race conditions | claimed-by field + session-log auto-merge |
| Cross-repo initiative analysis | No mechanism | /spec-os-explore personal skill — initiative files + Epic in ADO |
| ADO hierarchy coverage | Feature level only | Epic (explore) → Feature (brainstorm) → US (plan) → Task (implement) |
