---
name: spec-os-implement
description: Execute one implementation task from tasks.md (one session, one commit).
  Use this skill when the developer runs /spec-os-implement, is ready to implement a
  specific task, or when /spec-os-verify routes a FAIL back to implementation. Also
  handles resume mode for interrupted sessions, standalone reconcile, and unclaim.
---

# /spec-os-implement

## Goal

Execute one atomic task from `tasks.md` end-to-end: load minimal context, confirm with developer, load full context as file paths, run the inner loop (implement → test-run), reconcile spec drift, get developer review, commit, and log. One task = one session = one commit.

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

## Step 2 — Tracker Check

Check if `spec-os/tracker/` exists. If yes: read `spec-os/tracker/config.yaml` only — note the tracker type for later use. The full tracker adapter is loaded in Step 5 after confirmation.
If `spec-os/tracker/` does not exist, skip all tracker operations and continue.
Operations used by this skill: get-us, update-status, add-comment

---

## Step 3 — INIT

Read the target task section from `tasks.md` (not the full file — only the section for the specified task-id).

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
    Proceed to Step 4 (CONFIRM) then jump to Step 7 (RECONCILE). Skip Steps 5–6.
    Report: "Task {task-id} has a prior commit — resuming at RECONCILE."

  If no commit found:
    Proceed to Step 4 (CONFIRM) with session-log context loaded. Re-enter inner loop
    at Step 6b after Step 5 completes.
    Report: "Task {task-id} has no prior commit — resuming at EXECUTE."

If status: done:
  Stop. "Task {task-id} is already done. Did you mean a different task?"

If status: blocked:
  Stop. "Task {task-id} is blocked: {blocked-reason}. Resolve the blocker first."
```

Update task `status: in-progress` in tasks.md.

---

## Step 4 — CONFIRM

Present to developer using only the context already loaded (task section from tasks.md):

```
─────────────────────────────────────────────────
Ready to implement: {task-id} — {task title}
─────────────────────────────────────────────────
Feature:    {feature-id} — {title}
Agent:      {backend-dev | frontend-dev}
Scope:      {files from task scope field}
Done when:  {done-when criterion}
Context:    Tier {N} (context-level: {N})

Proceed? [y / n]
─────────────────────────────────────────────────
```

Wait for confirmation. Do not proceed to Step 5 without approval.

---

## Step 5 — LOAD & SETUP

All heavy loading and setup happens here — after the developer confirms.

**Load tracker adapter:**
Read `spec-os/tracker/{type}.md`. Apply the Tracker Resolution block.

**Create session-log.md if first task of feature:**
```
Check if spec-os/changes/{feature}/session-log.md exists.
If it does not exist (this is the first task ever started for this feature):
  Create session-log.md using the template at
  .claude/skills/spec-os-implement/references/session-log-template.md
  (write only the file header — the entry for this task is written in Step 9)
```

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

**Prepare context bundle for dev-agent:**

TIER 1 (always — inline, small):
- Read CLAUDE.md first 20 lines → pass inline
- Target task section already loaded in Step 3 → pass inline
- Read spec.md frontmatter → pass inline

TIER 2 (context-level: 2 or higher — default):
- Invoke `/spec-os-inject` with task keywords and subagent type → receive list of matched standard **file paths** (not content)
- Collect path: `spec-os/specs/{domain}/spec.md` (domain spec — if exists)
- Collect path + task-id: `session-log.md` depends-on entry (if depends-on is set)
All Tier 2 items are passed as **file paths** to the dev-agent. The dev-agent reads them directly — content never transits through the skill context.

If context-level: 1 (lite spec): skip `/spec-os-inject`. Pass `standards-paths: none` to dev-agent.

TIER 3 (context-level: 3):
- Collect path: `spec.md` (full, or sections matching task scope)
- Collect path: `spec-os/specs/knowledge-base.md` (dev-agent filters by domain + stack tags)
- Collect paths: relevant ADRs from `docs/design/adr/` if referenced in spec.md

---

## Step 6 — INNER LOOP

Read `implement.max-iterations` from `spec-os/config.yaml` (default: 3).

### 6a — EXECUTE

Invoke `.claude/agents/{backend-dev | frontend-dev}` via Agent tool with:
- Tier 1 context inline (CLAUDE.md identity, task section, spec.md frontmatter)
- `standards-paths`: list of file paths from `/spec-os-inject` (or `none` if context-level: 1)
- `context-paths`: domain spec path, session-log path + depends-on task-id (Tier 2/3 paths)
- Instruction: implement the task and write tests per the `test-scope` field. Read all files at the provided paths before writing code. **Do NOT commit.**

Agent reads all context files directly and executes in its isolated context.

### 6b — TEST-RUN

Invoke `.claude/agents/test-runner` via Agent tool with:
- `test-command`: from project test conventions (dotnet test | pytest | npm test)
- `test-files`: task's `test-scope` field + any new test files written in 6a
  (the task field is named `test-scope` — map it to test-runner's `test-files` parameter)
- `scope`: current task-id

**On PASS:** exit inner loop → proceed to Step 6c (COMMIT).

### 6c — COMMIT

Inner loop exited with PASS. Re-invoke `.claude/agents/{backend-dev | frontend-dev}` via Agent tool with:
- Instruction: commit — stage all changes and create one atomic commit
- Commit message format: `{type}({domain}): {task-title} [{feature-id}-{task-id}]`
  (follow `spec-os/standards/global/commits.md` if available — that format takes precedence)

This is the single commit for this task. All code and test changes are included.

**On FAIL:**
- Increment iteration counter
- If `iteration < max-iterations`:
  ```
  Tests failed — iteration {N}/{max}. Passing failure details to dev-agent for correction.
  ```
  Re-invoke dev-agent with failure report from test-runner. Return to 6a.
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
- **n** → re-invoke dev-agent with instruction: "run `git reset --hard HEAD~1` to discard this commit, then stop." Return to Step 6a.
- **request-changes** → re-invoke dev-agent with instruction: "run `git reset HEAD~1` to uncommit but preserve changes in the working directory, then apply these corrections: {developer's instructions}." Return to Step 6b with developer's instructions in scope.

---

## Step 9 — LOG

Write a new entry to `session-log.md` for this task. Use the template from `.claude/skills/spec-os-implement/references/session-log-template.md`.

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

Runs only the first part of Step 3 (locate feature folder, read target task section) and Step 7 (RECONCILE) on a completed task. Useful after a manual code review surfaces spec drift that was missed during the original session.

Does NOT run: CONFIRM (Step 4), LOAD & SETUP (Step 5), the inner loop (Step 6), LOG (Step 9), or US GATE (Step 10). Does not commit. Only detects and routes drift.

---

## UNCLAIM MODE

```
/spec-os-implement unclaim [task-id]
```

Releases `claimed-by` for the specified task. Sets `claimed-by: —` and `status: planned` in tasks.md (reverting from in-progress). Use when a developer abandons a session without completing the task and another developer needs to pick it up.

Writes a note to `session-log.md`: `{task-id} unclaimed by {dev} on {date} — reason: {ask developer for reason}`.

If `session-log.md` does not exist: create it using the header from `.claude/skills/spec-os-implement/references/session-log-template.md` before writing the unclaim note.

---

## Rules

- **One task per session.** Never implement two tasks in one invocation. The inner loop is per-task, not per-feature.
- **Claim before loading.** Step 3 (claim) must complete before Step 5 (load context). Never load Tier 2 or Tier 3 context for a task that another developer has claimed.
- **Gates are not optional.** Step 4 (CONFIRM) and Step 8 (REVIEW) are mandatory. They exist because autonomous implementation without checkpoints produces hard-to-review diffs.
- **Commit ownership belongs to dev-agent.** The skill never commits directly. The commit happens when Step 6c re-invokes the dev-agent with instruction `commit` — not inside the inner loop iterations. This ensures a commit is never created from failing-test state.
- **RECONCILE is not a blocker.** If the developer says `n` to recording spec drift, the session continues — the drift is logged in session-log.md. Unrecorded drift is a technical debt, not a blocker.
- **Resume mode trusts session-log.** When resuming an in-progress task, the session-log entry is the authoritative record of what was done. Load it before loading any other context.
- **Context is passed as paths, not content.** Tier 2 and Tier 3 context (standards, domain spec, knowledge-base, ADRs) are passed to dev-agents as file paths. The dev-agent reads them directly. This keeps the orchestration context lean.

---

## Self-improvement

Watch for these signals after each session:

- **Inner loop hits max-iterations frequently** → tasks may be too large or `done-when` criteria too vague. Suggest tightening task scope in `/spec-os-plan`.
- **RECONCILE fires on most tasks** → spec.md is being written too early. Consider suggesting a longer design phase before implementation starts.
- **Developer uses `request-changes` at REVIEW often** → inner loop produces poor first drafts. Check whether injected standards are too sparse or context-level is set too low.
