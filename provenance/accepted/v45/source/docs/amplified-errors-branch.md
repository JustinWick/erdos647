# Amplified errors: the next mathematical changeset (v44)

## Boundary between the two PRs

The preceding prime-mass/budget-gap PR has a passing 21/21-gate record, confirmed
by `erdos647_repo_v43_results_20260908T120436Z_93d219fb`. It is locally ready for a
normal PR. This overlay starts a separate mathematical changeset; its new gates
have pending acceptance. It does not change any of the 47 accepted mathematical
modules or 22 existing audit files. Repository CI and review of the actual GitHub
diff are not inferred from the uploaded local logs.

## Objective

Bound EVERY contribution in the accepted finite counting inequality, including
the full amplification multiplier, then reduce endpoint assembly to a final
asymptotic absorption argument. This is not an infrastructure or dependency port.

Keep the protected definitions:

\[
Q=\log X,\quad L=\log\log X,\quad
 a=\frac{\log2}{1+\log2},\quad H=\lfloor Q^a\rfloor,\quad
J=2\lceil H/100\rceil,\quad y=X^{1/(4J)},\quad t=\frac1{1000L}.
\]

Write \(\lambda=\operatorname{primeMass}(H,y)\),
\(B=\operatorname{correctedBudget}(H)\), \(\eta=-\log(1-t)\),
\(A=\eta B\), and \(\mu=t\lambda\). Here A denotes amplification, not an interval
translation. The three named adapters `endpointEta`, `endpointMu`, and
`amplificationExponent` only package these exact expressions.

## New proof-source targets

### Amplification and principal term

For the nonnegative-budget branch, combine the accepted gap and size estimates
with the existing quadratic logarithm bound:

\[
A\le H/500,\quad 0\le\mu\le H/1000,\quad
A-\mu\le-\frac{1499}{10^6}\frac HL.
\]

The rational coefficient is an algebraic consequence of the existing parameters,
not an optimization target. The actual principal contribution is bounded by
\(X\exp[-1499 H/(10^6 L)]\).

### Factorial tail with a growing numerator

For \(q=J+1\), use \(q\ge H/50\), \(\mu\le H/1000\), and the accepted
\((q/e)^q\le q!\). The implementation targets

\[
e^A\frac{\mu^q}{q!}\le e^{-H/30}.
\]

No fixed-numerator `c^n/n!` limit is used. All factorials are formed in the
naturals and cast to the reals before division.

### Arithmetic and exceptional-window contributions

Prove the exact identity \(y^J=X^{1/4}\) after establishing \(X,J>0\), then

\[
e^A(Hy)^J=\exp(Q/4+J\log H+A).
\]

Use \(HL/Q\to0\), \(J\log H/Q\to0\), and \(A\le H/500\) in the applicable
budget branch to bound the full expression by \(e^{Q/2}\) eventually. Separately
bound the exceptional window \(H\le e^{Q/2}\), with no budget sign assumption.
For positive X, \(e^{Q/2}=X^{1/2}\).

### All-sign counting reduction

The final new declaration targets the unconditional intermediate estimate

\[
\boxed{
C(X)\le
X\exp\!\left[-\frac{1499}{10^6}\frac HL\right]
+Xe^{-H/30}+2e^{Q/2}
\quad\text{eventually}.
}
\]

For B>=0 it is an application of `finiteCounting` and the three weighted bounds.
For B<0 it uses `candidateCount_le_window_of_negative_correctedBudget` and the
exceptional-window estimate. It does not assert that the budget is eventually
nonnegative. The factor 2 accounts for both the arithmetic remainder and H.

## Modules and checks

| Module | Gate |
|---|---|
| `Endpoint/Amplification.lean` | `endpoint_amplification` |
| `Endpoint/MomentTail.lean` | `endpoint_moment_tail` |
| `Endpoint/ErrorScales.lean` | `endpoint_error_scales` |
| `Endpoint/ArithmeticRemainder.lean` | `endpoint_arithmetic_remainder` |
| `Endpoint/CountingReduction.lean` | `endpoint_counting_reduction` |

The scope is 25 new theorem targets and 31 expanded type/definition checks.
The full suite has 26 gates: the accepted 21 plus these five. `ErrorScales` is
independent of the factorial/PNT/mass-gap route; an error on that route does not
prevent useful feedback for the elementary growth comparisons.

Warning handling and the transitive-axiom allowlist are unchanged. Lean/Mathlib
stays at 4.32.2, with the same pinned dependency lockfiles. The runner changes
only its output prefix to `erdos647_repo_v44_results_`; Lake still owns incremental
build invalidation. No cache or prior result is deleted.

## Remaining final absorption

No declaration of `EndpointBound c` or `PositiveEndpointClaim` is introduced by
this overlay. Once the new counting reduction is accepted, set \(S=Q^a/L\), prove
\(S\to\infty\) and \(S/Q\to0\), and divide the intermediate bound by
\(X e^{-cS}\). Choose any comfortable explicit fixed
\(0<c<1499/10^6\) using the already accepted \(H/Q^a\to1\).

The three normalized contributions then tend to zero; one eventual comparison
absorbs their sum without an unspecified multiplicative constant. A value such
as 1/2000 is sufficient as a planning example, not a required or proved value.
The old 1/1000 statement is a corollary only if it follows with essentially no
extra work. Preserve a and the asymptotic scale, record the actual final c, and
do not mark it proved before its exact statement and axiom audit pass.

This density theorem would not settle the existence question in Erdős #647.

## Source reuse

The new code consumes the accepted project factorial, logarithm, mass-gap, and
parameter results. The growth comparison uses Mathlib's
`isLittleO_log_rpow_atTop`, checked at commit
`905b95818eb32af7874a58b427f50c1711a5e96c`,
`Mathlib/Analysis/SpecialFunctions/Pow/Asymptotics.lean`.
No additional external theorem is adopted and no accepted proof is reopened.


## v45 audit repair following the v44 run

The v44 run retained the accepted 21/21 baseline. The new `Amplification` and
`ErrorScales` proof modules both built successfully, but their audit commands
exited 1 for ten unused hypothesis-name diagnostics. Although the audit logs
printed allowed axiom sets for thirteen declarations, neither whole gate passed.
`MomentTail`, `ArithmeticRemainder`, and `CountingReduction` were blocked.

v45 leaves all mathematical modules and target statements unchanged. It replaces
only unused proof-binder names with `_` in four audit files, including the two
blocked files with the same pattern. Every premise, quantifier, check and axiom
target remains present; warnings are still errors. The intermediate counting
bound and final endpoint remain pending. No fixed endpoint coefficient is claimed.
