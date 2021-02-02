# Pandoc HTML+PDF Pipeline

This repo uses pandoc to compile to both the Programming conference proceedings format, and an online essay.

The goal is to keep both versions in sync as closely as possible and avoid divergences.

## Compile

[Install pandoc](https://pandoc.org/installing.html)

Install `paru` for ruby: `sudo gem install paru`. (May require a ruby upgrade)

Install browsersync: `npm install -g browser-sync`

To view HTML with a live preview: `./watch.sh`

To compile to HTML (including copying assets to my personal homepage dir): `./compile-html.sh`
To compile to PDF through Latex: `./compile-latex.sh && open paper.pdf`

## notes

* To allow `pandoc-crossref` to run on Mac you may need to manually allow it in security settings.

* image sizes and Latex output interact weirdly. I use high-res pngs exported from Sketch at 72dpi, and then in the latex compile script I use ImageMagick to convert to 300dpi so that the final size comes out correctly in the pdf.

* references.bib is produced by the Better BibLatex Zotero plugin which doesn't export website accessed dates. So I made references2.bib into the references source; it's produced by the normal Zotero BibLatex exporter.

* For camera ready, we're ditching the markdown source and treating `cameraready.tex` as source of truth.
