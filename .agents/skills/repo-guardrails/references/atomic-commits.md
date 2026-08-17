# Atomic commits

An atomic commit is one reviewable outcome. It should be understandable,
revertable, and verifiable on its own.

## One outcome

Split when a diff mixes independent outcomes, for example:

- behavior change plus unrelated refactor
- feature work plus drive-by formatting
- bug fix plus changelog or docs for a different change
- lockfile or generated output unrelated to the task

Keep together when the parts are one outcome, for example a failing regression
test and the fix that makes it pass.

If the work should land as separate PRs rather than separate commits on one
branch, use `split-to-prs`.

## Message

Follow the repo's commit convention. If it uses Conventional Commits, prefer:

```text
<type>(<optional scope>): <imperative summary>
```

Common types: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `build`,
`ci`, `chore`. The summary names the outcome, not the files touched.

Do not write:

- bundled subjects (`fix login and refactor parser and update docs`)
- filler (`WIP`, `misc`, `address comments`, `updates`)
- restatements of the diff (`update file X`)

## Staging

1. `git status --short --branch`
2. `git diff` and `git diff --cached`
3. Confirm every path is in the locked scope.
4. Stage explicit paths only.
5. Run the repo's relevant verification.
6. Commit, then inspect `git show --stat` to confirm the commit stayed atomic.

Use `git-finish` for the mechanical stage, commit, and push steps after these
gates pass.

## Checker

When allowed globs are known:

```bash
.agents/skills/repo-guardrails/scripts/check-change-scope.sh \
  --allow 'src/feature/**' \
  --allow 'src/feature/**/__tests__/**'
```

The checker fails on paths outside the allow list, secret-like files, and
unresolved conflict markers. It does not invent the allow list; the agent must
pass the scope it locked from policy and the task.
