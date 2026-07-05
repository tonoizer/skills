---
name: release-pr
description: Release pull request workflow. Use when preparing release PRs, version bumps, changelog updates, release notes, rollout/rollback plans, or asking whether a release candidate is ready.
---

# Release PR

Release work needs proof and reversibility.

## Workflow

1. Read repo release instructions, changelog, package metadata, and current CI.
2. Identify version bump, release scope, compatibility notes, and migration risk.
3. Update only release-owned files unless a release blocker requires a fix.
4. Run release verification from repo docs.
5. Create or update the PR with summary, testing, rollout, rollback, and known gaps.
6. Monitor CI with `ci-fix`.

Stop for publishing, tags, registry release, GitHub Release creation, credentials, or irreversible migrations unless the user explicitly authorizes them.
