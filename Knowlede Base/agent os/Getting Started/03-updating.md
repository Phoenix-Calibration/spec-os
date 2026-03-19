# Updating

**Source:** https://buildermethods.com/agent-os/updating

---

Keep Agent OS current

## How Updates Work

Updates happen in two places: the base installation in your home directory, and the commands in each project. You can update your projects with just the latest commands, or also refresh your standards from a profile.

## Updating the Base Installation

When updating, you want to:

- Keep your `~/agent-os/profiles/` folder (this contains your standards)
- Replace the `~/agent-os/commands/` and `~/agent-os/scripts/` folders with the latest versions

If you've customized any commands or scripts, back those up separately and merge your changes after updating.

### Option A: Manual Update

Download the latest ZIP from [github.com/buildermethods/agent-os](https://github.com/buildermethods/agent-os), then manually replace the `commands/` and `scripts/` folders while keeping your `profiles/` folder intact.

### Option B: Command Line

Back up your profiles folder:

```bash
cp -r ~/agent-os/profiles ~/agent-os-profiles-backup
```

Remove the old installation and clone the latest version:

```bash
rm -rf ~/agent-os && git clone https://github.com/buildermethods/agent-os.git ~/agent-os && rm -rf ~/agent-os/.git
```

Restore your profiles from the backup:

```bash
cp -r ~/agent-os-profiles-backup/* ~/agent-os/profiles/
```

Remove the backup folder:

```bash
rm -rf ~/agent-os-profiles-backup
```

## Updating Your Projects

After updating the base installation, you can update your projects in two ways:

### Commands Only

Use this when you want the latest Agent OS commands but don't want to change your project's standards:

```bash
cd /path/to/your/project
~/agent-os/scripts/project-install.sh --commands-only
```

This updates the slash commands in `.claude/commands/agent-os/` without touching your standards, specs, or product docs.

### Commands + Standards

Use this when you've updated a profile's standards or want to switch to a different profile:

```bash
cd /path/to/your/project
~/agent-os/scripts/project-install.sh
```

Without the `--commands-only` flag, the script will prompt you to confirm before overwriting your project's standards with the ones from your profile. You can also specify a different profile:

```bash
~/agent-os/scripts/project-install.sh --profile rails
```

## Checking Your Version

Check the version in your base installation:

```bash
cat ~/agent-os/config.yml | grep version
```

## Next Steps

- [Learn about adaptability](04-adaptability.md)
- [See what's new in v3.0](05-new-in-v3.md)

---

[← Back to Getting Started](01-overview.md)
