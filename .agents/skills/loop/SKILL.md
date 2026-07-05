---
name: loop
description: Current-repo autonomous issue and PR processing loop. Use when the user says /loop, keep going, work through issues, process the queue, triage and fix, monitor CI until green, or repeatedly pick safe GitHub work and ship it. For multi-repo worker coordination use maintainer-orchestrator instead.
---

# Loop

Process one item at a time.

## Loop

1. Use `issue-triage` to classify the queue.
2. Pick the safest autonomous item with a verification path.
3. For bugs, use `bug`; for PRs, use `review-pr`; for narrow non-bug changes, follow repo instructions directly.
4. Implement in the current repo or an isolated worktree as appropriate.
5. Run repo verification.
6. Use `code-review` for non-trivial diffs.
7. Create or update the PR with `create-pr`.
8. Use `ci-fix` until green or blocked.
9. Return to a clean synchronized base before selecting the next item.

Stop when no autonomous item remains or the next step needs owner input.
