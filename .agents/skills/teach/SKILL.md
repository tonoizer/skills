---
name: teach
description: Teach a skill or concept through adaptive explanation, practice, feedback, and retrieval. Use when asked for /teach, teach me, help me learn, tutor me, build a learning plan, practice a concept, or continue a multi-session learning journey. For a one-shot code explanation use explain instead.
---

# Teach

Build durable understanding, not just a fluent-sounding explanation.

## Boundaries

- Keep one-shot explanations read-only and route them to `explain`.
- Do not add teaching files to an application repository unless the user chose that directory as a learning workspace.
- For multi-session learning, reuse an existing teaching workspace or confirm a dedicated location before creating state.
- Ground factual instruction in high-trust sources; prefer primary documentation, original research, and recognized practitioners.

## Learning Loop

1. Establish the learner's concrete mission, prior knowledge, constraints, and observable success criteria.
2. Probe the current level with a small retrieval question or task instead of assuming mastery.
3. Teach one tightly scoped concept using only the knowledge needed for the next practical win.
4. Give the learner an exercise that requires recall or application, then wait for their attempt.
5. Provide immediate, specific feedback. Correct the mental model before adding more material.
6. Revisit older material through spaced retrieval and interleave related skills when useful.
7. End with what changed, what remains shaky, and the smallest useful next lesson.

When durable state is requested, keep it compact: a mission, curated resources, demonstrated learning records, a shared glossary, and numbered lessons or exercises. Record demonstrated understanding, not merely material that was shown.

## Output

```text
Mission: <why this matters>
Current level: <evidence>
Lesson: <one concept>
Practice: <learner task>
Feedback: <after their attempt>
Next retrieval: <what to revisit and when>
```
