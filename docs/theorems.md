# Theorem guide

## Finite sieve — root package, Mathlib only

```lean
import Erdos647Sieve.Finite
```

`Erdos647Sieve.finiteMoment` gives the translated finite moment bound.
`Erdos647Sieve.budgetDebit` proves the signed corrected budget.
`Erdos647Sieve.finiteCounting` assembles them for the actual candidate predicate.

## Elementary estimates — root package, Mathlib only

```lean
import Erdos647Sieve.Elementary
```

The facade exposes all seven accepted elementary modules. Useful declarations:

- `Erdos647Sieve.Elementary.log_factorial_residual_tendsto_zero` and
  `shiftedFactorialLog_residual_tendsto_zero` retain the factorial's linear term.
- `Erdos647Sieve.Elementary.smallPrimeDebit_lower` proves
  $H(\log\log H-2)\le D_H$ for $H\ge2$.
- `Erdos647Sieve.Elementary.correctedBudget_upper_eventually` gives the
  constant-sensitive one-sided asymptotic upper bound for the signed budget.

All 20 elementary audit targets and their original expanded statements are
checked independently by the root's `Audit/Elementary.lean`. Old research
imports remain supported by import-only forwarders.

## Final endpoint — separate analytic package

```lean
import Erdos647Research.Endpoint
```

The declarations keep their established theorem namespace:

```lean
Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate
Erdos647Sieve.Endpoint.endpointBound_one_div_thousand
Erdos647Sieve.Endpoint.positiveEndpoint
Erdos647Sieve.endpoint
```

The main saving range is **0 < c < 1499/10^6**, with fixed c and a c-dependent
eventual onset. The proof also handles nonpositive c, but these are not
positive-saving results. c=1/1000 is the simple explicit corollary.
The upper boundary is not included, and no optimality is asserted.

`import Erdos647Research.Analytic` exposes the Mertens/selected-prime bridge
without relying on endpoint implementation filenames. The restricted PNT+
compatibility layer remains the only upstream interface.

The detailed hypotheses and quantifiers are recorded in the checked-in audit
files. The asymptotic result is not a finiteness proof or a resolution of #647.
