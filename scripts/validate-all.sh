#!/usr/bin/env bash
# validate-all.sh — Run all validation checks across the entire marketplace.
# Usage: ./scripts/validate-all.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

total_errors=0

run_check() {
  local label="$1"
  shift
  echo ""
  echo "========================================"
  echo " $label"
  echo "========================================"
  if "$@"; then
    echo ""
  else
    total_errors=$((total_errors + 1))
  fi
}

# 1. Validate each skill's structure
for skill_dir in "$REPO_ROOT"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  run_check "Structure: $skill_name" "$SCRIPT_DIR/validate.sh" "$skill_dir"
done

# 2. Schema validation (if check-jsonschema is available)
if command -v check-jsonschema &>/dev/null; then
  for meta in "$REPO_ROOT"/skills/*/metadata.json; do
    [ -f "$meta" ] || continue
    run_check "Schema: $meta" check-jsonschema --schemafile "$REPO_ROOT/schema/metadata.schema.json" "$meta"
  done
elif command -v python3 &>/dev/null; then
  # Fallback: basic JSON validation with Python
  for meta in "$REPO_ROOT"/skills/*/metadata.json; do
    [ -f "$meta" ] || continue
    run_check "JSON: $meta" python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$meta"
  done
else
  echo ""
  echo "SKIP: No JSON schema validator found (install check-jsonschema for full validation)"
fi

# 3. Registry consistency
run_check "Registry consistency" "$SCRIPT_DIR/check-registry.sh"

# 4. Prompt safety scan
run_check "Prompt safety scan" "$SCRIPT_DIR/scan-prompts.sh"

# 5. ShellCheck (if available)
if command -v shellcheck &>/dev/null; then
  for script in "$SCRIPT_DIR"/*.sh; do
    run_check "ShellCheck: $(basename "$script")" shellcheck "$script"
  done
else
  echo ""
  echo "SKIP: shellcheck not installed (recommended: apt install shellcheck)"
fi

echo ""
echo "========================================"
if [ "$total_errors" -gt 0 ]; then
  echo " RESULT: $total_errors check(s) FAILED"
  echo "========================================"
  exit 1
else
  echo " RESULT: All checks PASSED"
  echo "========================================"
  exit 0
fi
