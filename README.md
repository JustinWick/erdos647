# Erdos647Sieve

A Lean formalization of a **quantitative sparsity theorem for Erdős problem #647**,
together with reusable finite sieve and counting inequalities and a companion
proof paper under [`paper/`](paper/).

The final sparsity theorem was accepted in the **v47** verification run and
rechecked in **v48**, which also validated the public-library layout described
below. It bounds the count of integers satisfying the full condition in #647.
**It does not decide whether any such integer greater than 24 exists.**

The repository root is a **Mathlib-only library**. The separate `research/` Lake
package contains the analytic bridge and the completed endpoint proof, which
also depend on **PrimeNumberTheoremAnd (PNT+)**. The historical directory name
`research/` is retained for compatibility; the separate package isolates that
dependency, rather than marking the endpoint as unproved.

## The problem

Let $`\tau(m)`$ be the number of positive divisors of the positive integer $`m`$.
[Erdős problem #647](https://www.erdosproblems.com/647), posed by Erdős and
Selfridge, asks whether there is an integer $`n\gt 24`$ such that

```math
\max_{1\le m\lt n}\bigl(m+\tau(m)\bigr)\le n+2.
```

The condition holds at $`n=24`$; the question asks for another example beyond it.
Writing $`m=n-k`$ gives the equivalent condition used in this library:
an integer $`n\gt 24`$ is a **candidate** precisely when

```math
\tau(n-k)\le k+2
```

for every integer $`k`$ with $`1\le k\lt n`$.

Thus a candidate must satisfy a whole sequence of divisor restrictions:
$`\tau(n-1)\le3`$, $`\tau(n-2)\le4`$, $`\tau(n-3)\le5`$, and so on.
Here **candidate means an integer satisfying the full condition**, rather than
an integer that has only passed a preliminary computational test.

## What we have proved

Define the candidate counting function and exponent by

```math
C(X)=\#\{n\in\mathbb N:24\lt n\le X,\ \mathrm{Candidate}(n)\},
```

```math
a=\frac{\log 2}{1+\log 2}\approx0.4094.
```

All logarithms below are natural logarithms.

**Theorem (fixed-coefficient sparsity bound).** For every fixed real constant

```math
0\lt c\lt \frac{1499}{10^6}=0.001499,
```

there exists a natural number $`X_0=X_0(c)\ge3`$ such that, for every natural
number $`X\ge X_0`$,

```math
\boxed{
C(X)\le X\exp\!\left(
-c\,\frac{(\log X)^a}{\log\log X}
\right).
}
```

In particular, the formalization includes the explicit specialization,
valid for all sufficiently large $`X`$:

```math
C(X)\le X\exp\!\left(
-\frac{(\log X)^a}{1000\log\log X}
\right).
```

The coefficient range is **strict**: $`1499/10^6`$ is the upper threshold of the
proved range, not an attained coefficient in the final theorem. The theorem
does not provide a numerical value for $`X_0`$, and the threshold may depend on
the chosen $`c`$. No optimality claim is made for this coefficient range.

The general declaration is
`Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate`; the explicit
specialization is `Erdos647Sieve.Endpoint.endpointBound_one_div_thousand`.
Both are in [the final assembly](research/Erdos647Research/Endpoint/Main.lean).
The Lean generalization allows any real $`c\lt1499/10^6`$; the positive range
above is the one that gives the stated saving.

The saving scale $`(\log X)^a/\log\log X`$ tends to infinity. Consequently, the
proportion $`C(X)/X`$ tends to zero at the displayed rate. As an asymptotic
consequence, for each fixed admissible $`c`$ and each fixed $`M\gt0`$, its
right-hand side is eventually smaller than $`X/(\log X)^M`$. These are mathematical
consequences of the endpoint bound, not additional exported Lean theorems claimed
here. For fixed $`c`$, the right-hand side still tends to infinity:
**this proves neither finiteness nor the nonexistence of candidates**, and it
does not construct an example. It is a sparsity result toward #647.

### Intermediate bounds retained in the proof

Put

```math
Q=\log X,\qquad L=\log\log X,\qquad H=\lfloor Q^a\rfloor.
```

For the endpoint, the truncation order and prime cutoff are

```math
J=2\left\lceil\frac H{100}\right\rceil,
\qquad y=X^{1/(4J)}.
```

These formulas are used for sufficiently large $`X`$, when $`H,J\ge1`$.
The formal natural-number definition of $`J`$ is
`2 * ((H + 99) / 100)`; its equality to the ceiling expression is proved.
The resulting parameters satisfy $`H\lt y`$ eventually. Thus the estimates below
refer to these particular growing parameters, not to an arbitrary cutoff.

Define the prime mass and corrected budget by

```math
\lambda=H\sum_{\substack{H\lt p\le y\\p\ \mathrm{prime}}}\frac1p,
```

```math
B_H=
\sum_{k=1}^{H}\left\lfloor\frac{\log(k+2)}{\log2}\right\rfloor
-\sum_{\substack{p\le H\\p\ \mathrm{prime}}}
\left\lfloor\frac Hp\right\rfloor.
```

The subtraction defining $`B_H`$ is in the **signed integers**, not truncated
natural-number subtraction. All limits in this subsection are taken as natural
$`X\to\infty`$. For all sufficiently large $`X`$, the accepted estimates give

```math
\lambda-B_H\ge\frac32H,\qquad
0\le\lambda\le HL,\qquad B_H\le HL,
```

and

```math
\frac{\lambda}{HL}\longrightarrow1-a.
```

More generally, every fixed margin $`0\lt \delta\lt K`$ is available in
$`\lambda-B_H\ge\delta H`$ eventually, where

```math
K=\log(25/2)+\frac1{\log2}-2\gt \frac32.
```

After controlling all amplified error terms, the proof obtains the following
bound for the full candidate count, **without a sign assumption on $`B_H`$**,
for all sufficiently large $`X`$:

```math
\boxed{
C(X)\le
X\exp\!\left(-\frac{1499}{10^6}\frac HL\right)
+X\exp(-H/30)+2\sqrt X.
}
```

The term $`X\exp(-H/30)`$ bounds the amplified factorial truncation error.
The term $`2\sqrt X`$ combines one $`\sqrt X`$ bound for the amplified arithmetic
remainder and another for the exceptional initial window. The formal expression
uses $`2\exp(\log X/2)`$, which equals $`2\sqrt X`$ for positive $`X`$.
The final theorem absorbs all three contributions into one exponential bound.

## How the proof works

### 1. Turn divisor restrictions into a budget for prime factors

Let $`\omega(m)`$ count the distinct prime divisors of a positive integer $`m`$.
The elementary inequality $`2^{\omega(m)}\le\tau(m)`$ means that a candidate with
$`n\gt H`$ has a bounded sum $`\sum_{k=1}^{H}\omega(n-k)`$ across the window
$`n-1,\ldots,n-H`$. Each prime is counted once per window entry it divides,
regardless of its multiplicity in that entry.

Every prime $`p\le H`$ already divides at least $`\lfloor H/p\rfloor`$ numbers in
this window. Subtracting these unavoidable small-prime occurrences gives the
corrected budget $`B_H`$ above. If

```math
F_H(n)=\prod_{k=1}^{H}(n-k),
```

```math
T(n)=\#\{p\text{ prime}:H\lt p\le y,\ p\mid F_H(n)\},
```

then every such candidate satisfies $`T(n)\le B_H`$. A prime larger than $`H`$
cannot divide two different entries of the window, so these selected primes
are counted without duplicating their occurrences. If $`B_H\lt 0`$, no candidate
with $`n\gt H`$ is possible, and the separate exclusion theorem gives $`C(X)\le H`$.

### 2. Bound a weighted count using congruences

Choose $`0\lt z\lt 1`$. A candidate with $`T(n)\le B_H`$ has
$`z^{T(n)}\ge z^{B_H}`$, so an upper bound on the sum of $`z^{T(n)}`$ controls
the number of candidates beyond the initial window. The first $`H`$ integers
are accounted for separately.

For each selected prime $`p\gt H`$, the condition $`p\mid F_H(n)`$ occupies exactly
$`H`$ residue classes modulo $`p`$. The Chinese remainder theorem combines these
conditions for distinct primes. Counting the resulting residue classes in an
interval gives a main term and an explicit discrepancy. An even truncation of
the inclusion-exclusion expansion then produces a finite moment bound with a
factorial tail. This is a deterministic counting argument; it does not assume
that divisibility events are independent.

### 3. Choose the window and cutoff so prime mass exceeds the budget

The analytic layer estimates the reciprocal-prime sum defining $`\lambda`$ and
combines it with elementary budget estimates. The exponent is chosen so that

```math
\frac a{\log2}=1-a.
```

This balances the leading terms in the budget and prime-mass estimates.
Keeping the lower-order terms and constants yields the positive gap
$`\lambda-B_H\ge3H/2`$. That gap is what makes candidates rare: they must have
substantially fewer selected prime factors than the prime mass suggests.

The reciprocal-prime estimates come from the project's clean Mertens argument,
using the restricted analytic bridge to PNT+. They are proved inputs to the
endpoint, not additional conjectural prime-distribution assumptions in its
statement.

### 4. Convert the gap into an exponential saving, including the errors

Set

```math
t=\frac1{1000L},\qquad z=1-t,\qquad
\eta=-\log(1-t),\qquad \mu=t\lambda.
```

In the nonnegative-budget case, the principal counting contribution is
$`X\exp(\eta B_H-\mu)`$. The parameter lemmas give $`0\lt t\le1/2`$ eventually.
Using $`\eta\le t+t^2`$ in that range,
the gap and size bounds give

```math
\begin{aligned}
\eta B_H-\mu
&\le-t(\lambda-B_H)+t^2B_H\\
&\le-\frac32tH+t^2HL\\
&=-\frac{1499}{10^6}\frac HL.
\end{aligned}
```

This explains the coefficient: $`1500/10^6`$ comes from the gap, and $`1/10^6`$
pays for the quadratic logarithm correction. It is a constant produced by
these estimates, not a claimed optimal constant for #647.

The proof also bounds the **entire amplified** factorial tail and arithmetic
remainder, as well as the first $`H`$ integers. Combining those estimates with
the negative-budget exclusion gives the three-term bound above.

### 5. Absorb the remaining terms at the same scale

Write $`S=Q^a/L`$ and $`\alpha=1499/10^6`$. The scale lemmas prove

```math
\frac H{Q^a}\longrightarrow1,\qquad
S\longrightarrow\infty,\qquad
\frac SH\longrightarrow0,\qquad
\frac SQ\longrightarrow0.
```

For any fixed $`0\lt c\lt \alpha`$, divide the three-term bound by $`Xe^{-cS}`$.
Each of its three normalized contributions tends to zero, so their sum is
eventually at most one. This proves the final bound with no extra multiplicative
constant. The strict slack $`c\lt \alpha`$ handles rounding $`Q^a`$ down to $`H`$ and
absorbs the remaining errors; the argument does not establish $`c=\alpha`$.

## Reusable finite theorem

The finite library is useful independently of the asymptotic endpoint. In this
subsection, $`H,y,z,J`$ are free parameters satisfying the stated conditions; they
need not be the endpoint choices above.

For natural numbers $`X,H\ge1`$, real $`y\gt H`$, $`0\lt z\lt1`$, any even natural
$`J`$ (including zero), and **any integer translation $`A`$**, define $`T`$ using
the same selected-prime rule and set

```math
\mu=(1-z)H\sum_{\substack{H\lt p\le y\\p\ \mathrm{prime}}}\frac1p.
```

Here $`F_H(n)=\prod_{k=1}^{H}(n-k)`$ uses **integer subtraction** for every
$`n\in\mathbb Z`$, with no assumption $`n\gt H`$. If a factor is zero, all selected
primes divide the product; thus $`T(n)`$ remains well defined.

The proved moment inequality is

```math
\sum_{\substack{n\in\mathbb Z\\A\lt n\le A+X}}z^{T(n)}
\le
X\left(e^{-\mu}+\frac{\mu^{J+1}}{(J+1)!}\right)+(Hy)^J.
```

For $`B_H\ge0`$, the candidate counting theorem therefore gives

```math
C(X)\le H+
e^{(-\log z)B_H}
\left[
X\left(e^{-\mu}+\frac{\mu^{J+1}}{(J+1)!}\right)+(Hy)^J
\right].
```

The multiplier applies to the **whole** moment bound, including both errors.
For $`B_H\lt 0`$, the separate proved bound is $`C(X)\le H`$.
See [theorem statements](docs/theorems.md) for the library interfaces.

## Lean verification and acceptance

The accepted **v48 verification run**, completed on September 9, 2026 (UTC), records:

```text
erdos647_repo_v48_results_20260909T014011Z_dd165b9f
```

| Check | Accepted result |
| --- | --- |
| Build, exact-type and axiom gates | **30/30 passed** |
| Distinct declarations with transitive axiom audits | **235** |
| Expanded type/definition checks | **220** across 32 audit files |
| Runner and regression tests | **317 passed** |
| Build and audit diagnostics | **Zero warnings or errors** |
| Reported axioms | Only `propext`, `Classical.choice`, and `Quot.sound` |
| Final endpoint | General strict coefficient range and explicit $`c=1/1000`$ corollary |
| Promoted elementary library | Seven Mathlib-only modules in `Erdos647Sieve/Elementary/` and public facades |

The final mathematical assembly first passed in v47. The v48 run rechecked that
result and validated the promoted elementary library and public facades. These
counts describe that recorded source snapshot, not an automatic acceptance claim
for later commits or a count of independent mathematical results.

The PNT+ compatibility module imports `MediumPNT`; the runner also scans its
retained **14-module source subtree** for admissions. The consumed declarations
receive transitive-axiom audits. This does not certify the entire upstream PNT+
repository or complete its excluded theorem catalogues.

Exact-type checks pin the intended formal statements. Axiom reports identify
their transitive assumptions; they do not independently certify the prose proof,
novelty, or replay the development in a different implementation of Lean's kernel.
See [proof status](docs/proof-status.md),
[library promotion](docs/library-promotion-v48.md), and
[the PNT+ trust boundary](docs/pntplus-trust-boundary.md).

## Use the public library

```lean
import Erdos647Sieve

#check Erdos647Sieve.Candidate
#check Erdos647Sieve.finiteMoment
#check Erdos647Sieve.budgetDebit
#check Erdos647Sieve.finiteCounting

example : Erdos647Sieve.FiniteCountingClaim := Erdos647Sieve.finiteCounting
```

Within the separate analytic and endpoint package:

```lean
import Erdos647Research.Endpoint

#check Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate
#check Erdos647Sieve.Endpoint.endpointBound_one_div_thousand
#check Erdos647Sieve.Endpoint.positiveEndpoint
#check Erdos647Sieve.endpoint
```

The public interfaces in the v48 layout are:

| Import | Content | Dependencies |
| --- | --- | --- |
| `Erdos647Sieve.Basic` | Definitions | Mathlib-only core |
| `Erdos647Sieve.Finite` or `Erdos647Sieve` | Finite moment, budget and counting results | Mathlib-only core |
| `Erdos647Sieve.Elementary` | Promoted factorial, logarithm, prime-debit and budget estimates | Mathlib-only core |
| `Erdos647Research.Analytic` | Mertens and selected-prime results | Separate research package, including PNT+ |
| `Erdos647Research.Endpoint` | Completed fixed-coefficient endpoint | Separate research package, including PNT+ |

The seven promoted implementations live under `Erdos647Sieve/Elementary/`.
Their old research import paths remain supported by compatibility imports;
theorem names are unchanged and there is one implementation of each theorem.
The elementary facade is opt-in. Importing the finite library does not import
the analytic development or PNT+.

For downstream Lake projects, this repository's **root** is the package to use as
a Git dependency for the finite and elementary core. That dependency alone does
**not** expose `Erdos647Research.*`: those imports belong to the separate Lake
package under `research/`, which depends on the root by path. Use the recorded
pins for the checked configuration; compatibility with a different Lean/Mathlib
combination requires its own build and audit. See the [examples](Examples/) and
[dependency boundaries](docs/dependency-boundaries.md).

## Build and check

System prerequisites for the proof workflow: **Bash, Python 3.10+, Git, curl,
tar, a C/C++ build toolchain, unzip, zstd, and CA certificates**. The runner uses
Unix process and file-locking APIs. The recorded v48 build used **x86-64 Linux**;
on Windows, run in a Linux environment such as WSL rather than native Windows
Python. That run does not establish a tested macOS configuration.

The proof checks require no third-party Python packages, GPU, API key, or paid
model service. The first setup requires internet access to download the compiler
and libraries. Rebuilding the paper is separate and requires the TeX tools
described in its build documentation; TeX is not a dependency of the Lean checks.

From the repository root:

```bash
# Install or resume the pinned toolchain and dependencies, then check everything.
bash RUN.sh --setup

# Subsequent runs reuse tools, dependencies and compiled caches.
bash RUN.sh
```

`--upgrade` is an alias for `--setup`; it **does not select the latest release**.
The package is pinned to:

| Component | Pin |
| --- | --- |
| Lean | `leanprover/lean4:v4.32.2` |
| Mathlib | `905b95818eb32af7874a58b427f50c1711a5e96c` |
| PNT+ (research only) | `a5154676af9aa3095150ee410cdda80555aa0642` |

An existing matching Lean installation is reused. Otherwise setup installs a
repository-local Elan/toolchain under ignored `.tools/`, without changing the
global default or shell profile. Git dependencies use the exact commits in the
checked-in lockfiles. Existing caches are reused; a missing matching Mathlib
cache download is retried automatically once the toolchain and checkouts exist.
Thus a run without `--setup` can still need network access to restore a missing
Mathlib cache. Compiler and dependency installation still require `--setup`.
The core manifest, and the research manifest when research gates are selected,
are parsed by the installed Lake implementation before dependency/cache
preparation.

### Choose the scope

| Command | Scope |
| --- | --- |
| `bash RUN.sh` or `bash TEST_ALL.sh` | All registered core and research gates, including the endpoint. |
| `bash RUN.sh core` | Public core, examples, expanded types and axiom audits; includes the promoted elementary checks in v48. No PNT+ setup required. |
| `bash RUN.sh research` | All registered research gates and their prerequisites; needed core modules build as dependencies, but this is not a substitute for the separate core gate. |
| `bash RUN.sh --gate endpoint_public_results` | Public facade gate and registered prerequisites. |
| `bash RUN.sh tooling` | Offline runner/architecture tests only; not a Lean proof check. |
| `bash RUN.sh --list` | Gate inventory. |
| `bash RUN.sh --setup --refresh-cache` | Retry the matching Mathlib cache download. |
| `bash RUN.sh --jobs 4` | Run the default full suite with Lean worker-thread count set to four. |

`--setup` can be combined with `core`, `research`, or `--gate`.
`bash RUN.sh core --setup` installs only the public core's dependencies.

Lake reuses unchanged build artifacts and rebuilds changed modules and their
dependents. Selected exact-type and transitive-axiom audits run again on every
invocation. The runner does not reuse a historical audit verdict, invoke
`lake clean`, or recreate the project between runs.

### Ordinary Lake interface

With the pinned Lean/Lake toolchain available on `PATH`, the root also supports:

```bash
lake exe cache get
lake build
lake test
```

Here `lake build` builds the root library; **the exact-type and axiom audits run
through `lake test`**, whose driver checks the public core, including the elementary
estimates and examples. It does not audit the final endpoint. Inside `research/`,
`lake build` builds that package and `lake test` runs its research checks.

The test drivers delegate to the same Python checker used by `RUN.sh`; their
system prerequisites and diagnostic behavior therefore still apply. The
repository-wide runner joins the scopes and continues independent gates after
failures. There is no recursive `lake test` invocation.

## Results and failure behavior

A checking run normally creates a unique directory and ZIP under `results/`,
then prints `RESULTS ZIP: ...`. `results/latest_result.txt` records the completed
archive path. The directory, ZIP, and summary share one run identifier. The
version label identifies the runner; the recorded source hashes and executed
checks identify what was actually tested.

`--list` and `--collect-only` do not start a new proof check or create a new result
archive. Argument errors, lock acquisition failures, or early filesystem failures
can also occur before an archive is created.

Reports contain executed commands, exit codes, selected source/configuration
snapshots, dependency revisions, and available axiom output. The PNT+ closure
check also preserves the retained upstream source files. The collector excludes
tools and compiled caches and does not dump the entire environment or `.git`
configuration. **Source/configuration snapshots are copied byte-for-byte, not
secret-scrubbed.** Diagnostic redaction is best-effort; credentials accidentally
placed in collected source/configuration files can still be included. Review
archives before public sharing.

The v48 proof-result collector does not include `paper/`. The manuscript and its
supplement are separate artifacts; a successful Lean run does not itself rebuild
or verify the paper.

| Exit code | Meaning |
| --- | --- |
| `0` | All requested checks succeeded. In `tooling` mode, no Lean gate has run. |
| `1` | At least one selected proof/audit gate failed or was blocked. |
| `2` | Argument, setup, source-integrity, tooling, or runner failure. |
| `130` | A handled interruption of an active run. |

A failed prerequisite blocks downstream gates but leaves independent checks
running. Changes to collected checked inputs—including Lean source, Lake
configuration, scripts, tests, and collected documentation—between the recorded
before/after snapshots invalidate acceptance. CI workflow changes are recorded
separately because they do not affect the locally invoked proof commands.

Setup failures after the run has started are included in its diagnostics when
collection completes. A handled Ctrl+C normally packages partial output; abrupt
termination or a collection failure can leave only a partial results directory.
`--collect-only` reports the last completed archive without making a new
acceptance claim.

A failed full run is never converted to success because the core passed or a
historical checkpoint was green. An audit command that exits with an error does
not pass merely because it printed an allowed axiom list. The runner records
`endpoint_proved` only when the final gate and its prerequisites pass in that
invocation with stable checked inputs. Tooling tests or a core-only run do not
establish endpoint acceptance.

## Repository layout

| Path | Purpose |
| --- | --- |
| `RUN.sh`, `TEST_ALL.sh` | Top-level incremental check entry points |
| `Erdos647Sieve/` | Finite library and public core facades |
| `Erdos647Sieve/Elementary/` | Seven promoted Mathlib-only estimate modules in v48 |
| `Audit/`, `Examples/` | Public exact-type/axiom checks and usage examples |
| `paper/` | Proof manuscript (LaTeX source, rendered PDF, bibliography, build script) |
| `lakefile.lean`, `lake-manifest.json` | Mathlib-only core package and pinned dependencies |
| `research/` | Separate Lake package depending on the core by path |
| `research/Erdos647Research/Compat/PNTPlus.lean` | Restricted PNT+ import and attributed adapters |
| `research/Erdos647Research/Endpoint/` | Parameters, gap, amplified errors and final endpoint proof |
| `research/Audit/` | Research type and axiom audits |
| `scripts/check.py`, `scripts/gates.json` | Runner, module ownership guard and gate graph |
| `tests/` | Offline tooling, packaging and reporting tests |
| `docs/`, `provenance/` | Statements, scope, status and historical evidence |
| `.github/workflows/` | Core CI and manually dispatched research CI |

The core owns `Erdos647Sieve.*` import paths; research owns
`Erdos647Research.*`. Import paths and theorem namespaces are different: a theorem
in an `Erdos647Research` module can still have an `Erdos647Sieve.Endpoint` name.
The module roots are disjoint, and the runner checks that each audited module's
compiled object resolves to its expected package build directory. This detects
source-path shadowing rather than assuming that separate directory names alone
make it impossible.

The original rejected `MertensProbe` is retained as text under
`provenance/rejected/` and is never imported or built. Legacy source relocation
handles only the exact predecessor paths recorded for the v34 migration; a
checkout without those obsolete files needs no migration. Outside that guarded
one-time operation, ordinary checks do not synchronize or rewrite active proof
sources or clear compiled caches. They do copy source snapshots into diagnostics.

## CI and further documentation

The core GitHub workflow builds and tests the public core. The full research
workflow invokes the complete repository-wide suite. In the supplied v48 snapshot,
**both workflows are manually dispatched**; automatic push and pull-request
triggers in the core workflow are commented out. The checked-in workflow files
are authoritative for the current trigger policy; local checks do not rewrite
them.

Both workflows request diagnostic uploads even when checking fails, provided
those files were produced. A successful local checkpoint and a successful CI
run for a particular commit are separate pieces of evidence. The recorded local
result does not imply that CI has run on every PR.

- [Theorem statements](docs/theorems.md)
- [Proof status](docs/proof-status.md)
- [Manuscript and paper build](paper/README.md)
- [Final endpoint development](docs/final-endpoint-branch.md)
- [v48 library promotion](docs/library-promotion-v48.md)
- [Dependency boundaries](docs/dependency-boundaries.md)
- [Contributing](CONTRIBUTING.md)
- [Erdős problem #647: problem statement and references](https://www.erdosproblems.com/647)

The source is distributed with [LICENSE](LICENSE) and [NOTICE](NOTICE).
