# spec-os Improvements Backlog

Suggested improvements extracted from audit entries across projects.
Use `prompts/import-audit.md` to add entries from a new audit log.

**Source format:** `YYYY-MM-DD HH:MM — mode`
**Status values:** `pending` | `in-progress` | `implemented` | `wont-fix`

---

| ID | Source | Target | Severity | Description | Status |
|---|---|---|---|---|---|
| IMP-001 | 2026-04-23 00:00 — context | skill: spec-os-init | medium | Enforce sequential Q&A: present one configuration question per turn, never batch | implemented |
| IMP-002 | 2026-04-23 00:00 — context | skill: spec-os-init | medium | Detect legacy workflow artifacts during ADOPT mode and exclude them from new-workflow outputs | implemented |
| IMP-003 | 2026-04-23 00:00 — context | skill: spec-os-init | low | Proactively offer best-practice research for any file the skill proposes to replace or create | implemented |
| IMP-004 | 2026-04-23 00:00 — context | agent: explore (spec-os-init) | low | Document limitation: automated domain discovery cannot surface business-context relationships; add explicit developer review prompt | implemented |
| IMP-005 | 2026-04-23 00:00 — context | skill: spec-os-product | high | Add rate-limit handling for market-researcher: deliver partial results, mark incomplete sections, offer resume option | implemented |
| IMP-006 | 2026-04-23 00:00 — context | agent: product-owner (spec-os-product) | high | Add integration boundary section to prompt: scope what the product owns vs external systems before generating deliverables | implemented |
| IMP-007 | 2026-04-23 00:00 — context | agent: product-owner (spec-os-product) | medium | Require Explore codebase findings as explicit input; list KPI artifacts as candidate north-star signals | implemented |
| IMP-008 | 2026-04-23 00:00 — context | agent: product-owner + market-researcher (spec-os-product) | medium | Systematize self-review as mandatory last step: structured gap-check after each major deliverable | implemented |
| IMP-009 | 2026-04-23 00:00 — context | skill: spec-os-product | medium | Add session-progress tracker: show complete/remaining deliverables each turn; offer continuation prompt on incomplete sessions | implemented |
| IMP-010 | 2026-04-29 00:00 — context | skill: spec-os-discover | high | Make external source research mandatory before proposing any standard; report confidence level with draft | implemented |
| IMP-011 | 2026-04-29 00:00 — context | doc: references/templates-standards.md | high | Add three-layer structure to template: (1) Current state (2) Best practice (3) Migration path with steps, effort, and risk | implemented |
| IMP-012 | 2026-04-29 00:00 — context | skill: spec-os-tracker | medium | Expand UPDATE mode: when adapter has empty/placeholder fields, offer to populate via live MCP fetch | implemented |
| IMP-013 | 2026-04-29 00:00 — context | doc: ado.md template | low | Add dedicated story-point-schema field with structured key-value format | implemented |
| IMP-014 | 2026-05-07 00:00 — context | skill: spec-os-discover | high | Mandatory WebFetch of at least one external source per standard; summarizing from training data is a protocol violation | implemented |
| IMP-015 | 2026-05-07 00:00 — context | skill: spec-os-discover | medium | Update index.yml immediately after writing each standard — not at end of session or start of next | implemented |
| IMP-016 | 2026-05-07 00:00 — context | skill: spec-os-discover | medium | Formalize confidence gate (1–5) as mandatory pre-proposal step: list gaps, read real files for any unconfirmed gap | implemented |
| IMP-017 | 2026-05-07 00:00 — context | doc: references/templates-standards.md | medium | Codify three-layer structure as mandatory schema in template — not just verbal convention from prior sessions | implemented |
| IMP-018 | 2026-05-07 00:00 — context | framework | low | Establish minimum external source coverage criterion: 2 URLs per standard, at least one official vendor doc | implemented |
