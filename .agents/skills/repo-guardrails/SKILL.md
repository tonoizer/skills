---
name: repo-guardrails
description: Enforce repository policy from AGENTS.md around scoped edits, atomic commits, verification, and merge gates. Use when asked for /repo-guardrails, /safe-change, /atomic-commits, stay in scope, atomic commits, check the diff before commit, or to make a coding agent follow repo rules. Do not use to write the feature itself; use implement or debug. For staging, commit, and push mechanics use git-finish. For PR CI use ci-fix or babysit.
---

# Repo Guardrails

Do not write the feature. Make every coding change follow the current repo's rules.

This skill is the enforcement layer. `AGENTS.md` (or equivalent repo instructions) is the policy. Do not hard-code language, formatter, or test commands here.

```text
AGENTS.md
  -> repo-guardrails
  -> scope check
  -> implementation (implement | debug)
  -> lint / typecheck / tests
  -> diff review
  -> safe commit
  -> CI / merge gate
```

## Load policy

Read repository instructions before editing. Prefer `AGENTS.md`, then other committed agent or contributor docs. Extract only what this repo states:

- allowed paths and task scope
- formatter, lint, typecheck, test, and CI commands
- commit message and Git safety rules
- regression-test, docs, and changelog requirements
- security, breaking-change, and human-review rules

If a rule is missing, use the smallest safe default from [policy-sources.md](references/policy-sources.md) and say so. Never invent a stack-specific workflow.

## Scope check

Before editing, name the task outcome, non-goals, and allowed paths. Reject files, refactors, and drive-by cleanup outside that scope.

Use the bundled checker when paths can be stated as globs:

```bash
.agents/skills/repo-guardrails/scripts/check-change-scope.sh --allow '<glob>'
```

Stop when the diff includes unrelated work, secrets, or conflict markers. Preserve that work; do not delete it to make the task look clean.

## Implementation gate

Hand the actual change to `implement` or `debug`. While they work:

- keep edits inside the locked scope
- require a regression test for bug fixes when the repo can express one
- update docs or changelog only when policy requires it
- do not mix unrelated outcomes in one diff

## Verify

Run the repo's own formatter, lint, typecheck, and relevant tests. Prefer the focused check for the slice, then the broader relevant command from policy. Do not skip failing checks or weaken tests to pass.

## Diff review

Review `git diff` before commit. For non-trivial or risky changes, use `code-review`. Accept only in-scope, high-confidence findings and re-verify after fixes.

## Safe commit

Require small atomic commits: one outcome per commit, conventional messages if the repo uses them, explicit paths only. Then use `git-finish` for staging, commit, and push. Never `git add .` unless every change is intended.

See [atomic-commits.md](references/atomic-commits.md).

## CI and merge

If publication is in scope, use `ci-fix` or `babysit` on the exact head. Do not merge, approve, or skip required checks unless the user explicitly authorized that action.

Escalate breaking, security, data-loss, secret, or irreversible changes to a human. See [escalation.md](references/escalation.md).

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
