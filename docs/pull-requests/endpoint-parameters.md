# Prove endpoint parameter asymptotics and the prime-mass expansion

## Summary

Connect the protected endpoint parameters to the existing finite sieve and Mertens
interfaces. Introduce a fixed-coefficient endpoint statement interface, preserving
the critical exponent and saving scale without making `1/1000` mandatory.

This is a mathematical changeset after the accepted core/research fixes. It does
not reopen those proofs, port the toolchain, change the public finite API, or claim
the final endpoint.

## Mathematical results

For \(Q=\log X\), \(L=\log\log X\), \(a=\log2/(1+\log2)\), and the exact
protected choices \(H=\lfloor Q^a\rfloor\), \(J=2\lceil H/100\rceil\),
\(y=X^{1/(4J)}\), establish

\[
H\to\infty,\quad H/Q^a\to1,\quad\log H-aL\to0,\quad J/H\to1/50,
\]
\[
\log y/Q^{1-a}\to25/2,\quad y\to\infty,\quad H<y\ \text{eventually},
\]
and the finite-moment parameter admissibility, including parity and the range of
\(z=1-1/(1000L)\).

The main conclusion for \(\lambda=\operatorname{primeMass}(H,y)\) is
\[
\frac\lambda H-
 \bigl((1-a)L-\log\log H+\log(25/2)\bigr)\to0.
\]
The retained constant matters for the next gap argument. No unproved cutoff-growth
or distribution hypothesis is added to this declaration.

## Source scope

Five modules under `research/Erdos647Research/Endpoint/`: `Statement`,
`WindowParameters`, `TruncationParameters`, `CutoffParameters`, and
`PrimeMassParameters`, with five new audit gates and 43 branch declarations.
All 40 previously accepted mathematical modules and their 15 audit files are
unchanged relative to the v36 fixes checkpoint. The parameter modules reuse existing
Mathlib limits and project-level Mertens interfaces; there is no direct upstream
PNT+ import in the endpoint layer. Lean/Mathlib remains 4.32.2.

The v41 addition contains documentation and accepted evidence only; all mathematical
and checking code is the v40 code used in the successful run.

## Validation of the supplied source snapshot

Evidence: `erdos647_repo_v40_results_20260908T091111Z_0850cec9`, September 8, 2026.

- [x] **19/19 registered gates passed**, including the established 14.
- [x] All 47 commands exited successfully; no blocked or failed gate.
- [x] No warning or error diagnostics in the 39 build/audit logs.
- [x] All 183 distinct audited declarations use only `propext`, `Classical.choice`,
  and `Quot.sound`; all 43 branch targets are included.
- [x] 127 checked-in exact-type/definition examples across 20 audit files.
- [x] 178 runner tests passed; both caches reused; no source changes during the run.
- [x] Returned source matches the delivered proof/checking code, including the
  unchanged protected specification and all dependency revisions.
- [ ] Reviewer confirms the actual PR head/base diff matches this scope and the
  attached tested snapshot; repository-required CI and review are completed.

The source/log review and raw evidence are in `provenance/accepted/v40/`.
Local acceptance is satisfied. The unchecked item is ordinary review of the actual
PR, not a reason to extend the mathematical scope of this changeset.

## Coefficient policy

The endpoint goal is \(C(X)\le X\exp(-c(\log X)^a/\log\log X)\) for an explicit
fixed \(c>0\), chosen before the onset and before \(X\). No \(c(X)\) is allowed.
The internal choice \(t=1/(1000L)\) is retained. The historical `EndpointClaim` is
an optional corollary when a proved coefficient supports it at essentially no cost.

**This PR proves no positive-coefficient endpoint bound.** Its statement adapters
are not substitutes for the missing estimate. The machine-readable proved
coefficient remains null.

## Deliberately not included

The eventual mass-minus-budget gap, normalized upper bounds, amplified principal
term, factorial tail, arithmetic remainder and final absorption are the next
mathematical changeset. This PR also does not claim an explicit onset, novelty,
finiteness, or a resolution of Erdős #647.
