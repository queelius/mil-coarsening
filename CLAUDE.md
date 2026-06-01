# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Project Overview

Academic paper repository: **Coarsening at random for multiple
instance learning: identifiability conditions for instance-level
inference.**

Conference-format target (~12 pages). The third application in the
masked-data coarsening series, after `papers/scrna-coarsening/`
(precursor) and `papers/spatial-coarsening/` (sibling). It applies
the same masked-data identifiability framework to multiple instance
learning (MIL): instances are components, bags are candidate sets,
the logical-OR bag rule is series aggregation, and singleton bags
(instance-level labels) are singleton candidate sets.

## Build Commands

```bash
make paper      # builds main.pdf
make clean      # removes artifacts
```

## Architecture

- `main.tex`: pure-LaTeX top-level with preamble plus `\input{sections/...}`
- `sections/`: 8 section files (no `\end{document}` in section files)
- `refs.bib`: BibTeX
- `scripts/`: simulation/analysis scripts (empty currently)
- `figures/`: figures (empty currently; validation.tex has no
  `\includegraphics`, so the paper builds without figure assets)

## Companion repositories

- `papers/scrna-coarsening/` (precursor; same framework, scRNA-seq application)
- `papers/spatial-coarsening/` (sibling; spatial-transcriptomics application)
- `papers/masked-causes-in-series-systems/` (foundational; cited as Towell 2026)
- `papers/mdrelax/` (companion; cited as Towell 2026)

## Conventions (Alex's preferences)

- **No em-dashes** (soul plugin hook enforces). In LaTeX source this
  also means no `---`; use `--` only for numeric or label ranges.
- **No vanity counts** in the writeup (state the work, not the number
  of pages, references, or sections).
- LaTeX, not Quarto/RMarkdown.
- Tight conference-style writing: prefer one-paragraph subsections to
  multi-paragraph essays.
- Cite `towell2026scrnacoarsening` and `towell2026spatialcoarsening`
  for shared theorem apparatus rather than re-deriving; cite
  `towell2026milcoarsening` (this paper, full version) for proofs
  deferred from the conference format.
- Author: Alexander Towell, lex@metafunctor.com, SIUE Department of
  Computer Science.

## Conference format constraints

Target: ~12 pages including references. Strategies:
- 11pt with 1in margins.
- Push full proofs to the longer-version companion
  (`towell2026milcoarsening`).
- Compact theorem statements; cite companion papers for shared proof
  apparatus.
- Limit figures to a small set of essentials, added once the
  simulation runs.

## Status

Initial scaffold. Substantive content in all sections; proof sketches
in place. Simulation code, real-data application, and figures pending.
Run `make paper` to confirm the build.
