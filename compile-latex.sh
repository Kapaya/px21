set -e

pandoc \
  --filter conditional-render \
  --filter pandoc-crossref \
    --citeproc \
  -s \
  -o \
  paper.tex \
  --template=templates/sigconf.pandoc \
  --natbib \
  --metadata=format:pdf \
  paper.md

pdflatex paper.tex
bibtex paper
pdflatex -interaction=batchmode paper.tex
pdflatex -interaction=batchmode paper.tex
open paper.pdf
