---
name: git-finish
description: Finish-work git workflow. Use when asked to finish, verify, stage, commit, push, prepare handoff, or monitor CI after implementation. Do not use for code review, PR creation, or CI debugging unless those steps are explicitly next.
---

# Git Finish

Use after each meaningful implementation slice.

## Steps

1. `git status --short --branch`
2. Review `git diff` and ensure scope is intentional.
3. Run relevant verification from `AGENTS.md`.
4. Stage explicit paths only; avoid `git add .` unless every change is intended.
5. Commit with a concise message when requested or needed for PR work.
6. Push when the task involves GitHub, PRs, CI, or the user asked to publish.
7. After a push, invoke `ci-fix` unless the user requested local-only work.

Do not commit secrets, unrelated files, generated noise, or unresolved conflict markers.
