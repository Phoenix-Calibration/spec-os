# .env.example template

This file documents the environment variables required for tracker MCP authentication.
It is written to the project root as `.env.example` by /spec-os-tracker.
The actual `.env` file (if used) must be listed in `.gitignore` — never commit credentials.

---

## ADO

```
# Azure DevOps MCP Authentication
# Required when tracker type is: ado
# Set this variable in your SYSTEM environment — not in a .env file.
#
# Windows:
#   Settings → System → Advanced system settings → Environment Variables
#   Add: ADO_MCP_AUTH_TOKEN = <your-entra-id-token-or-pat>
#
# Mac / Linux:
#   Add to ~/.zshrc or ~/.bashrc:
#   export ADO_MCP_AUTH_TOKEN="<your-token>"
#   Then: source ~/.zshrc
#
# Restart Claude Code after setting the variable.

ADO_MCP_AUTH_TOKEN=your-ado-token-here
```

## GitHub

```
# GitHub MCP Authentication
# Required when tracker type is: github
# Personal Access Token with 'repo' scope.
# Set this variable in your SYSTEM environment — not in a .env file.
#
# Windows:
#   Settings → System → Advanced system settings → Environment Variables
#   Add: GITHUB_TOKEN = <your-pat>
#
# Mac / Linux:
#   Add to ~/.zshrc or ~/.bashrc:
#   export GITHUB_TOKEN="<your-pat>"
#   Then: source ~/.zshrc
#
# Restart Claude Code after setting the variable.

GITHUB_TOKEN=your-github-pat-here
```
