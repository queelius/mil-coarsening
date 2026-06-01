# Citation Verifier Report

**Paper**: Coarsening at random for multiple instance learning
**Date**: 2026-05-26

## Bibliography check

I reviewed `refs.bib` against the citations used in the manuscript.

### Citations used in text

- `dietterich1997solving`: used (intro, validation, real-data plan)
- `maron1998framework`: used (intro, translation, discussion,
  conclusion)
- `andrews2003support`: used (intro, translation, discussion,
  validation, conclusion)
- `ilse2018attention`: used (intro, translation, discussion,
  conclusion)
- `carbonneau2018multiple`: used (intro, discussion)
- `foulds2010review`: used (intro, methodology x2, discussion)
- `cour2011learning`: used (intro)
- `campanella2019clinical`: used (intro, validation)
- `lu2021data`: used (intro, translation, discussion, validation,
  conclusion)
- `bejnordi2017diagnostic`: used (validation)
- `pearl1988probabilistic`: used (methodology)
- `heitjan1991ignorability`: used (background)
- `towell2026masked`: used (intro, translation table, background)
- `towell2026mdrelax`: used (discussion)
- `towell2026scrnacoarsening`: used (intro, background,
  translation, identifiability, discussion, conclusion)
- `towell2026spatialcoarsening`: used (intro, background, methodology,
  discussion, conclusion)
- `towell2026milcoarsening`: used (translation, identifiability,
  methodology, validation)

All cited references are present in `refs.bib`.

### References present in `refs.bib` but not cited

`refs.bib` includes a "dormant sibling entries" block (lines 155--180)
with three entries not cited in this paper:

- `towell2026dpcoarsening` (differential-privacy coarsening)
- `towell2026weaksupcoarsening` (programmatic weak supervision)
- `towell2026phenotypecoarsening` (electronic phenotyping)

The `.bib` comment explicitly says these are "pre-staged for future
citation." This is unusual but not problematic: BibTeX silently
ignores uncited entries when using `\bibliographystyle{plainnat}`
and the natbib `\bibliography{...}` command. The compiled `.bbl`
will not include them.

Verified: `main.bbl` does not contain entries for
`towell2026dpcoarsening`, `towell2026weaksupcoarsening`, or
`towell2026phenotypecoarsening`. Clean.

(For a submission, the dormant block should be removed or moved to a
separate `dormant.bib` not bound to this paper, to avoid reviewer
confusion if they inspect the bibliography source. Minor.)

## Issues

### MINOR. Five "Manuscript in preparation" entries

The Towell self-citations all have `journal = {Manuscript in
preparation}` (or "This paper, manuscript in preparation"). Five of
them. This is a known feature of citing a series-in-progress, but
reviewers at a conference will see five non-archival self-citations
and may discount their evidentiary weight. Specifically:

- `towell2026masked`: "Manuscript in preparation"
- `towell2026mdrelax`: "Manuscript in preparation"
- `towell2026scrnacoarsening`: "Manuscript in preparation"
- `towell2026spatialcoarsening`: "Manuscript in preparation"
- `towell2026milcoarsening`: "This paper, manuscript in preparation"

Theorem 2's proof sketch defers to `towell2026scrnacoarsening` §3.
Theorem 3's sketch defers to `towell2026spatialcoarsening` §5,
`towell2026scrnacoarsening` §7, and `towell2026milcoarsening`. None
of these are publicly accessible at the time of writing (per
HANDOFF.md, the precursor scrna-coarsening paper is "in late
polish", spatial-coarsening is sibling-format, and milcoarsening is
this paper's full version, also unwritten).

For a conference submission this is borderline. Options:

1. Deposit the foundational `towell2026masked` paper on arXiv or
   Zenodo before submission and cite the preprint with a URL.
   (HANDOFF.md says towell2026masked is "a Zenodo preprint" but the
   `.bib` entry does not have a `url`, `doi`, or `eprint` field.
   Add one if available.)
2. Inline the precise scrna-coarsening §3 derivation that Theorem 2
   defers to, at least in sketch, since the precursor is not yet
   archived.
3. Cite a representative archived alternative for the parts that
   have non-self equivalents (e.g., for the M-estimator perturbation
   expansion of Theorem 3, cite van der Vaart 1998 "Asymptotic
   Statistics" Chapter 5).

Option 1 plus option 3 is the lowest-effort fix.

### MINOR. Heitjan-Rubin entry missing a DOI

`heitjan1991ignorability` (Annals of Statistics 19(4), 1991) is a
standard reference. A DOI for completeness:
10.1214/aos/1176348396. Same for `dietterich1997solving`:
10.1016/S0004-3702(96)00034-3. Not blocking; consider adding to all
foundational references.

### MINOR. Pearl 1988 page reference for noisy-OR

`pearl1988probabilistic` is cited as the source for noisy-OR
(`methodology.tex` line 31). For the reader who wants to follow the
reference, a chapter or section locator helps: Pearl 1988, Section
4.3.2 (noisy-OR gate). Currently just the book is cited.

### MINOR. CAMELYON16 attribution

`bejnordi2017diagnostic` is the CAMELYON16 algorithm-comparison
paper. The dataset itself is from Litjens et al. (2018,
GigaScience: "1399 H&E-stained sentinel lymph node sections..."),
which is the standard CAMELYON16 dataset citation. Either is
acceptable; if the paper's real-data plan in the full version
intends to actually use the CAMELYON16 dataset (not the algorithm
benchmark), the Litjens citation is the conventional one. Currently
in scope only as a forward-looking reference.

## Cross-references and labels

I checked all `\cref{...}` and `\eqref{...}` against the labels
defined in the manuscript:

- `\cref{sec:translation}`: defined in `translation.tex` ✓
- `\cref{sec:identifiability}`: defined in `identifiability.tex` ✓
- `\cref{sec:methodology}`: defined in `methodology.tex` ✓
- `\cref{sec:validation}`: defined in `validation.tex` ✓
- `\cref{sec:intro}`, `\cref{sec:background}`,
  `\cref{sec:discussion}`, `\cref{sec:conclusion}`: defined ✓
- `\cref{cond:c1,cond:c2,cond:c3}`: defined in `background.tex` ✓
- `\cref{thm:bg-id}`: defined in `background.tex` ✓
- `\cref{thm:rank}`, `\cref{thm:bag-total}`,
  `\cref{rem:firing-rate}`: defined in `identifiability.tex` ✓
- `\cref{thm:bias-rule}`: defined in `methodology.tex` ✓
- `\cref{tab:translation}`: defined in `translation.tex` ✓
- `\eqref{eq:bg-joint}`: defined in `background.tex` ✓
- `\eqref{eq:trans-eta}`, `\eqref{eq:trans-or}`,
  `\eqref{eq:trans-lik}`: defined in `translation.tex` ✓
- `\eqref{eq:bag-total}`: defined in `identifiability.tex` ✓
- `\eqref{eq:meth-delta}`, `\eqref{eq:bias-rule}`: defined in
  `methodology.tex` ✓

All cross-references resolve cleanly. No "??" in `main.log`.

## Confidence

High. The bibliography is well curated and the cross-references are
clean. The only nontrivial issue is the high proportion of in-
preparation self-citations, which is a feature of writing a paper
series rather than a citation error per se.
