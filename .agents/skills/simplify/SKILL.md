---
name: simplify
description: Use this skill when code is ready for human review, or when writing or reviewing code comments. Confirm the code works and meets its goal before simplifying it without changing behavior.
---

Review changes in the current branch, or in the scope the user names. Apply these
rules without changing behavior. Only touch code in that scope. Run the relevant
existing checks after changes.

## Word choice in code and comments

Variable names, function names, and comments are prose. Use short, plain words:

- Use a short word when it works.
- Cut words the context already carries.
- Use active voice.
- Avoid jargon when an everyday word is clear.

### Names

1. Use one word per concept and one concept per word. Keep the codebase's terms
   consistent.
2. Drop words that the module, type, or function already makes clear.
3. Prefer a clear short name over a compound name that explains too much.

### Comments

- Explain why non-obvious code exists or what constraint it protects.
- Add a doc comment for complex behavior or side effects when the code cannot
  show them clearly.
- Delete comments that only narrate history or restate the code.

## Code structure

1. Lead with exported or important functions; keep helpers below them.
2. Split large files by concept when that makes each part easier to understand.
3. Merge types, functions, or constants that represent the same concept.
4. Search for shared utilities before adding inline versions.
5. Remove state that can be derived from values already in scope.

## Overfitting

Code must stand on its own. If a name or comment needs this conversation or PR
to make sense, rewrite it using the codebase's own vocabulary.

Do not keep backwards compatibility for an old signature, alias, or data shape
that was never shipped. Update its callers and remove the old path.

## Guardrails

- Preserve behavior, public contracts, and user intent.
- Do not simplify by deleting tests, error handling, or needed safeguards.
- Do not make unrelated edits.
- If a change would alter behavior or a stated constraint, stop and report it.
- Run focused checks after each meaningful edit, then the broader relevant
  checks before finishing.

## Attribution

Adapted from Ben Holmes's `simplify` skill:
https://github.com/bholmesdev/skills/tree/main/skills/simplify

Related post:
https://x.com/bholmesdev/status/2083677834715750539?s=12
