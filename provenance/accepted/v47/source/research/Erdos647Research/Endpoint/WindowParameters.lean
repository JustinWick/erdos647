/-
Endpoint parameter layer: the protected exponent and rounded window length.
No analytic estimate or cutoff-growth hypothesis is assumed here.
-/
import Erdos647Sieve.Specification

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- Normalize the explicit real-power function before applying logarithm rules.
This shared adapter retains the exact exponent, including negative exponents. -/
theorem log_div_rpow_eq (u v r : ℝ) (hu : u ≠ 0) (hv : 0 < v) :
    Real.log (u / Real.rpow v r) = Real.log u - r * Real.log v := by
  rw [Real.rpow_eq_pow, Real.log_div hu (Real.rpow_pos_of_pos hv r).ne',
    Real.log_rpow hv]

/-- The critical exponent is strictly positive. -/
theorem endpointExponent_pos : 0 < endpointExponent := by
  have hl : 0 < Real.log 2 := Real.log_pos (by norm_num)
  unfold endpointExponent
  positivity

/-- The window grows slower than the logarithmic scale. -/
theorem endpointExponent_lt_one : endpointExponent < 1 := by
  have hl : 0 < Real.log 2 := Real.log_pos (by norm_num)
  unfold endpointExponent
  apply (div_lt_one (by linarith : 0 < 1 + Real.log 2)).mpr
  linarith

/-- The exact cancellation defining the critical exponent. -/
theorem endpointExponent_cancellation :
    endpointExponent / Real.log 2 = 1 - endpointExponent := by
  have hl : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hd : 0 < 1 + Real.log 2 := by linarith
  unfold endpointExponent
  calc
    (Real.log 2 / (1 + Real.log 2)) / Real.log 2 =
        (Real.log 2 / Real.log 2) / (1 + Real.log 2) := by ring
    _ = 1 / (1 + Real.log 2) := by rw [div_self hl.ne']
    _ = 1 - Real.log 2 / (1 + Real.log 2) := by
      apply (eq_sub_iff_add_eq).mpr
      rw [← add_div, div_self hd.ne']

/-- The logarithmic scale along natural interval lengths. -/
theorem logX_tendsto_atTop :
    Tendsto (fun X : ℕ => Real.log (X : ℝ)) atTop atTop :=
  Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop

/-- The iterated logarithm also diverges. -/
theorem logLogX_tendsto_atTop :
    Tendsto (fun X : ℕ => Real.log (Real.log (X : ℝ))) atTop atTop :=
  Real.tendsto_log_atTop.comp logX_tendsto_atTop

/-- The unrounded window scale tends to infinity. -/
theorem windowScale_tendsto_atTop :
    Tendsto (fun X : ℕ => Real.rpow (Real.log (X : ℝ)) endpointExponent)
      atTop atTop :=
  (tendsto_rpow_atTop endpointExponent_pos).comp logX_tendsto_atTop

/-- The exact natural floor in `windowLength` tends to infinity. -/
theorem windowLength_tendsto_atTop : Tendsto windowLength atTop atTop := by
  exact tendsto_nat_floor_atTop.comp windowScale_tendsto_atTop

/-- Real-cast version used by the analytic cutoff interface. -/
theorem windowLength_cast_tendsto_atTop :
    Tendsto (fun X : ℕ => (windowLength X : ℝ)) atTop atTop :=
  tendsto_natCast_atTop_atTop.comp windowLength_tendsto_atTop

/-- Rounding loses at most a vanishing relative error. -/
theorem windowLength_ratio_tendsto_one :
    Tendsto (fun X : ℕ => (windowLength X : ℝ) /
      Real.rpow (Real.log (X : ℝ)) endpointExponent) atTop (𝓝 1) := by
  exact tendsto_nat_floor_div_atTop.comp windowScale_tendsto_atTop

/-- Window positivity is a proved consequence, not a new cutoff premise. -/
theorem eventually_windowLength_pos : ∀ᶠ X : ℕ in atTop, 1 ≤ windowLength X :=
  windowLength_tendsto_atTop.eventually (eventually_ge_atTop 1)

/-- The logarithmic rounding error tends to zero, retaining the constant term. -/
theorem log_windowLength_sub_tendsto_zero :
    Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ) -
      endpointExponent * Real.log (Real.log (X : ℝ))) atTop (𝓝 0) := by
  have hlog : Tendsto (fun X : ℕ => Real.log ((windowLength X : ℝ) /
      Real.rpow (Real.log (X : ℝ)) endpointExponent)) atTop (𝓝 0) := by
    simpa only [Function.comp_def, Real.log_one] using
      (Real.continuousAt_log (by norm_num : (1 : ℝ) ≠ 0)).tendsto.comp
        windowLength_ratio_tendsto_one
  apply hlog.congr'
  filter_upwards [eventually_ge_atTop (2 : ℕ), eventually_windowLength_pos] with X hX hH
  have hQ : 0 < Real.log (X : ℝ) :=
    Real.log_pos (by exact_mod_cast (show 1 < X by omega))
  have hHR : 0 < (windowLength X : ℝ) := by exact_mod_cast (show 0 < windowLength X by omega)
  exact log_div_rpow_eq (windowLength X : ℝ) (Real.log (X : ℝ))
    endpointExponent hHR.ne' hQ

/-- Normalized logarithmic window growth. -/
theorem log_windowLength_div_logLog_tendsto :
    Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ) /
      Real.log (Real.log (X : ℝ))) atTop (𝓝 endpointExponent) := by
  have h : Tendsto (fun X : ℕ =>
      (Real.log (windowLength X : ℝ) -
        endpointExponent * Real.log (Real.log (X : ℝ))) /
        Real.log (Real.log (X : ℝ)) + endpointExponent) atTop (𝓝 endpointExponent) := by
    simpa using (log_windowLength_sub_tendsto_zero.div_atTop
      logLogX_tendsto_atTop).add_const endpointExponent
  apply h.congr'
  filter_upwards [logLogX_tendsto_atTop.eventually (eventually_gt_atTop (0 : ℝ))] with X hL
  rw [sub_div, mul_div_cancel_right₀ _ hL.ne']
  ring

end Erdos647Sieve.Endpoint
end
