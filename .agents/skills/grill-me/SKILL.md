---
name: grill-me
description: Stress-test a plan, decision, design, or idea through a focused interview. Use when asked for /grill-me, /grilling, grill me, challenge my thinking, question this plan, resolve ambiguity before implementation, or walk a decision tree before acting.
---

# Grill Me

Resolve consequential decisions before action. Combine Matt Pocock's
user-invoked `grill-me` entrypoint and model-invoked `grilling` discipline
into one skill. Adapted from
[mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me)
(`grill-me` + [`grilling`](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling)).

## Rules

- Interview relentlessly until shared understanding is reached; walk each
  branch of the decision tree and resolve dependencies one by one.
- Ask exactly one question at a time and wait for the answer. Multiple
  questions at once are bewildering.
- Lead each question with a recommended answer and its main tradeoff.
- Look up facts from the repository, tools, or trusted sources instead of
  asking the user. Decisions still belong to the user.
- Ask only for decisions that materially change scope, behavior, risk, or
  success criteria.
- Challenge contradictions, hidden assumptions, failure cases, non-goals, and
  what “done” means.
- Keep a concise decision ledger in the conversation so resolved branches stay
  resolved.
- Do not implement until the user confirms the shared understanding.

For a routine task with a clear verification path, skip the interview and
proceed with reasonable assumptions. Grilling is a high-value checkpoint, not
ceremony for every loop iteration.

## Completion

End with a compact contract:

```text
Goal: <outcome>
Decisions: <settled choices>
Non-goals: <explicit exclusions>
Constraints: <risk, compatibility, time, or platform boundaries>
Done when: <observable checks>
Open questions: none
```
