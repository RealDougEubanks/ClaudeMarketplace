#!/usr/bin/env bash
# test-scan-prompts.sh — Tests for scripts/scan-prompts.sh
# Usage: bash tests/test-scan-prompts.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCAN="$REPO_ROOT/scripts/scan-prompts.sh"

pass=0
fail=0
total=0

assert_exit_code() {
  local label="$1"
  local expected="$2"
  shift 2
  total=$((total + 1))
  local actual
  actual=0
  "$@" > /dev/null 2>&1 || actual=$?
  if [ "$actual" -eq "$expected" ]; then
    echo "  PASS: $label (exit=$actual)"
    pass=$((pass + 1))
  else
    echo "  FAIL: $label (expected exit=$expected, got exit=$actual)"
    fail=$((fail + 1))
  fi
}

echo "=== scan-prompts.sh tests ==="

# Test 1: Scanner runs without error on the full repo
assert_exit_code "full scan exits cleanly (0 or 1 for warnings)" 0 "$SCAN"

# Test 2: Scanner accepts a specific skill directory
assert_exit_code "scan single skill directory" 0 "$SCAN" "$REPO_ROOT/skills/example-skill"

# Test 3: Scanner rejects nonexistent directory
assert_exit_code "nonexistent directory fails" 1 "$SCAN" "$REPO_ROOT/skills/nonexistent-xyz"

# Test 4: Verify scanner finds commands/*.md files (not just skill.md)
total=$((total + 1))
output=$("$SCAN" "$REPO_ROOT/skills/golden-rules" 2>&1 || true)
if echo "$output" | grep -q "commands/golden-rules.md"; then
  echo "  PASS: scanner finds commands/<name>.md files"
  pass=$((pass + 1))
else
  echo "  FAIL: scanner did not find commands/<name>.md files"
  fail=$((fail + 1))
fi

echo ""
echo "Results: $pass passed, $fail failed, $total total"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
