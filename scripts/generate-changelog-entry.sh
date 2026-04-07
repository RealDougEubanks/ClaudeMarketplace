#!/usr/bin/env bash
# generate-changelog-entry.sh — Generate a changelog entry from git commits.
#
# Usage: ./scripts/generate-changelog-entry.sh [base-ref]
#   base-ref: branch to diff against (default: main)
#
# Outputs a Keep a Changelog formatted section to stdout.

set -euo pipefail

BASE_REF="${1:-main}"

# Get commits between base and HEAD
commits=$(git log --oneline "origin/${BASE_REF}...HEAD" 2>/dev/null || git log --oneline -20)

if [ -z "$commits" ]; then
  echo "No new commits found."
  exit 0
fi

# Categorize commits by conventional commit prefix
added=""
changed=""
fixed=""
removed=""
other=""

while IFS= read -r line; do
  # Strip the short hash
  msg="${line#* }"
  case "$msg" in
    feat:*|feat\(*|Add\ *|add\ *)
      added="${added}- ${msg#*: }
"
      ;;
    fix:*|fix\(*|Fix\ *|fix\ *)
      fixed="${fixed}- ${msg#*: }
"
      ;;
    refactor:*|refactor\(*|chore:*|chore\(*)
      changed="${changed}- ${msg#*: }
"
      ;;
    remove:*|Remove\ *|remove\ *|Delete\ *|delete\ *)
      removed="${removed}- ${msg#*: }
"
      ;;
    *)
      other="${other}- ${msg}
"
      ;;
  esac
done <<< "$commits"

# Build the changelog section
echo "## [Unreleased]"
echo ""

if [ -n "$added" ]; then
  echo "### Added"
  echo ""
  echo "$added"
fi

if [ -n "$changed" ]; then
  echo "### Changed"
  echo ""
  echo "$changed"
fi

if [ -n "$fixed" ]; then
  echo "### Fixed"
  echo ""
  echo "$fixed"
fi

if [ -n "$removed" ]; then
  echo "### Removed"
  echo ""
  echo "$removed"
fi

if [ -n "$other" ]; then
  echo "### Other"
  echo ""
  echo "$other"
fi
