#!/usr/bin/env bash
# test-new-skill.sh — Tests for scripts/new-skill.sh
# Usage: bash tests/test-new-skill.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NEW_SKILL="$REPO_ROOT/scripts/new-skill.sh"

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

echo "=== new-skill.sh tests ==="

# Use a temp directory to avoid polluting the real skills/
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# We need to run new-skill.sh from a fake repo root so it creates under skills/
FAKE_ROOT="$TMPDIR/repo"
mkdir -p "$FAKE_ROOT/skills" "$FAKE_ROOT/scripts" "$FAKE_ROOT/.claude-plugin"
cp "$NEW_SKILL" "$FAKE_ROOT/scripts/new-skill.sh"
echo '{"skills": []}' > "$FAKE_ROOT/skills/registry.json"
echo '{"name": "test-marketplace", "plugins": []}' > "$FAKE_ROOT/.claude-plugin/marketplace.json"

# Test 1: Scaffold a new skill
total=$((total + 1))
cd "$FAKE_ROOT"
if bash scripts/new-skill.sh test-skill > /dev/null 2>&1; then
  echo "  PASS: scaffold test-skill succeeds"
  pass=$((pass + 1))
else
  echo "  FAIL: scaffold test-skill failed"
  fail=$((fail + 1))
fi

# Test 2: Verify directory structure was created
assert_file_exists "commands/test-skill.md created" "$FAKE_ROOT/skills/test-skill/commands/test-skill.md"
assert_file_exists "metadata.json created" "$FAKE_ROOT/skills/test-skill/metadata.json"
assert_file_exists "README.md created" "$FAKE_ROOT/skills/test-skill/README.md"
assert_file_exists ".claude-plugin/plugin.json created" "$FAKE_ROOT/skills/test-skill/.claude-plugin/plugin.json"

# Test 2b: Verify auto-registration in registry.json and marketplace.json
total=$((total + 1))
reg_ok=$(python3 -c "
import json, sys
reg = json.load(open(sys.argv[1]))
mp = json.load(open(sys.argv[2]))
in_reg = any(s.get('name') == 'test-skill' for s in reg.get('skills', []))
in_mp = any(p.get('name') == 'test-skill' for p in mp.get('plugins', []))
print('yes' if in_reg and in_mp else 'no')
" "$FAKE_ROOT/skills/registry.json" "$FAKE_ROOT/.claude-plugin/marketplace.json" 2>/dev/null || echo "no")
if [ "$reg_ok" = "yes" ]; then
  echo "  PASS: skill auto-registered in registry.json and marketplace.json"
  pass=$((pass + 1))
else
  echo "  FAIL: skill not registered in registry.json and/or marketplace.json"
  fail=$((fail + 1))
fi

# Test 3: Verify metadata.json has correct name
total=$((total + 1))
meta_name=$(python3 -c "import json, sys; print(json.load(open(sys.argv[1]))['name'])" "$FAKE_ROOT/skills/test-skill/metadata.json" 2>/dev/null || echo "")
if [ "$meta_name" = "test-skill" ]; then
  echo "  PASS: metadata.json name matches skill name"
  pass=$((pass + 1))
else
  echo "  FAIL: metadata.json name is '$meta_name', expected 'test-skill'"
  fail=$((fail + 1))
fi

# Test 4: Verify commands file has YAML frontmatter
total=$((total + 1))
if head -1 "$FAKE_ROOT/skills/test-skill/commands/test-skill.md" | grep -q '^---$'; then
  echo "  PASS: commands file has YAML frontmatter"
  pass=$((pass + 1))
else
  echo "  FAIL: commands file missing YAML frontmatter"
  fail=$((fail + 1))
fi

# Test 5: Duplicate name fails
assert_fail "duplicate skill name fails" bash "$FAKE_ROOT/scripts/new-skill.sh" test-skill

# Test 6: Non-kebab-case name fails
assert_fail "CamelCase name fails" bash "$FAKE_ROOT/scripts/new-skill.sh" TestSkill
assert_fail "underscore name fails" bash "$FAKE_ROOT/scripts/new-skill.sh" test_skill

# Test 7: Valid kebab-case with numbers
total=$((total + 1))
if bash "$FAKE_ROOT/scripts/new-skill.sh" my-skill-2 > /dev/null 2>&1; then
  echo "  PASS: kebab-case with numbers succeeds"
  pass=$((pass + 1))
else
  echo "  FAIL: kebab-case with numbers should succeed"
  fail=$((fail + 1))
fi

cd "$REPO_ROOT"

echo ""
echo "Results: $pass passed, $fail failed, $total total"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
