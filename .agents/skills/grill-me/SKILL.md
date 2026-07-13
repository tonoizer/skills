---
name: grill-me
description: Stress-test a plan, decision, design, or idea through a focused interview. Use when asked for /grill-me, grill me, challenge my thinking, question this plan, resolve ambiguity before implementation, or walk a decision tree before acting.
---

# Grill Me

Resolve consequential decisions before action. Combine the user-facing interview and the reusable grilling discipline in this one skill.

## Rules

- Ask exactly one question at a time and wait for the answer.
- Lead each question with a recommended answer and its main tradeoff.
- Look up facts from the repository, tools, or trusted sources instead of asking the user.
- Ask only for decisions that materially change scope, behavior, risk, or success criteria.
- Follow dependencies between decisions; do not jump to downstream preferences before prerequisites are settled.
- Challenge contradictions, hidden assumptions, failure cases, non-goals, and what “done” means.
- Keep a concise decision ledger in the conversation so resolved branches stay resolved.
- Do not implement until the user confirms the shared understanding.

For a routine task with a clear verification path, skip the interview and proceed with reasonable assumptions. Grilling is a high-value checkpoint, not ceremony for every loop iteration.

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
