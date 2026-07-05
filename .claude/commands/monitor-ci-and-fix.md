---
description: Watch GitHub CI for a PR, branch, or commit and fix high-confidence failures.
argument-hint: <owner/repo pr|branch|sha>
---

Use `$ci-fix`.

Target: $ARGUMENTS

Watch exact-head checks until green or blocked. If checks fail, inspect only the
failing details, make the smallest high-confidence fix, push, and watch the new
head.
