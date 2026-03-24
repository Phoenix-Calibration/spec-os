---
name: spec-os-clean
description: Maintenance skill for the spec-os project layer. Use this skill when the
  developer runs /spec-os-clean at the end of a sprint or release cycle, wants to clean
  up outdated or contradictory entries in the knowledge base, or needs to archive
  completed features from spec-os/changes/ to spec-os/archive/. Run manually — not
  part of the daily workflow.
---

# /spec-os-clean

## Goal

Maintain the health of the spec-os knowledge layer at sprint or release close. Two responsibilities: (1) clean up the knowledge base by removing obsolete or contradictory entries, and (2) archive completed features from `spec-os/changes/` to `spec-os/archive/`.

## Syntax

```
/spec-os-clean [mode]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `mode` | No | `kb` (knowledge base only) or `archive` (archival only) — runs both if omitted |

---

## Step 1 — Determine scope

If `mode: kb` → skip to **KNOWLEDGE BASE CLEANUP**.
If `mode: archive` → skip to **ARCHIVAL**.
If no mode: run both passes in sequence.

---

## KNOWLEDGE BASE CLEANUP

### Step 2 — Read knowledge base

Read `spec-os/specs/knowledge-base.md` fully. Read `spec-os/specs/_index.md` (domain list).

If knowledge base is empty or has fewer than 5 entries:
```
Knowledge base has {N} entries — too sparse for meaningful cleanup. Skipping.
```

### Step 3 — Scan for issues

Analyze each entry for:

**Obsolete entries:**
- Entry references a feature (`source` field) that is now `abandoned` in spec.md
- Entry describes a pattern that has been superseded by a more recent entry on the same topic
- Entry date is older than 12 months and describes a tool, library, or version-specific behavior that may no longer apply

**Contradictory entries:**
- Two entries with the same `domain` + `layer` + `type` that recommend opposite approaches
- Entry directly contradicts a current standard in `spec-os/standards/`

**Invalid domain tags:**
- Entry has a `domain` tag that no longer exists in `_index.md`

### Step 4 — Propose removals and updates

Present findings to developer:

```
─────────────────────────────────────────────────
Knowledge base scan — {N} entries reviewed
─────────────────────────────────────────────────

Issues found: {N}

1. OBSOLETE — "{title}" (source: {feature-id}, date: {date})
   Reason: feature {feature-id} was abandoned
   Action: remove

2. CONTRADICTORY — "{title1}" vs "{title2}"
   Reason: both cover {topic} in {domain}/{layer} with opposite recommendations
   Action: remove "{title1}" (older) | keep "{title2}" (more recent)

3. INVALID-DOMAIN — "{title}" (domain: {domain})
   Reason: domain "{domain}" no longer in _index.md
   Action: reassign to {suggested-domain} | remove

─────────────────────────────────────────────────
Apply all? [y / review-each / skip]
```

On `review-each`: present each finding individually with `[apply / skip]`.
On `skip`: proceed to ARCHIVAL without changes.

### Step 5 — Apply knowledge base changes

For each approved action: update `spec-os/specs/knowledge-base.md`.

Report:
```
Knowledge base: {N} entries removed, {N} updated. Total entries: {N}.
```

---

## Tracker Resolution

Read `.claude/shared/tracker-adapter.md` and apply the Tracker Resolution block.
Operations used by this skill: get-feature, get-us, update-status

---

## ARCHIVAL

### Step 6 — Find archival candidates

Scan `spec-os/changes/` for feature folders where `spec.md` has:
- `status: done` — all US verified and PR merged, or
- `status: abandoned` — feature was formally abandoned via `/spec-os-abandon`

Present candidates to developer:

```
─────────────────────────────────────────────────
Archival candidates in spec-os/changes/
─────────────────────────────────────────────────

DONE:
  F042-equipment-migration   (completed {date}, {N} US, PR merged)
  F038-user-permissions      (completed {date}, {N} US, PR merged)

ABANDONED:
  F041-bulk-export           (abandoned {date}, reason: deprioritized)

Archive all? [y / review-each / skip]
─────────────────────────────────────────────────
```

### Step 7 — Validate before archiving

For each candidate marked `done`:
- Confirm `verify-report.md` has at least one PASS entry
- Confirm `verify-report.md` contains a PR URL
- **Confirm PR is merged:** read the PR URL from `verify-report.md` and query tracker status via adapter. If PR is not merged (still open or abandoned): flag as `not ready — PR not merged` and exclude from archival.
- Confirm all tasks in tasks.md are `status: done`
- Confirm no tasks have `claimed-by` set (would indicate active session)

If any validation fails: flag the folder as `not ready — {reason}` and exclude from archival.

### Step 8 — Archive

For each approved `done` candidate:

**Update tracker before moving:**
```
For each US-id in tasks.md Progress table:
  update-status tracker US {US-id} → Done/Closed

update-status tracker Feature {feature-id} → Done/Closed
```

Then move the folder:
1. Create `spec-os/archive/` if it does not exist
2. Move folder: `spec-os/changes/{folder}/` → `spec-os/archive/{folder}/`
3. Add `archived-date: {ISO-date}` to spec.md frontmatter

Report:
```
Archived: {N} feature folders → spec-os/archive/
  F042-equipment-migration  → archived
  F038-user-permissions     → archived
  F041-bulk-export          → archived
```

---

## Step 9 — Final report

```
/spec-os-clean complete.

Knowledge base:  {N} issues resolved ({N} removed, {N} updated)
                 or: skipped
Archival:        {N} folders moved to spec-os/archive/
                 or: skipped

spec-os/changes/ remaining: {N} active features
```

---

## Rules

- **Manual only — never part of the daily workflow.** `/spec-os-clean` is for release close or periodic maintenance. Running it mid-sprint risks archiving features that appear done but have open PRs.
- **Archive moves, never deletes.** Folders go to `spec-os/archive/`, not the trash. Historical context is preserved for future reference.
- **Validation before archival is non-negotiable.** Moving a folder with active claimed tasks or no PASS verify-report is a data loss risk. Step 7 guards against this.
- **Knowledge base cleanup requires developer approval per finding.** The skill proposes — the developer decides. Knowledge that looks stale may still be relevant to the team.

---

## Self-improvement

Watch for these signals:

- **Many contradictory entries found each cycle** → knowledge base entries may not be specific enough. Consider adding uniqueness checks to `/spec-os-sync` (warn on potential contradictions before writing).
- **Archival candidates pile up** → `/spec-os-clean` is being run infrequently. Remind developers in onboarding that it should run at sprint/release close.
- **Validation failures on "done" features** → verify flow may not be updating spec.md status correctly. Check `/spec-os-verify` Step 6 tracker update logic.
