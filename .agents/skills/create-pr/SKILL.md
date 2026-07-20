---
name: create-pr
description: Pull request creation workflow with conventional branch naming. Use when asked for /create-pr, open a PR, create a pull request, prepare PR text, push a branch, summarize changes for review, or turn local commits into a GitHub PR.
---

# Create PR

Create a reviewable PR with proof.

## Workflow

1. Read `AGENTS.md` and check `git status --short --branch`.
2. Review the diff and confirm only intended files changed.
3. Ensure the work is on a dedicated branch. Never open related work from the default branch.
4. Choose a Conventional Commit-style branch name that matches the primary change: `fix/<short-kebab-topic>`, `feat/<short-kebab-topic>`, `docs/<short-kebab-topic>`, `refactor/<short-kebab-topic>`, `test/<short-kebab-topic>`, `perf/<short-kebab-topic>`, `build/<short-kebab-topic>`, `ci/<short-kebab-topic>`, or `chore/<short-kebab-topic>`. Include the issue key when the repository convention requires it.
5. **Before committing, pushing, or creating the PR, rename the branch to that proper name when the current name is unsuitable.** Unsuitable names include the default branch, `cursor/...` session branches, generic agent names, `tmp`, `wip`, or any name that does not use a conventional prefix from step 4. Rename locally first:

```bash
git branch -m <prefix>/<short-kebab-topic>
```

If the old name was already pushed and no PR exists yet, push the renamed branch and delete the old remote ref before opening the PR:

```bash
git push -u origin HEAD
git push origin --delete <old-branch-name>
```

Do not rename a published/shared branch that already has an open PR or other collaborators without confirming the impact. See `references/branch-naming.md`.
6. Run relevant verification from repo instructions.
7. Commit with explicit paths when commits are needed.
8. Push the current (already properly named) branch.
9. Create the PR with the GitHub CLI (`gh`). `gh` is mandatory and must already be available. Open a PR only after the head branch uses the conventional name from steps 4–5. Use a Conventional Commit-style title, summary, testing, risks, and linked issue, and always assign the resolved operator in the same create step.
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
