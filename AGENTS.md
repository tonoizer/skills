# Agent Skill Pack

## Purpose

Maintain a compact set of reusable agent workflow skills for general coding,
review, PR, CI, and maintainer loops.

## Rules

- Keep skill names lowercase and hyphenated.
- Keep each `SKILL.md` focused on one workflow.
- Put long examples, personal defaults, and edge-case playbooks in `references/`.
- Do not add hard-coded personal paths to main skill instructions.
- Prefer a script only when deterministic shell logic would otherwise be retyped.
- Do not edit unrelated imported skills unless the change is part of the workflow pack.

## Verify

- Run `bash -n .agents/skills/ci-fix/scripts/watch-gh-checks.sh` after editing the CI watcher.
- Run `bash -n scripts/install-user-skills.sh` after editing the installer.
- Validate every `SKILL.md` has YAML frontmatter with `name` and `description`.
- Check slash command wrappers point to existing skills.

## Finish

Report:

- Summary
- Files changed
- Commands run
- Risks or follow-ups
