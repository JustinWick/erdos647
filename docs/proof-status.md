# Proof status

## Current accepted repository checkpoint: v40

The user-returned run `erdos647_repo_v40_results_20260908T091111Z_0850cec9`,
completed on September 8, 2026, passed **all 19 registered gates** on the pinned
**Lean/Mathlib 4.32.2** environment. There were no failed or blocked gates.

All **47 recorded commands** exited successfully. The 39 build/audit logs contain
no warning or error diagnostics. The tooling run passed **178 tests**, and the
source hashes did not change during the run. Both packages reused their caches.

The checked-in audits contain **127 exact-type/definition examples** across
**20 audit files**. The raw axiom reports cover **183 distinct declarations**
(185 occurrences across overlapping gates), each using only:

```text
propext, Classical.choice, Quot.sound
```

[Accepted v40 evidence](../provenance/accepted/v40/README.md) preserves the original
results ZIP, raw logs, audit and source hashes, and the source/log consistency
review. It supersedes the pending parameter statuses; it does not retroactively
turn earlier failed runs into successes.

| Layer | Recorded result |
|---|---|
| Mathlib-only finite library, public facades and both examples | Passed |
| Complete finite moment, corrected debit, and finite counting | Passed |
| Restricted PNT+ inputs and improper-integrability adapters | Passed |
| Replacement Mertens and selected-prime cutoff cancellation | Passed |
| Factorial, logarithm and fixed-constant small-prime estimates | Passed |
| Eventual corrected-budget upper estimate | Passed |
| Fixed-coefficient endpoint statement interface | Passed; not an endpoint proof |
| Exact window and truncation asymptotics | Passed |
| Cutoff growth, ordering and parameter admissibility | **Newly passed in v40** |
| Actual selected-prime error and prime-mass expansion | **Newly passed in v40** |
| Eventual positive gap between prime mass and corrected budget | v42 source implemented; two new gates pending |
| Normalized mass growth and signed mass/budget size bounds | v42 source implemented; pending |
| Amplified-error bounds and final positive-coefficient endpoint | Not yet proved |

## The accepted parameter result

For the protected definitions, put
\[
Q=\log X,\quad L=\log\log X,\quad
 a=\frac{\log2}{1+\log2},\quad H=\lfloor Q^a\rfloor,
\]
\[
J=2\lceil H/100\rceil,\qquad y=X^{1/(4J)},\qquad
 t=1/(1000L),\qquad\lambda=\operatorname{primeMass}(H,y).
\]

The parameter branch now has **43 accepted declarations** in five modules,
including the fixed-coefficient statement adapters. Fifteen cutoff/prime-mass
results passed for the first time in v40. Its main analytic conclusion is
\[
\boxed{\frac\lambda H-
 \bigl((1-a)L-\log\log H+\log(25/2)\bigr)\longrightarrow0.}
\]

The exact declaration is
`Erdos647Sieve.Endpoint.endpoint_primeMass_expansion_tendsto_zero`.
It has no free cutoff function, assumed growth condition, budget-gap premise,
or unproved prime-distribution estimate. The accepted result
`endpoint_parameters_admissible` supplies the actual finite-moment numerical
hypotheses eventually. It does not include nonnegativity of the signed budget;
the finite counting argument already has a separate negative-budget case.

The \(\log(25/2)\) constant has been retained, not replaced by an unspecified
bounded error. The endpoint exponent and scale are unchanged.

## Coefficient policy and remaining mathematics

The final goal is `EndpointBound c` for an **explicit fixed** real `c > 0`, and
then `PositiveEndpointClaim`. The coefficient is chosen before the onset and
before `X`. It is not allowed to vary with `X`.

**No endpoint coefficient is proved by v40.** The internal parameter
`t=1/(1000 log(log X))` is unchanged, but the final coefficient need not be
`1/1000`. The historical `EndpointClaim` is an optional corollary when available
without substantial extra effort. No alternative rigid numerical target is set.

The v42 changeset implements the fixed positive mass-budget gap and supporting
size bounds in two new modules. Their exact-type and axiom gates are pending;
the accepted 19-gate v40 baseline remains unchanged. There are now **21 registered
gates**, not 21 accepted gates. See [the current mathematical scope](prime-mass-gap-branch.md).
Every amplified error must then be bounded before final assembly.

## PR boundary

**The parameter-asymptotics changeset is ready for a normal PR on the supplied
source snapshot.** Its local acceptance criterion is satisfied: 19/19, warning-free,
with exact-type checks, permitted axioms and unchanged sources during the run.
The earlier v36 core/research fixes remain a separate accepted changeset.

[The parameter PR description](pull-requests/endpoint-parameters.md) records this
result. Review of an actual GitHub head/base diff, repository CI policy and external
mathematical review are separate; no remote PR or CI result was inspected here.

The v41 evidence update changed no checking or mathematical source. The subsequent
v42 gap changeset adds two proof modules and two audits, without modifying any of
the 45 existing mathematical modules or 20 existing audits. Its runner changes only
the diagnostic prefix to `erdos647_repo_v42_results_`. Dependency pins, cache and
checking behavior, and CI settings remain unchanged. The new proof source is not
part of the completed parameter PR's acceptance record.

## PNT+ scope and historical evidence

The recorded source scan covers the **14-module retained PNT+ subtree** rooted at
`MediumPNT`. It reports no admissions or forbidden proof shortcuts in that subtree;
`MediumPNT` and all seven extracted routines also passed their separate axiom audits.
The unfinished `ZetaSummary` catalogue is not imported. The scan is not a statement
that the full upstream repository or all Mathlib source is complete.

The [v36 checkpoint](../provenance/accepted/v36/README.md), earlier toolchain records,
rejected probe and previous failures remain preserved outside the current build
path. See [PNT+ trust boundary](pntplus-trust-boundary.md).

## Acceptance standard

The claimed acceptance is based on the returned build, exact-type and transitive-
axiom logs. Hash matching establishes source/log consistency, not independent
proof replay, source authenticity, novelty, or an explicit asymptotic onset.
No final positive-coefficient endpoint, finiteness result or resolution of #647
is claimed. The stable public library does not depend on the endpoint modules.
