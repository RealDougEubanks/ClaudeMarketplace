#!/usr/bin/env python3
"""check-plugin-versions.py — Verify plugin.json and marketplace.json versions match metadata.json."""
import json
import sys
from pathlib import Path

errors = 0

# 1. Check each skill's .claude-plugin/plugin.json version matches metadata.json
for skill_dir in sorted(Path("skills").iterdir()):
    if not skill_dir.is_dir():
        continue
    meta_path = skill_dir / "metadata.json"
    plugin_path = skill_dir / ".claude-plugin" / "plugin.json"
    if not meta_path.exists():
        continue
    meta = json.load(open(meta_path))
    if plugin_path.exists():
        plugin = json.load(open(plugin_path))
        if plugin.get("version") != meta.get("version"):
            print(f"::error::{skill_dir.name}: plugin.json version={plugin.get('version')} "
                  f"does not match metadata.json version={meta.get('version')}")
            errors += 1
        else:
            print(f"  OK  {skill_dir.name}: plugin.json version matches")

# 2. Check marketplace.json versions match metadata.json
mp_path = Path(".claude-plugin/marketplace.json")
if mp_path.exists():
    mp = json.load(open(mp_path))
    for entry in mp.get("plugins", []):
        name = entry.get("name", "")
        meta_path = Path("skills") / name / "metadata.json"
        if not meta_path.exists():
            continue
        meta = json.load(open(meta_path))
        if entry.get("version") != meta.get("version"):
            print(f"::error::{name}: marketplace.json version={entry.get('version')} "
                  f"does not match metadata.json version={meta.get('version')}")
            errors += 1
        else:
            print(f"  OK  {name}: marketplace.json version matches")

if errors:
    print(f"\nFAILED: {errors} version mismatch(es). "
          "Update plugin.json and marketplace.json to match metadata.json.")
    sys.exit(1)
print("\nPASSED: All plugin.json and marketplace.json versions match metadata.json.")
