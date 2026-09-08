# Analytic bridge and endpoint research

This is a separate Lake package, not a dependency of the public root library.
It uses the parent core by a local path dependency and PNT+ at its native locked
Lean/Mathlib 4.32.2 environment. The existing theorem/module names are preserved;
there are no duplicate finite-source copies or upstream proof patches.

## Inventory

The five analytic modules are `ReciprocalKernel`, `PrimeReciprocalSummation`,
`AnalyticInputs`, `CleanMertens`, and `SelectedPrimeReciprocals`. The PNT+ boundary
is the `AnalyticInputs` adapter plus one import-only compatibility shim.

The seven elementary modules are `EndpointLogBounds`, `FactorialBounds`,
`FactorialEstimate`, `LogBudgetFactorial`, `PrimeReciprocalLower`,
`SmallPrimeDebitEstimate`, and `CorrectedBudgetEstimate`.

The prime-reciprocal/debit chain is pending. The factorial and logarithm components
have earlier acceptance evidence. The final parameter asymptotics, mass-versus-budget
gap, and amplified-error absorption are still missing. No endpoint `Main` proof
has been added merely to make the module tree appear complete.

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
