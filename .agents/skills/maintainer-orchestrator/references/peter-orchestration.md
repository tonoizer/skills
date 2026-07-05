# Peter/OpenClaw-Style Orchestration Notes

Use this reference only when explicitly requested. The generic
`maintainer-orchestrator` skill should not assume these defaults.

- Prefer one long-lived project worker per repository.
- Keep root orchestration separate from implementation.
- Treat contributor PRs as proposals; reproduce the need and repair or rewrite when cleaner.
- Require exact-head CI, local proof, review, and clear PR comments before landing.
- Preserve contributor credit when replacing or repairing an incoming PR.
- Escalate releases, irreversible product/security/privacy choices, missing credentials, and destructive local-work handling.
- For OpenClaw-specific work, read the repository's current maintainer docs and testing runbooks before assigning work.
