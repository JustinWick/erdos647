# Dependency and public API boundaries

The root Lake package is Mathlib-only. Its finite source and public finite
facades are unchanged. Seven accepted elementary modules now live below
`Erdos647Sieve/Elementary/`; `import Erdos647Sieve.Elementary` is opt-in.
No core import refers to `Erdos647Research`, `PrimeNumberTheoremAnd`,
`RS_prime`, or the research workspace.

The separate `research/` package depends on the root package and the native
pinned PNT+ stack. Its public facades are `Erdos647Research.Analytic` and
`Erdos647Research.Endpoint`. The final endpoint is proved, but remains here
because of its analytic dependencies. A successful proof does not remove
those dependencies. Only `Compat/PNTPlus.lean` imports upstream PNT+ directly.

Import paths and theorem namespaces are different: theorem names such as
`Erdos647Sieve.Elementary.smallPrimeDebit_lower` stay unchanged when an
implementation moves. The seven historical research modules forward to the
core so earlier users do not need an import rewrite. There is one definition
of each theorem, not parallel copies.

The root owns `Erdos647Sieve.*`; the analytic package owns
`Erdos647Research.*`. Their compiled-module ownership is audited using the
actual search path. Every explicit module build target is now included in that
check, including public facades and examples. No dependency-owned module root
is duplicated in the research package.

Both packages retain Lean 4.32.2 and their exact existing lockfiles. No CI
workflow, version pin, tool directory, or cached build directory is altered
by the cleanup. Historical material remains outside active imports.
