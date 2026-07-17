---
name: create-pr
description: Pull request creation workflow with conventional branch naming. Use when asked for /create-pr, open a PR, create a pull request, prepare PR text, push a branch, summarize changes for review, or turn local commits into a GitHub PR.
---

# Create PR

Create a reviewable PR with proof.

## Workflow

1. Read `AGENTS.md` and check `git status --short --branch`.
2. Review the diff and confirm only intended files changed.
3. Ensure the work is on a dedicated, properly named branch. Never open related work from the default branch or a generic branch name.
4. Choose a Conventional Commit-style branch prefix that matches the primary change: `fix/<short-kebab-topic>`, `feat/<short-kebab-topic>`, `docs/<short-kebab-topic>`, `refactor/<short-kebab-topic>`, `test/<short-kebab-topic>`, `perf/<short-kebab-topic>`, `build/<short-kebab-topic>`, `ci/<short-kebab-topic>`, or `chore/<short-kebab-topic>`. Include the issue key when the repository convention requires it.
5. If the current unpublished branch name is unsuitable, create or rename it before committing. Do not rename a published/shared branch without confirming the impact.
6. Run relevant verification from repo instructions.
7. Commit with explicit paths when commits are needed.
8. Push the current branch.
9. Create the PR with the GitHub CLI (`gh`). `gh` is mandatory and must already be available. Open a PR with a Conventional Commit-style title, summary, testing, risks, and linked issue, and always assign the resolved operator in the same create step.
10. Resolve the assignee login dynamically from `gh` / git. Never hardcode a username. Accept only a real GitHub login (`^[A-Za-z0-9-]+$`); ignore API error payloads and bot identities. Prefer this order:

```bash
LOGIN=""
if candidate=$(gh api user --jq .login 2>/dev/null) \
  && [[ "$candidate" =~ ^[A-Za-z0-9-]+$ ]]; then
  LOGIN="$candidate"
elif candidate=$(gh api graphql -f query='query { viewer { login } }' --jq .data.viewer.login 2>/dev/null) \
  && [[ "$candidate" =~ ^[A-Za-z0-9-]+$ ]]; then
  LOGIN="$candidate"
elif candidate=$(gh repo view --json owner --jq .owner.login 2>/dev/null) \
  && [[ "$candidate" =~ ^[A-Za-z0-9-]+$ ]]; then
  LOGIN="$candidate"
fi

# Skip bot / automation identities
case "$LOGIN" in
  *"[bot]"*|cursor|cursoragent|"") LOGIN="" ;;
esac
```

If still empty, inspect recent default-branch commit authors via git and map the human operator to a GitHub login with `gh`. See `references/resolve-assignee.md`. Then create the PR:

```bash
gh pr create \
  --title "<conventional title>" \
  --body "$(cat <<'EOF'
## Summary
- ...

## Testing
- [ ] `<command>`

## Risks
- ...
EOF
)" \
  --assignee "$LOGIN"
```

Never leave the PR unassigned. Prefer `--assignee "$LOGIN"` on create. If the PR already exists without an assignee, run `gh pr edit --add-assignee "$LOGIN"`.
11. Read the initial PR checks and report their current state.

## PR Body

```md
## Summary
- ...

## Testing
- [ ] `<command>`

## Risks
- ...
```

Stop before pushing if the worktree contains unrelated changes or secrets.
