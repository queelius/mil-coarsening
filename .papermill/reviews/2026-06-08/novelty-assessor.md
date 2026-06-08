# Novelty Assessor Report

**Paper**: mil-coarsening
**Date**: 2026-06-08
**Scope**: contribution clarity, differentiation from prior art, significance.

## Summary

The contribution is real and now well-defended. The core claim, that MIL is an
instance of the masked-data series-system identifiability problem and that the
C1/C2/C3 coarsening conditions port to give a rank condition, a bag-prevalence
consistency identity, and an aggregation-rule bias bound, is novel against the
MIL literature and is differentiated from the closest neighbours. The
"subsumes" overclaim from the 2026-05-26 review is fixed throughout (the paper
now consistently says it "places methods in a common assumption-naming
language" and explicitly states "It does not by itself derive new estimators;
the contribution is diagnostic and structural rather than algorithmic"). The
PLL comparison, previously a one-liner, is now a developed half-page subsection.

The honest framing is the paper's strength: it is upfront that the apparatus is
borrowed (Heitjan-Rubin, Couso et al., the Towell masked-data series) and that
the contribution is the recognition of the isomorphism plus the domain reading.
This is the correct register for an application paper in a framework series and
mirrors the synthesis paper's prior-art honesty.

## What is genuinely new

1. **The rank condition as a pre-hoc identifiability diagnostic for MIL**
   (thm:rank). No prior MIL work states "instance-type positivity is
   identifiable from bag labels iff the bag-by-instance-type composition matrix
   has full column rank." Doran-Ray 2014's "true MIL" condition is the nearest
   existing identifiability statement but operates at the data-design level, not
   the parameter-rank level (see citation gap below).
2. **The bag-prevalence consistency identity as the likelihood-level mechanism
   for the Vanwinckelen et al. 2016 empirical bag-vs-instance gap**
   (thm:bag-total). This is the most compelling novelty move: it converts a
   known empirical phenomenon into a moment-matching statement and identifies
   the rank-deficient subspace as exactly where instance mass is unconstrained.
3. **The firing-rate confound as the discrete-label analogue of the scRNA-seq
   spike-in capture-efficiency gap** (rem:firing-rate). Fresh cross-domain
   observation; the noisy-OR `rho eta` non-separability is known folklore in
   the Diverse Density lineage but the explicit framing as a coarsening-channel
   gain parameter, and the prescription (instance labels or a known-eta=1
   positive control) is a genuine contribution.
4. **The Foulds-Frank standard-vs-collective taxonomy recovered as a
   C1-preservation partition** (sec:methodology). Clean reframing that gives the
   taxonomy a quantitative cost (the bias bound).

## Differentiation status against the closest neighbours

- vs **Jang-Kwon 2024 (PAC instance-learnability)**: differentiated correctly.
  PAC sample-complexity vs likelihood parameter-identifiability are orthogonal
  lenses; the paper says so.
- vs **Chen et al. 2017 (milr, EM for OR-Bernoulli)**: this is the sharpest
  differentiation risk and the paper now handles it well. It states eq (3) is
  the same OR-link Bernoulli likelihood as milr and that the added value is the
  identifiability layer on top of the milr estimator. A referee who knows milr
  will be satisfied that the paper is not reinventing milr.
- vs **Cour et al. 2011 (PLL)**: now a developed subsection framing MIL as the
  transpose coarsening of PLL, with the small-ambiguity-degree condition flagged
  as an importable tool. Closes the prior major-6.

## Findings

### NOV-1 (MAJOR, shared with citation-verifier): the nearest MIL-identifiability prior, Doran-Ray 2014, is uncited
**Location**: `sections/introduction.tex` (related work), `refs.bib`.
**Problem**: The paper's headline differentiator is "no prior work characterizes
when instance-level inference is identifiable from bag labels." Doran and Ray
2014 (Machine Learning), "A theoretical and empirical analysis of support
vector machine methods for multiple-instance classification," develops a "true
MIL" condition: a data-design-level statement of when the MIL problem is well
posed. It is the closest existing identifiability-flavored result and a
knowledgeable referee will expect it cited. The paper's contribution survives
the comparison (rank-of-design vs design-level well-posedness are different
objects), but the comparison must be made explicitly, not omitted. Leaving it
out is the single biggest novelty-defense exposure.
**Suggestion**: cite Doran-Ray 2014 in the related-work paragraph with one
sentence: their "true MIL" condition is a data-design-level well-posedness
statement, whereas thm:rank is a parameter-rank identifiability condition on the
composition matrix; the two are complementary.
**Cross-verified**: the 2026-05-26 broad and targeted scouts both flagged
Doran-Ray as the closest prior identifiability work; it remains uncited.

### NOV-2 (MINOR): "isomorphic" overclaims the correspondence
**Location**: abstract ("MIL is an instance of the masked-data identifiability
problem"); `sections/introduction.tex` ("We observe that MIL is mathematically
isomorphic to the masked-data series-system identifiability problem").
**Problem**: The intro still says "mathematically isomorphic." The correspondence
is a reduction / instance-of (a specialization of the coarse-data ML channel),
not a category-theoretic isomorphism, and indeed the paper itself flags a
"structural inversion" (the positive bag is the coarsened observation, opposite
to scRNA's coarsened zero) that an isomorphism would not have. The abstract
already uses the softer "is an instance of," so the intro is the outlier. This
was M8 in the prior review; the abstract was fixed, the intro line was not.
**Suggestion**: in the intro, "mathematically isomorphic to" -> "an instance
of" or "reduces to." The translation table then carries the precise
correspondence.

### NOV-3 (MINOR): significance for the deep-MIL audience rests on a claim the paper does not test
**Location**: abstract and `sections/discussion.tex` (attention-weights
interpretability).
**Observation**: The paper's most quotable practical claim is that attention
weights from a bag-trained model "estimate a parameter" only in the column space
of the composition matrix and otherwise "merely interpolate a rank-deficient
direction." This is a correct corollary of thm:bag-total, but the paper does not
run any attention-MIL model, so the claim is theoretical. That is acceptable for
a diagnostic/structural paper (and honestly scoped in the discussion's "what the
framework does not address: deep-pooling identifiability"), but the abstract
phrases it assertively. A referee from the deep-MIL community may want a toy
demonstration. Not a defect, but the highest-value future experiment for
audience reach.
**Suggestion**: optional; consider softening the abstract sentence to "the
framework makes precise when attention weights estimate a parameter," which the
draft mostly already does, and keep the deep-pooling caveat where it is.

## Verdict from the novelty lens
Solid and well-positioned. One must-add citation (Doran-Ray) to close the
identifiability-prior gap; two minor wording/scope items. The honest
"diagnostic not algorithmic" framing is correct and should be preserved.
