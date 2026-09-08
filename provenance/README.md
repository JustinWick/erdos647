# Provenance, not live build state

`source-map.json` accounts for all 37 prior project Lean files. Twenty-four finite
files live at the root; twelve analytical/elementary files live in `research/`;
the rejected historical probe is retained as `rejected/MertensProbe.lean.txt`.
The v31 `PrimeReciprocalLower` repair is the only difference from the v30 source
snapshot. This packaging makes no additional mathematical source edit.

`accepted/` contains historical raw theorem/axiom reports. `pending/` retains the
last submitted prime-reciprocal error and subsequent repair. `pins/` preserves
PNT+'s native dependency configuration, and `handoffs/` preserves supplied plans.
These are not imported or run. In particular, a historical green report is not
used to manufacture a current runner result.

The original local migration workspaces and complete user diagnostics archives
are not copied into this fresh repository. They remain unchanged in the user's
existing development environment. This source distribution contains no credentials,
local absolute checkout paths, generated caches, or archived live installations.
