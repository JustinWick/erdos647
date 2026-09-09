# Promote reusable elementary results and add the proof paper

## Summary

Publish the completed proof as a readable LaTeX/PDF manuscript under `paper/`,
and make its reusable elementary ingredients available through the Mathlib-only
core. Preserve the accepted theorem statements, proof bodies, namespace/API
compatibility, and pinned Lean/Mathlib 4.32.2 dependency environment.

## Library and public interfaces

- Promote seven elementary implementations into `Erdos647Sieve/Elementary/`:
  factorial bounds and asymptotics, the logarithmic-budget/factorial connection,
  the reciprocal-prime lower bound, the small-prime debit, logarithm bounds,
  and the corrected-budget estimate. The opt-in public import is
  `Erdos647Sieve.Elementary`.
- Preserve the old research paths as one-import forwarders; theorem names do
  not change. The existing finite facade remains unchanged, and the core has
  no PNT+ dependency.
- Add public `Erdos647Research.Endpoint` and `Erdos647Research.Analytic` facades,
  usage examples, and expanded statement/axiom checks. The completed analytic
  theorem remains in the separate PNT+-dependent package.

## Paper

Add *A logarithmic-budget sieve for Erdős problem #647: An explicit sparsity
bound with a Lean formalization*, with editable LaTeX source, rendered 25-page
PDF, bibliography, build script, and a supplementary verification record.

AI author: **GPT 6 Astra**. Operator: **Justin V. Wick**.
Independent project; no institutional affiliation.

The manuscript starts from the original divisor-function problem, states the
result, describes the ChatGPT/operator methodology, and develops the proof in
mathematical stages: the signed logarithmic budget, weighted Bonferroni estimate,
CRT and translated-interval counting errors, factorial/debit estimates,
Mertens convergence, parameter asymptotics, the positive mass–budget gap,
amplified errors, and final absorption. It also documents reusable machinery,
prospective connections to other Erdős problems, and theorem-to-Lean provenance.

The result is: for every **fixed** real coefficient

$$
0<c<\frac{1499}{10^6},\qquad a=\frac{\log2}{1+\log2},
$$

there exists a threshold $X_0=X_0(c)$ such that, for every natural $X\ge X_0$,

$$
C(X)\le X\exp\!\left(-c\,\frac{(\log X)^a}{\log\log X}\right).
$$

The explicit specialization $c=1/1000$ is included. The upper endpoint
$1499/10^6$ itself is not asserted.

## Validation

The supplied v48 repository-wide run passed **30/30 gates**, with **235 distinct
transitive-axiom reports**, **220 exact-type/definition checks** across **32 audit
files**, and **317 runner tests**. There were no build/audit warnings or errors,
no checked-source changes during the run, and both package caches were reused.
The only permitted transitive axioms are `propext`, `Classical.choice`, and
`Quot.sound`.

Evidence run: `erdos647_repo_v48_results_20260909T014011Z_dd165b9f`.
The paper supplement preserves the original results archive, its fingerprint,
and a read-only source/log consistency checker. PDF rendering and paper-evidence
checks are separate from Lean proof acceptance.

## Scope and limitations

This is a publication and library-interface changeset, not a stronger theorem
than the accepted endpoint. It does not resolve the existence question in #647,
prove finiteness, provide a numerical $X_0$, establish priority, or constitute
independent peer review or independent-kernel replay.

The paper's generic residue-set template is identified as a paper-level
extension rather than an additional exported v48 Lean theorem. The discussion
of #679, #826, #413, and #248 proposes applications and records limitations; it
claims no new solution to those problems.

The optional publication-tooling overlay v49 is a separate follow-up. Its checks
are not included in the v48 30/30 acceptance claim.
