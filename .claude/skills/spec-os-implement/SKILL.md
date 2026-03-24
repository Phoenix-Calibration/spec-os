---
name: spec-os-implement
description: Execute one implementation task from tasks.md (one session, one commit).
  Use this skill when the developer runs /spec-os-implement, is ready to implement a
  specific task, or when /spec-os-verify routes a FAIL back to implementation. Also
  handles resume mode for interrupted sessions, standalone reconcile, and unclaim.
---

# /spec-os-implement

## Goal

Execute one atomic task from `tasks.md` end-to-end: load context, run the inner loop (test-write → implement → test-run), reconcile spec drift, get developer review, commit, and log. One task = one session = one commit.

## Syntax

```
/spec-os-implement [task-id] [feature-id] [mode]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `task-id` | Yes | e.g. `T03` — the task to implement |
| `feature-id` | No | e.g. `F042` — auto-detected if only one feature is in-progress |
| `mode` | No | `reconcile` or `unclaim` — see Special Modes below |

---

## Step 1 — Detect mode

If `reconcile` argument → jump to **RECONCILE MODE**.
If `unclaim` argument → jump to **UNCLAIM MODE**.
Otherwise: **EXECUTE MODE** — proceed with steps below.

---

## Step 2 — Tracker Resolution

Read `.claude/shared/tracker-adapter.md` and apply the Tracker Resolution block.
Operations used by this skill: get-us, update-status, add-comment

---

## Step 3 — INIT

Locate the feature folder in `spec-os/changes/`. Read `tasks.md`.

**Check claimed-by:**
```
If claimed-by: {another dev name}:
  Stop. "Task {task-id} is claimed by {dev}. Check tasks.md before proceeding."
```

**Assign claimed-by:** write `claimed-by: {current session identifier}` to tasks.md for this task.

**Check task status:**
```
If status: in-progress:
  → RESUME MODE
  Read session-log.md entry for this task.
  Report: "Resuming {task-id} — loading prior session context."

  Check if a commit for this task exists:
    git log --oneline --grep="{task-id}" (or check session-log for commit hash)

  If commit found:
    Skip Steps 4–6. Load context (Step 4) then go directly to Step 7 (RECONCILE).
    Report: "Task {task-id} has a prior commit — resuming at RECONCILE."

  If no commit found:
    Continue from Step 4 with session-log context loaded.
    Re-enter inner loop at Step 6b.
    Report: "Task {task-id} has no prior commit — resuming at EXECUTE."

If status: done:
  Stop. "Task {task-id} is already done. Did you mean a different task?"

If status: blocked:
  Stop. "Task {task-id} is blocked: {blocked-reason}. Resolve the blocker first."
```

Update task `status: in-progress` in tasks.md.

**Update spec.md if first task:**
```
If spec.md frontmatter status: planned:
  Update spec.md frontmatter → status: in-progress
  Update tasks.md frontmatter → status: in-progress
```

**Update tracker US if first task of feature:**
```
Check tasks.md: are there any tasks with status: done for this feature?
If no done tasks exist (this is the first task being started):
  update-status tracker US → Active
```

**Add comment to tracker US:**
```
add-comment tracker US: "T{NN} in progress — {task title} — {current session identifier}"
```

---

## Step 4 — LOAD

Load context by tier based on the task's `context-level` field.

**TIER 1 (always):**
- Read CLAUDE.md (first 20 lines only)
- Read tasks.md (target task section only)
- Read spec.md (frontmatter only)

**TIER 2 (context-level: 2 or higher — default):**
- Invoke `/spec-os-inject` with task keywords and subagent type
- Read `spec-os/specs/{domain}/spec.md` (domain spec — if exists)
- Read session-log.md entry for `depends-on` task only (if depends-on is set)

**TIER 3 (context-level: 3):**
- Read spec.md fully (or sections matching task scope)
- Read `spec-os/specs/knowledge-base.md` filtered by task domain and stack tags
- Read relevant ADRs from `docs/design/adr/` if referenced in spec.md

---

## Step 5 — CONFIRM

Determine agent type from task `subagent` field (`backend` or `frontend`).

Present to developer:

```
─────────────────────────────────────────────────
Ready to implement: {task-id} — {task title}
─────────────────────────────────────────────────
Feature:    {feature-id} — {title}
Agent:      {backend-dev | frontend-dev}
Scope:      {files from task scope field}
Done when:  {done-when criterion}
Standards:  {list of injected standards files}

Proceed? [y / n]
─────────────────────────────────────────────────
```

Wait for confirmation. Do not proceed to the inner loop without approval.

---

## Step 6 — INNER LOOP

Read `implement.max-iterations` from `spec-os/config.yaml` (default: 3).

### 6a — TEST-WRITE

Invoke `.claude/agents/test-writer` via Agent tool with:
- `spec-path`: path to spec.md
- `test-scope`: value from task's `test-scope` field
- `standards`: injected testing standards
- `task-id`: current task-id

test-writer returns a proposed test gap list. Present it to developer:

```
─────────────────────────────────────────────────
Proposed tests for {task-id}:
─────────────────────────────────────────────────
{test-writer proposal output}
─────────────────────────────────────────────────
Approve test list? [y / n / edit]
```

Wait for approval [gate]. On `n`: proceed with no new tests (developer accepts coverage risk). On `edit`: revise list per developer feedback.

### 6b — EXECUTE

Invoke `.claude/agents/{backend-dev | frontend-dev}` via Agent tool with:
- Full task context (task definition, tier-loaded files, injected standards)
- Approved test list from 6a
- Instruction: implement the task and write approved tests. **Do NOT commit** — the commit happens outside the loop after tests pass.

Agent executes in isolated context with its declared tool restrictions.

### 6c — TEST-RUN

Invoke `.claude/agents/test-runner` via Agent tool with:
- `test-command`: from project test conventions (dotnet test | pytest | npm test)
- `test-scope`: task's `test-scope` + any new test files written in 6b
- `scope`: current task-id

**On PASS:** exit inner loop → proceed to Step 6d (COMMIT).

### 6d — COMMIT

Inner loop exited with PASS. Dev-agent executes the commit:
- Commit message format: follow `spec-os/standards/global/commits.md`
- Include: task-id, task title, feature-id in message
- Example: `feat(F042): T03 — implement equipment status validation`

This is the single commit for this task. All code and test changes are included.

**On FAIL:**
- Increment iteration counter
- If `iteration < max-iterations`:
  ```
  Tests failed — iteration {N}/{max}. Passing failure details to dev-agent for correction.
  ```
  Re-invoke dev-agent with failure report from test-runner. Return to 6b.
- If `iteration == max-iterations`:
  ```
  ─────────────────────────────────────────────────
  Inner loop exhausted ({max-iterations} iterations).
  Last test results:
  {test-runner report}

  Options:
  a) Continue — give dev-agent one more attempt
  b) Stop — abandon this loop, inspect manually
  c) Skip tests — commit current state without passing tests
  ─────────────────────────────────────────────────
  ```
  Wait for developer decision [gate].

**On RUNNER-ERROR:** surface raw error to developer. Wait for decision [gate] before retrying.

---

## Step 7 — RECONCILE

Invoke `.claude/agents/spec-reconciler` via Agent tool with:
- `feature-path`: path to feature folder
- `task-id`: current task-id
- `changed-files`: output of `git diff --name-only HEAD~1` (files changed in the session commit)

spec-reconciler returns a RECONCILE REPORT.

**If report shows spec.md modified OR drift detected:**
```
─────────────────────────────────────────────────
Spec drift detected:
{reconciler report}

Invoke /spec-os-design Update to record this change? [y / n]
─────────────────────────────────────────────────
```

On `y`: invoke `/spec-os-design update` [HANDOFF — wait for it to complete]. If spec change affects tasks → invoke `/spec-os-plan update` [HANDOFF — wait].

On `n`: log the drift as a note in session-log.md and continue.

**If report is clean:** proceed to Step 8.

---

## Step 8 — REVIEW

Present implementation summary to developer:

```
─────────────────────────────────────────────────
Implementation complete — {task-id}
─────────────────────────────────────────────────
Files changed:  {list}
Tests:          {N passing}
Reconcile:      {clean | drift recorded}
Commit:         {commit hash — short}

Review the diff and approve to finalize.
Approve? [y / n / request-changes]
─────────────────────────────────────────────────
```

- **y** → proceed to Step 9
- **n** → discard commit (dev-agent runs `git reset --hard HEAD~1`), return to inner loop
- **request-changes** → commit exists; dev-agent runs `git reset HEAD~1` (uncommit, preserves changes in working directory) → return to Step 6b with developer's instructions

---

## Step 9 — LOG

Write a new entry to `session-log.md` for this task. Use the template from `docs/master-plan/04-templates.md`.

Update `tasks.md`:
- `status: done`
- `claimed-by: —` (released)
- `lessons-pending: [true]` for each lesson noted during the session

---

## Step 10 — US GATE

Check if all tasks for the current US are `status: done` in tasks.md.

**If US is complete:**
```
All tasks for US #{id} — {title} are done.
Ready to run /spec-os-verify?
Run /spec-os-verify [feature-id] [us-id] to continue.
```
If `skill-handoffs: explicit` (default): stop here. Do not auto-invoke.

**If tasks remain:**
```
{task-id} done. Next task: {next-task-id} — {title}
Run /spec-os-implement {next-task-id} to continue.
```

---

## RECONCILE MODE

```
/spec-os-implement reconcile [task-id]
```

Runs only Steps 2–3 (read config + locate task) and Step 7 (RECONCILE) on a completed task. Useful after a manual code review surfaces spec drift that was missed during the original session.

Does not re-run the inner loop. Does not commit. Only detects and routes drift.

---

## UNCLAIM MODE

```
/spec-os-implement unclaim [task-id]
```

Releases `claimed-by` for the specified task. Sets `claimed-by: —` and `status: planned` in tasks.md (reverting from in-progress). Use when a developer abandons a session without completing the task and another developer needs to pick it up.

Writes a note to session-log.md: `{task-id} unclaimed by {dev} on {date} — reason: {ask developer for reason}`.

---

## Rules

- **One task per session.** Never implement two tasks in one invocation. The inner loop is per-task, not per-feature.
- **Claim before loading.** Step 3 (claim) must complete before Step 4 (load context). Never load tier-2 or tier-3 context for a task that another developer has claimed.
- **Gates are not optional.** Step 5 (CONFIRM), the test-write gate (6a), and Step 8 (REVIEW) are mandatory. They exist because autonomous implementation without checkpoints produces hard-to-review diffs.
- **Commit ownership belongs to dev-agent.** The skill never commits directly. The commit happens in Step 6d after the inner loop exits with PASS — not inside the loop. This ensures a commit is never created from failing-test state.
- **RECONCILE is not a blocker.** If the developer says `n` to recording spec drift, the session continues — the drift is logged in session-log.md. Unrecorded drift is a technical debt, not a blocker.
- **Resume mode trusts session-log.** When resuming an in-progress task, the session-log entry is the authoritative record of what was done. Load it before loading any other context.

---

## Self-improvement

Watch for these signals after each session:

- **Inner loop hits max-iterations frequently** → tasks may be too large or `done-when` criteria too vague. Suggest tightening task scope in `/spec-os-plan`.
- **RECONCILE fires on most tasks** → spec.md is being written too early. Consider suggesting a longer design phase before implementation starts.
- **Developer uses `request-changes` at REVIEW often** → inner loop produces poor first drafts. Check whether injected standards are too sparse or context-level is set too low.
- **test-writer proposals are consistently rejected** → AC scenarios in spec.md may not be written with enough specificity to generate useful tests.
