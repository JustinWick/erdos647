# PNT+ trust boundary

## What we use

The only upstream entry point is `PrimeNumberTheoremAnd.MediumPNT`, from the exact
commit fixed in both the research lockfile and `scripts/pins.json`.
`Erdos647Research.Compat.PNTPlus` supplies a small extraction of the already-proved
Rosser–Schoenfeld adapters:

- the theta error estimate `RS_prime.pnt`;
- the improper integrability estimate `RS_prime.integrableOn_deriv_inv_div_log`;
- their five supporting declarations.

The extracted code is attributed to the PNT+ contributors and stays in the
research compatibility layer. No PNT theorem is assumed as an axiom. No broad
upstream Mertens or zeta-summary theorem is a proof input.

## Two checks, with different scopes

`pntplus_inputs` checks the **entire retained PNT+ source import subtree** for
explicit admissions or proof shortcuts, not just selected theorem bodies. The
report lists every inspected source, its imports and hash. Missing source is an
error. This detects unused placeholder declarations that a final-theorem axiom
audit legitimately would not report.

The same gate separately checks the **transitive axioms of the theorem proofs**,
including `MediumPNT`. This catches an assumption reached indirectly through a
proof dependency. Both consumed interfaces have exact expanded type checks.

Mathlib and compiler/tactic implementation source are not subjected to the PNT+
lexical source rule; their mathematical contributions are covered by the theorem
axiom checks. This is not an independent kernel implementation or a claim to
validate arbitrary untrusted Lean metaprograms.

## What we do not claim

The upstream PNT+ repository is a research collection, not a uniformly completed
library. Its unimported `IEANTN/ZetaSummary` still contains nine admitted assertions.
This change does not prove those assertions, replace them with weaker claims, or
reinterpret successful compilation as their proof. It excludes the incomplete
catalogue from the dependency used by this project.

The original pinned checkout is left untouched. The public finite library remains
Mathlib-only. It can build and audit without installing PNT+ at all.
