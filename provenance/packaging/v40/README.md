# v40 overlay evidence

This directory records a one-module repair based on the uploaded v39 source and
logs. `prior-run/REVIEW.json` checks the supplied archive manifest, source hashes,
registered audit targets, exact-type commands and raw transitive axiom reports.
That review is an evidence consistency check, not a new theorem execution.

`CUTOFF_REPAIR_V40.patch` is the complete mathematical-source diff.
`source-preservation.json` records unchanged sources and audit files at this revision;
it does not impose a permanent source-freezing rule on later development.

The returned run accepted window and truncation parameters. The v40 cutoff source
is a repair awaiting its next build/type/axiom result; the prime-mass specialization
is still pending. No final EndpointBound c is asserted.

`validation.json` records the executed tooling tests and actual ZIP application
checks. These establish package behavior and source preservation, not universal
mathematical statements. No compiler, dependency, trust policy or CI workflow is
changed by this overlay.
