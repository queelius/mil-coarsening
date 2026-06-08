# Methodology Auditor Report

**Paper**: mil-coarsening
**Date**: 2026-06-08
**Scope**: experimental design, statistical rigor, reproducibility, alignment
between claimed numbers and the artifacts that produce them.

## Summary

The empirical section is much stronger than at the 2026-05-26 review. The
single-seed concern is resolved (twenty seeds, 20260523-20260542, every headline
number reported as median + IQR). The real-data application now exists (MUSK1 /
MUSK2 from UCI, discrete-K, continuous-feature, and PCA-reduced variants), the
firing-rate confound is demonstrated as a clean ratio-to-rho curve, and the
weighted-vs-unweighted residual contrast is shown. Reproducibility is good:
`scripts/sim.R`, `scripts/run.R`, `scripts/musk.R`, `scripts/figures.R` with
stated seeds; `data/musk_results.rds` carries the saved fits.

The one material problem I found is a set of FOUR numbers in the MUSK
"bag-prevalence consistency, real data" paragraph that do not match
`data/musk_results.rds`. The twelve hardcoded continuous/PCA macros all match
the file exactly; the discrepancy is localized to four hand-typed figures in
one paragraph. Because the surrounding argument (the theorem is mostly
inapplicable on heavily-boundary fits) does not depend on the precise values,
this is a correctness-of-reporting defect rather than a threat to the
conclusion, but it must be fixed before deposit.

## Reproducibility check (I loaded the artifact directly)

I read `data/musk_results.rds` and compared every MUSK number in
`validation.tex` and every `\newcommand` macro in `main.tex` against it.

### Macros (main.tex lines 51-63): ALL MATCH
The twelve hardcoded LOO numbers (discrete K=20, continuous d=166, PCA k=50,
acc/AUC, both datasets) match the results file to two decimals:

| macro | paper | file |
|---|---|---|
| musonemkacc / musonemkauc (M1 disc) | 0.75 / 0.79 | 0.75 / 0.791 |
| musttwomkacc / musttwomkauc (M2 disc) | 0.56 / 0.60 | 0.559 / 0.595 |
| musonemcacc / musonemcauc (M1 cont) | 0.55 / 0.66 | 0.554 / 0.664 |
| musttwomcacc / musttwomcauc (M2 cont) | 0.53 / 0.54 | 0.529 / 0.541 |
| musonempcacc / musonempcauc (M1 pca) | 0.57 / 0.68 | 0.565 / 0.683 |
| musttwompcacc / musttwompcauc (M2 pca) | 0.54 / 0.56 | 0.539 / 0.565 |

The `musresumphrase = underperforms` macro is also correct: continuous LOO AUC
(0.66 / 0.54) is below discrete-K=20 (0.79 / 0.60) on both datasets.

The rank/condition-number/boundary-count claims also MATCH:
- MUSK1 rank(M) = 20, condition number 26 (file: 25.8), boundary 11 of 20.
- MUSK2 rank(M) = 20, condition number 93 (file: 92.6), boundary 17 of 20.
- MUSK1 pred/obs positive rate 0.49 / 0.51 (file: 0.486 / 0.511).
- MUSK2 pred/obs positive rate 0.24 / 0.38 (file: 0.249 / 0.382).
- MUSK1 most-musky cluster eta_hat 0.58 (file: 0.581). MATCH.

### MET-1 (MAJOR): four numbers in the real-data consistency paragraph contradict the artifact
**Location**: `sections/validation.tex` lines ~214-219 (the "Bag-prevalence
consistency, real data" paragraph).
**Quoted text**: "only `8` of `20` instance types on MUSK1 and `4` of `20` on
MUSK2 are interior at the optimum, and accordingly the weighted score residual
is large (`||M^T D^{-1}(Y - p_hat)||_inf = 24.8` on MUSK1 and `505` on MUSK2)".

**Problem**: From `data/musk_results.rds` (`in_sample$K20`):
- MUSK1 has `n_boundary = 11`, hence `9` interior types, not `8`.
- MUSK2 has `n_boundary = 17`, hence `3` interior types, not `4`.
- MUSK1 `score_inf = 26.0`, not `24.8`.
- MUSK2 `score_inf = 611.6`, not `505`.

The interior counts are additionally INTERNALLY inconsistent with the same
section: the "Per-type positivity" paragraph earlier states "11 of 20 types on
the boundary" for MUSK1 (correct) and "17 of 20" for MUSK2 (correct), which
imply 9 and 3 interior respectively, directly contradicting the "8" and "4"
written three paragraphs later. So this is catchable without the artifact: the
paper contradicts itself on the same page.

**Why it is major not critical**: the paragraph's argument is qualitative
(thm:bag-total is an interior identity, the MUSK fits are boundary-dominated, so
the theorem is mostly inapplicable and the clean confirmation lives in the
simulation). That argument holds regardless of whether the residual is 26 or
24.8 and whether interior count is 9 or 8. But a published paper with a number
that contradicts its own deposited results file, and contradicts itself on the
same page, is a credibility liability and is exactly what a careful referee or
a reproducibility checker will catch.

**Suggestion**: change "8 of 20" -> "9 of 20", "4 of 20" -> "3 of 20",
"24.8" -> "26", "505" -> "612" (or "$\approx 610$"). Best practice: drive these
four numbers from the same `\newcommand` macro mechanism already used for the
LOO numbers, sourced from `musk_results.rds`, so they cannot drift from the
artifact again (the HANDOFF protocol of hand-filling after each rerun is
precisely what let these four slip).

**Cross-verified**: yes, loaded `data/musk_results.rds` and read
`in_sample$K20$n_boundary`, `$score_inf` directly for both datasets.

## Simulation design (sound)

- DGP supports deterministic OR, noisy-OR, label-noise, r-of-n. Estimator is a
  box-constrained L-BFGS-B fit in `s >= 0` with the analytic gradient from
  thm:bag-total. Good: the gradient used by the optimizer is the same object
  the theorem characterizes, so the score-residual check is a genuine test.
- Exp 1 (rank): the rank-deficient design forces `m_i1 = 2 m_i2`, recovers the
  identified combination `2 s_1 + s_2` to machine precision while individual
  `s_1` spreads across starts; singleton augmentation collapses the spread by
  three orders of magnitude. This is the right experiment and the figure
  (`fig_rank_collapse.pdf`) shows exactly the ridge-to-cloud collapse described.
- Exp 2 (consistency): weighted residual at optimizer tolerance (~1e-7),
  unweighted residual order ~5 (seven orders larger). This is the strongest
  single piece of evidence in the paper and it directly validates the
  non-canonical-link claim. `app:proof-bag-total`'s remark cites the same
  contrast.
- Exp 3 (firing-rate / label-noise): ratio `eta_hat/eta_k` tracks rho onto the
  identity line for all four types (`fig_firing_rate.pdf` confirms; eta labels
  0.05/0.15/0.30/0.60 match the Exp 2/Exp 3 eta vector in the text). Label-noise
  bias grows with epsilon, linear at epsilon <= 0.10 and super-linear at 0.20,
  consistent with the first-order Taylor prediction of thm:bias-rule.

### MET-2 (MINOR): the firing-rate confound is still demonstrated one-sided
**Location**: Exp 3 noisy-OR paragraph.
**Problem**: The experiment shows the bag-OR estimator recovers `rho * eta`
(the bias exists), which is necessary but not the sharpest possible evidence of
NON-identifiability. The cleanest demonstration, still not present, is two
distinct pairs `(rho_1, eta_1) != (rho_2, eta_2)` with equal product, generate
from each, fit, and show indistinguishable likelihoods. This was major-7 in the
2026-05-26 review; it has been partially answered (the ratio-collapse figure is
strong) but the equal-product likelihood-degeneracy demonstration is the direct
proof and remains a "would strengthen." Downgrading from major to minor because
the ratio curve plus the closed-form `rho eta_k` derivation together make the
point convincingly.
**Suggestion**: a few dozen lines in `run.R`; optional for this round.

### MET-3 (MINOR): MUSK k-means K is a free knob whose sensitivity is asserted, not shown
**Location**: `sec:musk`, "clustering instances with k-means at K = 20 (results
at K = 10 are qualitatively similar; see scripts/musk.R)".
**Observation**: the results file does carry K10 LOO fits (MUSK1 K10 AUC 0.711
vs K20 0.791; MUSK2 K10 AUC 0.604 vs K20 0.595), so "qualitatively similar" is
defensible but the K10 numbers are not reported. For a benchmark where the
discretization is the admitted weakness, one sentence with the K10 LOO AUCs
would make "qualitatively similar" verifiable rather than asserted. Optional.

### MET-4 (MINOR): boundary detection tolerance gap (carried from prior review M10)
`fit_or_mle` uses `lower = 1e-8`; boundary is detected at `s <= 1e-6`. The
100-fold gap is fine in practice (the eta_hat values are either order-1e-1 or
pinned at 1e-8, cleanly separated), but the validation section should state the
boundary threshold so the boundary counts are reproducible. Low effort.

## Verdict from the methodology lens
Sound design, good reproducibility, one must-fix reporting defect (MET-1) that
also surfaces as an on-page self-contradiction. Everything else is polish.
