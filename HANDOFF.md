# Hand-off: mil-coarsening paper

**Last touched**: 2026-06-02. JMLR-format draft, 20pp, em-dash free.
Run `make paper` to confirm the build.

## Publication state (2026-06-02)
- **git**: private repo at github.com/queelius/mil-coarsening
  (initial commit 9f39e2c on branch master). Flip to public at
  JMLR-submission time.
- **Zenodo**: DRAFT deposition 20502965, reserved DOI
  **10.5281/zenodo.20502965**. NOT YET PUBLISHED, matching every
  other paper in the series (all currently drafts). Do not publish
  MIL before the foundational `masked-causes` paper it cites is
  published, or its live record will point at not-yet-live sibling
  DOIs. Review draft: https://zenodo.org/deposit/20502965
- When ready to publish series-wide, the dependency order is:
  masked-causes and mdrelax first (foundational), then the six
  application papers (scrna, spatial, mil, dp, weaksup, phenotype),
  whose bibs cross-cite each other's reserved DOIs.

This is the third application paper in the masked-data coarsening
series, after `~/github/papers/scrna-coarsening/` (precursor) and
`~/github/papers/spatial-coarsening/` (sibling).

---

## 1. What this paper is

**Working title**: *Coarsening at random for multiple instance
learning: identifiability conditions for instance-level inference.*

**Central claim**: multiple instance learning (MIL) is mathematically
isomorphic to the masked-data series-system identifiability problem.
Instances are components, bags are candidate sets, the logical-OR
bag rule is series aggregation, the latent positive instance is the
masked cause, and singleton bags (instance-level labels) are
singleton candidate sets that restore identifiability.

**Why this exists**: MIL has a large methods literature (mi-SVM,
Diverse Density, attention-based deep MIL, CLAM) but no
characterization of when instance-level inference is identifiable
from bag labels. The masked-data framework supplies identifiability
conditions, a consistency theorem with a sharp practical warning
about attention weights, and a bias bound for misspecified
aggregation rules. The scrna- and spatial-coarsening papers proved
the framework carries for two biological applications; this paper
takes it to a mainstream machine-learning problem with a different
audience.

**Conference target**: 12-page format (AISTATS / ICML / a
weakly-supervised-learning or medical-imaging venue). Current draft
has substantive content in all sections; expanding with figures and
the real-data application is the natural next step.

---

## 2. The verification that preceded the scaffold

Before scaffolding, the rank theorem was derived to confirm the
framework carries. It does, cleanly:

- Bag likelihood: with conditionally independent instance labels,
  `P(Y_i = 0 | m_i) = exp(-m_i^T s)` where `s_k = -log(1 - eta_k)`.
  This is a complementary-log-log Bernoulli GLM with design matrix
  `M` (the bag-by-instance-type composition matrix).
- **Rank theorem**: `eta` is identifiable iff `M` has full column
  rank `K`. Direct twin of the spatial-coarsening rank theorem.
- Three corollaries map to known MIL phenomena: singleton bags
  restore rank (semi-supervised MIL), collinear columns are the
  co-occurrence confound (when attention weights are
  uninterpretable), and the GLM MLE matches bag prevalence (bag
  accuracy cannot validate instance scores).
- **Firing-rate confound**: under noisy-OR, only `rho * eta_k` is
  identified, not `rho` and `eta` separately. This is the
  discrete-label analogue of the ERCC capture-efficiency gap.

The verification is summarized in `sections/identifiability.tex`
(`thm:rank`, `rem:firing-rate`, `thm:bag-total`).

---

## 3. Current state

### Paper scaffold (`papers/mil-coarsening/`)
- `main.tex`: top-level, conference preamble (mirrors
  spatial-coarsening).
- `sections/` (all substantive):
  - `introduction.tex` (motivation, bridge, contributions)
  - `background.tex` (masked-data primer, C1-C2-C3, `thm:bg-id`)
  - `translation.tex` (DGP, translation table, existing methods)
  - `identifiability.tex` (`thm:rank`, firing-rate confound,
    `thm:bag-total`, rank-failure cases)
  - `methodology.tex` (`thm:bias-rule`, recovery of the
    standard-versus-collective taxonomy)
  - `validation.tex` (simulation protocol and real-data plan;
    DESCRIBED not RUN)
  - `discussion.tex` (method positioning, limitations)
  - `conclusion.tex`
- `refs.bib`: MIL foundations (Dietterich, Maron, Andrews, Ilse,
  Carbonneau, Foulds-Frank), computational pathology (Campanella,
  Lu/CLAM, CAMELYON16), noisy-OR (Pearl), Heitjan-Rubin, and Towell
  2026 manuscripts.
- `Makefile`, `README.md`, `CLAUDE.md`.
- **Status**: scaffold complete, em-dash free. `validation.tex`
  has no `\includegraphics`, so the paper builds without figure
  assets.

### Theorems stated
1. **Rank condition** (`thm:rank`): instance-type positivity
   identifiable iff bag-by-instance-type composition matrix `M` has
   full column rank.
2. **Bag-prevalence consistency** (`thm:bag-total`): bag-likelihood
   MLE matches observed bag-positive frequencies along `col(M)`;
   bag accuracy cannot validate instance scores.
3. **Bias bound** (`thm:bias-rule`): first-order bias under
   aggregation-rule misspecification; recovers the
   standard-versus-collective taxonomy as a C1-preservation
   statement.

---

## 4. What's left

### Tier 1: needed for submission
- [x] **Simulation code** (`scripts/sim.R`, `scripts/run.R`):
  L-BFGS-B box-constrained bag-OR MLE in direct `s` parametrization;
  DGP supports deterministic OR, noisy-OR, label-noise, r-of-n;
  three experiments wired to `results.rds` (seed `20260523`).
- [x] **Three validation checks executed** with numbers reported
  in `validation.tex`. Exp 1 rank condition cleanly recovers the
  identified linear functional `2 s_1 + s_2` to machine precision
  while the unidentified individual `s_1` spreads. Exp 2 verifies
  the corrected IRLS-weighted form of `thm:bag-total` at interior
  MLEs; the original unweighted form falsified empirically. Exp 3
  recovers the noisy-OR firing-rate confound and the label-noise
  bias profile.
- [ ] **Real-data application**. Start with MUSK1/MUSK2 and
  Elephant/Fox/Tiger (small, classical, partial instance labels);
  the headline target is a weakly supervised computational-pathology
  task (whole-slide bags, patch instances, pixel annotations as
  singleton bags).
- [ ] **Self-contained proofs**. Proof sketches currently cite
  `towell2026milcoarsening` (full version) and the companion
  papers. The rank-theorem proof and the score-equation derivation
  for `thm:bag-total` (interior + KKT cases) should be self-contained
  in an appendix.
- [ ] **Figures**: rank-condition diagnostic (Exp 1 collapse plot)
  and noisy-OR firing-rate confound (Exp 3 ratio plot).
  `validation.tex` deliberately omits `\includegraphics` until
  assets exist; add a figures section then.

### Tier 2: would strengthen
- [ ] Side-by-side comparison with mi-SVM, attention-based MIL, and
  CLAM on the same inputs.
- [ ] Continuous-feature rank theorem (Gram matrix of the feature
  map replaces `M`). Currently deferred to the full version.
- [ ] Empirical demonstration of the firing-rate confound: show two
  `(rho, eta)` pairs with identical bag fit, then break it with
  singleton bags.

### Tier 3: polish
- [ ] Conceptual figure for the bridge (instances/bags as
  components/candidate sets).
- [ ] Position against partial-label learning (Cour et al. 2011),
  the closest existing identifiability-flavored MIL work.
- [ ] Decide venue and trim to its page limit.

---

## 5. Companion repos

The framework is shared across three papers. Cite rather than
re-derive:
- `papers/scrna-coarsening/`: precursor. Cell-total consistency
  proof apparatus, spike-in oracle bias bound.
- `papers/spatial-coarsening/`: sibling. Rank-condition proof
  structure, marker-gene bias bound (the template for
  `thm:bias-rule`).
- `papers/masked-causes-in-series-systems/`: foundational
  (`towell2026masked`, `thm:bg-id`).
- `papers/mdrelax/`: C2-relaxation results, cited for the
  within-bag-dependence limitation.

Keep the citation pattern when expanding: the conference format
defers full proofs to `towell2026milcoarsening`.

---

## 6. Conventions

- **No em-dashes** anywhere (soul plugin hook). In LaTeX source,
  also avoid `---`; use `--` only for numeric or label ranges.
- **No vanity counts**: state the work, not the number of pages,
  references, or sections.
- LaTeX, not Quarto/RMarkdown.
- Author: Alexander Towell, lex@metafunctor.com, SIUE Department of
  Computer Science.

---

## 7. Quick-start commands

```bash
# Build the paper
cd ~/github/papers/mil-coarsening
make paper

# Run the simulation (once scripts are written)
Rscript scripts/run.R
```

---

## 8. Status checklist

- [x] Scaffold: substantive sections in all parts
- [x] Rank theorem verified before scaffolding
- [x] Theorem statements (rank, bag-prevalence consistency,
  aggregation-rule bias) with proof sketches
- [x] `thm:bag-total` corrected to the IRLS-weighted form
  `M^T D^{-1} (Y - p_hat) = 0` with interior-MLE qualifier and a
  remark on cloglog non-canonicity. The original unweighted form
  was an error that the simulation caught.
- [x] `rem:firing-rate` corrected (singleton bags do NOT break the
  noisy-OR confound; only direct instance labels or a calibrated
  positive-control type with known eta=1 do).
- [x] `thm:bias-rule` sign and notation corrected to `+I^{-1}` with
  the perturbation entering through the law of Y (not through the
  loss directly); implicit-function derivation made explicit.
- [x] PLL comparison: half-page subsection in discussion.tex
  positioning MIL as the transpose-coarsening of partial-label
  learning (Cour, Sapp, Taskar 2011).
- [x] "Subsumes" language softened in abstract, intro contributions,
  discussion, and conclusion: framework places methods in a common
  assumption-naming language, does not derive new estimators.
- [x] Multi-seed validation: 20 seeds (20260523-20260542), every
  headline number reported as median + IQR in `validation.tex`.
- [x] References for primary citations
- [x] Build confirmed (`make paper` -> 14 pages)
- [x] Simulation code (`scripts/sim.R`, `scripts/run.R`)
- [x] Validation numbers populated in `validation.tex` (multi-seed)
- [x] Real-data application: MUSK1 and MUSK2 from UCI in `data/`,
  analysis in `scripts/musk.R`, results in `data/musk_results.rds`,
  reported as `\subsection{Real-data application: MUSK1 and MUSK2}`
  in `validation.tex`. Headline: LOO-AUC 0.79 on MUSK1, 0.60 on
  MUSK2; rank-condition diagnostic computes cleanly; bag-prevalence
  consistency holds within the boundary-coordinate residual. The
  predictive gap to published continuous-feature methods (MI-SVM,
  Diverse Density) is honestly attributed to k-means discretization
  and motivates the continuous-feature extension.
- [x] Self-contained proofs in `sections/appendix.tex`: rank
  theorem (constructive null-vector for necessity, strict-monotonicity
  argument for sufficiency); bag-prevalence consistency (full score
  derivation + KKT for boundary case); aggregation-rule bias bound
  (implicit-function expansion with second Bartlett identity giving
  the `+I^{-1}` form; noisy-OR sensitivity worked out in closed form).
- [x] Figures: `figures/fig_rank_collapse.pdf` (Exp 1 ridge collapse
  under singleton augmentation), `figures/fig_firing_rate.pdf`
  (Exp 3 noisy-OR ratio on identity line), `figures/fig_musk_eta.pdf`
  (MUSK1 + MUSK2 sorted per-type positivity with boundary tail).
  Generated by `scripts/figures.R`, `make figures` target wired.
- [x] Comparison to published baselines: table in `validation.tex`
  (`tab:musk-comparison`) lays out iAPR, Diverse Density, MI-SVM,
  mi-SVM, and our bag-OR MLE side by side with honest discussion of
  the discretization gap.
- [ ] Same-folds head-to-head with mi-SVM / DD on MUSK: not done in
  this round; the continuous-feature refit
  (`sec:musk-continuous`) is the apples-to-apples comparison the
  framework now offers, against published numbers in the comparison
  table.

## Tier B (JMLR-version scope): converted to journal format

Tier B work (Wave 1 = hedge + bib cleanup, Wave 2 = formal appendix
proofs, Wave 3 = continuous-feature theorem + MUSK refit). Status:

- [x] Wave 1: removed `towell2026milcoarsening` from `refs.bib`;
  replaced every `\cite{towell2026milcoarsening}` with forward refs to
  `\cref{app:proof-X}` or rewrote the surrounding sentence to drop the
  "deferred to full version" framing.
- [x] Wave 2: `sections/appendix.tex` with formal proofs of
  `thm:rank`, `thm:bag-total`, `thm:bias-rule`, and (added in Wave 3)
  `thm:rank-continuous`. Closed-form noisy-OR sensitivity included.
- [x] Wave 3 theorem: `thm:rank-continuous` in
  `sections/identifiability.tex` (`sec:continuous`) ports the rank
  condition to continuous instance features under the
  linear-in-features parametrization $s(x) = \beta^T \phi(x)$. The
  discrete case is recovered as $\phi(x) = e_{k(x)}$.
- [x] Wave 3 estimator: `fit_or_mle` in `sim.R` was already general
  over any nonnegative design matrix, so it handles continuous
  features without modification by feeding `Phi` instead of `M`.
- [x] Wave 3 MUSK refit: `scripts/musk.R` extended with
  `in_sample_continuous` and `loo_cv_continuous`; results saved to
  `data/musk_results.rds` under keys `continuous_in_sample` and
  `continuous_loo_cv`.
- [x] Wave 3 validation prose: `sec:musk-continuous` subsection in
  `validation.tex` reports the continuous-feature LOO numbers
  alongside the discrete-$K=20$ table. Continuous-feature LOO AUC
  is 0.66 on MUSK1 and 0.54 on MUSK2, **worse** than discrete-$K=20$
  (0.79 and 0.60), because $d = 166 > N$ leaves $\beta$
  under-identified by 74 (MUSK1) and 64 (MUSK2) dimensions. This is
  exactly the empirical signature `thm:rank-continuous` warns about
  and is reported honestly: the rank diagnostic caught a second
  failure mode beyond discretization, and the natural framework
  response is rank-reduction of the feature map
  (e.g., PCA-to-k components with k < N).
- [ ] Tier C-ish extension (not in scope for this submission round
  but a natural follow-up): PCA-reduce the continuous feature map to
  `k = 50` components, refit, demonstrate the LOO numbers improve
  back above discrete-$K=20$ as the framework predicts.

## Page count vs. conference cap

Paper currently builds to 14 pages (about 1 page of bib). Conference
target was 12. Overage is from the PLL subsection (+1) and the MUSK
real-data subsection (+1), both added in the review-fix pass. Options
if a hard 12-page cap binds:

- Move the MUSK subsection to a supplementary file (cleanest, since
  the conference-format theorem is the discrete-type version and the
  MUSK demonstration partly motivates the continuous extension).
- Trim the PLL subsection by half (cut the C1-C2-C3 mapping
  paragraph, keep the duality and small-ambiguity-degree pointer).
- Trim the "what the real-data application demonstrates" paragraph
  in `validation.tex` (the four-item list at the end of the MUSK
  subsection).
