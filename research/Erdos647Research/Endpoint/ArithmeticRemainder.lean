/-
The full amplified CRT remainder and the exceptional initial window.
Square-root-scale upper bounds are sufficient; no coefficient is optimized.
-/
import Erdos647Research.Endpoint.Amplification
import Erdos647Research.Endpoint.ErrorScales

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- Exact logarithmic form of the arithmetic remainder, with its multiplier. -/
theorem amplified_arithmetic_remainder_eq (X : ℕ) (hX : 0 < X)
    (hH : 0 < windowLength X) (hJ : 0 < truncationOrder X) :
    Real.exp (amplificationExponent X) *
      ((windowLength X : ℝ) * primeCutoff X) ^ truncationOrder X =
      Real.exp (Real.log (X : ℝ) / 4 +
        (truncationOrder X : ℝ) * Real.log (windowLength X : ℝ) +
        amplificationExponent X) := by
  have hHR : 0 < (windowLength X : ℝ) := by exact_mod_cast hH
  have hXR : 0 < (X : ℝ) := by exact_mod_cast hX
  have hh : (windowLength X : ℝ) ^ truncationOrder X =
      Real.exp ((truncationOrder X : ℝ) * Real.log (windowLength X : ℝ)) := by
    calc
      _ = Real.exp (Real.log ((windowLength X : ℝ) ^ truncationOrder X)) :=
        (Real.exp_log (pow_pos hHR _)).symm
      _ = _ := by rw [Real.log_pow]
  have hy : primeCutoff X ^ truncationOrder X = Real.exp (Real.log (X : ℝ) / 4) := by
    rw [primeCutoff_pow_truncation_eq X hX hJ,
      Real.rpow_eq_pow, Real.rpow_def_of_pos hXR]
    congr 1
    ring
  rw [mul_pow, hh, hy, ← Real.exp_add, ← Real.exp_add]
  congr 1
  ring

/-- The exponent overhead is eventually at most a quarter of log X. -/
theorem eventually_arithmetic_overhead_le :
    ∀ᶠ X : ℕ in atTop,
      (truncationOrder X : ℝ) * Real.log (windowLength X : ℝ) +
        (windowLength X : ℝ) / 500 ≤ Real.log (X : ℝ) / 4 := by
  have hsmall := arithmetic_overhead_div_logX_tendsto_zero.eventually
    (gt_mem_nhds (by norm_num : (0 : ℝ) < 1 / 4))
  filter_upwards [hsmall, logX_tendsto_atTop.eventually
    (eventually_gt_atTop (0 : ℝ))] with X hs hQ
  have h := (div_lt_iff₀ hQ).mp hs
  linarith

/-- The complete arithmetic term is at most exp(log X/2), not merely the
unamplified CRT remainder. The nonnegative-budget counting branch is explicit. -/
theorem eventually_amplified_arithmetic_remainder_le :
    ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      Real.exp (amplificationExponent X) *
        ((windowLength X : ℝ) * primeCutoff X) ^ truncationOrder X ≤
        Real.exp (Real.log (X : ℝ) / 2) := by
  filter_upwards [eventually_amplification_exponents_le, eventually_arithmetic_overhead_le,
    eventually_ge_atTop (1 : ℕ), eventually_windowLength_pos, eventually_truncationOrder_pos]
    with X hA ho hX hH hJ hB
  rw [amplified_arithmetic_remainder_eq X (by omega) (by omega) (by omega)]
  apply Real.exp_le_exp.mpr
  linarith [(hA hB).1]

/-- The initial exceptional window has the same harmless square-root-scale bound. -/
theorem eventually_exceptional_window_le :
    ∀ᶠ X : ℕ in atTop,
      (windowLength X : ℝ) ≤ Real.exp (Real.log (X : ℝ) / 2) := by
  have hsmall := log_window_div_logX_tendsto_zero.eventually
    (gt_mem_nhds (by norm_num : (0 : ℝ) < 1 / 2))
  filter_upwards [hsmall, eventually_windowLength_pos, logX_tendsto_atTop.eventually
    (eventually_gt_atTop (0 : ℝ))] with X hs hH hQ
  have hHR : 0 < (windowLength X : ℝ) := by
    exact_mod_cast (show 0 < windowLength X by omega)
  have hlog : Real.log (windowLength X : ℝ) ≤ Real.log (X : ℝ) / 2 := by
    have h := (div_lt_iff₀ hQ).mp hs
    linarith
  calc
    (windowLength X : ℝ) = Real.exp (Real.log (windowLength X : ℝ)) :=
      (Real.exp_log hHR).symm
    _ ≤ Real.exp (Real.log (X : ℝ) / 2) := Real.exp_le_exp.mpr hlog

end Erdos647Sieve.Endpoint
end
