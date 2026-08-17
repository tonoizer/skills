# Escalation

Stop and ask a human before landing work that policy cannot safely authorize.

## Always escalate

- secrets, credentials, private keys, or production data in the diff
- auth, permission, or sandbox bypasses
- irreversible migrations, data deletion, or destructive Git history rewrites
- force-push to a shared or default branch
- merge, approve, publish, tag, or release unless the user asked for that action
- breaking public API, schema, or protocol changes without an explicit decision
- security-sensitive dependency or toolchain upgrades

## Usually escalate

- CI required-check failures whose cause is unrelated to this change
- flaky infrastructure that would be "fixed" by weakening tests
- scope that must grow into another feature, package, or ownership area
- missing credentials or tools required for the repo's stated verification
- conflict markers or unrelated dirty work that cannot be preserved safely

## Do not escalate

Routine in-scope implementation, tests, docs required by policy, and
high-confidence CI fixes for the current head. Resolve those with `implement`,
`debug`, `git-finish`, `ci-fix`, or `babysit`.

## How to stop

Leave the tree durable. Report:

```text
Escalate: <decision needed>
Why: <rule or risk>
Evidence: <files, commands, or CI>
Safe next step: <smallest owner action>
```

Do not hide the risk behind a commit, skip a required check, or delete
unrelated user work to proceed.
