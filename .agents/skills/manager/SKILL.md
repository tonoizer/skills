---
name: manager
description: Manage a settled feature plan through implementation, independent review, fix rounds, and final verification by starting fresh native agent sessions and collecting their results. Use for /manager, manager mode, builder-reviewer workflows, delegated feature delivery, coordinated agent threads, or requests to stay in the main chat while Codex, Cursor, Claude Code, OpenCode, GitHub Copilot, or another coding host runs implementer and reviewer workers.
---

# Manager

Stay manager. Own the plan, handoffs, checks, and final result. Do not quietly
become the builder or reviewer.

## Start

1. Read the user request, repo instructions, current branch, and working tree.
2. Record a baseline before workers run: HEAD, staged and unstaged patches,
   status including untracked files, and hashes for untracked files. Mark which
   existing paths or hunks are in scope.
3. Write a small control brief:
   - vision and user outcome;
   - settled plan and acceptance checks;
   - scope and non-goals;
   - required tests;
   - actions that still need user approval.
4. Resolve only choices that would change the feature. Use `grill-me` when a
   real product or architecture choice is still open.
5. Read [runtime-adapters.md](references/runtime-adapters.md), choose the
   current host's native worker mechanism, and keep every worker in that host.

## Run the loop

### 1. Start a builder

Start a fresh builder or implementer session. Give it the control brief, exact
repo and ref, current state, allowed scope, repo rules, verification commands,
and the report contract below.

Use one editing worker at a time in a shared checkout. Use an isolated worktree
when editing workers must overlap. Never let two workers edit the same checkout.

Do not give an editing worker a shared dirty checkout. Prefer an isolated
working-tree snapshot that preserves the baseline. If the host cannot make one,
stop and ask for a clean ref or another safe baseline. Tell the worker not to
stage, commit, or rewrite baseline changes unless the brief explicitly includes
them.

### 2. Collect the build

Wait for the worker through the host's native status tools. Read its final
report and compare the new state to the recorded baseline. Inspect only the
worker delta and its test proof. Relay a worker question only when it needs a
real user decision; answer routine repo questions from evidence.

Do not accept "done" without checking the files or commit the worker named.

### 3. Start an independent reviewer

Start a new, read-only reviewer session. Do not reuse the builder session. Give
the reviewer the acceptance checks, repo rules, exact diff or commit, and test
results. Do not give it the builder's opinions or the manager's expected
verdict.

Require a host-enforced read-only boundary for the reviewer: scoped tools, a
read-only platform policy, or a sandbox with no write credentials and no remote
mutation access. Use an isolated checkout as another boundary, not as a
replacement. If the host cannot enforce this, stop before review. If the
reviewer writes anything, preserve the changes and treat the review as
contaminated.

Ask for findings first, with severity, file or symbol, evidence, user impact,
smallest safe fix, and missing test. Style-only notes are not blockers.

### 4. Start a fix implementer

When the reviewer finds actionable issues, start another fresh implementer
session. Give it the accepted findings and current code state. Tell it to verify
each fix and report any rejected finding with proof.

Do not send fixes back to the original builder. Fresh context keeps the repair
honest.

### 5. Re-review

Start a fresh reviewer on the new diff. Repeat the fix and review rounds while
there are supported, in-scope findings. Stop when:

- acceptance checks pass and no actionable findings remain;
- a required user decision or permission blocks progress;
- the remaining request is outside scope;
- the host cannot create or inspect native worker sessions.

Never fake a separate agent. If native worker control is missing, explain the
missing capability and ask before falling back to same-session work.

## Worker report contract

Require every worker to return:

- summary;
- files or commits changed;
- commands and test results;
- findings accepted, fixed, or rejected with proof;
- risks or blockers;
- exact next action.

Keep a small ledger of session ID, role, repo/ref, state, and result. Collect
completed results before starting the next dependent role.

## Boundaries

- Use the current product's own sessions, tasks, or subagents. Do not shell out
  to Codex, Cursor, Claude Code, OpenCode, or another competing agent.
- Do not request a model or reasoning override unless the user asks for one.
  Let the current host apply its normal worker defaults or inheritance.
- Give workers only task-needed context. Never pass secrets or hidden reasoning.
- Preserve dirty work and existing branches. Do not discard or overwrite unique
  changes.
- Keep baseline changes out of worker commits and review only the worker delta
  unless the user explicitly puts those existing changes in scope.
- Do not push, open a PR, merge, deploy, or publish unless the user requested
  that action.
- Use `create-pr` only after the reviewed implementation is ready and PR
  creation is in scope.

## Finish

Return the feature outcome, final diff or commit, verification proof, review
round result, remaining risks, and next action. Keep worker chatter out of the
final answer.
