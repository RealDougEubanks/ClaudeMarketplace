#!/usr/bin/env python3
"""
check-version-bump.py — Verify that changed skills have bumped their version.

Rules:
  - New skills (didn't exist on base): no version bump required.
  - README.md-only changes: no version bump required.
  - Any change to skill.md or metadata.json: version must be strictly higher than on base.

Usage: python3 scripts/check-version-bump.py
Environment: BASE_REF (default: main)
"""
import json
import os
import subprocess
import sys
from pathlib import Path


def git(*args):
    result = subprocess.run(["git"] + list(args), capture_output=True, text=True, check=True)
    return result.stdout.strip()


def get_changed_skill_dirs():
    """Return set of skill names that have any changed file in this PR."""
    base_ref = os.environ.get("BASE_REF", "main")
    try:
        changed = git("diff", "--name-only", f"origin/{base_ref}...HEAD")
    except subprocess.CalledProcessError:
        print("WARNING: Could not diff against base branch. Skipping version check.")
        sys.exit(0)

    skills = set()
    for line in changed.splitlines():
        parts = Path(line).parts
        if len(parts) >= 2 and parts[0] == "skills":
            skills.add(parts[1])
    return skills


def get_base_version(skill_name):
    """Return version string from base branch, or None if skill is new."""
    base_ref = os.environ.get("BASE_REF", "main")
    try:
        raw = git("show", f"origin/{base_ref}:skills/{skill_name}/metadata.json")
        return json.loads(raw).get("version")
    except subprocess.CalledProcessError:
        return None  # Skill didn't exist on base branch


def get_current_version(skill_name):
    meta = Path("skills") / skill_name / "metadata.json"
    if not meta.exists():
        return None
    with open(meta) as f:
        return json.load(f).get("version")


def is_readme_only(skill_name):
    """Return True if only README.md changed for this skill."""
    base_ref = os.environ.get("BASE_REF", "main")
    try:
        changed = git("diff", "--name-only", f"origin/{base_ref}...HEAD",
                      "--", f"skills/{skill_name}/")
    except subprocess.CalledProcessError:
        return False
    files = [Path(f).name for f in changed.splitlines() if f.strip()]
    return len(files) > 0 and all(f == "README.md" for f in files)


def version_tuple(v):
    return tuple(int(x) for x in v.split("."))


def main():
    changed_skills = get_changed_skill_dirs()
    if not changed_skills:
        print("No skill directories changed in this PR.")
        return

    errors = 0
    checks = 0

    for skill_name in sorted(changed_skills):
        skill_dir = Path("skills") / skill_name
        if not skill_dir.is_dir():
            print(f"  SKIP {skill_name}: directory removed (deletion PR)")
            continue

        base_version = get_base_version(skill_name)
        if base_version is None:
            current = get_current_version(skill_name)
            print(f"  OK   {skill_name}: new skill at v{current}")
            continue

        if is_readme_only(skill_name):
            print(f"  OK   {skill_name}: README-only change, version bump not required")
            continue

        checks += 1
        current_version = get_current_version(skill_name)

        if current_version is None:
            print(f"  ERR  {skill_name}: metadata.json missing or has no 'version' field")
            errors += 1
            continue

        if version_tuple(current_version) <= version_tuple(base_version):
            print(f"  ERR  {skill_name}: v{base_version} → v{current_version} "
                  f"(unchanged). Bump the version in metadata.json.")
            errors += 1
        else:
            print(f"  OK   {skill_name}: v{base_version} → v{current_version}")

    print()
    if errors:
        print(f"FAILED: {errors} skill(s) have content changes but no version bump.")
        print("Update the 'version' field in the skill's metadata.json (semver, e.g. 1.0.1).")
        sys.exit(1)
    elif checks == 0:
        print("No skill content changes requiring a version bump.")
    else:
        print(f"PASSED: All {checks} changed skill(s) have bumped versions.")


if __name__ == "__main__":
    main()
