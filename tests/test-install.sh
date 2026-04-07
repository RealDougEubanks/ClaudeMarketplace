#!/usr/bin/env bash
# test-install.sh — Tests for scripts/install.sh
# Usage: bash tests/test-install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$REPO_ROOT/scripts/install.sh"

pass=0
fail=0
total=0

assert_pass() {
  local label="$1"
  shift
  total=$((total + 1))
  if "$@" > /dev/null 2>&1; then
    echo "  PASS: $label"
    pass=$((pass + 1))
  else
    echo "  FAIL: $label (expected pass, got failure)"
    fail=$((fail + 1))
  fi
}

assert_fail() {
  local label="$1"
  shift
  total=$((total + 1))
  if "$@" > /dev/null 2>&1; then
    echo "  FAIL: $label (expected failure, got pass)"
    fail=$((fail + 1))
  else
    echo "  PASS: $label"
    pass=$((pass + 1))
  fi
}

assert_file_exists() {
  local label="$1"
  local file="$2"
  total=$((total + 1))
  if [ -f "$file" ]; then
    echo "  PASS: $label"
    pass=$((pass + 1))
  else
    echo "  FAIL: $label (file not found: $file)"
    fail=$((fail + 1))
  fi
}

echo "=== install.sh tests ==="

# Set up temp project directory
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Test 1: Install a skill with commands/ layout
assert_pass "install golden-rules to temp dir" "$INSTALL" "$REPO_ROOT/skills/golden-rules" "$TMPDIR"

# Test 2: Verify the installed file exists
assert_file_exists "golden-rules.md installed" "$TMPDIR/.claude/commands/golden-rules.md"
assert_file_exists "golden-rules.metadata.json installed" "$TMPDIR/.claude/commands/golden-rules.metadata.json"

# Test 3: Verify base skill appended to CLAUDE.md
total=$((total + 1))
if [ -f "$TMPDIR/CLAUDE.md" ] && grep -q "Golden Rules" "$TMPDIR/CLAUDE.md"; then
  echo "  PASS: base skill appended to CLAUDE.md"
  pass=$((pass + 1))
else
  echo "  FAIL: base skill not appended to CLAUDE.md"
  fail=$((fail + 1))
fi

# Test 4: Install a non-base skill (should not modify CLAUDE.md further)
TMPDIR2=$(mktemp -d)
trap 'rm -rf "$TMPDIR" "$TMPDIR2"' EXIT
assert_pass "install code-review to temp dir" "$INSTALL" "$REPO_ROOT/skills/code-review" "$TMPDIR2"
total=$((total + 1))
if [ ! -f "$TMPDIR2/CLAUDE.md" ]; then
  echo "  PASS: non-base skill did not create CLAUDE.md"
  pass=$((pass + 1))
else
  echo "  FAIL: non-base skill created CLAUDE.md unexpectedly"
  fail=$((fail + 1))
fi

# Test 5: Nonexistent skill fails
assert_fail "nonexistent skill fails" "$INSTALL" "$REPO_ROOT/skills/nonexistent-xyz" "$TMPDIR"

# Test 6: Nonexistent project dir fails
assert_fail "nonexistent project dir fails" "$INSTALL" "$REPO_ROOT/skills/golden-rules" "/tmp/nonexistent-dir-xyz-$$"

echo ""
echo "Results: $pass passed, $fail failed, $total total"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
