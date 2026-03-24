# Tracker Adapter

Shared resolution block. Skills read this file to resolve tracker access — do not copy this content inline.

---

## Tracker Resolution

Read `spec-os/config.yaml`. Identify current repo name from git remote or working directory name.
Match against `tracker.repos[].name`. Use that entry's `type`.

```
If type: ado
  Use Azure DevOps MCP for all tracker operations.
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

If type: github
  Use GitHub MCP for all tracker operations.
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

If no match found:
  Stop. Report: "No tracker configured for repo {name} in spec-os/config.yaml.
  Add an entry under tracker.repos[] and retry."
```

Your skill's step lists which operations it uses — apply only those. Ignore operations not listed.
