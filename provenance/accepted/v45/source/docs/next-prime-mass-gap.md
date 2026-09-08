> **Completed in the newer v42 run (21/21 passed).** This is the preserved original
> assignment, not the current pending task. Its proposed interfaces were implemented
> in `PrimeMassGap.lean` and `MassBudgetBounds.lean`. The next task is
> [amplified-error control and final assembly](next-amplified-errors.md).

# Next mathematical changeset: the fixed positive prime-mass/budget gap

Date: 2026-09-08. Starting evidence: v40, 19/19 gates passed.
This document is an implementation assignment, not an added theorem or proof audit.

## Finish line

Add a new module `Erdos647Research.Endpoint.PrimeMassGap` with theorem namespace
`Erdos647Sieve.Endpoint`, consuming the accepted parameter, budget and logarithm
interfaces. Do not edit the accepted finite, PNT+, Mertens, factorial, debit or
parameter proofs unless a genuinely necessary interface repair is identified.

For the actual protected parameters, put
\[
L=\log\log X,\quad H=\operatorname{windowLength}(X),\quad
 y=\operatorname{primeCutoff}(X),\quad
\lambda=\operatorname{primeMass}(H,y),\quad B=\operatorname{correctedBudget}(H).
\]

The first target is an unconditional eventual statement
\[
\boxed{\lambda-(B:\mathbb R)\ge\delta H}
\]
for an explicit fixed \(\delta>0\). The accepted numerical margin already supports
\(\delta=3/2\); a smaller comfortable fixed value is acceptable if it materially
simplifies the argument. Do not replace \(\delta\) by a function tending to zero.
No extra budget nonnegativity assumption is needed for the gap theorem.

A sufficient proposed Lean interface (not currently declared) is:

```lean
∀ᶠ X : ℕ in Filter.atTop,
  (3 / 2 : ℝ) * (windowLength X : ℝ) ≤
    primeMass (windowLength X) (primeCutoff X) -
      (correctedBudget (windowLength X) : ℝ)
```

## Accepted inputs, with their actual names

From the parameter layer:
`windowLength_tendsto_atTop`, `eventually_windowLength_pos`,
`logLogX_tendsto_atTop`, `endpointExponent_pos`, `endpointExponent_lt_one`,
`endpointExponent_cancellation`, `log_windowLength_sub_tendsto_zero`,
`log_windowLength_div_logLog_tendsto`,
`endpoint_primeMass_expansion_tendsto_zero`, and
`endpoint_parameters_admissible`, all in `Erdos647Sieve.Endpoint`.

From the elementary layer:
`Erdos647Sieve.Elementary.correctedBudget_upper_eventually` and
`Erdos647Sieve.Elementary.endpoint_log_gap`.

The latter is the already-audited strict inequality
\[
K:=\log(25/2)+1/\log2-2>3/2.
\]

The budget theorem is eventual over natural **H**, not X. Compose its eventual
statement with `windowLength_tendsto_atTop`. Keep real casts of the signed integer
budget explicit. The window theorem supplies \(\log H-aL\to0\), rather than merely
\(\log H/L\to a\); use the stronger form to retain the constant.

## Suggested finite-epsilon assembly

The two accepted residuals give
\[
\lambda/H=(1-a)L-\log\log H+\log(25/2)+r_\lambda(X),\quad r_\lambda\to0,
\]
\[
\log H=aL+r_H(X),\quad r_H\to0.
\]
The accepted budget upper bound, for each fixed \(\varepsilon>0\), eventually gives
\[
B/H\le\log H/\log2-\log\log H+2-1/\log2+\varepsilon.
\]
Use \(a/\log2=1-a\). After subtraction the lower estimate is
\[
(\lambda-B)/H\ge K+r_\lambda-r_H/\log2-\varepsilon.
\]
For any fixed \(\delta<K\), choosing \(\varepsilon=(K-\delta)/4\) leaves slack
when both residual magnitudes are at most \(\varepsilon\). This is a proposed
proof route; v40 did not audit the application to the actual signed budget.

A general delta-below-K helper is useful only if it is essentially free. The
explicit positive-gap corollary is the required result, not numerical optimization.

## Supporting size estimates

In the same bounded changeset or a sibling module, establish
\[
\lambda/(HL)\to1-a,\qquad \lambda\le HL,\qquad B\le HL
\quad\text{eventually}.
\]

To handle the double logarithm in the prime-mass expansion, compose the standard
logarithm-over-identity limit at \(\log H\to\infty\) and multiply by the accepted
\(\log H/L\to a\). This gives \(\log\log H/L\to0\).
The residuals divided by \(L\to\infty\) vanish. Since \(0<a<1\), the limit
\(1-a<1\) leaves room for the displayed upper bounds. All eventual denominator
positivity facts must be proved from the accepted growth results.

Do not prove B is eventually nonnegative solely to avoid handling its sign.
The existing `candidateCount_le_window_of_negative_correctedBudget` remains
available for the negative case in the final counting assembly.

## After the gap: every amplified error, then the endpoint

Keep the existing \(t=1/(1000L)\), \(z=1-t\), \(J\), and \(y\).
With \(\eta=-\log z\), \(\mu=t\lambda\), the remaining obligations concern

\[
X e^{\eta B-\mu},\qquad
X e^{\eta B}\frac{\mu^{J+1}}{(J+1)!},\qquad
e^{\eta B}(Hy)^J,\qquad H.
\]

The multiplier must be included in every error. Use the accepted factorial lower
bound with a proved uniform bound on \(\mu/(J+1)\), not a theorem for a fixed
numerator. Express arithmetic-error absorption as actual limits/eventual
inequalities. Final assembly must yield `EndpointBound c` for a named explicit
fixed c>0; leave the exponent and \((\log X)^a/\log\log X\) scale unchanged.

The old `EndpointClaim` is a corollary only if the proved coefficient supports
1/1000 without substantial additional effort. No arbitrary replacement coefficient
is mandatory. At the v40 checkpoint `proved_coefficient` remains null.

## Gate and PR discipline

New source requires its own checked-in expanded type examples, transitive axiom
audits, warning-free build and registered prerequisites. Permit only `propext`,
`Classical.choice`, and `Quot.sound`; keep the source-admission and module-owner
checks. Preserve the locked Lean/Mathlib 4.32.2 environment and ordinary incremental
builds. Do not add a conditional wrapper and call its premises proved.

The completed parameter PR is not held open for this work. No new proof source,
new gate or endpoint theorem is included in the v41 documentation overlay.
