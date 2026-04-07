#!/usr/bin/env bash
# sync-versions.sh — Sync version numbers from metadata.json to all derived files.
#
# metadata.json is the single source of truth. This script updates:
#   - skills/registry.json
#   - .claude-plugin/marketplace.json
#   - skills/<name>/.claude-plugin/plugin.json
#
# Usage: ./scripts/sync-versions.sh [--check]
#   --check: exit 1 if any file is out of sync (for CI)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CHECK_ONLY=false
if [ "${1:-}" = "--check" ]; then
  CHECK_ONLY=true
fi

python3 - "$REPO_ROOT" "$CHECK_ONLY" << 'PYEOF'
import json
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
check_only = sys.argv[2].lower() == "true"
changes = 0

# Collect all metadata.json versions
skill_versions = {}
for meta_path in sorted(repo_root.glob("skills/*/metadata.json")):
    meta = json.load(open(meta_path))
    skill_versions[meta["name"]] = {
        "version": meta["version"],
        "description": meta.get("description", ""),
        "tags": meta.get("tags", []),
        "category": meta.get("category", ""),
        "path": meta_path.parent,
    }

# 1. Update registry.json
registry_path = repo_root / "skills" / "registry.json"
if registry_path.exists():
    registry = json.load(open(registry_path))
    for entry in registry.get("skills", []):
        name = entry.get("name")
        if name in skill_versions:
            sv = skill_versions[name]
            for field in ["version", "description", "tags", "category"]:
                old_val = entry.get(field)
                new_val = sv.get(field)
                if new_val and old_val != new_val:
                    if check_only:
                        print(f"  OUT OF SYNC: registry.json {name}.{field}: "
                              f"{json.dumps(old_val)} -> {json.dumps(new_val)}")
                    else:
                        print(f"  UPDATED: registry.json {name}.{field}: "
                              f"{json.dumps(old_val)} -> {json.dumps(new_val)}")
                    entry[field] = new_val
                    changes += 1
    if not check_only and changes > 0:
        with open(registry_path, "w") as f:
            json.dump(registry, f, indent=2, ensure_ascii=False)
            f.write("\n")

# 2. Update marketplace.json
mp_path = repo_root / ".claude-plugin" / "marketplace.json"
if mp_path.exists():
    mp = json.load(open(mp_path))
    for entry in mp.get("plugins", []):
        name = entry.get("name")
        if name in skill_versions:
            old_ver = entry.get("version")
            new_ver = skill_versions[name]["version"]
            if old_ver != new_ver:
                if check_only:
                    print(f"  OUT OF SYNC: marketplace.json {name}: {old_ver} -> {new_ver}")
                else:
                    print(f"  UPDATED: marketplace.json {name}: {old_ver} -> {new_ver}")
                entry["version"] = new_ver
                changes += 1
    if not check_only and changes > 0:
        with open(mp_path, "w") as f:
            json.dump(mp, f, indent=2, ensure_ascii=False)
            f.write("\n")

# 3. Update each plugin.json
for name, sv in skill_versions.items():
    plugin_path = sv["path"] / ".claude-plugin" / "plugin.json"
    if plugin_path.exists():
        plugin = json.load(open(plugin_path))
        old_ver = plugin.get("version")
        new_ver = sv["version"]
        if old_ver != new_ver:
            if check_only:
                print(f"  OUT OF SYNC: {name}/plugin.json: {old_ver} -> {new_ver}")
            else:
                print(f"  UPDATED: {name}/plugin.json: {old_ver} -> {new_ver}")
            plugin["version"] = new_ver
            changes += 1
            if not check_only:
                with open(plugin_path, "w") as f:
                    json.dump(plugin, f, indent=2, ensure_ascii=False)
                    f.write("\n")

if changes == 0:
    print("All versions are in sync.")
else:
    if check_only:
        print(f"\nFAILED: {changes} version(s) out of sync. Run ./scripts/sync-versions.sh to fix.")
        sys.exit(1)
    else:
        print(f"\nSynced {changes} version(s).")
PYEOF
