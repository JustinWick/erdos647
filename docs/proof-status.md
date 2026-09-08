# Proof status

## Accepted checkpoint: v45 amplified-error estimate

The supplied run `erdos647_repo_v45_results_20260908T125209Z_b6d9b2cb` passed
**26/26 gates**, with **220 distinct declarations**, **169 expanded type/definition
checks** across **27 audit files**, and **244 passing runner tests**. All build
and audit commands succeeded without warning/error diagnostics; checked sources
were stable and both caches were reused. Transitive axioms are contained in
`{propext, Classical.choice, Quot.sound}`.

[Accepted evidence](../provenance/accepted/v45/README.md) includes the original
raw logs, source snapshots, manifest and source/log review. The final endpoint
is not a result of that run.

| Layer | Status |
|---|---|
| Mathlib-only finite core, public facades and examples | Accepted |
| Restricted PNT+ inputs, Mertens and selected-prime bridge | Accepted |
| Factorial, logarithm and fixed-constant debit/budget estimates | Accepted |
| Fixed-coefficient interface and exact parameter asymptotics | Accepted |
| Positive mass-budget gap and supporting size bounds | Accepted |
| All amplified errors and all-sign intermediate counting bound | **Accepted in v45** |
| Final absorption and fixed-c endpoint | **v46 source implemented; new audits pending** |

The accepted all-sign result, with $k=1499/10^6$, $Q=\log X$, $L=\log\log X$,
and $H=\lfloor Q^a\rfloor$, is

$$C(X)\le X e^{-kH/L}+X e^{-H/30}+2e^{Q/2}\quad\text{eventually}.$$

Its declaration is
`Erdos647Sieve.Endpoint.eventually_candidateCount_le_amplified_errors`.
It retains the amplified error terms and handles both signs of the integer
corrected budget. The gap margin $3/2$ and intermediate rate $k$ are not themselves
an accepted endpoint coefficient.

## New final-absorption work

The [v46 branch](final-endpoint-branch.md) adds scale limits, whole-majorant
absorption and final assembly. Its source implements `EndpointBound c` for every
fixed $c<1499/10^6$, the explicit specialization **c=1/1000**,
`PositiveEndpointClaim`, and the historical `Erdos647Sieve.endpoint` corollary.
These have their own three gates; the full suite is now 29 gates. The preceding
26/26 acceptance does not cover those additions.

The committed [coefficient record](endpoint-coefficient-status.json) distinguishes
an implemented coefficient from a proved coefficient. No final coefficient is
yet accepted. No parameter, exponent, scale, accepted proof or trust rule changes.

## PR boundary

**The amplified-error PR is locally ready on the supplied v45 snapshot.** The
[PR description](pull-requests/amplified-errors.md) excludes final absorption.
Normal review of the actual GitHub diff and required CI remain separate.
The v46 final assembly belongs in a separate mathematical changeset.

## Dependency scope and limitations

The root library is Mathlib-only. The research package remains pinned to the
native Lean/Mathlib 4.32.2/PNT+ lockfile and imports PNT+ only through its restricted
compatibility boundary. The retained 14-module PNT+ subtree passes the source
admission scan; this does not complete excluded upstream catalogues.

Historical evidence and rejected experiments remain outside the build graph.
Source/log consistency checks are not independent replay or novelty review.
Neither the intermediate bound nor the planned endpoint is a finiteness proof or
a resolution of Erdős #647. No explicit eventual onset is computed.
