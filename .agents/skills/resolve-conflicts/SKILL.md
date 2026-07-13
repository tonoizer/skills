---
name: resolve-conflicts
description: Resolve an active local Git merge, rebase, cherry-pick, or revert conflict by reconstructing each side's intent and finishing the operation safely. Use when asked for /resolve-conflicts, resolve an in-progress merge conflict, fix active rebase conflicts, continue a conflicted Git operation, or repair local conflicts on an owned branch. For a PR branch conflict with its base and full PR stewardship use babysit.
---

# Resolve Conflicts

Finish the active Git operation without losing either side's intended behavior.

## Workflow

1. Read repository instructions, `git status`, the active operation state, conflicting paths, and surrounding history.
2. Identify the primary source for each side: commits, PRs, issues, tests, specifications, and nearby code.
3. Resolve each hunk by intent. Preserve both behaviors when compatible; when incompatible, choose the behavior required by the operation's stated goal and record the tradeoff.
4. Do not accept `ours` or `theirs` across a whole file unless the evidence proves the other side is obsolete.
5. Do not invent unrelated behavior, discard changes silently, or abort the operation without explicit authorization.
6. Confirm no unmerged paths remain, inspect the staged resolution, and run `git diff --check`.
7. Run focused checks for every conflicted area, then the repository's relevant broader verification.
8. Continue the merge, rebase, cherry-pick, or revert until the operation is complete. Recheck after every newly surfaced conflict.

Stop before choosing when the two intents are genuinely incompatible and the repository evidence cannot decide. Report the exact hunk, both intended behaviors, and a recommended choice.

## Output

```text
Operation: merge | rebase | cherry-pick | revert
Resolved: <paths and preserved intent>
Tradeoffs: <choices or none>
Verification: <commands and results>
State: complete | blocked
```
