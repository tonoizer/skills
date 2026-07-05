---
name: create-pr
description: Pull request creation workflow. Use when asked for /create-pr, open a PR, create a pull request, prepare PR text, push a branch, summarize changes for review, or turn local commits into a GitHub PR.
---

# Create PR

Create a reviewable PR with proof.

## Workflow

1. Read `AGENTS.md` and check `git status --short --branch`.
2. Review the diff and confirm only intended files changed.
3. Run relevant verification from repo instructions.
4. Commit with explicit paths when commits are needed.
5. Push the current branch.
6. Open a PR with summary, testing, risks, and linked issue.
7. If CI runs, invoke `ci-fix` for the PR or head SHA.

## PR Body

```md
## Summary
- ...

## Testing
- [ ] `<command>`

## Risks
- ...
```

Stop before pushing if the worktree contains unrelated changes or secrets.
