#!/usr/bin/env bash
# Build the manuscript; does not run Lean or access the network.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
command -v pdflatex >/dev/null 2>&1 || { echo 'pdflatex is required (TeX Live or equivalent).' >&2; exit 1; }
BIBTEX=''
for candidate in bibtex bibtex.original bibtex8; do
  if command -v "$candidate" >/dev/null 2>&1; then BIBTEX="$candidate"; break; fi
done
pdflatex -interaction=nonstopmode -halt-on-error erdos647_sparsity.tex
if [[ -n "$BIBTEX" ]]; then
  "$BIBTEX" erdos647_sparsity
elif [[ -f erdos647_sparsity.bbl ]]; then
  echo 'Using the included bibliography output; install BibTeX before changing references.' >&2
else
  echo 'BibTeX or the supplied .bbl file is required.' >&2; exit 1
fi
pdflatex -interaction=nonstopmode -halt-on-error erdos647_sparsity.tex
pdflatex -interaction=nonstopmode -halt-on-error erdos647_sparsity.tex
printf '\nPDF: %s/erdos647_sparsity.pdf\n' "$PWD"
