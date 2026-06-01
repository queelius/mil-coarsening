.PHONY: paper clean wordcount sim musk

PAPER = main

paper: $(PAPER).pdf

$(PAPER).pdf: $(PAPER).tex sections/*.tex refs.bib
	pdflatex $(PAPER).tex
	bibtex $(PAPER)
	pdflatex $(PAPER).tex
	pdflatex $(PAPER).tex

sim: results.rds

results.rds: scripts/sim.R scripts/run.R
	Rscript scripts/run.R

musk: data/musk_results.rds

data/musk_results.rds: scripts/musk.R scripts/sim.R \
                       data/musk1/clean1.data data/musk2/clean2.data
	Rscript scripts/musk.R

figures: figures/fig_rank_collapse.pdf \
         figures/fig_firing_rate.pdf \
         figures/fig_musk_eta.pdf

figures/fig_rank_collapse.pdf figures/fig_firing_rate.pdf \
figures/fig_musk_eta.pdf: scripts/figures.R scripts/sim.R \
                           results.rds data/musk_results.rds
	Rscript scripts/figures.R

clean:
	rm -f $(PAPER).aux $(PAPER).bbl $(PAPER).blg $(PAPER).log \
	      $(PAPER).out $(PAPER).pdf $(PAPER).fdb_latexmk \
	      $(PAPER).fls $(PAPER).synctex.gz $(PAPER).toc \
	      sections/*.aux

wordcount:
	@texcount -inc -sum -1 $(PAPER).tex 2>/dev/null || \
	  echo "(install texcount for word count)"
