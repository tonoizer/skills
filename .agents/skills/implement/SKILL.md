---
name: implement
description: Implement a settled request, specification, plan, or issue as small verified slices and leave a review-ready diff. Use when asked for /implement, implement this, build the agreed change, execute a plan, work through a specification, or turn a ready issue into code. For ambiguous product decisions use grill-me first; for bugs use debug.
---

# Implement

Turn settled intent into the smallest complete, verified change. Do not reopen decisions already made upstream.

## Contract

Before editing, identify the requested outcome, source of truth, non-goals, affected public seams, compatibility constraints, and verification commands. Discover facts locally. Stop only when a missing owner decision would materially change the result.

## Workflow

1. Read repository instructions, the request/specification/issue, relevant architecture, and nearby tests.
2. Inspect the worktree and use a dedicated conventional branch or isolated worktree when the task owns Git state.
3. Map the smallest vertical slices that each produce observable progress.
4. For each slice, add or update a behavior-focused test first when feasible, make the minimum implementation pass, and run the focused check.
5. Run typechecking, linting, or compilation regularly when the repository provides them.
6. Avoid speculative abstractions, unrelated cleanup, and scope hidden behind “while here” changes.
7. Compare the completed diff against every requested outcome and non-goal.
8. Run the relevant full verification once, then use `code-review` for non-trivial changes and fix accepted findings.
9. Leave a clean review-ready diff. If the surrounding task explicitly includes shipping, continue through the repository's finish, PR, and PR-readiness steps.

## Output

```text
Implemented: <outcomes>
Not changed: <non-goals>
Tests: <new/updated coverage>
Verification: <commands and results>
Review: <findings handled or not needed>
State: review-ready | blocked
```
