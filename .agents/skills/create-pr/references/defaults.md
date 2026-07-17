# Create PR defaults

## Operator assignee

Always assign newly created PRs to this GitHub login so the human operator owns the PR:

- `tonoizer`

Do not leave PRs unassigned. Do not assign the creating bot when the authenticated actor is automation (`cursor[bot]`, GitHub App tokens, or similar). Prefer an explicit `--assignee tonoizer` (or `gh pr edit --add-assignee tonoizer`) over `@me`.

If the token cannot assign (HTTP 403 / `Resource not accessible by integration`), surface that as a follow-up so the operator can assign manually or grant assignee permission.
