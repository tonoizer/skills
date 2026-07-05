---
name: maintainer-orchestrator
description: Multi-repo or multi-worker maintainer orchestration across repositories, issues, PRs, CI, releases, and worker threads. Use when asked to coordinate a portfolio, monitor workers, recover work, manage owner decisions, or run a maintainer loop. For one current repo queue use issue-triage or loop.
---

# Maintainer Orchestrator

Coordinate work; do not become the implementation thread unless the user asks
for a single-repo task in this same checkout.

## Control Plane

- Use one worker thread or one worktree per repository when implementation is needed.
- Keep this orchestrator focused on queue choice, state reconciliation, owner decisions, and final reporting.
- Read active worker state before steering, renaming, replacing, or archiving any worker.
- Never interrupt coherent active work just because another lane is waiting.
- Preserve dirty or non-default local checkouts before assigning new work.

## Startup

1. Read the newest user instruction.
2. List active repositories/workers if thread tools are available.
3. For each candidate repo, inspect `git status --short --branch`, GitHub queue, CI, and repo instructions.
4. Classify work with `issue-triage`.
5. Assign or continue exactly one coherent next action per repository.

## Execution Policy

- Autonomous: bounded bug fixes, docs, tests, CI repairs, dependency updates with clear compatibility proof, and already-approved PR cleanup.
- Needs owner: product/security/privacy/legal decisions, releases, registry publishing, unavailable credentials, destructive handling of unique work, or irreversible migrations.
- Noise: obvious spam or incoherent issues can be closed only when the user has granted that authority.

## Worker Prompt Contract

Every worker should receive:

- repo and exact issue/PR/ref;
- current user intent and repo instructions;
- allowed scope and forbidden actions;
- verification commands from `AGENTS.md`;
- requirement to run `code-review` when the diff is non-trivial;
- requirement to run `ci-fix` after push/PR update when GitHub CI applies;
- final report format: summary, files, commands, risks, next action.

## Owner Decisions

Ask only when autonomous work is exhausted. Include URL, title, plain-language
impact, proof completed, risk, recommendation, and exact choices.

## References

Read `references/peter-orchestration.md` only when the user explicitly wants
Peter/OpenClaw-style high-agency portfolio behavior.
