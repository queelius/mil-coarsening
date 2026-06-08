# Logic Checker Report

**Paper**: mil-coarsening
**Date**: 2026-06-08
**Scope**: proof correctness, logical-chain integrity, claim support.

## Summary

The mathematics is sound. The two correctness defects flagged in the
2026-05-26 review (the singleton-bag firing-rate overclaim in rem:firing-rate
and the sign of the bias-bound formula in thm:bias-rule) have both been fixed
in this draft, and the fixes are correct. The appendix now carries
self-contained proofs of all four theorems, and I re-derived each. No new
mathematical errors. The remaining logic issues are about labeling and framing,
not derivation: the appendix subsection titles cite stale theorem numbers, and
the "three theorems" framing is in tension with the four theorems actually
stated and proved.

## Verified correct

### thm:rank (rank condition), proof in app:proof-rank
Re-derived both directions. Sufficiency: `P_s` depends on `s` only through `Ms`
(via the strictly increasing `sigma(S) = 1 - e^{-S}`), so `P_s = P_s'` forces
`Ms = Ms'`, and full column rank gives injectivity. Necessity: a nonzero
null vector `v` of `M` and a small `t` with `s + tv` interior produce identical
bag-label laws for distinct eta. Correct, and the nonnegativity-orthant
handling (choosing `s` strictly interior so `s + tv` stays feasible) is right.

### thm:bag-total (bag-prevalence consistency), proof in app:proof-bag-total
The score derivation in eqs (app-score-raw)->(app-score-final) is exact:
`d ell / d s_k = sum_i m_ik (Y_i - p_i)/p_i`, giving the interior identity
`M^T D^{-1}(Y - p_hat) = 0` with `D = diag(p_hat)`. The boundary/KKT handling
is correct (constrained coordinate satisfies the inequality, interior
coordinates the equality). The IRLS-weighting remark is right: the link
`g(mu) = -log(1-mu)` is non-canonical for the Bernoulli family, the `1/p_i`
weights are the link-variance factors, and the unweighted identity does NOT
hold. This matches the synthesis paper's `cor:mil` exactly.

### thm:bias-rule (first-order bias under aggregation perturbation), proof in app:proof-bias-rule
The sign is now correct: the implicit-function expansion of the M-estimator
estimating equation `g(s_hat(eps), eps) = 0`, with `d_s g = -I(s*)` via the
second Bartlett identity at the truth, yields the `+ I^{-1}` leading term. The
prior review's sign defect is resolved. The notation is now clean: the
perturbation enters through the LAW of `Y`, not through `ell`'s formula
(g is defined as `E_eps[grad_s ell]`), resolving the prior "ell does not depend
on eps" ambiguity. The closed-form noisy-OR sensitivity (app-noisy-or-EY,
app-noisy-or-sens) is correctly derived; the appendix even self-documents that
an earlier draft carried the opposite sign in this expansion and that it is now
fixed, with simulation/figures unaffected. That candor is appropriate.

### rem:firing-rate (firing-rate confound)
Now correct. The text states that bag labels under noisy-OR identify only the
products `rho * eta_k`, that a singleton bag of type k does NOT break the
confound (since `P{Y=1 | type-k singleton} = rho eta_k` inherits the same
product), and that only (i) direct observation of the latent instance label or
(ii) a calibrated positive-control type with known eta=1 separates the factors.
This is the corrected statement the 2026-05-26 review prescribed, and it is
logically right. It also matches what the simulation implements (the singleton
augmentation in Exp 1 records the latent Bernoulli label directly, not a
post-firing bag label).

### thm:rank-continuous (continuous-feature rank condition), proof in app:proof-cont-rank
Re-derived; structurally identical to thm:rank with `(M, s) -> (Phi, beta)`.
The under-identification consequence when `d > N` (column rank at most `N`,
`beta` under-identified by `d - N` dimensions, bag-level predictions still
well-defined on the null space) is correct and is exactly the empirical
signature the MUSK continuous refit reports.

## Findings

### LOG-1 (MAJOR): Appendix theorem-number subsection titles are stale and wrong
**Location**: `sections/appendix.tex` lines 10, 102, 160 (subsection titles).
**Quoted text**:
- "Proof of Theorem 1 (rank condition)"
- "Proof of Theorem 2 (bag-prevalence consistency)"
- "Proof of Theorem 3 (aggregation-rule bias)"

**Problem**: The hand-typed numbers do not match the compiled numbering. The
theorem environment shares one counter across theorem/proposition/lemma/
corollary/definition, and `thm:bg-id` (background) is Theorem 1. From
`main.aux`: `thm:rank` = Theorem **2**, `thm:rank-continuous` = Theorem **4**
(this title is coincidentally correct), `thm:bag-total` = Theorem **5**,
`thm:bias-rule` = Theorem **7** (a Remark sits at 6). So the appendix titles
"Theorem 1 / 2 / 3" point a reader to the wrong statements: a reader who flips
to "Proof of Theorem 1" finds the rank proof, but Theorem 1 in the body is the
background identifiability theorem. The in-proof `\cref{thm:...}` calls are
label-based and therefore correct; only the human-readable subsection titles
are wrong. This is a correctness-of-presentation defect that a referee or a
careful reader will hit immediately.

**Suggestion**: replace the hardcoded numbers with `\cref`. For example,
`\subsection{Proof of \cref{thm:rank} (rank condition)}`, and likewise for the
others. This makes the titles track the compiled numbers automatically and
never drift again.

**Cross-verified**: confirmed against `main.aux` newlabel entries (see
format-validator).

### LOG-2 (MINOR): "three theorems" framing undercounts the four proved theorems
**Location**: `sections/appendix.tex` line 6 ("self-contained proofs of the
three theorems stated in Cref{sec:identifiability,sec:methodology}");
`sections/validation.tex` line 4 ("We validate the three theorems");
`sections/introduction.tex` line 120 ("A simulation that confirms the three
theorems"); abstract "We establish: (i)...(ii)...(iii)".

**Problem**: The paper states and proves FOUR theorems: thm:rank,
thm:rank-continuous, thm:bag-total, thm:bias-rule. The "three theorems"
language treats thm:rank-continuous as an extension of thm:rank rather than a
separately numbered result, which is a defensible authorial choice, but the
appendix literally says "proofs of the three theorems" and then provides four
proof subsections (including "Proof of Theorem 4 (continuous-feature rank
condition)"). The internal count is inconsistent.

**Suggestion**: either (a) say "the four theorems" and "(i)...(iv)" where the
continuous extension is counted, or (b) keep "three" but reword the appendix
opener to "self-contained proofs of the three core theorems and the
continuous-feature extension." Option (b) preserves the headline framing.

### LOG-3 (MINOR): thm:bag-total interior identity needs `p_i > 0`, i.e. no empty bags
**Location**: `sections/identifiability.tex` thm:bag-total and
`app:proof-bag-total`.
**Problem**: The `D^{-1}` weighting requires `p_hat_i > 0` for every bag, which
excludes empty bags (`m_i = 0`, giving `p_i = 0`). This is the same edge case
M1 from the 2026-05-26 review; it does not appear to have been addressed.
**Suggestion**: one clause in the theorem statement or a footnote, "assuming
`m_i != 0` for all bags (no empty bags), which is standard in MIL." Low effort.

### LOG-4 (MINOR, precision): C1-violation framing for threshold-r still slightly loose
**Location**: `sections/methodology.tex` lines ~100-108.
**Quoted text**: "Collective assumptions violate C1, because a bag can be
``positive'' with no individually positive instance (a threshold rule with
`r > 1`, or a proportion rule)."
**Problem**: For a threshold-r rule with `r > 1`, a positive bag DOES contain
positive instances; what fails is that the masked cause is no longer a
singleton within the candidate set (it is a size-`r` subset). C1 in its
"cause in candidate set" form is literally still true for threshold-r; what
breaks is the singleton-cause structure. The strong C1 failure ("no individual
instance is the cause") is the emergent/proportion case. The taxonomy recovery
is correct in spirit, and the bias bound correctly quantifies the cost, but the
one-line characterization conflates two distinct violation modes. This is the
prior review's major-8; it appears unaddressed.
**Suggestion**: distinguish the two modes in one sentence: threshold-r and
proportion rules generalize the masked cause to a subset of instances (C1's
singleton-cause form fails), while emergent rules can have no individually
positive instance (C1's support form fails); the bias bound quantifies the cost
of treating either as deterministic OR.

## Cross-checks performed
- Re-derived all four proofs against the body statements: consistent.
- Checked thm:bag-total against synthesis `cor:mil`: identical content.
- Checked rem:firing-rate text against `scripts/sim.R` singleton implementation
  (latent label recorded, not post-firing): consistent.
- Verified the noisy-OR sensitivity sign self-correction note is internally
  coherent with eq (app-noisy-or-EY).
