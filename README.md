# Generic Agent Workflow Skills

This repo curates compact, user-wide agent skills for an agentic coding
factory: decision sharpening, implementation, debugging, review, PR delivery,
CI repair, parallel worktrees, and maintainer orchestration.

## Skill Map

- `grill-me`: resolve consequential decisions one recommended question at a time; `/grilling` is an alias.
- `implement`: build settled work as small verified slices and leave it review-ready.
- `debug`: reproduce and fix defects using a focused debug subagent; `/bug` is an alias.
- `explain`: give a one-shot, read-only explanation from repository evidence.
- `teach`: build durable learning through explanation, practice, feedback, and retrieval.
- `readout`: turn an investigation or fresh codebase question into a durable interactive HTML guide.
- `code-review`: review a local diff, commit, branch, or PR for correctness risks.
- `resolve-conflicts`: finish an in-progress conflicted Git operation by intent.
- `create-pr`: prepare a clear, reviewable pull request on a conventional branch.
- `babysit`: keep an open PR healthy and merge-ready through review, CI, and conflicts.
- `split-to-prs`: divide current chat work, changes, a branch, or a PR into coherent PRs.
- `review-pr`: inspect an existing PR and decide whether to fix, request changes, or land.
- `release-pr`: prepare a release-oriented PR with version, changelog, and rollout proof.
- `ci-fix`: watch GitHub checks for a PR, branch, or commit and fix high-confidence failures.
- `issue-triage`: classify the current repo's issue/PR queue.
- `manager`: turn a settled feature plan into a built, reviewed, and repaired change through fresh native agent sessions.
- `loop`: own one item from request or queue selection to its authorized terminal state.
- `git-finish`: verify, stage, commit, push, and hand off finished implementation work.
- `repo-guardrails`: enforce AGENTS.md policy with scoped edits, verification, and atomic commits; `/safe-change` and `/atomic-commits` are aliases.
- `worktree-agents`: isolate parallel agent work with git worktrees.
- `humanizer`: rewrite prose to remove AI writing tells while preserving meaning.
- `simplify`: simplify ready code and comments without changing behavior.

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
- `readout`
- `humanizer`

`code-review` includes the independent read-only subagent review policy. Editing
subagents belong in isolated worktrees via `worktree-agents`.

## Loop Engineering Flow

`loop` is the orchestrator. It composes the focused skills without duplicating
their internals:

```text
request or queue
  -> repo-guardrails
  -> grill-me only for consequential unresolved decisions
  -> implement | debug | review-pr | resolve-conflicts
  -> verification + code-review
  -> git-finish + create-pr
  -> babysit until merge-ready
  -> optional authorized merge
  -> clean synchronized base, then repeat
```

`manager` is the session orchestrator for a settled feature. It keeps the main
chat in charge, starts a fresh builder, then a fresh reviewer, and sends
supported findings to a new fix implementer.

`teach`, `explain`, and `readout` are user-level learning and documentation
tools, not required stages in the engineering loop.

## Supported Agent Hosts

- **Generic** (OpenCode, etc.) read skills from `~/.agents/skills`.
- **Claude Code** reads skills from `~/.claude/skills`.
- **Cursor** reads skills from `~/.cursor/skills`.
- **Codex** reads skills from `~/.codex/skills`.
- **GitHub Copilot / VS Code** reads skills from `~/.copilot/skills`.
- The installer syncs the same skill set to all five locations so every host
  stays in sync. Keep `.agents/skills` as the source of truth.

## Source And License Notes

- Local workflow skills are licensed under [LICENCE](LICENCE).
- Sourced and source-inspired skills are tracked in
  [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
- Keep upstream license files with imported skills, for example
  `.agents/skills/frontend-design/LICENSE.txt`.

## User Install

Install or update this pack into user-wide supported-agent locations:

On macOS/Linux, use Bash:

```bash
scripts/install.sh
```

On Windows, use native PowerShell:

```powershell
.\scripts\install.ps1
```

If script execution is restricted, run it for this invocation with:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Preview changes first with either installer:

```bash
scripts/install.sh --dry-run
```

```powershell
.\scripts\install.ps1 --dry-run
```

Defaults:

- skills sync to `$HOME/.agents/skills`, `$HOME/.claude/skills`,
  `$HOME/.cursor/skills`, `$HOME/.codex/skills`, and `$HOME/.copilot/skills`;
- slash wrappers sync to `$HOME/.claude/commands`;
- only skills previously installed by this pack are pruned when removed here.

Both installers support `--dry-run`, `--skills-only`, `--commands-only`,
`--codex-only`, `--claude-only`, `--cursor-only`, `--copilot-only`,
`--no-prune`, and `-h`/`--help`.
Override the destinations with `AGENT_SKILLS_HOME`, `CLAUDE_SKILLS_HOME`,
`CLAUDE_COMMANDS_HOME`, `CURSOR_SKILLS_HOME`, `CODEX_SKILLS_HOME`, and
`COPILOT_SKILLS_HOME`.
In PowerShell, set them for the current session, for example:

```powershell
$env:AGENT_SKILLS_HOME = Join-Path $env:TEMP 'agent-skills'
$env:CLAUDE_SKILLS_HOME = Join-Path $env:TEMP 'claude-skills'
$env:CLAUDE_COMMANDS_HOME = Join-Path $env:TEMP 'claude-commands'
$env:CURSOR_SKILLS_HOME = Join-Path $env:TEMP 'cursor-skills'
$env:CODEX_SKILLS_HOME = Join-Path $env:TEMP 'codex-skills'
$env:COPILOT_SKILLS_HOME = Join-Path $env:TEMP 'copilot-skills'
.\scripts\install.ps1 --dry-run
```

## Slash Commands

The `.claude/commands` wrappers are intentionally tiny. They route common
commands such as `/manager`, `/grill-me`, `/implement`, `/debug`, `/teach`, `/readout`, `/humanizer`, `/simplify`, `/babysit`, `/create-pr`,
`/repo-guardrails`, `/safe-change`, and `/atomic-commits` to the skills above
instead of duplicating instructions.

## Maintenance Rules

- Keep `SKILL.md` files short. Put detailed examples in `references/`.
- Prefer scripts for fragile repeated shell logic.
- Avoid hard-coded personal paths in main skill bodies.
- Keep trigger descriptions specific so implicit skill selection stays cheap.
- Validate after edits:

```bash
find .agents/skills -name SKILL.md -print
bash -n .agents/skills/ci-fix/scripts/watch-gh-checks.sh
bash -n .agents/skills/repo-guardrails/scripts/check-change-scope.sh
bash -n scripts/install.sh
```
