/-
Normalized prime-mass growth and one-sided size bounds for amplified errors.
The budget stays signed; no asymptotic equality for the budget is claimed.
-/
import Erdos647Research.Endpoint.PrimeMassGap

set_option autoImplicit false
open scoped BigOperators Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- The inner argument needed for the standard logarithm-over-identity limit. -/
theorem log_windowLength_tendsto_atTop :
    Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ)) atTop atTop :=
  Real.tendsto_log_atTop.comp windowLength_cast_tendsto_atTop

/-- The double logarithm of the window is negligible compared with log log X. -/
theorem loglog_windowLength_div_logLog_tendsto_zero :
    Tendsto (fun X : ℕ => Real.log (Real.log (windowLength X : ℝ)) /
      Real.log (Real.log (X : ℝ))) atTop (𝓝 0) := by
  have hlog : Tendsto (fun u : ℝ => Real.log u / u) atTop (𝓝 0) := by
    simpa using Real.tendsto_pow_log_div_mul_add_atTop 1 0 1 (by norm_num)
  have h : Tendsto (fun X : ℕ =>
      (Real.log (Real.log (windowLength X : ℝ)) / Real.log (windowLength X : ℝ)) *
        (Real.log (windowLength X : ℝ) / Real.log (Real.log (X : ℝ))))
      atTop (𝓝 0) := by
    simpa using (hlog.comp log_windowLength_tendsto_atTop).mul
      log_windowLength_div_logLog_tendsto
  apply h.congr'
  filter_upwards [log_windowLength_tendsto_atTop.eventually
    (eventually_gt_atTop (0 : ℝ))] with X hlogH
  rw [div_mul_div_cancel₀ hlogH.ne']

/-- The actual prime mass grows like (1-a) H log log X. This controls the
numerator in the growing factorial tail, rather than treating it as a constant. -/
theorem endpoint_primeMass_div_window_logLog_tendsto :
    Tendsto (fun X : ℕ => primeMass (windowLength X) (primeCutoff X) /
      ((windowLength X : ℝ) * Real.log (Real.log (X : ℝ))))
      atTop (𝓝 (1 - endpointExponent)) := by
  have h : Tendsto (fun X : ℕ =>
      (primeMass (windowLength X) (primeCutoff X) / (windowLength X : ℝ) -
        ((1 - endpointExponent) * Real.log (Real.log (X : ℝ)) -
          Real.log (Real.log (windowLength X : ℝ)) + Real.log ((25 : ℝ) / 2))) /
          Real.log (Real.log (X : ℝ)) + (1 - endpointExponent) -
        Real.log (Real.log (windowLength X : ℝ)) / Real.log (Real.log (X : ℝ)) +
        Real.log ((25 : ℝ) / 2) / Real.log (Real.log (X : ℝ)))
      atTop (𝓝 (1 - endpointExponent)) := by
    simpa using (((endpoint_primeMass_expansion_tendsto_zero.div_atTop
      logLogX_tendsto_atTop).add_const (1 - endpointExponent)).sub
        loglog_windowLength_div_logLog_tendsto_zero).add
          (logLogX_tendsto_atTop.const_div_atTop (Real.log ((25 : ℝ) / 2)))
  apply h.congr'
  filter_upwards [logLogX_tendsto_atTop.eventually
    (eventually_gt_atTop (0 : ℝ))] with X hL
  rw [sub_div, add_div, sub_div, mul_div_cancel_right₀ _ hL.ne', div_div]
  ring

/-- Positivity of the finite prime sum, valid even for small degenerate X. -/
theorem endpoint_primeMass_nonneg (X : ℕ) :
    0 ≤ primeMass (windowLength X) (primeCutoff X) := by
  unfold primeMass
  apply mul_nonneg (Nat.cast_nonneg _)
  exact Finset.sum_nonneg (fun (p : ℕ) _ => div_nonneg zero_le_one (Nat.cast_nonneg p))

/-- A convenient eventual mass bound; 1-a < 1 supplies the slack. -/
theorem eventually_primeMass_le_window_mul_logLog :
    ∀ᶠ X : ℕ in atTop,
      primeMass (windowLength X) (primeCutoff X) ≤
        (windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) := by
  have hsmall := endpoint_primeMass_div_window_logLog_tendsto.eventually
    (gt_mem_nhds (by linarith [endpointExponent_pos] : 1 - endpointExponent < (1 : ℝ)))
  filter_upwards [hsmall, eventually_windowLength_pos,
    logLogX_tendsto_atTop.eventually (eventually_gt_atTop (0 : ℝ))] with X hs hH hL
  have hHR : 0 < (windowLength X : ℝ) := by
    exact_mod_cast (show 0 < windowLength X by omega)
  exact ((div_lt_one (mul_pos hHR hL)).mp hs).le

/-- The corresponding one-sided bound for the signed budget follows from the
gap. No new asymptotic expansion or nonnegativity assumption for the budget. -/
theorem eventually_correctedBudget_le_window_mul_logLog :
    ∀ᶠ X : ℕ in atTop,
      (correctedBudget (windowLength X) : ℝ) ≤
        (windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) := by
  filter_upwards [eventually_correctedBudget_le_primeMass,
    eventually_primeMass_le_window_mul_logLog] with X hb hm
  exact hb.trans hm

/-- Unconditional inputs for the next amplified-error layer. The absent
condition 0 <= correctedBudget is deliberate: final counting splits on its sign. -/
theorem eventually_endpoint_mass_budget_bounds :
    ∀ᶠ X : ℕ in atTop,
      1 ≤ windowLength X ∧ 0 < Real.log (Real.log (X : ℝ)) ∧
      0 ≤ primeMass (windowLength X) (primeCutoff X) ∧
      primeMass (windowLength X) (primeCutoff X) ≤
        (windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) ∧
      (correctedBudget (windowLength X) : ℝ) ≤
        (windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) ∧
      (3 / 2 : ℝ) * (windowLength X : ℝ) ≤
        primeMass (windowLength X) (primeCutoff X) -
          (correctedBudget (windowLength X) : ℝ) := by
  filter_upwards [eventually_windowLength_pos,
    logLogX_tendsto_atTop.eventually (eventually_gt_atTop (0 : ℝ)),
    eventually_primeMass_le_window_mul_logLog,
    eventually_correctedBudget_le_window_mul_logLog,
    eventually_primeMass_sub_correctedBudget_ge] with X hH hL hm hb hg
  exact ⟨hH, hL, endpoint_primeMass_nonneg X, hm, hb, hg⟩

end Erdos647Sieve.Endpoint
end
