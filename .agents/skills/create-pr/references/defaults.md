# Create PR defaults

## Operator assignee

Always assign newly created PRs to this GitHub login:

- `tonoizer`

Use the GitHub CLI:

```bash
gh pr create --assignee tonoizer ...
# or, if the PR already exists:
gh pr edit --add-assignee tonoizer
```
