# PR title

Bound amplified sieve errors and derive the all-sign counting estimate

# PR summary

## Summary

Complete the amplified-error layer between the accepted prime-mass/budget gap
and the final endpoint. Add five research modules, exact-type and transitive-axiom
audits, and regression coverage. Preserve the finite core, analytic dependencies,
parameter choices, signed budget and pinned Lean/Mathlib 4.32.2 environment.

## Mathematical results

With the existing parameters

$$
a=\frac{\log 2}{1+\log 2},\quad Q=\log X,\quad L=\log\log X,
\quad H=\lfloor Q^a\rfloor,\quad J=2\lceil H/100\rceil,
\quad y=X^{1/(4J)},
$$

and $t=1/(1000L)$, $\eta=-\log(1-t)$, $\mu=t\lambda$, prove the eventual
bounds for a nonnegative corrected budget $B_H$:

$$
\eta B_H-\mu\le-\frac{1499}{10^6}\frac{H}{L},
\qquad e^{\eta B_H}\frac{\mu^{J+1}}{(J+1)!}\le e^{-H/30},
$$

$$
e^{\eta B_H}(Hy)^J\le e^{Q/2},\qquad H\le e^{Q/2}.
$$

The factorial estimate uses a uniform bound for the **growing** numerator, not a
fixed-numerator convergence argument. The arithmetic remainder retains its full
exponential multiplier; the exact identity $y^J=X^{1/4}$ is separately checked.

Handle $B_H<0$ using the existing negative-budget exclusion theorem. The final
statement has **no budget-sign premise**:

$$
C(X)\le
X\exp\!\left(-\frac{1499}{10^6}\frac{H}{L}\right)
+X e^{-H/30}+2 e^{Q/2}
\quad\text{eventually}.
$$

The factor two accounts for both the amplified CRT error and the exceptional
initial window. The exported declaration is
`Erdos647Sieve.Endpoint.eventually_candidateCount_le_amplified_errors`.

## Source organization

`Amplification` bounds the multiplier and principal term; `MomentTail` handles the
factorial tail; `ErrorScales` proves the growth comparisons; `ArithmeticRemainder`
bounds the amplified CRT error and exceptional window; `CountingReduction`
assembles the all-sign estimate. All 47 previously accepted mathematical modules
remain unchanged across this branch. The audit-binder repair retains every
hypothesis and exact statement; warnings remain fatal.

## Validation

The supplied v45 run passed **26/26 gates** with zero build/audit warnings or
errors and no changed checked inputs. It audited **220 distinct declarations**,
including **25 new amplified-error declarations**, using only `propext`,
`Classical.choice`, and `Quot.sound`. There are **169 exact-type/definition checks**
across 27 audit files, and all **244 runner tests** passed. Both package caches
were reused.

Run identifier: `erdos647_repo_v45_results_20260908T125209Z_b6d9b2cb`.
The source snapshots, command exit codes and raw axiom reports agree. Current
acceptance is not inferred from historical PASS labels or from packaging tests.

## Scope and follow-up

This PR proves the intermediate all-sign counting estimate, **not** a final
`EndpointBound c`, a finiteness result or a resolution of Erdős #647. Final
same-scale absorption belongs to the next mathematical changeset. The final
constant need not be optimized; the exponent $a$ and the saving scale remain
unchanged. No compiler migration, upstream PNT+ patch or new dependency is added.
