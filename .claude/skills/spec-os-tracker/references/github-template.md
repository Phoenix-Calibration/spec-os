# GitHub Adapter

GitHub adapter for spec-os tracker operations.
This file is owned by /spec-os-tracker. Edit the Field Mapping section to match your repository configuration.

---

## Prerequisites

MCP server: `github/github-mcp-server` (configured in `.mcp.json` via HTTP transport)
Auth env var: `GITHUB_TOKEN` — Personal Access Token with `repo` scope. Must be set in system environment before starting Claude Code.

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

This section is populated during /spec-os-tracker INSTALL. Edit to match your repository configuration.

### Milestones
GitHub milestones map to spec-os cadence. Used by /spec-os-plan when assigning milestones to User Stories.
The skill always asks the developer for the current milestone at runtime — there is no `current` field to keep updated.

```
cadence:  2-weeks      # 1-week | 2-weeks | monthly | release-based
```

### Defaults
Structured values applied directly in MCP calls. Skills use these without interpretation.

```
default-labels:   []    # additional labels applied to all created items, or blank
sp-label-prefix:  sp:   # prefix for SP labels (e.g., "sp:3") — or blank to disable
sp-cap-per-us:    8     # /spec-os-plan warns if a single US exceeds this
```

### Behavior Rules
Free-form instructions applied by skills when performing tracker operations.
Write these as you would write rules in CLAUDE.md — natural language, one rule per line.

```
# - Always close the linked issue in the PR body with "Closes #{id}"
# - Production bugs must include "prod-bug" label in addition to required labels
# - Confirm milestone with developer before creating any work item
```

Remove the `#` prefix to activate a rule. Add your own rules as needed.

---

## Field Mapping

Maps spec-os concepts to GitHub issue/PR fields. Edit label names to match your repository's label setup.

```
title:        title
description:  body
story-points: (not native — use milestone or custom label: "sp:{n}")
state:        state          # open | closed
labels:
  feature:    feature
  epic:       epic
  user-story: user-story
  bug:        bug
milestone:    milestone      # maps to spec-os cadence (sprint/milestone)
```

---

## State Mapping

Maps spec-os lifecycle states to GitHub issue states and labels.

```
planned:        → open  + label: planned
in-progress:    → open  + label: in-progress
done:           → closed
abandoned:      → closed + label: abandoned
```

---

## Sync Direction

```
title:          write     # spec-os sets title on create
description:    write     # spec-os sets description on create
labels:         write     # spec-os applies labels on create and status update
milestone:      write     # /spec-os-plan assigns milestone
state:          both      # /spec-os-verify closes; /spec-os-bug reads
```

---

## Operation Mapping

Use GitHub MCP for all tracker operations.

```
get-bug         → mcp__github__get_issue(id)
get-feature     → mcp__github__get_issue(id)
get-us          → mcp__github__get_issue(id)
search-features → mcp__github__list_issues(labels: ["feature"])
create-epic     → mcp__github__create_issue(fields + label: "epic")
create-feature  → mcp__github__create_issue(fields + label: "feature")
create-us       → mcp__github__create_issue(fields + label: "user-story")
update-status   → mcp__github__update_issue(id, state, labels)
create-pr       → mcp__github__create_pull_request(...)
add-comment     → mcp__github__add_comment(id, text)
[get-capacity: not applicable — GitHub has no sprint capacity concept]
```

Your skill's step lists which operations it uses — apply only those. Use Field Mapping to resolve label names before constructing any MCP call.
