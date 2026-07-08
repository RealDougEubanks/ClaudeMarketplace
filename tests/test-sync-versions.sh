#!/usr/bin/env bash
# test-sync-versions.sh — Tests for scripts/sync-versions.sh
# Usage: bash tests/test-sync-versions.sh
#
# Runs against a fixture repo (sync-versions.sh resolves the repo root from
# its own location, so the script is copied into a fake root). The live
# skills/ tree is never touched.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

pass=0
fail=0
total=0

echo "=== sync-versions.sh tests ==="

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAKE_ROOT="$TMP/repo"
mkdir -p "$FAKE_ROOT/scripts" "$FAKE_ROOT/skills/fixture-skill/.claude-plugin" "$FAKE_ROOT/.claude-plugin"
cp "$REPO_ROOT/scripts/sync-versions.sh" "$FAKE_ROOT/scripts/sync-versions.sh"
SYNC="$FAKE_ROOT/scripts/sync-versions.sh"

cat > "$FAKE_ROOT/skills/fixture-skill/metadata.json" << 'EOF'
{
  "name": "fixture-skill",
  "version": "1.2.3",
  "description": "Fixture.",
  "author": {"name": "Test"},
  "tags": ["test"],
  "commands": ["/fixture-skill"],
  "category": "productivity"
}
EOF
cat > "$FAKE_ROOT/skills/fixture-skill/.claude-plugin/plugin.json" << 'EOF'
{"name": "fixture-skill", "version": "1.2.3"}
EOF
cat > "$FAKE_ROOT/skills/registry.json" << 'EOF'
{
  "skills": [
    {"name": "fixture-skill", "path": "skills/fixture-skill", "description": "Fixture.", "tags": ["test"], "version": "1.2.3", "category": "productivity"}
  ]
}
EOF
cat > "$FAKE_ROOT/.claude-plugin/marketplace.json" << 'EOF'
{
  "name": "test-marketplace",
  "plugins": [
    {"name": "fixture-skill", "source": "./skills/fixture-skill", "version": "1.2.3"}
  ]
}
EOF

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

# Test 3: --check detects an out-of-sync plugin.json
python3 -c "
import json, sys
p = json.load(open(sys.argv[1]))
p['version'] = '0.0.0-test'
with open(sys.argv[1], 'w') as f:
    json.dump(p, f, indent=2)
    f.write('\n')
" "$FAKE_ROOT/skills/fixture-skill/.claude-plugin/plugin.json"
total=$((total + 1))
if "$SYNC" --check > /dev/null 2>&1; then
  echo "  FAIL: --check should fail when plugin.json is out of sync"
  fail=$((fail + 1))
else
  echo "  PASS: --check detects out-of-sync plugin.json"
  pass=$((pass + 1))
fi

# Test 4: sync mode fixes the out-of-sync version
"$SYNC" > /dev/null 2>&1
total=$((total + 1))
if "$SYNC" --check > /dev/null 2>&1; then
  echo "  PASS: sync fixes out-of-sync version"
  pass=$((pass + 1))
else
  echo "  FAIL: sync did not fix out-of-sync version"
  fail=$((fail + 1))
fi

# Test 5: --check detects an out-of-sync registry version
python3 -c "
import json, sys
r = json.load(open(sys.argv[1]))
r['skills'][0]['version'] = '0.0.1'
with open(sys.argv[1], 'w') as f:
    json.dump(r, f, indent=2)
    f.write('\n')
" "$FAKE_ROOT/skills/registry.json"
total=$((total + 1))
if "$SYNC" --check > /dev/null 2>&1; then
  echo "  FAIL: --check should fail when registry.json is out of sync"
  fail=$((fail + 1))
else
  echo "  PASS: --check detects out-of-sync registry.json"
  pass=$((pass + 1))
fi

echo ""
echo "Results: $pass passed, $fail failed, $total total"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
