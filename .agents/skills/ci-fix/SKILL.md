---
name: ci-fix
description: GitHub CI monitor and repair loop. Use when asked for /ci-fix, /monitor-ci-and-fix, monitor CI, fix CI, wait until checks are green, poll checks for a commit/branch/PR, or after pushing a PR branch when failures should be diagnosed and fixed until green or blocked.
---

# CI Fix

Watch the exact GitHub head under test. Fix only high-confidence failures.

## Watch

Use the bundled watcher when available:

```bash
.agents/skills/ci-fix/scripts/watch-gh-checks.sh <owner/repo> <pr|branch|sha>
```

Examples:

```bash
.agents/skills/ci-fix/scripts/watch-gh-checks.sh owner/repo 123
.agents/skills/ci-fix/scripts/watch-gh-checks.sh owner/repo feature/my-branch
.agents/skills/ci-fix/scripts/watch-gh-checks.sh owner/repo 9ab5d657a8dfeb0a5dd77c61d0b2d4a6f1d41ba0
```

## Fix Loop

1. Resolve PR/branch to the current head SHA.
2. Poll check runs for that exact SHA.
3. Print only newly completed results unless state changes.
4. If all checks pass, stop green.
5. If checks fail, fetch only failing logs/details.
6. Diagnose the smallest likely fix.
7. Run relevant local verification.
8. Commit and push if the task owns the branch.
9. Watch the new head SHA.

Stop for missing credentials, unavailable logs, flaky infrastructure judgment,
destructive changes, unrelated failures, or fixes that require a larger refactor.

## Output

```text
CI: green | failed | blocked
Target: <repo>@<sha>
Failed checks: <names>
Fixes: <summary or none>
Commands: <local verification>
Risk: <remaining gap>
```
