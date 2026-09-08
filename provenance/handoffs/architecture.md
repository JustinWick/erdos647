# Erdős #647 Lean architecture simplification handoff

**Date:** 2026-09-08  
**Purpose:** simplify the current formalization into stable, usable boundaries without rewriting accepted mathematics or conflating proof-engineering cleanup with new progress on Erdős #647.

This handoff is about **architecture, packaging, interfaces, and maintainability**. It is not a new mathematical proof and does not promote any pending endpoint theorem.

---

## 1. Current checkpoint and design principle

The project has reached a point where the formal mathematics and the development infrastructure should be separated more aggressively.

The useful mathematical content now falls into three qualitatively different layers:

1. **Finite combinatorial/sieve core**
   - candidate predicate and exact finite definitions;
   - CRT/counting machinery;
   - hit-count and moment bounds;
   - budget bookkeeping;
   - the complete finite counting theorem.
   - This layer is essentially **Mathlib-only** and is the best candidate for a stable public Lean library.

2. **Analytic bridge**
   - reciprocal-log calculus;
   - PNT/integrability adapters;
   - replacement Mertens convergence;
   - selected-prime reciprocal mass and cutoff-error cancellation.
   - This layer currently depends on the pinned PNT+ development and should be isolated behind one explicit compatibility boundary.

3. **Endpoint research**
   - elementary debit and factorial estimates;
   - floor/ceiling parameter limits;
   - quantitative prime-mass versus budget gap;
   - growing truncation/factorial-tail estimates;
   - amplified error absorption;
   - the final asymptotic counting endpoint.
   - This layer is still research code and should not define the public stability boundary.

The central simplification rule is:

> **Do not rewrite accepted proofs merely because a cleaner abstraction exists. Simplify imports, package boundaries, adapters, facades, and workflow around them.**

Accepted source should be treated as a mathematical asset. Refactoring is justified only when it removes a real dependency, clarifies a reusable interface, or eliminates duplicated compatibility glue.

---

## 2. Primary architectural change: split the stable core from endpoint research

### 2.1 Stable package: `Erdos647Sieve`

Create a normal Lean/Lake library whose public purpose is the finite sieve and counting theorem.

It should have **no PNT+ dependency** and no imports from the endpoint research tree.

The public package should expose a deliberately small API. A reasonable starting surface is:

```lean
Erdos647Sieve.Candidate
Erdos647Sieve.finiteMoment
Erdos647Sieve.budgetDebit
Erdos647Sieve.finiteCounting
```

Do not rename these declarations merely for style. If nicer public names are desired, add aliases or wrapper theorems and keep the original declarations available.

The project should provide facade modules such as:

```lean
import Erdos647Sieve
```

or, if two levels are useful,

```lean
import Erdos647Sieve.Basic
import Erdos647Sieve.Finite
```

A user should not need to know the internal 20+ module import graph merely to use the finite theorem.

### 2.2 Analytic package: `Erdos647Sieve.Analytic`

Keep the existing analytic proof chain separate from the stable finite library.

This package may depend on:

- the stable finite/core package;
- the pinned PNT+ source;
- the matching Mathlib/Lean environment required by that PNT+ snapshot.

All PNT+-specific adaptation should be concentrated in a small boundary such as:

```text
Erdos647Sieve/Analytic/Compat/PNTPlus.lean
Erdos647Sieve/Analytic/ReciprocalKernel.lean
Erdos647Sieve/Analytic/CleanMertens.lean
Erdos647Sieve/Analytic/SelectedPrimeReciprocals.lean
```

The exact filenames do not matter as much as the dependency rule:

> **Only the compatibility/analytic layer should know the names and peculiarities of upstream PNT+ declarations.**

Do not spread direct PNT+ imports throughout endpoint modules.

### 2.3 Research package or repository: `Erdos647Endpoint`

The unfinished endpoint should be visibly experimental.

It should depend on the stable core and analytic layer, but neither of those packages should depend back on it.

Suggested namespace:

```lean
namespace Erdos647Sieve.Endpoint
```

Suggested content:

```text
Endpoint/
  Parameters.lean
  LogBounds.lean
  FactorialBounds.lean
  FactorialEstimate.lean
  PrimeReciprocalLower.lean
  SmallPrimeDebitEstimate.lean
  CorrectedBudgetEstimate.lean
  PrimeMassGap.lean
  MomentTail.lean
  AmplifiedErrors.lean
  Main.lean
```

`Main.lean` should eventually contain the endpoint theorem. Until it does, the stable package must not imply that the endpoint exists.

---

## 3. Repository strategy

### Recommended final shape: two repositories, or two independently versioned Lake packages

The cleanest long-term boundary is:

```text
erdos647-sieve/
    Mathlib-only stable library

erdos647-endpoint/
    current research development
    depends on erdos647-sieve
    contains PNT+ analytic bridge and endpoint work
```

Why not force everything into one Lake workspace?

Because the stable finite core and the analytic PNT+ layer have different versioning pressures. The finite source has already shown itself much more portable, while PNT+ ties the analytic development to a specific dependency stack. One workspace gives them a single dependency resolution and recreates the coupling that caused the recent migration detour.

### Initial release version

Do **not** make a toolchain upgrade part of the first extraction.

First make the stable core a clean package on the current working environment. Once it builds and audits from a clean checkout, port the **core-only repository** to the newest desired Lean/Mathlib release in a separate change.

The endpoint research repository may continue pinning its known-working Lean/Mathlib/PNT+ combination even after the core has a newer public release. It can depend on a compatible older tag of the core until its analytic dependencies are also ready to move.

---

## 4. What to preserve exactly

The implementation agent should assume the following are **not refactoring targets** unless compilation forces a change:

### 4.1 Mathematical definitions

Preserve the current intended meanings and signs of:

- `Candidate`;
- `Prefix`;
- `hitCount`;
- `logBudget`;
- `smallPrimeDebit`;
- `correctedBudget`;
- finite moment/counting claim structures;
- the protected endpoint parameter definitions.

In particular, do not turn the signed corrected budget into a natural subtraction merely to simplify types.

### 4.2 Accepted theorem statements

Do not strengthen, weaken, reorder quantifiers, or add assumptions to accepted finite or analytic declarations merely to make adapters easier.

If a new user-facing theorem is useful, prove it as a wrapper around the accepted declaration.

### 4.3 Accepted proof bodies

Do not perform style refactors inside accepted finite or analytic proofs during extraction.

Moving files, changing imports when demonstrably safe, and introducing facade modules are acceptable. Reproving an accepted theorem with different automation is not part of this cleanup.

### 4.4 Provenance

Do not delete old audit results, migration evidence, rejected experiments, or historical lockfiles.

Instead, move them out of the normal build path.

Suggested locations:

```text
provenance/
  accepted/
  historical-toolchains/
  rejected/
  migration/

docs/
  proof-status.md
  dependency-boundaries.md
```

The public source tree should be clean without pretending the research history never happened.

---

## 5. Simplify the module interfaces

This is the highest-value source-level cleanup after package extraction.

### 5.1 Add facade modules

Users should import a small number of modules.

Example:

```text
Erdos647Sieve.lean
Erdos647Sieve/Basic.lean
Erdos647Sieve/Finite.lean
```

`Finite.lean` should re-export only the finite theorem-facing modules.

Do not make users import implementation files such as CRT bookkeeping or subset-moment internals directly unless they actually want those lemmas.

### 5.2 Mark implementation modules as internal by convention

There is no need for a massive namespace rewrite.

A directory convention is enough:

```text
Erdos647Sieve/Internal/
```

Move only when doing so is mechanically safe. Otherwise leave source paths stable and treat the facade as the public boundary.

The first release does **not** need perfect internal organization.

### 5.3 Introduce wrappers where casts or upstream APIs leak

The project currently has several places where exact library presentation is irrelevant to the mathematics but expensive for downstream proofs.

Good candidates for tiny wrapper modules:

- natural-to-real factorial logarithm statements;
- floor/ceiling asymptotics;
- PNT+ reciprocal-error integrability;
- selected-prime cutoff cancellation;
- signed `Int` budget coercions.

The wrapper should expose the theorem in the exact project-specific form used repeatedly downstream.

For example, endpoint code should prefer a project theorem such as:

```lean
log_factorial_residual_tendsto_zero
```

over repeatedly unfolding the exact Mathlib Stirling sequence representation.

Likewise, endpoint modules should consume a project-level selected-prime limit, not upstream PNT+ internals.

### 5.4 One adapter per mismatch

Avoid long chains of one-off local `simpa`, `change`, and coercion repairs scattered across downstream theorems.

When the same mismatch appears twice, create one named adapter theorem at the boundary.

This applies especially to:

- function composition under limits/derivatives;
- real casts of natural factorials;
- floor/ceil expressions;
- `Nat` versus `Int` versus `ℝ` budget identities;
- PNT+ anonymous functions versus named project functions.

---

## 6. Simplify the endpoint research structure

The endpoint layer should be reorganized around mathematical obligations rather than the history of when a patch was written.

### 6.1 Group elementary estimates together

The factorial and budget work should form one coherent dependency chain:

```text
FactorialBounds
    ↓
FactorialEstimate
    ↓
LogBudgetFactorial
    ↓
CorrectedBudgetEstimate
```

The debit side should be a separate sibling chain:

```text
PrimeReciprocalLower
    ↓
SmallPrimeDebitEstimate
```

Then `CorrectedBudgetEstimate` combines the two.

This structure is much easier to understand than treating each historical overlay as its own stage.

### 6.2 Separate parameter asymptotics from arithmetic estimates

Create a dedicated module for:

- `windowLength`;
- `truncationOrder`;
- `primeCutoff`;
- `momentT`;
- `H → ∞`;
- `y → ∞`;
- eventual `H < y`;
- floor/ceiling ratio limits;
- `J/H → 1/50`;
- logarithmic asymptotics.

These facts should not be reproved opportunistically inside the final endpoint theorem.

### 6.3 Centralize numerical constants

Create a small `EndpointConstants.lean` or equivalent.

It should contain the kernel-checked inequalities actually required later, for example the positive gap involving:

```text
log(25/2) + 1/log 2 - 2
```

and the truncation-tail constant involving `log 20`.

Do not scatter numerical inequalities across unrelated proof files.

This also makes it obvious which constants are structural and which are artifacts of a proof choice.

### 6.4 Separate error-term lemmas by source

The final proof combines qualitatively different errors:

- finite CRT/discrepancy error;
- selected-prime cutoff error;
- factorial/moment tail;
- amplification multiplier;
- endpoint absorption.

Each should have a theorem with a clear asymptotic statement before they are combined.

The final endpoint theorem should read mostly as assembly, not as the place where five unrelated asymptotic estimates are first established.

---

## 7. Replace the custom runner as the normal user interface

The current runner has been valuable for migration, provenance, source synchronization, backup safety, and diagnostics. It should not remain the primary interface of a public Lean library.

### Stable repository

Normal user workflow should reduce to:

```text
lake build
lake test
```

or an equally standard pair of Lake targets.

Provide a checked-in `lean-toolchain`, `lakefile.toml`/`lakefile.lean`, and `lake-manifest.json`.

### Audit target

Keep the exact-type and axiom checks, but make them ordinary project artifacts.

For example:

```text
Audit/
  Finite.lean
  Analytic.lean
```

or a Lake script that executes files containing:

```lean
example : <exact exported theorem type> := Erdos647Sieve.finiteCounting
#print axioms Erdos647Sieve.finiteCounting
```

The audit logic should remain strict:

Allowed transitive axioms:

```text
propext
Classical.choice
Quot.sound
```

Anything else, especially `sorryAx`, is a failure.

### Migration runner

Move the current custom migration/overlay machinery under something like:

```text
tools/migration/
```

or preserve it only in the research repository.

It may remain useful for this project, but importing and using the mathematical library must not require understanding it.

---

## 8. GitHub/CI simplification

The public core repository should have a very small CI story.

### Required checks

On every pull request:

1. build the package;
2. run the exported-theorem exact-type checks;
3. run the axiom audit;
4. optionally build example files.

Do not run endpoint research or PNT+ compatibility checks in the stable core repository because those dependencies should not exist there.

### Version policy

For the first extraction, pin one exact known-working toolchain.

After that, version upgrades should happen as explicit compatibility changes, not automatically.

A useful policy is:

```text
main = current supported release
release/<older-version> = older reproducible checkpoint if needed
```

Do not create a matrix of many Lean versions unless there is a real user need.

---

## 9. Documentation simplification

The README should answer four questions immediately.

### What is this?

A Lean formalization of finite sieve/counting results motivated by Erdős problem #647.

### What is actually proved?

List the exported declarations and give short mathematical descriptions.

### What is not proved?

State prominently:

> This library does not resolve Erdős problem #647 and does not currently contain the proposed final asymptotic endpoint theorem.

### How do I use it?

Give one minimal import and one theorem-use example.

The README should not begin with migration history, failed toolchains, or the sequence of diagnostic ZIPs.

Put research history elsewhere.

---

## 10. Add examples as a usability test

Create one or two small files under:

```text
Examples/
```

They should compile using only the public facade.

For example:

```lean
import Erdos647Sieve.Finite

#check Erdos647Sieve.finiteMoment
#check Erdos647Sieve.finiteCounting
```

A stronger example should instantiate a harmless finite parameter choice or derive a simple consequence without importing internal modules.

These files serve as both documentation and a guard against accidentally exposing a fragile public interface.

---

## 11. What should not be generalized yet

Avoid turning every project-specific theorem into a generic Mathlib-style abstraction during this cleanup.

In particular, do not delay release in order to:

- create a universal finite sieve framework;
- generalize every CRT lemma to arbitrary semirings;
- abstract every moment estimate over arbitrary weight functions;
- upstream project lemmas to Mathlib;
- redesign the entire arithmetic API;
- replace current proofs with theoretically prettier proofs.

Some internal results may later deserve generalization. First establish a small stable package that people can actually build and inspect.

---

## 12. Treatment of old or rejected paths

### Rejected Mertens probe

Any source whose transitive axiom closure contains `sorryAx` must remain clearly rejected and outside the normal build/import graph.

Do not “fix” such a historical result by broadening the axiom allowlist.

### Old migration patches

Retain patches and logs for provenance, but they should not be imported by current source and should not affect a fresh checkout.

### Earlier toolchain checkpoints

Preserve them as historical evidence, not as alternate live environments embedded in the public repository.

---

## 13. Concrete implementation sequence

An implementation agent should work in this order.

### Phase A — extract without refactoring proofs

1. Copy the exact current stable finite source closure into a fresh Lake library.
2. Remove PNT+ from that project's dependency graph.
3. Add a single public facade module.
4. Add exact-type and axiom audit files for the exported declarations.
5. Add minimal examples.
6. Build from a clean checkout.
7. Compare all exported theorem statements and axiom reports with the accepted checkpoint.

**Acceptance criterion:** the stable core is reproducible independently of the research repository.

### Phase B — clean the research dependency boundary

1. Make the endpoint repository depend on the extracted core package.
2. Remove duplicate copies of stable core sources after equivalence is checked.
3. Put PNT+ adaptation behind one analytic compatibility module/directory.
4. Ensure endpoint source imports project-level analytic results, not raw upstream APIs.
5. Keep the current working analytic toolchain pinned.

**Acceptance criterion:** changes to PNT+ compatibility cannot affect the finite package.

### Phase C — reorganize endpoint modules

1. Group factorial/budget lemmas into the dependency chain described above.
2. Add `Parameters.lean`.
3. Add `EndpointConstants.lean`.
4. Give each asymptotic/error source a named theorem.
5. Keep `Main.lean` as assembly only.

**Acceptance criterion:** an independent reader can identify every remaining endpoint obligation from imports and theorem names without reading migration history.

### Phase D — port the stable core

Only after Phase A is reproducible:

1. update Lean and Mathlib in the **core-only** repository;
2. fix imports/API presentation without altering theorem content;
3. rebuild and re-audit;
4. make that a separately reviewable change.

Do not couple this with a PNT+ port.

---

## 14. Acceptance checklist for the architecture cleanup

The cleanup is complete when all of the following hold.

### Stable core

- [ ] Core has no PNT+ dependency.
- [ ] Fresh checkout builds with ordinary Lake commands.
- [ ] A facade module exposes the intended public API.
- [ ] `finiteMoment`, `budgetDebit`, and `finiteCounting` retain their intended exact types.
- [ ] Exported theorem axiom closures contain only the permitted axioms.
- [ ] At least one example compiles using only public imports.
- [ ] README states clearly that #647 is not solved.

### Analytic/research boundary

- [ ] PNT+ imports are localized.
- [ ] Core does not import analytic or endpoint source.
- [ ] Endpoint consumes project-level analytic wrappers.
- [ ] Experimental modules are not re-exported from the stable facade.
- [ ] The current working research toolchain remains reproducible.

### Endpoint organization

- [ ] Factorial and debit estimates are separated into coherent chains.
- [ ] Parameter limits live in a dedicated module.
- [ ] Numerical constants are centralized.
- [ ] Error terms have individual asymptotic lemmas.
- [ ] The final endpoint theorem, when written, is primarily an assembly theorem.
- [ ] Pending source is never described as accepted merely because it exists or compiles upstream.

### Provenance

- [ ] Historical evidence is retained outside the normal import graph.
- [ ] Rejected `sorryAx` paths remain rejected.
- [ ] Toolchain migrations are explicit versioned changes.
- [ ] No acceptance claim is inferred from packaging or CI configuration alone.

---

## 15. Stop conditions

Do not let architecture cleanup become another indefinite branch of the research project.

Stop refactoring when:

1. the finite core is independently buildable and audited;
2. the analytic dependency is localized;
3. endpoint obligations have clear module boundaries;
4. a reader can use the core without learning the migration system.

After that, return to mathematics.

Do not spend time polishing internal names, moving every legacy file, or generalizing lemmas unless the change directly reduces proof friction in the remaining endpoint.

---

## 16. Expected payoff

This restructuring does not make the finite theorem mathematically stronger. Its value is that it changes the project from one large historical research workspace into:

```text
stable reusable mathematics
        ↓
isolated analytic dependency
        ↓
explicit experimental endpoint
```

That should produce three practical benefits:

1. **Reviewability:** another Lean user can inspect the proved contribution without wading through migration infrastructure.
2. **Portability:** the Mathlib-only core can be upgraded independently of PNT+.
3. **Research velocity:** endpoint work can rely on small stable interfaces rather than reopening accepted finite proofs or upstream compatibility details.

The guiding principle for future work should be:

> **Simplify across boundaries first. Rewrite mathematics last.**

---

## 17. Source basis and status boundary

This architecture handoff builds on the existing endpoint-library reconnaissance, which explicitly recommends reusing existing Mathlib ingredients instead of rebuilding factorial, Euler-product, rounding, and asymptotic machinery. It also follows the broader dependency-inventory principle that already accepted project work should be preserved rather than replaced solely because a newer or more generic proof exists upstream.

The current project state additionally includes a later working native PNT+ dependency checkpoint and subsequent endpoint-adapter work. Those later project facts are part of the current development history, not claims established by the earlier reconnaissance document itself.

This document proposes **how to reorganize that work**. It does not independently verify theorem correctness, novelty, or the final Erdős #647 endpoint.
