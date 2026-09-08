# Prime-mass/budget gap: the next mathematical changeset

Version: v42, 2026-09-08. Baseline: accepted v40 source and v41 evidence update.
This is new proof-source implementation with two new acceptance gates. The prior
parameter PR is a separate changeset. No remote PR is created or modified here.

## Purpose

The parameter layer established the actual cutoff asymptotics. This changeset
uses them to obtain a fixed positive excess of prime mass over the signed budget:

\[
 \lambda(X)-(B_{H(X)}:\mathbb R)\ge\tfrac32 H(X)
 \quad\text{eventually over natural }X.
\]

Here all parameters are the existing protected definitions:

\[
 H=\operatorname{windowLength}(X),\quad y=\operatorname{primeCutoff}(X),\quad
 \lambda=\operatorname{primeMass}(H,y),\quad B_H=\operatorname{correctedBudget}(H),
 \quad L=\log\log X,\quad a=\frac{\log2}{1+\log2}.
\]

No nonnegative-budget assumption is added. In particular, B_H is never converted
to a natural number, truncated at zero, or replaced by an absolute value.

This is the quantitative comparison needed before exponential weighting gives a
useful saving. It is not the final counting endpoint.

## Two new modules

`Erdos647Research.Endpoint.PrimeMassGap` contains five theorems and one definition.
It imports only accepted project-level interfaces:
`Endpoint.PrimeMassParameters`, `CorrectedBudgetEstimate`, and `EndpointLogBounds`.

`Erdos647Research.Endpoint.MassBudgetBounds` contains seven theorems and imports
the gap module. It supplies

\[
 \frac{\lambda}{HL}\longrightarrow1-a,\qquad
 0\le\lambda\le HL,\qquad B_H\le HL\quad\text{eventually}.
\]

Its final bundle includes H>=1, L>0, mass nonnegativity, both upper bounds, and the
fixed gap. It deliberately does not assert B_H>=0. The final counting argument
will retain the existing separate negative-budget case.

The theorem namespace remains `Erdos647Sieve.Endpoint`. No existing module,
theorem, definition, proof body, audit, or dependency pin is rewritten.

## The gap argument

Define the surviving constant

\[
 K=\log(25/2)+\frac1{\log2}-2.
\]

The new definition is `primeMassGapConstant`; the already accepted
`Elementary.endpoint_log_gap` proves K>3/2 without a new numerical approximation.
Define, for this explanation only,

\[
 F(H)=\frac{\log H}{\log2}-\log\log H+2-\frac1{\log2}.
\]

The accepted expansions give residuals r_lambda and r_H tending to zero such that

\[
 \frac\lambda H-F(H)=K+r_\lambda-\frac{r_H}{\log2}.
\]

The new limit theorem proves that expression tends to K. It does **not** claim
that (lambda-B_H)/H tends to K: the accepted budget result is one-sided.

For any fixed delta<K, choose epsilon=(K-delta)/2>0. Eventually,

\[
 \lambda/H-F(H)>\delta+\varepsilon,\qquad B_H/H\le F(H)+\varepsilon.
\]

The second statement is obtained by composing the accepted budget estimate over
natural H with the proved map H(X)->infinity. Subtract and multiply by H>0 to obtain
lambda-B_H>=delta H. The fixed delta=3/2 result is then an immediate specialization.

The general delta-below-K result is included because it is the same proof, not a
constant-optimization project. Delta is fixed before the eventual quantifier;
the onset can depend on delta, but delta does not depend on X.

## The size argument

First prove log H -> infinity and use Mathlib's logarithm-over-identity limit:

\[
 \frac{\log\log H}{L}
 =\frac{\log\log H}{\log H}\frac{\log H}{L}\longrightarrow0\cdot a=0.
\]

Divide the accepted prime-mass expansion by L->infinity to obtain lambda/(HL)->1-a.
Since a>0, the limiting constant is strictly less than 1; hence lambda<=HL
once H and L are positive. The positive gap already gives B_H<=lambda, so the
budget upper bound follows without another asymptotic budget proof.

The library input was inspected at the unchanged Mathlib commit
`905b95818eb32af7874a58b427f50c1711a5e96c`:
`Real.tendsto_pow_log_div_mul_add_atTop` in
`Mathlib/Analysis/SpecialFunctions/Log/Basic.lean`.
No new dependency or toolchain is introduced.

## Checking and preservation

The two new gates are `endpoint_prime_mass_gap` and `endpoint_mass_budget_bounds`.
Each theorem has a checked-in expanded type example, `#check`, and `#print axioms`.
The constant itself receives an additional expanded-definition check. Existing
warning, module-ownership, admission, and allowed-axiom checks are unchanged.

There are now 21 registered gates: the accepted 19-gate baseline plus these two
pending gates. The twelve new theorem targets and thirteen new type/definition
examples do not inherit acceptance from the old 19/19 run.

Ordinary incremental builds, the Mathlib-only core scope, all existing selective
gates, tools/caches, previous results, and CI settings remain intact. The only
runner behavior change is the diagnostic archive prefix `erdos647_repo_v42_results_`.

## Endpoint coefficient and next boundary

The gap constant delta=3/2 is **not** the endpoint saving coefficient c.
`proved_coefficient` remains null until a final `EndpointBound c` has actually
passed its own exact-type and axiom gate. The exponent a and saving scale remain
unchanged; no final numerical coefficient is compulsory.

The next changeset must bound every amplified contribution, not just the principal
term. With t=1/(1000 L), z=1-t, eta=-log z, mu=t lambda, those contributions are

\[
 X e^{\eta B_H-\mu},\qquad
 X e^{\eta B_H}\frac{\mu^{J+1}}{(J+1)!},\qquad
 e^{\eta B_H}(Hy)^J,\qquad H.
\]

The factorial numerator grows with X; a fixed-numerator limit is not a substitute
for its uniform estimate. All multiplier factors must remain present. Final
assembly will select and record a comfortable explicit fixed c>0. The historical
1/1000 endpoint is a corollary only when essentially free.

The local acceptance condition for this new mathematical PR is a warning-free
21/21 run with the exact statement/axiom reports, not completion of the endpoint.
