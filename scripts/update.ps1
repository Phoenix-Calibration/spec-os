# spec-os update script — Windows (PowerShell)
# Clones the latest spec-os, overwrites skills and agents in your project,
# then removes the temporary clone.
#
# WARNING: all framework files will be overwritten. Rename any customized
# skill or agent files before running this script.
#
# Usage:   .\update.ps1 [-TargetDir <path>]
# Example: .\update.ps1 -TargetDir C:\projects\my-app
# Default: updates the current directory
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

# ── Check spec-os is installed ─────────────────────────────────────────────────

$SkillsDest  = Join-Path $TargetDir ".claude\skills"
$AgentsDest  = Join-Path $TargetDir ".claude\agents"
$VersionFile = Join-Path $TargetDir "spec-os\version"

if (-not (Test-Path $SkillsDest) -or -not (Test-Path $AgentsDest)) {
    Write-Error "spec-os is not installed in '$TargetDir'. Run install.ps1 first."
    exit 1
}

# ── Read current installed version ────────────────────────────────────────────

$currentVersion = if (Test-Path $VersionFile) {
    (Get-Content $VersionFile -Raw).Trim()
} else {
    "unknown"
}

# ── Clone to temp ──────────────────────────────────────────────────────────────

$TempDir = Join-Path $env:TEMP "spec-os-update-$([System.Guid]::NewGuid().ToString('N').Substring(0,8))"

try {
    Write-Host "Fetching latest spec-os..."
    git clone --depth 1 --quiet $RepoUrl "$TempDir\spec-os"

    # ── Read latest version from cloned repo ──────────────────────────────────

    $latestVersion = "unknown"
    $versionYaml = Join-Path $TempDir "spec-os\VERSION.yaml"
    if (Test-Path $versionYaml) {
        $line = Get-Content $versionYaml | Where-Object { $_ -match '^version:' }
        if ($line) { $latestVersion = ($line -replace '^version:\s*', '').Trim() }
    }

    # ── Version check ─────────────────────────────────────────────────────────

    Write-Host ""
    Write-Host "Installed version : $currentVersion"
    Write-Host "Latest version    : $latestVersion"
    Write-Host ""

    if ($currentVersion -eq $latestVersion) {
        Write-Host "Already up to date."
        $confirm = Read-Host "Update anyway? [y/N]"
        if ($confirm -notmatch '^[Yy]$') {
            Write-Host "Update cancelled."
            exit 0
        }
    } else {
        Write-Host "Update available: $currentVersion → $latestVersion"
        Write-Host "Warning: all framework files will be overwritten."
        Write-Host "Local modifications to skill or agent files will be lost."
        Write-Host ""
        $confirm = Read-Host "Continue? [y/N]"
        if ($confirm -notmatch '^[Yy]$') {
            Write-Host "Update cancelled."
            exit 0
        }
    }

    # ── Update ────────────────────────────────────────────────────────────────

    Copy-Item -Recurse -Force "$TempDir\spec-os\.claude\skills\*" $SkillsDest
    Copy-Item -Recurse -Force "$TempDir\spec-os\.claude\agents\*" $AgentsDest

    # ── Write new version to project ──────────────────────────────────────────

    if ($latestVersion -ne "unknown") {
        Set-Content -Path $VersionFile -Value $latestVersion -NoNewline
    }

    # ── Done ──────────────────────────────────────────────────────────────────

    Write-Host ""
    Write-Host "spec-os updated successfully to $latestVersion."

} finally {
    # ── Cleanup ───────────────────────────────────────────────────────────────
    if (Test-Path $TempDir) {
        Remove-Item -Recurse -Force $TempDir
    }
}
