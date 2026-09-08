/-
Growth comparisons for the arithmetic remainder and the exceptional window.
This module is independent of prime-mass estimates and the factorial tail.
-/
import Erdos647Research.Endpoint.CutoffParameters

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- Exact complementary-power identity at positive logarithmic arguments. -/
theorem window_complementary_scale_product (X : ℕ) (hX : 2 ≤ X) :
    Real.rpow (Real.log (X : ℝ)) endpointExponent *
      Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent) = Real.log (X : ℝ) := by
  have hQ : 0 < Real.log (X : ℝ) :=
    Real.log_pos (by exact_mod_cast (show 1 < X by omega))
  simp only [Real.rpow_eq_pow]
  rw [← Real.rpow_add hQ]
  simp

/-- H log log X = o(log X), using the preserved exponent a<1. -/
theorem window_mul_logLog_div_logX_tendsto_zero :
    Tendsto (fun X : ℕ => (windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) /
      Real.log (X : ℝ)) atTop (𝓝 0) := by
  have hsmall : Tendsto (fun X : ℕ => Real.log (Real.log (X : ℝ)) /
      Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)) atTop (𝓝 0) :=
    ((isLittleO_log_rpow_atTop (sub_pos.mpr endpointExponent_lt_one)).tendsto_div_nhds_zero).comp
      logX_tendsto_atTop
  have h : Tendsto (fun X : ℕ =>
      ((windowLength X : ℝ) / Real.rpow (Real.log (X : ℝ)) endpointExponent) *
        (Real.log (Real.log (X : ℝ)) /
          Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent))) atTop (𝓝 0) := by
    simpa using windowLength_ratio_tendsto_one.mul hsmall
  apply h.congr'
  filter_upwards [eventually_ge_atTop (2 : ℕ)] with X hX
  rw [div_mul_div_comm, window_complementary_scale_product X hX]

/-- The exceptional window is also negligible on the logarithmic scale. -/
theorem window_div_logX_tendsto_zero :
    Tendsto (fun X : ℕ => (windowLength X : ℝ) / Real.log (X : ℝ))
      atTop (𝓝 0) := by
  have h : Tendsto (fun X : ℕ =>
      ((windowLength X : ℝ) / Real.rpow (Real.log (X : ℝ)) endpointExponent) *
        (1 / Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent))) atTop (𝓝 0) := by
    simpa using windowLength_ratio_tendsto_one.mul
      (complementaryScale_tendsto_atTop.const_div_atTop (1 : ℝ))
  apply h.congr'
  filter_upwards [eventually_ge_atTop (2 : ℕ)] with X hX
  rw [div_mul_div_comm, mul_one, window_complementary_scale_product X hX]

/-- J log H = o(log X), with the exact rounded truncation order. -/
theorem truncation_log_window_div_logX_tendsto_zero :
    Tendsto (fun X : ℕ => (truncationOrder X : ℝ) * Real.log (windowLength X : ℝ) /
      Real.log (X : ℝ)) atTop (𝓝 0) := by
  have h : Tendsto (fun X : ℕ =>
      ((truncationOrder X : ℝ) / (windowLength X : ℝ)) *
        (Real.log (windowLength X : ℝ) / Real.log (Real.log (X : ℝ))) *
        ((windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) / Real.log (X : ℝ)))
      atTop (𝓝 0) := by
    simpa using (truncationOrder_div_windowLength_tendsto.mul
      log_windowLength_div_logLog_tendsto).mul window_mul_logLog_div_logX_tendsto_zero
  apply h.congr'
  filter_upwards [eventually_windowLength_pos,
    logLogX_tendsto_atTop.eventually (eventually_gt_atTop (0 : ℝ))] with X hH hL
  have hHR : (windowLength X : ℝ) ≠ 0 := by
    exact_mod_cast (show windowLength X ≠ 0 by omega)
  rw [div_mul_div_comm, div_mul_div_cancel₀ (mul_ne_zero hHR hL.ne')]

/-- An unconditional majorant for the logarithmic amplification overhead. -/
theorem arithmetic_overhead_div_logX_tendsto_zero :
    Tendsto (fun X : ℕ =>
      ((truncationOrder X : ℝ) * Real.log (windowLength X : ℝ) +
        (windowLength X : ℝ) / 500) / Real.log (X : ℝ)) atTop (𝓝 0) := by
  have h : Tendsto (fun X : ℕ =>
      (truncationOrder X : ℝ) * Real.log (windowLength X : ℝ) / Real.log (X : ℝ) +
        ((windowLength X : ℝ) / Real.log (X : ℝ)) / 500) atTop (𝓝 0) := by
    simpa using truncation_log_window_div_logX_tendsto_zero.add
      (window_div_logX_tendsto_zero.div_const 500)
  exact h.congr (fun X => by ring)

/-- A logarithmic bound for the exceptional H contribution. -/
theorem log_window_div_logX_tendsto_zero :
    Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ) / Real.log (X : ℝ))
      atTop (𝓝 0) := by
  have hsmall : Tendsto (fun X : ℕ =>
      Real.log (Real.log (X : ℝ)) / Real.log (X : ℝ)) atTop (𝓝 0) := by
    have hlog : Tendsto (fun u : ℝ => Real.log u / u) atTop (𝓝 0) := by
      simpa using Real.tendsto_pow_log_div_mul_add_atTop 1 0 1 (by norm_num)
    exact hlog.comp logX_tendsto_atTop
  have h : Tendsto (fun X : ℕ =>
      (Real.log (windowLength X : ℝ) / Real.log (Real.log (X : ℝ))) *
        (Real.log (Real.log (X : ℝ)) / Real.log (X : ℝ))) atTop (𝓝 0) := by
    simpa using log_windowLength_div_logLog_tendsto.mul hsmall
  apply h.congr'
  filter_upwards [logLogX_tendsto_atTop.eventually
    (eventually_gt_atTop (0 : ℝ))] with X hL
  rw [div_mul_div_cancel₀ hL.ne']

/-- The variable cutoff exponent is cancelled only after proving J is nonzero. -/
theorem primeCutoff_pow_truncation_eq (X : ℕ) (hX : 0 < X)
    (hJ : 0 < truncationOrder X) :
    primeCutoff X ^ truncationOrder X = Real.rpow (X : ℝ) ((1 : ℝ) / 4) := by
  have hJR : (truncationOrder X : ℝ) ≠ 0 := by exact_mod_cast hJ.ne'
  have hXR : 0 < (X : ℝ) := by exact_mod_cast hX
  calc
    primeCutoff X ^ truncationOrder X =
        Real.exp (Real.log (primeCutoff X ^ truncationOrder X)) :=
      (Real.exp_log (pow_pos (primeCutoff_pos X hX) _)).symm
    _ = Real.exp (Real.log (X : ℝ) / 4) := by
      rw [Real.log_pow, log_primeCutoff X hX]
      congr 1
      calc
        (truncationOrder X : ℝ) *
            (Real.log (X : ℝ) / (4 * (truncationOrder X : ℝ))) =
          (Real.log (X : ℝ) / 4) *
            ((truncationOrder X : ℝ) / (truncationOrder X : ℝ)) := by
          simp only [div_eq_mul_inv, mul_inv_rev]
          ring
        _ = Real.log (X : ℝ) / 4 := by rw [div_self hJR, mul_one]
    _ = Real.rpow (X : ℝ) ((1 : ℝ) / 4) := by
      rw [Real.rpow_eq_pow, Real.rpow_def_of_pos hXR]
      congr 1
      ring

end Erdos647Sieve.Endpoint
end
