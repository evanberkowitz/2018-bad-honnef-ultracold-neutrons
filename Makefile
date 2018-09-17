TEX=pdflatex -halt-on-error
BIB=bibtex
GIT_STATUS=git_information.tex

DRAFT=draft
MASTER=master
ABSTRACT=abstract
SECTIONS = $(shell ls -1 section/ | sed -e 's/^/section\//g')
WATCH?=draft

ifndef VERBOSE
	REDIRECT=1>/dev/null 2>/dev/null
endif

all: $(MASTER).pdf

$(MASTER).pdf: $(SECTIONS) macros.tex $(MASTER).tex
	@echo $@
	echo "" > $(GIT_STATUS) $(REDIRECT)
	$(TEX) $(MASTER).tex $(REDIRECT)
	$(BIB) $(MASTER) $(REDIRECT)
	$(TEX) $(MASTER).tex $(REDIRECT)
	$(TEX) $(MASTER).tex $(REDIRECT)
	make tidy

$(DRAFT).pdf: $(SECTIONS) $(MASTER).tex
	@echo $@
	make $(GIT_STATUS)
	$(TEX) -jobname=$(DRAFT) $(MASTER).tex $(REDIRECT)
	$(BIB) $(DRAFT) $(REDIRECT)
	$(TEX) -jobname=$(DRAFT) $(MASTER).tex $(REDIRECT)
	$(TEX) -jobname=$(DRAFT) $(MASTER).tex $(REDIRECT)
	make tidy

$(ABSTRACT).pdf: $(SECTIONS) $(ABSTRACT).tex
	@echo $@
	echo "" > $(GIT_STATUS) $(REDIRECT)
	$(TEX) $(ABSTRACT).tex $(REDIRECT)
	$(TEX) $(ABSTRACT).tex $(REDIRECT)
	$(TEX) $(ABSTRACT).tex $(REDIRECT)
	make tidy

.PHONY: $(GIT_STATUS)

$(GIT_STATUS): 
	./git_information.sh > $(GIT_STATUS)

.PHONY: git-hooks
git-hooks:
	for h in hooks/*; do ln -f -s "../../$$h" ".git/$$h"; done

.PHONY: tidy
tidy:
	$(RM) git_information.aux section/*.aux
	$(RM) {$(MASTER),$(DRAFT),$(ABSTRACT)}.{out,log,aux,synctex.gz,bbl,blg,toc,fls,fdb_latexmk}

.PHONY: clean
clean: tidy
	$(RM) $(GIT_STATUS)
	$(RM) {$(MASTER),$(DRAFT),$(ABSTRACT)}Notes.bib
	$(RM) {$(MASTER),$(DRAFT),$(ABSTRACT)}.pdf

.PHONY: watch
watch: $(WATCH).pdf
	watchman-make -p '**/*.tex' '*/*.tex' '*.tex' '*.bib' -t $(WATCH).pdf