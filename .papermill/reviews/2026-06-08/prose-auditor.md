# Prose Auditor Report

**Paper**: mil-coarsening
**Date**: 2026-06-08
**Scope**: writing quality, narrative arc, notation consistency, conventions.

## Summary

The writing is clean, well-organized, and in the tight conference register the
project prefers. The narrative arc works: motivation -> bridge -> translation
table -> theorems -> validation -> method positioning -> limitations. The
"central message" sentence at the end of the introduction earns its place. The
no-em-dash convention is held with zero violations (verified by Unicode scan:
no U+2014 anywhere in `main.tex`, `sections/`, or `refs.bib`; no non-ASCII at
all in the section files). No vanity counts in the prose.

The defects are local: one on-page self-contradiction in the MUSK numbers (the
same issue methodology-auditor flags from the artifact side, but it is also a
pure prose-consistency defect because the section contradicts itself), a stale
theorem-number set in the appendix titles, the lingering "isomorphic," and the
"three theorems / four theorems" mismatch.

## Strengths

- Section sizing is balanced; no section sprawls. The translation table
  (`tab:translation`) is the right device and is placed where the reader needs
  it.
- The appendix proofs read as actual derivations now, not as pointers to other
  papers. The 2026-05-26 complaint that "Theorem 3's sketch reduces to three
  pointers and no actual derivation" is resolved: the appendix carries the full
  implicit-function expansion and the closed-form noisy-OR sensitivity.
- The "What the discrete-type application demonstrates" and "What the PCA
  experiment confirms, and what it does not" paragraphs are models of honest
  empirical writing: they separate what was shown from what was not, which is
  exactly right for a benchmark where the method underperforms the baselines.
- The remark distinguishing the log-survival link from logit and cloglog is
  precise and useful.

## Findings

### PRO-1 (MAJOR, shared with methodology-auditor): MUSK section contradicts itself on interior-type counts
**Location**: `sections/validation.tex`, `sec:musk`.
**Quoted text (paragraph A, "Per-type positivity")**: "with `11` of `20` types
on the boundary" (MUSK1) and "the boundary count is `17` of `20`" (MUSK2).
**Quoted text (paragraph B, "Bag-prevalence consistency, real data")**: "only
`8` of `20` instance types on MUSK1 and `4` of `20` on MUSK2 are interior".
**Problem**: 20 - 11 = 9 interior, not 8; 20 - 17 = 3 interior, not 4. The two
paragraphs are on the same page and cannot both be right. (The artifact confirms
9 and 3; see methodology-auditor MET-1.) This is a pure internal-consistency
defect independent of the data file: a reader doing the subtraction catches it.
**Suggestion**: "8 of 20" -> "9 of 20", "4 of 20" -> "3 of 20" (and fix the two
residual numbers per MET-1).

### PRO-2 (MAJOR, shared with logic-checker): appendix subsection titles cite wrong theorem numbers
**Location**: `sections/appendix.tex` lines 10, 102, 160.
**Problem**: "Proof of Theorem 1 (rank condition)" / "Proof of Theorem 2
(bag-prevalence consistency)" / "Proof of Theorem 3 (aggregation-rule bias)" do
not match the compiled numbers (Theorem 2 / 5 / 7; see logic-checker LOG-1 and
format-validator). A reader who cross-references "Proof of Theorem 1" to the
body finds the background theorem instead. Use `\cref{thm:...}` in the titles so
they track automatically.

### PRO-3 (MINOR): "three theorems" vs four proved
**Location**: appendix line 6, validation line 4, introduction line 120,
abstract.
**Problem**: see logic-checker LOG-2. The appendix says "proofs of the three
theorems" then provides four proof subsections. Reword to "three core theorems
and the continuous-feature extension," or recount to four.

### PRO-4 (MINOR): "isomorphic" in the introduction
**Location**: `sections/introduction.tex`, bridge subsection.
**Problem**: "MIL is mathematically isomorphic to the masked-data series-system
identifiability problem." The abstract already uses "is an instance of"; the
intro is the outlier and the paper itself flags a structural inversion that an
isomorphism would preclude. See novelty-assessor NOV-2. Replace with "is an
instance of" / "reduces to."

### PRO-5 (MINOR): three noun-form citations use `\cite` instead of `\citet`
**Location**: `sections/identifiability.tex` (the `\cite[\S 3]{towell2026
scrnacoarsening}` in the bag-total proof sketch), `sections/methodology.tex`
(the `\cite[\S 5]{towell2026spatialcoarsening}` and `\cite[\S 7]{...}` in the
bias proof sketch), `sections/discussion.tex` (the `\cite{towell2026mdrelax}`
in the adaptive-bag-construction bullet).
**Problem**: These read as parenthetical citations where the sentence uses them
as nouns ("parallels `\cite[\S 3]{...}`"). With `plainnat`, `\cite` and `\citep`
both produce the parenthetical form; the noun-form needs `\citet`. Cosmetic but
this was M3 in the prior review and a few instances remain.
**Suggestion**: change to `\citet[\S 3]{...}` etc. where the citation is the
grammatical subject/object.

### PRO-6 (SUGGESTION): the bridge still does its conceptual work before the table appears
**Location**: `sections/introduction.tex` bridge subsection vs
`sections/translation.tex` `tab:translation`.
**Observation**: prior review M11 suggested pulling the correspondence forward.
The intro bridge subsection now gives a prose correspondence (instances=
components, bag=candidate set, OR=series, singleton bag=singleton candidate set)
which substantially mitigates this; the full table arriving in sec:translation
is fine. No action required; noting it as resolved-enough.

## Convention compliance
- No em-dashes: PASS (Unicode scan clean).
- No vanity counts in prose: PASS.
- Author identity correct (Alexander Towell, SIUE, ORCID 0000-0001-6443-9897 in
  main.tex): PASS.
