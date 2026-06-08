# Multi-Agent Review Report

**Date**: 2026-06-08
**Paper**: Coarsening at random for multiple instance learning: identifiability conditions for instance-level inference
**Author**: Alexander Towell (SIUE, ORCID 0000-0001-6443-9897)
**Manuscript**: `/home/spinoza/github/coarsening/papers/mil-coarsening/main.tex`
**Build**: `make paper` clean (0 undefined excluding font-shape), 22 pages
**Recommendation**: **minor-revision**

## Summary

**Overall Assessment**: This is a strong, mathematically sound entry in the
coarsening-at-random family. The bridge from multiple instance learning to the
masked-cause series-system identifiability problem is genuinely productive,
yielding a rank condition for instance-type identifiability, a bag-prevalence
consistency identity that explains the known bag-vs-instance accuracy gap as a
moment-matching statement, and a first-order bias bound that recovers the
Foulds-Frank standard-vs-collective taxonomy as a C1-preservation partition. The
two correctness defects from the 2026-05-26 review (the singleton firing-rate
overclaim and the bias-bound sign) are fixed and verified; validation is now
multi-seed with a real-data MUSK1/MUSK2 application and figures; the appendix
carries self-contained proofs of all four theorems. The result is consistent
with the synthesis paper's `cor:mil`. Two major issues remain, both quick and
both pre-deposit blockers: a set of four MUSK numbers that contradict the
deposited results file (and contradict the same section on the same page), and
stale hardcoded theorem numbers in the appendix subsection titles.

**Strengths**:
1. The mathematics is correct end to end; all four appendix proofs re-derived
   without error, and the prior review's two correctness defects are fixed
   (logic-checker).
2. The bag-prevalence consistency identity as the likelihood-level mechanism for
   the Vanwinckelen et al. 2016 empirical bag-vs-instance gap is a compelling,
   well-positioned novelty move (novelty-assessor).
3. Reproducibility is good: 20-seed simulation with median+IQR reporting, a real
   MUSK application, and the 12 hardcoded LOO macros all match the deposited
   `musk_results.rds` exactly (methodology-auditor).
4. Honest scoping throughout: "diagnostic and structural, not algorithmic," the
   admitted discretization gap on MUSK, and the "what the framework does not
   address" section. The prior "subsumes" overclaim is fixed (novelty-assessor,
   prose-auditor).
5. Build is clean and the figures match their captions; conventions (no
   em-dashes, no vanity counts) are fully respected (format-validator,
   prose-auditor).

**Weaknesses**:
1. Four numbers in the MUSK consistency paragraph contradict the results file
   and the same page (methodology-auditor, prose-auditor).
2. Appendix subsection titles cite stale theorem numbers that disagree with the
   compiled numbering (logic-checker, prose-auditor, format-validator).
3. The nearest MIL-identifiability prior, Doran-Ray 2014 ("true MIL"), is
   uncited (novelty-assessor, citation-verifier).
4. Three self-citations are stale ("Manuscript in preparation") relative to
   their already-minted Zenodo DOIs (citation-verifier).

**Finding Counts**: Critical: 0 | Major: 2 | Minor: 9 | Suggestions: 4

## Critical Issues

None.

## Major Issues

### 1. Four MUSK numbers contradict the results file and the same page (source: methodology-auditor, cross-confirmed by prose-auditor)
- **Location**: `sections/validation.tex`, `sec:musk`, "Bag-prevalence
  consistency, real data" paragraph (lines 215-219).
- **Quoted text**: "only $8$ of $20$ instance types on MUSK1 and $4$ of $20$ on
  MUSK2 are interior at the optimum, and accordingly the weighted score residual
  is large ($\|M^\top D^{-1}(\bm Y - \hat{\bm p})\|_\infty = 24.8$ on MUSK1 and
  $505$ on MUSK2)".
- **Problem**: From `data/musk_results.rds` (`in_sample$K20`): MUSK1 has
  `n_boundary = 11` (so 9 interior, not 8) and `score_inf = 26.0` (not 24.8);
  MUSK2 has `n_boundary = 17` (so 3 interior, not 4) and `score_inf = 611.6`
  (not 505). The interior counts are also internally contradictory: the
  "Per-type positivity" paragraph earlier in the same section states "11 of 20
  types on the boundary" (MUSK1) and "17 of 20" (MUSK2), which imply 9 and 3
  interior, directly contradicting the "8" and "4" written below. A reader doing
  the subtraction catches this without the artifact.
- **Why major not critical**: the paragraph's argument is qualitative
  (thm:bag-total is an interior identity; the MUSK fits are boundary-dominated;
  the clean confirmation lives in the simulation) and does not depend on the
  precise values. But a number that contradicts the paper's own deposited data
  and contradicts the same page is a credibility liability and is exactly what a
  reproducibility checker catches.
- **Suggestion**: "8 of 20" -> "9 of 20"; "4 of 20" -> "3 of 20"; "24.8" -> "26";
  "505" -> "612" (or "$\approx 610$"). Best practice: drive these four from the
  same `\newcommand`-from-`musk_results.rds` mechanism the LOO numbers already
  use, so they cannot drift again.
- **Cross-verified**: yes. Methodology-auditor loaded `data/musk_results.rds`
  and read `n_boundary` and `score_inf` directly; prose-auditor independently
  found the on-page self-contradiction. Both agree.

### 2. Appendix subsection titles cite stale, wrong theorem numbers (source: logic-checker, cross-confirmed by prose-auditor and format-validator)
- **Location**: `sections/appendix.tex` lines 10, 102, 160.
- **Quoted text**: "Proof of Theorem 1 (rank condition)", "Proof of Theorem 2
  (bag-prevalence consistency)", "Proof of Theorem 3 (aggregation-rule bias)".
- **Problem**: The theorem environment shares one counter across
  theorem/proposition/lemma/corollary, and `thm:bg-id` (background) is Theorem 1.
  From `main.aux`: `thm:rank` = Theorem **2**, `thm:rank-continuous` = Theorem
  **4** (this title is coincidentally right), `thm:bag-total` = Theorem **5**,
  `thm:bias-rule` = Theorem **7**. So "Proof of Theorem 1" actually proves
  `thm:rank` (body Theorem 2), while body Theorem 1 is the background
  identifiability theorem; "Proof of Theorem 2" proves `thm:bag-total` (body
  Theorem 5); "Proof of Theorem 3" proves `thm:bias-rule` (body Theorem 7). The
  in-proof `\cref{thm:...}` calls are label-based and correct; only the
  human-readable subsection titles are wrong, and they mislead anyone who
  cross-references by number.
- **Suggestion**: replace the literals with `\cref`, e.g.
  `\subsection{Proof of \cref{thm:rank} (rank condition)}`, and likewise for the
  others. Titles then track the compiled numbers automatically and never drift.
- **Cross-verified**: yes, by three lenses against `main.aux` (logic-checker
  LOG-1, prose-auditor PRO-2, format-validator FMT-1). No disagreement.

## Minor Issues

### M1. Nearest MIL-identifiability prior (Doran-Ray 2014) uncited (source: novelty-assessor, citation-verifier)
- **Location**: `sections/introduction.tex` related work; `refs.bib`.
- **Problem**: Doran and Ray 2014 (Machine Learning), the "true MIL" condition,
  is the closest existing MIL-identifiability statement and is uncited. The
  paper's contribution survives the comparison (data-design-level well-posedness
  vs parameter-rank identifiability are different objects), but the comparison
  must be explicit. Both 2026-05-26 scouts flagged this; it remains open.
- **Suggestion**: cite it once in related work with a one-sentence distinction.

### M2. "Mathematically isomorphic" in the introduction (source: prose-auditor, novelty-assessor)
- **Location**: `sections/introduction.tex` line 59.
- **Quoted text**: "We observe that MIL is mathematically isomorphic to the
  masked-data series-system identifiability problem".
- **Problem**: The correspondence is a reduction / instance-of, not a
  category-theoretic isomorphism; the paper itself flags a "structural inversion"
  an isomorphism would preclude. The abstract already uses "an instance of"
  (main.tex line 93); the intro is the outlier.
- **Suggestion**: "mathematically isomorphic to" -> "an instance of".

### M3. Three self-citations stale relative to minted Zenodo DOIs (source: citation-verifier)
- **Location**: `refs.bib` entries `towell2026masked`,
  `towell2026scrnacoarsening`, `towell2026spatialcoarsening`.
- **Problem**: all three are `journal = {Manuscript in preparation}` with no DOI,
  yet the sibling spatial-coarsening `state.md` records that `towell2026masked`
  (10.5281/zenodo.20414723) and `towell2026scrnacoarsening`
  (10.5281/zenodo.20414735) were minted on 2026-05-27. This bib is stale, and a
  referee cannot reach the deferred proofs. `towell2026mdrelax` already shows the
  correct `@misc{... doi = ...}` form.
- **Suggestion**: update to the `@misc`/Zenodo concept-DOI form per the project
  convention.

### M4. "Three theorems" framing vs four proved (source: logic-checker, prose-auditor)
- **Location**: `sections/appendix.tex` line 6, `sections/validation.tex` line 4,
  `sections/introduction.tex` line 120, abstract.
- **Problem**: the paper states and proves four theorems (rank, rank-continuous,
  bag-total, bias-rule) but the appendix says "self-contained proofs of the
  three theorems" then provides four proof subsections.
- **Suggestion**: reword the appendix opener to "the three core theorems and the
  continuous-feature extension," or recount to four.

### M5. Empty-bag edge case in thm:bag-total (source: logic-checker)
- **Location**: `sections/identifiability.tex` thm:bag-total; `app:proof-bag-total`.
- **Problem**: the `D^{-1}` weighting requires `p_hat_i > 0` for every bag, which
  excludes empty bags (`m_i = 0`). Carried from prior review M1, still open.
- **Suggestion**: one clause/footnote "assuming `m_i != 0` (no empty bags),
  standard in MIL."

### M6. Threshold-r C1-violation framing is loose (source: logic-checker)
- **Location**: `sections/methodology.tex` lines ~100-108.
- **Quoted text**: "Collective assumptions violate C1, because a bag can be
  ``positive'' with no individually positive instance (a threshold rule with
  $r > 1$, or a proportion rule)."
- **Problem**: for threshold-r with `r > 1`, the positive bag does contain
  positive instances; what fails is the singleton-cause structure (the masked
  cause is a size-`r` subset), not C1's support form. Emergent rules are the case
  where no instance is the cause. The two violation modes are conflated. Carried
  from prior review major-8.
- **Suggestion**: distinguish the subset-cause failure (threshold/proportion)
  from the support failure (emergent) in one sentence.

### M7. Three noun-form citations use `\cite` instead of `\citet` (source: prose-auditor, citation-verifier)
- **Location**: `sections/methodology.tex` lines 87, 89; `sections/identifiability.tex`
  line 169; (`sections/discussion.tex` line 85 also uses `\cite{towell2026mdrelax}`
  mid-sentence).
- **Problem**: with `plainnat`, noun-form citations need `\citet` for correct
  grammar; these read as parentheticals. Carried from prior review M3.
- **Suggestion**: change to `\citet[\S ...]{...}` where the citation is the
  grammatical subject/object.

### M8. Firing-rate confound still demonstrated one-sided (source: methodology-auditor)
- **Location**: `sections/validation.tex` Exp 3 noisy-OR paragraph.
- **Problem**: the experiment shows the estimator recovers `rho * eta` (bias
  exists), which is necessary but not the sharpest evidence of
  non-identifiability. The direct demonstration (two equal-product `(rho, eta)`
  pairs with indistinguishable likelihoods) is still absent. Downgraded from the
  prior review's major-7 to minor because the ratio-collapse figure plus the
  closed-form `rho eta_k` derivation together make the point convincingly.
- **Suggestion**: a few dozen lines in `run.R`; optional this round.

### M9. Six cosmetic hyperref pdfstring warnings (source: format-validator)
- **Location**: `main.log` lines 576, 589, 594, 634, 639, 643, from `\cref`/math
  in sectioning titles. Affects PDF bookmark strings only. Carried from prior M9
  (then 3, now 6 with the added sections).
- **Suggestion**: optional `\texorpdfstring` wrapping, or accept.

## Suggestions

1. Report the K=10 MUSK LOO AUCs (the results file has them: MUSK1 0.711, MUSK2
   0.604) so "results at K=10 are qualitatively similar" is verifiable rather
   than asserted (methodology-auditor MET-3).
2. Document the boundary-detection tolerance (`lower = 1e-8`, boundary at
   `s <= 1e-6`) in the validation section so boundary counts are reproducible
   (methodology-auditor MET-4, carried M10).
3. Add a one-line distinction from Halpern-Sontag 2013 (noisy-OR network
   identifiability) near rem:firing-rate (citation-verifier CIT-3).
4. Update CLAUDE.md/README venue and length metadata: the paper is now 22 pages
   (journal-length), not the "~12-page conference" the repo docs still describe;
   decide JMLR vs a trimmed conference submission (format-validator FMT-3).

## Detailed Notes by Domain

### Logic and Proofs
All four appendix proofs re-derived without error. The two prior correctness
defects are fixed and verified: rem:firing-rate now correctly states singleton
bags alone do not separate `rho` from `eta` (only direct instance labels or a
known-eta=1 control do), and thm:bias-rule now carries the correct `+I^{-1}`
sign with the perturbation entering through the law of `Y`. thm:bag-total's score
derivation and KKT boundary handling are exact and match the synthesis `cor:mil`.
Open logic items are presentational (stale appendix theorem numbers, LOG-1, a
major) plus minors (three-vs-four count, empty-bag clause, threshold-r framing).

### Novelty and Contribution
Solid and well-positioned. The MIL-through-coarsening-conditions framing is novel
against the MIL literature, and the closest neighbours (Jang-Kwon PAC, Chen milr,
Cour PLL) are cited and correctly differentiated; the coarse-data genealogy
(Couso et al.) is acknowledged so the apparatus is not overclaimed. The prior
"subsumes" overclaim is fixed throughout ("places methods in a common
assumption-naming language ... does not derive new estimators"). One must-add
prior (Doran-Ray 2014) and the lingering "isomorphic" are the open items.

### Methodology
Much stronger than at the prior review: 20-seed median+IQR reporting resolves the
single-seed concern, the MUSK real-data application exists, and reproducibility
is good (the 12 LOO macros match the artifact exactly; rank/condition-number/
boundary-count/positive-rate claims all match). The one material defect is MET-1
(four contradictory MUSK numbers), which is also an on-page self-contradiction.
The firing-rate confound demonstration remains one-sided (now minor).

### Writing and Presentation
Clean, balanced, in the intended tight register; the appendix reads as real
derivations now. No em-dashes (Unicode-scan clean), no vanity counts, author
identity correct. Open items: the MUSK self-contradiction (PRO-1, the prose face
of MET-1), the stale appendix theorem-number titles (PRO-2), "isomorphic"
(PRO-4), three-vs-four (PRO-3), and a few `\cite`->`\citet` (PRO-5).

### Citations and References
Bibliography integrity is good: 0 undefined, clean `.bbl`, the three dormant
sibling entries are correctly excluded by design (not a defect). Open: Doran-Ray
2014 missing (CIT-2, major-adjacent), three self-cites stale vs their minted
Zenodo DOIs (CIT-1), and optional DOIs/locators (Heitjan-Rubin, Dietterich,
Pearl section).

### Formatting and Production
`make paper` clean, 22 pages, all cross-references resolve, figures render and
match captions. Production defects: stale appendix theorem numbers (FMT-1, the
only one with reader impact), 6 cosmetic hyperref warnings (FMT-2), one 24pt
overfull hbox (FMT-4), and a metadata/length mismatch with the repo's
conference-target docs (FMT-3).

## Literature Context Summary
MIL is a mature field with a complete canonical lineage in the bib, and no prior
identifiability-conditions (rank-of-composition-matrix) treatment of
instance-level inference, so the bridge is genuinely original. The closest
neighbours are cited and differentiated: Jang-Kwon 2024 (PAC instance-
learnability, orthogonal lens), Chen et al. 2017 milr (the closest likelihood
model, now explicitly acknowledged), Cour et al. 2011 PLL (developed transpose-
coarsening subsection). The one remaining gap a domain referee will notice is
Doran-Ray 2014 ("true MIL," the nearest existing identifiability statement);
Halpern-Sontag 2013 (noisy-OR network identifiability) is a minor secondary add.
Cross-family consistency with the synthesis paper's `cor:mil` is clean: same
identity `M^T D^{-1}(Y - p_hat) = 0`, same regime-(A) exact-finite-sample
framing, same IRLS / non-canonical-link wrinkle, same rank-condition routing for
the vector statement.

## Review Metadata
- Agents used (lenses executed directly; Task sub-agent spawning unavailable in
  this environment): literature-scout (broad + targeted, merged),
  logic-checker, novelty-assessor, methodology-auditor, prose-auditor,
  citation-verifier, format-validator.
- Cross-verifications performed: 3
  - MUSK numbers: methodology-auditor (against `musk_results.rds`) and
    prose-auditor (on-page self-contradiction) independently confirmed.
  - Appendix theorem numbers: logic-checker, prose-auditor, format-validator all
    confirmed against `main.aux`.
  - "Isomorphic"/contribution framing: novelty-assessor and prose-auditor agree.
- Disagreements between specialists: 0.
- Hallucination checks: every quoted manuscript passage in the major and minor
  findings was re-read against the source files and verified verbatim. The four
  MUSK numbers and the two boundary-count claims were verified against
  `data/musk_results.rds` directly. The 12 LOO macros were cross-checked against
  the same file (all match). The theorem-counter mapping was verified against
  `main.aux`.
- Prior review (2026-05-26): the nine major findings were checked for closure;
  most are resolved (singleton-confound, bias sign, multi-seed, real-data,
  subsumes, PLL, self-contained proofs); the C1/threshold-r framing (M6) and the
  one-sided firing-rate demo (M8) carry forward at reduced severity.
