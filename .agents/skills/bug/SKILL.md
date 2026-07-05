---
name: bug
description: Bug reproduction and smallest safe fix workflow. Use when the user says /bug, bug, reproduce this, find the cause, fix failing behavior, investigate a regression, or asks for the smallest high-confidence fix with relevant tests.
---

# Bug

Goal: prove the bug, fix the cause, and avoid scope drift.

## Workflow

1. Read repo instructions and suspected files.
2. Capture the bug report, environment, expected behavior, and actual behavior.
3. Reproduce locally or explain exactly why reproduction is blocked.
4. Localize the failing path with logs, tests, call graph, or `git bisect` when useful.
5. Add or update the smallest regression test when feasible.
6. Fix the root cause at the owning boundary.
7. Run the focused test first, then the repo's relevant verification.
8. Stop if the fix needs a larger refactor, product decision, missing credential, or risky migration.

## Output

```text
Cause: <path + confidence>
Fix: <small change>
Tests: <commands/results>
Risk: <remaining uncertainty>
```
