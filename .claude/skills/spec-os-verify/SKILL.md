---
name: spec-os-verify
description: Quality gate per User Story. Use this skill when the developer runs
  /spec-os-verify after all tasks in a US are done, or when /spec-os-implement
  signals US completion. Runs test coverage audit, executes tests, checks conventions
  and DoD, creates PR, and routes to /spec-os-doc and /spec-os-sync.
---

# /spec-os-verify

## Goal

Validate that a completed User Story meets its Acceptance Criteria, passes all tests, is convention-clean, and satisfies the Definition of Done. Produce a persisted `verify-report.md` entry and create a PR on PASS.

## Syntax

```
/spec-os-verify [feature-id] [us-id]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `feature-id` | No | e.g. `F042` — auto-detected if one feature is in-progress |
| `us-id` | No | e.g. `US-142` — auto-detected if one US is awaiting verification |

---

## Step 1 — Tracker Resolution

Check if `spec-os/tracker/` exists. If yes: read `spec-os/tracker/config.yaml` to get tracker type, then read `spec-os/tracker/{type}.md` and apply the Tracker Resolution block. If `spec-os/tracker/` does not exist, skip tracker operations and continue.
Operations used by this skill: get-us, update-status, create-pr

---

## Step 2 — Read verification context

Read in parallel:
- `spec.md` — full: Requirements, Scenarios, Domain model (if full spec), DoD, spec-level
- `tasks.md` — all tasks for the target US: `done-when`, `doc-impact`, `test-scope`
- `spec-delta.md` — any changes since last verify cycle
- Tracker US — AC as recorded in the tracker

---

## Step 3 — QA AUDIT (coverage)

Invoke `/spec-os-inject` with keywords derived from the US title and domain, requesting
testing standards. Store the result as `standards-paths` (list of file paths).

Invoke `.claude/agents/qa-engineer` via Agent tool in Modo auditoría de cobertura with:
- `user-story`: US ID and title
- `spec-path`: path to spec.md
- `test-scope`: union of all `test-scope` values from US tasks
- `ac-list`: AC list from spec.md Scenarios
- `standards-paths`: [list of paths from /spec-os-inject]

Present qa-engineer's coverage proposal to developer:

```
─────────────────────────────────────────────────
AC test coverage audit — US #{id}
─────────────────────────────────────────────────
{qa-engineer proposal — gaps and proposed tests}
─────────────────────────────────────────────────
Add these tests before verification run? [y / n / edit]
```

On `n`: proceed without new tests (developer accepts coverage risk — noted in verify-report.md).

---

## Step 4 — QA EXECUTE & REPORT

Invoke `.claude/agents/qa-engineer` via Agent tool in Modo ejecución y reporte with:
- `user-story`: US ID and title
- `spec-path`: path to spec.md
- `test-command`: project test command
- `ac-list`: AC list from spec.md Scenarios
- `approved-tests`: tests approved in Step 3 (empty if developer declined)
- `feature-path`: path to feature folder in `spec-os/changes/`
- `standards-paths`: standards-paths from Step 3

qa-engineer writes tests, runs the full suite, and writes `changes/{feature}/verify-report.md`.

Read `changes/{feature}/verify-report.md` — check the Decisión field.

**On FAIL:**
```
─────────────────────────────────────────────────
QA FAIL — verify cannot proceed.
{verify-report.md — Decisión section}

Responsible task: {T-ID derived from failing test/AC}

Options:
a) Route to /spec-os-implement {T-ID} to fix
b) Inspect manually — stop verify here
─────────────────────────────────────────────────
```

Wait for developer decision [gate]. Do not create PR.

---

## Step 5 — CHECKS

Run all checks. Accumulate findings — do not stop on first failure.

**Check 1 — Scope compliance:**
Read `git diff --name-only` for all commits in this US. Verify all changed files are within the declared `scope` fields of the US tasks. Flag any out-of-scope changes.

**Check 2 — Conventions compliance:**
Invoke `/spec-os-inject` → get matched file paths. Read each file at the returned paths. Scan changed files for obvious violations (naming, structure, patterns). This is a heuristic scan, not a linter — flag clear violations only.

**Check 3 — DoD completeness:**
Read `spec.md` Definition of Done. Verify each checkbox:
- All tasks status: done ✓ (known from tasks.md)
- Unit tests passing ✓ (from Step 4)
- Integration tests passing ✓ (from Step 4)
- All AC verified (assess from Step 4 results)
- PR not yet created (will be created in Step 6)
- doc-impact tasks covered (check Step 7 will be offered)

**Check 4 — Placeholders:**
Grep changed files for `TODO`, `FIXME`, `HACK`, `PLACEHOLDER`, `throw new NotImplementedException`, `pass  #`, `// TODO`. Flag any found.

**Check 5 — spec-delta review:**
If `spec-delta.md` has entries since the last verify cycle: confirm the tasks affected by each delta entry are `status: done`.

**On any CHECK FAIL:**
```
─────────────────────────────────────────────────
Verification checks failed.
{findings list}

Responsible task: {T-ID if attributable}

Options:
a) Route to /spec-os-implement {T-ID} to fix
b) Waive this finding — document reason and proceed
─────────────────────────────────────────────────
```

Write a FAIL entry to `verify-report.md`. Wait for developer decision [gate].

---

## Step 6 — PASS: Create PR and update tracker

All tests passing and all checks clean (or waived with developer approval).

**Update spec.md and tasks.md status:**
```
Update spec.md frontmatter → status: in-review
Update tasks.md frontmatter → status: in-review
```

**Create PR** using the `spec-os/standards/global/pr-template.md` template. Fill:
- Summary from spec.md Scope
- US title and tracker URL
- AC list from spec.md Scenarios (checked)
- Test counts from `changes/{feature}/verify-report.md`
- Files changed from task scopes
- spec-os/changes/{feature}/ links
- **Autolink to tracker US in PR body:**
  - ADO: `AB#{us-id}` (links PR to User Story automatically)
  - GitHub: `Closes #{us-id}` (closes issue on merge automatically)

Create PR via tracker adapter. Store returned PR URL.

**Update tracker US status** → `In Review`.

**Bug resolution (if applicable):**
```
If feature-id starts with "B":
  update-status tracker Bug {feature-id} → Resolved/Closed
  add-comment tracker Bug {feature-id}:
    "Fixed in PR {PR-url} — verified {ISO-date}"
```

**Write PASS entry to verify-report.md:**
```
## Cycle {N} — {ISO-date} — Result: PASS

AC Coverage:       {n}/{total}
Unit tests:        passing ({N} tests)
Integration tests: passing ({N} tests)
Scope compliance:  clean
Conventions:       clean
Placeholders:      none
DoD:               complete
PR:                {PR URL}
```

---

## Step 7 — Report and handoffs

```
─────────────────────────────────────────────────
/spec-os-verify PASS — US #{id} — {title}

Tests:    {N} passing
PR:       {URL}
Tracker:  US #{id} → in-review
─────────────────────────────────────────────────
```

**doc-impact check:**
If any task in this US has `doc-impact: true`:
```
One or more tasks have doc-impact: true.
Run /spec-os-doc to update user documentation before syncing.
```
If `skill-handoffs: explicit` (default): stop. Do not auto-invoke `/spec-os-doc`.

**sync:**
`/spec-os-sync` runs automatically after PR creation regardless of `skill-handoffs` setting (Decision 27). This is the only exception to the `skill-handoffs: explicit` default — sync is idempotent and low-risk.

Invoke `/spec-os-sync` with feature-id and us-id now. Notify developer:
```
Sync ran automatically as part of PR creation (always automatic — see Decision 27).
```

---

## Rules

- **Never create a PR with failing tests.** The PR is the public artifact — it must represent a verified state. No exceptions for "minor" failures.
- **FAIL routes back, not forward.** A verify FAIL always produces a verify-report.md entry and routes to `/spec-os-implement`. Never skip the failure record.
- **Waived findings must be documented.** If the developer waives a check finding, record the waiver reason in verify-report.md. Silent waivers introduce invisible technical debt.
- **spec-delta is authoritative on what changed.** If spec-delta.md has entries, verify must confirm all affected tasks are done before PASS. An undone affected task means the spec change was not fully implemented.
- **/spec-os-sync is automatic post-PR — always, no exceptions.** `skill-handoffs: explicit` does NOT apply to sync. This is the sole exception to that setting (Decision 27). Sync is idempotent and low-risk; it never modifies source code or spec artifacts.

---

## Self-improvement

Watch for these signals after each session:

- **Scope compliance violations found frequently** → tasks.md scope fields are too broad or not respected by dev-agent. Tighten scope definitions in `/spec-os-plan` guidance.
- **qa-engineer FAIL rate is high** → tasks may lack test-scope detail suficiente. Revisá la especificidad de los ACs en spec.md y el campo `test-scope` en tasks.md.
- **Check 2 (conventions) fires on every US** → standards are not being injected effectively in `/spec-os-implement`. Check index.yml keyword matching.
- **Developer waives findings frequently** → DoD criteria may be set too strictly for this project. Consider revising spec.md DoD template.
