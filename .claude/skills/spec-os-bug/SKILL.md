---
name: spec-os-bug
description: Analyze a bug and route to the appropriate fix path. Use this skill when
  the developer runs /spec-os-bug with a tracker bug ID, wants to fix a reported defect,
  or needs to triage whether a bug requires a simple targeted fix or a full spec-driven
  analysis. Simple path creates a minimal feature folder and routes to /spec-os-implement.
  Complex path creates analysis.md for developer review before escalating.
---

# /spec-os-bug

## Goal

Triage a reported bug, classify it as simple or complex, and prepare the minimum necessary artifacts to route it to implementation. Simple bugs bypass the full spec lifecycle. Complex bugs get a structured analysis before entering it.

## Syntax

```
/spec-os-bug [bug-id]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `bug-id` | Yes | Tracker bug ID — e.g. `BUG-237` or `#891` |

---

## Step 1 — Tracker Resolution

Read `.claude/shared/tracker-adapter.md` and apply the Tracker Resolution block.
Operations used by this skill: get-bug

Fetch the bug from the tracker. Extract: title, description, reproduction steps, expected vs actual behavior, affected area/labels, severity/priority if set.

---

## Step 2 — Classify: simple or complex

Apply the classification table:

| Condition | Classification |
|-----------|---------------|
| Single file or function isolated to one layer | simple |
| Regression with clear reproduction steps and known cause | simple |
| No spec.md or domain model change required | simple |
| Cause unknown — requires codebase investigation | complex |
| Fix touches multiple layers or multiple domains | complex |
| Fix requires changing a documented behavior in spec.md | complex |
| Security or data integrity impact | complex |
| Intermittent or environment-dependent | complex |

**Multiple conditions:** if any "complex" condition is met, classify as complex.

Present to developer:

```
─────────────────────────────────────────────────
Bug: {bug-id} — {title}

Classification: simple | complex
Reason: {one-line rationale}

Proceed with {simple | complex} path? [y / reclassify]
─────────────────────────────────────────────────
```

Wait for confirmation. Developer may override classification.

---

## SIMPLE PATH (Steps 3–5)

### Step 3 — Create minimal feature folder

Create folder: `spec-os/changes/B{bug-id}-{slug}/`

Create `spec.md` with the bug context:

```markdown
---
feature-id: B{bug-id}
tracker-type: {ado | github}
tracker-url: {full URL}
status: in-progress
domain: {domain inferred from bug area}
stack: {from config.yaml}
spec-level: lite
spec-os-version: {version}
created: {ISO-date}
last-updated: {ISO-date}
---

## Bug reference
{bug-id} — {title}
Tracker: {URL}

## Scope

### In scope
Fix: {specific behavior to correct}

### Out of scope
No spec changes. No new features.

## Requirements

### Requirement: Correct {behavior}
The system MUST {expected behavior from bug report}.

#### Scenario: Bug reproduction
- GIVEN {reproduction precondition from bug report}
- WHEN {triggering action}
- THEN {expected behavior — what should happen}

#### Scenario: No regression
- GIVEN {normal usage precondition}
- WHEN {normal action}
- THEN {existing behavior is preserved}

## Definition of Done
- [ ] Bug reproduction scenario passes
- [ ] No regression in related tests
- [ ] PR created and linked to {bug-id}
```

Create `tasks.md` with a single task:

```markdown
---
feature-id: B{bug-id}
status: planned
last-updated: {ISO-date}
---

## Progress
| US | Title | SP | Status | Tasks |
|----|-------|----|--------|-------|
| — | Bug fix: {title} | 1 | planned | T01 |

---

## Bug fix: {title}

### T01 — Fix {specific behavior}
- subagent: {backend | frontend}
- depends-on: —
- scope: {file(s) inferred from bug description}
- done-when: Bug reproduction scenario passes, no regression in related tests
- context-level: 1
- doc-impact: false
- test-scope: {relevant existing test files | none}
- claimed-by: —
- status: planned
- lessons-pending: []
```

Create the required empty companion files so `/spec-os-implement` and `/spec-os-verify` do not fail:

**`session-log.md`:**
```markdown
# Session Log — B{bug-id}
```

**`spec-delta.md`:**
```markdown
# Spec Delta — B{bug-id}
```

**`verify-report.md`:**
```markdown
# Verify Report — B{bug-id}
```

### Step 4 — Report and handoff (simple)

```
─────────────────────────────────────────────────
/spec-os-bug simple path ready.

Created:
  spec-os/changes/B{bug-id}-{slug}/spec.md
  spec-os/changes/B{bug-id}-{slug}/tasks.md
  spec-os/changes/B{bug-id}-{slug}/session-log.md
  spec-os/changes/B{bug-id}-{slug}/spec-delta.md
  spec-os/changes/B{bug-id}-{slug}/verify-report.md

Bug: {bug-id} — {title}

Ready to fix?
Run /spec-os-implement T01 to begin.
─────────────────────────────────────────────────
```

If `skill-handoffs: explicit` (default): stop. Do not invoke `/spec-os-implement` automatically.

---

## COMPLEX PATH (Steps 5–6)

### Step 5 — Investigate and create analysis.md

Read relevant source files, tests, and spec.md (if it exists for the affected domain) to investigate the bug.

Create `spec-os/changes/B{bug-id}-{slug}/analysis.md`:

```markdown
# Bug Analysis — {bug-id}

## Bug summary
{title} — {tracker-url}

## Root cause
{what is causing the behavior — specific file:line if identifiable}

## Affected scope
- Files: {list}
- Domains: {list}
- Spec.md impact: {none | section to update}

## Fix options
### Option A — {name}
{description}
Pros: {list}
Cons: {list}

### Option B — {name}
{description}
Pros: {list}
Cons: {list}

## Recommendation
{which option and why}

## Suggested path
{simple — after review → /spec-os-implement}
{or: full spec path → /spec-os-design → /spec-os-plan → /spec-os-implement}
```

### Step 6 — Report and route (complex)

```
─────────────────────────────────────────────────
/spec-os-bug complex path — analysis ready.

Created: spec-os/changes/B{bug-id}-{slug}/analysis.md

Review the analysis and decide:
  a) Proceed with simple fix → run /spec-os-implement directly after creating spec.md + tasks.md
  b) Full spec path → run /spec-os-design B{bug-id} to formalize the change
─────────────────────────────────────────────────
```

Stop. Developer reviews analysis.md and decides the next step manually.

---

## Rules

- **Classification is a conversation, not an automated gate.** The table is a guide. Developer judgment overrides it — they know the codebase context.
- **Simple path does not write tests.** The test-write gate lives in `/spec-os-implement`'s inner loop. `spec-os-bug` only creates the minimal folder structure.
- **doc-impact: false is the default for bugs.** A bug fix restores existing behavior — that behavior was already documented (or should have been). Only set `doc-impact: true` if the fix changes how users interact with the feature.
- **Never modify spec.md for complex bugs without going through /spec-os-design.** If the fix requires a spec change, the complex path routes to `/spec-os-design`, which owns spec evolution.

---

## Self-improvement

Watch for these signals:

- **Simple bugs frequently turn complex during implementation** → the classification heuristics may be too lenient. Consider tightening the "multiple layers" condition.
- **analysis.md is rarely used (developers skip to implement)** → complex path may be adding friction without value. Consider simplifying.
- **Bug PRs frequently fail /spec-os-verify** → done-when criteria in the simple path T01 task are too vague. Tighten the template.
