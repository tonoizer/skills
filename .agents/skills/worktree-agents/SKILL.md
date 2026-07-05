---
name: worktree-agents
description: Git worktree workflow for isolated parallel agent tasks. Use when running multiple agents, isolated experiments, parallel implementation, independent branches, or when subagents need to edit without interfering with the main worktree.
---

# Worktree Agents

Use worktrees to isolate parallel implementation.

## Create

```bash
git fetch origin
git worktree add ../<repo>-<task> -b <branch-name> origin/main
```

If the default branch is not `main`, use the repo default branch.

## Rules

- One task per worktree.
- Give the worker repo path, branch, scope, verification, and final report format.
- Never let two agents edit the same worktree.
- Keep shared credentials and production systems out of worker prompts.
- Merge only after review, verification, and CI.

## Cleanup

```bash
git worktree list
git worktree remove ../<repo>-<task>
git branch -d <branch-name>
```

Do not remove a worktree with uncommitted or unique work.
