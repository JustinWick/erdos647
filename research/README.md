# Analytic bridge and endpoint research

This is a separate Lake package, not a dependency of the public root library.
It uses the parent core by a local path dependency and PNT+ at its native locked
Lean/Mathlib 4.32.2 environment. The existing theorem names and proof bodies are preserved;
there are no duplicate finite-source copies or upstream proof patches.

## Inventory

Research import paths begin with `Erdos647Research`, while theorem names remain
in their existing `Erdos647Sieve` namespaces. The core and upstream PNT+ keep their
own module roots.

The five analytic modules are `ReciprocalKernel`, `PrimeReciprocalSummation`,
`AnalyticInputs`, `CleanMertens`, and `SelectedPrimeReciprocals`. The PNT+ boundary
is the `AnalyticInputs` adapter plus `Erdos647Research.Compat.PNTPlus`. The
compatibility module imports `PrimeNumberTheoremAnd.MediumPNT` and supplies
seven attributed PNT/integrability routines extracted from the pinned source.
It does not import the unfinished zeta or Rosser–Schoenfeld catalogues. No
project module occupies an upstream-owned import root.

The seven elementary modules are `EndpointLogBounds`, `FactorialBounds`,
`FactorialEstimate`, `LogBudgetFactorial`, `PrimeReciprocalLower`,
`SmallPrimeDebitEstimate`, and `CorrectedBudgetEstimate`.

All **13 research gates registered at the v36 snapshot** passed alongside the core in the v36
repository-wide run. This includes the prime-reciprocal lower bound, the exact
small-prime debit estimate, and `correctedBudget_upper_eventually`. The
[accepted record](../provenance/accepted/v36/README.md) includes the raw audits.

The `Endpoint/` directory contains `Statement`, `WindowParameters`,
`TruncationParameters`, `CutoffParameters`, and `PrimeMassParameters`. All five
parameter-branch gates and their **43 declarations** passed in the v40 run,
alongside all established gates: **19/19 total**. The exact constant-sensitive
prime-mass expansion completes the first parameter changeset. See the
[accepted v40 record](../provenance/accepted/v40/README.md).

The mass-versus-budget gap and amplified-error absorption remain subsequent
targets. No endpoint `Main` proof has been added merely to make the module tree
appear complete. The next changeset is specified in
[the positive-gap assignment](../docs/next-prime-mass-gap.md), separate from both
the completed build/dependency fixes and the accepted parameter layer.

## Endpoint coefficient

The branch seeks `EndpointBound c` for an explicit fixed c>0, preserving the critical
exponent and (log X)^a/log(log X) scale. The arbitrary historical 1/1000 target is
not mandatory. The coefficient is outside both the onset and X quantifiers; it
cannot vary with X. No endpoint coefficient is yet accepted, and no replacement working
coefficient is fixed. See the branch charter and coefficient status record.

## Checking

From the repository root, `bash RUN.sh research --setup` prepares this pinned
workspace and checks all research gates. Later `bash RUN.sh research` reuses it.
`bash RUN.sh --gate corrected_budget_estimate` selects that target and its explicit
prerequisites. The root `TEST_ALL.sh` checks core and research together.

With the pinned toolchain on PATH, `lake build` and `lake test` also work from this
subdirectory. They use this package's own dependency resolution. A research failure
is not ignored; the core's independent build remains available at the repository root.

The manuscript under `docs/MANUSCRIPT.md` is preserved as a historical proposed
argument. Its original verification comments describe its creation time. Current
status is recorded centrally in [proof status](../docs/proof-status.md).

## Mathematical branch boundary

[The parameter branch charter](../docs/endpoint-parameter-branch.md) gives the exact
parameter formulas, new acceptance targets, reused library interfaces, and the
remaining route to the final endpoint. The stable finite facade does not import
any of the new experimental modules.
