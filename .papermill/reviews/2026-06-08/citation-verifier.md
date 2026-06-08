# Citation Verifier Report

**Paper**: mil-coarsening
**Date**: 2026-06-08
**Scope**: citation accuracy, missing references, bibliography integrity.

## Summary

The bibliography is in good shape. The build resolves every citation (0
undefined), the compiled `.bbl` is clean, and the three dormant sibling entries
are correctly excluded from the compiled output. The MIL foundations are
complete and accurate. Two substantive items remain: a genuinely missing prior
(Doran-Ray 2014, the nearest MIL-identifiability work, shared with
novelty-assessor) and the self-citation archival status, which has materially
improved since the prior review but is not yet uniform.

## Bibliography integrity (verified)

- `refs.bib` defines 23 entries; 20 are cited in the body. The 3 uncited entries
  (`towell2026dpcoarsening`, `towell2026weaksupcoarsening`,
  `towell2026phenotypecoarsening`) are the deliberately dormant sibling-series
  pre-stages, documented in the `refs.bib` comment block and excluded from the
  `.bbl`. This is by design (the family cross-references these for future
  citation as the manuscripts mature) and is NOT a defect.
- No undefined citations, no multiply-defined labels (`grep undefined main.log`
  excluding font-shape = 0; see format-validator).
- DOIs present and well-formed for the entries that carry them (Carbonneau,
  Foulds-Frank, Vanwinckelen, Chen/milr, Couso, Campanella, Lu/CLAM, Bejnordi,
  Jang-Kwon, and `towell2026mdrelax`).

## Self-citation archival status (improved, not uniform)

The prior review's M4 ("five Manuscript in preparation self-cites") is partly
addressed:
- `towell2026mdrelax` now has a Zenodo DOI (10.5281/zenodo.20414727), publisher,
  url, and a `note = {Preprint, Zenodo}`. Good.
- `towell2026masked`, `towell2026scrnacoarsening`, `towell2026spatialcoarsening`
  are still `@article{... journal = {Manuscript in preparation}}` with no DOI or
  URL.

### CIT-1 (MINOR): three foundational/sibling self-cites lack archival identifiers
**Location**: `refs.bib` entries `towell2026masked`, `towell2026scrnacoarsening`,
`towell2026spatialcoarsening`.
**Problem**: These three are cited for shared proof apparatus (thm:bg-id; the
bag-total proof parallel; the bias-bound template). A referee who wants to
verify the deferred derivations cannot reach them. Note an internal
inconsistency in the family: the sibling spatial-coarsening `state.md` records
that `towell2026masked` -> 10.5281/zenodo.20414723 and
`towell2026scrnacoarsening` -> 10.5281/zenodo.20414735 were minted on
2026-05-27, yet this paper's `refs.bib` still lists both as "Manuscript in
preparation." The DOIs exist; this bib is stale relative to the sibling's
record.
**Suggestion**: update these three entries to `@misc{... publisher = {Zenodo},
doi = {...}, url = {https://doi.org/...}, note = {Preprint, Zenodo}}` using the
concept DOIs already recorded in the spatial-coarsening state file and the
project README. This is the project's stated citation convention (cite Zenodo
concept DOIs, not version DOIs) and these three should follow it like
`towell2026mdrelax` already does. This is also a prerequisite the HANDOFF notes
for series-wide publication ordering.

### CIT-2 (MAJOR, shared with novelty-assessor): Doran-Ray 2014 missing
**Location**: `refs.bib` and `sections/introduction.tex` related work.
**Problem**: Doran and Ray 2014 (Machine Learning), the "true MIL" condition, is
the nearest existing MIL-identifiability statement and is uncited. See
novelty-assessor NOV-1 for the substantive argument; from the citation side it
is a missing reference that both 2026-05-26 scouts independently flagged.
**Suggestion**: add the entry and cite it once in related work.

### CIT-3 (MINOR): optional secondary identifiability/noisy-OR references
**Location**: related work; rem:firing-rate.
**Problem**: Halpern-Sontag 2013 (UAI, noisy-OR identifiability) is the obvious
neighbour to rem:firing-rate's noisy-OR confound, in a different scope (network
topology). A one-line distinction would inoculate against a referee from that
line. Lower priority: Sabato-Tishby 2012 (MIL sample complexity), Feng et al.
2020 / Liu-Dietterich 2014 (PLL identifiability) for the PLL subsection.
**Suggestion**: optional; add Halpern-Sontag if space allows.

### CIT-4 (MINOR, carried): a few foundational entries lack DOIs
**Location**: `refs.bib`.
**Problem**: `heitjan1991ignorability` (DOI 10.1214/aos/1176348396) and
`dietterich1997solving` (DOI 10.1016/S0004-3702(96)00034-3) still lack DOIs.
`maron1998framework` and `andrews2003support` are NeurIPS volumes without
identifiers (acceptable for proceedings). Add the two journal DOIs for
completeness.

## Accuracy spot-checks (all correct)
- `dietterich1997solving`: MUSK dataset origin, Artificial Intelligence 89(1-2),
  31-71, 1997. Correct, and the paper's MUSK1/MUSK2 counts (92 molecules / 476
  conformations; 102 / 6598) match the canonical dataset.
- `chen2017milr`: R Journal 9(1), 446-457, 2017. Correctly characterized as EM
  for OR-rule Bernoulli MLE with lasso.
- `jang2024learnable`: NeurIPS 2024, correctly characterized as PAC
  instance-learnability.
- `foulds2010review`: correctly used as the standard-vs-collective taxonomy
  source.
- `pearl1988probabilistic`: noisy-OR; prior review M6 suggested a section
  locator (Sec 4.3.2) when cited in methodology; still absent, optional.
