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

There is no copied finite source tree inside `research/`. Module roots are disjoint:

| Owner | Import root | Theorem namespace |
|---|---|---|
| Mathlib-only core | `Erdos647Sieve.*` | `Erdos647Sieve.*` |
| Project research | `Erdos647Research.*` | Existing `Erdos647Sieve.Analytic.*` and `Erdos647Sieve.Elementary.*` |
| Upstream PNT+ | `PrimeNumberTheoremAnd.*` | Upstream names, used only by the compatibility boundary |

Lean 4.32.2 selects the first search-path entry containing the top-level module
root, *then* constructs the full object path. It does not keep searching if the
leaf module is absent. Thus, putting some `Erdos647Sieve.*` modules in each package
is unsafe even when the full module names differ. v33 reproduced precisely this
failure: research builds succeeded, but audits sought their objects in the core.

The compatibility boundary is
`research/Erdos647Research/Compat/PNTPlus.lean`. It imports only
`PrimeNumberTheoremAnd.MediumPNT` from PNT+ and supplies seven attributed
PNT/integrability adapters. `AnalyticInputs.lean` consumes that interface; the
PNT-specific definitions and adaptation stay in this analytic boundary. There
is no project-owned module under the upstream `PrimeNumberTheoremAnd` root.
The former broad catalogue import is not part of the active proof dependency.

In v34, only research module paths and import lines changed. The stable public
imports, declaration names, and theorem statements remain unchanged. Later
v35/v36 changes added the restricted PNT interface and focused lint/adapter
repairs; their accepted combined result is recorded in v36.
The relocation manifest and diff preserve the correspondence with historical
source records. Old source copies from overlay installations are retained outside
the active build graph, not linked back into it.

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

After each module build, the runner checks which `.olean` each project import will
resolve to using Lean 4.32.2's first-root rule. The owner must be the expected
package, and the object must exist. Results are written under `module_resolution/`
in the diagnostic ZIP. Reordering `LEAN_PATH` or combining build directories is
not used as a workaround. The actual Lean exact-type and axiom audits still run
separately and determine theorem acceptance.


### Completed PNT interface (v35)

The only direct PNT+ import is now `PrimeNumberTheoremAnd.MediumPNT` inside
`Erdos647Research.Compat.PNTPlus`. The required theta estimate and error-integral
lemmas are an attributed extraction, not an import of the broad IEANTN catalogue.
The source-closure and theorem-audit scopes are documented in
`docs/pntplus-trust-boundary.md`. The original upstream repository remains pinned
and unchanged; no new compiler migration or forked dependency lock is introduced.

## Accepted combined boundary

The v36 run passed the core plus all 13 research gates, including the retained
14-module PNT+ source-closure check and its separate theorem/axiom audit.
All recorded compiled-module ownership checks passed. The complete upstream
PNT+ repository is not asserted to be admission-free. See the
[accepted record](../provenance/accepted/v36/README.md).
