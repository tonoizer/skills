---
name: autoresearch
description: Run bounded, hypothesis-driven experiments against a measurable engineering objective. Use when asked for /autoresearch, autonomous optimization, benchmark-driven iteration, try many alternatives, improve performance/quality/cost, or run an experiment loop. For ordinary feature work use implement; for end-to-end queue work use loop.
---

# Autoresearch

Improve one measurable objective through small, reversible experiments and
leave an evidence trail.

## When to use it

Use this for optimization problems with:

- a repeatable evaluation command or harness;
- one primary metric with a clear direction (for example, lower latency or
  higher test accuracy);
- a bounded experiment budget, time window, or stopping rule; and
- an isolated, reviewable change surface.

Good targets include benchmark speed, query latency, bundle size, prompt or
model evaluation scores, memory use, and flaky-test rates. Do not use it for
ordinary feature implementation, open-ended refactoring, or any objective
that cannot be measured reproducibly.

## Contract

Before the first experiment, make these explicit:

1. the baseline ref and exact evaluation command;
2. the primary metric, direction, and minimum meaningful improvement;
3. invariants and guardrail checks that must not regress;
4. the allowed files, dependencies, and resources; and
5. the maximum experiments, wall-clock budget, and stop conditions.

If any of these would materially change the task, ask the owner before
starting. Never modify the evaluation harness, test oracle, or data split just
to improve the score.

## Workflow

1. Read `AGENTS.md`, inspect the worktree, and preserve unrelated changes. Use
   a dedicated branch or worktree; do not experiment on the default branch.
2. Read the evaluation harness and in-scope implementation. Confirm the
   baseline passes its guardrails and record its metric, environment, commit,
   and command.
3. State one falsifiable hypothesis. Change the smallest coherent surface and
   keep the experiment independently attributable.
4. Run the focused evaluation with a timeout. Capture stdout/stderr to a log
   when output is large; retain the exact command and relevant environment.
5. Record every result, including crashes and discarded runs, with the commit,
   metric, guardrail status, resource use when relevant, and a short
   description.
6. Keep an experiment only when it beats the current best by the agreed
   threshold and passes all guardrails. Otherwise revert it cleanly before the
   next experiment. For noisy metrics, repeat the measurement using the same
   protocol before deciding. A crash is evidence about the hypothesis, not
   permission to weaken the evaluator.
7. Periodically review the log for duplicates, regressions, and diminishing
   returns. Stop at the budget, a satisfactory result, unsafe behavior, noisy
   measurements, or when the next experiment needs owner input.
8. Re-run the winning result from a clean checkout, then use `code-review` and
   the normal `git-finish`/`create-pr` workflow if publication is authorized.

Do not silently run forever, push intermediate experiments, merge, or broaden
the allowed change surface. For parallel ideas, use `worktree-agents` and keep
the same baseline and evaluator across workers.

## Result format

Maintain a compact log such as `results.tsv` or the repository’s existing
experiment format:

```text
commit  metric  status   guardrails  hypothesis/result
abc1234 120ms   keep     pass        batch database reads
def5678 135ms   discard  pass        larger cache; slower than baseline
fed9876   0     crash    n/a         allocator change; timeout
```

Finish with:

```text
Objective: <metric and direction>
Baseline: <ref and result>
Best: <ref and result>
Experiments: <kept/discarded/crashed>/<budget>
Guardrails: <proof>
State: improved | unchanged | blocked
Next: <none or the smallest follow-up>
```
