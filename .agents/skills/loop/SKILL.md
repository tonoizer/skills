---
name: loop
description: Start-to-finish autonomous engineering loop for the current repository. Use when asked for /loop, keep going, take this from request to PR, work through issues, process the queue, triage and fix, stay until merge-ready, or repeatedly select safe work and ship it. For multi-repo worker coordination use maintainer-orchestrator.
---

# Loop

Own one item from selection to its authorized terminal state, then repeat.

## Run Contract

Infer the target and terminal outcome from the request: verified diff, pushed branch, merge-ready PR, merged PR, or queue exhaustion. Do not broaden authorization. Keep the exact issue/PR, branch, and head SHA visible throughout the run.

## Engine

1. Read repository instructions and inspect the worktree before changing Git state. If a merge, rebase, cherry-pick, or revert is already conflicted, preserve it and use `resolve-conflicts` before any synchronization, checkout, or branch creation.
2. Select the explicit request, specification, issue, or PR. If none is named, use `issue-triage` and pick the safest autonomous item with a clear verification path.
3. Resolve discoverable facts directly. Use `grill-me` only when an unresolved owner decision materially changes scope, behavior, or risk.
4. Preserve all unrelated work. Never use reset, clean, forced checkout, or broad restoration as loop cleanup. If the current base is dirty, use an isolated worktree or stop when isolation cannot preserve the user's state safely.
5. For new work, synchronize a clean base and create a conventional branch or isolated worktree. Route defects to `debug` and settled feature or maintenance work to `implement`. Route an existing PR to `review-pr` on its actual branch; do not create a replacement PR.
6. Run repository verification and use `code-review` for non-trivial diffs. Fix only accepted, in-scope findings and verify again.
7. Use `git-finish` to stage explicit paths, commit, and push when publication is in scope. When a PR follows, continue immediately rather than waiting on branch-only checks.
8. For unpublished work, use `create-pr` to open a reviewable PR. For an existing PR, keep its original PR and branch. In both cases, use `babysit` on the exact head until it is merge-ready or genuinely blocked.
9. Merge only when explicitly authorized. Confirm the terminal state, then return to a clean synchronized base only after proving no unrelated user work can be lost. Select the next item when the contract calls for repetition.

## Persistence

While waiting on checks, reviews, or external state, retain the current target, exact head SHA, completed proof, and next action. Recheck quietly and act only on new state. Do not restart discovery or repeat completed work.

## Stop Conditions

Stop when the contracted outcome is reached, the queue has no safe autonomous item, or a missing credential, owner decision, destructive migration, incompatible conflict, unrelated failure, or repeated external blocker prevents meaningful progress. Report the smallest decision or state change that would unblock the run.

## Output

```text
Target: <request, issue, or PR>
State: complete | merge-ready | blocked | queue-empty
Branch/head: <branch>@<sha>
Proof: <tests, review, and checks>
Published: <PR URL or none>
Next: <next item, unblocker, or none>
```
