# Proof status

This repository repackages the source through the **v31** repair/extraction.
It is not a new theorem or a new toolchain migration. Lean/Mathlib remain on 4.32.2.

## Historical evidence retained

| Layer | Last relevant recorded evidence | Status carried into this repository |
|---|---|---|
| Complete finite-moment, budget, finite-counting chain | v30 final finite audit | Accepted in the former research workspace. |
| Reciprocal-log calculus and Abel identity | v25/v27 analytic repair sequence | Accepted source retained. |
| Analytic input, clean Mertens, selected-prime bridge | v27/v28 | Accepted on the native PNT+ 4.32.2 dependency set. |
| Factorial bounds, normalized residual, log-budget connection, endpoint log inequalities | v29 | Accepted source retained. |
| Prime-reciprocal lower bound | v30 reported an attached-sum error; v31 supplied a repair | Pending acceptance of repaired source. |
| Small-prime debit and joint corrected-budget estimate | v30 blocked by the prime-reciprocal module | Pending. |
| Endpoint parameter limits, quantitative mass/budget gap, amplified-error absorption | Not implemented in the supplied source | Still required. |
| Final asymptotic endpoint | Only the target is defined | No proof. |

The raw accepted axiom logs are under `provenance/accepted/`. The failed prime-sum
build and the later source repair are under `provenance/pending/`. The source map
records the hash and location of all 37 original files. Its checksums document
origin; normal development is not forced to match every historical proof hash.

The new root/research package boundary and runner report their own results in
`results/`. Historical acceptance is never inserted as a current gate pass. A
successful source/package test is not itself theorem verification.

## Standalone repository evidence: v33

Run `erdos647_repo_v33_results_20260908T061726Z_5c0e7860` accepted the independent
core package, both public examples, and both core audit files. Its 95 distinct
axiom reports contain only the permitted foundations. The resolved core search
path contains no PNT+ library directory.

Four research modules compiled (`ReciprocalKernel`, `EndpointLogBounds`,
`FactorialBounds`, `PrimeReciprocalLower`) but failed at audit import resolution.
Eight dependent gates were blocked. Their successful builds are not recorded as
passing theorem/audit gates. v34 changes module ownership to repair that packaging
failure; it does not change a mathematical statement or fill the endpoint gap.

## Acceptance standard

A Lean proof gate builds the relevant modules, checks its checked-in exact-type
examples, and reads fresh `#print axioms` output. Permitted transitive axioms are
`propext`, `Classical.choice`, and `Quot.sound`. Missing output, duplicate reports,
additional axioms, and nonzero command exit codes cause failure.

The public audit includes named claim types and expanded statements. The signed
budget and arbitrary integer interval translation are preserved. The protected
specification's historical hash is also checked; changes to that definition file
need a separately reviewed statement change.

These checks do not establish mathematical novelty, independent-kernel replay,
or a resolution of Erdős #647. None of those is claimed by a green core job.


## v34 returned results / v35 dependency and lint repair

The v34 run passed 11/13 gates, covering 130 distinct audited declarations. The
prime reciprocal lower bound is now among those accepted results. The natural
index of the small-prime quotient sum remains the immediate reported proof repair;
the combined corrected-budget check was blocked. All selected PNT/analytic theorem
axiom reports passed, but the broad imported environment included 15 admitted
upstream declarations. v35 replaces that broad import with the completed PNT
subtree and adds a separate recursive source-closure check. Historical acceptance
of the broader adapter is not counted as acceptance of the new extracted module.

The new combined PR threshold is all 14 implemented gates with no build warnings
and an acceptable PNT source-closure/axiom report. No endpoint theorem has been added.


## v35 returned evidence / v36 focused lint repair

The run `erdos647_repo_v35_results_20260908T071828Z_a8ef3d01` passed **13/14**
implemented gates, with **139 distinct declarations** in the successful axiom
reports. All use only the permitted foundations. Both core examples and all
completed analytic adapters passed. The small-prime debit theorem is now accepted:

```lean
Erdos647Sieve.Elementary.smallPrimeDebit_lower
```

Its exact conclusion is `H * (log (log H) - 2) <= smallPrimeDebit H` over the
reals for natural `H >= 2`, with the natural quotients unchanged.

The new PNT+ compatibility boundary also passed. Its retained upstream source
subtree comprises 14 modules with no admission tokens found; `MediumPNT` and the
seven extracted adapters passed their separate theorem/axiom audits. This is not
a claim that every unimported PNT+ catalogue is complete.

`corrected_budget_estimate` failed solely on an unnecessary `<;>` linter diagnostic,
which is fatal under the unchanged warning policy. Its axiom audit was not run.
v36 replaces that tactic combinator with ordinary sequencing. The combined fixes
can be reviewed in a draft PR; merge approval still requires a current 14/14 run.
Historical or partial success is not substituted for that result.

The source and audit review is recorded in
`provenance/accepted/v35/REVIEW.json`, with selected raw logs alongside it.
No endpoint theorem, explicit asymptotic onset, independent kernel replay, or
novelty determination is added by this packaging/lint repair.
