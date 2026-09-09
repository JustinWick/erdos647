# Source and claim ledger

Research session: September 5, 2026 (America/New_York).

The new budget-debit/endpoint derivation in `MANUSCRIPT.md` is the originating assistant's argument. It is not attributed to any of the external sources below. No external novelty certification or independent reviewer has been obtained.

## Existing project materials

`RESEARCH_DIRECTION.md` and `REVIEW_REQUEST.md` from the original logarithmic-budget package were read in full. They proposed the quarter-power bound, the general fixed-subcritical calculation, and the original finite moment lemma. Their stated lack of independent review, Lean verification, and established novelty remains in force.

The original `check_finite_lemma.py` was rerun, and the full JSON equals the original JSON. This is reproducibility by the same assistant, not a second independent mathematical investigation.

## Hughes consolidation

Title: *Erdős problem 647: reductions, density bounds, and the prime-tuples barrier*.

Source: `https://github.com/scottdhughes/erdos647-proof-chain/blob/main/paper/main.tex`

Live source was fetched through the GitHub connector. The paper-directory listing confirms blob SHA `c1a0570e10c6f3bd7b0549a138637c3023ed4cd2`, matching the previous session's inspected source. The current directory lists `main.tex`, `main.pdf`, and an `archive` directory. The TeX source, not the PDF, was analyzed in this session.

Inspected claim: C(X)<=X exp(-(log log X)^(2-o(1))), from an aggregate Omega budget, with proofs attributed to submitted companion manuscripts. Those manuscripts were not retrieved. Do not treat the consolidation as a proof audit of them, nor an exhaustive catalogue of density bounds.

Repository landing page also retrieved by web search:
`https://github.com/scottdhughes/erdos647-proof-chain`

## Problem page and forum

Direct opens of `https://www.erdosproblems.com/647` and `https://www.erdosproblems.com/forum/thread/647` returned HTTP 403. Web search did surface an indexed excerpt of the forum quoting Hughes's stated density estimate. The excerpt was inspected; the complete current forum was not. Search indexing dates were older than the session.

Exact-title and topical searches, including combinations of Erdős 647, density, logarithmic budget, Bonferroni, and omega, did not establish priority. Irrelevant search results were not used. Absence of a result is not evidence that no such theorem exists.

## Tao–Teräväinen

Terence Tao and Joni Teräväinen, *Quantitative correlations and some problems on prime factors of consecutive integers*, arXiv:2512.01739v2, April 25, 2026.

`https://arxiv.org/html/2512.01739v2`

Inspected introduction: equation (1.5) records omega<=log(tau)/log2<=Omega. Remark 1.2 discusses why the existence constructions do not handle the small-shift demands of #647. Those results are contextual comparisons, not dependencies of our upper-bound sieve proof.

## Lau

Cheuk Fung (Joshua) Lau, *On the Number of Prime Factors of Consecutive Integers*, arXiv:2604.15042, current HTML.

`https://arxiv.org/html/2604.15042`

Inspected Theorem 1.3: infinitely many n satisfy omega(n-k)<=Omega(n-k)<=C log k for every 1<k<n, for an absolute unspecified C. This is an existence theorem with a different threshold, not the candidate-count bound proved here.

## Mertens estimate

Z. Chen and J. R. Luo, *Multiple Mertens theorems for arithmetic progressions*, arXiv:2512.07336v1.

`https://arxiv.org/html/2512.07336v1`

The introduction's equation (1.2) records the classical estimate

    sum_(p<=u) 1/p = log log u + M + O(1/log u).

Only this classical theorem is used. No new arithmetic-progression or multiple-Mertens theorem from the paper is required. The elementary lower bound for the small-prime debit is proved directly in our manuscript, so no numerical value of the Mertens constant is assumed.

## Open gates

Mathematical: external audit of the full endpoint derivation and its dependencies.

Priority: obtain and compare the two companion density manuscripts, the full current forum, and relevant general high-dimensional sieve results. Neither lack of retrieval nor failure of search licenses a novelty claim.

Formal: no Lean or lake executable was found; no proof/build/audit was performed.

Effective: no explicit onset X_0 or practical frontier exclusion follows from the current asymptotic proof.
