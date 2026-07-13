---
name: explain
description: Explain without changing code. Use when asked for /explain, explain this code or diff, how something works, why a design exists, teach a subsystem, trace a request or data flow, or make technical behavior understandable with repository evidence.
---

# Explain

Explain the actual system at the reader's level. Stay read-only; if the user asks for changes, finish the explanation and hand the implementation to the appropriate workflow.

## Workflow

1. Identify the subject, intended audience, and desired depth from the request; make a reasonable assumption when unspecified.
2. Read repository instructions, relevant source, nearby tests, configuration, documentation, and history when it clarifies intent.
3. Trace the real path across entrypoints, state changes, boundaries, and outputs. Distinguish verified behavior from inference.
4. Lead with a plain-language summary, then explain how it works and why it is shaped that way.
5. Use small examples, file-and-symbol references, or a compact diagram only when they materially improve understanding.
6. Call out invariants, failure modes, tradeoffs, and unknowns that affect the mental model.

For a diff, explain behavior before and after, the motivation visible in evidence, and user-facing or operational consequences. For an error, explain the causal chain rather than merely restating the message.

## Output

```text
In short: <plain-language answer>
How it works: <ordered flow>
Why: <design reason or evidence-backed inference>
Key locations: <files and symbols>
Watch for: <edge cases, tradeoffs, or unknowns>
```
