/-
Normalize the accepted amplified-error majorant by the fixed-c endpoint RHS.
Every contribution tends to zero for c strictly below the existing principal
rate. No tuning of the protected parameters or numerical approximation is used.
-/
import Erdos647Research.Endpoint.AbsorptionScales

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- Exactly the three-term majorant from the accepted all-sign counting reduction. -/
def amplifiedErrorMajorant (X : ℕ) : ℝ :=
  (X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
    ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ)))) +
  (X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30) +
  2 * Real.exp (Real.log (X : ℝ) / 2)

/-- Cancel the common interval length before comparing two exponential rates. -/
theorem scaled_exp_div_endpointRHSWith (c u : ℝ) (X : ℕ) (hX : 0 < X) :
    ((X : ℝ) * Real.exp u) / endpointRHSWith c X =
      Real.exp (u + c * endpointScale X) := by
  have hXR : (X : ℝ) ≠ 0 := by exact_mod_cast hX.ne'
  rw [endpointRHSWith, mul_div_mul_left _ _ hXR, ← Real.exp_sub]
  congr 1
  ring

/-- The interval-length denominator contributes minus log X to the exponent. -/
theorem exp_div_endpointRHSWith (c u : ℝ) (X : ℕ) (hX : 0 < X) :
    Real.exp u / endpointRHSWith c X =
      Real.exp (u - Real.log (X : ℝ) + c * endpointScale X) := by
  have hXR : 0 < (X : ℝ) := by exact_mod_cast hX
  have hd : endpointRHSWith c X =
      Real.exp (Real.log (X : ℝ) - c * endpointScale X) := by
    unfold endpointRHSWith
    rw [sub_eq_add_neg, Real.exp_add, Real.exp_log hXR]
  rw [hd, ← Real.exp_sub]
  congr 1
  ring

/-- The strict principal-rate margin absorbs rounding of H and any fixed factor. -/
theorem principal_ratio_tendsto_zero (c : ℝ) (hc : c < (1499 / 1000000 : ℝ)) :
    Tendsto (fun X : ℕ =>
      ((X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
        ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ))))) /
          endpointRHSWith c X) atTop (𝓝 0) := by
  have hcoef : Tendsto (fun X : ℕ => c - (1499 / 1000000 : ℝ) *
      ((windowLength X : ℝ) / Real.rpow (Real.log (X : ℝ)) endpointExponent))
      atTop (𝓝 (c - (1499 / 1000000 : ℝ))) := by
    simpa only [mul_one] using
      (windowLength_ratio_tendsto_one.const_mul (1499 / 1000000 : ℝ)).const_sub c
  have h := Real.tendsto_exp_atBot.comp
    (hcoef.neg_mul_atTop (sub_neg.mpr hc) endpointScale_tendsto_atTop)
  apply h.congr'
  filter_upwards [eventually_ge_atTop (2 : ℕ)] with X hX
  have hXN : 0 < X := by omega
  have hQ : 0 < Real.log (X : ℝ) :=
    Real.log_pos (by exact_mod_cast (show 1 < X by omega))
  have hU : Real.rpow (Real.log (X : ℝ)) endpointExponent ≠ 0 :=
    (Real.rpow_pos_of_pos hQ _).ne'
  rw [scaled_exp_div_endpointRHSWith c _ X hXN]
  change Real.exp ((c - (1499 / 1000000 : ℝ) *
    ((windowLength X : ℝ) / Real.rpow (Real.log (X : ℝ)) endpointExponent)) *
      endpointScale X) = _
  congr 1
  have hcancel : ((windowLength X : ℝ) /
      Real.rpow (Real.log (X : ℝ)) endpointExponent) * endpointScale X =
      (windowLength X : ℝ) / Real.log (Real.log (X : ℝ)) := by
    dsimp only [endpointScale]
    exact div_mul_div_cancel₀ hU
  rw [sub_mul, mul_assoc, hcancel]
  ring

/-- The factorial tail is negligible relative to every fixed-c endpoint scale. -/
theorem momentTail_ratio_tendsto_zero (c : ℝ) :
    Tendsto (fun X : ℕ =>
      ((X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30)) /
        endpointRHSWith c X) atTop (𝓝 0) := by
  have hcoef : Tendsto (fun X : ℕ =>
      c * (endpointScale X / (windowLength X : ℝ)) - (1 / 30 : ℝ))
      atTop (𝓝 (-(1 / 30 : ℝ))) := by
    simpa only [mul_zero, zero_sub] using
      (endpointScale_div_window_tendsto_zero.const_mul c).sub_const (1 / 30 : ℝ)
  have h := Real.tendsto_exp_atBot.comp
    (hcoef.neg_mul_atTop (by norm_num) windowLength_cast_tendsto_atTop)
  apply h.congr'
  filter_upwards [eventually_ge_atTop (1 : ℕ), eventually_windowLength_pos] with X hX hH
  have hXR : 0 < X := by omega
  have hHR : (windowLength X : ℝ) ≠ 0 := by
    exact_mod_cast (show windowLength X ≠ 0 by omega)
  rw [scaled_exp_div_endpointRHSWith c _ X hXR]
  change Real.exp ((c * (endpointScale X / (windowLength X : ℝ)) - (1 / 30 : ℝ)) *
      (windowLength X : ℝ)) = _
  congr 1
  rw [sub_mul, mul_assoc, div_mul_cancel₀ _ hHR]
  ring

/-- The square-root majorant is negligible relative to every fixed-c endpoint. -/
theorem squareRoot_ratio_tendsto_zero (c : ℝ) :
    Tendsto (fun X : ℕ => Real.exp (Real.log (X : ℝ) / 2) /
      endpointRHSWith c X) atTop (𝓝 0) := by
  have hcoef : Tendsto (fun X : ℕ =>
      c * (endpointScale X / Real.log (X : ℝ)) - (1 / 2 : ℝ))
      atTop (𝓝 (-(1 / 2 : ℝ))) := by
    simpa only [mul_zero, zero_sub] using
      (endpointScale_div_logX_tendsto_zero.const_mul c).sub_const (1 / 2 : ℝ)
  have h := Real.tendsto_exp_atBot.comp
    (hcoef.neg_mul_atTop (by norm_num) logX_tendsto_atTop)
  apply h.congr'
  filter_upwards [eventually_ge_atTop (2 : ℕ)] with X hX
  have hXN : 0 < X := by omega
  have hQ : Real.log (X : ℝ) ≠ 0 :=
    (Real.log_pos (by exact_mod_cast (show 1 < X by omega))).ne'
  rw [exp_div_endpointRHSWith c _ X hXN]
  change Real.exp ((c * (endpointScale X / Real.log (X : ℝ)) - (1 / 2 : ℝ)) *
      Real.log (X : ℝ)) = _
  congr 1
  rw [sub_mul, mul_assoc, div_mul_cancel₀ _ hQ]
  ring

/-- The full majorant, including the factor two, divided by the target tends to zero. -/
theorem amplifiedErrorMajorant_ratio_tendsto_zero
    (c : ℝ) (hc : c < (1499 / 1000000 : ℝ)) :
    Tendsto (fun X : ℕ => amplifiedErrorMajorant X / endpointRHSWith c X)
      atTop (𝓝 0) := by
  have h := ((principal_ratio_tendsto_zero c hc).add
    (momentTail_ratio_tendsto_zero c)).add ((squareRoot_ratio_tendsto_zero c).const_mul 2)
  simpa only [amplifiedErrorMajorant, add_div, mul_div_assoc, add_zero, mul_zero] using h

/-- One eventual comparison absorbs the entire sum with no residual prefactor. -/
theorem eventually_amplifiedErrorMajorant_le_endpointRHSWith
    (c : ℝ) (hc : c < (1499 / 1000000 : ℝ)) :
    ∀ᶠ X : ℕ in atTop, amplifiedErrorMajorant X ≤ endpointRHSWith c X := by
  have hsmall := (amplifiedErrorMajorant_ratio_tendsto_zero c hc).eventually
    (gt_mem_nhds (by norm_num : (0 : ℝ) < 1))
  filter_upwards [hsmall, eventually_ge_atTop (1 : ℕ)] with X hX hpos
  have hd := endpointRHSWith_pos c X (by omega)
  exact (div_le_one hd).mp hX.le

end Erdos647Sieve.Endpoint
end
