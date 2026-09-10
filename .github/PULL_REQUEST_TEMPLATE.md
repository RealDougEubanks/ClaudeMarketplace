## What this PR does

<!-- One or two sentences. What skill was added, changed, or fixed? -->

## Pre-commit checklist

- [ ] `./scripts/validate.sh skills/<name>` passes
- [ ] Version bumped in `metadata.json`, `registry.json`, `marketplace.json`, and `plugin.json`
- [ ] `./scripts/check-registry.sh` passes
- [ ] `./scripts/sync-versions.sh --check` passes
- [ ] `shellcheck scripts/*.sh tests/*.sh` clean
- [ ] `npx markdownlint-cli2 "skills/**/*.md" "*.md"` clean
- [ ] `.scan-exempt` changes reviewed and justified (if any)

## Testing

<!-- How did you test the skill locally? -->
