# mil-coarsening

**Coarsening at random for multiple instance learning: identifiability
conditions for instance-level inference.**

Conference-format paper. The third application in the masked-data
coarsening series, after `papers/scrna-coarsening/` (precursor) and
`papers/spatial-coarsening/` (sibling). Multiple instance learning
(MIL) is shown to be an instance of the masked-data series-system
identifiability problem.

## The bridge

| Masked-data framework | Multiple instance learning |
|---|---|
| Component | Instance type |
| System failure (OR of component events) | Bag label (OR of instance labels) |
| Failed cause (latent) | Which instance is positive (latent) |
| Candidate set | Bag |
| Singleton candidate set | Singleton bag (instance-level label) |
| C1 (cause in candidate set) | Bag-positive implies a positive instance present |

## Results

1. **Rank condition** (`thm:rank`): instance-type positivity is
   identifiable from bag labels iff the bag-by-instance-type
   composition matrix has full column rank.
2. **Bag-prevalence consistency** (`thm:bag-total`): any bag-likelihood
   maximizer matches observed bag-positive frequencies along the
   column space of the composition matrix, so bag-level accuracy
   cannot validate instance-level scores.
3. **Bias bound** (`thm:bias-rule`): a first-order bound on
   instance-score bias under aggregation-rule misspecification
   (noisy-OR, label noise, threshold), recovering the
   standard-versus-collective taxonomy as a C1-preservation statement.

A confound between intrinsic instance positivity and the noisy-OR
firing rate is the discrete-label analogue of the spike-in
capture-efficiency gap in scRNA-seq.

## Build

```bash
make paper      # builds main.pdf
make clean      # removes build artifacts
```

## Layout

- `main.tex`: top-level preamble plus `\input{sections/...}`
- `sections/`: introduction, background, translation, identifiability,
  methodology, validation, discussion, conclusion
- `refs.bib`: BibTeX
- `scripts/`: simulation and analysis scripts (to be added)
- `figures/`: figures (to be added)

## Status

Initial scaffold. Theorem statements and proof sketches in place;
simulation code, real-data application, and figures pending. See
`HANDOFF.md`.

Author: Alexander Towell (`lex@metafunctor.com`), SIUE Department of
Computer Science.
