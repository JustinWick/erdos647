# Erdős #647: finite sieve and asymptotic sparsity

This repository formalizes counting inequalities for the actual candidate set

$$24<n,\qquad \tau(n-k)\le k+2\quad(1\le k<n).$$

Let C(X) count such natural numbers up to X and let
$a=\log2/(1+\log2)$. The accepted v47 endpoint proves, for every fixed
**0 < c < 1499/10^6**,

$$C(X)\le X\exp\!\left(-c\,\frac{(\log X)^a}{\log\log X}\right)$$

for all sufficiently large natural X. **c=1/1000** is an explicit corollary.
The onset may depend on c and is not computed. The upper coefficient boundary
is strict; no optimality is claimed. **This does not resolve Erdős #647 or
prove finiteness of its candidate set.**

[Accepted v47 evidence](provenance/accepted/v47/README.md) records **29/29 passing
gates**, 235 audited declarations, 194 exact-type/definition examples, and zero
build/audit warnings. The v48 package cleanup is a separate **30-gate** checkpoint
awaiting its own run; mathematical acceptance is not inferred from relocation.

## Public imports and package boundaries

| Import | Package / dependencies | Purpose |
|---|---|---|
| `Erdos647Sieve` or `Erdos647Sieve.Finite` | Root; Mathlib only | Finite-moment and finite-counting theorems |
| `Erdos647Sieve.Elementary` | Root; Mathlib only | Factorial, logarithm, prime-reciprocal and debit/budget estimates |
| `Erdos647Research.Analytic` | `research/`; core and restricted PNT+ | Mertens and selected-prime interfaces |
| `Erdos647Research.Endpoint` | `research/`; core and restricted PNT+ | Proved fixed-coefficient sparsity endpoint |

```lean
import Erdos647Sieve.Finite
#check Erdos647Sieve.finiteCounting
```

Within the separate analytic package:

```lean
import Erdos647Research.Endpoint
#check Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate
#check Erdos647Sieve.Endpoint.endpointBound_one_div_thousand
```

The module root `Erdos647Research` is retained for compatibility; it no longer
means the endpoint is unproved. The PNT+ dependency is the reason this package
stays separate. Old research imports for the seven promoted elementary modules
remain import-only forwarders. Every mathematical declaration has one implementation.

## Build and test

Lean **4.32.2**, Mathlib **905b95818eb32af7874a58b427f50c1711a5e96c**,
and PNT+ **a5154676af9aa3095150ee410cdda80555aa0642** are pinned. Both lockfiles
are checked in. No toolchain change accompanies this cleanup.

```bash
bash RUN.sh --setup     # first-time pinned setup; --upgrade is the same pinned action
bash RUN.sh             # all 30 checks, incremental builds
bash RUN.sh core        # finite + elementary core, without PNT+
bash RUN.sh research    # separate analytic/endpoint package and compatibility imports
bash RUN.sh --gate endpoint_public_results
bash RUN.sh tooling     # Python engineering tests, not mathematical verification
```

`TEST_ALL.sh` is the all-checks entry point. With the pinned tools on PATH, each
package also supports `lake build` and `lake test`. Root `lake test` covers the
finite and promoted elementary APIs; research's `lake test` covers its registered
gates. Internet access is needed for initial dependency/toolchain/cache setup.
No Python packages beyond the standard library are required (Python 3.10+).

Lake owns incremental invalidation. Selected exact-type/axiom audits rerun; no
previous verdict substitutes for the current audit. Project warnings are fatal.
Only `propext`, `Classical.choice`, and `Quot.sound` are permitted. Restricted
PNT+ source scanning rejects admissions even in unused declarations of the retained
14-module closure; it does not certify the whole upstream catalogue.

Unique diagnostic ZIPs use `erdos647_repo_v48_results_...`; previous results and
cache directories are retained. No GitHub operation or CI trigger is changed.
Any failed or blocked selected gate makes the run fail. A core-only pass cannot
claim endpoint acceptance. Exact statuses appear in the run's summary, not in
static documentation.

## Layout

```text
Erdos647Sieve/                  Mathlib-only finite library
  Elementary/                  Seven promoted, previously accepted proof modules
Audit/                         Core exact-type and transitive-axiom checks
Examples/                      Public finite and elementary examples
research/Erdos647Research/      Separate analytic and endpoint library
  Compat/PNTPlus.lean           Restricted upstream adapter boundary
  Endpoint.lean                Public endpoint facade
  Endpoint/Main.lean           Existing final proof assembly, unchanged
research/Audit/                 All existing checks plus public-facade audit
scripts/                       One incremental runner and gate registry
tests/                         Engineering/source-preservation regression checks
provenance/                    Accepted evidence and historical material
```

[Theorems](docs/theorems.md) · [Proof status](docs/proof-status.md) ·
[Dependency boundaries](docs/dependency-boundaries.md) ·
[Cleanup scope](docs/library-promotion-v48.md) ·
[PNT+ trust boundary](docs/pntplus-trust-boundary.md).

External mathematical/novelty review and independent kernel replay remain separate
from the recorded build, statement and transitive-axiom checks.
