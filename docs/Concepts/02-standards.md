# Standards

Standards are coding conventions extracted from your codebase into indexed, discoverable files. They are Layer 1 of spec-os — the answer to "how do we build things here?"

## What Standards Are

A standard is a concise, declarative file that describes one aspect of how your team writes code:

- Naming conventions
- Architectural patterns
- Error handling rules
- Test structure
- Stack-specific practices (dotnet, nextjs, python, etc.)

Standards are **not** prompts. They're reference files that the AI reads when relevant to a task.

## Where They Live

```
spec-os/standards/
├── index.yml              ← keyword → file mapping
├── global/
│   ├── naming.md
│   ├── commits.md
│   ├── security.md
│   └── pr-template.md
├── backend/
│   ├── architecture.md
│   ├── patterns.md
│   ├── testing.md
│   ├── error-handling.md
│   └── dotnet.md          (or python.md, etc.)
└── frontend/
    ├── components.md
    ├── state.md
    └── testing.md
```

## The Index

`spec-os/standards/index.yml` maps keywords to standard files. This is how `/spec-os-inject` knows which standards to load for a given task:

```yaml
standards:
  - file: backend/error-handling.md
    keywords: [error, exception, result, failure, handling]
  - file: backend/testing.md
    keywords: [test, unit, integration, coverage, mock, assertion]
  - file: global/commits.md
    keywords: [commit, git, message, branch]
```

When a task involves "error handling in a service", `/spec-os-inject` matches `error` and `handling` → loads `error-handling.md`. Nothing else.

## How Standards Are Created

**Automatic extraction** — `/spec-os-discover` scans your codebase and proposes standards based on what it finds. Every proposal requires your approval before writing.

**Manual creation** — `/spec-os-standard` lets you create or update a standard directly, with the full proposed file shown before any write.

Both commands update `index.yml` when keywords change.

## Status Field

Every standard file carries a status line:

```
> Status: STUB — populate with project-specific rules
> Status: EXTRACTED — 2026-03-22
> Status: UPDATED — 2026-03-28
```

`STUB` means it was created by `/spec-os-init` and hasn't been populated yet. Run `/spec-os-discover` to replace stubs with real conventions.

## Next Steps

← [Back to Architecture](01-architecture.md)

- [Specs](03-specs.md) — how behavior is documented
- [Setup Workflow](../Workflow/02-setup.md) — extract standards from your codebase
- [Skills Reference: /spec-os-discover](../Workflow/06-skills-reference.md#spec-os-discover)
