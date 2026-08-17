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

After the scope checker passes, use `git-finish` for stage, commit, and push.
Then inspect `git show --stat` to confirm the commit stayed atomic.
