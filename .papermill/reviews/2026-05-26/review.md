# Multi-Agent Review Report

**Date**: 2026-05-26
**Paper**: Coarsening at random for multiple instance learning: identifiability conditions for instance-level inference
**Author**: Alexander Towell (SIUE)
**Manuscript**: `/home/spinoza/github/papers/mil-coarsening/main.tex`
**Build**: 12 pages, `make paper` clean
**Recommendation**: **minor revision** (with one substantive logic fix)

## Summary judgment

This is a strong third entry in the coarsening-at-random series.
The bridge between multiple instance learning and the masked-cause
series-system identifiability framework is genuinely productive: it
yields a clean rank condition for instance-type identifiability, a
non-trivial bag-prevalence consistency theorem with a sharp
practical warning about attention weights, and a first-order bias
bound that recovers the Foulds-Frank standard-vs-collective taxonomy
as a C1-preservation partition. The simulation evidence in
`scripts/run.R` is reproducible from the stated seed, the corrected
IRLS-weighted form of Theorem 2 is verified to optimizer tolerance,
and the noisy-OR firing-rate confound is a fresh and useful
observation in the MIL literature. The paper builds clean at 12
pages with no em-dashes, no broken cross-references, and a clean
bibliography.

The recommendation is minor revision rather than ready, principally
because (i) the singleton-bag fix for the firing-rate confound is
stated incorrectly in `rem:firing-rate` (the singleton-*bag* alone
does not separate $\rho$ from $\eta$; what does is direct
observation of the latent instance label, which is what the
simulation actually implements), and (ii) the bias-bound formula in
Theorem 3 has a sign issue under the standard Fisher-information
convention. Both are fixable in a sentence or two. The remaining
issues are about positioning (PLL comparison underdeveloped,
"subsumes" too strong a verb, real-data plan promised in the
abstract but only described not executed) rather than correctness.

## Finding counts

- Critical: 0
- Major: 9 (3 logic-or-substance, 3 methodology, 2 prose-or-novelty, 1 cross-cutting)
- Minor: 11
- Suggestions: 5

## Major issues

### 1. Singleton-bag fix for firing-rate confound overclaimed (source: logic-checker, cross-confirmed by methodology-auditor)

**Location**: `sections/identifiability.tex`, `rem:firing-rate`, lines 53--54.
**Severity**: major (substantive logic).

**Quoted text**: "Singleton bags of any one type pin $\rho$ and restore absolute calibration."

**Problem**: A singleton bag of type $k$ under noisy-OR still has
$P\{Y=1\} = \rho\eta_k$. Adding singleton bags whose only observable is the
post-firing bag label *does not* separate $\rho$ from $\eta_k$. The
confound persists.

What does separate them: (a) direct observation of the latent
instance label $y_j$ (which is in fact what `scripts/sim.R` line 86
implements for Exp 1c: `singleton_Y <- rbinom(per_type_singletons,
1, eta_true[k])` --- the latent label, not the noisy-OR-firing-affected
bag label), or (b) a positive-control type with externally known
$\eta_k$ (the discrete analogue of the ERCC spike-in's known
concentration in scRNA-seq).

**Suggestion**: rewrite the closing two sentences of `rem:firing-rate`
to read:

> Singleton bags do not break the confound on their own: a singleton
> bag of type $k$ still has $P\{Y=1\}=\rho\eta_k$. Absolute
> calibration requires either (i) direct observation of an instance
> label (a singleton whose latent $y_j$ is recorded, bypassing the
> firing step), or (ii) a positive-control type with externally
> known $\eta_k$. This is the discrete-label analogue of ERCC
> spike-ins in scRNA-seq, where known spike-in concentrations
> calibrate the capture-efficiency gain.

The simulation implementation is correct as written; only the text
overstates what singletons alone accomplish.

**Cross-verified**: yes, by methodology-auditor against
`scripts/sim.R` and `scripts/run.R`.

### 2. Theorem 3 has a sign error in the first-order bias formula (source: logic-checker)

**Location**: `sections/methodology.tex`, equation `eq:bias-rule` (line 51--57).
**Severity**: major (correctness).

**Quoted text**:
$$\hat{\bm s}(\bm\epsilon) - \bm s^* = -\mathcal{I}(\bm s^*)^{-1} \E[\partial_{\bm\epsilon}\nabla_{\bm s}\ell(\bm s^*; Y, \bm m)]|_{\bm\epsilon=0} \bm\epsilon + O(\|\bm\epsilon\|^2)$$

**Problem**: Under the standard convention
$\mathcal I = -\E[\nabla_{\bm s}^2 \ell]$, the implicit-function
expansion of the M-estimator estimating equation gives a leading
$+\mathcal I^{-1}$, not $-\mathcal I^{-1}$. Additionally, the inner
expression has a notational ambiguity: $\ell$ does not explicitly
depend on $\bm\epsilon$, only the measure does, so
$\partial_{\bm\epsilon}\nabla_{\bm s}\ell = 0$ pointwise; the
intended object is $\partial_{\bm\epsilon}\E_{\bm\epsilon}[\nabla_{\bm s}\ell(\bm s^*)]|_0$.

**Suggestion**: rewrite as
$$\hat{\bm s}(\bm\epsilon) - \bm s^*
= \mathcal{I}(\bm s^*)^{-1}\,
\frac{\partial}{\partial\bm\epsilon}\E_{\bm\epsilon}[\nabla_{\bm s}\ell(\bm s^*; Y, \bm m)]\Big|_{\bm\epsilon=0}\bm\epsilon
+ O(\|\bm\epsilon\|^2).$$

Or, equivalently, keep the minus sign and define $\mathcal I = +\E[\nabla^2\ell]$
in a footnote (less standard). The conclusion of the theorem (linear
in $\bm\epsilon$, zero at $\bm\epsilon=0$) is unaffected.

**Cross-verified**: this is a textbook calculation; standard reference
is van der Vaart 1998, "Asymptotic Statistics," Chapter 5.

### 3. Single-seed validation, several reported numbers are sample realizations (source: methodology-auditor)

**Location**: `sections/validation.tex` throughout.
**Severity**: major (rigor).

**Problem**: All numbers in `validation.tex` come from seed
`20260523`. The qualitative claims (rank collapse to machine
precision, IRLS-weighted residual at optimizer tolerance, noisy-OR
ratio tracking $\rho$) are robust to seed. The *specific numbers*
(0.038, 0.060, 0.095, 4.6e-7, 4.7, ratio triplets like
(0.99, 0.84, 0.97, 0.93)) are point realizations of stochastic
statistics and may move under reseeding. The boundary-MLE count (5
of 30) is particularly seed-sensitive.

**Suggestion**: rerun Exp 2 and Exp 3 with 100--200 replicates per
cell, or across 20 seeds of 30 reps each, and report median ±
IQR or median ± [min, max] across seeds. Exp 1's machine-precision
collapse can stay as a single seed because it is an algebraic
identity.

### 4. Real-data plan is described but not executed; abstract overclaims (source: methodology-auditor, cross-confirmed by prose-auditor)

**Location**: abstract (line 95: "supplies a diagnostic to run before trusting instance-level outputs"); contributions list (`introduction.tex` lines 103--107); `sections/validation.tex` "Real-data plan" subsection.
**Severity**: major (alignment between promises and deliverables).

**Problem**: The paper promises "a simulation and real-data
validation protocol on MUSK and image-MIL benchmarks, with weakly
supervised computational pathology as the headline application,"
but delivers only the simulation. The abstract's promise of "a
diagnostic to run before trusting instance-level outputs" is
testable on real bags with minimal effort (compute $\mathrm{rank}(M)$
on MUSK1's bag-by-instance-feature design and report).

**Suggestion**: either tighten the contributions and abstract to
match the simulation-only delivery, or run a minimal real-data
check on MUSK1 (rank of the composition matrix, identified vs.
unidentified directions). The latter is the higher-value path and
is well within reach for a revision.

### 5. "Subsumes" is too strong a verb (source: prose-auditor, cross-confirmed by novelty-assessor)

**Location**: abstract; `introduction.tex` line 94; `discussion.tex`
section heading; `conclusion.tex` line 17.
**Severity**: major (claim calibration).

**Problem**: The paper's framework *names* and *places* the
assumptions of mi-SVM, Diverse Density, attention-MIL, and CLAM,
but does not derive their estimators from the framework's
likelihood. "Subsumes" implies the latter. The actual contribution
is that the framework supplies a vocabulary for what each method
assumes.

**Suggestion**: replace "subsumes [...] as special cases" with
"places [...] within one identifiability framework" or "names the
bag-formation and aggregation assumption each method makes."

### 6. The "dual of partial-label learning" claim is asserted but not developed (source: novelty-assessor)

**Location**: `sections/introduction.tex` lines 34--38.
**Severity**: major (positioning).

**Problem**: The introduction's one-sentence mention of partial-label
learning (Cour, Sapp, Taskar 2011) as the dual coarsening is the
paper's weakest novelty defense. A reviewer who knows PLL may
identify this framework as "essentially the MIL case of Cour et
al.'s ambiguity framework" without further detail. The duality is
real but underdeveloped.

**Suggestion**: add a half-page subsection (in discussion or
methodology) explicitly comparing the PLL ambiguity condition to
the MIL rank condition and explaining whether they are dual
statements of the same coarsening result, distinct identifiability
results in a common framework, or independent. `HANDOFF.md` Tier 3
already flags this; resolving it would strengthen the novelty case.

### 7. The firing-rate confound demonstration is one-sided (source: methodology-auditor)

**Location**: `sections/validation.tex`, Exp 3 noisy-OR paragraph (lines 90--99).
**Severity**: major (evidentiary completeness).

**Problem**: Exp 3 shows the bag-OR estimator recovers $\rho\eta$
when applied to noisy-OR data. This shows the bias *exists* but
not that the parameter is *non-identified*. The cleanest
demonstration is: take two pairs $(\rho_1, \eta_1) \neq (\rho_2, \eta_2)$
with $\rho_1\eta_1 = \rho_2\eta_2$, generate data from each, fit
the bag-OR likelihood from each, and show the likelihood values are
indistinguishable.

**Suggestion**: add a brief experiment (a few dozen lines in
`run.R`) demonstrating the confound directly. `HANDOFF.md` Tier 2
already flags this.

### 8. The C1-violation framing for collective MIL elides a subtlety (source: logic-checker)

**Location**: `sections/methodology.tex` lines 88--98.
**Severity**: major (precision).

**Quoted text**: "Collective assumptions violate C1, because a bag
can be ``positive'' with no individually positive instance (a
threshold rule with $r > 1$, or a proportion rule)."

**Problem**: For threshold-$r$ with $r > 1$, the positive bag *does*
contain positive instances; what fails is that there is no longer a
*single* masked cause. C1 violation is more accurately stated as
"the cause is not a singleton within the candidate set" rather than
"the cause is absent from the candidate set." For pure emergent
rules (where bag positivity depends on instance covariation
independent of individual positivity), C1 fails in the strong sense
the text describes. The taxonomy recovery is correct in spirit but
the precise C1-violation mode for threshold-$r$ deserves a
clarifying sentence.

**Suggestion**: rephrase as "Collective assumptions correspond to
generalizations of the masked-cause setup in which the masked
quantity is a *subset* of instances (threshold-$r$, proportion) or
no individual instance is the cause (emergent collective). C1 in
its singleton-cause form fails in both cases; the framework
naturally extends to the subset-cause case but the bias bound
quantifies the cost of pretending the cause is a singleton."

### 9. Proof sketches defer to in-preparation manuscripts that are not yet accessible (source: novelty-assessor, citation-verifier)

**Location**: `sections/identifiability.tex` line 35; `sections/methodology.tex` lines 75--78.
**Severity**: major (verifiability).

**Problem**: Theorem 1's proof sketch defers the continuous-feature
extension to `towell2026milcoarsening`; Theorem 2's parallel
derivation defers to `towell2026scrnacoarsening` §3; Theorem 3's
full proof defers to `towell2026spatialcoarsening` §5,
`towell2026scrnacoarsening` §7, and `towell2026milcoarsening`. All
five Towell self-citations are "Manuscript in preparation." A
conference reviewer cannot independently verify the proofs without
access to these.

**Suggestion**: (a) deposit `towell2026masked` and the scrna-coarsening
precursor on arXiv/Zenodo before submission and update `.bib` with
URLs/DOIs; (b) for Theorem 3, cite a textbook reference (van der
Vaart 1998, Chapter 5) for the M-estimator perturbation expansion
so the reader has a verifiable handle on the result type even
without the companion papers.

## Minor issues

### M1. Empty-bag edge case in Theorem 2 (source: logic-checker)

**Location**: `sections/identifiability.tex`, `thm:bag-total`.

The derivation of the IRLS-weighted score requires $p_i > 0$ for all
$i$, which excludes empty bags ($m_i = 0$). Add a one-line footnote:
"we assume $m_i \neq 0$ for all bags, which is standard in MIL."

### M2. Continuous-feature extension is referenced but not previewed (source: logic-checker)

**Location**: `sections/identifiability.tex` line 34.

One sentence on the replacement object ("the Gram matrix
$\Phi^\top\Phi$ of an embedding $\Phi: \mathcal X \to \R^d$") would
let the reader see the shape of the extension.

### M3. Three `\cite{}` should be `\citet{}` (source: citation-verifier, format-validator)

**Locations**: `sections/discussion.tex` line 46;
`sections/identifiability.tex` line 35;
`sections/methodology.tex` line 78.

Use `\citet{}` for noun-form citations to avoid parenthetical reading.

### M4. Five "Manuscript in preparation" self-citations (source: citation-verifier)

**Location**: `refs.bib`.

A conference reviewer will see five non-archival self-citations.
Where possible, deposit on arXiv/Zenodo and add `url`/`doi`/`eprint`
fields. Specifically, `towell2026masked` is described in HANDOFF as
a Zenodo preprint but the `.bib` entry has no URL.

### M5. Heitjan-Rubin and Dietterich entries missing DOIs (source: citation-verifier)

`heitjan1991ignorability`: DOI 10.1214/aos/1176348396.
`dietterich1997solving`: DOI 10.1016/S0004-3702(96)00034-3.
Add for completeness.

### M6. Pearl 1988 page reference (source: citation-verifier)

Noisy-OR is in Pearl 1988 §4.3.2. Add the locator when citing
`pearl1988probabilistic` in `methodology.tex` line 31.

### M7. CAMELYON16 dataset citation (source: citation-verifier)

`bejnordi2017diagnostic` is the algorithm-comparison paper; for the
dataset itself, the conventional citation is Litjens et al. 2018
GigaScience. Optional, depending on what the full-version real-data
analysis actually uses.

### M8. "Isomorphic" is the wrong word (source: prose-auditor)

`sections/introduction.tex` line 42: "MIL is mathematically
isomorphic to..." The correspondence is a reduction or an instance-
of, not a category-theoretic isomorphism. Replace with "is an
instance of" or "reduces to" or "can be reformulated as."

### M9. Hyperref warnings from `\cref` inside `\paragraph{}` (source: format-validator)

`main.log` lines 576, 580, 585. Cosmetic only. Optional fix with
`\texorpdfstring`. Not blocking.

### M10. L-BFGS-B lower-bound tolerance documentation (source: methodology-auditor)

`fit_or_mle` uses `lower = 1e-8`; `run_exp2` detects "boundary" at
`s ≤ 1e-6`. The 100-fold gap is fine in practice but should be
documented in the validation section.

### M11. Single-paragraph bridge in introduction (source: prose-auditor)

`sections/introduction.tex` lines 40--67 do the entire conceptual
work of justifying the paper in one paragraph; the translation table
appears two sections later. Pull the table forward or add a short
numbered correspondence list to the bridge subsection so the reader
can verify the claim before reading further.

## Suggested revisions, prioritized

### Tier 1 (substantive, required for revision acceptance)

1. **Fix the singleton-bag firing-rate confound text** (`rem:firing-
   rate`). Rewrite the closing two sentences per the corrected
   interpretation. (Logic correctness, one paragraph.)
2. **Fix the sign and notation in eq (4)** (`thm:bias-rule`). Either
   drop the leading minus or restate the differentiation as $\partial_\epsilon
   \E_\epsilon[\nabla_s \ell]$ explicitly. (One equation.)
3. **Rerun Exp 2 and Exp 3 with multiple replicates / seeds.** Report
   median ± IQR. (A few hours of compute, no theory change.)
4. **Tighten the abstract and contributions list to match what is
   delivered**: drop "real-data" from the contributions or run the
   rank diagnostic on MUSK1. (One paragraph either way.)

### Tier 2 (positioning, strongly recommended)

5. **Develop the PLL comparison** into a half-page subsection.
   (`HANDOFF.md` Tier 3 already lists this.)
6. **Replace "subsumes" with weaker, accurate language** throughout
   (abstract, intro contributions, discussion).
7. **Add the firing-rate confound's two-parameter-pair demonstration**
   to Exp 3 (`HANDOFF.md` Tier 2).
8. **Add citations to Doran & Ray 2014** ("true MIL" condition),
   **Halpern & Sontag 2013** (noisy-OR identifiability), and
   **Quadrianto et al. 2009** (label-proportion learning) for
   adjacent-but-different work.

### Tier 3 (polish)

9. **Deposit foundational manuscripts** (`towell2026masked`,
   scrna-coarsening precursor) and add URLs/DOIs to the .bib.
10. **Cite a textbook reference for the M-estimator expansion** in
    Theorem 3's proof sketch (van der Vaart 1998, Ch. 5).
11. **Pull the translation table forward** or add a compact
    correspondence list to the introduction's bridge subsection.
12. **Move the "what the framework does not address" subsection
    earlier**, or add a forward pointer from `translation.tex`.
13. **Convert validation numbers to a small table** for the rank
    experiment and the noisy-OR experiment.

## Specialist findings

### Logic and proofs (logic-checker)

The score derivation for Theorem 2 was re-verified line by line and
matches the corrected IRLS-weighted form. The rank condition and the
noisy-OR likelihood derivation are correct. Two issues stood out:
the singleton-bag fix for the firing-rate confound is overstated
(major issue 1), and the bias-bound formula has a sign error under
the standard Fisher-information convention (major issue 2). Three
minor logical or precision issues are listed above (M1, M2, and the
C1-violation framing in major issue 8).

### Methodology (methodology-auditor)

The simulation is well factored (pure `sim.R`, driver `run.R`,
serialized results) and reproducible from the stated seed (I
confirmed numerical values against `results.rds` directly). The
main concerns are evidentiary: single-seed reporting (major issue
3), one-sided demonstration of the firing-rate confound (major
issue 7), and the gap between the abstract's "diagnostic" promise
and the validation section's simulation-only delivery (major issue
4). The real-data plan exists in name only; either run a minimal
real-data check or remove the contribution claim.

### Writing and presentation (prose-auditor)

Narrative arc is clean, section sizes are well balanced, and the
"central message" close to the introduction earns its place. Main
prose issues are calibration of strong words ("subsumes,"
"isomorphic") and the underdeveloped PLL comparison. The proof
sketches read more as references-to-other-papers than as
derivations; Theorem 3's sketch in particular reduces to three
pointers and no actual derivation. The author's no-em-dashes
convention is held with zero violations.

### Citations and references (citation-verifier)

Bibliography is clean: all cited references resolve, no
multiply-defined or undefined cross-references, dormant entries in
`refs.bib` are correctly excluded from the compiled `.bbl`. Five
"Manuscript in preparation" Towell self-citations are the main
verifiability concern (M4). Minor: three `\cite{}` calls should be
`\citet{}` (M3), and a few foundational references could use DOIs
(M5, M6).

### Formatting and production (format-validator)

`make paper` produces a clean 12-page PDF with no warnings beyond
three cosmetic hyperref-PDF-string notices for `\cref` inside
`\paragraph{}` headings. All cross-references resolve. Empty
`figures/` directory is deliberate per HANDOFF. Package selection,
theorem environments, and math macros are clean.

### Novelty and contribution (novelty-assessor)

The novelty case is solid against MIL-specific prior art (no one
has framed MIL through Heitjan-Rubin C1-C2-C3 before) and against
scRNA-seq prior art (the discrete-label analogue of the spike-in
gap is fresh). The medium-confidence component is the PLL
comparison: Cour, Sapp, Taskar is the most natural prior target and
the paper's one-sentence mention is below what a careful ML reviewer
would want. The "subsumes mi-SVM/DD/attention-MIL/CLAM" claim is
overstated; the framework *places* these methods, it does not
*derive* them.

### Broad literature scout

MIL is a mature field (Dietterich 1997 through CLAM 2021) with a
large methods literature but no prior identifiability-conditions
treatment. The closest prior work on MIL identifiability is Doran
& Ray 2014 "true MIL" condition, which operates at the data-design
level rather than at the parameter-rank level. The
weakly-supervised-learning literature (Zhou 2018) catalogs three
weak-supervision types but does not use coarsening conditions. The
masked-data / competing-risks literature (Heitjan-Rubin 1991,
Goetghebeur-Ryan 1995) has not crossed over to ML weak supervision.
The bridge in this paper appears to be genuinely original.

### Targeted literature scout

The closest prior work on the specific MIL-identifiability question:
Doran & Ray 2014 (Machine Learning) on "true MIL," Sabato & Tishby
2012 on MIL sample complexity, Babenko et al. 2009 on bag-vs-instance
classification. None gives a rank condition; the framework here is
the first to do so. On noisy-OR identifiability: Halpern & Sontag
2013 (UAI) addresses noisy-OR Bayesian networks but in a different
scope (network topology, not bag aggregation). On the partial-label
duality: Cour, Sapp, Taskar 2011 (JMLR) is the standard reference;
Feng et al. 2020 and Liu & Dietterich 2014 give PLL identifiability
results that should be at least cited.

## Review metadata

- Specialists consulted: logic-checker, novelty-assessor,
  methodology-auditor, prose-auditor, citation-verifier,
  format-validator
- Literature scouts: broad and targeted, results in
  `literature-context.md`
- Cross-verifications performed: 3 (singleton-confound fix between
  logic-checker and methodology-auditor; "subsumes" wording between
  prose-auditor and novelty-assessor; abstract overpromise between
  methodology-auditor and prose-auditor)
- Disagreements between specialists: 0
- Hallucination checks: all quoted manuscript text verified against
  the source files
- Simulation re-verification: `results.rds` loaded directly,
  reported numerical values in `validation.tex` match
- HANDOFF.md Tier 1 deferrals respected (real-data, self-contained
  proofs, figures); each is flagged in the review only where the
  abstract or contributions list overreaches what the deferred work
  supports
