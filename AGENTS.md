# Project guardrails

- Stay on the checked-in Lean/Mathlib 4.32.2 pins unless the task explicitly requests
  a separately reviewed version migration.
- The root is the Mathlib-only finite and elementary library; `research/` is a separate Lake
  package. Never introduce PNT+ into the root's imports or lockfile.
- Core import paths use `Erdos647Sieve`; research import paths use `Erdos647Research`.
  The theorem namespaces are independent of module paths and remain unchanged.
  Never split one top-level module root across separate packages or change
  `LEAN_PATH` to compensate.
- Edit visible source directly. There are no managed-source copies, overlays,
  immutable runner inventories, or automatic upstream proof patches.
- Preserve the signed `Int` corrected budget, arbitrary integer translations and
  accepted hypotheses. Do not weaken an accepted statement to compile it.
- The endpoint must preserve a=log 2/(1+log 2) and the scale (log X)^a/log(log X).
  Its coefficient may be any explicit FIXED c>0. Use EndpointBound c; the historical
  EndpointClaim at c=1/1000 is retained unchanged but is not mandatory. Do not
  optimize arbitrary constants at the expense of the proof. Record the actual
  coefficient and final theorem audit; a candidate coefficient is not proved.
- Keep the current parameter definitions, including t=1/(1000 log(log X)), unless
  they obstruct the mathematics. Prioritize exact asymptotics, a fixed positive
  gap, every amplified error, then final assembly with a comfortable fixed c>0.
  Prove the legacy EndpointClaim as a corollary only when the available coefficient
  reaches 1/1000 without substantial extra work. Do not impose a replacement rigid
  coefficient such as 1/2000. Reuse accepted finite/PNT/Mertens/factorial/debit proofs.
- Keep the new parameter/endpoint work in its own mathematical changeset, separate
  from the accepted v36/v37 fixes. Do not add new proof code to that closed scope.
- Search existing library lemmas before reimplementing standard analysis.
- Use `RUN.sh --gate NAME` for targeted incremental feedback; `RUN.sh` tests all
  registered current gates. Source edits invalidate Lake traces normally.
- Add a checked-in exact-type and axiom audit for each new exported statement.
  Allowed axioms: propext, Classical.choice, Quot.sound only.
- The final endpoint passed in v47, with every fixed 0<c<1499/10^6 and the explicit
  c=1/1000 corollary. The upper boundary is strict. This does not solve #647.
- Keep historical logs separate from current acceptance. The v48 layout still
  needs its own core/compatibility/public-facade checks; see docs/proof-status.md.
- Public imports are Erdos647Sieve.Finite, Erdos647Sieve.Elementary,
  Erdos647Research.Analytic, and Erdos647Research.Endpoint. The last two stay in
  the separate PNT+-dependent package even though their theorems are proved.
- The seven research elementary paths are compatibility imports, not places to
  add new proof implementations. Edit Erdos647Sieve/Elementary/ instead.
- Do not spend time recreating migration/backup infrastructure or reorganizing
  accepted proof bodies for style.
