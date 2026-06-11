# Comprehensive Review: mil-coarsening (pre-TMLR final pass)

**Date**: 2026-06-10
**Paper**: Coarsening at random for multiple instance learning: identifiability conditions for instance-level inference
**Author**: Alexander Towell (SIUE)
**Target venue**: TMLR (double-blind, OpenReview)
**Reviewer**: single deep pass (Fable 5 / Opus 4.8, max effort), all sections read in full;
independent symbolic verification (sympy) of the perturbation formulas; MUSK numbers
cross-checked against `data/musk_results.rds`. No agents.
**Builds**: `make paper` (article) clean, 22 pp, 0 undefined; `main-tmlr.tex` (TMLR,
anonymized) clean, 19 pp, 0 undefined.
**Recommendation**: **accept-with-one-fix.** The paper is sound, honest, and well
written. One substantive conceptual imprecision (C1 vs the collective-assumption
taxonomy) recurs in three places and should be fixed before submission; everything
else is clean. Submission itself is externally blocked (no OpenReview profile yet).

---

## Summary

A genuinely strong paper. The MIL-as-masked-data reduction is productive, the three
core results (rank condition, bag-prevalence consistency, aggregation-rule bias) are
correctly proved, the validation is multi-seed with honest reporting, and the MUSK
real-data section is unusually candid about its own limits (it states outright that
identifiability does not buy competitiveness). All four appendix proofs re-derive
without error. All 2026-06-08 review items are cleared. The single finding below is a
framing error, not a broken result.

### What I verified (evidence)
- **Methodology formulas (sympy):** the label-noise perturbation
  `delta = eps_minus*(1-q0) - eps_plus*q0` and the noisy-OR `P{Y=0|m} =
  prod_k (1-(1-eps)eta_k)^{m_k}` both check out symbolically.
- **Appendix proofs (by hand):** `thm:rank` and `thm:rank-continuous` (iff via strict
  monotonicity of `1-e^{-S}` + injectivity), `thm:bag-total` (score reduces to
  `m_ik(Y_i-p_i)/p_i`, verified algebraically), `thm:bias-rule` (IFT + second Bartlett
  identity) are all correct.
- **MUSK numbers vs `musk_results.rds`:** condition numbers 26/93, boundary 11/17,
  interior 9/3, weighted residuals 26/612, bag-rates 0.49-vs-0.51 / 0.24-vs-0.38, and
  the LOO macros (0.75/0.79 MUSK1, 0.56/0.60 MUSK2; continuous 0.66/0.54; PCA 0.68/0.56)
  all match the deposited results file.
- **Background rank-deficiency example** ({1,2},{3,4},{1,3},{2,4}): rows satisfy
  r1+r2 = r3+r4, so rank 3 < 4, separable but rank-deficient. Correct.
- **TMLR anonymization:** "Anonymous authors", no name/email/affiliation leak on the
  title page or in the text; "Towell" appears only as third-person citations (TMLR-
  permitted).

### Finding counts
Critical: 0 | Medium: 1 | Minor: 1 | Notes: 2

---

## Medium

### M-C1. The "standard vs collective" taxonomy is mischaracterized as a C1-preservation partition
- **Where**: `sections/methodology.tex` lines ~102-104 (primary); echoed in
  `sections/introduction.tex` contributions (~line 122-124) and
  `sections/conclusion.tex` (~line 15-16).
- **Quoted** (methodology): "Collective assumptions violate C1, because a bag can be
  ``positive'' with no individually positive instance (a threshold rule with `r > 1`,
  or a proportion rule)."
- **Problem**: A threshold-`r` rule ("a bag is positive iff at least `r` of its
  instances are positive") produces positive bags that contain `>= r >= 1` positive
  instances, so C1 ("`Y=1` implies a positive instance is in the bag") **still holds**.
  The same is true of count and proportion rules whose threshold requires at least one
  positive instance. What threshold/count/proportion rules break is the **single-cause
  OR structure** (the masked "cause" becomes a size-`r` subset, not one instance), not
  C1's support condition. C1 is genuinely violated only by **emergent / relational**
  rules, where bag positivity is a collective property and no single instance is
  individually positive. So the parenthetical examples are attached to the wrong
  category. This is the carried-forward M6 item from the 2026-05-26 and 2026-06-08
  reviews (logic-checker), still unfixed.
- **Why it matters, and why it is not Critical**: `thm:bias-rule` is a general smooth-
  perturbation bound on the deterministic-OR estimator and is agnostic to whether the
  departure preserves or violates C1, so the theorem and all numerics are unaffected.
  The error is purely in the prose mapping of the Foulds-Frank taxonomy onto C1. But a
  rigorous TMLR reviewer in this area will catch it, and as written it reads as a
  conceptual mistake about the framework's own central condition.
- **Proposed fix** (a few sentences, no math change). In `methodology.tex` replace the
  C1 sentence with a two-tier statement, e.g.:
  > "The standard assumption is the regime in which C1 holds: a positive bag contains
  > an individually positive instance. Threshold, count, and proportion rules *preserve*
  > C1 (a positive bag still contains positive instances) but break the single-cause OR
  > structure, so the masked cause becomes a subset of instances rather than one
  > instance. Emergent (relational) rules, where bag positivity is a collective property
  > with no individually positive instance, *violate* C1 outright. `thm:bias-rule`
  > bounds the deterministic-OR estimator's bias under any smooth departure `eps` from
  > the OR rule, whether that departure preserves C1 (threshold/proportion) or violates
  > it (emergent)."
  Then soften the intro-contributions and conclusion lines from "which rules preserve
  the C1 condition" to "how rules depart from the OR/C1 structure" (or similar).

---

## Minor

### m1. `[ht]` float placement (harmless for TMLR; flag only if the venue changes)
- **Where**: `sections/translation.tex` (`tab:translation`), and the article preamble.
- **Note**: TMLR has no float-placement rule, so `[ht]`/`[t]` are fine as-is. This is
  recorded only so that if mil is ever retargeted to an IMS journal (EJS/STS/AOAS),
  the floats would need `[tb]` per that portal's checklist, as we hit on the other two
  papers. No action for TMLR.

---

## Notes (non-blocking)

### N1. Main-body length vs TMLR's soft preference
Main body is ~14 pp (references at p15 in the article build), proofs in the uncapped
appendix. TMLR's fast-track guidance prefers ~12 pp of main content but explicitly
allows longer; the author accepted this when choosing TMLR. No trim required; a
reviewer may simply note the length. If a trim is ever wanted, the natural move is to
push the continuous-feature MUSK subsections (`sec:musk-continuous`, `sec:musk-pca`)
toward the appendix, but they carry the paper's most honest empirical point and are
worth keeping in the main text.

### N2. Self-citations and double-blind (decided: keep as-is)
The paper cites the author's own coarsening family in third person, rendering as
"Towell (2026a,c,d)" ~16 times. TMLR explicitly permits third-person self-citation
with real names, so this is compliant; the author chose to keep it as-is rather than
anonymize the sibling cites. Recorded here as a deliberate decision, not a defect.

---

## Disposition

Content-ready for TMLR after the one-paragraph M-C1 fix (no math changes, no rebuild
risk). The TMLR build (`main-tmlr.tex`) is already anonymized and clean. The only hard
blocker to actually submitting is external: an OpenReview profile must exist first
(moderated signup), after which the OpenReview submission can be driven and the
accepted version later deposited as a new version under the existing Zenodo concept DOI
10.5281/zenodo.20502964.
