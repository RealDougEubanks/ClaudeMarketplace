#!/usr/bin/env bash
# run-all.sh — Run all tests in the tests/ directory.
# Usage: bash tests/run-all.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
total_errors=0

run_test() {
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

# Shell script tests
for test_script in "$SCRIPT_DIR"/test-*.sh; do
  [ -f "$test_script" ] || continue
  run_test "$(basename "$test_script")" bash "$test_script"
done

# Python tests
for test_py in "$SCRIPT_DIR"/test_*.py; do
  [ -f "$test_py" ] || continue
  run_test "$(basename "$test_py")" python3 "$test_py"
done

echo ""
echo "========================================"
if [ "$total_errors" -gt 0 ]; then
  echo " RESULT: $total_errors test suite(s) FAILED"
  echo "========================================"
  exit 1
else
  echo " RESULT: All test suites PASSED"
  echo "========================================"
  exit 0
fi
