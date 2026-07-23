# Runtime Adapters

Use the adapter for the host that is running this skill. Tool names can change,
so inspect the tools exposed by the current session before acting.

## Common rule

- Stay in the current host.
- Use its native task, thread, session, or subagent control.
- Start a fresh worker for each builder, reviewer, and fix role.
- Do not request a model override. Let the host use its normal worker default or
  inheritance unless the user asks for another model.
- Use one editing worker at a time unless each worker has an isolated worktree.
- Never assign an editing worker to a shared dirty checkout. Use an isolated
  working-tree snapshot or stop for a safe baseline.
- Enforce a reviewer's read-only role with tool permissions, platform policy,
  or a sandbox without write credentials or remote mutation access. Isolation
  alone is not enough. Stop if no enforced boundary exists.
- If the host has no worker control, report that limit. Do not launch another
  coding CLI through the shell.

## Codex

Keep the main Codex task as manager. Use internal native subagents by default.
Create user-visible Codex tasks only when the user explicitly asks for new or
background tasks, as a `/manager` request may do.

- For user-visible tasks, discover the project first when project-scoped task
  creation needs a project ID.
- When the current checkout must be shared, prefer a new same-directory Codex
  task or internal subagent and run editing workers one at a time.
- Use a Codex worktree task when the user asked for visible isolated work. Pass
  the correct existing branch or working-tree state only when the worker needs
  it, record the starting baseline, and define how only its delta returns to the
  managed branch.
- Use the native thread wait/read tools to collect results and the native send
  tool for follow-ups.
- Use Codex's read-only review policy or scoped tools for reviewers. Add an
  isolated worktree when available. Stop if the current host policy still
  permits local or remote mutation.
- Do not set model or thinking fields unless the user asked for them.
- Keep task IDs and cursors in the manager ledger.

## Cursor

Use Cursor's local native Task/subagent controls exposed in the current Cursor
session. Let the parent Cursor agent remain manager. Give the reviewer a
read-only tool profile with no remote mutation access. Use a remote or cloud
background agent only when the user authorized remote work and the input is a
clean pushed ref; state whether it may push or open a PR. Do not run a headless
`cursor-agent` command from the shell to simulate a worker.

## Claude Code

Use Claude Code's native Agent/Task subagent control. Start a new agent
invocation for every role. Keep the manager in the primary conversation and
collect each subagent result before the dependent next step. Give the reviewer
a read-only tool and permission profile with no remote mutation access.

## OpenCode

Use OpenCode's native Task tool and configured subagents. If no special worker
profile exists, give a general subagent the full role prompt. Respect task and
edit permissions, and deny edit and shell-write permissions for the reviewer.
OpenCode inherits the primary model for subagents when no model override is
configured.

## GitHub Copilot

Use Copilot's local native subagent/custom-agent control when it is exposed in
the CLI, IDE, app, or SDK session. Keep work in the same Copilot runtime and
scope reviewer tools as read-only. Use a cloud coding-agent task only when the
user authorized remote work from a clean pushed ref. State that it may create a
branch or PR before starting it, then collect that result before review.

## Other hosts

Use the equivalent native worker API only when the current session exposes it
and the result can be inspected. Otherwise stop at the capability boundary and
tell the user what is missing.
