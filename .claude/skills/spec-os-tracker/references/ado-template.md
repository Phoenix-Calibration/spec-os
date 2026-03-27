# ADO Adapter

Azure DevOps adapter for spec-os tracker operations.
This file is owned by /spec-os-tracker. Edit the Field Mapping and State Mapping sections to match your organization's ADO configuration.

---

## Prerequisites

MCP server: `@azure-devops/mcp` (configured in `.mcp.json`)
Auth env var: `ADO_MCP_AUTH_TOKEN` — must be set in system environment before starting Claude Code.

---

## Tracker Resolution

Read `spec-os/tracker/config.yaml`. Identify current repo name from git remote or working directory name.
Match against `tracker.repos[].name`. Use that entry's connection details.

If no match found:
```
Stop. Report: "No tracker configured for repo {name} in spec-os/tracker/config.yaml.
Run /spec-os-tracker add to register this repo."
```

---

## Project Context

This section is populated during /spec-os-tracker INSTALL. Edit to match your organization and project configuration.

### Teams
List the teams spec-os will interact with. Used by /spec-os-plan and /spec-os-brainstorm when creating work items.

```
- name: {Team Name}
  area-path: {Project}\{Team Name}
```

Add one entry per relevant team.

### Iterations
Sprint path structure. Used by /spec-os-plan to format the iteration prompt when creating User Stories.
The skill always asks the developer for the current sprint at runtime — there is no `current` field to keep updated.

```
path-pattern:  {Project}\Sprint {N}    # {N} = sprint number placeholder
cadence:       2-weeks                 # 1-week | 2-weeks | 3-weeks | 4-weeks
```

### Defaults
Structured values applied directly in MCP calls. Skills use these without interpretation.

```
process-template:   Agile               # Agile | Scrum | CMMI
default-area-path:  {Project}\{Team}
bug-triage-area:    {Project}\{Triage}  # area-path for new bugs, if different from default
required-tags:                          # comma-separated tags applied to all created items, or blank
sp-cap-per-us:      8                   # /spec-os-plan warns if a single US exceeds this
```

### Behavior Rules
Free-form instructions applied by skills when performing tracker operations.
Write these as you would write rules in CLAUDE.md — natural language, one rule per line.

```
# - Never create Features directly under root — always link to an existing Epic first
# - Production bugs must include "prod-bug" tag in addition to required-tags
# - Confirm area-path with developer before creating any item under the Payments domain
```

Remove the `#` prefix to activate a rule. Add your own rules as needed.

---

## Field Mapping

Maps spec-os concepts to ADO field names. Edit these to match your organization.

```
title:          System.Title
description:    System.Description
story-points:   Microsoft.VSTS.Scheduling.StoryPoints
area-path:      System.AreaPath
iteration-path: System.IterationPath
state:          System.State
assigned-to:    System.AssignedTo
tags:           System.Tags
```

---

## State Mapping

Maps spec-os lifecycle states to ADO work item states. Edit to match your process configuration.

```
planned:        → New
in-progress:    → Active
done:           → Closed
abandoned:      → Removed
```

---

## Sync Direction

Controls which fields spec-os reads from and writes to ADO.

```
title:          write     # spec-os sets title on create
description:    write     # spec-os sets description on create
story-points:   write     # /spec-os-plan writes SP
area-path:      write     # set from config.yaml on create
state:          both      # /spec-os-implement and /spec-os-verify update; /spec-os-bug reads
assigned-to:    read      # spec-os reads but does not assign
```

---

## Operation Mapping

Use Azure DevOps MCP for all tracker operations.

```
get-bug         → mcp__ado__get_work_item(id)
get-feature     → mcp__ado__get_work_item(id)
get-us          → mcp__ado__get_work_item(id)
search-features → mcp__ado__get_work_items(query)
create-epic     → mcp__ado__create_work_item(type: "Epic", fields)
create-feature  → mcp__ado__create_work_item(type: "Feature", fields)
create-us       → mcp__ado__create_work_item(type: "User Story", fields)
update-status   → mcp__ado__update_work_item(id, fields)
create-pr       → mcp__ado__create_pull_request(...)
get-capacity    → mcp__ado__get_sprint_capacity(...)
add-comment     → mcp__ado__add_comment(id, text)
```

Your skill's step lists which operations it uses — apply only those. Use Field Mapping to resolve field names before constructing any MCP call.
