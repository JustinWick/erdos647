# Accepted parameter-asymptotics checkpoint — v40

Run: `erdos647_repo_v40_results_20260908T091111Z_0850cec9`. Completed: September 8, 2026.
Environment: `leanprover/lean4:v4.32.2`; Mathlib
`905b95818eb32af7874a58b427f50c1711a5e96c`; PNT+
`a5154676af9aa3095150ee410cdda80555aa0642`.

## Accepted scope

All **19 gates** passed: the established 14 plus the five parameter-branch gates.
All **43 branch declarations** are covered; 15 cutoff/prime-mass results passed
for the first time here. In total: **183 distinct declarations**, 185 axiom report
occurrences, **127 exact-type/definition examples**, **20 audit files**,
**47 successful commands**, and **178 passing runner tests**.
The 39 build/audit logs contain no warning or error diagnostics. Both caches were
reused. No source/configuration changed during the run.

The constant-sensitive expansion `endpoint_primeMass_expansion_tendsto_zero` and
the exact `endpoint_parameters_admissible` result are accepted. The mass-minus-budget
gap, amplified errors and final endpoint are not yet project theorems. No explicit
positive endpoint coefficient is claimed.

## Evidence contents

[Original results ZIP](erdos647_repo_v40_results_20260908T091111Z_0850cec9.zip) contains all recorded source, checked-in audits,
configuration, command logs and diagnostic reports. Its byte-level checksum is
in [REVIEW.json](REVIEW.json). The original internal `MANIFEST.json` paths refer
to files inside that diagnostic ZIP; they are not a manifest of this directory.

The raw [cutoff audit](logs/045_endpoint_cutoff_parameters_audit_0.log) and
[prime-mass audit](logs/047_endpoint_prime_mass_parameters_audit_0.log) include the
exact printed types and transitive axiom reports. The other raw logs are retained
as well. `AUDITED_DECLARATIONS.json` indexes all reported declarations.
`CHECKED_SOURCE_SHA256.json` and `CHECKED_MATH_SOURCE_SHA256.json` identify the tested
configuration and mathematical modules. The original source itself is retained in
the ZIP rather than duplicated as another live proof tree.

The read-only review checked 201 manifest hashes, 118 source hashes, all 45
mathematical modules against the delivered sources, all audit targets, 94 recorded
module-ownership resolutions and 14 dependency revisions. The only difference from
the delivered snapshot was the already-existing user CI workflow edit; it is
preserved. The recorded 14-module PNT+ admission scan passed. Its lexical scope is
the retained PNT+ subtree, not the entire upstream repository or Mathlib.

The bundled `review_evidence.py` checks the preserved ZIP read-only, without
executing its source or changing the repository. Its recorded output is
[CONSISTENCY_REPLAY.json](CONSISTENCY_REPLAY.json).

## PR scope and evidence limits

This satisfies the local acceptance condition for a normal parameter-asymptotics
PR on this source snapshot. It does not assert that an actual GitHub PR has been
created, that remote CI has passed, or that a maintainer has reviewed the diff.
The positive-gap work belongs in the next mathematical changeset.

These are user-returned compiler/type/axiom reports plus a source/log consistency
review. Hash checks detect discrepancies; they are not authentication of a remote
build, independent kernel replay, a novelty review or a numerical onset certificate.
The historical endpoint with coefficient 1/1000 remains optional and unproved.
