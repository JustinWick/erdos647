# Project guardrails

- Stay on the checked-in Lean/Mathlib 4.32.2 pins unless the task explicitly requests
  a separately reviewed version migration.
- The root is the Mathlib-only finite library; `research/` is a separate Lake
  package. Never introduce PNT+ into the root's imports or lockfile.
- Core import paths use `Erdos647Sieve`; research import paths use `Erdos647Research`.
  The theorem namespaces are independent of module paths and remain unchanged.
  Never split one top-level module root across separate packages or change
  `LEAN_PATH` to compensate.
- Edit visible source directly. There are no managed-source copies, overlays,
  immutable runner inventories, or automatic upstream proof patches.
- Preserve the signed `Int` corrected budget, arbitrary integer translations, exact
  hypotheses, and protected endpoint target. Do not weaken a statement to compile it.
- Search existing library lemmas before reimplementing standard analysis.
- Use `RUN.sh --gate NAME` for targeted incremental feedback; `RUN.sh` tests all
  registered current gates. Source edits invalidate Lake traces normally.
- Add a checked-in exact-type and axiom audit for each new exported statement.
  Allowed axioms: propext, Classical.choice, Quot.sound only.
- Keep historical logs separate from current acceptance. Pending endpoint work is
  documented in docs/proof-status.md and research/README.md.
- Do not spend time recreating migration/backup infrastructure or reorganizing
  accepted proof bodies for style.
