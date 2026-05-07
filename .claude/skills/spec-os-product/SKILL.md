---
name: spec-os-product
description: Create or update the product documentation layer (docs/). Use this skill
  when the developer runs /spec-os-product, wants to create mission.md and roadmap.md
  from scratch, wants to generate docs from an existing codebase, or needs to update
  existing product documentation. Runs before /spec-os-init — gives the framework
  product context at setup time. Also use when the developer asks to document their
  product, write a mission statement, define scope or roadmap, set up the docs/ folder,
  create or update design documentation, add an ADR, or describe what the product does
  and for whom — even if they don't mention /spec-os-product explicitly.
---

# /spec-os-product

## Goal

Own the `docs/` layer entirely. Orchestrate the creation and update of product
documentation by delegating to specialized agents — `market-researcher`, `product-owner`,
`architect`, `security-engineer`, `ui-ux-designer` — and writing the approved outputs.
Runs before `/spec-os-init` to give the framework product context and the team a stable
reference for what the product is and why it exists.

**Core principle: every product document must support MEASURABLE AND ACHIEVABLE RESULTS.**
mission.md defines success metrics. roadmap.md defines expected outcomes per initiative.
No initiative, capability, or goal is documented without a concrete, measurable outcome.

## Syntax

```
/spec-os-product [mode]
```

| Argument | Required | Values |
|----------|----------|--------|
| `mode` | No | `initialize` \| `generate` \| `update` — auto-detected if omitted |

---

## Step 1 — Detect mode

If `mode` argument provided, use it directly. Otherwise auto-detect:

1. `docs/mission.md` exists → **UPDATE mode**
2. Project has existing source files (non-empty repo, no `docs/mission.md`) → **GENERATE mode**
3. Otherwise → **INITIALIZE mode**

**Check for existing standards:**
If `spec-os/standards/` exists, note it — relevant standards will be passed to agents
as context in subsequent steps.

Report detected mode and reason. Proceed.

---

## INITIALIZE mode

Use when: new project with no existing codebase.

### I.0 — Market research (always run)

Invoke `.claude/agents/market-researcher` via Agent tool with:
- Any context already available: product name, idea description, files, URLs
  provided by the developer in this session
- Instruction: research the market, users, competitors, and value gaps for this
  project. Produce a complete draft of `docs/market-research.md` including
  the Measurable outcomes section with KPIs, baselines, and realistic targets.
  **If web search quota is exhausted mid-research:** do NOT stop. Deliver all results
  gathered so far. Clearly mark each incomplete section with
  `> ⚠ INCOMPLETE — web search quota exhausted. Fill manually or re-run.`
  Then return the partial output with a note: "Quota exhausted — resume in a new
  session or continue with partial research."

Present output to developer:

```
─────────────────────────────────────────────────
market-researcher — docs/market-research.md
─────────────────────────────────────────────────
{market-researcher proposed content}
─────────────────────────────────────────────────
Accept? [y / edit / skip]
  skip → proceeds without market research context
─────────────────────────────────────────────────
```

If accepted or edited: write `docs/market-research.md` immediately.
Pass approved content to all subsequent agent invocations as market context.

### I.1 — Conversational discovery

Gather product information in a single structured conversation:

```
─────────────────────────────────────────────────
/spec-os-product — Initialize
─────────────────────────────────────────────────
Let's define your product. Answer as much or as little as you know right now.

Product name:
> _

What problem does it solve? (for whom, in what context)
> _

Who are the primary users?
> _

What does success look like for users?
> _

What are the main capabilities you're building? (list them)
> _

What are you explicitly NOT building? (out of scope)
> _

Any known technical or business constraints?
> _
─────────────────────────────────────────────────
```

Wait for developer answers. Incomplete answers are fine — mark gaps as TBD.

### I.2 — Propose docs structure

Present what will be created and which agent owns each section:

```
─────────────────────────────────────────────────
Proposed docs/ structure:
─────────────────────────────────────────────────
docs/
  mission.md              ← product-owner
  roadmap.md              ← product-owner
  design/
    README.md             ← skill
    00-overview.md        ← architect
    01-stack.md           ← architect
    02-security.md        ← security-engineer
    03-performance.md     ← stub
    04-metrics.md         ← stub
    05-data-model.md      ← architect
    06-integrations.md    ← stub
    07-error-handling.md  ← stub
    08-glossary.md        ← stub
    09-design-system.md   ← ui-ux-designer
    adr/                  ← empty
  runbooks/               ← empty
  manual/                 ← empty

Create? [y / n]
─────────────────────────────────────────────────
```

### I.3 — Invoke product-owner

Read reference templates before invoking:
- `references/template-mission.md`
- `references/template-roadmap.md`

If `spec-os/standards/` exists: read `spec-os/standards/index.yml`, load any standards
relevant to product documentation or global conventions.

**Integration boundary check (run before invoking product-owner):**
Check product answers from I.1 and any available context for mentions of ERP systems,
third-party platforms, or external integrations (Odoo, SAP, Salesforce, QuickBooks, etc.).
If found, ask the developer:
```
Integration detected: {system name(s)}.
Before generating mission/roadmap — what does {product} own vs what does {system} own?
List the boundary explicitly (one bullet per external system).
> _
```
Wait for response. Include the boundary statement in the product-owner invocation context.
If no external systems detected: skip this check.

Invoke `.claude/agents/product-owner` via Agent tool with:
- Product answers from I.1
- Content of `references/template-mission.md` and `references/template-roadmap.md`
- Standards (if available)
- Integration boundary statement (if collected above)
- Instruction: draft `docs/mission.md` and `docs/roadmap.md` based on the product answers
  and the template structures. Propose — do not write files.
  **Mandatory self-review before returning output:** check for (1) competitors missing or
  conflated, (2) regulatory bodies correctly identified, (3) integration boundaries
  correctly scoped, (4) KPIs present with baselines and targets, (5) market-specific
  context present (not generic). Revise output based on findings before returning.

Present output to developer:

```
─────────────────────────────────────────────────
product-owner — docs/mission.md + docs/roadmap.md
─────────────────────────────────────────────────
{product-owner proposed content}
─────────────────────────────────────────────────
Accept? [y / edit / skip]
  skip → creates minimal stubs instead
─────────────────────────────────────────────────
```

On `edit`: revise with developer feedback, re-present. On `skip`: note as stub.

### I.4 — Invoke architect

Read reference template before invoking:
- `references/template-design.md`

If `spec-os/standards/` exists: load architecture-relevant standards
(keywords: architecture, patterns, backend).

Invoke `.claude/agents/architect` via Agent tool with:
- Approved mission.md content (from I.3)
- Product answers from I.1 (constraints, capabilities)
- Content of `references/template-design.md`
- Standards (if available)
- Instruction: propose content for `docs/design/00-overview.md` (architecture vision,
  system description, future technical direction), `docs/design/01-stack.md` (recommended
  technologies, frameworks, versions), and `docs/design/05-data-model.md` (core entities
  and relationships). Propose — do not write files.

Present output section by section — gate each doc independently:

```
─────────────────────────────────────────────────
architect — docs/design/00-overview.md
─────────────────────────────────────────────────
{proposed content}
─────────────────────────────────────────────────
Accept? [y / edit / skip]
─────────────────────────────────────────────────
```

Repeat for `01-stack.md` and `05-data-model.md`.

### I.5 — Invoke security-engineer

If `spec-os/standards/` exists: load security-relevant standards (keywords: security, auth,
credentials, secrets).

Invoke `.claude/agents/security-engineer` via Agent tool in Modo diseño with:
- Approved mission.md content
- Approved 01-stack.md content (stack and technologies)
- Standards (if available)
- Instruction: propose content for `docs/design/02-security.md` — threat model,
  auth strategy, encryption, secrets management, security headers. Propose — do not write files.

Present output to developer:

```
─────────────────────────────────────────────────
security-engineer — docs/design/02-security.md
─────────────────────────────────────────────────
{proposed content}
─────────────────────────────────────────────────
Accept? [y / edit / skip]
─────────────────────────────────────────────────
```

### I.6 — Invoke ui-ux-designer

If `spec-os/standards/` exists: load frontend-relevant standards (keywords: component,
state, frontend).

Invoke `.claude/agents/ui-ux-designer` via Agent tool with:
- Approved mission.md content (product type, target users)
- Approved 01-stack.md content (frontend stack)
- Standards (if available)
- Instruction: propose content for `docs/design/09-design-system.md` — component
  philosophy, palette approach, typography, spacing system, accessibility baseline.
  Propose — do not write files.

Present output to developer:

```
─────────────────────────────────────────────────
ui-ux-designer — docs/design/09-design-system.md
─────────────────────────────────────────────────
{proposed content}
─────────────────────────────────────────────────
Accept? [y / edit / skip]
─────────────────────────────────────────────────
```

### I.7 — Write all approved content

Read all remaining reference templates:
- `references/template-design.md` — for stub sections and README

Create files in this order:

1. `docs/mission.md` — approved product-owner content (or stub)
2. `docs/roadmap.md` — approved product-owner content (or stub)
3. `docs/design/README.md` — index from `references/template-design.md`
4. `docs/design/00-overview.md` — approved architect content (or stub)
5. `docs/design/01-stack.md` — approved architect content (or stub)
6. `docs/design/02-security.md` — approved security-engineer content (or stub)
7. `docs/design/03-performance.md` — stub
8. `docs/design/04-metrics.md` — stub
9. `docs/design/05-data-model.md` — approved architect content (or stub)
10. `docs/design/06-integrations.md` — stub
11. `docs/design/07-error-handling.md` — stub
12. `docs/design/08-glossary.md` — stub
13. `docs/design/09-design-system.md` — approved ui-ux-designer content (or stub)
14. `docs/design/adr/` — `.gitkeep`
15. `docs/runbooks/README.md` — from `references/template-runbook.md`
16. `docs/manual/` — `.gitkeep`

---

## GENERATE mode

Use when: existing codebase with no `docs/mission.md`. Derive documentation from
what's already built.

### G.0 — Market research (always run)

Invoke `.claude/agents/market-researcher` via Agent tool with:
- Any context available: README.md content, existing docs, URLs or files provided
  by the developer in this session
- Instruction: research the market, users, competitors, and value gaps for this
  project based on the codebase signals. Produce a complete draft of
  `docs/market-research.md` including the Measurable outcomes section with KPIs,
  baselines, and realistic targets.
  **If web search quota is exhausted mid-research:** do NOT stop. Deliver all results
  gathered so far. Clearly mark each incomplete section with
  `> ⚠ INCOMPLETE — web search quota exhausted. Fill manually or re-run.`
  Then return the partial output with a note: "Quota exhausted — resume in a new
  session or continue with partial research."

Gate with developer — same format as I.0.
If accepted or edited: write `docs/market-research.md` immediately.
Pass approved content to all subsequent agent invocations as market context.

### G.1 — Scan codebase for product signals

Read in parallel:
- `README.md` (root)
- Any existing files in `docs/`
- `package.json`, `.csproj`, `pyproject.toml`, or equivalent
- Top-level module/namespace names

Assess signal quality:
- If `README.md` is missing or fewer than 5 meaningful lines → stop and report:
  ```
  ─────────────────────────────────────────────────
  Not enough product signals to generate documentation.

  README.md: {missing | too sparse}

  Options:
    a) Add a README.md with a product description, then re-run
    b) Switch to INITIALIZE mode — answer questions interactively
    c) Let me help you write README.md — I'll collect product info
       and create both README.md and docs/ in one pass
  ─────────────────────────────────────────────────
  ```
  Wait for developer choice. If `c)`: run INITIALIZE mode from I.1, then also write
  `README.md` at root before creating docs/.

### G.2 — Deep technical analysis (Explore subagent)

Only run if G.1 signals are sufficient. Delegate read-only technical analysis:

```
Analyze this codebase and return:
1. Main technology stack (languages, frameworks, versions)
2. Top-level domains or bounded contexts (modules, folder structure)
3. Key external integrations (APIs, databases, services)
4. Architectural pattern (monolith, layered, event-driven, etc.)
5. Core data entities and their relationships
6. Notable design patterns used

Do not modify any files. Return findings only.
```

### G.3 — Invoke product-owner

Read reference templates (`template-mission.md`, `template-roadmap.md`).

**Integration boundary check (run before invoking product-owner):**
Scan README.md content and Explore subagent findings for mentions of ERP systems,
third-party platforms, or external integrations (Odoo, SAP, Salesforce, QuickBooks, etc.).
If found, ask the developer:
```
Integration detected: {system name(s)}.
Before generating mission/roadmap — what does {product} own vs what does {system} own?
List the boundary explicitly (one bullet per external system).
> _
```
Wait for response. Include the boundary statement in the product-owner invocation context.
If no external systems detected: skip this check.

**KPI artifact pass-through:** from Explore subagent findings, extract any named KPI
artifacts (stored procedures with performance semantics, dashboard widgets, named metrics,
report definitions). Include these explicitly in the product-owner context as:
"Codebase KPI signals: {list}. Evaluate each as a candidate north-star metric."

Invoke `.claude/agents/product-owner` via Agent tool with:
- README.md content and any existing docs
- Explore subagent findings (domain signals, product purpose inferred from codebase)
- Templates content
- Integration boundary statement (if collected above)
- KPI artifact list (if found)
- Instruction: derive and propose `docs/mission.md` and `docs/roadmap.md` from the
  codebase signals. Mark what is inferred vs confirmed. Propose — do not write files.
  **Mandatory self-review before returning output:** check for (1) competitors missing or
  conflated, (2) regulatory bodies correctly identified, (3) integration boundaries
  correctly scoped, (4) KPIs present with baselines and targets, (5) market-specific
  context present (not generic). Revise output based on findings before returning.

Gate with developer — same format as I.3.

### G.4 — Invoke architect

If `spec-os/standards/` exists: read `spec-os/standards/index.yml`, load architecture-
relevant standards files, include as `standards` context.

Invoke `.claude/agents/architect` via Agent tool with:
- Approved mission.md content
- Explore subagent full findings
- Standards (if available)
- Instruction: propose `docs/design/00-overview.md`, `docs/design/01-stack.md`, and
  `docs/design/05-data-model.md` derived from the codebase analysis. Flag gaps where
  inferences are uncertain. Propose — do not write files.

Gate per doc — same format as I.4.

### G.5 — Invoke security-engineer

If `spec-os/standards/` exists: load security-relevant standards.

Invoke `.claude/agents/security-engineer` via Agent tool in Modo auditoría with:
- Approved 01-stack.md content
- Approved 00-overview.md content
- Standards (if available)
- Instruction: audit existing codebase for security posture and propose
  `docs/design/02-security.md`. Include findings and recommended improvements.
  Propose — do not write files.

Gate — same format as I.5.

### G.6 — Invoke ui-ux-designer

If `spec-os/standards/` exists: load frontend-relevant standards.

Invoke `.claude/agents/ui-ux-designer` via Agent tool with:
- Approved mission.md content
- Approved 01-stack.md content
- Existing UI patterns found in the codebase (from Explore subagent)
- Standards (if available)
- Instruction: derive and propose `docs/design/09-design-system.md` from existing
  UI code and patterns. Propose — do not write files.

Gate — same format as I.6.

### G.7 — Write all approved content

Follow same creation order as INITIALIZE mode (I.7).
Mark fields that could not be inferred as `TBD — fill in manually`.

---

## UPDATE mode

Use when: `docs/mission.md` exists and needs updating.

### U.1 — Read current state

Read all existing files in `docs/`. If `spec-os/` exists, also read:
- `spec-os/specs/_index.md` — registered domains
- `spec-os/standards/` — confirm real stack in use

### U.2 — Identify what needs updating

```
─────────────────────────────────────────────────
/spec-os-product — Update
─────────────────────────────────────────────────
Current docs found:
  docs/mission.md      (last updated: {date})
  docs/roadmap.md      (last updated: {date})
  docs/design/{files}

What needs updating?
  a) Mission or roadmap → product-owner
  b) Architecture or stack → architect
  c) Security strategy → security-engineer
  d) Design system → ui-ux-designer
  e) Other design doc → skill writes directly
  f) Add new ADR → skill writes from template
  g) Refresh market research → market-researcher
  h) Full refresh → invoke all agents
─────────────────────────────────────────────────
```

### U.3 — Invoke relevant agent

Based on developer selection, read the relevant standard file if `spec-os/standards/`
exists, then invoke the mapped agent:

| Selection | Agent | Doc(s) |
|---|---|---|
| a) Mission / Roadmap | `product-owner` | mission.md, roadmap.md |
| b) Architecture / Stack | `architect` | 00-overview, 01-stack, 05-data-model |
| c) Security | `security-engineer` | 02-security.md |
| d) Design system | `ui-ux-designer` | 09-design-system.md |
| e) Other doc | skill writes directly | specific file |
| f) New ADR | skill writes from `references/template-adr.md` | adr/{slug}.md |
| g) Full refresh | all agents | all docs |

Pass to each agent:
- Current content of the doc(s) being updated
- Relevant standards (if available)
- Instruction: propose targeted updates — not a full rewrite unless content is
  significantly stale. Propose — do not write files.

### U.4 — Gate and write

Present agent proposals as targeted diffs:

```
─────────────────────────────────────────────────
Proposed update: docs/design/{file} — {section}
─────────────────────────────────────────────────
BEFORE:
{current content}

AFTER:
{proposed content}

Apply? [y / n / edit]
─────────────────────────────────────────────────
```

Wait for approval per section. Update `Last updated` date in each modified file.

---

## Progress tracking (all modes)

After each approved deliverable is written, display a progress summary before proceeding:

```
Progress ({mode} mode):
  ✓ {completed deliverable}
  ✓ {completed deliverable}
  ○ {next deliverable}  ← next
  ○ {remaining...}

Continue with next deliverable? [y / pause]
```

If the developer responds `pause`, or if the session is approaching context limits, offer:
```
Remaining deliverables: {list}
To resume: run /spec-os-product {mode} — it will detect what is complete
and continue from {next deliverable}.
```

---

## Step 2 (all modes) — Report

```
/spec-os-product complete.

Mode: {initialize | generate | update}

Agents invoked: {list}

Files written:
  docs/mission.md      {created | updated | stub}
  docs/roadmap.md      {created | updated | stub}
  docs/design/         {created | updated}

{If spec-os/ does not exist:}
Product documentation ready. Next step: set up the framework.
Run /spec-os-init to continue.

{If spec-os/ already exists:}
Product documentation updated.
No framework action needed — spec-os is already installed.
```

If `skill-handoffs: explicit` (default): stop. Do not invoke `/spec-os-init` automatically.

---

## Rules

- **Owns docs/ entirely.** This skill creates and modifies `docs/`. Other skills read
  `docs/mission.md` but do not write it. Boundaries are strict (Decision 22).
- **Orchestrates, never fabricates.** Content for agent-owned docs comes from agents.
  The skill does not write those sections itself unless the developer skips the agent.
- **Propose before writing.** Every agent output is gated with the developer before
  being written to disk. No file is written without explicit approval.
- **Stubs are acceptable.** If the developer skips an agent or answers are incomplete,
  create a stub with `TBD` placeholders. Stubs can be completed later with UPDATE mode.
- **Standards injection when available.** If `spec-os/standards/` exists, read and pass
  relevant standards to agents before invoking them (Decision B — session 2026-03-26).
- **May write README.md only on explicit developer request.** When GENERATE mode detects
  no usable README and the developer chooses option c), this skill writes `README.md`
  at project root. This is the only exception to the `docs/`-only boundary.
- **Roadmap is strategic, not tactical.** No tracker IDs or sprint references in roadmap.md.
- **Measurable outcomes are non-negotiable.** mission.md must have a Success metrics
  section with concrete KPIs. roadmap.md must have an Expected outcome per initiative.
  No doc is complete without measurable outcomes — stubs are acceptable but the section
  must exist and be filled before the skill reports completion.
- **market-researcher runs before product-owner.** Market evidence informs mission and
  roadmap. If market-researcher is skipped, product-owner works without external
  validation — note this gap in the generated docs.

---

## Self-improvement

Watch for these signals:

- **Developer skips all agents** → product-owner and architect agents may not have enough
  context to produce useful output. Consider improving the conversational discovery to
  gather more technical context upfront.
- **Developer frequently edits agent proposals** → agent prompts may need refinement.
  Record what was consistently wrong and update the affected agent file.
- **GENERATE mode produces poor inferences** → README.md is sparse. Suggest the developer
  add a proper README before running GENERATE.
- **UPDATE mode is never run** → docs are going stale. Consider adding a reminder to
  CLAUDE.md to run `/spec-os-product update` at major milestones.
