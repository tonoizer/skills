---
name: code-review
description: Code review for local diffs, staged changes, commits, and branches. Use when asked for /code-review, review my diff, review this branch/commit, code-reviewer, test-reviewer, second opinion, adversarial review, or independent review after changes. For GitHub PR lifecycle work use review-pr; for root-cause issue/PR analysis use deep-review.
---

# Code Review

Review for correctness first. Findings lead.

## Inputs

- Local diff: `git diff --stat && git diff`
- Staged diff: `git diff --cached`
- Commit/range: `git show <sha>` or `git diff <base>...HEAD`
- GitHub PR lifecycle: use `review-pr`
- GitHub root-cause analysis: use `deep-review`

## Checklist

- Behavior matches the request and repo instructions.
- Error paths, empty states, race/concurrency, and boundary values are handled.
- Tests cover the changed behavior or the gap is explicit.
- The change fits existing ownership and patterns.
- No secrets, unsafe logging, injection, auth bypass, or broad permissions.
- No avoidable performance regressions in hot paths.

## Independent Review

For non-trivial or risky diffs, or when the user asks for a second opinion,
spawn a read-only review subagent with narrow scope. Do not use subagents for
tiny one-file obvious edits.

Prompt shape:

```text
Review the current diff only. Do not edit files.
Look for bugs, regressions, missing tests, security issues, and risky design.
Return findings first with file/line references and concrete failure modes.
If no blocking issues, say so and list residual risk.
```

Accept only high-confidence findings. After fixing accepted findings, run
relevant verification again.

## Output

Lead with findings ordered by severity:

```text
Findings:
- [P1] file:line - <concrete failure mode>

Residual risk:
- <test gap or uncertainty>
```

If no blocking issues are found, say so and name the strongest proof checked.
