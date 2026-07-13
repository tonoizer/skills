---
name: babysit
description: Keep a PR merge-ready by triaging comments, resolving clear conflicts, and fixing CI in a loop. Use when asked for /babysit, babysit a PR, stay with a PR until it is ready, handle incoming review feedback, resolve merge conflicts, repair CI failures, or repeatedly recheck a PR until it is mergeable or genuinely blocked.
---

# Babysit

Keep one pull request merge-ready through a bounded, evidence-driven loop.
Operate directly on the PR; do not invoke another workflow skill.

## Guardrails

- Read repository instructions and inspect the worktree before changing anything.
- Confirm the PR number, repository, base branch, head branch, and exact head SHA.
- Change and push only a branch the task owns. Preserve unrelated worktree changes.
- Evaluate review feedback; do not apply suggestions blindly.
- Resolve conflicts only when both sides' intent is clear.
- Never approve, merge, close, or enable auto-merge unless explicitly requested.
- Stop for missing access, ambiguous product intent, unsafe migrations, unrelated failures, or a required fix that materially expands scope.

## Loop

1. Read PR metadata, required checks, reviews, comments, unresolved review threads, and merge state. Paginate review threads when necessary.
2. Classify new work as a requested code change, valid review suggestion, CI failure, merge conflict, flaky infrastructure, or non-actionable comment.
3. Address the highest-confidence blocker with the smallest coherent change.
4. Run focused verification, then the repository's relevant broader checks.
5. Commit with a conventional commit message and push to the existing PR branch.
6. Resolve only review threads actually addressed by the pushed change.
7. Refresh the PR at its new head SHA and repeat while actionable work remains.
8. If checks or reviews are still pending, wait using the available task-wakeup mechanism or bounded polling, then recheck without producing noisy updates.

## Ready Condition

Finish only when all required checks pass, no actionable review threads or requested changes remain, the PR is conflict-free, and the current head SHA is the one verified. Otherwise report the precise blocker and evidence.

## Output

```text
PR: <url>
Head: <sha>
State: merge-ready | blocked
Handled: <reviews, failures, conflicts, or none>
Verification: <commands and results>
Remaining: <pending items or none>
```
