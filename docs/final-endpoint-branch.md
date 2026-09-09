> **Completed in v47:** all 29 gates passed. The general coefficient range and the 1/1000 corollary are accepted. The plan below is historical; see [current proof status](proof-status.md).

# Final endpoint branch — v46

## Accepted starting point and separate PR boundary

The v45 run passed all 26 gates, including the 25 amplified-error declarations.
The current amplified-error PR is locally ready on that source snapshot. Its
[prepared summary](pull-requests/amplified-errors.md) excludes the new work here.

This overlay adds final absorption; **its three new gates are pending**. It
preserves all 52 accepted mathematical modules and all 27 existing audit files.
Neither the stable Mathlib-only core nor its public imports change.

## Objective and explicit coefficient

Prove `EndpointBound c` for every fixed real $c<1499/10^6$; the useful saving
range is $0<c<1499/10^6$. Supply the named specialization at **$c=1/1000$**, the
existential positive-coefficient theorem, and the historical `EndpointClaim` as
corollaries. These declarations are implemented in the new source, not accepted
by the preceding v45 run. The committed `proved_coefficient` remains null until
the final gate succeeds.

There is no constant optimization: $1/1000<1499/10^6$ is rational arithmetic.
The stronger interval statement is the same absorption proof, with c left as a
fixed parameter. Nothing claims the endpoint of that interval or an optimal c.

The exponent $a=\log 2/(1+\log 2)$, all protected parameters, and the scale
$S(X)=(\log X)^a/\log\log X$ remain unchanged. The coefficient is outside both
the onset and X quantifiers, and cannot depend on X.

## The absorption argument

Write $Q=\log X$, $L=\log\log X$, $H=\lfloor Q^a\rfloor$, and $k=1499/10^6$.
The accepted all-sign reduction is

$$C(X)\le X e^{-kH/L}+X e^{-H/30}+2e^{Q/2}.$$

`AbsorptionScales` proves $S\to\infty$, $S/H\to0$, and $S/Q\to0$ from the
accepted parameter limits and existing Mathlib limit lemmas.

Divide the entire bound by the positive expression $D_c(X)=X e^{-cS(X)}$.
The three ratios are

$$\exp((c-kH/Q^a)S),\qquad
\exp((cS/H-1/30)H),\qquad
2\exp((cS/Q-1/2)Q).$$

For $c<k$, the coefficients in those exponents tend respectively to $c-k<0$,
$-1/30<0$, and $-1/2<0$. Their positive scales diverge, so all three ratios tend
to zero. Therefore their sum is eventually at most one. This absorbs rounding,
the number of terms, and the factor two **without a leftover multiplicative
constant** or an effective numerical onset computation.

`Main` then combines this majorant comparison with the accepted all-sign
counting reduction. There is no new budget-sign, PNT, moment, gap or error-bound
premise in the final theorem.

## Source and audits

| Module | Required output |
|---|---|
| `Endpoint/AbsorptionScales` | Positivity of the target and the three scale limits |
| `Endpoint/ErrorAbsorption` | Exact ratios, all three limits and whole-majorant absorption |
| `Endpoint/Main` | General fixed-c result, c=1/1000, positive existential, historical endpoint |

The full suite has 29 gates: the accepted 26 plus three new gates. The new sources
have 15 named theorem/axiom targets and 23 expanded type/definition checks.
Warnings remain errors and only `propext`, `Classical.choice`, and `Quot.sound`
are permitted. The final audit spells out the natural onset, fixed coefficient,
original exponent, saving scale, and candidate count; no named proposition alone
is treated as a statement check.

The runner changes `endpoint_proved` only after the current final build and audit
succeed with their prerequisites, allowed axiom reports and stable checked source.
A core-only run, an earlier PASS, or a failed audit printing clean axioms cannot
set that flag. Source and documentation are not edited during checking.

## Scope

A passing final gate establishes this density bound at the project's build/type/
axiom-audit standard. It does not resolve #647, establish finiteness, determine a
last candidate, prove optimality, establish novelty, or supply an explicit onset.
External statement review and comparison with prior mathematics remain separate.

## Reused library interfaces

The new source uses `isLittleO_log_rpow_atTop`, `tendsto_nhdsWithin_iff`,
`tendsto_inv_nhdsGT_zero`, `Filter.Tendsto.neg_mul_atTop`, and
`Real.tendsto_exp_atBot` in the unchanged Mathlib dependency. The negative-limit
multiplication interface was checked at the actual pin:

`https://raw.githubusercontent.com/leanprover-community/mathlib4/905b95818eb32af7874a58b427f50c1711a5e96c/Mathlib/Topology/Algebra/Order/Field.lean`

No new dependency, compiler version, CI trigger, search-path workaround or source
synchronization framework is introduced. The result prefix is
`erdos647_repo_v46_results_`.

## v47: explicit scale conversion

The v46 uploaded run passed all 26 predecessor gates. The absorption-scale build
failed at one conversion: its term was a limit of the explicit reciprocal quotient,
while the target retained the named function `endpointScale`. The other two
final-assembly gates were blocked. No endpoint coefficient was accepted.

The repair explicitly exposes the quotient definition in the goal, then uses
`inv_div`. Only this proof step changes. Every existing theorem statement and
audit stays unchanged, as do the exponent, parameters, and coefficient range.

The 29-gate suite is retained. New diagnostics have the prefix
`erdos647_repo_v47_results_`. The amplified-error PR remains supported by its
accepted evidence; the final-assembly PR awaits the three final gates.
