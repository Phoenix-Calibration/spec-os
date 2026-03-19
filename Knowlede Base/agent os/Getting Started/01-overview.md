# Agent OS - Overview

**Source:** https://buildermethods.com/agent-os

---

> Agents that build the way you would

## What is Agent OS?

Every time you prompt an AI coding agent, you're re-teaching it context that should already be known. The reasoning behind your conventions, the patterns your team refined over time, the architectural decisions that shape everything — none of that comes through when an agent scans your code.

Agent OS fills that gap. It's a lightweight system for defining and managing your coding standards in AI-powered development — and in v3, it discovers and documents those standards for you.

It's designed to complement tools like Claude Code, Cursor, and other AI coding assistants, not replace them.

## Key Benefits

- **Standards management** — Maintain coding standards across all agentic work. Whether you're writing specs, prompting agents, or creating custom Skills, inject your standards to keep work aligned.

- **Legacy codebase support** — Bring pre-AI codebases into the modern era. Discover and document tribal knowledge that exists only in your code, making it easier to use AI agents going forward.

- **Better spec shaping** — Enhanced shaping questions (run in plan mode) help you create stronger, more aligned specs that account for your product's mission and all your standards.

- **Team alignment** — Keep your entire organization aligned on a spec-driven approach with Claude Code or any AI coding tool.

## How It Works

1. **[Install](02-installation.md)** — Set up Agent OS in your project with a simple installation script
2. **Discover** — Extract existing patterns from your codebase into documented standards
3. **Inject** — Deploy relevant standards into your context when you need them
4. **Shape** — Use enhanced shaping in plan mode to create specs aligned with your standards

## Works With Any Tool

Agent OS is designed primarily for Claude Code, with slash commands that integrate directly into your workflow. However, since all outputs are markdown files, Agent OS works just as well with any AI coding tool:

- **Claude Code** (recommended) — Full integration with slash commands
- **Cursor**
- **Windsurf**
- **Codex**
- **Any AI coding assistant** that can read files

For tools other than Claude Code, simply reference the underlying files in `agent-os/` directly.

## Next Steps

- [Installation guide](02-installation.md)
- [Updating Agent OS](03-updating.md)
- [Using with other tools](04-adaptability.md)
- [What's new in v3.0](05-new-in-v3.md)

## Resources

- **GitHub**: https://github.com/buildermethods/agent-os
- **Website**: https://buildermethods.com/agent-os
- **Created by**: [Brian Casel](https://briancasel.com/)

---

**Free & Open Source**

© 2026 CasJam Media, LLC / Builder Methods
