# spec-os

AI-assisted development framework for Claude Code. Combines standards management, spec tracking, and a structured skill chain so you and your AI agree on what to build before any code is written.

```
→ tracker-agnostic   — ADO, GitHub, or any supported tracker
→ standards-first    — coding conventions extracted from your codebase, not hardcoded
→ spec-driven        — observable behavior documented before implementation begins
→ developer-controlled — explicit approval gates at every handoff (v1)
→ brownfield-ready   — adopt in existing projects, not just greenfield
```

## See it in action

```text
You: /spec-os-brainstorm
AI:  What idea would you like to analyze?

You: Equipment status email notifications
AI:  Real problem: operators discover status changes reactively, after delays.
     Proposed solution: event-driven notifications, configurable per role.
     Classification: Feature | Complexity: medium

     Searching ADO for related Feature... not found.
     Create Feature "Equipment status notifications"? [y/n]

You: y
AI:  Created Feature F042 in ADO.
     Created: spec-os/changes/F042-S24-equipment-notifications/origin.md
     Ready for /spec-os-create

You: /spec-os-create
AI:  Reading origin.md and Feature F042...
     Created: spec.md, spec-delta.md, session-log.md, verify-report.md
     Ready for /spec-os-plan

You: /spec-os-plan
AI:  Defined US-142 (SP: 5) and US-143 (SP: 3). Created in ADO.
     Generated tasks.md — T01 through T05.
     Ready for /spec-os-implement T01

You: /spec-os-implement T01
AI:  Loading context (Tier 2)... injecting standards (dotnet, domain-events)...
     Specialist: backend-dev. Confirm? [y/n]

You: y
AI:  [implements NotificationDispatcher service]
     Committed: feat(equipos): add NotificationDispatcher [F042-T01]
     Next: T02
```

## Quick Start

**1. Install spec-os in your project**

```text
/spec-os-init
```

That's it. spec-os detects whether you're starting from scratch or adopting in an existing project and creates the full structure.

**2. Configure your tracker**

Edit `spec-os/config.yaml` with your ADO or GitHub details.

**3. Start working**

```text
/spec-os-brainstorm   — new idea or requirement
/spec-os-bug {id}     — bug from tracker
```

## Docs

→ **[Getting Started](docs/getting-started.md)**: what spec-os creates and your first walkthrough
→ **[Concepts](docs/concepts.md)**: the 4-layer architecture and key ideas
→ **[Skills](docs/skills.md)**: reference for all `/spec-os-*` skills
→ **[Workflows](docs/workflows.md)**: patterns for features, bugs, and cross-repo initiatives

## Why spec-os?

AI coding assistants are powerful but lose context across sessions, duplicate tribal knowledge, and have no memory of why things were built a certain way. spec-os adds a lightweight layer that survives sessions:

- **Standards layer** — coding conventions live in indexed files, injected on demand (not dumped into every prompt)
- **Spec layer** — observable behavior is documented before implementation, not reconstructed after
- **Workflow layer** — a structured skill chain keeps the developer in control at every decision point
- **Tracker adapter** — works with your existing tracker (ADO, GitHub) without changing how you manage work

## Skills

| Skill | Purpose |
|-------|---------|
| `/spec-os-init` | Install or adopt spec-os in a project |
| `/spec-os-product` | Create product documentation (mission, roadmap) |
| `/spec-os-brainstorm` | Analyze an idea → create `origin.md` |
| `/spec-os-bug` | Analyze a bug → simple or complex path |
| `/spec-os-create` | Write technical spec from `origin.md` |
| `/spec-os-plan` | Decompose spec into User Stories and tasks |
| `/spec-os-implement` | Execute one task (one session, one commit) |
| `/spec-os-verify` | Quality gate per User Story |
| `/spec-os-doc` | Update user documentation (conditional) |
| `/spec-os-sync` | Sync lessons to knowledge base (always last) |
| `/spec-os-discover` | Extract coding standards from your codebase |
| `/spec-os-inject` | Load relevant standards for the current task |
| `/spec-os-standard` | Update or create a standard |
| `/spec-os-abandon` | Close a feature without completing it |
| `/spec-os-prune` | Clean up outdated knowledge base entries |
| `/spec-os-explore` | Analyze a cross-repo initiative (Claude Desktop) |
