# spec-os install script — Windows (PowerShell)
# Clones the spec-os repo, copies skills and agents into your project,
# then removes the temporary clone.
#
# Usage:   .\install.ps1 [-TargetDir <path>]
# Example: .\install.ps1 -TargetDir C:\projects\my-app
# Default: installs into the current directory
#
# Requirements:
#   - git installed and authenticated with GitHub
#   - Access to the spec-os repo

param(
    [string]$TargetDir = "."
)

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/Phoenix-Calibration/spec-os.git"

# ── Validate target ────────────────────────────────────────────────────────────

if (-not (Test-Path $TargetDir)) {
    Write-Error "Target directory '$TargetDir' does not exist."
    exit 1
}

$TargetDir = (Resolve-Path $TargetDir).Path

# ── Clone to temp ──────────────────────────────────────────────────────────────

$TempDir = Join-Path $env:TEMP "spec-os-install-$([System.Guid]::NewGuid().ToString('N').Substring(0,8))"

try {
    Write-Host "Fetching spec-os..."
    git clone --depth 1 --quiet $RepoUrl "$TempDir\spec-os"

    # ── Install ────────────────────────────────────────────────────────────────

    Write-Host "Installing into: $TargetDir"

    $SkillsDest = Join-Path $TargetDir ".claude\skills"
    $AgentsDest = Join-Path $TargetDir ".claude\agents"

    New-Item -ItemType Directory -Force -Path $SkillsDest | Out-Null
    New-Item -ItemType Directory -Force -Path $AgentsDest | Out-Null

    Copy-Item -Recurse -Force "$TempDir\spec-os\.claude\skills\*" $SkillsDest
    Copy-Item -Recurse -Force "$TempDir\spec-os\.claude\agents\*" $AgentsDest

    # ── Done ──────────────────────────────────────────────────────────────────

    Write-Host ""
    Write-Host "spec-os installed successfully."
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Open Claude Code in: $TargetDir"
    Write-Host "  2. Run: /spec-os-init"

} finally {
    # ── Cleanup ───────────────────────────────────────────────────────────────
    if (Test-Path $TempDir) {
        Remove-Item -Recurse -Force $TempDir
    }
}
