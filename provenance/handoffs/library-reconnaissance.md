# Lean-library handoff: remaining Erdős #647 endpoint work

**Research date:** September 6, 2026. **Scope:** debit/factorial estimates, logarithmic constants, parameter limits, and amplified errors. The finite theorem and replacement Mertens/selected-prime bridge are already accepted in the project; do not rebuild them.

**Recommendation:** most useful ingredients already exist in the project's pinned Mathlib. Keep Lean `v4.28.0-rc1` and Mathlib `5352afccd6866369be9de43f5b7ec47203555f44`. All Mathlib links below point to that exact commit; declarations and relevant proof bodies were inspected, but **no new Lean compilation or axiom audit was run**. Application steps below are proposed deductions, not newly verified project lemmas.

## 1. Factorial estimate: reuse Stirling instead of implementing it

Import [`Mathlib.Analysis.SpecialFunctions.Stirling`][stirling]. Useful declarations in namespace `Stirling`:

- `log_stirlingSeq_formula`
- `log_stirlingSeq'_antitone`
- `log_stirlingSeq_bounded_by_constant`
- `le_log_factorial_stirling` (requires `n ≠ 0`)
- `factorial_isEquivalent_stirling`

**Why useful:** the exact logarithmic formula, the antitone upper bound, and the constant lower bound give
\[
\log(n!)=n\log n-n+\tfrac12\log(2n)+O(1).
\]
Substitute `n=H+2`, subtract `log 2`, and bound the shift to obtain the required `H log H − H + O(log H)`. This preserves the critical **−H** term without proving integral estimates for factorials. The explicit lower bound `le_log_factorial_stirling` also supports the factorial-tail estimate when its numerator grows with X.

Current documentation contains newer refinements; do not assume those names/signatures exist at our pin. The ingredients listed above do.

## 2. Debit estimate: the finite Euler-product machinery is already available

Import [`Mathlib.NumberTheory.EulerProduct.Basic`][euler] and [`Mathlib.NumberTheory.Harmonic.Bounds`][harmonic]. The most useful interface is

```lean
EulerProduct.summable_and_hasSum_smoothNumbers_prod_primesBelow_geometric
```

It takes a multiplicative map `f : ℕ →* ℝ` with `‖f p‖ < 1` for primes and supplies the sum over N-smooth integers as the finite Euler product over primes **strictly below N**. Set `f n = (n : ℝ)⁻¹` and `N=H+1`; compare the nonnegative subseries indexed by `1,…,H` using `sum_le_hasSum`.

**Important trap:** do **not** choose the adjacent `prod_primesBelow_geometric_eq_tsum_smoothNumbers` convenience theorem: it assumes global `Summable f`, which is false for `1/n`. The longer `summable_and_hasSum...` theorem only needs convergence of the prime-power geometric series.

`log_add_one_le_harmonic` and `harmonic_eq_sum_Icc` provide the harmonic comparison directly; `harmonic` is rational-valued, so its cast to ℝ needs attention.

**Proposed assembly:** finite Euler product ≥ harmonic sum ≥ log H; bound each logarithmic Euler-factor remainder by `1/(p*(p−1))`; telescope its sum to ≤1. This gives `∑_{p≤H}1/p ≥ log(log H)−1`. Then `floor(H/p) ≥ H/p−1` and `#{p≤H}≤H` give the required `D_H ≥ H(log(log H)−2)`. The project-specific assembly still needs proof.

**Useful external worked example:** [`LongGapsBetweenPrimes.sum_smooth_le_eulerProduct` and `log_le_eulerProduct_one`][longgaps] already implement the first comparison using that Mathlib theorem. Port these small proof patterns rather than the whole project. Its [toolchain is Lean 4.33.0][longgaps-toolchain], not our pin, so compatibility and transitive axioms must be rechecked; this is a source reference, not a verified drop-in dependency.

## 3. Logarithmic remainders and the numerical gaps

[`Mathlib.Analysis.SpecialFunctions.Complex.LogBounds`][logbounds] contains

```lean
Complex.norm_log_one_sub_inv_sub_self_le
```

For `‖z‖<1`, it proves
\[
\|\log((1-z)^{-1})-z\|\le\frac{\|z\|^2}{2(1-\|z\|)}.
\]
Embed real `0≤t≤1/2`, justify the positive-real logarithm/cast identities, and obtain `−log(1−t)≤t+t²`. At `t=1/p`, the same result is more than sufficient for the Euler-factor remainder in §2. There is no need to develop a new logarithm series, although the real/complex conversion is a genuine wrapper obligation.

[`Mathlib.Analysis.Complex.ExponentialBounds`][constants] provides exact proved bounds `Real.log_two_gt_d9` and `Real.log_two_lt_d9`. Coarsen these to `0.693 < log 2 < 0.7`.

**Shorter constant proofs:** monotonicity gives `log(25/2)>log 8=3 log 2` and `log 20>log 16=4 log 2`. Those bounds already suffice for **both** required inequalities
\[
\log(25/2)+1/\log2-2>3/2,
\qquad (\log20-1)/50-1/500>1/30.
\]
Thus separate numerical approximations to log 5 or log 20 are unnecessary. Use rational inequalities and kernel-checked tactics, not floating-point certificates.

## 4. Floor/ceiling parameter limits: direct library matches

[`Mathlib.Analysis.SpecificLimits.Basic`][rounding] supplies these **root-namespace** declarations:

```lean
tendsto_nat_floor_atTop
tendsto_nat_floor_div_atTop
tendsto_nat_ceil_mul_div_atTop
tendsto_nat_ceil_div_atTop
tendsto_mod_div_atTop_nhds_zero_nat
```

Compose the floor-ratio theorem with `(log X)^a` to get `H/(log X)^a → 1`. The scaled ceiling theorem with scale `1/100`, multiplied by 2, supplies `J/H → 1/50` **after proving** that the protected natural expression `2*((H+99)/100)` equals the ceiling expression. Keep that discrete bridge explicit; the real limit theorem does not prove it automatically.

## 5. Growth comparisons and amplified-error absorption

Import [`Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics`][growth]. Particularly useful **root-namespace** names:

```lean
tendsto_rpow_atTop
isLittleO_log_rpow_atTop
isLittleO_log_rpow_rpow_atTop
isLittleO_exp_mul_rpow_of_lt
tendsto_rpow_mul_exp_neg_mul_atTop_nhds_zero
```

These handle positive-power divergence, logarithmic powers versus positive powers, and polynomial factors versus exponential decay. Compose them with `Q=log X` or other proved-divergent parameters, and work with logarithms/ratios of the amplified errors. They are ingredients, not a ready-made proof for our variable exponent `y=X^(1/(4J))` or the final constant-sensitive gap.

Avoid applying a theorem for **fixed** `c^n/n!→0` to the growing numerator `μ(X)`: use the Stirling lower bound and a proved uniform control of `μ/(J+1)` instead.

## Suggested order and acceptance boundary

Start with Stirling-derived factorial bounds and the two numerical gaps (shortest wrappers), then finish the debit/Euler-product assembly and parameter limits. Preserve every protected definition and the endpoint coefficient. Reuse the already accepted selected-prime limit only after its cutoff hypotheses are proved.

These inspected sources do not supply the project-specific endpoint assembly. Add independent exact-type/`#print axioms` gates; permit only `propext`, `Classical.choice`, and `Quot.sound`. Source inspection is not an axiom audit. Keep the existing toolchain/cache and overlay workflow; no Mathlib upgrade is needed for §§1–5.

[stirling]: https://github.com/leanprover-community/mathlib4/blob/5352afccd6866369be9de43f5b7ec47203555f44/Mathlib/Analysis/SpecialFunctions/Stirling.lean
[euler]: https://github.com/leanprover-community/mathlib4/blob/5352afccd6866369be9de43f5b7ec47203555f44/Mathlib/NumberTheory/EulerProduct/Basic.lean#L293-L330
[harmonic]: https://github.com/leanprover-community/mathlib4/blob/5352afccd6866369be9de43f5b7ec47203555f44/Mathlib/NumberTheory/Harmonic/Bounds.lean
[longgaps]: https://github.com/openai/LongGapsBetweenPrimes/blob/03a1190d0bc5502d9f54eeb60ad3e45e22b0df0b/LongGapsBetweenPrimes.lean#L976-L1001
[longgaps-toolchain]: https://github.com/openai/LongGapsBetweenPrimes/blob/03a1190d0bc5502d9f54eeb60ad3e45e22b0df0b/lean-toolchain
[logbounds]: https://github.com/leanprover-community/mathlib4/blob/5352afccd6866369be9de43f5b7ec47203555f44/Mathlib/Analysis/SpecialFunctions/Complex/LogBounds.lean#L235-L241
[constants]: https://github.com/leanprover-community/mathlib4/blob/5352afccd6866369be9de43f5b7ec47203555f44/Mathlib/Analysis/Complex/ExponentialBounds.lean
[rounding]: https://github.com/leanprover-community/mathlib4/blob/5352afccd6866369be9de43f5b7ec47203555f44/Mathlib/Analysis/SpecificLimits/Basic.lean#L705-L770
[growth]: https://github.com/leanprover-community/mathlib4/blob/5352afccd6866369be9de43f5b7ec47203555f44/Mathlib/Analysis/SpecialFunctions/Pow/Asymptotics.lean
