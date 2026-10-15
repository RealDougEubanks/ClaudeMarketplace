## What this pull request changes

<!-- One or two sentences. Name the skill that you added, changed, or fixed. -->

## Checks

- [ ] `./scripts/validate.sh skills/<name>` passes for each changed skill.
- [ ] The version is higher in `metadata.json`, `skills/registry.json`, `.claude-plugin/marketplace.json`, and `.claude-plugin/plugin.json`.
- [ ] `./scripts/check-registry.sh` passes.
- [ ] `./scripts/sync-versions.sh --check` passes.
- [ ] `shellcheck scripts/*.sh tests/*.sh` passes.
- [ ] `npx markdownlint-cli2 "skills/**/*.md" "*.md"` passes.
- [ ] `bash tests/run-all.sh` passes.
- [ ] Each `.scan-exempt` change has a comment that tells why the pattern is necessary.

## Tests

<!-- Tell how you tested the skill in Claude Code. -->
