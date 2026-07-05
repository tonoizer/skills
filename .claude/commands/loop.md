---
description: Triage a queue, pick safe work, ship it, monitor CI, and repeat.
argument-hint: <optional repo, issue queue, or scope>
---

Use `$loop`.

Scope: $ARGUMENTS

Process one autonomous item at a time. Use subagents only for independent review
or read-only investigation when they add signal.
