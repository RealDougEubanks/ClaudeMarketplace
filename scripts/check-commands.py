#!/usr/bin/env python3
"""check-commands.py — Detect duplicate slash commands across skills."""
import json
import glob
import sys
from collections import defaultdict

seen = defaultdict(list)
for f in sorted(glob.glob("skills/*/metadata.json")):
    d = json.load(open(f))
    for cmd in d.get("commands", []):
        seen[cmd].append(f)

dupes = {k: v for k, v in seen.items() if len(v) > 1}
if dupes:
    for cmd, files in dupes.items():
        print(f"::error::Duplicate command {cmd} claimed by: {', '.join(files)}")
    sys.exit(1)
print(f"OK: {len(seen)} unique command(s) across {len(glob.glob('skills/*/metadata.json'))} skill(s). No duplicates.")
