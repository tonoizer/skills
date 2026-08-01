---
name: maintainer-orchestrator
description: Multi-repo or multi-worker maintainer orchestration across repositories, issues, PRs, CI, releases, and worker threads. Use when asked to coordinate a portfolio, monitor workers, recover work, manage owner decisions, or run a maintainer loop. For one current repo queue use issue-triage or loop.
---

# Maintainer Orchestrator

Coordinate the portfolio; do not become the implementation thread unless the
user asks for a single-repo task in this same checkout.

## Control Plane

- Keep a bounded set of visible issue/repository lanes. Set the cap from the
  available attention and tools; count each active lane once, even when it has
  both an issue and a PR. Own the portfolio state, queue choice, lane health,
  and refill; do not let visible work grow without a bound.
- Give each issue/PR pair one canonical lane and one owner. Make that owner a
  mini-orchestrator for exactly that lane, not a second portfolio manager.
- Read active task, worker, and worktree state before steering, renaming,
  replacing, or archiving anything. Do not interrupt coherent work because
  another lane is waiting.
- Preserve dirty or non-default local checkouts before assigning new work.
- Refill a lane only after its issue reaches a terminal state (merged, closed,
  abandoned, rejected, superseded, or explicitly paused), or is blocked with a
  clear owner decision. Release the lane with its final proof, then reconcile
  state before taking the next queue item.

## Issue/PR Owner Loop

For each visible issue/PR, have its owner:

1. Reconcile the issue, PR, branch/worktree, dependencies, permissions, and
   repository instructions.
2. Plan the bounded change and prove dependency or ordering assumptions before
   implementation.
3. Hand implementation to a focused child when delegation helps; execute the
   bounded work directly when it is simpler or delegation is unavailable. Own
   the PR, independent review, CI, conflict resolution, merge, and final
   report either way.
4. Allow one fix pass by default after review. Escalate extra scope, repeated
   failure, or owner decisions instead of looping without a bound.
5. Merge only when authorization, review, exact-head proof, and required checks
   allow it; otherwise return a precise handoff and keep the lane visible.

Use a conflict resolver when synchronization conflicts appear. After merge or
an explicit terminal outcome, report the proof and release the lane for refill.

## Delegation Bounds

- Choose a short-lived subagent for a small, well-bounded role. Choose a nested
  task or isolated worktree for isolation, long-running CI/merge work, user
  visibility, or durable ownership.
- Give each child one role and a clear return point to its issue owner. Children
  must not manage unrelated issues or spawn recursively without an explicit,
  bounded reason.
- Read child/task state before steering it. Keep the issue owner accountable
  for scope, permissions, evidence, user intent, and merge even when children
  do the work.

## Startup

1. Read the newest user instruction.
2. List active repositories/workers if thread tools are available.
3. For each candidate repo, inspect `git status --short --branch`, GitHub queue, CI, and repo instructions.
4. Classify work with `issue-triage`.
5. Assign or continue exactly one coherent next action per visible issue/PR owner.

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

Keep this contract for issue owners and their children. Let explicit user
instructions override these defaults when they set a different scope, lane
policy, delegation boundary, or merge rule.

## Owner Decisions

Ask only when autonomous work is exhausted. Include URL, title, plain-language
impact, proof completed, risk, recommendation, and exact choices.

## References

Read `references/peter-orchestration.md` only when the user explicitly wants
Peter/OpenClaw-style high-agency portfolio behavior.
