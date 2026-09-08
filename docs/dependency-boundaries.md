# Dependency boundaries

The root package `erdos647-sieve` has one direct dependency, Mathlib. Its lockfile
contains Mathlib and eight transitive packages. It has no PNT+ dependency.

The nested package `research/` is a separate Lake workspace with its own manifest.
It depends on the local root package with `require «erdos647-sieve» from ".."`, and
on PNT+ at the same native 4.32.2 snapshot used by the accepted analytical route.
PNT+'s 13 dependency revisions are retained. No upstream source is patched.

The two packages presently use the same Lean and Mathlib pins. Their separation
allows a future **core-only** compatibility change rather than another wholesale
PNT+ port. Supporting different versions in one checkout would require separate
compatible core releases; do not independently change a compiler line and assume
binary or theorem-API compatibility.

## Source ownership

There is no copied finite source tree inside `research/`. Its narrow Lake-library
roots own only the five analytical and seven elementary modules. The root library
owns the finite modules. Shared `Erdos647Sieve.*` names preserve the existing public
and internal theorem names without a namespace rewrite.

The one old upstream import path is handled by
`research/PrimeNumberTheoremAnd/RosserSchoenfeldPrime.lean`, which contains only an
import of the pinned upstream module at its current path. `AnalyticInputs.lean`
is the single PNT+-aware project adapter. Endpoint work consumes its project-level
wrappers; the core cannot see these modules.

## Incremental build state

Each package keeps its own ignored `.lake/` state. Setup may link a research
Mathlib dependency directory to the core's **same verified revision** to reuse its
compiled libraries. These links are generated locally, are not distributed or
tracked, and never include PNT+ in the root manifest/search path.

Core compiled artifacts are naturally reused as a path dependency by research.
No source snapshots are synchronized into hidden workspaces: the visible source
is the source being built. The runner reconstructs each package's Lean search path
and rejects paths outside that package, its locked dependencies, its local core
(if research), and the selected toolchain.
