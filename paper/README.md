# A logarithmic-budget sieve for Erdős problem #647

**An explicit sparsity bound with a Lean formalization**

AI author: **GPT 6 Astra**  
Operator: **Justin V. Wick**  
Independent project; no institutional affiliation. September 2026.

## Contents

- `erdos647_sparsity.pdf`: the rendered 25-page paper.
- `erdos647_sparsity.tex`: complete editable LaTeX manuscript.
- `references.bib`: 20 bibliographic entries, with primary-literature and software references.
- `erdos647_sparsity.bbl`: generated bibliography included for convenience.
- `BUILD_PDF.sh`: rebuilds the PDF with pdfLaTeX and BibTeX; it never runs Lean or accesses the network.
- `supplement/`: the exact operator-supplied v48 results archive, its reviewed evidence, and a read-only consistency checker.

The paper walks through the full mathematical argument: signed logarithmic
budget, finite weighted Bonferroni estimate, CRT/progression errors, factorial
and debit estimates, Mertens convergence, parameter asymptotics, the positive
mass–budget gap, all amplified contributions, and final absorption. It also
contains the methodology, reusable-library discussion, proposed connections to
other Erdős problems, a theorem-to-Lean map, and version/hash provenance.

## Result and limitations

For every **fixed** `0 < c < 1499/1,000,000`, and all sufficiently large natural
`X`, the paper proves

`C(X) <= X exp(-c (log X)^a / log log X)`,

where `a = log(2)/(1 + log(2))`. The bound holds in particular for `c=1/1000`.
The threshold may depend on `c` and is not numerically supplied. The boundary
coefficient `1499/1,000,000` itself is not asserted. This is a sparsity result,
not a proof of finiteness or a resolution of the existence question in #647.

The generic residue-set template in Section 12.2 is an explicitly identified
paper-level extension, not an additional exported Lean theorem in v48. The
related-problem section proposes uses and states their limitations; it does not
claim new results for #679, #826, #413, or #248. Priority and external peer review
are not certified by the build record.

## Building the manuscript

The source uses standard TeX Live packages: `amsmath`, `amsthm`, `newtx`,
`microtype`, `geometry`, `natbib`, `xurl`, `hyperref`, `booktabs`, `longtable`,
`tabularx`, and `fancyhdr`. Run `bash BUILD_PDF.sh` in this directory. A complete
TeX Live installation includes the required packages. The script detects
`bibtex`, `bibtex.original`, or `bibtex8`; a generated `.bbl` is also provided.

The file does not require custom font files, images, shell escape, a Python
package, or network downloads. No fonts are distributed in this source bundle.

## Checking the supplied evidence

`python3 supplement/verify_evidence.py` checks the original archive fingerprint,
296 manifest entries, 179 stable source inputs, 30 passing gates, command exit
codes, all 235 distinct raw axiom reports, and 220 exact-type/definition examples
in 32 audit files. It is a source-and-log review, not a Lean execution or an
independent kernel replay. The original archive contains the source and audit
files against which the paper was written.

## Citation and model provenance

The AI author attribution and human operator designation follow the operator's
request. The methodology records chatgpt.com and the operator-reported interface
label “GPT-6 Pro” (Astra). It does not treat that label as an independently pinned
or replayable model artifact. The mathematical proof is the object verified.

No GitHub files were changed or published in creating this manuscript bundle.
