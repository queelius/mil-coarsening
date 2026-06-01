# Prose Auditor Report

**Paper**: Coarsening at random for multiple instance learning
**Date**: 2026-05-26

## Overall narrative arc

The paper has a clean arc: motivation (intro), framework primer
(background), translation table (translation), three theorems
(identifiability + methodology), simulation evidence (validation),
positioning and limits (discussion), one-paragraph summary
(conclusion). At 12 pages this is tight but sustainable, and the
section sizes are well balanced.

The opening of each section reliably tells the reader what they are
about to read, and most sections close with a practical-implication
statement. This is good craftsmanship.

## Strengths

- The "central message" paragraph at the end of the introduction
  ("MIL methods are not arbitrary heuristics; they are special cases
  of a single identifiability framework") earns its place. It tells
  the reader what to remember after the technical content.
- The translation table (`tab:translation`) is the single most
  useful object in the paper for a reader new to either side of the
  bridge.
- The "Practical implication" paragraph after Theorem 2 connects the
  formal result to the attention-weights interpretability question,
  which is what a methods-paper reader will actually want.
- The "What the framework does *not* address" subsection in
  discussion is honest and sets expectations correctly. Many
  framework papers fail this test.

## Issues

### MAJOR. The abstract overpromises on real-data validation

Abstract claim: "The framework subsumes mi-SVM, Diverse Density,
attention-based MIL, and CLAM as special cases and supplies a
diagnostic to run before trusting instance-level outputs."

The paper does not actually run that diagnostic on any real MIL
benchmark. The text is true in a literal sense (the *framework*
supplies the diagnostic) but the reader will form the expectation
that the paper demonstrates the diagnostic in action on real bags.
The validation section is simulation only; the real-data plan is
deferred.

Two ways to fix:

1. Weaken the abstract: "The framework subsumes [...] as special
   cases and supplies an identifiability diagnostic for instance-
   level outputs; we validate the theorems on simulated data and
   outline the real-data benchmarks deferred to the full version."
2. Run the diagnostic (compute $\mathrm{rank}(M)$, report
   identified/unidentified directions) on one or two real MIL
   benchmarks (MUSK is small, fast, classical), and update the
   abstract to claim the diagnostic has been run.

Option 2 is the higher-value path because it adds substantive
content for minimal effort.

### MAJOR. "Subsumes" is too strong a verb (cross-link with novelty-assessor)

Used in the abstract, introduction contributions list, methodology
section heading, and discussion. The framework *names* the
assumptions these methods make; it does not derive the methods'
estimators. A reviewer who reads "subsumes" and then sees only an
informal mapping in `translation.tex` will distrust the rest of the
paper. "Place" or "characterizes" or "names the assumption set
of" is more accurate.

### MAJOR. The proof sketches read more as references-to-other-papers than as derivations

Theorems 1, 2, and 3 all defer substantive proof structure to
companion or full-version papers. This is acceptable in a 12-page
conference format, but the *sketches* themselves should still walk
the reader through the key step. The Theorem 1 sketch is good (both
directions in plain English). The Theorem 2 sketch is good (the
score derivation is explicit). The Theorem 3 sketch reduces to "this
is the standard M-estimator perturbation expansion; details in
spatial-coarsening §5 and scRNA-coarsening §7 and full version."
That is three pointers and no derivation; the conference reader who
does not have access to the full version is left with no
verification path. Add a one-sentence statement of *what*
$\partial_\epsilon \E[\nabla_s \ell]$ evaluates to for each of the
three cases (label noise, noisy-OR, threshold), even if the
explicit closed form is in the full version.

### MAJOR. The introduction's bridge subsection is the paper's load-bearing wall and is currently a single paragraph

`introduction.tex` lines 40--67 do the entire work of justifying
why this paper exists: MIL is the masked-data identifiability
problem. This is one long paragraph followed by the contributions
list. A reader who is skeptical of the bridge ("is this really an
isomorphism, or is it just a metaphor?") will not get traction from
the current structure. The translation table comes much later
(`tab:translation`, page 3 or 4).

**Fix**: either pull the translation table forward into the
introduction's bridge subsection, or add a short numbered list in
the bridge ("instances are components; bags are candidate sets; OR
is series aggregation; singleton bags are singleton candidate sets")
so the reader can verify the bridge claim before reading further.
Right now they have to take the claim on faith for a full section.

### MINOR. "We observe that MIL is mathematically isomorphic to..." is a strong word

"Isomorphic" is a category-theoretic term implying a bijection of
structure. What you have is a *translation* or *correspondence* or
*reduction*: a forgetful map in one direction, with the inverse
holding modulo continuous-feature extensions not yet established.
The two domains are not isomorphic as categories; they are
isomorphic for the binary-label discrete-type sub-case under C1-C2-C3
and the deterministic-OR rule.

Replace "isomorphic" with "is an instance of" or "reduces to" or
"can be reformulated as." The current word will draw a category-
theoretically inclined reviewer's red pen even though the substance
is correct.

(Used three times: abstract line "MIL is an instance of the masked-
data identifiability problem" -- this one is fine; introduction
line 42 "MIL is mathematically isomorphic to..." -- replace; HANDOFF
also uses "isomorphic" but that's not in the paper.)

### MINOR. The contributions list mixes contribution kinds

The four bulleted contributions in the introduction are: a bridge
(reframing), a theorem (rank), a theorem (consistency), a theorem
(bias bound), a validation protocol. The validation protocol is
a tier below the others; it is also overpromised (no real data).
Either pull it out into a separate "we validate the theorems"
sentence or rewrite it to match what is delivered ("simulation
validation; real-data protocol deferred").

### MINOR. The "structural inversion" callout in translation.tex is well done but uses "structural feature" twice in the same paragraph

`translation.tex` lines 74--83. Minor wordsmithing. "One structural
feature has no counterpart [...] The masked-data framework is
polarity-agnostic [...] the practical consequence..." reads better
as "One feature of MIL has no counterpart in the earlier applications.
In scRNA-seq..."

### MINOR. The conclusion is honest but does not preview what the full version contributes that the conference version cannot

A reader who wants to know whether to wait for the full version is
not served. One sentence: "The full version
\citep{towell2026milcoarsening} establishes the continuous-feature
rank theorem, self-contained proofs, real-data benchmarks on MUSK
and CAMELYON, and a side-by-side comparison with attention-MIL and
CLAM." That sets up the citation and explains the conference/full
split for the curious reader.

### MINOR. Three `\cite{}` calls in mid-sentence position should be `\citet{}`

`sections/discussion.tex` line 46: "the C2-relaxation results of
\cite{towell2026mdrelax} would be"
`sections/identifiability.tex` line 35: "is in \cite{towell2026milcoarsening}."
`sections/methodology.tex` line 78: "is in \cite{towell2026milcoarsening}."

With natbib, `\cite{}` produces a parenthetical citation by default,
which reads awkwardly in mid-sentence ("the results of (Towell, 2026)
would be"). For author-as-noun usage, prefer `\citet{}` (renders as
"Towell (2026)").

### SUGGESTION. The "what does the framework not address" subsection should appear earlier

It currently lives in `discussion.tex`. A reader who is going to
disagree with the C2 assumption ("but MIL bags often have correlated
instances") would benefit from seeing this acknowledgment earlier;
right now they spend half the paper formulating an objection that
the discussion section actually concedes.

Either move it forward (after `translation.tex`?) or have a one-
sentence forward pointer in `translation.tex` that flags the
limitations and says "we address each in the discussion."

### SUGGESTION. Numerical results in the validation section would read better in a small table

The Exp 1 numbers are scattered across three paragraphs:
- Full-rank: max-abs error 0.038
- Rank-deficient: spread(s1) = 0.060, spread(2s1 + s2) = 1.6e-15
- Singleton-augmented: spread(s1) collapses to 4.4e-5, max-abs error 0.095

A 3x3 table would let the reader see the rank-condition story in
one glance. Same for Exp 3 noisy-OR ratios.

## Notation consistency

I checked the major notation choices and found no inconsistencies:
- $\bm{m}_i$ (vector) vs. $M$ (matrix) vs. $m_{ik}$ (entry): used
  consistently.
- $\bm{s}$ as the log-survival parametrization and $\bm{\eta}$ as
  the positivity parametrization: linked by $s_k = -\log(1-\eta_k)$
  and used consistently.
- $Y_i$ for bag labels (uppercase), $y_{ij}$ for instance labels
  (lowercase): consistent.
- $\bm{1}\{\cdot\}$ macro defined in main.tex, used in
  translation.tex. Consistent.
- $\Prob$, $\E$ macros consistently used.

No notation issues.

## Em-dash check

`grep` for U+2014, en-dash U+2013, and LaTeX `---`: **zero
violations**. The author's convention is held.

## Confidence

High on writing-quality issues. Most of the prose findings are
matters of degree (overpromising language, missing forward
pointers, single-sentence proofs-by-reference) rather than
correctness; the substance of the prose is clean and the section
structure is well chosen.
