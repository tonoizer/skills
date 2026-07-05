---
name: review-pr
description: GitHub pull request lifecycle review and repair workflow. Use when asked for /review-pr, review a PR, fix PR feedback, decide if a PR is ready, inspect CI on a PR, or update an incoming contributor PR. For local-only diff review use code-review.
---

# Review PR

Treat the PR as a proposal until source, tests, and CI support it.

## Workflow

1. Read PR metadata, comments, files, commits, and checks.
2. Read repo instructions and related code/tests.
3. Use `deep-review` for root cause and fix-quality questions.
4. If changes are needed and allowed, patch the PR branch or create a replacement branch with credit.
5. Run relevant verification.
6. Use `code-review` for non-trivial changes.
7. Push fixes and invoke `ci-fix`.
8. Report ready, needs changes, blocked, or should close.

Do not approve, merge, close, or push unless the user requested that action.
