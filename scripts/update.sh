#!/usr/bin/env bash
# spec-os update script — Linux / Mac
# Clones the latest spec-os, overwrites skills and agents in your project,
# then removes the temporary clone.
#
# WARNING: all framework files will be overwritten. Rename any customized
# skill or agent files before running this script.
#
# Usage:   ./update.sh [target-project-path]
# Example: ./update.sh ~/projects/my-app
# Default: updates the current directory
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

# ── Check spec-os is installed ─────────────────────────────────────────────────

if [ ! -d "$TARGET_DIR/.claude/skills" ] || [ ! -d "$TARGET_DIR/.claude/agents" ]; then
  echo "Error: spec-os is not installed in '$TARGET_DIR'."
  echo "Run install.sh first."
  exit 1
fi

# ── Confirm ────────────────────────────────────────────────────────────────────

echo "Updating spec-os in: $TARGET_DIR"
echo ""
echo "Warning: all framework files will be overwritten."
echo "Local modifications to skill or agent files will be lost."
echo ""
read -r -p "Continue? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Update cancelled."
  exit 0
fi

# ── Clone to temp ──────────────────────────────────────────────────────────────

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

echo ""
echo "Fetching latest spec-os..."
git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR/spec-os"

# ── Update ─────────────────────────────────────────────────────────────────────

cp -r "$TEMP_DIR/spec-os/.claude/skills/"* "$TARGET_DIR/.claude/skills/"
cp -r "$TEMP_DIR/spec-os/.claude/agents/"* "$TARGET_DIR/.claude/agents/"

# ── Done ───────────────────────────────────────────────────────────────────────

echo ""
echo "spec-os updated successfully."
