---
description: Verify, stage, commit, push, and monitor CI after implementation.
argument-hint: <optional commit/push context>
---

Use `$git-finish`.

Context: $ARGUMENTS

Check the diff, run relevant verification, stage only intended files, commit or
push when appropriate, and invoke `$ci-fix` after pushing.
