# Methodology Auditor Report

**Paper**: Coarsening at random for multiple instance learning
**Date**: 2026-05-26

## Scope

Reviewed the simulation protocol (`scripts/sim.R`, `scripts/run.R`),
the validation section, the deferred real-data plan, and the
practical claims attached to each theorem.

## Reproducibility

The simulation is reproducible from seed `20260523`. I confirmed
this by re-loading `results.rds` directly:

- Exp 2 weighted residual median: 4.58e-7 (paper says 4.6e-7) ✓
- Exp 2 unweighted residual median: 4.71 (paper says 4.7) ✓
- Exp 2 boundary-replicate count: 5 of 30 (paper says 5 of 30) ✓
- Exp 3 noisy-OR ratios at $\rho=0.9$, $\rho=0.7$, $\rho=0.5$:
  numerical values match the paper's reported triplets ✓

The simulation script structure is clean: `sim.R` is pure (no I/O,
no side effects), `run.R` is the driver, results are serialized.
This is the right factoring for a paper-backing simulation.

## Issues

### MAJOR. Single-seed validation, conclusions not stress-tested

All numbers in `validation.tex` come from a single seed
(`20260523`). The conclusions are robust in some respects and
fragile in others:

- **Robust**: Exp 1's rank-deficient collapse to machine precision
  (1.6e-15) is an algebraic identity, not a sample-size question;
  it will be machine-precision at every seed.
- **Robust**: Exp 2's interior-MLE residual at optimizer tolerance
  is a fixed-point property; it will hold at every seed.
- **Fragile**: Exp 2's boundary-MLE count (5 of 30) and the
  specific boundary residual values are stochastic. They will vary
  across seeds, possibly substantially given $K=4$, $N=400$, and
  the smallest $\eta_k = 0.05$ being marginal for L-BFGS-B's lower
  bound `1e-8`.
- **Fragile**: Exp 3's specific ratio triplets are sample
  realizations; the *qualitative* claim ($\hat\eta/\eta \approx \rho$)
  is robust but the digit-by-digit numbers will move.

**Fix**: rerun Exp 2 and Exp 3 across multiple seeds (say, 20 seeds
of 30 reps each, or a single run with 100--200 replicates) and
report median ± IQR, or median ± min/max across seeds, rather than
point values from one realization. The Exp 1 numbers can stay as a
single seed since the substantive content is the algebraic collapse,
which is seed-independent.

This is the difference between "the simulation supports the
theorems" (true) and "the reported numbers are reproducible
generalizations" (currently only weakly evidenced).

### MAJOR. Exp 1's full-rank max-abs error of 0.038 is anomalously high

For $N = 600$ bags, $K = 5$, $\eta = (0.05, 0.10, 0.20, 0.30, 0.50)$,
the reported max-abs error is 0.038. For the bag-OR MLE with a
non-degenerate design, the asymptotic standard error per coordinate
should be roughly $1/\sqrt{N \cdot \text{eff. instances per type}}$,
which for $N=600$ and bag-size Poisson(8) (so ~$\lambda N/K = 960$
instances per type in expectation) puts the SE per $\eta_k$ in the
$0.01$--$0.03$ range. A max-abs error of $0.038$ across 5 types is
plausibly within sampling noise but is on the high side.

It is also a single seed. Report a histogram or the per-type errors,
not just the max-abs. The current presentation reads as "the
estimator is precise" but is one realization of a noisy max-of-5
statistic. A box of per-type sampling error across seeds would be
much more informative.

### MAJOR. Real-data plan exists in name only

The "Real-data plan" subsection lists MUSK, Elephant/Fox/Tiger, and
CAMELYON-style pathology but reports no executed analyses.
`HANDOFF.md` flags this as Tier 1 (needed for submission). The
abstract and introduction promise "a diagnostic to run before
trusting instance-level outputs"; without a real-data demonstration,
that promise is unsupported. The contributions list includes
"A simulation and real-data validation protocol... on MUSK and
image-MIL benchmarks, with weakly supervised computational pathology
as the headline application" but the paper itself only delivers the
simulation.

**Severity here depends on venue.** For a methods/theory paper at
AISTATS or a workshop, the simulation is sufficient; for an
applied-MIL venue or for a paper that wants to be cited by
pathology methodologists, a real-data result on at least MUSK1/MUSK2
is expected. The text should be tightened to match what is actually
done: drop "real-data validation protocol" from the contributions
or replace it with "a simulation validation protocol; real-data
benchmarks deferred to the full version."

The abstract's claim "supplies a diagnostic to run before trusting
instance-level outputs" is testable on real bags right now: compute
$\mathrm{rank}(M)$ on MUSK1 and report whether the design is full
rank or rank-deficient. This would be a small but real contribution
that does not require fitting any model.

### MAJOR. Exp 3 demonstrates only one direction of the firing-rate confound

The noisy-OR experiment shows that fitting a deterministic-OR model
to noisy-OR data recovers $\rho\eta$. That is one direction. The
practitioner-facing claim is that the confound *cannot be broken
without auxiliary information* (`rem:firing-rate`). The natural
companion experiment is: take two parameter pairs
$(\rho_1, \eta_1) \neq (\rho_2, \eta_2)$ with
$\rho_1\eta_1 = \rho_2\eta_2$, generate data from each, and show that
the bag-OR likelihoods are statistically indistinguishable.
`HANDOFF.md` Tier 2 flags exactly this.

This is a small addition (a few dozen lines of R) and would
substantially strengthen the firing-rate-confound discussion. The
current Exp 3 evidence is consistent with "the estimator is biased,"
which is weaker than "the parameter is non-identified."

### MAJOR (cross-link with logic-checker). The singleton-bag fix in Exp 1c does not match the textual description

Exp 1c is described as "adding 20 singleton bags per type" and the
narrative implication is that singleton bags break the rank
deficiency. The code does:

```r
singleton_Y <- unlist(lapply(seq_len(K), function(k)
  stats::rbinom(per_type_singletons, 1L, eta_true[k])))
```

That is, each singleton's label is a Bernoulli draw from the
*latent* per-instance positivity $\eta_k$, **not** the post-firing
or noisy bag label. This is correct for the rank-condition
experiment (deterministic OR), but if the same singleton-augmentation
pattern were used under noisy-OR (as `rem:firing-rate` claims would
break the confound), the singleton would have to be either
(i) a direct instance-label observation (bypass the firing step),
or (ii) a calibrated control. The simulation code implements (i);
the paper's text in `rem:firing-rate` reads as if a singleton *bag
label* under noisy-OR would suffice, which is incorrect.

The validation section should explicitly note: "singleton augmentation
in Exp 1c records the latent instance label directly, not the
post-firing bag label. Under noisy-OR with only bag-label
singletons, the confound persists; instance-label or calibration
information is required."

### MINOR. L-BFGS-B box-constraint choice and the boundary-MLE handling

The lower bound `lower = 1e-8` (in `fit_or_mle`) is treated as the
boundary. Replicates with at least one $\hat s_k \leq 10^{-6}$ are
flagged as "boundary" in `run_exp2`. The tolerance mismatch (lower
bound $10^{-8}$, boundary detection $10^{-6}$) is fine in practice
but should be documented in the validation section. A reviewer
asking "what counts as boundary?" will not find a clear answer.

### MINOR. The "max absolute error 0.038" comparison to a "sampling-noise floor" is asserted, not computed

`validation.tex` line 33 says "(sampling-noise floor for this $N$)"
parenthetically. A one-line analytical or Monte-Carlo benchmark for
what the sampling-noise floor *is* for the design would let the
reader see this is normal, not optimistic.

### SUGGESTION. The bias bound (Theorem 3) is not directly validated

Exp 3 shows the bias *exists* under noisy-OR and label noise but
does not validate the *form* of `thm:bias-rule`, i.e., the linear-in-
$\bm\epsilon$ first-order expansion. The paper does claim "the bias
is well-approximated as linear in $\epsilon$ for small $\epsilon$
(the first-order Taylor prediction of (4)) and grows super-linearly
for $\epsilon \geq 0.1$." This is the right qualitative observation
but a regression of $\hat\eta - \eta$ on $\epsilon$ with a linear-
plus-quadratic fit, with the linear coefficient compared to the
predicted sensitivity from (4), would directly validate the
theorem. Currently the theorem is asserted and the bias is
observed; the bridge between the two is informal.

### SUGGESTION. The rank diagnostic should appear as a numeric procedure, not just an abstract condition

The abstract promises "a diagnostic to run before trusting
instance-level outputs." The text never operationalizes this as a
runnable algorithm. A 3--4 line algorithm box ("Compute
$\mathrm{rank}(M)$ via SVD; report identified subspace as
$\mathrm{col}(M)$; flag rank-deficient directions") would make the
diagnostic concrete and would let pathology practitioners (the
nominal audience) actually use the result.

## Confidence

High. The simulation code is straightforward to read; I confirmed
the reported numbers against `results.rds`; the cross-issue with
the logic-checker on the firing-rate confound is supported by
direct inspection of `sim.R`.
