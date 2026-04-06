#!/usr/bin/env bash
# check-registry.sh — Verify registry.json is consistent with skill directories.
# Usage: ./scripts/check-registry.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REGISTRY="$REPO_ROOT/skills/registry.json"

errors=0

echo "Checking registry consistency..."
echo "---"

# 1. Validate registry.json is valid JSON
if ! python3 -c "import json; json.load(open('$REGISTRY'))" 2>/dev/null; then
  echo "ERROR: registry.json is not valid JSON."
  exit 1
fi
echo "  OK: registry.json is valid JSON"

# 2. Get skill names from registry
registry_skills=$(python3 -c "
import json
with open('$REGISTRY') as f:
    data = json.load(f)
for s in data.get('skills', []):
    print(s['name'])
" | sort)

# 3. Get skill directories (exclude templates)
dir_skills=$(find "$REPO_ROOT/skills" -mindepth 1 -maxdepth 1 -type d \
  -exec basename {} \; | sort)

# 4. Check every directory is in the registry
while IFS= read -r dir; do
  [ -z "$dir" ] && continue
  if ! echo "$registry_skills" | grep -qx "$dir"; then
    echo "  ERROR: Skill directory 'skills/$dir' is NOT in registry.json"
    errors=$((errors + 1))
  else
    echo "  OK: skills/$dir is registered"
  fi
done <<< "$dir_skills"

# 5. Check every registry entry has a directory
while IFS= read -r name; do
  [ -z "$name" ] && continue
  if [ ! -d "$REPO_ROOT/skills/$name" ]; then
    echo "  ERROR: Registry entry '$name' has no matching directory at skills/$name"
    errors=$((errors + 1))
  fi
done <<< "$registry_skills"

# 6. Check metadata name matches directory name, and registry version matches metadata version
while IFS= read -r dir; do
  [ -z "$dir" ] && continue
  meta="$REPO_ROOT/skills/$dir/metadata.json"
  if [ -f "$meta" ]; then
    meta_name=$(python3 -c "import json; print(json.load(open('$meta'))['name'])" 2>/dev/null || echo "")
    if [ "$meta_name" != "$dir" ]; then
      echo "  ERROR: skills/$dir/metadata.json name is '$meta_name', expected '$dir'"
      errors=$((errors + 1))
    fi

    # Cross-validate registry version vs metadata version
    registry_version=$(python3 -c "
import json
data = json.load(open('$REGISTRY'))
match = next((s for s in data.get('skills', []) if s['name'] == '$dir'), None)
print(match['version'] if match else '')
" 2>/dev/null || echo "")
    meta_version=$(python3 -c "import json; print(json.load(open('$meta'))['version'])" 2>/dev/null || echo "")
    if [ -n "$registry_version" ] && [ "$registry_version" != "$meta_version" ]; then
      echo "  ERROR: skills/$dir: registry.json version=\"$registry_version\" does not match metadata.json version=\"$meta_version\""
      errors=$((errors + 1))
    fi
  fi
done <<< "$dir_skills"

echo "---"
if [ "$errors" -gt 0 ]; then
  echo "FAILED: $errors error(s) found."
  exit 1
else
  echo "PASSED: Registry is consistent."
fi
