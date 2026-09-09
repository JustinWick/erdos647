# Erdos647Sieve

A Lean formalization of a **quantitative sparsity theorem for Erdős problem #647**,
together with reusable finite sieve and counting inequalities.

The final sparsity theorem is proved in the accepted **v47** checkpoint. It bounds
how many integers could satisfy the condition in #647. **It does not decide
whether any such integer greater than 24 exists.**

The repository root is a **Mathlib-only library**. The separate `research/` Lake
package contains the analytic bridge and the completed endpoint proof, which
also depend on PNT+. The directory name `research/` describes the dependency
boundary; it does not mean that the endpoint is still unproved.

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

there exists $`X_0=X_0(c)`$ such that, for every natural number $`X\ge X_0`$,

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
the chosen $`c`$.

The saving scale $`(\log X)^a/\log\log X`$ tends to infinity. Consequently, the
proportion $`C(X)/X`$ tends to zero at the displayed rate. As an asymptotic
consequence, the bound is eventually smaller than $`X/(\log X)^M`$ for every fixed
$`M\gt 0`$. However, the displayed upper bound itself still tends to infinity:
**this proves neither finiteness nor the nonexistence of candidates**, and it
does not construct an example. It is a sparsity result toward #647.

### Intermediate bounds retained in the proof

Put

```math
Q=\log X,\qquad L=\log\log X,\qquad H=\lfloor Q^a\rfloor.
```

For the project's selected prime cutoff $`y`$, define the prime mass and corrected
budget by

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
natural-number subtraction. For all sufficiently large $`X`$, the accepted estimates give

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

The last two contributions include the factorial truncation error, the amplified
arithmetic remainder, and the exceptional initial window. The final theorem
absorbs all of them into one exponential bound.

## How the proof works

### 1. Turn divisor restrictions into a budget for prime factors

Let $`\omega(m)`$ count the distinct prime divisors of a positive integer $`m`$.
The elementary inequality $`2^{\omega(m)}\le\tau(m)`$ means that a candidate with
$`n\gt H`$ has a bounded total number of prime-factor occurrences in the window
$`n-1,\ldots,n-H`$.

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
the number of candidates.

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

The reciprocal-prime estimates come from the project's formalized analytic
bridge to PNT+. They are proved inputs to the endpoint, not conjectural
prime-distribution assumptions.

### 4. Convert the gap into an exponential saving, including the errors

Set

```math
t=\frac1{1000L},\qquad z=1-t,\qquad
\eta=-\log(1-t),\qquad \mu=t\lambda.
```

In the nonnegative-budget case, the principal counting contribution is
$`X\exp(\eta B_H-\mu)`$. Using $`\eta\le t+t^2`$ for the eventual parameter range,
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

The finite library is useful independently of the asymptotic endpoint. For
natural numbers $`X,H\ge1`$, real $`y\gt H`$, $`0\lt z\lt 1`$, even natural $`J`$, and **any
integer translation $`A`$**, let $`T`$ be as above and set

```math
\mu=(1-z)H\sum_{\substack{H\lt p\le y\\p\ \mathrm{prime}}}\frac1p.
```

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

The accepted **v47 mathematical checkpoint** records:

| Check | Accepted result |
| --- | --- |
| Build, exact-type and axiom gates | **29/29 passed** |
| Distinct declarations with transitive axiom audits | **235** |
| Expanded type/definition checks | **194** |
| Build and audit diagnostics | **Zero warnings or errors** |
| Reported axioms | Only `propext`, `Classical.choice`, and `Quot.sound` |
| Final endpoint | General strict coefficient range and explicit $`c=1/1000`$ corollary |

This checkpoint completes the mathematical chain through final absorption.
It supersedes the earlier v45 amplified-error milestone and the pending status
of the initial v46 endpoint implementation.

The **v48 library-promotion changeset** moves seven Mathlib-only estimate modules
into the core and adds public analytic/endpoint facades. It introduces a
30th gate and requires its own **30/30 acceptance**. Historical v47 success does
not certify the changed package layout. See [proof status](docs/proof-status.md)
and [library promotion](docs/library-promotion-v48.md).

## Use the public library

```lean
import Erdos647Sieve

#check Erdos647Sieve.Candidate
#check Erdos647Sieve.finiteMoment
#check Erdos647Sieve.budgetDebit
#check Erdos647Sieve.finiteCounting

example : Erdos647Sieve.FiniteCountingClaim := Erdos647Sieve.finiteCounting
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
a Git dependency for the core. The dependent project must use a compatible
Lean/Mathlib pin. See the [examples](Examples/) and
[dependency boundaries](docs/dependency-boundaries.md).

## Build and check

System prerequisites: **Bash, Python 3.10+, Git, curl, tar, a C/C++ build toolchain,
unzip, zstd, and CA certificates**. Linux and macOS are supported by the wrapper;
on Windows use WSL. No Python packages, GPU, API key, or paid service is needed.
The first setup requires internet access to download the compiler and libraries.

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
cache is resumed automatically once the toolchain and checkouts exist. Compiler
and dependency installation still require `--setup`. Both manifests are parsed
by the installed Lake implementation before dependency/cache preparation.

### Choose the scope

| Command | Scope |
| --- | --- |
| `bash RUN.sh` or `bash TEST_ALL.sh` | All registered core and research gates, including the endpoint. |
| `bash RUN.sh core` | Public core, examples, expanded types and axiom audits; includes the promoted elementary checks in v48. No PNT+ setup required. |
| `bash RUN.sh research` | All registered research gates; core imports build as dependencies. |
| `bash RUN.sh --gate corrected_budget_estimate` | That gate and its registered prerequisites. |
| `bash RUN.sh tooling` | Offline runner/architecture tests only; not a Lean proof check. |
| `bash RUN.sh --list` | Gate inventory. |
| `bash RUN.sh --setup --refresh-cache` | Retry the matching Mathlib cache download. |
| `bash RUN.sh --jobs 4` | Set Lean worker-thread count. |

`--setup` can be combined with `core`, `research`, or `--gate`.
`bash RUN.sh core --setup` installs only the public core's dependencies.

Lake reuses unchanged build artifacts and rebuilds changed modules and their
dependents. Selected exact-type and transitive-axiom audits run again on every
invocation. The runner does not reuse a historical audit verdict, invoke
`lake clean`, or recreate the project between runs.

### Ordinary Lake interface

With the pinned toolchain available on `PATH`, the root also supports:

```bash
lake exe cache get
lake build
lake test
```

Here `lake test` checks the **public core only**. Inside `research/`, its own
`lake build` and `lake test` check the research package. The repository-wide
runner joins these scopes and continues independent gates after failures.
There is no recursive `lake test` invocation.

## Results and failure behavior

Every actual runner invocation creates a unique directory and ZIP under
`results/`, then prints `RESULTS ZIP: ...`. `results/latest_result.txt` records
the archive path. Reports include executed commands, exit codes, source and
configuration snapshots, dependency revisions, and available axiom output.
They do not collect caches, complete environment dumps, credential files, or
Git remote configuration. Log redaction is best-effort; reports should be
reviewed before public sharing.

| Exit code | Meaning |
| --- | --- |
| `0` | All selected gates passed. |
| `1` | A proof or audit failed, or a gate was blocked. |
| `2` | Setup or integrity failure. |
| `130` | Interruption. |

A failed prerequisite blocks downstream gates but leaves independent checks
running. Changes to Lean source, Lake configuration, scripts, or tests during
a run invalidate that run. CI workflow changes are recorded separately because
they do not affect the locally invoked proof commands. Setup failures remain
visible. A normal Ctrl+C still packages partial output; a machine crash can
leave a partial results directory. `--collect-only` reports the last completed
archive without making a new acceptance claim.

A failed full run is never converted to success because the core passed or a
historical checkpoint was green. Tooling tests alone do not certify a theorem.

## Repository layout

| Path | Purpose |
| --- | --- |
| `RUN.sh`, `TEST_ALL.sh` | Top-level incremental check entry points |
| `Erdos647Sieve/` | Finite library and public core facades |
| `Erdos647Sieve/Elementary/` | Seven promoted Mathlib-only estimate modules in v48 |
| `Audit/`, `Examples/` | Public exact-type/axiom checks and usage examples |
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
`Erdos647Research.*`. Theorem namespaces are preserved. The separate module
roots prevent Lean's first-root import resolution from finding a research
object in the core's build directory.

The original rejected `MertensProbe` is retained as text under
`provenance/rejected/` and is never imported or built. Legacy source relocation
applies only to overlays over v32/v33; a new checkout needs no migration.
Ordinary runs do not copy or rewrite source files or delete compiled caches.

## CI and further documentation

The core GitHub workflow builds and tests the public core. Its triggers are
controlled in `.github/workflows/ci.yml`; local checks do not rewrite them.
The full research workflow remains manually dispatched. Both upload diagnostics
and preserve failed check results. A successful local checkpoint and the CI
result for a particular commit are separate pieces of evidence.

- [Theorem statements](docs/theorems.md)
- [Proof status](docs/proof-status.md)
- [Final endpoint development](docs/final-endpoint-branch.md)
- [v48 library promotion](docs/library-promotion-v48.md)
- [Dependency boundaries](docs/dependency-boundaries.md)
- [Contributing](CONTRIBUTING.md)
- [Erdős problem #647: problem statement and references](https://www.erdosproblems.com/647)

The source is distributed with [LICENSE](LICENSE) and [NOTICE](NOTICE).
