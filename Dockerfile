FROM python:3.12-slim

LABEL org.opencontainers.image.source="https://github.com/RealDougEubanks/ClaudeMarketplace"
LABEL org.opencontainers.image.description="Skill validation tooling for the Claude Code Skills Marketplace"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       shellcheck \
       nodejs \
       npm \
       git \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir "check-jsonschema==0.29.3" \
    && npm install -g markdownlint-cli2

WORKDIR /workspace

COPY schema/   schema/
COPY scripts/  scripts/
COPY tests/    tests/

RUN chmod +x scripts/*.sh tests/*.sh

# Mount your repo at /workspace and pass a skill directory:
#   docker run --rm -v $(pwd):/workspace ghcr.io/realdougeubanks/claudemarketplace skills/my-skill
ENTRYPOINT ["bash", "scripts/validate.sh"]
