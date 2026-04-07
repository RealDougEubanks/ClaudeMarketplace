# Security & Architecture Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all findings from the security review (1 critical, 2 severe, 3 moderate, 2 low, 2 info) and architecture review (1 high, 2 medium, 2 low).

**Architecture:** Direct edits to CI workflows, shell scripts, and documentation. One new script (sync-versions.sh) and one new config file (CODEOWNERS). No new dependencies.

**Tech Stack:** Bash, GitHub Actions YAML, Python 3, jq (for JSON parsing in shell)

---

### Task 1: Fix CI Script Injection Vectors (CRITICAL + 2 SEVERE)

**Files:**
- Modify: `.github/workflows/ci.yml:291-350` (label-tools job)

- [ ] **Step 1: Fix `steps.detect.outputs.tools` injection in github-script**

Replace direct `${{ }}` interpolation in JavaScript with environment variable:

```yaml
      - name: Comment tool summary on PR
        if: steps.detect.outputs.tools != ''
        uses: actions/github-script@v7
        env:
          DETECTED_TOOLS: ${{ steps.detect.outputs.tools }}
        with:
          script: |
            const tools = (process.env.DETECTED_TOOLS || '').split(',').filter(Boolean);
```

- [ ] **Step 2: Fix `github.base_ref` injection in detect step**

Pass `github.base_ref` as env var instead of inline interpolation:

```yaml
      - name: Detect tools used by changed skills
        id: detect
        env:
          BASE_REF: ${{ github.base_ref }}
        run: |
          changed_metas=$(git diff --name-only "origin/${BASE_REF}...HEAD" \
```

- [ ] **Step 3: Fix inline Python file path injection in detect step**

Pass `$meta` as a Python argument instead of string interpolation:

```bash
            skill_tools=$(python3 -c "
          import json, sys
          data = json.load(open(sys.argv[1]))
          for t in data.get('tools', []):
              print(t)
          " "$meta" 2>/dev/null || true)
```

### Task 2: Fix `eval` in validate-all.sh and tests/run-all.sh (MODERATE)

**Files:**
- Modify: `scripts/validate-all.sh:10-24`
- Modify: `tests/run-all.sh:10-22`

- [ ] **Step 1: Replace `eval` with direct invocation in validate-all.sh**

Change `run_check` to use `"$@"` instead of `eval "$cmd"`, and update all callers.

- [ ] **Step 2: Replace `eval` with direct invocation in tests/run-all.sh**

Same pattern as validate-all.sh.

### Task 3: Fix Inline Python Injection in Shell Scripts (SEVERE)

**Files:**
- Modify: `scripts/install.sh:41-56`
- Modify: `scripts/check-registry.sh:17,24-30,57-66`
- Modify: `tests/test-check-registry.sh:41`

- [ ] **Step 1: Fix install.sh — pass paths as Python args**

Replace `json.load(open('$SKILL_DIR/metadata.json'))` with `sys.argv[1]` pattern.

- [ ] **Step 2: Fix check-registry.sh — pass paths as Python args**

Three inline Python blocks need the same fix.

- [ ] **Step 3: Fix test-check-registry.sh — same pattern**

### Task 4: Fix SECURITY.md Outdated Path (LOW)

**Files:**
- Modify: `SECURITY.md:7`

- [ ] **Step 1: Update skill content path reference**

```diff
- Skill content (`skills/*/skill.md`) — prompt instructions
+ Skill content (`skills/*/commands/<name>.md`) — prompt instructions
```

### Task 5: Add CODEOWNERS (INFO)

**Files:**
- Create: `.github/CODEOWNERS`

- [ ] **Step 1: Create CODEOWNERS protecting security-sensitive paths**

### Task 6: Add .scan-exempt Change Detection to CI (MODERATE)

**Files:**
- Modify: `.github/workflows/ci.yml` (add new job after prompt-safety)

- [ ] **Step 1: Add CI job that comments on PRs when .scan-exempt files change**

### Task 7: Add Test Suite to CI (LOW)

**Files:**
- Modify: `.github/workflows/ci.yml` (add new job)

- [ ] **Step 1: Add test job that runs `bash tests/run-all.sh`**

### Task 8: Remove Legacy skill.md Fallback from scan-prompts.sh (MEDIUM)

**Files:**
- Modify: `scripts/scan-prompts.sh:207-215,222`

- [ ] **Step 1: Remove skill.md scanning from scan-prompts.sh**

Remove the fallback that scans `skill.md` and the `find` that includes `-name "skill.md"`.

### Task 9: Build Version Sync Script (HIGH)

**Files:**
- Create: `scripts/sync-versions.sh`

- [ ] **Step 1: Create sync-versions.sh**

Reads each `skills/*/metadata.json` and updates `registry.json`, `marketplace.json`, and each `plugin.json` to match.

- [ ] **Step 2: Run and verify**
