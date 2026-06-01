# Format Validator Report

**Paper**: Coarsening at random for multiple instance learning
**Date**: 2026-05-26

## Build verification

Confirmed the build with `make paper`:

- `main.pdf` produced cleanly, 12 pages.
- No `undefined references` warnings in `main.log`.
- No `multiply defined labels` warnings.
- BibTeX produced `main.bbl` without errors (`main.blg` clean).
- All `\cref`, `\eqref`, `\citep`, `\citet` calls resolve.
- Cleveref capitalization correct throughout (Section/section,
  Theorem/theorem, etc.).

## Issues

### MINOR. Hyperref PDF-string warnings for `\paragraph{}` headings using `\cref`

`main.log` lines 576, 580, 585 show:

```
Package hyperref Warning: Token not allowed in a PDF string (Unicode):
(hyperref)                removing `\new@ifnextchar' on input line 25.
```

Triggered from `validation.tex` lines 25, 56, 85, all of which use
`\cref{...}` inside `\paragraph{...}` headings. The warnings are
cosmetic (PDF bookmarks may lose the cross-reference text) and do
not affect the rendered PDF.

Mitigation: use `\texorpdfstring` to provide a plain-text PDF-string
fallback. Example:

```latex
\paragraph{Rank condition
  (\texorpdfstring{\cref{thm:rank}}{Theorem 1})}
```

Optional, not blocking.

### MINOR. `figures/` directory exists but no `\includegraphics` calls

`figures/` is empty. The `\graphicspath{{figures/}}` directive is
present but unused. `HANDOFF.md` confirms this is deliberate:
figures are deferred to a later draft. No action needed for the
current draft, but the rank-condition diagnostic plot (Exp 1) and
the noisy-OR firing-rate ratio plot (Exp 3) are the natural
candidates when figures are added.

### MINOR. Author block formatting

Author block in `main.tex` lines 53--59 uses inline `\\` separators
with each line listed manually. This renders fine but is not the
conference-template style at AISTATS, ICML, or NeurIPS, each of
which has its own author block macros. If a specific venue is
chosen, the author block should be re-templated.

### MINOR. `\maketitle` produces a generic article title page

The current `\documentclass{article}` with default `\maketitle`
produces a left-aligned title and centered author block in the
default 11pt geometry. For a 12-page conference paper this is fine
as a draft, but most venues expect a specific title-page style.
Re-template when venue is chosen.

### MINOR. Three `\cite{}` should be `\citet{}` (cross-link with citation-verifier)

Already noted by the citation verifier. These are syntactically
valid but stylistically should be `\citet{}` for noun-form
citations.

### MINOR. Hyperlink color choice

`\usepackage[colorlinks=true,linkcolor=blue,citecolor=blue,urlcolor=blue]{hyperref}`
makes all hyperlinks bright blue. Many conference templates prefer
darker links (e.g., `linkcolor=darkblue` or no color) for print
readability. Minor stylistic choice.

## What is correct

- Package selection (`amsmath`, `amsthm`, `mathtools`, `bm`,
  `cleveref`, `natbib`, `hyperref`, `booktabs`, `enumitem`,
  `microtype`, `geometry`) is appropriate and conflict-free.
- Theorem environment setup is clean: `theorem`, `proposition`,
  `lemma`, `corollary` share a counter; `definition`, `condition`,
  `remark` use appropriate styles. Cleveref names defined for
  `condition`. No environment collisions.
- Math macros (`\E`, `\Prob`, `\R`, `\1`) defined once in main.tex
  and used consistently.
- `\graphicspath{{figures/}}` correctly set even though no figures
  yet.
- Em-dash check: zero U+2014, zero `---` in source. ✓ (Author
  convention held.)

## Build environment

- pdfTeX, TeX Live distribution.
- `natbib` + `plainnat` bibliography style.
- Font setup: Computer Modern via amsfonts (default), with cm-super
  type1 fonts for PDF embedding.
- Output: PDF 1.5, 12 pages, 318 KB.

## Confidence

High. The build is clean, the labels resolve, the warnings are
cosmetic. The only structural format concern is venue templating,
which is correctly deferred until a venue is chosen.
