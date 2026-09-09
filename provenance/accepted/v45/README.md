# Accepted amplified-error checkpoint — v45

The supplied run `erdos647_repo_v45_results_20260908T125209Z_b6d9b2cb` passed
**26/26 gates** on the recorded source snapshot, with no warning or error in its
build/audit logs. It checked **220 distinct declarations** and **169 expanded
type/definition examples** across **27 audit files**. All **244 runner tests**
passed. The compiler was Lean 4.32.2 and both package caches were reused.

The five amplified-error gates supply 25 newly accepted declarations, culminating
in `eventually_candidateCount_le_amplified_errors`. This is an all-sign bound,
including the amplified factorial tail, amplified CRT remainder and exceptional
window. It is not yet the final `EndpointBound c` theorem.

`SUMMARY.md`, `summary.json`, `logs/`, `source/`, `source_dependencies/` and the
original `MANIFEST.json` reproduce the returned evidence. `REVIEW.json` records
consistency checks against those files. Every original manifest entry matches.
The original run's static historical-status strings are preserved verbatim;
the current command exit codes and gate results, not historical strings, establish
this checkpoint's acceptance.

This evidence supports a normal amplified-error PR on the supplied local snapshot.
The actual GitHub base/head diff and remote CI are separate. The final absorption
source introduced in v46 is not covered by this checkpoint.
