#!/usr/bin/env bash
# scan-prompts.sh — Scan skill prompt files for potentially dangerous patterns.
#
# Usage: ./scripts/scan-prompts.sh [skill-directory|prompt-file]
#   No arguments: scans all skills in skills/
#   With argument: scans a single skill directory or file
#
# Exemptions:
#   Skills may contain a .scan-exempt file listing patterns (one per line) that
#   are expected and reviewed. Lines starting with # are comments. Use this for
#   security or base skills that legitimately reference vulnerability patterns.
#
# Code fences:
#   Content inside triple-backtick (```) code blocks is stripped before scanning,
#   since code examples are not executable prompt instructions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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
  '[~]/.ssh'
  '[~]/.aws'
  '[~]/.gnupg'
  # Requesting excessive permissions
  'dangerouslyDisableSandbox'
  'no-verify'
  '--no-verify'
)

# Strip content inside triple-backtick code fences.
# Output: cleaned text (code block bodies removed, fence markers removed).
preprocess_file() {
  local file="$1"
  awk '/^[[:space:]]*```/{in_fence=!in_fence; next} !in_fence' "$file"
}

# Load exempted patterns from .scan-exempt in the skill directory.
# If the file doesn't exist, outputs nothing.
load_exemptions() {
  local file="$1"
  local skill_dir
  skill_dir=$(dirname "$file")
  local exempt_file="$skill_dir/.scan-exempt"
  if [ -f "$exempt_file" ]; then
    grep -v '^\s*#' "$exempt_file" | grep -v '^\s*$' || true
  fi
}

scan_file() {
  local file="$1"
  local file_errors=0
  local file_warnings=0
  local file_exemptions=0

  # Pre-process: strip code fence content into a temp file
  local tmpfile
  tmpfile=$(mktemp)
  preprocess_file "$file" > "$tmpfile"

  # Load exemptions for this skill
  local exemptions
  exemptions=$(load_exemptions "$file")

  # HIGH severity checks
  for pattern in "${HIGH_PATTERNS[@]}"; do
    # Skip if this pattern is listed in .scan-exempt
    if echo "$exemptions" | grep -qxF "$pattern" 2>/dev/null; then
      echo -e "  ${CYAN}EXEMPT${NC} [$pattern] (see .scan-exempt)"
      file_exemptions=$((file_exemptions + 1))
      continue
    fi
    if grep -qiP "$pattern" "$tmpfile" 2>/dev/null; then
      local match
      match=$(grep -niP "$pattern" "$tmpfile" | head -3)
      echo -e "  ${RED}HIGH${NC}  [$pattern]"
      # shellcheck disable=SC2001  # Multi-line prefix; ${var//search/replace} only works on first line
      echo "$match" | sed 's/^/         /'
      file_errors=$((file_errors + 1))
    fi
  done

  # MEDIUM severity checks
  for pattern in "${MEDIUM_PATTERNS[@]}"; do
    # Skip if this pattern is listed in .scan-exempt
    if echo "$exemptions" | grep -qxF "$pattern" 2>/dev/null; then
      echo -e "  ${CYAN}EXEMPT${NC} [$pattern] (see .scan-exempt)"
      file_exemptions=$((file_exemptions + 1))
      continue
    fi
    if grep -qiP "$pattern" "$tmpfile" 2>/dev/null; then
      local match
      match=$(grep -niP "$pattern" "$tmpfile" | head -3)
      echo -e "  ${YELLOW}MEDIUM${NC} [$pattern]"
      # shellcheck disable=SC2001  # Multi-line prefix; ${var//search/replace} only works on first line
      echo "$match" | sed 's/^/         /'
      file_warnings=$((file_warnings + 1))
    fi
  done

  rm -f "$tmpfile"

  errors=$((errors + file_errors))
  warnings=$((warnings + file_warnings))

  if [ "$file_errors" -eq 0 ] && [ "$file_warnings" -eq 0 ]; then
    if [ "$file_exemptions" -gt 0 ]; then
      echo "  No issues found ($file_exemptions pattern(s) exempted via .scan-exempt)."
    else
      echo "  No issues found."
    fi
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
  elif [ -d "$target" ]; then
    files=()
    skill_name=$(basename "$target")
    # commands/<name>.md is the authoritative skill content file
    if [ -f "$target/commands/$skill_name.md" ]; then
      files+=("$target/commands/$skill_name.md")
    fi
    if [ ${#files[@]} -eq 0 ]; then
      echo "Error: $target has no scannable prompt files (commands/<name>.md)."
      exit 1
    fi
  else
    echo "Error: $target is not a valid prompt file or skill directory."
    exit 1
  fi
else
  # Scan all skills — commands/<name>.md files
  mapfile -t files < <(find "$REPO_ROOT/skills" -path "*/commands/*.md" -type f | sort)
fi

if [ ${#files[@]} -eq 0 ]; then
  echo "No prompt files found."
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
  echo "To exempt a pattern that is intentionally referenced, add it to"
  echo "the skill's .scan-exempt file with a comment explaining why."
  exit 1
elif [ "$warnings" -gt 0 ]; then
  echo -e "${YELLOW}WARNING: $warnings medium-severity issue(s) found. Manual review recommended.${NC}"
  exit 0
else
  echo "PASSED: No issues detected."
  exit 0
fi
