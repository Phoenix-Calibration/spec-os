# DevCanvas — Template Repository Implementation Prompt for Claude Code

## Context

You are being asked to create the **DevCanvas template repository** — a reusable base that any project can adopt as a starting point for Spec-Driven Development.

This is NOT a specific project implementation. You are building the **empty, universal template** that will later be used in two ways:

1. **New projects** — clone this repo as the starting point
2. **Existing projects** — run `project-init` from this template inside an existing repo to adopt DevCanvas

The complete specification is in the attached `devcanvas.md` document. Read it in full before doing anything else. Every decision in that document has a reason — implement it faithfully.

---

## What this repo is

The output of this session is a GitHub repository named `devcanvas` (or `phoenix-devcanvas`) that contains:

- The complete DevCanvas folder structure with all READMEs
- All Skills fully implemented and ready to use
- A universal `CLAUDE.md` template with placeholder values
- Empty `docs/design/` base files ready to be filled per project
- A `project-init` Skill that developers run to adopt DevCanvas in any repo

This repo has no project-specific content — it is stack-agnostic and reusable across CalSystem, Odoo, Next.js, Python, or any other project.

---

## Your mission

### Part 1 — Read and understand

Before writing a single file:

1. Read `devcanvas.md` completely from start to finish
2. Confirm you understand the difference between:
   - This template repo (what you are building now)
   - A project repo (where `project-init` will be run later)
3. Ask me clarifying questions if anything is ambiguous — maximum 3 at a time

### Part 2 — Propose the implementation plan

Before creating anything, present me with:

1. **What you will create** — complete list of all files and folders
2. **What stays as placeholder** — files that will be filled per project when `project-init` runs
3. **What needs my input** — anything requiring decisions before proceeding (e.g., default specialist set to include in the template, organization-specific values)

Wait for my approval before proceeding to Part 3.

### Part 3 — Implement

Once I approve your plan:

1. Create the complete structure as defined in `devcanvas.md` Section 3
2. For each Skill, read the Skill Creator standard first:
   `/mnt/skills/examples/skill-creator/SKILL.md`
   Use it to ensure all SKILL.md files follow the correct format
3. For specialist Skills — create the full set as placeholders:
   `spec-implement/specialists/backend-dev/`
   `spec-implement/specialists/frontend-dev/`
   `spec-verify/specialists/qa/`
   Each with a SKILL.md that contains the structure but notes:
   `# Stack-specific content — project-init will fill this per project`
4. Create `.claude/CLAUDE.md` as a template with clear placeholders:
   `Project: {fill with project name}`
   `Stack: {dotnet | odoo | nextjs | python | other}`
   etc.
5. Leave all `docs/design/` base files (00-09) with headers and:
   `# {filename} — fill with project-specific content via project-init`
6. Create `docs/GETTING-STARTED.md` as a template with placeholders
   for values that `project-init` will fill (ADO org, GitHub org, etc.)

After completing each major section, report progress before continuing.

### Part 4 — Analysis and improvement suggestions

After implementation is complete, perform a thorough analysis of DevCanvas from multiple perspectives. For each finding, provide:

- **Area**: which section, file, or Skill is affected
- **Perspective**: from which angle you identified this (e.g., agent efficiency, developer experience, token consumption, scalability, security, maintainability, Scrum alignment)
- **Observation**: what you found
- **Suggestion**: what you recommend
- **Impact if ignored**: what problem stays unsolved
- **Priority**: high | medium | low
- **Score**: rate the finding from 1-10 (10 = critical gap, 1 = minor polish)

Analyze from at least these perspectives:

1. **Agent efficiency** — are there steps that consume unnecessary tokens or context? Are any Skills doing too much or too little?
2. **Developer experience** — is the workflow intuitive? Are there friction points where a developer might get confused or skip steps?
3. **Token consumption** — which Skills load the most context? Are there optimization opportunities?
4. **Scalability** — does the system hold up as the project grows? What breaks at 50 features? At 10 developers?
5. **Scrum alignment** — does the system faithfully represent Scrum ceremonies and artifacts? What is missing or misaligned?
6. **ADO integration** — are there ADO capabilities being underused? Is the MCP usage optimal?
7. **Skills architecture** — are the Skill boundaries clean? Are there missing Skills or Skills that should be merged?
8. **Risk and failure modes** — what can go wrong silently? Where are the single points of failure?
9. **Cross-repo scenarios** — does the cross-repo workflow hold up under real conditions?
10. **Your own perspective** — anything else you observe that does not fit the above categories

Present findings sorted by Score (highest first). Group findings with the same Score together.

---

## Rules for this session

- Read `devcanvas.md` completely before doing anything
- Always propose before applying — never create files without my approval
- Ask questions when unclear — maximum 3 at a time
- Report progress after each major section
- If you find a conflict between what `devcanvas.md` says and what makes technical sense, flag it — do not silently resolve it your way
- This is a template repo — never add project-specific content (no real ADO URLs, no real project names, no stack-specific code)
- All values that vary per project must be explicit placeholders in the format `{description}`
- Be direct and honest in your analysis — do not soften findings to be polite

---

## Attached document

`devcanvas.md` — the complete DevCanvas specification. This is your primary source of truth for everything you implement.
