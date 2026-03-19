# Adaptability

**Source:** https://buildermethods.com/agent-os/adaptability

---

Using Agent OS with any AI coding tool

## Works With Any Tool

Agent OS is optimized for Claude Code, but works with any AI coding tool that can read file references. Whether you use Cursor, Windsurf, Gemini, Copilot, or another tool, you can use Agent OS to manage your coding standards.

The key is referencing the command files directly instead of using slash commands.

## Referencing Commands

Instead of typing `/discover-standards`, reference the command file with `@`:

```
@.claude/commands/agent-os/discover-standards.md
```

Most AI coding tools support `@` file references. When you reference a command file, the tool reads the instructions and follows them.

Add a brief instruction after the reference:

```
@.claude/commands/agent-os/discover-standards.md run this command
```

## Referencing Standards

You can also reference your standards files directly:

```
@agent-os/standards/api/response-format.md follow these conventions
```

Or reference multiple standards:

```
@agent-os/standards/api/response-format.md @agent-os/standards/api/error-handling.md apply these standards
```

This is the manual equivalent of `/inject-standards`—useful when you know exactly which standards apply.

## Tips

- **Check your tool's syntax** — Most tools use `@` for file references, but some may differ
- **Use tab completion** — Many tools auto-complete file paths after typing `@`
- **Reference the index** — Point your tool to `@agent-os/standards/index.yml` to see available standards
- **Combine with context** — Reference standards alongside the files you're working on for better results

## Next Steps

- [See what's new in v3.0](05-new-in-v3.md)
- [Learn about the workflow](../Workflow/workflow-overview.md)

---

[← Back to Getting Started](01-overview.md)
