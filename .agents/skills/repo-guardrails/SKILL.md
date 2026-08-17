---
name: repo-guardrails
description: Enforce repository policy from AGENTS.md around scoped edits, atomic commits, verification, and merge gates. Use when asked for /repo-guardrails, /safe-change, /atomic-commits, stay in scope, atomic commits, check the diff before commit, or to make a coding agent follow repo rules. Do not use to write the feature itself; use implement or debug. For staging, commit, and push mechanics use git-finish. For PR CI use ci-fix or babysit.
---

# Repo Guardrails

Do not write the feature. Enforce this repo's `AGENTS.md`. Do not hard-code
formatter or test commands here.

## Gates

1. Load policy from `AGENTS.md` first. If a rule is missing, use [policy-sources.md](references/policy-sources.md) and say so.
2. Lock allowed paths and non-goals. Reject unrelated files, refactors, and drive-by cleanup.
3. Hand the change to `implement` or `debug`. Keep the locked scope.
4. Run the repo's formatter, lint, typecheck, and relevant tests. Do not skip failing checks or weaken tests to pass.
5. Review `git diff`. For non-trivial or risky changes, use `code-review`.
6. Require one outcome per commit and explicit paths. Then use `git-finish`. See [atomic-commits.md](references/atomic-commits.md).
7. If publishing, use `ci-fix` or `babysit` on the exact head. Do not merge or skip required checks unless the user authorized that. Escalate breaking, security, data-loss, secret, or irreversible work per [escalation.md](references/escalation.md).

## Scope check

Use the bundled checker when paths can be stated as globs:

```bash
.agents/skills/repo-guardrails/scripts/check-change-scope.sh --allow '<glob>'
```

Stop when the diff includes unrelated work, secrets, or conflict markers. Preserve that work; do not delete it to make the task look clean.

## Output

```text
Policy: <source files and rules used>
Scope: <allowed paths and non-goals>
Out of scope: <rejected or preserved paths>
Verification: <commands and results>
Review: <findings handled or not needed>
Commits: <atomic commit subjects or none>
CI/merge: <green, blocked, not in scope>
Escalate: <human decision or none>
```
