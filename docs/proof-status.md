# Proof status

## Current accepted repository checkpoint: v36

The local run `erdos647_repo_v36_results_20260908T073909Z_c7bbf1b5`, completed on
September 8, 2026, passed **all 14 registered gates** under **Lean/Mathlib 4.32.2**.
All **37 recorded commands** exited successfully. The 29 build/audit logs contain
**zero warning or error diagnostics**; the tooling run passed **144 tests**.

The exact-type and transitive-axiom checks cover **140 distinct declarations**
(142 report occurrences where a declaration is audited in more than one gate).
Every reported axiom set is contained in:

```text
propext, Classical.choice, Quot.sound
```

[Accepted evidence](../provenance/accepted/v36/README.md) includes the original
results archive, raw logs, source hashes, and a read-only consistency review.
The report records no source changes during the run and cache reuse in both packages.

| Layer | Current recorded result |
|---|---|
| Mathlib-only finite core, public facades and both examples | Passed |
| Complete `finiteMoment`, `budgetDebit`, and `finiteCounting` | Passed |
| Reciprocal-log calculus and exact Abel-summation identity | Passed |
| Restricted PNT+ inputs and improper-integrability adapters | Passed |
| Replacement Mertens convergence and selected-prime cutoff cancellation | Passed |
| Factorial bounds, shifted residual limit, and exact `logBudget` connection | Passed |
| All three endpoint logarithm/constant inequalities | Passed |
| Prime-reciprocal lower bound and fixed-constant small-prime debit | Passed |
| `correctedBudget_upper_eventually` | **Newly passed in v36** |
| Exact growing-parameter limits and eventual prime-mass/budget gap | Not yet proved |
| Amplified-error absorption and final `EndpointClaim` | Not yet proved |

## The new mathematical milestone

For every real `ε > 0`, eventually over natural `H`, the accepted declaration
`Erdos647Sieve.Elementary.correctedBudget_upper_eventually` proves

\[
\frac{B_H}{H}\le
\frac{\log H}{\log2}-\log\log H+2-\frac1{\log2}+\varepsilon,
\qquad B_H=\operatorname{correctedBudget}(H).
\]

The budget is the exact signed integer budget, cast to the reals. There is no
assumed debit, factorial asymptotic, or budget estimate among this declaration's
premises. The explicit `ε > 0` and eventual quantifier remain part of its statement.

Its checked type and axioms are in the
[raw corrected-budget audit](../provenance/accepted/v36/logs/037_corrected_budget_estimate_audit_0.log).
It completes the elementary-budget estimate, not the final endpoint deduction.

## PNT+ scope

The retained PNT+ source import subtree rooted at `MediumPNT` contains **14
modules** in the recorded scan and has no detected admissions or forbidden
shortcuts. `MediumPNT` and all seven extracted adapters also passed their separate
axiom audits. Only the retained PNT+ subtree is covered by that lexical scan;
Mathlib and tactic/compiler implementation source are outside its scope.

This does not prove or import the unfinished upstream `ZetaSummary` catalogue.
The restricted compatibility layer leaves the upstream checkout untouched. See
[PNT+ trust boundary](pntplus-trust-boundary.md).

## PR boundary

**The accumulated core/research fixes are ready for a normal reviewable PR.**
The previously outstanding local acceptance criterion—14/14 with no warnings and
acceptable exact-type/axiom reports—is satisfied. Parameter asymptotics and the
endpoint are separate future mathematical work; they should not keep this fixes
PR open or expand its scope.

v37 updates documentation and preserves the v36 evidence. It changes **no Lean
source, audit source, runner, test, Lake configuration, lockfile, toolchain or CI
workflow**. The checking implementation and generated-results version label stay
at v36 deliberately, so the passing code is not churned just for a documentation
version number. Future runner invocations continue to produce unique result names.

The submitted archive identifies a source snapshot, not a remotely inspected PR
head/base pair. This readiness judgment is based on that snapshot; it is not a
claim that GitHub CI or maintainer review has already passed. Existing manual CI
settings are preserved.

## Historical record

Prior source and audit records remain under `provenance/accepted/`,
`provenance/pending/`, and `provenance/rejected/`. Earlier failures and rejected
experiments are not deleted or retroactively marked successful. The previous
version of this status page is preserved as
[the pre-v37 status record](../provenance/packaging/v37/prior-docs/docs/proof-status.md).
The original source map documents origin; it is not a requirement that future
maintained proofs remain byte-identical forever.

## Acceptance standard and limits

A proof gate builds its relevant modules, checks the checked-in type examples,
and reads fresh `#print axioms` output. Missing output, duplicate reports within
an audit, extra axioms, warnings, failed commands and blocked prerequisites cannot
produce an accepted gate. The core audits include the named claim types, expanded
statements and the candidate predicate; signed subtraction and unrestricted integer
interval translation remain protected.

Compilation/type/axiom acceptance and the source/log consistency review do not
establish mathematical novelty, independent-kernel replay, an explicit asymptotic
onset, or a solution to Erdős #647. The final endpoint theorem remains absent.
