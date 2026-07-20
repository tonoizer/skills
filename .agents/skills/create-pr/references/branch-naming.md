# Branch naming before PR create

Never open a PR from the default branch or from a generic/session branch
name. Rename first, then push, then create the PR.

## Required shape

Use a Conventional Commit-style prefix and a short kebab topic:

- `fix/<short-kebab-topic>`
- `feat/<short-kebab-topic>`
- `docs/<short-kebab-topic>`
- `refactor/<short-kebab-topic>`
- `test/<short-kebab-topic>`
- `perf/<short-kebab-topic>`
- `build/<short-kebab-topic>`
- `ci/<short-kebab-topic>`
- `chore/<short-kebab-topic>`

Include an issue key in the topic when the repository convention requires it
(for example `fix/123-login-timeout`).

## Treat these as unsuitable

- Default branches: `main`, `master`, `trunk`, `develop`
- Agent/session branches: `cursor/...`, other machine-generated session names
- Generic placeholders: `tmp`, `temp`, `wip`, `patch`, `branch`, `head`
- Names missing a conventional prefix from the list above

## Rename before PR create

1. Pick the proper name from the current change.
2. Rename the local branch:

```bash
git branch -m feat/<short-kebab-topic>
```

3. Confirm the rename:

```bash
git status --short --branch
```

4. Push the renamed branch and set upstream:

```bash
git push -u origin HEAD
```

5. If an old unsuitable remote branch exists and no PR is open yet, delete it:

```bash
git push origin --delete <old-branch-name>
```

6. Only then run `gh pr create`.

## Already-pushed unsuitable branch, no PR yet

Safe sequence when the work is only on a remote session branch:

```bash
OLD="$(git rev-parse --abbrev-ref HEAD)"
git branch -m feat/<short-kebab-topic>
git push -u origin HEAD
git push origin --delete "$OLD"
gh pr create ...
```

## Already has an open PR

Do not silently rename a shared PR head. Keep the existing PR branch, or get
explicit approval before retargeting / replacing the PR head.
