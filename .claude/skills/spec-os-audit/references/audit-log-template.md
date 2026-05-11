# Audit Log Template

Use this template to create and append entries to `spec-os/audit-log.md`.
The audit-analyst agent is the sole writer of this file — never write directly.

---

## File header (create once if file does not exist)

```markdown
# spec-os Audit Log

Framework quality signals captured during development sessions.
To act on an improvement: copy the relevant "Suggested improvements" entries
and open an issue or PR in the spec-os repo.

---
```

---

## Entry template

```markdown
## Entry — {YYYY-MM-DD HH:MM} — {mode: context | analyze | feedback}

> source: {context | feature: F{ID} | feedback}  |  topic: {brief description}

### Context
{1-3 lines: what happened in this session, what feature was analyzed, or what feedback was given}

### Friction signals

| Target | Type | Evidence | Impact |
|---|---|---|---|
| {skill/agent/doc} | {spec-gap | unclear-output | missing-step | wrong-assumption | other} | {concrete observation} | {consequence for the developer} |

### What worked well
- {pattern or behavior that was smooth and should be preserved}

### Suggested improvements
- {target-type}: {target-id} | severity: {low | medium | high} | {concrete, actionable suggestion}

---
```

---

## Field reference

### mode
| Value | Meaning |
|---|---|
| `context` | Derived from analyzing the current session conversation |
| `analyze` | Derived from reading feature artifacts (session-log, verify-report, spec-delta, tasks) |
| `feedback` | Derived from direct developer feedback via guided Q&A |

### Friction signal — Type
| Value | Meaning |
|---|---|
| `spec-gap` | Skill did not probe enough — gaps discovered mid-implementation |
| `unclear-output` | Agent or skill output was ambiguous or required correction |
| `missing-step` | A step that should exist in the skill was absent |
| `wrong-assumption` | Skill or agent assumed something that wasn't true |
| `missing-skill` | A workflow need that no existing skill covers |
| `other` | Doesn't fit above — describe in evidence |

### Suggested improvements — target-type
| Value | Points to |
|---|---|
| `skill` | A skill file in `.claude/skills/` (e.g. `spec-os-design`) |
| `agent` | An agent file in `.claude/agents/` (e.g. `qa-engineer`) |
| `doc` | A doc file in `docs/` (e.g. `getting-started`) |
| `framework` | Structural gap — no single file is responsible |

### severity
| Value | Meaning |
|---|---|
| `low` | Minor UX friction — worth fixing but not blocking |
| `medium` | Causes rework or confusion — should be addressed soon |
| `high` | Blocks correct use of the framework or produces wrong output |
