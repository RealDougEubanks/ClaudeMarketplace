#!/usr/bin/env bash
# scan-prompts.sh — Scan skill.md files for potentially dangerous prompt patterns.
# Usage: ./scripts/scan-prompts.sh [skill-directory|skill.md]
#   No arguments: scans all skills in skills/
#   With argument: scans a single skill directory or file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

warnings=0
errors=0

# --- Pattern definitions ---

# HIGH severity: patterns that strongly suggest malicious or dangerous intent
HIGH_PATTERNS=(
  # Data exfiltration
  'curl\s.*\$'
  'wget\s.*\$'
  'curl\s+https?://'
  'wget\s+https?://'
  'nc\s+-'
  'netcat'
  # Credential / secret access
  '\.env\b'
  'credentials'
  'api[_-]?key'
  'secret[_-]?key'
  'access[_-]?token'
  'private[_-]?key'
  'password'
  'AWS_SECRET'
  'GITHUB_TOKEN'
  'ANTHROPIC_API_KEY'
  # Destructive commands
  'rm\s+-rf\s+/'
  'rm\s+-rf\s+~'
  'rm\s+-rf\s+\$HOME'
  'mkfs\.'
  'dd\s+if='
  ':(){.*};'
  'chmod\s+777'
  # Git destructive
  'git\s+push\s+--force'
  'git\s+push\s+-f\b'
  'git\s+reset\s+--hard'
  'git\s+clean\s+-fd'
  # Prompt injection / override attempts
  'ignore\s+(all\s+)?previous\s+instructions'
  'ignore\s+(all\s+)?prior\s+instructions'
  'ignore\s+(all\s+)?above\s+instructions'
  'disregard\s+(all\s+)?previous'
  'you\s+are\s+now\s+in\s+.*mode'
  'enter\s+.*mode'
  'override\s+safety'
  'bypass\s+safety'
  'jailbreak'
  'DAN\s+mode'
)

# MEDIUM severity: patterns that are suspicious and warrant review
MEDIUM_PATTERNS=(
  # Encoded content (could hide malicious instructions)
  'base64'
  'eval\s*\('
  'eval\s+"'
  "eval\s+'"
  '\$\(.*\$\(.*\)\)'
  # Network access
  'ssh\s+'
  'scp\s+'
  'ftp\s+'
  # Process/system manipulation
  'kill\s+-9'
  'pkill'
  'sudo\b'
  'chmod\s+[0-7]{3}'
  'chown\b'
  # File system sensitive paths
  '/etc/passwd'
  '/etc/shadow'
  '~/.ssh'
  '~/.aws'
  '~/.gnupg'
  # Requesting excessive permissions
  'dangerouslyDisableSandbox'
  'no-verify'
  '--no-verify'
)

scan_file() {
  local file="$1"
  local file_errors=0
  local file_warnings=0

  # HIGH severity checks
  for pattern in "${HIGH_PATTERNS[@]}"; do
    if grep -qiP "$pattern" "$file" 2>/dev/null; then
      local match
      match=$(grep -niP "$pattern" "$file" | head -3)
      echo -e "  ${RED}HIGH${NC}  [$pattern]"
      echo "$match" | sed 's/^/         /'
      file_errors=$((file_errors + 1))
    fi
  done

  # MEDIUM severity checks
  for pattern in "${MEDIUM_PATTERNS[@]}"; do
    if grep -qiP "$pattern" "$file" 2>/dev/null; then
      local match
      match=$(grep -niP "$pattern" "$file" | head -3)
      echo -e "  ${YELLOW}MEDIUM${NC} [$pattern]"
      echo "$match" | sed 's/^/         /'
      file_warnings=$((file_warnings + 1))
    fi
  done

  errors=$((errors + file_errors))
  warnings=$((warnings + file_warnings))

  if [ "$file_errors" -eq 0 ] && [ "$file_warnings" -eq 0 ]; then
    echo "  No issues found."
  fi
}

echo "========================================"
echo " Claude Skills Marketplace — Prompt Safety Scanner"
echo "========================================"
echo ""

if [ $# -gt 0 ]; then
  # Scan a specific target
  target="$1"
  if [ -f "$target" ]; then
    files=("$target")
  elif [ -d "$target" ] && [ -f "$target/skill.md" ]; then
    files=("$target/skill.md")
  else
    echo "Error: $target is not a valid skill.md file or skill directory."
    exit 1
  fi
else
  # Scan all skills
  mapfile -t files < <(find "$REPO_ROOT/skills" -name "skill.md" -type f | sort)
fi

if [ ${#files[@]} -eq 0 ]; then
  echo "No skill.md files found."
  exit 0
fi

for file in "${files[@]}"; do
  echo "Scanning: $file"
  scan_file "$file"
  echo ""
done

echo "========================================"
echo "Summary: $errors HIGH, $warnings MEDIUM"
echo "========================================"

if [ "$errors" -gt 0 ]; then
  echo -e "${RED}FAILED: $errors high-severity issue(s) require review before merge.${NC}"
  exit 1
elif [ "$warnings" -gt 0 ]; then
  echo -e "${YELLOW}WARNING: $warnings medium-severity issue(s) found. Manual review recommended.${NC}"
  exit 0
else
  echo "PASSED: No issues detected."
  exit 0
fi
