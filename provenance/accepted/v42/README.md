# Accepted v42 gap-and-size checkpoint

Date: September 8, 2026. Run: `erdos647_repo_v42_results_20260908T111052Z_81bd3ce5`.

The newer user-supplied archive passed **21/21 gates**, with no failed or blocked
checks and no warning/error diagnostics in build or audit logs. All **51 recorded
commands** exited successfully. There are **195 distinct audited declarations**,
**140 exact-type/definition examples** across **22 audit files**, and **203 passing
runner tests**. All transitive axiom lists are contained in
`{propext, Classical.choice, Quot.sound}`.

## Newly accepted mathematics

For the exact protected parameters H=windowLength(X), y=primeCutoff(X),
lambda=primeMass(H,y), B=correctedBudget(H), L=log(log X), eventually

\[
\lambda-B\ge\tfrac32 H,\qquad 0\le\lambda\le HL,\qquad B\le HL,
\]

and lambda/(HL) tends to 1-a. The budget is signed; no B>=0 hypothesis is imposed
on these theorems. The general gap theorem supplies every fixed delta<K, where
K=log(25/2)+1/log 2-2. This is a one-sided bound, not convergence of (lambda-B)/H.

Twelve declarations in `PrimeMassGap` and `MassBudgetBounds` passed their own
exact-type/axiom audits. The earlier 45 mathematical modules are unchanged from
the accepted v40 source, and both new modules match the delivered v42 overlay.

## Superseded diagnostic

The earlier `erdos647_repo_v42_results_20260908T110025Z_0072275b` stopped before
any Lean command, reporting the unresolved project import
`Erdos647Research.Endpoint.PrimeMassParameters`. That source snapshot contained
only the two new endpoint modules, not the five prerequisite parameter modules.
The newer archive includes the prerequisites and passes all gates. The earlier
failure is historical; it is not the basis of this acceptance record.

## Files and scope

The original ZIP, raw `logs/`, `source/`, `summary.json`, and its original
`MANIFEST.json` are preserved here. `REVIEW.json` records source/log consistency
checks; `AUDITED_DECLARATIONS.json` records parsed axiom lists.

`MANIFEST.json` authenticates consistency of the original bundle entries only;
it does not list this added README or review outputs. File hashes do not establish
source authenticity or independent proof replay. Acceptance here is based on the
returned compiler, exact-type and transitive-axiom evidence.

The local acceptance criterion for the gap-and-size PR is satisfied. Remote PR
diffs, branch ancestry, and required CI have not been assessed. No amplified-error
or endpoint theorem is proved in this checkpoint, and no final coefficient c is
claimed. The critical exponent and scale remain unchanged.
