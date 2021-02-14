set -e

 pandoc \
  --filter pandoc-crossref \
  --citeproc \
  --metadata=format:html \
  -s \
  --number-sections \
  -o index.html \
  --css basic.css \
  --toc \
  --toc-depth=1 \
  --variable=toc-title:"Contents" \
  --template=templates/pandoc-template-html.html \
  paper.md