# Proof status

## Current accepted repository checkpoint: v42

The newer run `erdos647_repo_v42_results_20260908T111052Z_81bd3ce5` passed **21/21 gates** on September 8, 2026,
using the pinned **Lean/Mathlib 4.32.2** environment. No gates failed or were blocked.
All **51 commands** exited successfully. The build/audit logs contain zero warning
or error diagnostics, and all **203 runner tests** passed. Checked sources were
stable during the run, and both packages reused their caches.

The audits cover **195 distinct declarations** and **140 expanded type/definition
examples** across **22 audit files**. All reported transitive axioms are within
`{propext, Classical.choice, Quot.sound}`.
[Accepted evidence](../provenance/accepted/v42/README.md) preserves the source,
raw reports, original results ZIP and consistency review.

The earlier v42 diagnostic lacked the prerequisite parameter modules and stopped
before any Lean command. It remains a historical failure; the newer complete
source snapshot supplies the successful evidence here.

| Layer | Recorded result |
|---|---|
| Mathlib-only finite library, facades and examples | Passed |
| Complete finite moment, debit and counting | Passed |
| Restricted PNT+, integrability, clean Mertens and cutoff cancellation | Passed |
| Factorial, logarithm, small-prime and corrected-budget estimates | Passed |
| Fixed-coefficient endpoint statement interface | Passed; not an endpoint proof |
| Exact parameter asymptotics and prime-mass expansion | Passed |
| Fixed positive prime-mass/budget gap | **Newly passed in v42** |
| Normalized prime mass and signed budget size bounds | **Newly passed in v42** |
| Amplified-error bounds and final fixed-positive-coefficient endpoint | Not yet proved |

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

## The newly accepted gap and size results

With B=correctedBudget(H) kept signed, the new results are

\[
\lambda-B\ge\frac32 H\quad\text{eventually},\qquad
\frac{\lambda}{HL}\longrightarrow1-a,
\]

and eventually 0<=lambda<=HL and B<=HL. The fixed gap declaration is
`Erdos647Sieve.Endpoint.eventually_primeMass_sub_correctedBudget_ge`.
The combined interface is
`Erdos647Sieve.Endpoint.eventually_endpoint_mass_budget_bounds`.
It includes H>=1 and L>0 but deliberately does not assume B>=0.

There are **12 new accepted declarations** in two modules. The more general gap
theorem supplies every fixed delta<K, with K=log(25/2)+1/log 2-2.
It does not assert (lambda-B)/H converges to K; the budget estimate is one-sided.

## Endpoint coefficient and next effort

**No endpoint coefficient has yet been proved.** The constant 3/2 is a gap per
window shift, not the saving coefficient c. The goal remains `EndpointBound c`
for a named explicit fixed c>0, then `PositiveEndpointClaim`, with c independent
of X and the critical exponent and scale unchanged.

Keep t=1/(1000 log(log X)) and the other current parameters. The final coefficient
need not be 1/1000; derive the historical `EndpointClaim` only when essentially
free. No replacement rigid coefficient target is imposed.

The next mathematical changeset is [every amplified error term](next-amplified-errors.md),
followed by final assembly and the separate negative-budget case. Do not reopen
the accepted finite, PNT+, Mertens, factorial, debit or parameter proofs.

## PR boundary

**The gap-and-size changeset meets its local PR acceptance condition.**
[The prepared PR description](pull-requests/prime-mass-gap.md) records the 21/21
source snapshot. The previous parameter PR remains separate. Remote head/base
diffs and required CI are not assessed by these uploaded local results.

The v43 closeout modifies only documentation, provenance, and one evidence-status
regression test. All **47 mathematical modules**, **22 audits**, the runner,
gate registry, pins, lockfiles and CI workflows remain unchanged.

## PNT+ scope and historical records

The retained **14-module PNT+ source subtree** passed the admission scan;
`MediumPNT` and the seven extracted routines also passed their audits.
The excluded `ZetaSummary` catalogue is not imported. This does not claim that
the entire upstream repository is free of admissions.

Earlier accepted checkpoints, rejected experiments and source history remain
preserved outside the active build graph. The root library remains Mathlib-only.

## Evidence scope

Acceptance records the returned build, expanded-type and transitive-axiom results.
Hash comparison establishes file consistency, not source authenticity, independent
proof replay or novelty. No final endpoint, finiteness result or resolution of
Erdős #647 is claimed.
