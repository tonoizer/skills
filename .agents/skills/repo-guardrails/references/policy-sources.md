# Policy sources

Repo-guardrails enforces whatever the current repository already wrote down.
It does not carry TypeScript, Go, Python, or other stack defaults.

## Read order

1. `AGENTS.md`
2. Other committed agent instruction files (`CLAUDE.md`, `CODEX.md`, `.cursorrules`)
3. Contributor docs (`CONTRIBUTING.md`, `docs/agent.md`)
4. Nearby package or build docs only for named verification commands

Stop at the first source that answers a given rule. Later files may fill gaps,
not override a clearer `AGENTS.md` rule.

## Extract

| Rule | Look for |
| --- | --- |
| Allowed paths | owned directories, "do not edit", generated files, vendored trees |
| Verification | format, lint, typecheck, test, and CI commands |
| Commits | conventional messages, atomic/scoped commits, no `git add .` |
| Tests | regression tests for bug fixes, required suites before commit |
| Docs | README, changelog, or API doc updates after user-facing changes |
| Safety | secrets, force-push, production, migrations, human review |

Quote the repo's commands. Do not substitute a familiar toolchain.

## Safe defaults when policy is silent

Use these only when the repo does not state a rule, and report that they are
defaults:

- Touch only files required for the requested outcome.
- Stage explicit paths. Never `git add .` unless every change is intended.
- Keep one outcome per commit.
- Run the smallest relevant existing check, then any broader check the repo
  already documents.
- Add or update a regression test for bug fixes when a test harness exists.
- Do not commit secrets, credentials, conflict markers, or generated noise.
- Do not merge, approve, force-push, or skip required CI.

## What does not belong in this skill

Language-specific formatters, linters, and test runners live in the repo's
`AGENTS.md`. Personal paths, machine-local tools, and one-off defaults belong
in that repo's policy, not here.
