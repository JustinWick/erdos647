# Erdos647Sieve

Finite sieve and counting inequalities in Lean, motivated by **Erdős problem #647**.
The repository root is a **Mathlib-only library**. The separate `research/` Lake
package contains the analytic bridge and unfinished endpoint development.

**This project does not resolve Erdős #647 and does not contain a proof of the
proposed final asymptotic endpoint.** The accepted v36 source snapshot has a recorded **14/14** build/type/axiom pass
in the v36 local run, covering **140 distinct audited declarations** with no
build or audit warnings. This includes the finite core, analytic bridge and
elementary budget estimates—not the final endpoint. See
[proof status](docs/proof-status.md) and the [accepted record](provenance/accepted/v36/README.md).

## Use the public library

```lean
import Erdos647Sieve

#check Erdos647Sieve.Candidate
#check Erdos647Sieve.finiteMoment
#check Erdos647Sieve.budgetDebit
#check Erdos647Sieve.finiteCounting

example : Erdos647Sieve.FiniteCountingClaim := Erdos647Sieve.finiteCounting
```

`Erdos647Sieve.Basic` exposes definitions; `Erdos647Sieve.Finite` exposes the finite
results. Existing theorem names and proof bodies are preserved. The
[examples](Examples/) use these public imports.

For downstream Lake projects, this repository's **root** is the package to use as
a Git dependency. The dependent project must use a compatible Lean/Mathlib pin;
adding this core package does **not** pull in PNT+.

## What the finite theorem says

Let

- `Candidate n` mean `n > 24` and `tau(n-k) <= k+2` for every `1 <= k < n`;
- `P = {p prime : H < p <= y}`;
- `T(n)` count the primes in `P` dividing the integer window polynomial
  `F(n) = product_(1 <= k <= H) (n-k)`;
- `mu = (1-z) H sum_(p in P) (1/p)`.

For natural `X,H >= 1`, real `y > H`, `0 < z < 1`, even natural `J`, and **any
integer translation A**, the proved finite moment statement is

```text
sum_(A < n <= A+X) z^T(n)
  <= X * (exp(-mu) + mu^(J+1)/(J+1)!) + (H*y)^J.
```

The budget is the **signed integer difference**

```text
B_H = sum_(k=1..H) floor(log(k+2)/log 2)
      - sum_(p <= H, p prime) (H / p),
```

where the last division is natural-number quotient. Prefix survivors satisfy
`T(n) <= B_H`. With `B_H >= 0`, the candidate count is bounded by `H` plus the entire
moment bound multiplied by `exp((-log z)*B_H)`. Negative-budget exclusion is a
separate proved consequence. See [theorem statements](docs/theorems.md).

## One runner for a new checkout

System prerequisites: **Bash, Python 3.10+, Git, curl, tar, a C/C++ build toolchain,
unzip, zstd, and CA certificates**. Linux and macOS are supported by the wrapper;
on Windows use WSL. No Python packages, GPU, API key, or paid service is needed.
The first setup requires internet access and downloads the compiler and libraries.

From the repository root:

```bash
# Install/resume the exact pinned toolchain and dependencies, then test everything.
bash RUN.sh --setup

# Later runs: incremental builds; reuse tools/dependencies and fill only a missing cache.
bash RUN.sh
```

`--upgrade` is an alias for `--setup` for continuity with the research workflow.
It **does not select the latest release**. The package is pinned to:

| Component | Pin |
|---|---|
| Lean | `leanprover/lean4:v4.32.2` |
| Mathlib | `905b95818eb32af7874a58b427f50c1711a5e96c` |
| PNT+ (research only) | `a5154676af9aa3095150ee410cdda80555aa0642` |

An existing matching Lean installation is reused. Otherwise setup installs a
repository-local Elan/toolchain under ignored `.tools/`, without changing the
global default or shell profile. Git dependencies are materialized at the exact
commits in the checked-in lockfiles. No version-mismatch reset, upstream proof
patch, or destructive cache cleaning is performed. Once the pinned toolchain and
dependency checkouts exist, a missing compiled Mathlib cache is resumed automatically;
already-present caches are reused. Compiler and repository installation still requires
`--setup`. Both manifests are parsed by the installed Lake implementation before
dependency/cache preparation.

### Choose the scope

| Command | Scope |
|---|---|
| `bash RUN.sh` or `bash TEST_ALL.sh` | All implemented core, analytic, and elementary gates. |
| `bash RUN.sh core` | Public finite library, examples, expanded types, and component/export axiom audits. No PNT+ setup required. |
| `bash RUN.sh research` | All 13 research gates; core imports are built as dependencies. |
| `bash RUN.sh --gate corrected_budget_estimate` | That gate plus its explicitly registered prerequisites. |
| `bash RUN.sh tooling` | Offline runner/architecture tests only. Not a Lean proof check. |
| `bash RUN.sh --list` | Display the gate inventory. |
| `bash RUN.sh --setup --refresh-cache` | Retry the matching Mathlib cache download. |
| `bash RUN.sh --jobs 4` | Set Lean worker-thread count; useful for memory control. |

`--setup` can be combined with `core`, `research`, or `--gate`. In particular,
`bash RUN.sh core --setup` installs only the public core's dependencies.

**Incremental does not mean weaker checking.** Lake reuses unchanged build
artifacts and rebuilds changed modules and their dependents. Selected exact-type
and transitive-axiom audits run again on every invocation. This runner does not
cache a theorem's audit verdict or mistake a previous `PASS` for a new one.
It never invokes `lake clean`, and it does not recreate the project between runs.

### Ordinary Lake interface

With the pinned toolchain available on `PATH`, the root also supports:

```bash
lake exe cache get
lake build
lake test
```

Here `lake test` checks the **public core only**. Inside `research/`, its own
`lake build` and `lake test` check the research package. The repository-wide
`RUN.sh`/`TEST_ALL.sh` joins these scopes while continuing independent gates after
failures. There is no recursive `lake test` invocation.

## Results and failure behavior

Every actual runner invocation creates a unique directory and ZIP under
`results/`, then prints `RESULTS ZIP: ...`. `results/latest_result.txt` records that
archive path. Reports contain executed commands, exit codes, source/configuration
snapshots, dependency revisions, and available axiom output. No cache, complete
environment dump, credential file, or Git remote configuration is collected.
Log redaction is best-effort; review reports before sharing them publicly.

Exit code `0` means **all selected gates passed**; `1` means a proof/audit failed or
was blocked; `2` means a setup/integrity failure; `130` means interruption. A failed
prerequisite blocks its downstream gates but does not suppress independent checks.
Changes to Lean source, Lake configuration, scripts, or tests during a run invalidate
that run. CI workflow YAML changes are recorded separately because they do not affect
the locally invoked proof commands. Setup failures remain visible in the report.
A normal Ctrl+C still packages partial output. A machine crash can leave a partial
results directory; `--collect-only` prints the last completed archive, not a new
acceptance claim.

**All 14 currently registered gates have passed in the v36 record.** Future
changes must still pass their selected checks: a failing `all` run is never
converted to success because the core passed. The remaining endpoint work is
outside this completed gate inventory and remains separate from the public core.

## Repository layout

```text
RUN.sh / TEST_ALL.sh       Top-level incremental check entry points
Erdos647Sieve/             24 preserved finite modules plus public facades
Audit/                    Checked-in public exact-type and axiom checks
Examples/                 Public-import usage examples
lakefile.lean              Mathlib-only public Lake package
lake-manifest.json         Nine exact core dependency revisions
research/                 Separate Lake package; depends on this core by path
  Erdos647Research/       12 analytic/elementary modules; theorem names unchanged
    Compat/PNTPlus.lean   Restricted PNT+ import plus seven attributed adapters
  Audit/                  A separate audit for every research module
  lake-manifest.json      Native PNT+ lock plus the local core dependency
scripts/check.py           Incremental checks and compiled-module ownership guard
scripts/gates.json         Gate inventory and prerequisite graph
tests/                    Offline tests of tooling, packaging, and reporting
docs/                     Statements, scope, contribution and version policy
provenance/               Historical reports, source map, rejected probe, handoffs
.github/workflows/        Core CI and manually dispatched research CI
```

The core owns `Erdos647Sieve.*` import paths; research owns `Erdos647Research.*`.
Their **theorem namespaces** are unchanged. These separate module roots prevent
Lean's first-root import resolution from finding a research object in the core's
build directory. See [dependency boundaries](docs/dependency-boundaries.md).

For an overlay over v32/v33 only, the runner archives the 13 exact obsolete source
paths under `provenance/refactors/v34/retired/` once. Unknown edits are preserved
and stop that relocation. A new checkout with the new paths needs no migration;
ordinary runs do not copy or rewrite source files. No compiled cache is deleted.

There is **one active copy of each mathematical source file**. The original
rejected `MertensProbe` is retained as text under `provenance/rejected/`, never
imported or built. The historical migration executables and alternative live
workspaces are not part of the new workflow. Existing external archives are not
modified or deleted by this distribution.

## CI and status

The core GitHub workflow builds and tests only the public library. Its triggers
are controlled in `.github/workflows/ci.yml`; local checks do not rewrite them.
The full research workflow remains manually dispatched under the existing CI
policy; all currently registered research gates have local acceptance evidence. Both upload diagnostics, and neither swallows failed checks.
No repository name, owner, token, or upload credential is hardcoded. The ZIP does
not contain a `.git` directory or perform any GitHub write operation.

[Proof status](docs/proof-status.md) distinguishes historical theorem evidence from
current package results. [Contributing](CONTRIBUTING.md) explains the package
boundaries and gate registry. The source is distributed with `LICENSE` and `NOTICE`.

## New endpoint-parameter branch (v38)

The accepted finite library is unchanged. Five new research gates develop the
actual growing parameters and a coefficient-parametrized endpoint interface. The
full suite now has 19 gates; the new five are not covered by the historical v36
pass. The final goal keeps the critical exponent and scale with an explicit fixed
c>0; the historical 1/1000 coefficient is optional. No positive-coefficient endpoint
bound is yet claimed. See [branch scope](docs/endpoint-parameter-branch.md).
