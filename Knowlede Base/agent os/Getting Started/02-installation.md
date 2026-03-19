# Installation

**Source:** https://buildermethods.com/agent-os/installation

---

Set up Agent OS on your system and in your projects

## Two-Part Installation

Agent OS has two parts:

1. **Base installation** — Lives in your home directory (`~/agent-os/`). Holds your profiles, scripts, and slash commands.
2. **Project installation** — Lives in your project (`your-project/agent-os/`). Holds standards, specs, and product docs specific to that project.

This separation lets you maintain standards across multiple projects while keeping each project self-contained.

## Step 1: Base Installation

Get Agent OS into your home directory using one of two methods:

### Option A: Git Clone

Clone the repository to your home directory:

```bash
cd ~
git clone https://github.com/buildermethods/agent-os.git && rm -rf ~/agent-os/.git
```

### Option B: Download ZIP

If you prefer not to use git, download the ZIP file directly:

1. Download the ZIP from [github.com/buildermethods/agent-os](https://github.com/buildermethods/agent-os) (Code → Download ZIP)
2. Extract the contents
3. Move the extracted folder to your home directory and rename it to `agent-os`

Either method creates `~/agent-os/` with:

- `profiles/` — Your reusable standards sets
- `scripts/` — Installation and sync scripts
- `commands/` — Slash commands that get copied to projects
- `config.yml` — Configuration including default profile

## Step 2: Install Into Your Project

Navigate to your project directory and run the installation script:

```bash
cd /path/to/your/project
~/agent-os/scripts/project-install.sh
```

> **Windows Users**: The installation command requires a bash shell. We recommend using [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install), which provides a full Linux environment on Windows. Alternatively, you can use [Git Bash](https://git-scm.com/download/win) (included with Git for Windows) to run the installation command. Once installed, open your bash terminal and run the command above.

This creates:

- `agent-os/standards/` — Your project's coding standards
- `agent-os/standards/index.yml` — Index for standard matching
- `.claude/commands/agent-os/` — Slash commands for Claude Code

### Using a Specific Profile

To install with a specific profile:

```bash
~/agent-os/scripts/project-install.sh --profile rails
```

### Commands Only

To update only the commands (preserving existing standards):

```bash
~/agent-os/scripts/project-install.sh --commands-only
```

## Next Steps

- [Learn about updating](03-updating.md)
- [Using with other AI tools](04-adaptability.md)
- [Learn about profiles](../Concepts/profiles.md)
- [Discover standards from your codebase](../Workflow/discover-standards.md)

---

[← Back to Getting Started](01-overview.md)
