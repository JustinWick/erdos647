# New mathematical branch: endpoint parameter asymptotics

Date: 2026-09-08. First source delivery: v38.

## Goal and PR boundary

This is a **new mathematical changeset**, separate from the accepted v36 fixes
and v37 evidence update. The first PR on this branch should establish the actual
parameter asymptotics and their specialization of the already accepted Mertens
interface. It should not include another toolchain migration, upstream port, or
rewrite of the finite library.

**Why this is necessary:** the finite theorem permits any admissible parameters;
the Mertens bridge requires two cutoffs to diverge and be ordered. Neither result
by itself proves those properties for the particular parameters in `Specification`.
The new source targets that missing connection, including the constant term.

The returned run `erdos647_repo_v40_results_20260908T091111Z_0850cec9`
passed **19/19 gates**. The final cutoff and prime-mass gates add 15 newly accepted
declarations; the full run covers 183 distinct declarations with permitted axioms
and no build/audit warnings. All 43 branch declarations now have successful exact-
type and axiom evidence. Both packages reused their caches, with no source changes
during the run.

**This parameter-asymptotics changeset is ready for a normal PR on the checked
snapshot.** The v41 overlay freezes that boundary by updating documentation and
preserving evidence only. It does not add the gap proof or broaden the PR into
amplified-error absorption. See [accepted v40 evidence](../provenance/accepted/v40/README.md)
and the [next mathematical assignment](next-prime-mass-gap.md).

## Endpoint coefficient policy (user revision, 2026-09-08)

The final goal preserves the **critical exponent and exact asymptotic scale** but
no longer requires the arbitrary coefficient 1/1000:

\[
 C(X) \le X\exp\!\left(-c\,\frac{(\log X)^a}{\log\log X}\right),\qquad
 a=\frac{\log2}{1+\log2},\quad c>0.
\]

Here c is one explicit fixed real number, chosen **before** the onset X0 and
before X. It is not c(X), and it cannot tend to zero. The eventual onset may depend
on the chosen fixed coefficient. The final theorem must have no unproved analytic,
cutoff, budget-gap, or absorption premise.

`Endpoint/Statement.lean` introduces `EndpointBound c`, `endpointRHSWith c X`, and
`PositiveEndpointClaim` without modifying `Specification.lean`. It proves the
coefficient-order and legacy-statement adapters. An audited implication whose
premise is `EndpointBound d` is **not** itself a proof of an endpoint bound.

The historical `EndpointClaim` remains unchanged and is identified with
`EndpointBound (1/1000)`. Attaining that specialization is not an acceptance
requirement for this branch. There is **no replacement mandatory coefficient**.
Carry a proved positive decay margin symbolically, then choose and explicitly
record a comfortable fixed rational coefficient. Retain stronger smaller-than-margin
coefficients when the general absorption lemma gives them at essentially no cost.
If the final coefficient is at least 1/1000 without substantial additional effort,
derive the historical EndpointClaim as a corollary. Otherwise report the actual
proved coefficient and move on. Do not optimize a numerical constant separately.

**Currently proved endpoint coefficient: none.** The machine-readable
[coefficient status](endpoint-coefficient-status.json) leaves both the working
choice and proved coefficient unset until the error estimates justify a choice. A final acceptance must record the explicit
witness, theorem name, source revision and exact-type/axiom evidence together.

## Exact internal parameters — no replacement definitions

All limits below are along natural X tending to infinity. Put

\[
Q=\log X,\quad L=\log\log X,\quad
 a=\frac{\log2}{1+\log2},\quad H=\lfloor Q^a\rfloor,
\]
\[
J=2\left\lceil H/100\right\rceil
 =2((H+99)\mathbin{\mathrm{div}}100),\quad
 y=X^{1/(4J)},\quad t=1/(1000L),\quad z=1-t.
\]

The internal choice t=1/(1000L) is retained because it already has useful proved
logarithm bounds. That internal tuning number does **not** force the output
coefficient c to equal 1/1000. Changing it is unnecessary for this first milestone.

These are the existing `endpointExponent`, `windowLength`, `truncationOrder`,
`primeCutoff`, and `momentT`. The new files do not redeclare them. Small X is not
silently excluded from total definitions: positivity claims have explicit finite
hypotheses or are eventual statements. The ceiling identity and the strict rounding
bound include H=0 and exact multiples of 100.

## Accepted parameter interfaces (v40)

| Module (under `research/Erdos647Research/Endpoint/`) | Main targets |
|---|---|
| `Statement.lean` | Fixed-positive-coefficient goal; coefficient monotonicity; eventual formulation; exact correspondence with the legacy 1/1000 statement. |
| `WindowParameters.lean` | 0<a<1; a/log 2=1-a; H tends to infinity; H/Q^a tends to 1; log H-aL tends to 0; log H/L tends to a. |
| `TruncationParameters.lean` | Exact ceiling correspondence; even J; H/50 <= J < H/50+2; eventual positivity; J/H and J/Q^a tend to 1/50. |
| `CutoffParameters.lean` | Exact log y; log y/Q^(1-a) tends to 25/2; y tends to infinity; log log y-(1-a)L tends to log(25/2); H<y eventually; t tends to zero and eventually lies in (0,1/2]; all finite-moment parameter hypotheses. |
| `PrimeMassParameters.lean` | Applies the existing project Mertens interface with those proved cutoff hypotheses; produces the exact prime-mass expansion below. |

For the exact `primeMass`, write lambda=primeMass H y. The accepted asymptotic theorem is

\[
\boxed{\frac\lambda H-
 \left((1-a)L-\log\log H+\log(25/2)\right)\longrightarrow0.}
\]

Its declaration is
`Erdos647Sieve.Endpoint.endpoint_primeMass_expansion_tendsto_zero`.
There is no free cutoff function, growth hypothesis, assumed prime-distribution
estimate, or numerical approximation in its statement.

The source uses the exact identity `log y=Q/(4J)`, not a limit theorem for a fixed
exponent applied incorrectly to a variable exponent. Relative limits are converted
to logarithmic differences to retain log(25/2); replacing them by a generic O(1)
error would be insufficient for the next constant-gap theorem.

Every one of the 43 branch theorem declarations (42 from v38 plus the shared v39
power/log adapter) has a checked-in type example and a successful transitive
axiom report in the v40 run. Expanded definition checks also pin the coefficient quantifier
order, exponent and scale. Separate gates are `endpoint_statement`, `endpoint_window_parameters`,
`endpoint_truncation_parameters`, `endpoint_cutoff_parameters`, and
`endpoint_prime_mass_parameters`. The statement and first three parameter modules use only Mathlib and project
parameter lemmas. Only the last imports the project-level selected-prime interface;
none directly imports upstream PNT+.

## What comes after this accepted checkpoint

The next proof combines the displayed prime-mass expansion with the accepted
`correctedBudget_upper_eventually`. Both expressions contain -log log H, and
`a/log 2=1-a` cancels the leading L term. The intended surviving gap is

\[
\log(25/2)+\frac1{\log2}-2>\frac32.
\]

The strict numerical inequality is already accepted. Its application to the
actual signed budget is **not yet proved**. The next quantitative target is a
fixed positive gap. The already-established constant margin can support

\[
\lambda-B_H\ge\tfrac32 H\quad\text{eventually}.
\]

The value 3/2 is a sufficient available margin, not an optimization target;
a smaller comfortable fixed delta > 0 is acceptable if it simplifies the assembly.

Further obligations remain B_H <= HL, lambda <= HL, the amplified principal
and factorial-tail estimates, the arithmetic-error comparison, and absorption of
all terms into `endpointRHSWith c` for an explicit fixed c>0. Negative B_H
retains its existing separate
candidate-count case. No `endpoint : EndpointClaim` or `Endpoint/Main.lean` is
introduced by this overlay.

The eventual overall target is `EndpointBound c` for an explicit positive
coefficient, followed by the existential consequence `PositiveEndpointClaim`.
The preserved legacy `EndpointClaim` is optional, not a blocker.

This is a sparsity conclusion, not a proof that no candidate above 24 exists.
No explicit numerical onset is asserted by these eventual parameter limits.

## Engineering boundary

The v41 update is documentation/evidence only. All statements below describe the
already-accepted v40 source and checking configuration.

The root finite package remains untouched. One new experimental Lake library is
registered in the existing research package. The default full runner now selects
19 gates: the existing 14 plus the four parameter gates and the statement gate.
Selective checking and Lake's ordinary
incremental invalidation remain unchanged. The same source/type/axiom, module-owner,
admission and warning checks apply. No allowed axiom, warning suppression, setup
policy, dependency pin, cache path, Git ignore rule, or CI workflow is changed.

Results use the unique `erdos647_repo_v40_results_` prefix. The prior fixes PR is
still bounded by its v36 accepted source snapshot; its description is not edited
by this new mathematical work. No remote branch, PR, or publication is created by
this source overlay.

## Reused library interfaces

The following were inspected at the actual locked Mathlib commit
`905b95818eb32af7874a58b427f50c1711a5e96c`, not at a newer default branch:

- `Analysis/SpecificLimits/Basic.lean`: `tendsto_nat_floor_atTop`,
  `tendsto_nat_floor_div_atTop`, and `Filter.Tendsto.num`.
- `Analysis/SpecialFunctions/Pow/Real.lean`: `Real.rpow_eq_pow`, the existing
  normalization identity used in the v39 repair.
- `Algebra/Order/Floor/Semiring.lean`: `Nat.le_ceil` and `Nat.ceil_le`.
- `Analysis/SpecialFunctions/Pow/Asymptotics.lean`: `tendsto_rpow_atTop` and
  `isLittleO_log_rpow_atTop`.

The integer ceiling bridge and the parameter specialization are project adapters.
The handoff's older compiler recommendation is not used: the working Lean/Mathlib
4.32.2 pins remain unchanged.
