---
schema_version: 1
last_updated: 2026-06-08
stage: revised-post-review-v0.3
paper_type: theory-with-simulation-and-real-data
format: latex
build_command: make paper
main_file: main.tex
output_file: main.pdf
---

# Paper state: mil-coarsening

## Metadata

- **Working title**: Coarsening at random for multiple instance learning: identifiability conditions for instance-level inference
- **Short name**: mil-coarsening
- **Type**: Application / theory + simulation + real-data
- **Target length**: journal-length (currently builds to 22 pages). Originally scoped as a ~12-page conference paper; grew with the continuous-feature theorem, the MUSK discrete/continuous/PCA experiments, and a formal appendix. CLAUDE.md and README still say "conference ~12 pages" and should be updated to match.
- **Format**: LaTeX, `\documentclass[11pt,letterpaper]{article}`, 1in margins, `natbib` + `cleveref` + `amsthm`
- **Build**: `make paper` (produces `main.pdf`); verify clean with `LC_ALL=C grep -ai undefined main.log | grep -vi "font shape" | wc -l` (expect 0)
- **Status**: Builds clean (0 undefined, 22 pages). All sections substantive. Three core theorems plus a continuous-feature extension, all with self-contained appendix proofs. Simulation (20 seeds) and real-data MUSK1/MUSK2 application executed with figures. Folded into the synthesis paper as `cor:mil`.

## Author

- **Name**: Alexander Towell
- **Email**: lex@metafunctor.com
- **Affiliation**: Department of Computer Science, Southern Illinois University Edwardsville
- **ORCID**: 0000-0001-6443-9897

## Thesis

Multiple instance learning (MIL) is an instance of the masked-data series-system identifiability problem from reliability statistics. Under this bridge: instances are components, bags are candidate sets, the "at least one positive instance" (logical-OR) bag rule is series aggregation, the latent positive instance is the masked cause, and a singleton bag (an instance-level label) is a singleton candidate set that restores identifiability. The C1/C2/C3 ignorable-coarsening conditions of Heitjan-Rubin (1991), as specialized to the masked-cause channel by the Towell masked-data series, port directly and yield instance-level identifiability conditions for inference from bag labels.

**Central message**: MIL methods are not arbitrary heuristics; they are special cases of a single identifiability framework that names the bag-formation and aggregation assumption each method makes. The rank condition is a diagnostic a practitioner can run before trusting instance-level outputs (attention weights in particular). The contribution is diagnostic and structural, not algorithmic: the framework does not derive new estimators.

**Novelty**: prior work supplies the apparatus (Heitjan-Rubin coarsening; Couso-Dubois-Hullermeier coarse-data ML; the Towell masked-data series). The contribution is recognizing the isomorphism, porting the conditions, and reading off three named MIL results. This is the first identifiability-conditions (rank-of-composition-matrix) treatment of instance-level inference in MIL. Closest neighbours, correctly differentiated: Jang-Kwon 2024 (PAC instance-learnability), Chen et al. 2017 milr (EM for OR-Bernoulli, the closest likelihood model), Cour et al. 2011 (partial-label learning, the transpose coarsening). The discrete-label firing-rate confound is the analogue of the ERCC spike-in capture-efficiency gap in the scrna sibling.

## Contributions

1. **Bridge** from MIL to masked-data inference (`sections/translation.tex`, `tab:translation`). Places mi-SVM/MI-SVM, Diverse Density, attention-based deep MIL, milr, and CLAM in a common assumption-naming language.
2. **Rank condition** (`thm:rank`, `sections/identifiability.tex`): instance-type positivity is identifiable from bag labels iff the bag-by-instance-type composition matrix `M` has full column rank. Singleton bags add unit-vector rows and restore rank. Continuous-feature extension `thm:rank-continuous` (design `M -> Phi`).
3. **Bag-prevalence consistency** (`thm:bag-total`): any interior bag-OR-likelihood maximizer satisfies the IRLS-weighted moment-matching identity `M^T D^{-1}(Y - p_hat) = 0` along `col(M)`; bag-level accuracy cannot validate instance-level scores. Folded into the synthesis as `cor:mil` (regime A, exact finite-sample identity, IRLS-weighted by the non-canonical log-survival link).
4. **Bias bound under aggregation-rule misspecification** (`thm:bias-rule`): closed-form first-order bias when the true rule is noisy-OR, label-noisy, or threshold rather than deterministic OR. Recovers the Foulds-Frank standard-vs-collective taxonomy as a partition of rules by whether they preserve C1.
5. **Firing-rate confound** (`rem:firing-rate`): under noisy-OR only the products `rho * eta_k` are identified; singleton bags alone do not separate the factors (only direct instance labels or a known-eta=1 positive control do). Discrete-label analogue of the spike-in capture-efficiency gap.
6. **Simulation (20 seeds) + real-data MUSK1/MUSK2 validation** (`sections/validation.tex`): rank collapse and singleton restoration, the weighted-vs-unweighted residual contrast, the noisy-OR ratio curve, and the MUSK rank diagnostic / boundary-MLE regime / discretization gap.

## Companion / framework-series papers

- `towell2026masked` (foundational): masked-causes-in-series-systems, `thm:bg-id`. Zenodo concept DOI 10.5281/zenodo.20414723 (per spatial-coarsening state; this paper's bib is currently stale, see review CIT-1).
- `towell2026mdrelax` (companion): C2-relaxation / sensitivity. Zenodo DOI 10.5281/zenodo.20414727 (present in bib).
- `towell2026scrnacoarsening` (precursor): cell-total consistency proof apparatus, spike-in oracle bias. Zenodo concept DOI 10.5281/zenodo.20414735 (per spatial state; bib stale).
- `towell2026spatialcoarsening` (sibling): rank-condition proof structure, marker-gene bias-bound template. (bib stale: "Manuscript in preparation").
- `coarsening-synthesis` (flagship): carries this result as `cor:mil`; consistent with `thm:bag-total`.
- `towell2026{dp,weaksup,phenotype}coarsening`: dormant sibling entries pre-staged in `refs.bib`, excluded from the compiled `.bbl`.

## Venue

**Analyzed 2026-06-09** (web-verified). The decisive fact is that this paper is a
*correct-and-useful but non-novel-algorithm, non-SOTA, journal-length theory+diagnostic*
contribution: it proposes no new estimator and does not try to beat baselines. That reorders
the usual ML ladder, the novelty/impact-weighted venues (NeurIPS/ICML/ICLR, TPAMI, Pattern
Recognition) work against it, while two venues whose criteria fit this profile rise to the top.

### Candidates (ranked)
1. **TMLR (Transactions on Machine Learning Research)** -- PRIMARY. Its acceptance criteria
   explicitly forbid rejecting work for being "not novel enough" or for not topping a
   benchmark, and name diagnostic/robustness studies as in-scope, removing this paper's single
   largest rejection risk. Full OA, no APC, ~9-week rolling review, preprint-friendly (double-blind on
   OpenReview with a de-anonymization option in the style file for the Zenodo preprint).
   Friction: the fast track wants ~12pp of main content; either trim main toward 12pp with
   proofs in the uncapped appendix, or accept a slower review at the current 22pp.
2. **JMLR** -- calibrated/no-trim alternative. This is original research (a new analytical
   framework), so the "surveys by invitation only" rule does NOT apply. No page cap (keep all
   22pp + proofs intact), no fees, CC-BY, preprints allowed, highest ML-journal prestige, and
   JMLR is AISTATS Journal-to-Conference eligible (can later be presented as an AISTATS poster;
   TMLR is not yet on that list). Trade: slower/higher-bar review + mandatory JMLR-style
   reformat from the article class.
3. **AISTATS 2027** (conference, if a hard deadline + visibility is wanted). Abstract
   ~Jan 15, 2027; Paris, Apr 26-28, 2027 (re-verify on the official site near Dec 2026). Needs
   heavy compression: 22pp -> ~8-9pp main + supplement (keep the MIL-as-masked-data reduction,
   the rank diagnostic as headline, one MUSK demonstration; appendix the rest). Novelty IS
   weighed, so frame the structural reduction + the practitioner diagnostic as the novel
   object. **UAI 2027** (~Feb 2027, unofficial; July 2027) is the better topical fit
   (uncertainty/identifiability) on the same compression terms.

### Excluded
- **NeurIPS / ICML / ICLR**: strongest novelty/impact weighting + 8-9pp compression; high-risk
  for a deliberately non-novel diagnostic. TMLR is the JMLR-family route built precisely so such
  work need not fight that bar.
- **IEEE TPAMI / Pattern Recognition**: vision/empirical, novelty-driven, two-column page caps,
  reformat; PR charges ~USD 2,800 APC for OA. Poor fit for a non-SOTA identifiability paper.
- **Weakly-supervised / computational-pathology venue**: deferred, not now. Relevant only if a
  pathology (e.g., WSI/TCGA) experiment is added; the paper currently defers that.

### Submission strategy
- **Primary path: TMLR.** If trimming main to ~12pp feels like too much surgery on a
  proof-bearing paper, go to **JMLR** instead (no page cap, keep everything; slower, higher bar,
  JtC bonus).
- **Never run a journal and a conference submission concurrently.** Conferences bar work under
  review at another refereed-proceedings venue; a Zenodo preprint does NOT trip this, but a live
  TMLR/JMLR review does. Pick one track at a time. The clean combo for both a journal of record
  and conference visibility: publish in JMLR first, then use the AISTATS Journal-to-Conference
  track.
- **Conference anonymity**: do not deanonymize via "our prior preprint"; cite the Zenodo
  version in third person.
- **Publication ordering (now satisfied on the blocking axis)**: foundational `masked-causes`
  is LIVE (Zenodo 10.5281/zenodo.20457290, concept 18725577), so the concept-DOI sibling cites
  resolve and MIL is unblocked. Still clear the pre-deposit review items before publishing: the
  four MUSK numbers (MET-1; reportedly fixed, re-verify against `data/musk_results.rds`), the
  appendix theorem numbers (FMT-1), and the three stale self-cites (CIT-1). At acceptance,
  deposit the accepted version as a NEW VERSION under the existing concept DOI (10.5281/zenodo.20502964).

## Structure

`main.tex` (preamble + theorem environments + macros + `\input` of sections) + 8 section files under `sections/` + `sections/appendix.tex`.

| Section | File | Status |
|---|---|---|
| Introduction | `introduction.tex` | substantive |
| Background (masked-data primer, C1/C2/C3, `thm:bg-id`) | `background.tex` | substantive |
| Translation (DGP, table, existing methods) | `translation.tex` | substantive |
| Identifiability (`thm:rank`, `rem:firing-rate`, `thm:rank-continuous`, `thm:bag-total`) | `identifiability.tex` | substantive, proofs in appendix |
| Methodology (`thm:bias-rule`, taxonomy recovery) | `methodology.tex` | substantive, proof in appendix |
| Validation (sim 20 seeds + MUSK1/MUSK2 discrete/continuous/PCA) | `validation.tex` | executed, figures in place |
| Discussion (method positioning, PLL subsection, limitations) | `discussion.tex` | substantive |
| Conclusion | `conclusion.tex` | substantive |
| Appendix (self-contained proofs of all four theorems) | `appendix.tex` | substantive |

`refs.bib`: MIL foundations (Dietterich, Maron, Andrews, Ilse, Carbonneau, Foulds-Frank), instance-vs-bag (Vanwinckelen), milr (Chen), PAC (Jang-Kwon), PLL (Cour), coarse-data ML (Couso), computational pathology (Campanella, Lu/CLAM, Bejnordi), noisy-OR (Pearl), Heitjan-Rubin, Towell series (4 active + 3 dormant).

`figures/`: `fig_rank_collapse.pdf`, `fig_firing_rate.pdf`, `fig_musk_eta.pdf` (all built and included).
`scripts/`: `sim.R`, `run.R`, `musk.R`, `figures.R`.
`data/`: `musk1.zip`/`musk2.zip` + extracted dirs, `musk_results.rds`.

## Experiments

### Done
- [x] Simulation, 20 seeds (20260523-20260542), every headline number median + IQR. Exp 1 rank collapse + singleton restoration; Exp 2 weighted-vs-unweighted residual; Exp 3 noisy-OR ratio + label-noise bias profile.
- [x] Real-data MUSK1/MUSK2: discrete-K (K=10, K=20), continuous-feature (d=166), PCA-to-k=50. Rank diagnostic, boundary-MLE regime, LOO-CV against published baselines, discretization-gap discussion. Results in `data/musk_results.rds`; the 12 hardcoded LOO macros all match the artifact.
- [x] Self-contained appendix proofs of `thm:rank`, `thm:rank-continuous`, `thm:bag-total`, `thm:bias-rule` (closed-form noisy-OR sensitivity included).
- [x] Figures generated (`scripts/figures.R`, `make figures`).

### Open / would strengthen
- [ ] Equal-product two-pair likelihood-degeneracy demonstration of the firing-rate confound (review MET-2; direct non-identifiability proof, currently shown one-sided via the ratio curve).
- [ ] Same-folds head-to-head with mi-SVM / Diverse Density on MUSK (currently compared to published numbers in `tab:musk-comparison`).
- [ ] Deferred: Elephant/Fox/Tiger and weakly-supervised computational-pathology applications (pixel annotations as singleton candidate sets).
- [ ] Report the K=10 MUSK LOO AUCs to make "qualitatively similar" verifiable (review MET-3).

## Reviews

### 2026-05-26 multi-agent review
Saved to `.papermill/reviews/2026-05-26/`. Recommendation: minor revision. Counts: 0 critical, 9 major, 11 minor, 5 suggestions. Major findings (singleton-bag firing-rate overclaim; bias-bound sign error; single-seed validation; abstract real-data overpromise; "subsumes" overclaim; underdeveloped PLL; one-sided firing-rate demo; C1-violation framing for threshold-r; deferred-manuscript proof verifiability). Most were addressed in subsequent revision passes (see HANDOFF.md): the singleton-confound text and the bias-bound sign are fixed and verified; validation is now 20-seed median+IQR; the real-data MUSK application is executed; "subsumes" is softened to "places in a common language"; PLL is a developed subsection; the appendix carries self-contained proofs.

### 2026-06-08 multi-agent review (this pass)
Saved to `.papermill/reviews/2026-06-08/`. Recommendation: **minor revision**. Counts: 0 critical, 2 major, 9 minor, 4 suggestions. Math re-verified sound (all four proofs); build clean (0 undefined, 22 pages); 12 hardcoded LOO macros match `musk_results.rds`; synthesis `cor:mil` consistent with `thm:bag-total`.

Two majors:
1. **MET-1 / PRO-1**: four numbers in the MUSK "bag-prevalence consistency, real data" paragraph contradict `data/musk_results.rds` AND contradict the same section on the same page: interior counts "8 of 20 (MUSK1)" and "4 of 20 (MUSK2)" should be 9 and 3 (boundary 11 and 17, stated correctly three paragraphs earlier); residuals "24.8" and "505" should be 26 and ~612.
2. **FMT-1 / LOG-1 / PRO-2**: appendix subsection titles hardcode stale theorem numbers ("Proof of Theorem 1/2/3") that disagree with the compiled numbering (thm:rank=2, thm:bag-total=5, thm:bias-rule=7). Replace literals with `\cref`.

Notable minors: Doran-Ray 2014 (nearest MIL-identifiability prior) uncited (NOV-1/CIT-2); three self-cites stale vs their already-minted Zenodo DOIs (CIT-1); "isomorphic" lingers in the intro vs "an instance of" in the abstract (NOV-2/PRO-4); "three theorems" vs four proved (LOG-2/PRO-3); empty-bag edge case in thm:bag-total (LOG-3); threshold-r C1-violation framing (LOG-4); a few `\cite`->`\citet` (PRO-5); 6 cosmetic hyperref pdfstring warnings (FMT-2).

## Conventions

- **No em-dashes** (soul plugin hook enforces; verified clean by Unicode scan).
- **No vanity counts** in the writeup.
- LaTeX only, not Quarto/RMarkdown.
- Cite `towell2026scrnacoarsening` / `towell2026spatialcoarsening` for shared proof apparatus; the appendix now carries self-contained proofs of this paper's own theorems.
- Drive numerical claims from `\newcommand` macros sourced from `musk_results.rds` (the LOO macros already do this; the four MUSK consistency-paragraph numbers do not, which is how MET-1 slipped).
- Author: Alexander Towell, lex@metafunctor.com, SIUE, ORCID 0000-0001-6443-9897.

## Publication / deposit state

- git: private repo github.com/queelius/mil-coarsening (flip public at submission).
- Zenodo: DRAFT deposition 20502965, reserved DOI 10.5281/zenodo.20502965. NOT published. Per HANDOFF, do not publish before foundational `masked-causes` is live. Fix MET-1, FMT-1, and CIT-1 before any deposit/publish.

## Next action

1. Fix the four MUSK numbers (MET-1) and the appendix theorem numbers (FMT-1): both are quick, both are pre-deposit blockers for credibility.
2. Add Doran-Ray 2014 and update the three stale self-cites to their Zenodo DOIs.
3. Sweep the remaining minors (isomorphic, three-vs-four, empty-bag clause, threshold-r framing, cite->citet).
4. Update CLAUDE.md/README venue/length metadata to the journal-length reality.
