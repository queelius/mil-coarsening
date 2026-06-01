# Logic Checker Report

**Paper**: Coarsening at random for multiple instance learning
**Date**: 2026-05-26

## Scope

Verified the three theorems, their proof sketches, the derivation in
`identifiability.tex`, the noisy-OR firing-rate confound, and the
score derivation re-quoted in `validation.tex`.

## Verified correct

### Theorem 2 (`thm:bag-total`), interior-MLE score equation

The proof sketch reads:

> Direct differentiation of $\log L(\bm s) = \sum_i [Y_i \log(1 - e^{-S_i}) + (1-Y_i)(-S_i)]$, $S_i = \bm m_i^\top \bm s$, gives $\partial_{s_k}\log L = \sum_i m_{ik}(Y_i - p_i)/p_i$ at any interior point.

Re-derived independently. Differentiating term by term and using
$p_i = 1 - e^{-S_i}$, $1-p_i = e^{-S_i}$:

$$\partial_{s_k}\log L = \sum_i m_{ik}\left[Y_i \cdot \frac{1-p_i}{p_i} - (1-Y_i)\right]
= \sum_i m_{ik} \cdot \frac{Y_i(1-p_i) - (1-Y_i)p_i}{p_i}
= \sum_i m_{ik}\frac{Y_i - p_i}{p_i}.$$

Setting to zero yields $M^\top D^{-1}(Y - p) = 0$ with
$D = \mathrm{diag}(p_i)$, matching equation (3) and Theorem 2 exactly.
The remark on cloglog non-canonicity is correct: the unweighted moment
identity $M^\top(Y - \hat p)=0$ holds only for the canonical (logit)
link, not for cloglog.

The empirical evidence in `validation.tex` (`scripts/run.R` Exp 2:
median weighted residual $4.58\times 10^{-7}$, median unweighted
residual $4.71$) confirms the corrected form.

### Theorem 1 (`thm:rank`)

The rank-condition argument is a clean translation of `thm:bg-id`.
Both directions verified:

- Necessity: any null-space vector $v \in \ker M$ with
  $\bm s + tv$ in the nonneg orthant gives observational equivalence.
- Sufficiency: $\bm s \mapsto M\bm s$ injective combined with cloglog
  GLM regularity identifies the linear predictor and hence $\bm s$.

The remark "singleton bags contribute unit-vector rows $\bm e_k$" is
correct.

### Noisy-OR likelihood (`rem:firing-rate`)

Re-derived:

$$\Prob\{Y=0\mid m\} = \prod_k \E[(1-\rho)^{n_{ik}^+}]
= \prod_k (1-\eta_k + \eta_k(1-\rho))^{m_{ik}}
= \prod_k (1-\rho\eta_k)^{m_{ik}}.$$

So only the products $\rho\eta_k$ are identified from bag labels.
Confirmed.

## Issues

### MAJOR. The singleton-bag fix for the firing-rate confound is overclaimed

In `rem:firing-rate` (`identifiability.tex` line 53):

> Singleton bags of any one type pin $\rho$ and restore absolute calibration.

This is not correct as stated. A singleton bag of type $k$ under
noisy-OR has $P\{Y=1\} = \rho\eta_k$: the bag-label distribution
involves the same product $\rho\eta_k$ that the multi-instance bags
identify. Adding singleton bags whose only observable is the *bag
label* does **not** separate $\rho$ from $\eta_k$.

What does separate them:
- Singleton bags whose *instance label* $y_j$ is directly observed
  (not just the bag-label after the firing step), since
  $P\{y_j=1\}=\eta_k$ does not involve $\rho$. This is what Exp 1c
  actually does: "each singleton's label is Bernoulli$(\eta_k)$",
  i.e., the latent instance label is observed directly.
- A type with a known $\eta_k$ (a positive control whose intrinsic
  positivity is calibrated externally). This is the precise analogue
  of the ERCC spike-ins in scRNA-seq, where the spike-in
  *concentrations* are known.

The remark conflates these two notions of "singleton bag." The
distinction is structurally important: in scRNA-seq, ERCC works
because spike-in concentrations are known; in MIL, the equivalent is
either ground-truth instance labels (gold-standard annotation, not
just an "instance-level bag") or a calibration type.

**Fix**: rewrite the last two sentences of `rem:firing-rate` to read
something like:

> Singleton bags do not break the confound on their own: a singleton
> bag of type $k$ still has $P\{Y=1\}=\rho\eta_k$. Absolute
> calibration requires either (i) direct observation of an instance
> label (a singleton whose latent $y_j$ is recorded, bypassing the
> firing step), or (ii) a positive-control type with externally
> known $\eta_k$. This is the discrete-label analogue of ERCC
> spike-ins in scRNA-seq, where known spike-in concentrations
> calibrate the capture-efficiency gain.

The empirical demonstration in `validation.tex` is consistent with
(i): Exp 1c records the singleton's Bernoulli label directly, not the
post-firing bag label. So the implementation is correct; the
exposition needs to acknowledge that this is a stronger ask than a
"singleton bag with observed bag-label."

### MAJOR. Theorem 3 sign / notation in the bias-bound formula

Equation (4) in `methodology.tex` (eq `eq:bias-rule`):

$$\hat s(\bm\epsilon) - \bm s^*
= -\mathcal{I}(\bm s^*)^{-1}\,
  \E\!\big[\partial_{\bm\epsilon}\nabla_{\bm s}\ell(\bm s^*; Y, m)\big]\big|_{\bm\epsilon=\bm 0}\,
  \bm\epsilon
+ O(\|\bm\epsilon\|^2).$$

Two issues, one minor (notation), one substantive (sign).

1. **Notation.** $\ell(\bm s; Y, m)$ as written does not explicitly
   depend on $\bm\epsilon$; only the *distribution* of $(Y, m)$ does.
   So $\partial_{\bm\epsilon}\nabla_{\bm s}\ell(\bm s; Y, m) = 0$
   pointwise. The intended object is
   $\partial_{\bm\epsilon}\E_{\bm\epsilon}[\nabla_{\bm s}\ell(\bm s^*; Y, m)]$
   evaluated at $\bm\epsilon=0$, i.e., the derivative of the expected
   score under the perturbed measure. The current expression
   commutes $\partial_{\bm\epsilon}$ with $\E$, which is only valid
   when both are taken with respect to compatible measures. State the
   object as $\partial_{\bm\epsilon}\E_{\bm\epsilon}[\,\cdot\,]$ to
   avoid ambiguity.

2. **Sign.** From the implicit-function expansion of the M-estimator
   estimating equation $\E_{\bm\epsilon}[\nabla_{\bm s}\ell(\hat{\bm s})] = 0$:

   $$\E_0[\nabla_{\bm s}^2 \ell(\bm s^*)] \cdot \partial_{\bm\epsilon}\hat{\bm s}
   + \partial_{\bm\epsilon}\E_{\bm\epsilon}[\nabla_{\bm s}\ell(\bm s^*)]|_{0} = 0.$$

   With $\mathcal{I}(\bm s^*) = -\E_0[\nabla_{\bm s}^2 \ell(\bm s^*)]$
   (standard convention from the log-likelihood; the paper uses
   $\mathcal{I}$ for the Fisher information), the solution is

   $$\partial_{\bm\epsilon}\hat{\bm s}
   = +\mathcal{I}(\bm s^*)^{-1}\,\partial_{\bm\epsilon}\E_{\bm\epsilon}[\nabla_{\bm s}\ell(\bm s^*)]|_{0}.$$

   The paper has a leading minus sign, which is wrong under the
   standard $\mathcal I = -\E[\nabla^2 \ell]$ convention. Either:
   (a) flip the sign in (4); or
   (b) define $\mathcal I = +\E[\nabla^2 \ell]$ in the lead-in
   text (note: this is *negative* under standard regularity, so
   $\mathcal I^{-1}$ would be negative definite, which is unusual);
   or (c) define $\mathcal I$ via the variance of the score (the
   information matrix proper), in which case $\mathcal I$ is
   positive definite and the sign is $+$ as in (a).

   The likeliest fix is option (a): drop the leading minus. The
   conclusion ("first-order bias is linear in $\bm\epsilon$, zero at
   $\bm\epsilon=0$") survives unchanged.

### MINOR. Interior-MLE qualifier in Theorem 2 needs an "all bags non-empty" footnote

The derivation requires $p_i > 0$ for all $i$, which fails if any
bag has $m_i = 0$ (empty bag). Empty bags carry zero likelihood
information under deterministic OR ($Y_i = 0$ deterministically and
$\partial S_i / \partial s_k = 0$), so the standard handling is to
exclude them from the dataset. A one-line footnote stating "we
assume $m_i \neq 0$ for all bags, which is automatic in any MIL
dataset" would close the gap.

### MINOR. The continuous-feature extension is referenced but not previewed

The proof sketch of `thm:rank` ends with "the continuous-feature
extension in which $M$ is replaced by the Gram matrix of the
instance feature map, is in `towell2026milcoarsening`." For a
conference paper this is acceptable, but one sentence on the
intended replacement object ("the Gram matrix $\Phi^\top\Phi$ of an
embedding $\Phi: \mathcal X \to \R^d$") would help the reader see the
shape of the extension.

### MINOR. The C1 / collective-MIL connection in Section 5.3 elides a subtlety

The methodology section claims:

> Collective assumptions violate C1, because a bag can be ``positive''
> with no individually positive instance (a threshold rule with $r>1$,
> or a proportion rule).

Strictly, threshold-$r$ with $r > 1$ requires multiple positive
instances but still requires *at least one* positive instance; the
positive bag still contains the cause(s). C1 is violated more
sharply by *emergent* collective rules where a bag can be positive
with zero positive instances (e.g., a bag-level feature that depends
on the joint distribution but not on any individual instance's
positivity). Threshold-$r$ violates a *stronger* condition: that the
single masked cause (the one positive instance) be in the candidate
set. For $r > 1$ there is no single masked cause; there is a set.
The framing is approximately correct but the precise C1-violation
mode for threshold-$r$ is that the cause is a *set*, not that the
cause is *absent*. A one-sentence clarification would tighten the
recovered taxonomy.

## Confidence

High on all findings above. The Theorem 2 score derivation was
verified independently; the noisy-OR likelihood was re-derived; the
singleton-confound issue was checked against `scripts/run.R` (the
implementation directly observes the singleton's Bernoulli label,
which is consistent with the corrected interpretation). The bias-
bound sign issue is a standard textbook expansion and the sign error
is unambiguous.
