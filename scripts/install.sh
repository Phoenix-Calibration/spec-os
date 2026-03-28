#!/usr/bin/env bash
# spec-os install script — Linux / Mac
# Clones the spec-os repo, copies skills and agents into your project,
# then removes the temporary clone.
#
# Usage:   ./install.sh [target-project-path]
# Example: ./install.sh ~/projects/my-app
# Default: installs into the current directory
#
# Requirements:
#   - git installed and authenticated with GitHub
#   - Access to the spec-os repo

set -e

REPO_URL="https://github.com/Phoenix-Calibration/spec-os.git"
TARGET_DIR="${1:-.}"

# ── Validate target ────────────────────────────────────────────────────────────

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: target directory '$TARGET_DIR' does not exist."
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# ── Clone to temp ──────────────────────────────────────────────────────────────

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Fetching spec-os..."
git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR/spec-os"

# ── Install ────────────────────────────────────────────────────────────────────

echo "Installing into: $TARGET_DIR"

mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/.claude/agents"

cp -r "$TEMP_DIR/spec-os/.claude/skills/"* "$TARGET_DIR/.claude/skills/"
cp -r "$TEMP_DIR/spec-os/.claude/agents/"* "$TARGET_DIR/.claude/agents/"

# ── Done ───────────────────────────────────────────────────────────────────────

echo ""
echo "spec-os installed successfully."
echo ""
echo "Next steps:"
echo "  1. Open Claude Code in: $TARGET_DIR"
echo "  2. Run: /spec-os-init"
