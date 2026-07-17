# Resolve PR assignee

Never hardcode a GitHub username. Resolve the assignee from the local
`gh` / git environment each time.

## Preferred order

1. `gh api user --jq .login`
2. `gh api graphql -f query='query { viewer { login } }' --jq .data.viewer.login`
3. `gh repo view --json owner --jq .owner.login` when the owner is a user
4. Recent default-branch commit authors from git (`git log`), then map to a
   GitHub login with `gh` when the author is clearly the human operator

## Skip these identities

- Logins ending in `[bot]`
- Automation placeholders such as `cursor`, `cursoragent`, or similar
  machine accounts that are only present because an agent token is active

## Apply with gh

```bash
gh pr create --assignee "$LOGIN" ...
# or, if the PR already exists:
gh pr edit --add-assignee "$LOGIN"
```

Do not use `--assignee @me` when the authenticated actor is an automation
identity; resolve the human login instead.
