#!/usr/bin/env bash
# scan-prompts.sh — Scan skill prompt files for potentially dangerous patterns.
#
# Usage: ./scripts/scan-prompts.sh [skill-directory|prompt-file]
#   No arguments: scans all non-README .md files under skills/
#   With argument: scans a single skill directory or file
#
# Coverage:
#   Every .md file inside a skill plugin is scanned (SKILL.md at the plugin
#   root, nested skills/*/SKILL.md in multi-skill plugins, and supporting
#   files: log-types/, templates/, rules/, etc.) — skills load and execute
#   content from supporting files at runtime, so they are prompt surface.
#   README.md files are skipped (documentation, not executed prompt content).
#
# Exemptions:
#   Skills may contain a .scan-exempt file listing patterns (one per line) that
#   are expected and reviewed. Lines starting with # are comments. Exemption
#   files are honored in the scanned file's own directory and every directory
#   up to the plugin root (the directory containing .claude-plugin/). Use this
#   for security or base skills that legitimately reference vulnerability
#   patterns.
#
# Code fences:
#   Prose outside triple-backtick (```) code blocks is scanned with the full
#   HIGH + MEDIUM pattern sets. Fenced code blocks are ALSO scanned, with a
#   focused set of destructive/exfiltration patterns (FENCE_HIGH_PATTERNS) —
#   skills put their executable bash inside fences, so fences cannot be
#   skipped, but documented workflow commands (git, install steps) would drown
#   the scan in false positives if the full prose pattern set applied there.

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

# Destructive/exfiltration patterns scanned INSIDE fenced code blocks.
# Narrower than HIGH_PATTERNS: fenced git/install commands are legitimate in
# workflow skills, but nothing inside a fence should ever pipe downloads to a
# shell or destroy the filesystem.
FENCE_HIGH_PATTERNS=(
  'curl\s[^\n]*\|\s*(ba|z)?sh'
  'wget\s[^\n]*\|\s*(ba|z)?sh'
  'base64\s[^\n]*\|\s*(ba|z)?sh'
  'nc\s+-e'
  'rm\s+-rf\s+/'
  'rm\s+-rf\s+~'
  'mkfs\.'
  'dd\s+if=/dev'
  ':\(\)\{.*\};'
  'chmod\s+777'
)

# --- PCRE matching (portable) ---
# The pattern lists above are PCRE. BSD grep on macOS does not support -P and
# fails with a usage error, which `2>/dev/null` used to hide — making the
# scanner a silent no-op on macOS. Detect a PCRE-capable matcher up front and
# fail loudly if none exists.
if echo x | grep -qP 'x' 2>/dev/null; then
  pcre_match() { grep -qiP "$1" "$2" 2>/dev/null; }
  pcre_show()  { grep -niP "$1" "$2" 2>/dev/null | head -3; }
elif command -v ggrep >/dev/null 2>&1 && echo x | ggrep -qP 'x' 2>/dev/null; then
  pcre_match() { ggrep -qiP "$1" "$2" 2>/dev/null; }
  pcre_show()  { ggrep -niP "$1" "$2" 2>/dev/null | head -3; }
elif command -v perl >/dev/null 2>&1; then
  # The `--` stops perl from parsing patterns like '--no-verify' as switches.
  pcre_match() {
    perl -e 'my ($p, $f) = @ARGV; open my $fh, "<", $f or exit 1;
             while (<$fh>) { exit 0 if /$p/i } exit 1' -- "$1" "$2"
  }
  pcre_show() {
    perl -e 'my ($p, $f) = @ARGV; open my $fh, "<", $f or exit 1;
             while (<$fh>) { print "$.:$_" if /$p/i }' -- "$1" "$2" | head -3
  }
else
  echo "Error: scan-prompts.sh needs a PCRE-capable grep (GNU grep -P, ggrep) or perl." >&2
  echo "On macOS: brew install grep" >&2
  exit 1
fi

# Emit the prose portion of a file (fenced code block bodies removed).
extract_prose() {
  local file="$1"
  awk '/^[[:space:]]*```/{in_fence=!in_fence; next} !in_fence' "$file"
}

# Emit only the fenced code block bodies of a file.
extract_fences() {
  local file="$1"
  awk '/^[[:space:]]*```/{in_fence=!in_fence; next} in_fence' "$file"
}

# Load exempted patterns for a scanned file. Honors .scan-exempt in the
# scanned file's own directory and every ancestor directory up to and
# including the plugin root (identified by a .claude-plugin/ directory).
# In a nested multi-skill plugin (skills/<plugin>/skills/<sub>/SKILL.md) this
# finds both the sub-skill's and the plugin root's exemptions. The walk is
# bounded at 8 levels; for fixtures without .claude-plugin/ it also stops at
# a directory whose parent is named "skills". Duplicates are removed.
load_exemptions() {
  local file="$1"
  local file_dir plugin_root dir depth
  file_dir=$(dirname "$file")

  # Pass 1: locate the plugin root — the nearest ancestor containing
  # .claude-plugin/. A nested sub-skill dir also has an ancestor whose parent
  # is named "skills" (the inner skills/ dir), so .claude-plugin is the only
  # reliable marker. Fixtures without .claude-plugin/ fall back to the first
  # ancestor whose parent is named "skills", else the file's own directory.
  plugin_root=""
  dir="$file_dir"
  depth=0
  while [ "$dir" != "/" ] && [ -n "$dir" ] && [ "$depth" -lt 8 ]; do
    if [ -d "$dir/.claude-plugin" ]; then
      plugin_root="$dir"
      break
    fi
    dir=$(dirname "$dir")
    depth=$((depth + 1))
  done
  if [ -z "$plugin_root" ]; then
    dir="$file_dir"
    depth=0
    while [ "$(basename "$(dirname "$dir")")" != "skills" ] \
          && [ "$dir" != "/" ] && [ -n "$dir" ] && [ "$depth" -lt 8 ]; do
      dir=$(dirname "$dir")
      depth=$((depth + 1))
    done
    if [ "$dir" = "/" ] || [ -z "$dir" ]; then
      plugin_root="$file_dir"
    else
      plugin_root="$dir"
    fi
  fi

  # Pass 2: collect .scan-exempt from the file's directory up to and
  # including the plugin root.
  {
    dir="$file_dir"
    depth=0
    while [ -n "$dir" ] && [ "$depth" -lt 8 ]; do
      if [ -f "$dir/.scan-exempt" ]; then
        grep -v '^\s*#' "$dir/.scan-exempt" | grep -v '^\s*$' || true
      fi
      [ "$dir" = "$plugin_root" ] && break
      [ "$dir" = "/" ] && break
      dir=$(dirname "$dir")
      depth=$((depth + 1))
    done
  } | sort -u
}

scan_file() {
  local file="$1"
  local file_errors=0
  local file_warnings=0
  local file_exemptions=0

  # Split the file into prose and fenced-code temp files
  local prose_file fence_file
  prose_file=$(mktemp)
  fence_file=$(mktemp)
  extract_prose "$file" > "$prose_file"
  extract_fences "$file" > "$fence_file"

  # Load exemptions for this skill
  local exemptions
  exemptions=$(load_exemptions "$file")

  # HIGH severity checks (prose)
  for pattern in "${HIGH_PATTERNS[@]}"; do
    # Skip if this pattern is listed in .scan-exempt
    if echo "$exemptions" | grep -qxF -- "$pattern" 2>/dev/null; then
      echo -e "  ${CYAN}EXEMPT${NC} [$pattern] (see .scan-exempt)"
      file_exemptions=$((file_exemptions + 1))
      continue
    fi
    if pcre_match "$pattern" "$prose_file"; then
      local match
      match=$(pcre_show "$pattern" "$prose_file")
      echo -e "  ${RED}HIGH${NC}  [$pattern]"
      # shellcheck disable=SC2001  # Multi-line prefix; ${var//search/replace} only works on first line
      echo "$match" | sed 's/^/         /'
      file_errors=$((file_errors + 1))
    fi
  done

  # HIGH severity checks (fenced code blocks — destructive/exfil subset)
  for pattern in "${FENCE_HIGH_PATTERNS[@]}"; do
    if echo "$exemptions" | grep -qxF -- "$pattern" 2>/dev/null; then
      echo -e "  ${CYAN}EXEMPT${NC} [$pattern] (see .scan-exempt)"
      file_exemptions=$((file_exemptions + 1))
      continue
    fi
    if pcre_match "$pattern" "$fence_file"; then
      local match
      match=$(pcre_show "$pattern" "$fence_file")
      echo -e "  ${RED}HIGH${NC}  [$pattern] (inside code fence)"
      # shellcheck disable=SC2001  # Multi-line prefix; ${var//search/replace} only works on first line
      echo "$match" | sed 's/^/         /'
      file_errors=$((file_errors + 1))
    fi
  done

  # MEDIUM severity checks (prose)
  for pattern in "${MEDIUM_PATTERNS[@]}"; do
    # Skip if this pattern is listed in .scan-exempt
    if echo "$exemptions" | grep -qxF -- "$pattern" 2>/dev/null; then
      echo -e "  ${CYAN}EXEMPT${NC} [$pattern] (see .scan-exempt)"
      file_exemptions=$((file_exemptions + 1))
      continue
    fi
    if pcre_match "$pattern" "$prose_file"; then
      local match
      match=$(pcre_show "$pattern" "$prose_file")
      echo -e "  ${YELLOW}MEDIUM${NC} [$pattern]"
      # shellcheck disable=SC2001  # Multi-line prefix; ${var//search/replace} only works on first line
      echo "$match" | sed 's/^/         /'
      file_warnings=$((file_warnings + 1))
    fi
  done

  rm -f "$prose_file" "$fence_file"

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
    # All .md files in the skill directory except README.md — supporting
    # files (log-types/, templates/, rules/) are runtime prompt surface too.
    mapfile -t files < <(find "$target" -name '*.md' -not -name 'README.md' -type f | sort)
    if [ ${#files[@]} -eq 0 ]; then
      echo "Error: $target has no scannable prompt files (*.md)."
      exit 1
    fi
  else
    echo "Error: $target is not a valid prompt file or skill directory."
    exit 1
  fi
else
  # Scan all skills — every non-README .md file under skills/
  mapfile -t files < <(find "$REPO_ROOT/skills" -name '*.md' -not -name 'README.md' -type f | sort)
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
