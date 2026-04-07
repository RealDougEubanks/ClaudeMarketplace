#!/usr/bin/env python3
"""check-registry-metadata.py — Verify registry.json fields match metadata.json."""
import json
import sys
from pathlib import Path

registry = json.load(open("skills/registry.json"))
SYNCED_FIELDS = ["description", "version", "tags", "category"]
errors = 0

for entry in registry.get("skills", []):
    name = entry["name"]
    meta_path = Path("skills") / name / "metadata.json"
    if not meta_path.exists():
        continue
    meta = json.load(open(meta_path))
    skill_ok = True
    for field in SYNCED_FIELDS:
        meta_val = meta.get(field)
        registry_val = entry.get(field)
        if meta_val is None:
            continue
        if isinstance(meta_val, list):
            meta_val = sorted(meta_val)
            registry_val = sorted(registry_val) if isinstance(registry_val, list) else registry_val
        if registry_val != meta_val:
            print(f"::error::skills/{name}: registry.json {field}={json.dumps(entry.get(field))} "
                  f"does not match metadata.json {field}={json.dumps(meta.get(field))}")
            errors += 1
            skill_ok = False
    if skill_ok:
        print(f"  OK  {name}")

if errors:
    print(f"\nFAILED: {errors} registry/metadata mismatch(es). "
          "Update registry.json to match metadata.json.")
    sys.exit(1)
print("\nPASSED: All registry entries match their metadata.json.")
