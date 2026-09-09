# Analytic bridge and proved endpoint

This separate Lake package supplies the PNT+/Mertens bridge and the accepted
fixed-coefficient endpoint. The historical directory and module names are retained
for compatibility, not to mark the completed theorem as experimental.

```lean
import Erdos647Research.Endpoint
#check Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate
```

For every fixed $0<c<1499/10^6$ there is an onset (depending on c) after which
$C(X)\le X\exp(-c(\log X)^a/\log\log X)$, with
$a=\log2/(1+\log2)$. The explicit specialization is c=1/1000.
The upper threshold is not included. This is not a resolution of #647.

`Erdos647Research.Analytic` exposes the analytic bridge.
`Erdos647Research.Examples.EndpointUsage` demonstrates public-only imports.
The seven elementary modules now forward to `Erdos647Sieve.Elementary.*` in
the Mathlib-only root package. The accepted analytic/endpoint proof bodies are
unchanged; the v48 import-boundary checks are separate from historical acceptance.

Lean/Mathlib remains 4.32.2 with the native pinned PNT+ lockfile. The only direct
PNT+ import is in `Compat/PNTPlus.lean`; the retained source closure and theorem
axioms are checked separately. No broader claim of completeness for upstream is made.

Normal entry points are this package's `lake build` / `lake test`, or the root
`RUN.sh` for combined incremental checking and diagnostics. There is no duplicated
finite implementation and no research dependency in the root package.

See [proof status](../docs/proof-status.md), [accepted endpoint evidence](../provenance/accepted/v47/README.md),
and [cleanup scope](../docs/library-promotion-v48.md).
