## Summary

Stabilize the independently usable finite-sieve library and its separate research
package without changing the mathematical statements or pinned toolchain.

- Keep the public finite core Mathlib-only and preserve the existing facade imports
  and `finiteMoment`, `budgetDebit`, and `finiteCounting` declarations.
- Give research modules the separate `Erdos647Research` import root and consolidate
  upstream adaptation in `Erdos647Research.Compat.PNTPlus`.
- Replace the broad Rosser–Schoenfeld catalogue import with the required
  `MediumPNT` subtree plus seven attributed PNT/integrability adapters. Retain both
  recursive admission screening and exact-type/transitive-axiom audits.
- Resolve reported project lint warnings and the natural-index quotient adapter;
  keep warnings fatal, including cached/replayed warnings.

The final v36 change replaces one unnecessary all-goals tactic combinator in
`CorrectedBudgetEstimate.lean` with ordinary sequencing. The runner's checking
behavior is unchanged; the new diagnostic prefix distinguishes the resulting run.
Its archive-name regression now checks the versioned format and the actual run ID.

## Evidence available at PR preparation

Run: `erdos647_repo_v35_results_20260908T071828Z_a8ef3d01`.

| Area | Recorded result |
|---|---|
| Independent core and public examples | Passed |
| Restricted PNT+ boundary and Mertens/selected-prime chain | Passed |
| Factorial, logarithm, reciprocal-prime, and small-prime debit estimates | Passed |
| Corrected-budget estimate | Build rejected one `unnecessarySeqFocus` lint; final audit not reached |

Overall: **13/14 gates passed**. All **139 distinct audited declarations** use
only `propext`, `Classical.choice`, and `Quot.sound`. The retained PNT+ source
subtree contains **14 modules**, with no admission or forbidden shortcut detected.
Selected raw evidence and its integrity review are under `provenance/accepted/v35`.

The v36 lint correction is present in this changeset. The attached v35 result is
not represented as a successful run of that new revision.

## Merge criterion

- [x] Standalone core build, public examples, exact statement checks, and permitted axioms.
- [x] Restricted PNT+ source subtree and consumed theorem interfaces accepted.
- [x] Fixed-constant debit estimate accepted without changing natural division.
- [x] Final reported lint site repaired without disabling any linter.
- [ ] A current repository-wide **14/14** build/type/axiom result for the PR revision,
  including `corrected_budget_estimate`, with zero project warnings.

The project keeps its existing manual CI settings; this changeset does not enable
automatic workflows or authorize paid execution.

## Scope and trust boundary

The pin remains Lean/Mathlib **4.32.2** and the original PNT+ lockfile. Upstream
sources and dependency revisions are unchanged. Unused catalogue assertions such
as `ZetaSummary` are excluded, not proved, and no claim is made that the entire
upstream repository is admission-free.

This PR does not resolve Erdős #647 or supply the final asymptotic endpoint.
Parameter limits, the eventual prime-mass/budget gap, and amplified-error
absorption remain separate mathematical work. No endpoint completion is required
for merging this repair PR.

This description covers the accumulated prepared fixes; its scope should be
compared with the actual chosen Git base during PR review. No remote comparison,
branch push, or PR creation is represented as already performed.
