# Generic Agent Workflow Skills

This repo curates compact, user-wide agent skills for an agentic coding
factory: decision sharpening, implementation, debugging, review, PR delivery,
CI repair, parallel worktrees, and maintainer orchestration.

## Skill Map

- `grill-me`: resolve consequential decisions one recommended question at a time; `/grilling` is an alias.
- `implement`: build settled work as small verified slices and leave it review-ready.
- `autoresearch`: improve a measurable objective through bounded, hypothesis-driven experiments.
- `debug`: reproduce and fix defects using a focused debug subagent; `/bug` is an alias.
- `explain`: give a one-shot, read-only explanation from repository evidence.
- `teach`: build durable learning through explanation, practice, feedback, and retrieval.
- `code-review`: review a local diff, commit, branch, or PR for correctness risks.
- `resolve-conflicts`: finish an in-progress conflicted Git operation by intent.
- `create-pr`: prepare a clear, reviewable pull request on a conventional branch.
- `babysit`: keep an open PR healthy and merge-ready through review, CI, and conflicts.
- `split-to-prs`: divide current chat work, changes, a branch, or a PR into coherent PRs.
- `review-pr`: inspect an existing PR and decide whether to fix, request changes, or land.
- `release-pr`: prepare a release-oriented PR with version, changelog, and rollout proof.
- `ci-fix`: watch GitHub checks for a PR, branch, or commit and fix high-confidence failures.
- `issue-triage`: classify the current repo's issue/PR queue.
- `loop`: own one item from request or queue selection to its authorized terminal state.
- `git-finish`: verify, stage, commit, push, and hand off finished implementation work.
- `worktree-agents`: isolate parallel agent work with git worktrees.

Imported or source-inspired skills kept here:

- `agent-browser`
- `find-skills`
- `frontend-design`
- `deep-review`
- `maintainer-orchestrator`
- `grill-me`
- `implement`
- `resolve-conflicts`
- `teach`
- `autoresearch`

`code-review` includes the independent read-only subagent review policy. Editing
subagents belong in isolated worktrees via `worktree-agents`.

## Loop Engineering Flow

`loop` is the orchestrator. It composes the focused skills without duplicating
their internals:

```text
request or queue
  -> grill-me only for consequential unresolved decisions
  -> implement | autoresearch | debug | review-pr | resolve-conflicts
  -> verification + code-review
  -> git-finish + create-pr
  -> babysit until merge-ready
  -> optional authorized merge
  -> clean synchronized base, then repeat
```

`teach` and `explain` are user-level learning tools, not required stages in the
engineering loop.

`autoresearch` is the optimization specialist inside the loop: use it when
there is a reproducible metric and a bounded experiment budget. It adds a
baseline, one-hypothesis-at-a-time iteration, result logging, guardrails, and
reversible keep/revert decisions. It does not replace `implement` for feature
work or `loop` for end-to-end task ownership.

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
commands such as `/grill-me`, `/implement`, `/autoresearch`, `/debug`, `/teach`, `/babysit`, and `/create-pr` to
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
