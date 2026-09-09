# v48 — library promotion and public results

This is a separate changeset after the accepted v47 endpoint. It changes package
placement and public imports, not theorem strength, proof bodies, parameters or
coefficient quantifiers. The current-layout checks remain pending.

## Bounded cleanup

Seven Mathlib-only modules move into `Erdos647Sieve/Elementary/`: FactorialBounds,
FactorialEstimate, LogBudgetFactorial, PrimeReciprocalLower,
SmallPrimeDebitEstimate, EndpointLogBounds and CorrectedBudgetEstimate. Only
imports are redirected; three obsolete pending-status comment lines are removed.
An explicit source map records old/new hashes and every textual substitution.
The existing research paths become one-import compatibility modules. Their old
audits stay unchanged and continue to check the compatibility paths.

`Erdos647Sieve.Elementary` is the opt-in public facade. The existing finite facade
stays byte-for-byte unchanged; using it does not import the new elementary layer.
A new core audit copies all 20 previously audited elementary targets and exact
statements into the PNT+-free package. No type or axiom check is removed.

`Erdos647Research.Endpoint` and `Erdos647Research.Analytic` are public facades in
the separate analytic package. Its example and exact public-endpoint audit use
only these public imports. Its historical name is deliberately not changed.
The endpoint stays out of the Mathlib-only core because its proof uses PNT+.

## Acceptance

The original 29 gates remain; the core gate gains the independent elementary
audit. One new `endpoint_public_results` gate builds both research facades and
the public example and repeats the final exact statement and axiom checks.
The full suite is 30 gates. Core-only testing includes the elementary layer and
requires no PNT+ checkout. The seven research elementary gates intentionally
remain inexpensive backwards-compatibility regression checks.

The runner now accounts for every explicitly requested module build target in
its ownership/registry validation, not just the first target. No dependency,
cache invalidation policy, linter, axiom allowlist, or endpoint acceptance logic
is changed. No source migration runs at startup for this promotion: extracting
the overlay replaces the seven old files with their compatibility imports.

The v47 mathematical checkpoint is retained separately under
`provenance/accepted/v47/`. It does not pre-approve the v48 package relocation.
Historical fixture tests check the actual moved proof against a deterministic
import/comment transformation of that accepted source; hashes are not silently
reset to accept arbitrary replacement proofs.

## Stop here

No wholesale renaming, new package, toolchain upgrade, generic sieve framework,
or proof-style refactoring is included. Once the new package-boundary tests
pass, this cleanup is complete. Independent review and mathematical follow-up
are separate work, not prerequisites for releasing the accepted result.
