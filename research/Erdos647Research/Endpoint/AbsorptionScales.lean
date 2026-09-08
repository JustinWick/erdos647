/-
The final saving scale diverges but is smaller than both the window and log X.
These estimates depend only on accepted parameter results, not PNT+ or counting.
-/
import Erdos647Research.Endpoint.Statement
import Erdos647Research.Endpoint.ErrorScales

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- The comparison denominator is positive on the eventual natural domain. -/
theorem endpointRHSWith_pos (c : ℝ) (X : ℕ) (hX : 0 < X) :
    0 < endpointRHSWith c X := by
  unfold endpointRHSWith
  exact mul_pos (by exact_mod_cast hX) (Real.exp_pos _)

/-- The required saving scale itself grows without bound. -/
theorem endpointScale_tendsto_atTop : Tendsto endpointScale atTop atTop := by
  have hsmall : Tendsto (fun X : ℕ => Real.log (Real.log (X : ℝ)) /
      Real.rpow (Real.log (X : ℝ)) endpointExponent) atTop (𝓝 0) :=
    ((isLittleO_log_rpow_atTop endpointExponent_pos).tendsto_div_nhds_zero).comp
      logX_tendsto_atTop
  have hright : Tendsto (fun X : ℕ => Real.log (Real.log (X : ℝ)) /
      Real.rpow (Real.log (X : ℝ)) endpointExponent) atTop (𝓝[>] (0 : ℝ)) := by
    refine tendsto_nhdsWithin_iff.mpr ⟨hsmall, ?_⟩
    filter_upwards [logLogX_tendsto_atTop.eventually (eventually_gt_atTop (0 : ℝ)),
      logX_tendsto_atTop.eventually (eventually_gt_atTop (0 : ℝ))] with X hL hQ
    exact div_pos hL (Real.rpow_pos_of_pos hQ _)
  have hinv := tendsto_inv_nhdsGT_zero.comp hright
  change Tendsto (fun X : ℕ => (Real.log (Real.log (X : ℝ)) /
    Real.rpow (Real.log (X : ℝ)) endpointExponent)⁻¹) atTop atTop at hinv
  change Tendsto (fun X : ℕ =>
    Real.rpow (Real.log (X : ℝ)) endpointExponent /
      Real.log (Real.log (X : ℝ))) atTop atTop
  simpa only [inv_div] using hinv

/-- The factorial tail decays on the larger window scale: S/H tends to zero. -/
theorem endpointScale_div_window_tendsto_zero :
    Tendsto (fun X : ℕ => endpointScale X / (windowLength X : ℝ)) atTop (𝓝 0) := by
  have hratio : Tendsto (fun X : ℕ =>
      Real.rpow (Real.log (X : ℝ)) endpointExponent / (windowLength X : ℝ))
      atTop (𝓝 1) := by
    have hinv := windowLength_ratio_tendsto_one.inv₀ (by norm_num : (1 : ℝ) ≠ 0)
    change Tendsto (fun X : ℕ => ((windowLength X : ℝ) /
      Real.rpow (Real.log (X : ℝ)) endpointExponent)⁻¹) atTop (𝓝 ((1 : ℝ)⁻¹)) at hinv
    simpa only [inv_div, inv_one] using hinv
  have h := hratio.div_atTop logLogX_tendsto_atTop
  exact h.congr (fun X => by dsimp only [endpointScale]; ring)

/-- The square-root-scale remainder is negligible since S/log X tends to zero. -/
theorem endpointScale_div_logX_tendsto_zero :
    Tendsto (fun X : ℕ => endpointScale X / Real.log (X : ℝ)) atTop (𝓝 0) := by
  have hsmall : Tendsto (fun X : ℕ =>
      1 / Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)) atTop (𝓝 0) :=
    complementaryScale_tendsto_atTop.const_div_atTop (1 : ℝ)
  have h := hsmall.div_atTop logLogX_tendsto_atTop
  apply h.congr'
  filter_upwards [eventually_ge_atTop (2 : ℕ)] with X hX
  have hQ : 0 < Real.log (X : ℝ) :=
    Real.log_pos (by exact_mod_cast (show 1 < X by omega))
  have hV : Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent) ≠ 0 :=
    (Real.rpow_pos_of_pos hQ _).ne'
  have hquot : Real.rpow (Real.log (X : ℝ)) endpointExponent / Real.log (X : ℝ) =
      1 / Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent) := by
    apply (div_eq_div_iff hQ.ne' hV).mpr
    simpa only [one_mul] using window_complementary_scale_product X hX
  change (1 / Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)) /
      Real.log (Real.log (X : ℝ)) = _
  calc
    _ = (Real.rpow (Real.log (X : ℝ)) endpointExponent / Real.log (X : ℝ)) /
        Real.log (Real.log (X : ℝ)) := by rw [hquot]
    _ = endpointScale X / Real.log (X : ℝ) := by dsimp only [endpointScale]; ring

end Erdos647Sieve.Endpoint
end
