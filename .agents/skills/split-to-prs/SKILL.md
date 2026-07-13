---
name: split-to-prs
description: Split current work into small reviewable PRs. Use when asked for /split-to-prs or to split a chat, set of changes, branch, or PR; create a stacked PR series; separate refactors from behavior; or improve reviewability and landing safety without losing work.
---

# Split to PRs

Divide work by independently understandable outcomes, not arbitrary file counts.

## Guardrails

- Read repository instructions and inspect status, base, commits, diff, tests, and PR metadata.
- Treat requested work and decisions from the current chat as inputs even when some work is not committed yet.
- Create a clearly named safety branch before reconstructing committed work.
- Preserve unrelated changes and never force-push, rewrite a shared branch, close the original PR, or retarget PRs without explicit approval.
- Use conventional branch names such as `refactor/<topic>`, `feat/<topic>`, `fix/<topic>`, `test/<topic>`, or `docs/<topic>`.
- Keep each PR buildable and testable. If that is impossible, use an explicit stacked dependency.

## Plan the Series

1. Map the change into intent clusters: preparatory refactor, schema or API foundation, behavior, migration, tests, documentation, and cleanup.
2. Identify dependencies, shared files, risky seams, and commits that already form clean boundaries.
3. Prefer independent PRs from the original base. Use stacked PRs only when a later change cannot stand alone without distorting the design.
4. Give every PR one outcome, a narrow conventional title, its own verification, and a clear reason reviewers can evaluate independently.
5. Present the proposed order and dependency graph before mutation when the split is ambiguous or changes published history.

## Execute the Split

1. Create each branch from its intended base.
2. Move complete commits when clean; otherwise reconstruct the smallest coherent diff and preserve attribution in commit history where practical.
3. Add compatibility shims or tests when needed to keep intermediate states safe.
4. Verify each branch independently and compare the combined final tree with the original intended result.
5. Push and create PRs only when requested or clearly included in the splitting task. Cross-link stacked PRs and state their landing order.

## Output

```text
Original: <branch or PR>
Safety branch: <name>
PR 1: <branch> -> <base> — <outcome>
PR 2: <branch> -> <base> — <outcome>
Dependencies: <independent or ordered edges>
Verification: <per-PR commands/results>
Preservation check: <combined tree comparison>
Remaining risk: <gap or none>
```
