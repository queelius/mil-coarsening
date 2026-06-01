# Novelty Assessor Report

**Paper**: Coarsening at random for multiple instance learning
**Date**: 2026-05-26

## Claimed contributions

1. **Bridge** from MIL to masked-data inference, formalizing four
   major methods (mi-SVM, Diverse Density, attention-MIL, CLAM) as
   special cases.
2. **Rank condition** for instance-type identifiability.
3. **Bag-prevalence consistency theorem** showing the bag-OR MLE
   reproduces bag-positive frequencies along $\mathrm{col}(M)$,
   undermining bag-accuracy as a validator for instance scores.
4. **First-order bias bound** under aggregation-rule
   misspecification; recovery of the Foulds-Frank
   standard-vs-collective taxonomy as a C1-preservation statement.
5. **Firing-rate confound under noisy-OR** as the discrete-label
   analogue of the scRNA-seq spike-in capture-efficiency gap.

## Differentiation against the closest related work

### Foulds & Frank 2010, "A review of multi-instance learning assumptions"

This survey organizes MIL methods by their bag-formation assumption
(standard, presence-based, threshold, count, proportion). The MIL-
coarsening paper *recovers* this taxonomy as a C1-preservation
partition. That recovery is genuinely new and is the cleanest
contribution of `methodology.tex`. Foulds & Frank did not write
their taxonomy in identifiability language and did not connect it
to coarsening conditions. **Differentiation: clear.**

### Carbonneau et al. 2018, MIL survey

A broader methods survey. Catalogs methods, doesn't address
identifiability. **No overlap with the present paper's
contribution.**

### Cour, Sapp, Taskar 2011, "Learning from partial labels"

This is the nearest existing identifiability-flavored
weakly-supervised paper. They give an "ambiguity" condition that
serves as a partial-label identifiability condition. The MIL paper
asserts that MIL is the *dual* of partial-label (instance with
candidate label set vs. label with candidate instance set). This
duality is an old folk observation (the dualities between MIL,
partial-label, and label-proportion learning have been discussed in
the LPL/PLL literature for over a decade) but the explicit
formulation as duality through *coarsening of either coordinate of
the joint distribution* is the framework's natural language.

**Issue**: the paper *mentions* this duality (intro lines 35--38)
but does not develop it. The Cour et al. paper gives an
identifiability condition for partial-label; the MIL paper gives an
identifiability condition for MIL; the natural question is whether
these are *the same condition*, or different conditions under the
same framework, or independent. A half-page in the discussion
working out this correspondence would substantially raise the
novelty profile: it would let the paper claim a *unified*
identifiability theory for the class of label-aggregation weak
supervision problems.

**Differentiation: present but underdeveloped.** Without a more
explicit comparison, a reviewer at AISTATS or ICML may ask "why is
this not just the MIL case of Cour et al.'s framework?" The answer
is: Cour et al. work in the partial-label setting (one instance,
many candidate labels), the MIL framework here works in the dual
(many instances, one observed label), and both are instances of
Heitjan-Rubin coarsening of one or the other coordinate. But that
needs to be said.

### Has anyone framed MIL through Heitjan-Rubin C1-C2-C3 before?

**To my knowledge, no.** The masked-data literature
(Heitjan-Rubin 1991, Goetghebeur and Ryan 1995, Lawless and others
in reliability) has not crossed over into MIL, and the MIL
literature has not adopted the coarsening-conditions vocabulary.
The closest cross-references I can identify:

- Cheplygina, Tax, Loog (2015) "On classification with bags,
  groups, and sets" considers MIL within a structured-output
  classification taxonomy but does not invoke coarsening conditions.
- Zhou (2018) "A brief introduction to weakly supervised learning"
  is the standard weak-supervision overview; treats incomplete
  supervision, inexact supervision (MIL), inaccurate supervision as
  three separate threads. No coarsening-conditions framing.
- The propensity-weighted MIL literature (e.g., the noisy-MIL work
  of Bao et al. 2018, Wang et al. 2018) deals with label-noise but
  not with identifiability conditions on the bag design.
- In the partial-label/PLL literature, Liu & Dietterich (2014) and
  Feng et al. (2020) give identifiability conditions for PLL but
  again under the PLL data structure, not in coarsening language.

The Heitjan-Rubin-via-MIL framing is, to the best of my literature
recall, genuinely new. The novelty is solid *provided* the targeted
literature scout (which I am also acting as) does not turn up an
explicit prior MIL-as-coarsening paper. I recommend the broad-
literature scout check this independently as a sanity check.

### The "firing-rate confound" as the discrete analogue of the ERCC spike-in gap

This analogy is real and is one of the more striking observations in
the paper. The structure is: a multiplicative gain parameter ($\rho$
under noisy-OR, capture efficiency in scRNA-seq) factors with the
signal of interest ($\eta_k$, expression rate) and only the product
is identified from the observed channel; an auxiliary
instance-resolved observation (calibrated spike-in / known
positive-control instance) breaks the confound.

This is genuinely new as far as I can find. The MIL community has
identified Diverse Density's noisy-OR parametrization as
problematic in various ways but has not, to my knowledge, named the
non-identifiability as a confound of this specific structure or
connected it to scRNA-seq calibration. The framing is contribution-
grade.

(See logic-checker's note that the "singletons fix the confound"
sentence overclaims; the analogy is correct but the fix story needs
to be stated as "calibrated controls or direct latent-label
observation," not "any singleton bag.")

## Issues

### MAJOR. The "dual of partial-label learning" claim is asserted but not developed

`introduction.tex` lines 35--38:

> The nearest existing identifiability-flavored line is partial-label
> learning \citep{cour2011learning}, in which each \emph{instance}
> carries a candidate \emph{label} set with one correct label; MIL is
> the dual coarsening, in which a candidate \emph{instance} set (the
> bag) carries one observed label.

This is a one-sentence pointer where a paragraph (or a subsection in
the discussion) is warranted. The novelty case against PLL is the
single weakest in the paper: if a reviewer who knows PLL identifies
this framework as "essentially Cour et al. 2011 in the dual
direction," they may discount the contribution. Mitigating this
needs a focused comparison: state the PLL identifiability condition
(Cour et al.'s ambiguity bound), state the MIL identifiability
condition (the rank condition here), and explain whether one implies
the other, whether they are dual statements of the same underlying
coarsening result, or genuinely different.

`HANDOFF.md` Tier 3 flags this as "Position against partial-label
learning (Cour et al. 2011), the closest existing identifiability-
flavored MIL work." The author already knows this is needed.

### MAJOR. The novelty case is weakened by deferral of self-contained proofs

Theorem 1 (rank condition) cites the spatial-coarsening paper for
the structure and `towell2026milcoarsening` for the full proof.
Theorem 2 cites `towell2026scrnacoarsening` Section 3 for parallel
derivations. Theorem 3 cites `towell2026spatialcoarsening` Section 5
and the full version. A reviewer cannot evaluate the *MIL-specific*
content of these theorems without access to the full version. The
proof sketches are present and adequate for the conference format,
but the theorems read as "the rank theorem from spatial-coarsening,
with $P$ renamed to $M$." If that is approximately what they are,
the novelty case becomes "applying a known framework to a new
application," which is acceptable for an application paper but
weakens the theory-paper framing.

The cleanest fix is a one-paragraph "what is new here vs. the
sibling papers" subsection, perhaps in the introduction or
methodology. The genuinely MIL-specific contributions are:

- The cloglog likelihood with $s_k = -\log(1-\eta_k)$ as the
  identifying parametrization (the sibling papers use linear/Poisson
  parametrizations).
- The IRLS-weighted bag-prevalence consistency identity (Theorem 2)
  is structurally different from the cell-total consistency in
  scRNA-seq because the link is non-canonical here and canonical
  there.
- The noisy-OR firing-rate confound, which has no scRNA-seq analogue
  for *discrete* labels until you spell out the analogy.
- The recovery of Foulds-Frank as a C1 partition.

These are real new things; making them explicit will protect against
the "this is just the spatial-coarsening rank theorem renamed"
critique.

### MAJOR. "Subsumes mi-SVM, Diverse Density, attention-MIL, CLAM as special cases" is overstated

The abstract and discussion both claim the framework "subsumes"
these methods. What is actually shown:

- **Diverse Density**: identified as a noisy-OR MLE in our
  parametrization. *Substantively shown* in `translation.tex`.
- **mi-SVM**: identified as a hard-assignment surrogate for the
  candidate-set sum. *Asserted but not derived*.
- **Attention-MIL**: identified as a pooling map whose weights
  estimate parameters only in $\mathrm{col}(M)$. *Asserted as an
  identifiability consequence, not as a derivation of the method.*
- **CLAM**: identified as attention-MIL plus singleton candidate
  sets via clustering. *Reasonable interpretation but not a
  reduction.*

"Subsumes" implies the framework recovers the methods' objectives or
estimators; what is shown is mostly that each method's
*assumptions* fit somewhere in the framework's catalog. This is
useful (it lets the framework name what each method assumes) but it
is not subsumption. **Weaken the language**: "the framework names
the bag-formation and aggregation assumption each method makes"
rather than "the framework subsumes these methods as special cases."

### MINOR. The "structural inversion" comment is well placed but could be stronger

`translation.tex` lines 74--83 flag that in MIL, the *negative* bag
is the fully informative observation (every instance label resolved)
and the *positive* bag is the coarsened one, reversing the scRNA-seq
case. This observation is genuinely useful and worth one more
sentence: it implies that high-positive-prevalence MIL problems
(most bags positive) are *more* coarsened than low-prevalence ones,
which has practical consequences for design (sample more negatives
to recover identifiability faster).

### SUGGESTION. The framework's predictions are testable; the paper does not promise specific predictions

A reviewer at a methods-focused venue will appreciate framework
papers that make testable predictions. The framework as stated
predicts:

- Bag-trained attention scores will *not* match independent
  instance-resolved validation in rank-deficient designs. This is
  testable on any MIL dataset with patch-level annotations.
- The bag-OR MLE applied to noisy-OR data will have $\hat\eta /
  \eta$ approximately constant across types (the constant being
  $\rho$). This is observable in any dataset where instance labels
  are sometimes available.
- The Foulds-Frank standard-assumption methods will degrade
  predictably under collective-assumption data, at a rate first-
  order in the C1 violation.

One paragraph in the discussion enumerating these predictions would
make the framework do real work for the reader.

## Confidence

Medium-high. The novelty case is solid against MIL-specific work
(Foulds-Frank, Carbonneau, Dietterich, mi-SVM, attention-MIL, CLAM)
and against scRNA-seq prior art. The medium-confidence component is
the PLL comparison: Cour, Sapp, Taskar is the most natural prior
target, and the paper's one-sentence mention is below what a
careful reviewer at an ML venue would want.
