## Summary

Stabilize the independently usable Mathlib-only finite library and its separate
research package without changing theorem statements or the pinned Lean/Mathlib
4.32.2 environment.

- Preserve the public facade imports and the existing `finiteMoment`, `budgetDebit`,
  and `finiteCounting` declarations while keeping PNT+ out of the core dependency graph.
- Give research modules a disjoint `Erdos647Research` import root and verify compiled
  module ownership before theorem audits.
- Restrict PNT+ imports to `MediumPNT` and seven attributed PNT/integrability adapters;
  check both the retained source subtree and the consumed proof dependencies.
- Fix the reported project lint and natural-quotient adapter errors while keeping
  warnings fatal, including cached/replayed warnings.

The final proof-source repair in v36 replaces the unnecessary `<;>` sequence in
`CorrectedBudgetEstimate.lean` with ordinary tactic sequencing. v37 is documentation
and evidence only; it leaves that passing code and all checking behavior unchanged.

## Validation: complete local pass

Run: `erdos647_repo_v36_results_20260908T073909Z_c7bbf1b5`

| Check | Recorded result |
|---|---|
| Full implemented suite | **14/14 gates passed**, no failures or blocked gates |
| Public finite core and both examples | Passed |
| Restricted PNT+ inputs and Mertens/selected-prime chain | Passed |
| Factorial, logarithm, prime-reciprocal and debit estimates | Passed |
| Combined corrected-budget estimate | **Passed its build, expanded type check and axiom audit** |
| Audited declarations | **140 distinct declarations**, permitted axioms only |
| Build/audit warnings | **0** |
| Offline runner tests in the submitted run | **144 passed** |
| Checked sources changed during run | None |

Allowed transitive axioms remain `propext`, `Classical.choice`, and `Quot.sound`.
The retained PNT+ source-closure report covers 14 modules; it is not a blanket
assertion about the complete upstream repository.

The original result archive, human-readable logs and integrity review are in
[`provenance/accepted/v36`](../../provenance/accepted/v36/README.md).
Both packages reused their matching caches; no setup or compiler change was requested.

## Local readiness criteria

- [x] Independently usable core, public examples and exact statement/axiom checks pass.
- [x] Research compiled-module ownership and import boundaries pass.
- [x] Restricted PNT+ source subtree and required theorem interfaces pass.
- [x] Fixed-constant debit and combined eventual budget estimate pass.
- [x] The current complete 14-gate suite passes with no project warnings.
- [x] The final documentation/evidence overlay preserves all checked executable inputs.

**Ready for normal PR review, not just a draft.** The previous local validation
hold is cleared. Review of the actual branch diff and any required repository CI
remain the normal maintainer checks; they are not represented as completed by this
local result. Existing manual CI settings are unchanged.

## Mathematical scope

The newly accepted `correctedBudget_upper_eventually` states, for every `ε > 0`,
eventually over natural `H`:

```text
(correctedBudget H : Real) / H <=
  log H / log 2 - log (log H) + 2 - 1 / log 2 + ε.
```

This retains the signed budget, small-prime debit and linear factorial term.
No unproved asymptotic-budget or PNT premise is added to the project theorem.

This PR does **not** resolve Erdős #647, prove finiteness, finish `EndpointClaim`,
or complete the unused upstream `ZetaSummary` assertions. Parameter limits,
the eventual prime-mass/budget gap and amplified-error absorption belong to the
next mathematical PR. They are not prerequisites for this fixes PR.

The description covers the accumulated prepared fixes. The submitted local evidence
is tied to source hashes rather than a fetched GitHub head/base comparison. No
remote branch, pull request, review status or merge action is claimed here.
