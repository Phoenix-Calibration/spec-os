---
name: spec-os-audit
description: >
  Capture framework quality signals during or after a development session and
  append a structured entry to spec-os/audit-log.md. Supports three modes:
  context (analyzes current session conversation), analyze (reads feature
  artifacts), and feedback (guided Q&A with developer). Use this skill when
  the developer runs /spec-os-audit, wants to report friction with a spec-os
  skill or agent, or wants to capture what worked well in a session.
---

# /spec-os-audit

## Goal

Collect quality signals about the spec-os framework from a real development
session and write a structured audit entry to `spec-os/audit-log.md`. The
entry is reviewed by the developer before being written. Nothing is written
without approval.

## Syntax

```
/spec-os-audit [feature-id] [--feedback]
```

| Argument | Required | Description |
|----------|----------|-------------|
| *(none)* | — | **Context mode** — analyzes the current session conversation |
| `feature-id` | No | **Analyze mode** — e.g. `F042` — reads artifacts from that feature folder |
| `--feedback` | No | **Feedback mode** — opens a guided Q&A session with the developer |

---

## Step 1 — Detect mode

**Context mode** (no arguments):
Capture the relevant parts of the current session conversation — commands run,
skill/agent outputs, corrections made, workarounds used. Proceed to Step 2 with
`mode: context` and the captured session text.

**Analyze mode** (`feature-id` provided):
Locate `spec-os/changes/{feature-id}/`. Verify it exists. Collect paths for:
`session-log.md`, `verify-report.md`, `spec-delta.md`, `tasks.md`, `spec.md`.
If the folder does not exist:
```
/spec-os-audit: Feature folder not found for {feature-id}.
Check spec-os/changes/ for available features.
```
Stop. Proceed to Step 2 with `mode: analyze`.

**Feedback mode** (`--feedback`):
Ask the developer three open questions — one at a time, wait for each answer:

1. *"¿Qué skill o agente te generó más fricción en esta sesión? ¿Dónde tuviste
   que improvisar o corregir el output?"*
2. *"¿Hubo algún paso del flujo que esperabas que existiera pero no existía?"*
3. *"¿Qué funcionó especialmente bien — algo que debería mantenerse como está?"*

Collect the answers as structured feedback text. Proceed to Step 2 with
`mode: feedback`.

---

## Step 2 — Invoke audit-analyst

Invoke `.claude/agents/audit-analyst` via Agent tool with:

- `mode`: context | analyze | feedback
- For `context`: the captured session text (commands, outputs, corrections, workarounds)
- For `analyze`: the list of artifact paths collected in Step 1
- For `feedback`: the structured developer answers from Step 1
- Instruction: produce a complete audit draft following the format in
  `.claude/skills/spec-os-audit/references/audit-log-template.md`

---

## Step 3 — Review with developer

Present the audit draft:

```
─────────────────────────────────────────────────
Audit draft — {mode} — {date}
─────────────────────────────────────────────────
{full draft from audit-analyst}
─────────────────────────────────────────────────
Write to spec-os/audit-log.md? [y / n / edit]
```

- `y`: proceed to Step 4
- `n`: discard — no file written
- `edit`: developer provides corrections, update the draft, re-present

---

## Step 4 — Write to audit-log.md

Read `.claude/skills/spec-os-audit/references/audit-log-template.md` to get
the file header and entry format.

Check if `spec-os/audit-log.md` exists:
- **Does not exist**: create it using the file header from the template, then
  append the approved entry.
- **Exists**: append the approved entry after the last `---` separator.

---

## Step 5 — Report

```
/spec-os-audit complete.

Entry written:  spec-os/audit-log.md
Mode:           {context | analyze | feedback}
Improvements:   {N} suggestion(s) logged

To act on these improvements, copy the "Suggested improvements" section
and open an issue in the spec-os repo.
```

---

## Rules

- **Never write without approval.** The draft always goes to the developer first.
  Step 3 is the only gate — nothing is written before it.
- **audit-log.md is append-only.** Never modify existing entries. If an entry
  needs correction, add a new one with a note referencing the original date.
- **audit-analyst produces the content, this skill writes the file.** The agent
  returns a draft — the skill owns the write operation.
- **Context mode captures, not invents.** Only include session events that
  actually happened in the conversation — no speculation about what might have
  been friction.
- **spec-os/audit-log.md lives in the project using spec-os**, not in the
  spec-os framework repo itself.

---

## Self-improvement

Watch for these signals:

- **Most entries have no friction signals** → context capture may be too shallow.
  Consider prompting the developer to add explicit friction notes in session-log.md.
- **Suggested improvements always target the same skill** → that skill likely has
  a systemic issue worth prioritizing in the spec-os backlog.
- **Developer frequently edits the draft** → audit-analyst prompt or Q&A questions
  need refinement.
