# Next mathematical target: amplified errors and final endpoint

Date: September 8, 2026. Baseline: the newer accepted v42 run, 21/21 gates.
This is a proposed implementation assignment, not new accepted Lean source.
The gap-and-size PR is a separate, locally validated changeset.

## Goal and fixed parameters

Prove a same-scale endpoint with an explicit fixed coefficient c>0:

\[
 C(X)\le X\exp\left(-c\frac{(\log X)^a}{\log\log X}\right),
 \qquad a=\frac{\log2}{1+\log2},
\]

for all sufficiently large natural X. Keep the current exact definitions:
Q=log X, L=log(log X), H=windowLength(X), J=truncationOrder(X),
y=primeCutoff(X), t=momentT(X)=1/(1000L), z=1-t,
lambda=primeMass(H,y), B=correctedBudget(H), eta=-log z, mu=t*lambda.

Do not change a or the saving scale. Do not optimize arbitrary coefficients.
Neither 1/1000 nor another final coefficient is mandatory. Record the explicit
c actually proved, and prove the historical EndpointClaim only if essentially free.

## Accepted interfaces to consume

All names below refer to existing declarations, not new assumptions.

In `Erdos647Sieve.Endpoint`:

- `eventually_endpoint_mass_budget_bounds`: H>=1, L>0, 0<=lambda<=HL,
  B<=HL, and lambda-B>=3H/2, eventually, without assuming B>=0.
- `eventually_primeMass_gap_of_lt`: every fixed delta<K is available,
  K=log(25/2)+1/log 2-2. The fixed 3/2 corollary is sufficient.
- `endpoint_parameters_admissible`, `eventually_momentT_bounds`,
  `truncationOrder_bounds`, `eventually_truncationOrder_pos`.
- `windowLength_ratio_tendsto_one`, `log_windowLength_div_logLog_tendsto`,
  `truncationOrder_div_windowLength_tendsto`, `log_primeCutoff` and the
  established growth results.
- `EndpointBound`, `endpointBound_iff_eventually`, `endpointBound_mono`,
  `positiveEndpointClaim_of_explicit` from `Endpoint/Statement.lean`.

In `Erdos647Sieve.Elementary`:
`neg_log_one_sub_le_add_sq`, `endpoint_tail_log_constant`, and
`factorial_pow_lower`.

For counting: `Erdos647Sieve.finiteCounting` and
`candidateCount_le_window_of_negative_correctedBudget`.
Read the exact types and casts before applying them. Do not assume the existing
parameter lemmas already include every product-scale limit needed below.

## First bounded milestone: principal term and amplification

Introduce only small named definitions/adapters when they eliminate repeated
presentation mismatches. Prove the eta estimates on 0<=t<=1/2, using the existing
quadratic logarithm bound. Under B>=0, combine the accepted gap and size bounds:

\[
 \eta B-\mu
 \le -t(\lambda-B)+t^2B
 \le-\frac{1499}{10^6}\frac H L.
\]

This rational coefficient falls out by algebra; there is no numerical optimization
problem here. A coarser fixed positive principal coefficient is fine when useful.
Also obtain the convenient upper estimate eta*B<=H/500.

State explicitly when B>=0 is needed. Multiplying an upper bound on eta by a
negative B reverses the inequality. Do not assume eventual B>=0 to evade that issue.
The final negative-budget branch is handled by the existing counting theorem.

Prove the bound for the actual principal contribution X*exp(eta*B-mu), not only
an unrelated exponent expression. A separate general real-variable lemma may be
useful, but it does not replace the specialization to the actual parameters.

## Second milestone: the growing-numerator factorial tail

Put q=J+1. From accepted bounds derive mu<=H/1000, q>=H/50, and q>=1.
Use the accepted factorial lower bound, with the factorial cast to real first:

\[
 e^{\eta B}\frac{\mu^q}{q!}
 \le e^{H/500}(e/20)^q
 \le e^{-H/30}.
\]

The final numerical comparison is already provided by `endpoint_tail_log_constant`.
A different comfortable fixed positive decay rate is acceptable, but cannot be
assumed. Do not apply a fixed-numerator c^n/n! limit to mu(X).
All denominator positivity and real/natural exponent conversions stay explicit.

## Third milestone: arithmetic remainder and exceptional window

Derive the exact identity y^J=X^(1/4) eventually, using J>0 and X>0.
The amplified remainder is

\[
 e^{\eta B}(Hy)^J=X^{1/4}\exp(J\log H+\eta B).
\]

Prove actual limits/eventual inequalities, for example
(J log H + eta B)/Q -> 0 under the nonnegative-budget conditions, or a
sufficient unconditional upper comparison for the applicable counting branch.
Show H*L/Q -> 0 from a<1 and the established parameter ratios, using library
logarithm/power comparisons. Do not insert it as an unproved estimate.

A coarse bound by X^(1/2) eventually is enough to make this term negligible at
the target scale. Similarly handle the initial H contribution explicitly.
Do not drop the multiplier exp(eta*B).

## Final assembly and the sign split

For B>=0, apply the accepted finiteCounting inequality with the actual parameters
and combine the four contributions:

\[
 H + X e^{\eta B-\mu}
 + X e^{\eta B}\frac{\mu^{J+1}}{(J+1)!}
 + e^{\eta B}(Hy)^J.
\]

For B<0, the existing theorem gives candidateCount(X)<=H. Absorb that using the
same eventual scale comparison, with no unsupported assumption that B is eventually
nonnegative. The final theorem must cover both signs for every sufficiently large X.

Use H/Q^a -> 1 and a strict coefficient margin to absorb floors, sums and numerical
prefactors. Work with normalized ratios tending to zero, then a single eventual
upper bound, rather than optimizing separate prefactors. A choice such as c=1/2000
would be sufficient if it falls comfortably out of the proved inequalities; it is
not a prescribed target or a currently proved coefficient.

Export an actual `EndpointBound c` at a named explicit c>0 and derive
`PositiveEndpointClaim`. Keep c fixed before X0 and X. No assumed gap, growth,
error estimate, or endpoint proposition may remain in the unconditional statement.
Only then update `proved_coefficient`, `proved_endpoint_theorem` and endpoint
acceptance evidence. The gap constant 3/2 must never be recorded as c.

## Packaging and audit boundary

Add new modules and audits; preserve the 47 accepted mathematical modules and
22 audits unless a necessary adapter issue is specifically identified. Keep
Lean/Mathlib 4.32.2, the restricted PNT+ interface, independent Mathlib-only core,
warning policy and axiom allowlist unchanged. Keep incremental builds.

Each substantive new module needs expanded type checks, transitive axiom reports,
registered prerequisites and warning-free acceptance. Stage this work so a failure
in one error source does not prevent useful independent feedback from another.
The final assembly must not be described as complete because only a helper passes.

No solution to the existence question in Erdős #647 is implied by this density
bound; its right-hand side still grows. Novelty and external review are separate.
