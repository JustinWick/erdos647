# Contributing

The default public API is `import Erdos647Sieve`, with `Basic` and `Finite` facades.
`Erdos647Sieve.Elementary` is the opt-in Mathlib-only elementary-estimate surface.
Preserve existing declarations and exact theorem hypotheses. Avoid proof-body
refactors during packaging changes; use small named adapters for repeated API or
cast mismatches. Never replace an unproved result by an axiom or implicit premise.

The root package must remain Mathlib-only. PNT+-dependent work belongs
in `research/`, including the accepted endpoint; proved does not mean dependency-free. New research modules need a narrow root in its Lake file,
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

A core-only build does not check the PNT+-dependent endpoint. The accepted v47
endpoint is historical evidence; current-layout validation must run its own
selected audits. Update proof-status records only from actual theorem-type and
axiom results, keeping their provenance.

Seven elementary implementations live under `Erdos647Sieve/Elementary/`. Their
old research imports remain forwarding modules, not duplicate implementations.
New theorem statements should receive exact-type/axiom checks in the owning
package. Preserve the existing checks on old imports as compatibility regressions.
Do not add PNT+ to the core to move the endpoint into it. The public endpoint
facade is `Erdos647Research.Endpoint` in the separate package.
