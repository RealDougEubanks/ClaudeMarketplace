#!/usr/bin/env bash
# test-validate.sh — Tests for scripts/validate.sh (SKILL.md layout)
# Usage: bash tests/test-validate.sh
#
# Uses self-contained fixtures; does not depend on the live skills/ tree.
# (validate-all.sh covers the real skills in CI.)

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

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FIX="$TMP/skills"

# make_skill <name> — valid single-skill fixture (SKILL.md at plugin root)
make_skill() {
  local name="$1"
  local dir="$FIX/$name"
  mkdir -p "$dir/.claude-plugin"
  cat > "$dir/SKILL.md" << EOF
---
name: $name
description: Test fixture skill.
---

# $name
EOF
  cat > "$dir/metadata.json" << EOF
{
  "name": "$name",
  "version": "1.0.0",
  "description": "Test fixture skill.",
  "author": {"name": "Test"},
  "tags": ["test"],
  "commands": ["/$name"]
}
EOF
  echo "# $name" > "$dir/README.md"
  cat > "$dir/.claude-plugin/plugin.json" << EOF
{"name": "$name", "version": "1.0.0"}
EOF
}

# Fixture 1: valid single-skill plugin
make_skill good-skill
assert_pass "valid single-skill plugin passes" "$VALIDATE" "$FIX/good-skill"

# Fixture 2: valid multi-skill plugin
make_skill multi-plugin
rm "$FIX/multi-plugin/SKILL.md"
for sub in sub-one sub-two; do
  mkdir -p "$FIX/multi-plugin/skills/$sub"
  cat > "$FIX/multi-plugin/skills/$sub/SKILL.md" << EOF
---
name: $sub
description: Test fixture sub-skill.
---

# $sub
EOF
done
python3 - "$FIX/multi-plugin/metadata.json" << 'EOF'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
d["commands"] = ["/sub-one", "/sub-two"]
json.dump(d, open(p, "w"), indent=2)
EOF
assert_pass "valid multi-skill plugin passes" "$VALIDATE" "$FIX/multi-plugin"

# Fixture 3: missing SKILL.md entirely
make_skill no-skill-md
rm "$FIX/no-skill-md/SKILL.md"
assert_fail "missing SKILL.md fails" "$VALIDATE" "$FIX/no-skill-md"

# Fixture 4: legacy commands/ directory present
make_skill legacy-skill
mkdir -p "$FIX/legacy-skill/commands"
echo "x" > "$FIX/legacy-skill/commands/legacy-skill.md"
assert_fail "legacy commands/ directory fails" "$VALIDATE" "$FIX/legacy-skill"

# Fixture 5: frontmatter name mismatch
make_skill name-mismatch
sed -i.bak 's/^name: name-mismatch/name: wrong-name/' "$FIX/name-mismatch/SKILL.md" && rm -f "$FIX/name-mismatch/SKILL.md.bak"
assert_fail "frontmatter name mismatch fails" "$VALIDATE" "$FIX/name-mismatch"

# Fixture 6: missing plugin.json
make_skill no-plugin-json
rm "$FIX/no-plugin-json/.claude-plugin/plugin.json"
assert_fail "missing plugin.json fails" "$VALIDATE" "$FIX/no-plugin-json"

# Fixture 7: metadata commands[] missing /<name>
make_skill bad-commands
python3 - "$FIX/bad-commands/metadata.json" << 'EOF'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
d["commands"] = ["/something-else"]
json.dump(d, open(p, "w"), indent=2)
EOF
assert_fail "metadata commands mismatch fails" "$VALIDATE" "$FIX/bad-commands"

# Fixture 8: missing frontmatter description
make_skill no-desc
cat > "$FIX/no-desc/SKILL.md" << 'EOF'
---
name: no-desc
---

# no-desc
EOF
assert_fail "missing frontmatter description fails" "$VALIDATE" "$FIX/no-desc"

# Fixture 9: both root SKILL.md and nested skills/*/SKILL.md
make_skill dual-layout
mkdir -p "$FIX/dual-layout/skills/extra"
cat > "$FIX/dual-layout/skills/extra/SKILL.md" << 'EOF'
---
name: extra
description: Extra nested skill.
---
EOF
assert_fail "dual root+nested layout fails" "$VALIDATE" "$FIX/dual-layout"

# Test: nonexistent directory fails
assert_fail "nonexistent skill fails" "$VALIDATE" "$FIX/nonexistent-skill-xyz"

echo ""
echo "Results: $pass passed, $fail failed, $total total"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
