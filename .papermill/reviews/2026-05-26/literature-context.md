# Literature Context

**Paper**: Coarsening at random for multiple instance learning
**Date**: 2026-05-26

## Field landscape

### MIL methods, in approximate chronological order

- **Dietterich, Lathrop, Lozano-Pérez 1997** (Artificial Intelligence):
  axis-parallel rectangles, the original MIL formulation; introduced
  MUSK1/MUSK2 datasets.
- **Maron & Lozano-Pérez 1998** (NeurIPS): Diverse Density, an early
  noisy-OR-based MIL formulation. Important for this paper because
  Diverse Density is the prototype noisy-OR estimator whose
  identifiability now has a formal characterization.
- **Andrews, Tsochantaridis, Hofmann 2003** (NeurIPS): mi-SVM /
  MI-SVM. Introduced Elephant/Fox/Tiger image-MIL datasets.
- **Foulds & Frank 2010** (KER): the standard-vs-collective
  assumption taxonomy. This paper *recovers* the taxonomy as a C1-
  preservation statement, the cleanest novelty hook.
- **Ilse, Tomczak, Welling 2018** (ICML): attention-based deep MIL.
  Currently the workhorse of computational pathology and the method
  whose attention weights this paper warns about.
- **Carbonneau et al. 2018** (Pattern Recognition): broad MIL survey
  organizing methods by problem characteristics, instance/bag space
  geometry, and pooling strategy. Does not address identifiability.
- **Lu, Williamson, Chen et al. 2021** (Nature Biomedical Eng):
  CLAM, attention-MIL with instance-level clustering for whole-slide
  pathology. Currently the SOTA-by-popularity in MIL pathology.
- **Campanella et al. 2019** (Nature Medicine): clinical-grade weakly
  supervised pathology, the application motivating much of the
  current MIL theoretical interest.

### Weakly supervised learning / partial-label / coarsening

- **Cour, Sapp, Taskar 2011** (JMLR): partial-label learning;
  introduces an "ambiguity condition" that is the closest existing
  identifiability-flavored result for label-aggregation weak
  supervision. The paper's framing as "MIL is the dual coarsening"
  is the natural connection but is underdeveloped (one sentence in
  intro).
- **Heitjan & Rubin 1991** (Annals of Statistics): coarsening at
  random, the foundational paper for the C1-C2-C3 conditions.
- **Zhou 2018** ("A brief introduction to weakly supervised
  learning", National Science Review): standard taxonomy of weak
  supervision, distinguishes incomplete, inexact, and inaccurate
  supervision. Does not invoke coarsening conditions.
- **Liu & Dietterich 2014** (NeurIPS): conditions for partial-label
  identifiability. PLL-specific.
- **Feng, Lv, Han et al. 2020** (ICML / NeurIPS): provably consistent
  PLL methods. PLL-specific.

### Noisy-OR and discrete-label aggregation

- **Pearl 1988** (Probabilistic Reasoning in Intelligent Systems,
  Section 4.3.2): foundational noisy-OR gate.
- **Halpern & Sontag 2013** ("Unsupervised learning of noisy-or
  Bayesian networks", UAI): identifiability of noisy-OR networks
  with hidden variables. Adjacent but not MIL.
- **Jernite, Halpern, Sontag 2013** (ICML): faster algorithms for
  noisy-OR network learning. Adjacent.

### Reliability statistics, masked-cause inference

- **Towell 2026 "masked"** (Zenodo preprint per HANDOFF, not in the
  .bib URL field): foundational identifiability framework for series
  systems with masked cause of failure.
- **Goetghebeur & Ryan 1995, 2000**: masked-cause likelihood for
  competing risks; conventional reliability/biostatistics audience.
- **Flehinger, Reiser, Yashchin 2002** (Lifetime Data Analysis):
  parametric estimation under masked cause.
- **Lawless 2003** ("Statistical Models and Methods for Lifetime
  Data"): the standard reliability statistics textbook reference.

### Sibling coarsening-at-random application papers

- **Towell 2026 scrna-coarsening** (precursor): zero-inflation in
  scRNA-seq as a coarsening problem. Introduces the ERCC spike-in
  calibration analogy that this paper extends.
- **Towell 2026 spatial-coarsening** (sibling): cell-type
  deconvolution in spatial transcriptomics as a coarsening problem.
  Source of the rank-theorem template.

## Direct comparisons

### Have C1-C2-C3 coarsening conditions been applied to MIL before?

Based on my literature recall: **no**. The masked-data literature
has stayed in reliability and competing-risks biostatistics; the MIL
literature has stayed in machine-learning weak supervision. The
Heitjan-Rubin vocabulary does not appear in MIL surveys (Foulds-Frank
2010, Carbonneau et al. 2018, Zhou 2018) or in attention-MIL or
CLAM papers.

This appears to be a genuine framework transfer with no direct
precedent.

### Has MIL identifiability been characterized before?

There is scattered work:
- **Babenko, Yang, Belongie 2009** (NeurIPS): considers when bag
  classifiers can be used for instance classification (online
  multiple instance learning), but framed as a learning-theoretic
  generalization question, not identifiability.
- **Sabato & Tishby 2012** (JMLR): MIL sample complexity bounds.
- **Doran & Ray 2014** (Machine Learning): the "true MIL" problem,
  conditions under which standard-assumption MIL applies. Closest
  prior work on what amounts to a C1 question, but framed as a data-
  property check, not as an identifiability rank condition.

The MIL-coarsening paper's rank condition is, as best I can tell,
the first explicit rank-based identifiability characterization for
the bag-OR likelihood. Doran & Ray's "true MIL" condition is
related but operates at the data-design level (each positive bag
contains a positive instance) rather than at the parameter-
identifiability level.

### Has the noisy-OR firing-rate confound been named in MIL?

The Diverse Density paper (Maron & Lozano-Pérez 1998) uses noisy-OR
and the subsequent MIL literature has noted that Diverse Density is
sensitive to the firing-rate parameter, but I have not found an
explicit statement that $\rho\eta$ is identified while $\rho$ and
$\eta$ separately are not. The firing-rate confound framing
appears to be original to this paper.

### Connection to label-proportion learning (LLP)

**Quadrianto, Smola, Caetano, Le 2009** (NeurIPS): learning from
label proportions. This is another label-aggregation weak
supervision setting, distinct from both MIL and PLL. The framework
in this paper extends naturally to LLP (the bag label is a
*proportion* rather than a Boolean OR), but the paper does not
mention LLP. A one-sentence forward pointer in the discussion would
strengthen the framework's reach.

## Risks for the novelty case

1. The "MIL is the dual of partial-label learning" claim, if a PLL
   expert reviews and identifies prior dual formulations (perhaps in
   recent PLL papers I am not surfacing), could weaken the framing.
   The paper currently mentions Cour et al. 2011 only and would
   benefit from a more thorough PLL-identifiability literature
   check.
2. The "rank condition for bag-OR" result, if any of the
   identifiability-of-noisy-OR-Bayesian-network results (Halpern &
   Sontag 2013) cover a special case of this, could partially
   precede the paper. The bag-OR setting is sufficiently specific
   that I would expect Halpern-Sontag's noisy-OR identifiability to
   be a different question (they are concerned with the topology of
   the noisy-OR network), but the relation is worth checking.
3. Doran & Ray 2014's "true MIL" condition deserves explicit
   citation; it is the closest prior identifiability-flavored MIL
   work.

## Recommendations for the literature review

The paper should add:

- A citation and one-sentence positioning against Doran & Ray 2014
  ("true MIL" condition vs. our rank condition).
- A more developed PLL comparison (one paragraph in the discussion,
  not one sentence in the intro).
- A passing reference to Halpern & Sontag 2013 on noisy-OR
  identifiability with a note on the different scope.
- A passing reference to label-proportion learning (Quadrianto et
  al. 2009) as a sibling weak-supervision problem that the
  framework should extend to.
- A citation to Sabato & Tishby 2012 for MIL sample-complexity, with
  one sentence noting that identifiability and sample complexity are
  complementary (identifiability says *what can be estimated*;
  sample complexity says *how much data is needed*).

These additions are cheap and would inoculate against the most
likely "this exists already" reviewer reactions.
