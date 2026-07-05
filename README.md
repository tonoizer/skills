# Generic Agent Workflow Skills

This repo curates compact, user-wide agent skills for an agentic coding
factory: issue triage, bug fixing, PR review, CI repair, parallel worktrees,
and maintainer orchestration.

## Skill Map

- `bug`: reproduce and fix bugs with the smallest high-confidence patch.
- `code-review`: review a local diff, commit, branch, or PR for correctness risks.
- `create-pr`: prepare a clear, reviewable pull request.
- `review-pr`: inspect an existing PR and decide whether to fix, request changes, or land.
- `release-pr`: prepare a release-oriented PR with version, changelog, and rollout proof.
- `ci-fix`: watch GitHub checks for a PR, branch, or commit and fix high-confidence failures.
- `issue-triage`: classify the current repo's issue/PR queue.
- `loop`: process safe issue/PR work one item at a time until green or blocked.
- `git-finish`: verify, stage, commit, push, and monitor CI after implementation.
- `worktree-agents`: isolate parallel agent work with git worktrees.

Imported or source-inspired skills kept here:

- `agent-browser`
- `find-skills`
- `frontend-design`
- `deep-review`
- `maintainer-orchestrator`

`code-review` includes the independent read-only subagent review policy. Editing
subagents belong in isolated worktrees via `worktree-agents`.

## Codex And Claude Code

- Codex reads the canonical skills from `.agents/skills`.
- Claude Code reads the same skills through `.claude/skills`, which points to
  the canonical `.agents/skills` directory.
- Keep `.agents/skills` as the source of truth so the two clients do not drift.

## Source And License Notes

- Local workflow skills are licensed under [LICENCE](LICENCE).
- Sourced and source-inspired skills are tracked in
  [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
- Keep upstream license files with imported skills, for example
  `.agents/skills/frontend-design/LICENSE.txt`.

## User Install

Install or update this pack into user-wide Codex and Claude Code locations:

```bash
scripts/install-user-skills.sh
```

Preview changes first:

```bash
scripts/install-user-skills.sh --dry-run
```

Defaults:

- skills sync to `$HOME/.agents/skills` and `$HOME/.claude/skills`;
- slash wrappers sync to `$HOME/.claude/commands`;
- only skills previously installed by this pack are pruned when removed here.

## Slash Commands

The `.claude/commands` wrappers are intentionally tiny. They route common
commands such as `/bug`, `/loop`, `/create-pr`, and `/ci-fix` to
the skills above instead of duplicating instructions.

## Maintenance Rules

- Keep `SKILL.md` files short. Put detailed examples in `references/`.
- Prefer scripts for fragile repeated shell logic.
- Avoid hard-coded personal paths in main skill bodies.
- Keep trigger descriptions specific so implicit skill selection stays cheap.
- Validate after edits:

```bash
find .agents/skills -name SKILL.md -print
bash -n .agents/skills/ci-fix/scripts/watch-gh-checks.sh
bash -n scripts/install-user-skills.sh
```
