---
name: humanizer
description: >-
  Remove signs of AI-generated writing from text so it sounds natural and
  human-written. Use when asked for /humanizer, humanize this, make this sound
  less AI, strip AI writing patterns, or edit prose against Wikipedia's Signs of
  AI writing guide (significance inflation, AI vocabulary, em dashes, rule of
  three, filler, chatbot artifacts, and related tells).
---

# Humanizer

Rewrite text to remove AI writing tells while preserving meaning, coverage, and
the intended voice. Pattern catalog and worked example live in
[references/ai-writing-patterns.md](references/ai-writing-patterns.md). Based on
[Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
via [blader/humanizer](https://github.com/blader/humanizer).

## Workflow

1. Read the target text (and any voice sample the user provides).
2. Read [references/ai-writing-patterns.md](references/ai-writing-patterns.md)
   and scan for clusters of AI tells, not isolated false positives.
3. Draft a rewrite that replaces AI-isms instead of deleting content. Keep
   roughly the same coverage and paragraph count.
4. Preserve meaning and match the intended register (formal, casual, technical).
5. Ask: "What makes the below so obviously AI generated?" List remaining tells.
6. Produce a final rewrite that clears those tells.

Hard constraint: the final rewrite must contain no em dashes (`—`) or en dashes
(`–`). Replace with periods, commas, colons, parentheses, or restructure.

## Voice calibration

If the user provides a writing sample:

- Note sentence length, word choice, paragraph openings, punctuation habits,
  recurring phrases, and transition style.
- Match those patterns in the rewrite rather than producing generic "clean"
  prose.

If no sample is provided, use a natural varied voice. Add personality only when
the content calls for it (blog, essay, opinion, personal). For encyclopedic,
technical, legal, or reference text, stay neutral and plain.

## Personality (when voice is wanted)

Sterile, evenly paced, opinion-free prose can read as AI even after pattern
cleanup. Prefer mixed sentence length, concrete detail, and honest uncertainty
over polished neutrality. Do not inject first person or humor into text that
should stay impersonal.

## Output

Deliver:

1. Draft rewrite
2. Brief "still AI" bullets from the audit question
3. Final rewrite
4. Optional short summary of changes

Do not leave chatbot framing ("I hope this helps", "Would you like...") in the
rewritten content.
