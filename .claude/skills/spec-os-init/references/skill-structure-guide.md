# Skill Structure Guide

Reference for creating spec-os skills (SKILL.md files) and agent files (.claude/agents/).
Use this guide when scaffolding new skills or reviewing existing ones.

---

## When this applies

**Skills** — slash commands in `.claude/skills/{skill-name}/SKILL.md`. Orquestrators. Entry points invoked by developers or other skills.

**Agents** — subagents in `.claude/agents/{name}.md`. Executors. Invoked by skills via the Agent tool. Not invoked directly.

Both use YAML frontmatter. Only skills follow the full structure below.

---

## Skill anatomy

```
.claude/skills/{skill-name}/
├── SKILL.md              (required — frontmatter + process, <500 lines)
└── references/           (optional — load only when needed)
    ├── {topic}.md        (detail too long for SKILL.md body)
    └── templates-*.md    (file templates used during execution)
```

**Progressive disclosure — the 3-level loading system:**
1. **Metadata** (name + description) — always in context, ~100 words max
2. **SKILL.md body** — in context whenever the skill is active, target <500 lines
3. **references/** — read on demand during execution, unlimited size

If SKILL.md approaches 500 lines, move detail into `references/` and add a pointer.

---

## SKILL.md structure

```markdown
---
name: skill-name
description: {what it does AND when to trigger it — see description guide below}
---

# /{skill-name}

## Goal
One sentence. What this skill accomplishes.

## Syntax
\`\`\`
/{skill-name} [arg]
\`\`\`

| Argument | Required | Description |
|----------|----------|-------------|
| `arg` | No | ... |

---

## Step 1 — {verb phrase}
{instructions}

## Step 2 — {verb phrase}
{instructions}

...

---

## Rules
- {guardrail}: {why it matters}
- ...

## Self-improvement
{How outputs from this skill inform future improvements}
```

---

## Writing the `description` field

The description is the **primary triggering mechanism** — Claude decides whether to invoke a skill based on name + description alone.

**Include both:**
- What the skill does
- Specific contexts that should trigger it (user phrases, states, situations)

**Be specific and a little "pushy"** — skills tend to undertrigger. Vague descriptions mean missed invocations.

**Example — too vague:**
```
Manages coding standards for the project.
```

**Example — good:**
```
Update an existing standard or create a new one in spec-os/standards/.
Use this skill when the developer runs /spec-os-standard, wants to edit,
refine, or add a coding convention, asks to update a standard, add a rule,
change a convention, or manage the standards files. Also use it when a
standard is outdated after a refactor or when the developer wants to
document a pattern that doesn't exist yet.
```

---

## Writing steps

- Use imperative form: "Read the file", "Propose the content", "Wait for approval"
- Name each step: `## Step N — {verb phrase}` (e.g., `## Step 2 — Propose content`)
- Mark human-in-the-loop decisions explicitly: show the prompt format and valid responses `[y / n / edit]`
- Explain *why* when a step isn't obvious — Claude follows instructions better with context

---

## Rules section

Each rule should have:
- The constraint (what not to do or what must always happen)
- The reason (what goes wrong if the rule is broken)

Avoid `ALWAYS` / `NEVER` in all caps without explanation. Explain the reasoning instead — it allows better judgment on edge cases.

---

## Self-improvement section

Describes how outputs from this skill feed back into improving it:
- What signals indicate the skill's rules or templates need updating
- Which file to update when that happens (`/spec-os-standard`, a `references/` file, etc.)
- Who initiates the update (developer, or the skill itself)

---

## Agent anatomy (for .claude/agents/)

Agents are not skills — they are executors, not orchestrators.
For the full agent creation guide (all frontmatter fields, spec-os patterns, system prompt structure, rules), read `references/agent-creation-guide.md`.

**Key differences from skills at a glance:**
- `tools` and `model` are set in frontmatter (not inferred)
- No `## Goal`, `## Syntax`, `## Steps` — the invoking skill controls the workflow
- `## Behavioral rules` replaces `## Rules` — agent-level hard constraints
- `## What you do NOT own` — explicitly names files/decisions that belong to skills
- Description names the invoking skill: "Invoked by /spec-os-implement. Not for direct use."
