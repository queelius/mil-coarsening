# Literature Context Packet (merged scouts)

**Paper**: Coarsening at random for multiple instance learning: identifiability conditions for instance-level inference
**Date**: 2026-06-08

This packet merges a field survey (broad) and a targeted same-problem search,
deduplicated. It carries forward the still-valid findings of the 2026-05-26
scout pass and adds checks against the current draft.

## Field position

MIL is a mature subfield of weak supervision. The canonical lineage the paper
cites is correct and complete for the "standard assumption" line:

- Dietterich, Lathrop, Lozano-Perez 1997 (axis-parallel rectangles, MUSK
  benchmark origin).
- Maron and Lozano-Perez 1998 (Diverse Density, noisy-OR concept point).
- Andrews, Tsochantaridis, Hofmann 2003 (mi-SVM / MI-SVM; Elephant/Fox/Tiger).
- Ilse, Tomczak, Welling 2018 (attention-based deep MIL).
- Lu et al. 2021 (CLAM, weakly supervised computational pathology).
- Surveys: Carbonneau et al. 2018; Foulds and Frank 2010 (the
  standard-vs-collective assumption taxonomy the paper recovers).

The assumption-taxonomy framing (Foulds-Frank) is the right anchor for the
paper's bias-bound contribution, and it is cited and used correctly.

## Closest prior work on the SPECIFIC question (instance-level identifiability)

The paper's novelty claim is "no prior work characterizes when instance-level
inference is identifiable from bag labels through coarsening conditions." The
targeted search supports this, with the following neighbours the paper should be
measured against:

1. **Jang and Kwon 2024 (NeurIPS), "Are MIL Algorithms Learnable for
   Instances?"** PAC/learnability account of instance-level recovery. Cited.
   This is the closest contemporaneous work and the paper positions against it
   correctly (PAC-learnability vs likelihood-identifiability are different
   lenses; the paper's rank condition is a parameter-identifiability statement,
   not a sample-complexity bound).
2. **Vanwinckelen et al. 2016**, instance-level vs bag-level accuracy.
   Cited and used well: thm:bag-total is offered as the likelihood-level
   mechanism for their empirical gap. This is one of the paper's strongest
   positioning moves.
3. **Chen et al. 2017 (milr, R Journal)**, EM for OR-rule Bernoulli MLE with
   latent instance labels and a lasso penalty. Cited. This is the closest
   prior LIKELIHOOD model and the paper is now explicit that its eq (3) is the
   same OR-link Bernoulli likelihood; the added value is the identifiability
   layer (rank condition + bag-prevalence identity) on top of the milr
   estimator. The honesty here is appropriate and defuses a "this is just
   milr" referee reaction.
4. **Cour, Sapp, Taskar 2011 (JMLR)**, partial-label learning. Cited and now
   developed into a half-page discussion subsection framing MIL as the
   transpose coarsening of PLL, with the small-ambiguity-degree condition
   pointed to as an import that could sharpen finite-sample rates. This closes
   the prior review's N-C/major-6 finding.
5. **Couso, Dubois, Hullermeier 2017 (SUM)**, maximum likelihood and coarse
   data. Cited as the general coarse-data ML theory of which the masked-cause
   series-system channel is one case. Good: it correctly genealogizes the
   contribution within the superset-label coarse-data literature and prevents
   an overclaim of full originality of the coarsening apparatus.

## Adjacent work flagged by the prior scout, still only partially engaged

The 2026-05-26 targeted scout flagged the following as "should be at least
cited." Status in the current draft:

- **Doran and Ray 2014 (Machine Learning), "true MIL" condition** -- NOT cited.
  This is a data-design-level condition for when MIL is well posed; it is the
  nearest existing "when is MIL identifiable" statement and a knowledgeable
  referee will expect it. Operating at a different level (design vs parameter
  rank) is exactly the differentiation the paper can make, but only if it
  cites it. STILL OPEN.
- **Halpern and Sontag 2013 (UAI), noisy-OR identifiability** -- NOT cited.
  Noisy-OR network identifiability, different scope (network topology vs bag
  aggregation), but the firing-rate confound discussion (rem:firing-rate)
  touches the same object. A one-line "distinct from network-topology
  identifiability of Halpern-Sontag" would inoculate against a referee who
  knows that line. STILL OPEN (minor).
- **Sabato and Tishby 2012 (MIL sample complexity)**, **Babenko et al. 2009
  (bag-vs-instance)** -- not cited; lower priority, sample-complexity rather
  than identifiability.
- **Quadrianto et al. 2009 (label-proportion learning)**, **Zhou 2018 (weak
  supervision survey)** -- adjacent-but-different; optional.

## Cross-family consistency (this paper vs the synthesis and siblings)

- The synthesis paper (`coarsening-synthesis`) carries this result as
  `cor:mil` (Bag-prevalence consistency, MIL) in `sections/consistency.tex`.
  The corollary states the identity as `M^T D^{-1}(Y - p_hat) = 0`, places MIL
  in regime (A) (regular exponential family, exact finite-sample identity),
  notes the IRLS / inverse-fitted-rate weighting from the non-canonical
  log-survival link, and routes the vector statement through the joint rank
  condition. This is IDENTICAL in content to thm:bag-total and its remark in
  this paper. The two are mutually consistent; no drift detected.
- The translation-table conventions (component=instance type, candidate
  set=bag, singleton candidate=singleton bag, C1/C2/C3 rows) match the sibling
  papers' shared template (spatial-coarsening `tab:translation`).
- The firing-rate confound is correctly named as the discrete-label analogue
  of the ERCC spike-in capture-efficiency gap in `towell2026scrnacoarsening`,
  consistent with the scrna paper's framing.

## Takeaways for the review

1. The novelty case is solid: MIL-through-CAR-coarsening-conditions is genuinely
   new, the closest neighbours (Jang-Kwon PAC, milr EM, PLL) are cited and
   correctly differentiated, and the coarse-data genealogy (Couso et al.) is
   acknowledged so the apparatus is not overclaimed.
2. The one remaining literature gap a domain referee will notice is Doran-Ray
   2014 ("true MIL"), the nearest existing MIL-identifiability statement. Add
   it. Halpern-Sontag 2013 is a minor secondary add.
3. Cross-family consistency with the synthesis `cor:mil` is clean; preserve it
   when editing thm:bag-total.
