# Prove the fixed-coefficient sparsity endpoint for Erdős #647

## Summary

Complete the same-scale absorption of the previously accepted amplified-error
counting estimate and prove the asymptotic counting endpoint. The earlier finite
sieve, PNT/Mertens, elementary estimates, parameter asymptotics, and mass–budget
gap are used as proved inputs; no such input remains as an unproved hypothesis
in the final theorem.

## Main result

Let C(X) count natural numbers n ≤ X satisfying

$$24<n,\qquad \tau(n-k)\le k+2\quad(1\le k<n),$$

and put $a=\log 2/(1+\log 2)$. For every **fixed** real constant

$$0<c<\frac{1499}{10^6},$$

there exists $X_0=X_0(c)\ge3$ such that for every natural $X\ge X_0$,

$$\boxed{C(X)\le X\exp\!\left(-c\,\frac{(\log X)^a}{\log\log X}\right).}$$

In particular this holds with **c=1/1000**. The coefficient is independent of X;
its choice precedes the onset quantifier. The strict upper threshold 1499/10^6
is not claimed as an attained or optimal coefficient. No explicit numerical X0
is computed.

## Proof organization

- `Endpoint/AbsorptionScales.lean`: prove that
  $S=(\log X)^a/\log\log X$ diverges, $S/H\to0$, and $S/\log X\to0$.
- `Endpoint/ErrorAbsorption.lean`: divide the complete accepted majorant by
  $X e^{-cS}$ and show all three normalized contributions tend to zero.
  The amplified factorial tail, amplified arithmetic error, exceptional window,
  and factor two are all retained.
- `Endpoint/Main.lean`: assemble the coefficient-parametric theorem and derive
  the explicit 1/1000, positive-coefficient, and historical endpoint corollaries.

The argument uses the all-sign counting reduction, so no eventual nonnegativity
of the signed corrected budget is assumed. The internal moment parameter
$t=1/(1000\log\log X)$ is unchanged.

## Exported results

```lean
Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate
Erdos647Sieve.Endpoint.endpointBound_one_div_thousand
Erdos647Sieve.Endpoint.positiveEndpoint
Erdos647Sieve.endpoint
```

The general Lean theorem actually holds for every real c below 1499/10^6;
the positive subrange is the substantive sparsity statement.

## Validation

Accepted run: `erdos647_repo_v47_results_20260908T205250Z_0078dcb7`.

- **29/29 gates passed**, including all three final-assembly gates.
- **235 distinct declarations** passed transitive-axiom audits; permitted axioms
  remain exactly `propext`, `Classical.choice`, and `Quot.sound`.
- **194 exact-type/definition checks** across 30 audit files; **284 runner tests**
  passed. No warnings or errors in successful build/audit logs.
- All recorded commands succeeded; checked sources were stable and caches reused.

The source/log consistency review checked 272 manifest entries and 159 checked
source/configuration hashes. The raw final audit is
`provenance/accepted/v47/logs/067_endpoint_final_audit_0.log` in the checkpoint
record. Historical evidence is not a substitute for the PR's required CI.

## Scope and limits

This completes the stated sparsity theorem. It **does not resolve Erdős #647**,
exclude every candidate, prove finiteness, establish novelty, or provide an
independent kernel implementation's replay. The whole upstream PNT+ catalogue
is not certified; the restricted dependency closure is audited separately.

The Mathlib-only finite package remains separate from PNT+-dependent analysis.
Keep the subsequent module-promotion/API cleanup in a separate changeset; it is
not part of this tested endpoint proof snapshot.
