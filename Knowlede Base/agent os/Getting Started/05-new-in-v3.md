# New in 3.0

**Source:** https://buildermethods.com/agent-os/migration

---

What's changed in Agent OS 3.0 and how to migrate from v2

## Upgrading to Agent OS v3

Agent OS 3.0 was released in January 2026.

## Why the Change?

AI coding tools have evolved significantly since Agent OS's original release in mid-2025. Claude Code's plan mode, extended thinking, and improved models now handle much of the scaffolding that earlier versions of Agent OS provided.

It doesn't make sense to reinvent these core functions, which are much better handled by the core tools than 3rd-party frameworks like Agent OS:

- **Spec writing** — Now best handled using Plan mode.
- **Task breakdown** — Claude Code and other tools automatically create and track todo lists.
- **Implementation orchestration** — Frontier models manage and delegate tasks on their own now (but you can still direct them to use subagents as you like).

Agent OS v3 focuses more squarely on the original problems it set out to solve in the first place:

- **Establishes standards** — A system to align your agents to how you build products and your product's mission.
- **Injects standards smartly** — Deploys the right standards at the right time, without reinventing your workflow.
- **Enhances spec-driven development** — Helps you create stronger, more aligned specs.

## What's Different in v3?

### Standards

The concept and structure of [standards](../Concepts/standards.md) is unchanged. But v3 introduces new tools for creating and maintaining them:

- **[/discover-standards](../Workflow/discover-standards.md)** — Lets the agent surface, suggest, and create standards from your codebase.
- **[/inject-standards](../Workflow/inject-standards.md)** — Injects standards into any context: conversations, plans, Claude Skills, or anywhere your agent needs them. It automatically detects which standards are relevant via the new `index.yml` file.
- **[Sync script](../Concepts/profiles.md)** — Syncs your project's standards back to your base profiles.

### Specs

The structure of specs is unchanged—your `agent-os/specs/` folders remain intact.

What's new is how specs are created. Instead of Agent OS commands handling spec writing, we defer to Plan Mode in Claude Code (or Cursor, or any agent with plan mode). This is the industry-standard approach to spec-driven development in 2026+.

Agent OS enhances plan mode with [/shape-spec](../Workflow/shape-spec.md), which prompts targeted questions that consider your standards and product mission—resulting in better, more aligned specs (which get written via Plan mode). It also saves your plan into your Agent OS spec folder automatically.

### Product Planning

The [product planning](../Workflow/product-planning.md) phase from v2 is still here, producing the same files:

- `agent-os/product/mission.md`
- `agent-os/product/roadmap.md`
- `agent-os/product/tech-stack.md`

It's simpler, smarter, and uses the AskUserQuestion tool for a smoother experience.

### Profiles

[Profiles](../Concepts/profiles.md) are still here for managing different standards sets across project types.

Inheritance is simpler in v3—now defined in your main `config.yml` instead of separate `profile-config.yml` files. V3 also adds a sync script to push new standards from a project back to your base profiles.

### Subagents & Orchestration

The implementation and orchestration phases from v2 have been retired. Today's frontier models handle spec implementation well on their own—this is the recommended approach in 2026+.

While Agent OS no longer installs subagents, you can create your own. Use [/inject-standards](../Workflow/inject-standards.md) to bake your standards into subagents, Claude Skills, custom commands, or any prompt.

## Is It Backward Compatible?

Yes and no.

**Your content stays the same.** Your standards, specs, and product docs use the same format. They transfer directly to v3 without modification.

**Commands and scripts are new.** The installation and updating process is much simpler in v3, but the commands themselves are different.

If you prefer to remain on v2, the [v2 documentation](https://buildermethods.com/agent-os/v2) is still available. However, we recommend using v3 on all new projects and consider updating existing projects to v3.

## Migrating the Base Installation

In v2, each profile folder contained: `agents/`, `commands/`, `workflows/`, `standards/`, and a `profile-config.yml` file.

For v3, you only need to keep the `standards/` folder in each profile. Everything else can be deleted (or backed up and removed).

Back up your profile standards:

```bash
cp -r ~/agent-os/profiles ~/agent-os-profiles-backup
```

Remove the old base installation and clone v3:

```bash
rm -rf ~/agent-os && git clone https://github.com/buildermethods/agent-os.git ~/agent-os && rm -rf ~/agent-os/.git
```

Restore your standards folders into each profile:

```bash
cp -r ~/agent-os-profiles-backup/my-profile/standards ~/agent-os/profiles/my-profile/
```

Repeat for each profile you had.

> **Note:** Profile inheritance is now defined in the main `~/agent-os/config.yml` file instead of `profile-config.yml` files inside each profile. See [Profiles](../Concepts/profiles.md) for details.

## Migrating Your Projects

For each project using Agent OS v2:

Remove the old agents folder:

```bash
rm -rf .claude/agents/agent-os
```

Remove the old commands folder:

```bash
rm -rf .claude/commands/agent-os
```

Install the new v3 commands:

```bash
~/agent-os/scripts/project-install.sh --commands-only
```

The `--commands-only` flag ensures your existing standards aren't overwritten. Your specs and product docs also remain untouched.

## Next Steps

- [Learn about the workflow](../Workflow/workflow-overview.md)
- [Understand profiles](../Concepts/profiles.md)
- [Learn about standards](../Concepts/standards.md)

---

[← Back to Getting Started](01-overview.md)
