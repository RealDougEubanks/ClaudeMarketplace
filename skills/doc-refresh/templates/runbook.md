<!--
doc: RUNBOOK
last-refreshed: YYYY-MM-DD
generated-by: doc-refresh skill
-->

# Runbook — <Service Name>

> **You were just paged. Start here.**

## Is the service alive?

```bash
# Quick health check
curl -f http://localhost:<port>/health || echo "HEALTH CHECK FAILED"

# Tail logs (last 50 lines)
<log command — docker logs / journalctl / kubectl logs / tail -n 50 /var/log/...>
```

Expected healthy response: `{ "status": "ok" }` (or equivalent — fill in the actual shape).

## Service Overview

| Property | Value |
|----------|-------|
| Port | |
| Health endpoint | `/health` |
| Log location | |
| Restart command | |
| Deployed via | |

## Start / Stop / Restart

```bash
# Start
<command>

# Stop (graceful)
<command>

# Restart
<command>
```

> **SECURITY:** If restarting due to a suspected security incident, do NOT restart in place.
> Isolate the instance first. Contact the security team before bringing it back online.

## Known Failure Modes

| Symptom | Root cause | Immediate fix |
|---------|-----------|---------------|

## Environment Variables

> **SECURITY:** Never log, print, or commit these values. Rotate immediately if exposed.

| Variable | Required | Description | Where to find it |
|----------|----------|-------------|-----------------|

## Rollback

```bash
# See recent commits
git log --oneline -10

# Revert the last commit (safe — creates a new commit)
git revert HEAD

# Or roll back a container image
docker pull <image>:<previous-tag>
```

## Escalation Path

If not resolved in 15 minutes: <CODEOWNERS contact, team Slack, or on-call rotation>
