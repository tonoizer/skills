---
name: readout
description: Create a polished, self-contained HTML readout from the current investigation or a fresh codebase question. Use when the user invokes /readout or $readout, asks to write findings up, turn research into a document or page, make a shareable codebase guide, explain architecture visually, or preserve an investigation as a durable artifact with verified source links.
---

# Readout

Turn verified findings into one durable HTML document that makes sense without the original conversation. Create documentation only; do not modify the codebase being explained.

## Choose the mode

- Use **snapshot mode** when the conversation already contains the investigation. Distill its corrected end state, not its chronology.
- Use **research mode** when the request introduces a fresh question. Inspect the codebase before writing.

Ask only for missing choices that materially affect the artifact: audience, depth, scope, or private-source embedding. Infer them when the request or conversation already makes them clear.

## Prepare a self-sufficient brief

Before delegating or writing, record:

- working title, mode, audience, and intended depth;
- two to five questions the document must answer;
- included and excluded subsystems;
- absolute repository paths;
- each repository's remote URL, exact `HEAD` commit, and public/private status when discoverable;
- snapshot conclusions worth preserving, with enough evidence that another agent need not read hidden conversation history;
- research entry points, symbols, and directories already known.

Never give a child agent only a conversation ID or an instruction to recover hidden history. The brief must stand alone.

## Investigate and write

When a local subagent is available, use exactly one research/writing subagent for a broad readout. Give it the brief, the skill directory, and permission to create only the readout artifact and its index. Otherwise perform the same workflow directly. Do not block completion merely because delegation is unavailable.

For research mode, trace actual entrypoints, state changes, boundaries, and outputs. Verify line references against the pinned commit and distinguish evidence from inference. For snapshot mode, re-check any source reference that will appear in the document.

Read [references/doc-guide.md](references/doc-guide.md) completely before writing. Start from [assets/template.html](assets/template.html). When the document has GitHub source links, insert [assets/code-pane.html](assets/code-pane.html) immediately before `</body>`.

## Write the artifact

Resolve the library directory as `${READOUTS_HOME:-$HOME/.readouts}`. Allocate a collision-safe artifact from the canonical template:

```bash
python3 <skill-dir>/scripts/create_readout.py "<topic>"
```

Use the absolute path printed by the helper. It names files `<YYYY-MM-DD>-<topic-slug>.html`, adding `-2`, `-3`, and so on when needed.

Require every document to include:

- an executive summary a reader can stop after;
- a working table of contents;
- verified, commit-pinned source links for code-specific claims;
- an architecture or data-flow visual when it materially improves understanding;
- explicit verification caveats and a provenance footer;
- responsive light/dark styling and readable no-JavaScript behavior.

Use inline SVG for diagrams and link useful nodes to matching sections or pinned source locations. Do not use Mermaid, D3, remote fonts, external images, or other render-time dependencies.

## Handle source embedding safely

Use links only unless embedding is allowed:

- For a public GitHub repository, embed cited line windows automatically.
- For a private or unknown repository, explain that the HTML would contain source excerpts and obtain explicit permission before embedding. Without permission, keep pinned links only.
- Never embed credentials, untracked files, binary files, or whole source files.

When allowed, run one of:

```bash
python3 <skill-dir>/scripts/embed_snippets.py <readout.html> --repo <checkout> --public-repo <org/repo>
python3 <skill-dir>/scripts/embed_snippets.py <readout.html> --repo <checkout> --private-source-approved
```

Repeat `--repo` and `--public-repo` for additional checkouts. The helper resolves only exact commits and fails rather than substituting `HEAD`.

## Validate and index

Run both helpers before reporting success:

```bash
python3 <skill-dir>/scripts/validate_readout.py <readout.html> [--repo <checkout> ...] [--context N]
python3 <skill-dir>/scripts/update_index.py "${READOUTS_HOME:-$HOME/.readouts}"
```

Pass every checkout used for embedded snippets with `--repo`; omit it for links-only readouts. When embedding used `--context N`, pass the same value during validation. Fix every validation failure. If validation cannot pass, report the incomplete artifact and the exact blocker rather than presenting it as finished.

Open the readout with the platform's local file opener when one is available and the environment permits it. Otherwise return the absolute path as a clickable link. Report the path, a two-sentence summary, what was verified, and any unresolved inference.
