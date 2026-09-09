# Contributing

The default public API is `import Erdos647Sieve`, with `Basic` and `Finite` facades.
Preserve existing declarations and exact theorem hypotheses. Avoid proof-body
refactors during packaging changes; use small named adapters for repeated API or
cast mismatches. Never replace an unproved result by an axiom or implicit premise.

The root package must remain Mathlib-only. Experimental and PNT+-dependent work
belongs in `research/`. New research modules need a narrow root in its Lake file,
a checked-in `research/Audit/*.lean` file, and a gate in `scripts/gates.json`.
A prerequisite edge means its audit must pass first; imports remain the actual
mathematical dependency mechanism. `RUN.sh --list` shows the current inventory.

Use `RUN.sh core` for the stable API, `RUN.sh research` for research, or
`TEST_ALL.sh` for the combined suite. Lake performs incremental rebuilds; there is
no need to clear `.lake/` after a source edit. Audit verdicts are not cached.
The offline test suite is available through `RUN.sh tooling` and directly through
`python3 -m unittest discover -s tests -v`.

Version changes must update the compatible toolchain, manifests, and
`scripts/pins.json` together. The current release deliberately retains 4.32.2.
Dependency setup never resets unexpected local edits or changes a recorded pin.

Commit source, manifests, audit files, documentation, and tests. Do not commit
`.lake`, local toolchains, generated results, credentials, or migration caches.
The `.gitignore` protects those paths without excluding historical axiom logs.
CI has read-only repository permissions and needs no repository-specific secrets.

A clean public build is not a proof of the unfinished endpoint. Update proof-status
records only from actual theorem-type and axiom results, keeping their provenance.
