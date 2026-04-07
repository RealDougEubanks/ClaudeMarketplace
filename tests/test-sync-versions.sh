#!/usr/bin/env bash
# test-sync-versions.sh — Tests for scripts/sync-versions.sh
# Usage: bash tests/test-sync-versions.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC="$REPO_ROOT/scripts/sync-versions.sh"

pass=0
fail=0
total=0

echo "=== sync-versions.sh tests ==="

# Test 1: --check passes when versions are in sync
total=$((total + 1))
if "$SYNC" --check > /dev/null 2>&1; then
  echo "  PASS: --check passes when versions are in sync"
  pass=$((pass + 1))
else
  echo "  FAIL: --check failed but versions should be in sync"
  fail=$((fail + 1))
fi

# Test 2: Output contains "All versions are in sync" when clean
total=$((total + 1))
output=$("$SYNC" --check 2>&1 || true)
if echo "$output" | grep -q "All versions are in sync"; then
  echo "  PASS: --check reports all in sync"
  pass=$((pass + 1))
else
  echo "  FAIL: --check did not report 'All versions are in sync'"
  fail=$((fail + 1))
fi

# Test 3: Sync mode (without --check) also works without error
total=$((total + 1))
output=$("$SYNC" 2>&1 || true)
if echo "$output" | grep -q "All versions are in sync\|Synced"; then
  echo "  PASS: sync mode runs without error"
  pass=$((pass + 1))
else
  echo "  FAIL: sync mode produced unexpected output: $output"
  fail=$((fail + 1))
fi

# Test 4: Detect out-of-sync by temporarily modifying a plugin.json
# Save original, modify, check, restore
FIRST_SKILL=$(ls -d "$REPO_ROOT"/skills/*/  | head -1)
PLUGIN_JSON="$FIRST_SKILL/.claude-plugin/plugin.json"
if [ -f "$PLUGIN_JSON" ]; then
  ORIGINAL=$(cat "$PLUGIN_JSON")

  # Set version to something obviously wrong
  python3 -c "
import json, sys
p = json.load(open(sys.argv[1]))
p['version'] = '0.0.0-test'
with open(sys.argv[1], 'w') as f:
    json.dump(p, f, indent=2)
    f.write('\n')
" "$PLUGIN_JSON"

  total=$((total + 1))
  if "$SYNC" --check > /dev/null 2>&1; then
    echo "  FAIL: --check should fail when plugin.json is out of sync"
    fail=$((fail + 1))
  else
    echo "  PASS: --check detects out-of-sync plugin.json"
    pass=$((pass + 1))
  fi

  # Test 5: Sync fixes the out-of-sync version
  "$SYNC" > /dev/null 2>&1
  total=$((total + 1))
  if "$SYNC" --check > /dev/null 2>&1; then
    echo "  PASS: sync fixes out-of-sync version"
    pass=$((pass + 1))
  else
    echo "  FAIL: sync did not fix out-of-sync version"
    fail=$((fail + 1))
  fi

  # Restore original to avoid dirty working tree
  echo "$ORIGINAL" > "$PLUGIN_JSON"
else
  echo "  SKIP: no plugin.json found for sync tests"
fi

echo ""
echo "Results: $pass passed, $fail failed, $total total"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
