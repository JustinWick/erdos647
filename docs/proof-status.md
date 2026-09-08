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
