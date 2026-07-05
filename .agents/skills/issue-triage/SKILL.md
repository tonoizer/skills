---
name: issue-triage
description: GitHub issue and PR triage for the current repo or a named owner/repo. Use when the user says /issue-triage, /triage, issue triage, asks what to work on, wants open issue/PR queues prioritized, needs blockers/CI/risk/proof summarized, or asks for autonomous candidates. Do not use for continuous implementation loops; use loop.
---

# Issue Triage

Default to the current GitHub repo. Broaden only when the user names an owner,
org, or says all/broad/everything.

## Current Repo

```bash
repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)
if [ -z "$repo" ]; then
  url=$(git remote get-url origin 2>/dev/null || true)
  repo=$(printf '%s\n' "$url" | sed -E 's#^git@github.com:##; s#^https://github.com/##; s#\.git$##')
fi
printf '%s\n' "$repo"
```

Read local instructions before judging:

```bash
git status --short --branch
test -f AGENTS.md && sed -n '1,220p' AGENTS.md
test -f VISION.md && sed -n '1,220p' VISION.md
```

## Queue Scan

```bash
gh issue list --repo "$repo" --state open --limit 50 \
  --json number,title,author,labels,createdAt,updatedAt,url
gh pr list --repo "$repo" --state open --limit 50 \
  --json number,title,author,isDraft,reviewDecision,mergeStateStatus,createdAt,updatedAt,url
```

Inspect details for likely candidates:

```bash
gh issue view <n> --repo "$repo" --json number,title,author,body,comments,labels,createdAt,updatedAt,url
gh pr view <n> --repo "$repo" --json number,title,author,body,comments,files,commits,isDraft,reviewDecision,mergeStateStatus,statusCheckRollup,createdAt,updatedAt,url
gh pr diff <n> --repo "$repo" --patch
```

## Classification

- `Autonomous`: bounded bug, docs, tests, CI cleanup, dependency repair, or small UX fix with a verification path.
- `Needs owner`: product direction, security/privacy decision, irreversible migration, destructive local-work handling, missing required credential, or no usable proof path.
- `Defer/close/supersede`: duplicate, stale, already fixed, invalid, or lower-quality overlapping work.

For risky or ambiguous candidates, use a narrow read-only subagent only when it
adds concrete feasibility signal.

## Output

Use URL-first cards:

```text
<url> - <title>
Class: Autonomous | Needs owner | Defer/close/supersede
Why: <one sentence>
Risk: low | medium | high - <reason>
Proof needed: <tests/CI/repro/live check>
Next: <specific action>
```

Do not mutate GitHub unless the user asked for action beyond triage.
