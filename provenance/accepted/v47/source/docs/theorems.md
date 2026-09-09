# Statement guide

All names below are in `Erdos647Sieve`. These are the preserved theorem types,
not strengthened versions or new assumptions.

## `Candidate`

`Candidate n` means `24 < n` and for every natural `k`, `1 <= k < n` implies
`(n-k).divisors.card <= k+2`. `Prefix H n` includes `H < n` and only the first
`H` shift inequalities.

## `finiteMoment : FiniteMomentClaim`

For every integer `A`, natural `X H`, real `y z`, and natural `J`:
`1 <= X`, `1 <= H`, `H < y`, `0 < z`, `z < 1`, and `Even J` imply

```text
sum_{n in Icc(A+1,A+X)} z^(hitCount H y n) <= momentBound X H y z J.
```

The interval and polynomial use integers throughout. Empty prime sets, zero
polynomial values, `J=0`, and negative translations are included.

## `budgetDebit : BudgetDebitClaim`

For natural `n H` and real `y`, `1 <= H`, `H < y`, and `Prefix H n` imply
`(hitCount H y (n:Int):Int) <= correctedBudget H`.
The right side is the signed difference of the exact logarithmic-floor budget
and the exact natural-quotient small-prime debit.

## `finiteCounting : FiniteCountingClaim`

For natural `X H`, real `y z`, and natural `J`, the moment parameter hypotheses
and `0 <= correctedBudget H` imply

```text
(candidateCount X : Real) <= H +
  exp((-log z) * (correctedBudget H : Real)) * momentBound X H y z J.
```

The multiplier covers the ENTIRE bound. The negative-budget branch is a separate
proved consequence; it is not silently omitted or converted to natural subtraction.

## What is not here

No proof of `EndpointClaim`, no proof of finiteness, no exclusion of every candidate
above 24, and no novelty claim. The public extraction changes packaging, not the
mathematical strength of the accepted finite theorem.
