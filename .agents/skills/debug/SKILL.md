---
name: debug
description: Debug and fix using a focused debug subagent. Use when asked for /debug, /bug, debug this, reproduce or fix a bug, investigate an error, determine why something fails, inspect logs or runtime behavior, isolate a regression, or repair a hard-to-localize defect.
---

# Debug

Turn symptoms into a reproducible cause with independent evidence, then make the smallest verified fix.
This is the canonical bug workflow; `/bug` is an alias rather than a separate overlapping skill.

## Debug Subagent

Spawn a focused debug subagent for non-trivial failures. Give it the raw symptom, reproduction details, repository instructions, and the narrow investigation scope. Ask it to stay read-only, test competing hypotheses, and return the causal chain with file and symbol references. Do not leak a suspected answer into its prompt.

Prompt shape:

```text
Debug this failure without editing files. Reproduce it if safe, test competing
hypotheses, and return the root cause, evidence, confidence, and smallest fix shape.
```

Continue locally if subagents are unavailable or the failure is trivial. Validate the subagent's conclusion against source and reproduction evidence before accepting it.

## Workflow

1. Read repository instructions and capture the symptom, expected result, actual result, environment, frequency, and last-known-good state.
2. Reproduce with the smallest reliable command or scenario. Preserve the original error and relevant versions.
3. Delegate the independent investigation to the debug subagent while inspecting the failing path locally.
4. Form and test a short list of falsifiable hypotheses ordered by likelihood and cost.
5. Add temporary observability only when existing logs, tests, traces, or state inspection cannot discriminate between hypotheses.
6. Narrow the path across inputs, control flow, state, concurrency, external boundaries, and outputs. Compare working and failing cases.
7. Reconcile the subagent report with local evidence. Reject conclusions without a demonstrated causal link.
8. Add a regression test when feasible and make the smallest fix at the owning boundary.
9. Remove temporary instrumentation, run focused then relevant broader verification, and report the result.

Do not treat warnings, correlation, or the last changed line as the cause without a causal link. Stop when reproduction would risk production data, credentials are unavailable, or the remaining question requires a product decision.

## Output

```text
Symptom: <observed failure>
Reproduction: <command or scenario>
Cause: <causal chain and location>
Confidence: high | medium | low
Evidence: <tests, logs, trace, or history>
Fix: <smallest change>
Verification: <commands and results>
```
