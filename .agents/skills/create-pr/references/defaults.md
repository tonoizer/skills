# Create PR defaults

## Operator assignee

Always assign newly created PRs to this GitHub login so the human operator owns the PR:

- `tonoizer`

Do not leave PRs unassigned. Do not assign the creating bot when the authenticated actor is automation (`cursor[bot]`, GitHub App tokens, or similar). Prefer an explicit `--assignee tonoizer` (or `gh pr edit --add-assignee tonoizer`) over `@me`.
