---
name: deep-review
description: Deep GitHub issue/PR analysis for root cause, provenance, and fix quality. Use when asked for deep-review, root-cause review, stale-or-real review, compare fixes, or decide whether a proposed issue/PR fix is correct. For ordinary local diff review use code-review; for PR lifecycle work use review-pr.
---

# GitHub Deep Review

Use `gh` and local source first. Do not rely on issue comments alone.

## Start

```bash
gh issue view <n> --json number,title,state,author,body,comments,labels,updatedAt,url
gh pr view <n> --json number,title,state,author,body,comments,reviews,files,commits,statusCheckRollup,mergeStateStatus,headRefName,baseRefName,url
gh pr diff <n> --patch
git status --short --branch
rg "<symbol/error/route/config>"
```

Read the repo's `AGENTS.md`, test docs, and nearby tests before judging.

## Review Contract

Answer these explicitly:

- Ref: URL or issue/PR number.
- Surface: user-visible area, API, CLI, docs, infra, or tests.
- Bug or behavior: what is changing and why it matters.
- Cause: code path and confidence, or what evidence is missing.
- Provenance: introducing commit/PR when bounded history makes it clear; otherwise `unknown` or `N/A`.
- Best fix: whether the current/proposed fix is the right ownership boundary.
- Refactor: whether a larger cleanup is warranted now or should be deferred.
- Proof: tests, repro, CI, screenshots, docs, dependency source, or live behavior.
- Risk: remaining uncertainty and what would reduce it.

## Depth

Follow the real call path instead of reviewing only touched files:

- entrypoint -> validation -> owner module -> shared helper -> persistence/network boundary
- config/schema/docs -> runtime behavior -> migration/doctor/fix path
- UI event -> state update -> API call -> rendered result

For dependency behavior, verify current docs, source, types, or changelog when the contract may have changed.

## Output

Lead with findings for PR review. If no blocking issues are found, say that clearly and list residual risk.

```text
Ref: <url or #n>
Surface: <area>
Bug: <summary>
Cause: <path + confidence>
Provenance: <commit/PR/date or N/A/unknown>
Best fix: <decision>
Refactor: <yes/no + shape>
Proof: <commands/evidence>
Risk: <remaining gap>
```
