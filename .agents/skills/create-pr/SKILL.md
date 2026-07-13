---
name: create-pr
description: Pull request creation workflow with conventional branch naming. Use when asked for /create-pr, open a PR, create a pull request, prepare PR text, push a branch, summarize changes for review, or turn local commits into a GitHub PR.
---

# Create PR

Create a reviewable PR with proof.

## Workflow

1. Read `AGENTS.md` and check `git status --short --branch`.
2. Review the diff and confirm only intended files changed.
3. Ensure the work is on a dedicated, properly named branch. Never open related work from the default branch or a generic branch name.
4. Choose a Conventional Commit-style branch prefix that matches the primary change: `fix/<short-kebab-topic>`, `feat/<short-kebab-topic>`, `docs/<short-kebab-topic>`, `refactor/<short-kebab-topic>`, `test/<short-kebab-topic>`, `perf/<short-kebab-topic>`, `build/<short-kebab-topic>`, `ci/<short-kebab-topic>`, or `chore/<short-kebab-topic>`. Include the issue key when the repository convention requires it.
5. If the current unpublished branch name is unsuitable, create or rename it before committing. Do not rename a published/shared branch without confirming the impact.
6. Run relevant verification from repo instructions.
7. Commit with explicit paths when commits are needed.
8. Push the current branch.
9. Open a PR with a Conventional Commit-style title, summary, testing, risks, and linked issue.
10. Read the initial PR checks and report their current state.

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
