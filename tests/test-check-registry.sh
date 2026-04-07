#!/usr/bin/env bash
# test-check-registry.sh — Tests for scripts/check-registry.sh
# Usage: bash tests/test-check-registry.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECK_REGISTRY="$REPO_ROOT/scripts/check-registry.sh"

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

echo "=== check-registry.sh tests ==="

# Test 1: Current registry is consistent
assert_pass "registry is consistent with skill directories" "$CHECK_REGISTRY"

# Test 2: Every skill directory has a metadata.json with a matching name
total=$((total + 1))
all_match=true
for dir in "$REPO_ROOT"/skills/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  meta="$dir/metadata.json"
  if [ -f "$meta" ]; then
    meta_name=$(python3 -c "import json, sys; print(json.load(open(sys.argv[1]))['name'])" "$meta" 2>/dev/null || echo "")
    if [ "$meta_name" != "$name" ]; then
      echo "    MISMATCH: $name vs metadata name=$meta_name"
      all_match=false
    fi
  fi
done
if $all_match; then
  echo "  PASS: all metadata.json names match directory names"
  pass=$((pass + 1))
else
  echo "  FAIL: metadata.json name mismatches found"
  fail=$((fail + 1))
fi

echo ""
echo "Results: $pass passed, $fail failed, $total total"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
