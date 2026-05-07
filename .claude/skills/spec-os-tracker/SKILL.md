---
name: spec-os-tracker
description: Set up and manage the tracker module (spec-os/tracker/) in a spec-os project. Use this skill when the developer runs /spec-os-tracker, wants to configure ADO or GitHub tracker integration, needs to add a tracker to an existing spec-os installation, or wants to update tracker connection details. Also triggered automatically by /spec-os-init after installation when a tracker type was declared. This skill is the sole owner of spec-os/tracker/ — invoke it whenever the developer mentions tracker setup, ADO configuration, GitHub integration, or changing tracker settings in a spec-os project, even if they don't say /spec-os-tracker explicitly.
---

# /spec-os-tracker

## Goal

Create and maintain the `spec-os/tracker/` module — the physical isolation layer for all tracker-related configuration and adapter logic. Once installed, skills that need tracker access read this module; if the module is absent, they continue in tracker-free mode.

## Syntax

```
/spec-os-tracker [mode] [tracker-type]
```

| Argument | Required | Values |
|----------|----------|--------|
| `mode` | No | `install` \| `update` \| `add` — auto-detected if omitted |
| `tracker-type` | No | `ado` \| `github` — passed by `/spec-os-init` on handoff |

---

## Step 1 — Detect mode

If `mode` argument provided, use it directly. Otherwise auto-detect:

1. `spec-os/tracker/` does not exist → **INSTALL mode**
2. `spec-os/tracker/` exists, single repo in config → **UPDATE or ADD** — ask:
   ```
   Tracker module found. What would you like to do?
   1. Update existing tracker connection details
   2. Add a second tracker (multi-repo project)
   ```
3. `spec-os/tracker/` exists, multiple repos → same prompt

Report detected mode. Proceed.

---

## INSTALL mode

Use when: no tracker module exists yet.

### T.1 — Guard

Check that `spec-os/` exists. If not:
```
spec-os/ not found. Run /spec-os-init first, then re-run /spec-os-tracker.
```
Stop.

### T.2 — Confirm tracker type

If `tracker-type` argument was passed (from `/spec-os-init`), use it and skip this step.

Otherwise ask:
```
Tracker type: ado | github
```
Wait for response.

### T.3 — Collect connection details

**If ado:**
```
ADO organization URL:  https://dev.azure.com/{org}
ADO project name:
Repo name (as it appears in git remote):
```

**If github:**
```
GitHub organization:
GitHub repo name:
```

Wait for response.

### T.4 — Propose module

Present the files to create. Wait for confirmation:

```
Will create:

spec-os/tracker/config.yaml   ← tracker connection for {repo-name}
spec-os/tracker/{type}.md     ← {type} adapter (resolution + MCP mapping)

Proceed? [y/n]
```

### T.5 — Create files

On confirmation, read the reference files before writing:
- `references/config-template.yaml` — config.yaml structure
- `references/{type}-template.md` — adapter file with field mapping, state mapping, and MCP operations
- `references/env-example-template.md` — `.env.example` content for the declared tracker type

Create files in this order:

1. `spec-os/tracker/config.yaml` — filled with declared values; no auth tokens
2. `spec-os/tracker/{type}.md` — copied from reference template; pre-fill `Project Context → Defaults` using known values (project name, org name); remaining placeholders are for the developer to complete
3. `.mcp.json` — create or merge into existing file:

**If ado:**
```json
{
  "mcpServers": {
    "ado": {
      "command": "npx",
      "args": ["-y", "@azure-devops/mcp", "{org-name}", "--authentication", "envvar"]
    }
  }
}
```

**If github:**
```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp",
      "headers": {
        "Authorization": "Bearer GITHUB_TOKEN"
      }
    }
  }
}
```
> Note: `GITHUB_TOKEN` in the Authorization header is a placeholder — the developer must replace it with the actual token value. Warn explicitly: do NOT commit `.mcp.json` after replacing the token. If `.mcp.json` is already tracked by git, add it to `.gitignore` before setting the real value.

4. `.env.example` — document required env vars (never write actual values)
5. Append `.env` to `.gitignore` if not already present

### T.6 — Report

```
Tracker module installed.

  spec-os/tracker/config.yaml    ← tracker connection registered
  spec-os/tracker/{type}.md      ← adapter with field mapping and project context (review and complete before first skill run)
  .mcp.json                      ← MCP server configured
  .env.example                   ← required environment variables documented

One manual step required — set the auth token in your system environment:

  {if ado:}
  Windows:   Settings → System → Advanced system settings → Environment Variables
             Add: ADO_MCP_AUTH_TOKEN = <your-Entra-ID-token-or-PAT>
  Mac/Linux: Add to ~/.zshrc or ~/.bashrc:
             export ADO_MCP_AUTH_TOKEN="<your-token>"
             Then: source ~/.zshrc

  {if github:}
  Windows:   Settings → System → Advanced system settings → Environment Variables
             Add: GITHUB_TOKEN = <your-PAT-with-repo-scope>
  Mac/Linux: Add to ~/.zshrc or ~/.bashrc:
             export GITHUB_TOKEN="<your-token>"
             Then: source ~/.zshrc

Restart Claude Code after setting the variable.
```

---

## UPDATE mode

Use when: tracker module exists, developer wants to change connection details or switch tracker type.

### U.1 — Read and show current config

Read `spec-os/tracker/config.yaml`. Display:
```
Current tracker configuration:
  Repo:   {name}
  Type:   {type}
  Org:    {organization | org}
  Project: {project}
```

### U.2 — Ask what to change

Also check: if the adapter file (`spec-os/tracker/{type}.md`) exists but its `Project Context`
section has empty fields or `{placeholder}` values, pre-select option 3 and note it.

```
What would you like to update?
1. Connection details (org URL, project name, repo name)
2. Tracker type (switch from ado to github or vice versa)
3. Complete Project Context (teams, iterations, defaults) {← suggested if placeholders found}
4. Options 1 + 3 or 2 + 3
```

### U.3 — Collect new values

Ask only for fields being changed. Show current value alongside:
```
ADO organization URL [{current}]:
ADO project name [{current}]:
```
Empty response = keep current value.

If switching tracker type: create the new adapter file (`spec-os/tracker/{new-type}.md`) from reference template, and delete the old adapter file (`spec-os/tracker/{old-type}.md`).

### U.3b — Complete Project Context (if option 3 selected)

Fetch live data from the configured tracker MCP in parallel:
- Teams list for the project
- Current and upcoming iterations
- Team defaults (default area path, iteration path, work item type)

Propose populated values for each empty field in the adapter's `Project Context` section:
```
─────────────────────────────────────────────────
Project Context — fetched from {tracker type} MCP
─────────────────────────────────────────────────
{populated fields with live values}
─────────────────────────────────────────────────
Write? [y / n / edit]
```

Wait for approval. Write updated adapter file.

### U.4 — Propose and write

Show the diff of what will change. Wait for confirmation. Write `spec-os/tracker/config.yaml`. If type changed, write new adapter file.

---

## ADD mode

Use when: tracker module exists, developer needs to register a second repo (multi-repo project).

### A.1 — Show existing repos

Read `spec-os/tracker/config.yaml`. Display current repos.

### A.2 — Collect new repo details

```
New repo tracker type: ado | github
Repo name (as it appears in git remote):
```
Then collect connection details per T.3.

### A.3 — Check adapter coverage

If the new repo uses a tracker type not yet in `spec-os/tracker/` (e.g., first GitHub repo in an ADO project): create the new adapter file from the reference template.

### A.4 — Propose and write

Show what will be added to `config.yaml` (and any new adapter file). Wait for confirmation. Write.

---

## Rules

- **Guard before everything.** Always check `spec-os/` exists before creating tracker files. A tracker module in a project without spec-os is orphaned and useless.
- **Propose before creating.** Show the full file list and wait for explicit confirmation before writing anything.
- **Never write credentials.** Organization URLs, project names, and repo names are safe. API tokens, PATs, and passwords are not — leave them as `{placeholder}` with a comment pointing to the developer's secret manager.
- **Operation Mapping must not be modified.** The MCP call structure in `ado.md` and `github.md` is shared across all projects — do not customize it per project. Field Mapping, State Mapping, and Project Context ARE meant to be edited per project. Connection details live in `config.yaml`.
- **This skill is the sole writer of `spec-os/tracker/`.** No other skill creates or modifies files in this folder. Other skills read it; only this skill writes it.
- **One repo per ADD run.** If the developer needs to add multiple repos, complete one ADD cycle, then run again. Mixing repos in a single run creates inconsistent state.
