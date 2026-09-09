# Packaging references

The repository layout follows the user-supplied architecture handoff, preserved
at `provenance/handoffs/architecture.md`. Earlier mathematical library leads are
preserved separately; their old toolchain recommendation does not override this
repository's current native 4.32.2 lock.

For reproducible tool semantics, the packaging pass inspected:

- Lean 4.32.2 Lake README (library roots, globs, local path dependencies, test drivers,
  and trace-based incremental builds):
  https://github.com/leanprover/lean4/blob/v4.32.2/src/lake/README.md
- Lean 4.32.2 Lake manifest schema (`type: path`, `dir`, and inherited Git entries):
  https://github.com/leanprover/lean4/blob/v4.32.2/src/lake/Lake/Load/Manifest.lean
- Elan setup and toolchain selection:
  https://github.com/leanprover/elan
- Official Lean GitHub action (build, test, and Mathlib/.lake caches):
  https://github.com/leanprover/lean-action

These references establish tool behavior, not acceptance of a project theorem.
Proof status is based on the historical project reports and subsequent actual
runs of this repository, not on a CI YAML file existing.
