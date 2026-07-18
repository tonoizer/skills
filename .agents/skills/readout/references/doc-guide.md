# Readout document guide

Read this file completely before generating a readout.

## Artifact contract

Produce one HTML file that remains readable offline and with JavaScript disabled. Keep all presentation CSS and behavior inline. Allow external URLs only as ordinary hyperlinks; never load remote scripts, stylesheets, fonts, images, frames, or renderers.

Start from `assets/template.html` and replace every `{{UPPER_CASE_SLOT}}`. Preserve the `style[data-readout]` and `script[data-readout]` blocks. Add document-specific styling only inside `style[data-doc]`.

When GitHub source links are present, copy `assets/code-pane.html` verbatim immediately before `</body>`. The pane enhances embedded excerpts; ordinary links still work when an excerpt is unavailable or JavaScript is disabled.

## Required content

Write for someone who has none of the originating conversation:

1. Open with a concise executive summary.
2. Answer the brief's questions in a reader-friendly order, usually following the real data flow.
3. Ground code-specific claims in linked `file:line` evidence.
4. Mark inferred behavior and unresolved questions explicitly.
5. Include an architecture or data-flow figure only when it clarifies a relationship that prose would obscure.
6. Close with verification caveats and provenance: date, source, repositories, and exact commits examined.

Curate the corrected end state. Do not reproduce the investigation chronologically or preserve discarded guesses unless they teach an important gotcha.

## Source links

Use full 40-character commit hashes:

```text
https://github.com/ORG/REPO/blob/FULL_COMMIT/path/to/file.ext#L10-L24
```

Link both the visible `file.ext:10-24` caption and useful diagram nodes. Never link to a branch, tag, abbreviated hash, or guessed remote. If the host or commit cannot be verified, use plain monospace text and record the limitation.

Keep citations close to the claims they support. Prefer a small number of decisive references over a wall of links.

## Safe embedded excerpts

The embedding helper reads tracked source from the exact linked commit and stores only cited windows plus a small amount of context. It never reads the working tree, falls back to another revision, or embeds an entire file.

The exact commit must also be reachable from an `origin/*` remote-tracking ref. Fetch the intended revision first when a legitimate detached or shallow checkout has not populated that ref; never weaken the check or substitute a local-only commit.

- Pass each known-public slug with `--public-repo ORG/REPO`.
- For a private or unknown repository, use `--private-source-approved` only after the user explicitly accepts that source excerpts will travel inside the HTML.
- Do not embed paths likely to contain credentials, keys, certificates, environment files, or other secrets. The helper refuses common credential filenames, private-key formats, token prefixes, and secret assignments as defense in depth, but this is not exhaustive secret scanning; inspect cited private-source windows before approving embedding.
- If embedding is declined or unavailable, leave the pinned links intact.

When GitHub CLI access is available, determine visibility with `gh repo view ORG/REPO --json visibility --jq .visibility`. Treat a failed or unavailable lookup as unknown, never as public.

If embedding uses a non-default `--context N`, pass the same `--context N` to `validate_readout.py`.

## Layout and visuals

Use the template's existing classes: `.callout`, `.warn`, `.badge`, `.table-wrap`, `figure`, and `details`. Keep tables horizontally scrollable. Use semantic sections with unique IDs and ensure every contents entry points to one.

Draw diagrams as accessible inline SVG with a title and description. Use `currentColor`, CSS variables, text labels, arrowheads, and links rather than raster screenshots. A diagram must still convey its meaning without animation.

## Final checks

Run `validate_readout.py`. Then skim the artifact for:

- a useful title and description;
- no empty or placeholder sections;
- correct contents ordering;
- citations that open the claimed lines;
- clear verified-versus-inferred language;
- sensible narrow-screen behavior;
- no confidential excerpt embedded without consent.
