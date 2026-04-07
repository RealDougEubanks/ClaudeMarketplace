#!/usr/bin/env bash
# test-validate.sh — Tests for scripts/validate.sh
# Usage: bash tests/test-validate.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VALIDATE="$REPO_ROOT/scripts/validate.sh"

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

echo "=== validate.sh tests ==="

# Test 1: Valid skill passes validation
assert_pass "example-skill passes validation" "$VALIDATE" "$REPO_ROOT/skills/example-skill"

# Test 2: Nonexistent skill fails
assert_fail "nonexistent skill fails" "$VALIDATE" "$REPO_ROOT/skills/nonexistent-skill-xyz"

# Test 3: All real skills pass validation
for dir in "$REPO_ROOT"/skills/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  assert_pass "skill '$name' passes validation" "$VALIDATE" "$dir"
done

echo ""
echo "Results: $pass passed, $fail failed, $total total"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
