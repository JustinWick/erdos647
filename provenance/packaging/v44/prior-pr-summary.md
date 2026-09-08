# PR title

Prove the prime-mass/budget gap and supporting size bounds

## Summary

Connect the accepted endpoint parameter asymptotics and corrected-budget estimate
to a fixed positive gap for the actual sieve parameters. Add two research modules
and their exact-type/transitive-axiom audits, without reopening the accepted
finite, PNT, Mertens, factorial, debit, or parameter proofs.

The public Mathlib-only finite API and pinned Lean/Mathlib 4.32.2 environment are
unchanged. This is the gap-and-size PR, separate from the subsequent amplified-error
implementation.

## Mathematical results

For the actual protected choices

$$
H=\operatorname{windowLength}(X),\quad
y=\operatorname{primeCutoff}(X),\quad
\lambda=\operatorname{primeMass}(H,y),\quad
B_H=\operatorname{correctedBudget}(H),\quad
L=\log\log X,\quad a=\frac{\log 2}{1+\log 2},
$$

prove

$$
\boxed{\lambda-B_H\ge\frac32H\quad\text{eventually}}
$$

and

$$
\frac{\lambda}{HL}\longrightarrow1-a,
\qquad
0\le\lambda\le HL,\qquad B_H\le HL\quad\text{eventually}.
$$

The general gap theorem supplies every fixed margin

$$
\delta<\log(25/2)+\frac1{\log2}-2.
$$

The margin is fixed before X; the onset may depend on the chosen margin.
The fixed 3/2 specialization has no assumed distribution estimate, cutoff-growth
hypothesis, or unproved gap premise. The corrected budget remains a signed
integer and is not assumed eventually nonnegative.

The budget estimate is one-sided: this PR does **not** assert that
$(\lambda-B_H)/H$ converges to the displayed constant.

## Main declarations

- `Erdos647Sieve.Endpoint.eventually_primeMass_gap_of_lt`
- `Erdos647Sieve.Endpoint.eventually_primeMass_sub_correctedBudget_ge`
- `Erdos647Sieve.Endpoint.endpoint_primeMass_div_window_logLog_tendsto`
- `Erdos647Sieve.Endpoint.eventually_endpoint_mass_budget_bounds`

The two modules add 12 theorem targets and 13 expanded type/definition checks.

## Validation

The latest confirmation is
`erdos647_repo_v43_results_20260908T120436Z_93d219fb`:

- **21/21 gates passed**, with no failed or blocked checks.
- **195 distinct declarations** passed transitive-axiom audits, using only
  `propext`, `Classical.choice`, and `Quot.sound`.
- **140 expanded type/definition checks** across 22 audit files.
- **Zero build/audit warnings or errors**; all **51 recorded commands** succeeded.
- **203 runner tests passed**. Checked inputs were stable and both package caches
  were reused.

The 47 mathematical modules and 22 audit files match the previously accepted v42
checkpoint. The v43 confirmation also resolves the diagnostic filename mismatch;
it does not introduce additional mathematical results.

The v43 results archive SHA-256 is:

```text
7217d520262b6b3bac52ac8379bd639c33bf7f9f1523b786f9d6b702d9c4bc22
```

The local evidence supports a normal PR on this tested source snapshot. Review of
the actual GitHub diff and required CI remain separate from the supplied logs.

## Scope and next changeset

This PR does not prove the final asymptotic endpoint, record a positive endpoint
coefficient, prove finiteness, or resolve Erdős #647. The 3/2 gap margin is **not**
the final saving coefficient c.

The subsequent v44 overlay starts the amplified-error branch: principal term,
growing factorial tail, complete amplified arithmetic remainder, and exceptional
window. Its new proof code and pending audit targets are not part of this PR's
accepted 21/21 evidence. Final assembly will retain the critical exponent and
scale and use a comfortable explicit fixed c>0, without treating 1/1000 as sacred.
