---
description: Enforce AGENTS.md policy with scoped edits, verification, and atomic commits.
argument-hint: <optional task, paths, or commit context>
---

Use `$repo-guardrails`.

Context: $ARGUMENTS

Read repository instructions first. Lock the allowed file scope, reject
unrelated changes, run the repo's formatter/lint/typecheck/tests, review the
diff, and allow only small atomic commits. Do not write the feature; hand
implementation to `$implement` or `$debug`, then `$git-finish` for commit
mechanics.
