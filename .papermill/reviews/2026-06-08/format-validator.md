# Format Validator Report

**Paper**: mil-coarsening
**Date**: 2026-06-08
**Scope**: build verification, label resolution, venue formatting, production.

## Build

- `make paper` exits 0.
- Undefined references/citations: `LC_ALL=C grep -ai undefined main.log`
  excluding "Font shape ... undefined" = **0**. Clean.
- Output: 22 pages, `main.pdf` produced. (Note the HANDOFF and prior review
  refer to a 12-14 page conference draft; the paper has since grown to 22 pages
  with the continuous-feature theorem, the MUSK discrete/continuous/PCA
  experiments, and the formal appendix. This is now a journal-length draft;
  see FMT-3.)
- `rerunfilecheck`: `main.out` unchanged, no rerun needed. Cross-references and
  the `.bbl` are converged.
- All three figures (`fig_rank_collapse.pdf`, `fig_firing_rate.pdf`,
  `fig_musk_eta.pdf`) exist in `figures/`, are referenced via
  `\includegraphics`, and render. They match their captions (verified
  visually): the rank-collapse ridge-to-cloud, the firing-rate ratio onto the
  identity line, and the MUSK sorted per-type positivity with a boundary tail.

## Label resolution

- All `\cref` / `\Cref` targets resolve (0 undefined).
- Theorem counter (from `main.aux`): thm:bg-id=1, thm:rank=2, rem:firing-rate=3,
  thm:rank-continuous=4, thm:bag-total=5, (remark)=6, thm:bias-rule=7. The
  shared-counter scheme is intentional (one `\newtheorem` counter across
  theorem/proposition/lemma/corollary, definition/remark on their own styles but
  same counter). The `\cref` calls in the body and appendix use labels and
  resolve to these numbers correctly.

### FMT-1 (MAJOR, shared with logic-checker / prose-auditor): appendix subsection titles hardcode wrong theorem numbers
**Location**: `sections/appendix.tex` lines 10, 102, 160.
**Problem**: The titles "Proof of Theorem 1 / 2 / 3" are typed literals, not
`\cref`, and disagree with the compiled numbers (2 / 5 / 7). The
label-resolution machinery is fine; the literals are stale. This is the
production-side manifestation of LOG-1.
**Suggestion**: `\subsection{Proof of \cref{thm:rank} (rank condition)}` and
likewise. After this, all theorem references in the document are label-driven
and cannot drift.

### FMT-2 (MINOR): six hyperref "Token not allowed in a PDF string" warnings
**Location**: `main.log` lines 576, 589, 594, 634, 639, 643. These come from
`\cref` and inline math appearing inside `\paragraph{}` / sectioning titles
(e.g. `\subsection{Proof of Theorem 4 (continuous-feature \cref{...})}` and
paragraph headings containing math). They affect only the PDF bookmark strings,
not the typeset output.
**Problem**: cosmetic; the PDF outline shows a degraded string for those
headings. This was M9 in the prior review (then 3 warnings; now 6, tracking the
added appendix/continuous sections).
**Suggestion**: optional. Wrap the offending tokens in
`\texorpdfstring{<tex>}{<plain>}` within the titles, or accept the cosmetic
warnings. Not blocking.

### FMT-3 (MINOR): page count has outgrown the stated conference target
**Location**: whole document; `CLAUDE.md` / `README.md` say "conference-format
target (~12 pages)".
**Problem**: The draft is 22 pages. The HANDOFF acknowledges the growth and
records it as a JMLR-format draft, and the `.zenodo.json` plus draft Zenodo
deposition are consistent with a journal-length submission. So the artifact is
internally coherent as a journal draft, but the repo's CLAUDE.md/README still
describe a 12-page conference paper. Either retarget the metadata to the journal
format (JMLR / a stats-ML journal) or, if a conference cap is still wanted, the
HANDOFF's trimming options (move MUSK or PLL to supplementary) apply.
**Suggestion**: update CLAUDE.md/README and `state.md` venue to match the
journal-length reality (the new state.md written in this pass does this), and
decide the venue explicitly. Not a build defect.

### FMT-4 (SUGGESTION): one overfull hbox
**Location**: `main.log`, a single Overfull \hbox (24.1pt too wide). Minor
typographic bleed into the margin somewhere; `microtype` is already loaded.
**Suggestion**: locate and reword/rebreak the offending line, or leave it (24pt
is visible but not egregious). Low priority.

## Venue formatting
- `\documentclass[11pt,letterpaper]{article}`, 1in margins, `natbib` +
  `cleveref` + `amsthm`. This matches the family template (spatial-coarsening,
  dp-coarsening). For a JMLR submission the class would eventually swap to
  `jmlr`/`jmlr2e`, but the current generic-article form is fine for a preprint /
  Zenodo deposit and for review.
- No `\end{document}` in section files (correct; single top-level).
- Math macros (`\E`, `\Prob`, `\R`, `\1`) defined once in the preamble, used
  consistently.

## Production verdict
Build is clean and reproducible. The only production defect with reader impact
is the stale appendix theorem numbers (FMT-1, also a logic/prose finding). The
rest is cosmetic (FMT-2, FMT-4) or metadata hygiene (FMT-3).
