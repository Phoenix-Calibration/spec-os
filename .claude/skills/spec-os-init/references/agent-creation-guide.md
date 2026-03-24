# Agent Creation Guide — spec-os

How to create `.claude/agents/` files that work correctly within the spec-os framework.
Based on official Claude Code documentation for subagents.

---

## Agents vs Skills — the spec-os distinction

| | Skills | Agents |
|--|--------|--------|
| Location | `.claude/skills/*/SKILL.md` | `.claude/agents/*.md` |
| Invoked by | Developer (slash command) | `/spec-os-implement` (Agent tool) |
| Role | Orchestrator — runs the workflow | Executor — does the actual work |
| Scope awareness | Full framework context | Only what's passed as context |
| Can spawn others | Yes (via skill handoffs) | No — subagents cannot spawn subagents |
| Standards access | Via `/spec-os-inject` | Received as injected context from calling skill |

**Design rule:** agents never read `spec-os/` files directly. All standards, task context, and spec content are passed to them by `/spec-os-implement` at invocation time.

---

## File format

```markdown
---
name: agent-name
description: {when to invoke this agent — see description guide below}
tools: Read, Edit, Write, Bash, Grep, Glob, TodoWrite
model: sonnet
---

# {Agent Title}

## Role
{One sentence: what expert this agent embodies}

## Behavioral rules (non-negotiable)
{Numbered list of hard constraints}

## What you do NOT own
{Files and decisions that belong to other skills}
```

---

## YAML frontmatter — all fields

Only `name` and `description` are required. Use the others only when there's a clear need.

### Required fields

| Field | Description |
|-------|-------------|
| `name` | Unique identifier — lowercase letters and hyphens only. Must match how `/spec-os-implement` references it. |
| `description` | When Claude should delegate to this agent. Also used by `@agent-name` @-mention syntax. Be specific — see description guide below. |

### Commonly used in spec-os agents

| Field | Description | spec-os default |
|-------|-------------|-----------------|
| `tools` | Allowlist of tools the agent can use. Omitting this inherits all tools — usually too broad for a focused executor. | `Read, Edit, Write, Bash, Grep, Glob, TodoWrite` |
| `model` | `sonnet` \| `opus` \| `haiku` \| full model ID \| `inherit`. `inherit` uses the same model as the calling session. | `sonnet` |
| `disallowedTools` | Denylist — removed from inherited or specified list. Use when you want to inherit most tools but block specific ones. | (not used by default) |

### Advanced fields (use when warranted)

| Field | Description | When to use |
|-------|-------------|-------------|
| `memory` | `user` \| `project` \| `local` — enables persistent memory directory across conversations. | When an agent should accumulate codebase knowledge (e.g., a long-lived reviewer agent). Not recommended for task-execution agents — they should work from injected context. |
| `skills` | List of skill names to preload into agent context at startup. Full skill content is injected, not just made available. | When an agent needs framework-level knowledge (e.g., always needs verify conventions). Injected at startup, so don't overload. |
| `permissionMode` | `default` \| `acceptEdits` \| `dontAsk` \| `bypassPermissions` \| `plan` | Rarely needed. `acceptEdits` may be appropriate for task-execution agents where edit confirmations would interrupt flow. |
| `maxTurns` | Maximum agentic turns before the agent stops. | Set for bounded tasks where an agent running indefinitely would be a problem. |
| `hooks` | `PreToolUse` / `PostToolUse` hooks for conditional validation. | When you need to allow a tool generally but block specific operations within it (e.g., allow Bash but block destructive git commands). |
| `isolation` | `worktree` — runs the agent in a temporary git worktree. | Experimental/advanced: when an agent needs to make changes in isolation before review. |
| `background` | `true` — agent runs concurrently, not blocking the main conversation. | Not recommended for spec-os task agents — `/spec-os-implement` expects sequential execution. |

### Tool allowlist — tool names

Core tools available in Claude Code:

```
Read, Edit, Write, Bash, Grep, Glob, TodoWrite
WebFetch, WebSearch
Agent (spawning subagents — NOT available to agents, only to main session)
```

**spec-os task agents** (backend-dev, frontend-dev) should use: `Read, Edit, Write, Bash, Grep, Glob, TodoWrite`

**Read-only agents** (e.g., a future verify agent): `Read, Bash, Grep, Glob`

---

## Writing the `description` field

The description determines when Claude delegates to this agent. It's also what the developer sees when using `@agent-name` @-mention.

**Include:**
- What expertise/role the agent embodies
- That it's invoked by `/spec-os-implement`, not directly
- Any specialized focus

**Example — too vague:**
```
Backend developer agent for implementing tasks.
```

**Example — good:**
```
Backend developer specialist. Invoked by /spec-os-implement to execute one task
as defined in tasks.md. Applies injected standards and produces one atomic commit.
Not for direct use — /spec-os-implement is the entry point.
```

---

## Writing the system prompt (markdown body)

The body of the file becomes the agent's system prompt. Agents receive **only** this system prompt plus basic environment details (working directory, etc.) — they do NOT receive the full Claude Code system prompt or `CLAUDE.md`.

This means: anything the agent needs to know must be either in its system prompt OR passed as context by the invoking skill.

### System prompt structure for spec-os task agents

```markdown
# {Agent Title}

## Role
{One sentence: what expert this agent embodies in the context of a spec-os task}

## Behavioral rules (non-negotiable)
1. **Scope discipline** — only touch files declared in the task's `scope` field.
   Adjacent issues → report as notes, never fix silently.
2. **Propose before implement** — for non-trivial decisions, state your approach
   and wait for approval before writing code.
3. **No placeholders** — no TODO, FIXME, or placeholder code in committed output.
4. **Spec vs code contradiction** — stop immediately and report. Do not guess.
5. **Standards as law** — the standards passed as context are project law.
   Apply without deviation unless explicitly approved otherwise.
6. **One task = one commit** — exactly one atomic commit at the end.
7. **Commit format** — `{type}({domain}): {description} [{feature-id}-{task-id}]`

## What you do NOT own
- spec.md (owned by /spec-os-design)
- tasks.md (owned by /spec-os-plan)
- session-log.md (written by /spec-os-implement after your session)

Report discoveries (spec gaps, missing standards, scope questions) as notes.
Do not self-apply changes outside your declared scope.
```

---

## spec-os agent patterns

### Pattern 1 — Task execution agent (standard)

Used by: `/spec-os-implement`
Purpose: Implement exactly one task from `tasks.md`

```markdown
---
name: backend-dev
description: Backend developer specialist. Invoked by /spec-os-implement to
  execute one task as defined in tasks.md, applying injected standards.
  Not for direct use — /spec-os-implement is the entry point.
tools: Read, Edit, Write, Bash, Grep, Glob, TodoWrite
model: sonnet
---
```

### Pattern 2 — Read-only analysis agent

Used by: analysis or verify skills
Purpose: Read and analyze without modifying

```markdown
---
name: code-analyzer
description: Read-only code analysis specialist. Use to analyze code quality,
  architecture, or behavior without making changes.
tools: Read, Grep, Glob, Bash
model: sonnet
---
```

### Pattern 3 — Agent with injected skills

When the agent needs framework-level conventions at startup:

```markdown
---
name: spec-writer
description: Technical spec writer for spec-os. Creates spec.md content
  following spec-os spec format. Invoked by /spec-os-design.
tools: Read, Write, Grep, Glob
model: sonnet
skills:
  - spec-os-design
---
```

Note: only use `skills` when the agent needs the full skill content injected at startup. For standards injection (which varies per task), `/spec-os-inject` handles this dynamically — pass the result as context when invoking.

---

## What agents receive from /spec-os-implement

`/spec-os-implement` assembles context before invoking an agent via the Agent tool. The agent receives:

1. **Task definition** — the specific task block from `tasks.md` (scope, done-when, subagent type)
2. **Injected standards** — output from `/spec-os-inject` (matched standard files, full content)
3. **Tier 1 context** — first 20 lines of `CLAUDE.md`, target task section, spec.md frontmatter
4. **Tier 2/3 context** — additional files per `context-level` field on the task

Agents should treat all of this as authoritative — they don't need to re-read the framework files themselves.

---

## Storage and scope

| Location | Scope | Checked into git? |
|----------|-------|-------------------|
| `.claude/agents/` | Project — all team members | Yes — commit it |
| `~/.claude/agents/` | Personal — all your projects | No |

spec-os agents live in `.claude/agents/` and are committed to version control so the whole team uses the same executor definitions.

---

## Rules for spec-os agent design

- **One agent, one role.** Don't create a "full-stack" agent — keep backend and frontend separate so tool restrictions and behavioral rules match the role.
- **Tool discipline.** Grant only what the role requires. A backend agent doesn't need frontend-specific tools. A read-only analyzer should never have Write.
- **No framework reads.** Agents don't read `spec-os/config.yaml`, `spec-os/standards/`, or `spec-os/specs/` themselves — that's the skill's job. If an agent needs standards, they come through `/spec-os-inject` context.
- **No tracker calls.** Agents never call MCP tracker tools directly. Tracker operations belong to skills.
- **Atomic output.** Every task-execution agent ends with exactly one atomic commit. No partial commits, no "WIP" commits.
- **Commit format is enforced in the system prompt.** Include it explicitly — `{type}({domain}): {description} [{feature-id}-{task-id}]`.

---

## Updating agents

When agents need updating (e.g., new behavioral rule, tool added):
1. Edit `.claude/agents/{name}.md` directly
2. Restart the Claude Code session (agents are loaded at session start)
3. Commit the change — the team gets it via git pull

If you create a new agent type (beyond backend-dev and frontend-dev), also update:
- `/spec-os-implement` to know when to invoke it
- `tasks.md` `subagent` field vocabulary
- This guide
