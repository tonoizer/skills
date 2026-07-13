---
description: Verify, stage, commit, push, and prepare an implementation handoff.
argument-hint: <optional commit/push context>
---

Use `$git-finish`.

Context: $ARGUMENTS

Check the diff, run relevant verification, stage only intended files, and
commit or push when appropriate. If a PR follows, hand off immediately; use
`$ci-fix` only for explicit branch/SHA CI work.
