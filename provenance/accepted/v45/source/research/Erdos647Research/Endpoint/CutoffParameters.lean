/-
The protected prime cutoff and moment weight at natural interval lengths.
The variable exponent is handled through its exact logarithm; no fixed-exponent
limit is applied to the cutoff itself.
-/
import Erdos647Research.Endpoint.TruncationParameters

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- Positive bases give a positive prime cutoff even when J=0. -/
theorem primeCutoff_pos (X : ℕ) (hX : 0 < X) : 0 < primeCutoff X := by
  unfold primeCutoff
  exact Real.rpow_pos_of_pos (by exact_mod_cast hX) _

/-- Exact logarithm of the variable-exponent prime cutoff. -/
theorem log_primeCutoff (X : ℕ) (hX : 0 < X) :
    Real.log (primeCutoff X) = Real.log (X : ℝ) / (4 * (truncationOrder X : ℝ)) := by
  unfold primeCutoff
  rw [Real.rpow_eq_pow, Real.log_rpow (by exact_mod_cast hX : 0 < (X : ℝ))]
  ring

/-- The complementary logarithmic-power scale tends to infinity. -/
theorem complementaryScale_tendsto_atTop :
    Tendsto (fun X : ℕ => Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent))
      atTop atTop :=
  (tendsto_rpow_atTop (sub_pos.mpr endpointExponent_lt_one)).comp logX_tendsto_atTop

/-- The explicit coefficient 25/2 comes from J/H tending to 1/50. -/
theorem log_primeCutoff_scale_ratio_tendsto :
    Tendsto (fun X : ℕ => Real.log (primeCutoff X) /
      Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent))
      atTop (𝓝 ((25 : ℝ) / 2)) := by
  have h : Tendsto (fun X : ℕ =>
      (4 * ((truncationOrder X : ℝ) /
        Real.rpow (Real.log (X : ℝ)) endpointExponent))⁻¹)
      atTop (𝓝 ((25 : ℝ) / 2)) := by
    convert! (truncationOrder_scale_ratio_tendsto.const_mul 4).inv₀
      (by norm_num : (4 * ((1 : ℝ) / 50)) ≠ 0) using 1
    norm_num
  apply h.congr'
  filter_upwards [eventually_ge_atTop (2 : ℕ)] with X hX
  have hQ : 0 < Real.log (X : ℝ) :=
    Real.log_pos (by exact_mod_cast (show 1 < X by omega))
  have hc : Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent) ≠ 0 :=
    (Real.rpow_pos_of_pos hQ _).ne'
  have hp : Real.log (X : ℝ) =
      Real.rpow (Real.log (X : ℝ)) endpointExponent *
        Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent) := by
    simp only [Real.rpow_eq_pow]
    rw [← Real.rpow_add hQ]
    simp
  symm
  rw [log_primeCutoff X (by omega)]
  calc
    Real.log (X : ℝ) / (4 * (truncationOrder X : ℝ)) /
        Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent) =
      (Real.log (X : ℝ) / Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)) /
        (4 * (truncationOrder X : ℝ)) := by ring
    _ = Real.rpow (Real.log (X : ℝ)) endpointExponent /
        (4 * (truncationOrder X : ℝ)) := by rw [(div_eq_iff hc).mpr hp]
    _ = (4 * ((truncationOrder X : ℝ) /
        Real.rpow (Real.log (X : ℝ)) endpointExponent))⁻¹ := by
      rw [← mul_div_assoc, inv_div]

/-- In particular, log y tends to infinity. -/
theorem log_primeCutoff_tendsto_atTop :
    Tendsto (fun X : ℕ => Real.log (primeCutoff X)) atTop atTop :=
  complementaryScale_tendsto_atTop.num (by norm_num : (0 : ℝ) < 25 / 2)
    log_primeCutoff_scale_ratio_tendsto

/-- The actual cutoff, not just a comparison scale, diverges. -/
theorem primeCutoff_tendsto_atTop : Tendsto primeCutoff atTop atTop := by
  have h := Real.tendsto_exp_atTop.comp log_primeCutoff_tendsto_atTop
  apply h.congr'
  filter_upwards [eventually_ge_atTop (1 : ℕ)] with X hX
  exact Real.exp_log (primeCutoff_pos X (by omega))

/-- Taking another logarithm retains the constant needed for the critical gap. -/
theorem loglog_primeCutoff_sub_tendsto :
    Tendsto (fun X : ℕ => Real.log (Real.log (primeCutoff X)) -
      (1 - endpointExponent) * Real.log (Real.log (X : ℝ)))
      atTop (𝓝 (Real.log ((25 : ℝ) / 2))) := by
  have hlog : Tendsto (fun X : ℕ => Real.log (Real.log (primeCutoff X) /
      Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)))
      atTop (𝓝 (Real.log ((25 : ℝ) / 2))) := by
    exact (Real.continuousAt_log (by norm_num : ((25 : ℝ) / 2) ≠ 0)).tendsto.comp
      log_primeCutoff_scale_ratio_tendsto
  apply hlog.congr'
  filter_upwards [eventually_ge_atTop (2 : ℕ),
    log_primeCutoff_tendsto_atTop.eventually (eventually_gt_atTop (0 : ℝ))] with X hX hy
  have hQ : 0 < Real.log (X : ℝ) :=
    Real.log_pos (by exact_mod_cast (show 1 < X by omega))
  exact log_div_rpow_eq (Real.log (primeCutoff X)) (Real.log (X : ℝ))
    (1 - endpointExponent) hy.ne' hQ

/-- A logarithm is negligible relative to the complementary positive power. -/
theorem log_windowLength_div_complementaryScale_tendsto_zero :
    Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ) /
      Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)) atTop (𝓝 0) := by
  have hsmall : Tendsto (fun X : ℕ => Real.log (Real.log (X : ℝ)) /
      Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)) atTop (𝓝 0) :=
    ((isLittleO_log_rpow_atTop (sub_pos.mpr endpointExponent_lt_one)).tendsto_div_nhds_zero).comp
      logX_tendsto_atTop
  have h : Tendsto (fun X : ℕ =>
      (Real.log (windowLength X : ℝ) -
        endpointExponent * Real.log (Real.log (X : ℝ))) /
        Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent) +
      endpointExponent * (Real.log (Real.log (X : ℝ)) /
        Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent))) atTop (𝓝 0) := by
    simpa using (log_windowLength_sub_tendsto_zero.div_atTop
      complementaryScale_tendsto_atTop).add (hsmall.const_mul endpointExponent)
  exact h.congr (fun X => by ring)

/-- Logarithmic comparison of the actual window and prime cutoff. -/
theorem log_windowLength_div_log_primeCutoff_tendsto_zero :
    Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ) /
      Real.log (primeCutoff X)) atTop (𝓝 0) := by
  have h : Tendsto (fun X : ℕ =>
      (Real.log (windowLength X : ℝ) /
        Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)) /
      (Real.log (primeCutoff X) /
        Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent))) atTop (𝓝 0) := by
    simpa only [Pi.div_def, zero_div] using
      log_windowLength_div_complementaryScale_tendsto_zero.div
        log_primeCutoff_scale_ratio_tendsto (by norm_num : ((25 : ℝ) / 2) ≠ 0)
  apply h.congr'
  filter_upwards [eventually_ge_atTop (2 : ℕ)] with X hX
  have hQ : 0 < Real.log (X : ℝ) :=
    Real.log_pos (by exact_mod_cast (show 1 < X by omega))
  exact div_div_div_cancel_right₀ (Real.rpow_pos_of_pos hQ (1 - endpointExponent)).ne'
    (Real.log (windowLength X : ℝ)) (Real.log (primeCutoff X))

/-- The ordering required by the finite sieve is eventually valid. -/
theorem eventually_windowLength_lt_primeCutoff :
    ∀ᶠ X : ℕ in atTop, (windowLength X : ℝ) < primeCutoff X := by
  have hsmall := log_windowLength_div_log_primeCutoff_tendsto_zero.eventually
    (gt_mem_nhds (by norm_num : (0 : ℝ) < 1))
  filter_upwards [eventually_ge_atTop (1 : ℕ), hsmall,
    log_primeCutoff_tendsto_atTop.eventually (eventually_gt_atTop (0 : ℝ))] with X hX hs hy
  have hlt : Real.log (windowLength X : ℝ) < Real.log (primeCutoff X) :=
    (div_lt_one hy).mp hs
  by_contra! hle
  have hrev := Real.log_le_log (primeCutoff_pos X (by omega)) hle
  linarith

/-- The protected t(X), including its exact factor 1000, tends to zero. -/
theorem momentT_tendsto_zero : Tendsto momentT atTop (𝓝 0) := by
  have h := logLogX_tendsto_atTop.const_div_atTop ((1 : ℝ) / 1000)
  exact h.congr (fun X => by dsimp only [momentT]; rw [div_div])

/-- A single eventual range sufficient for the logarithm and moment lemmas. -/
theorem eventually_momentT_bounds :
    ∀ᶠ X : ℕ in atTop, 0 < momentT X ∧ momentT X ≤ (1 : ℝ) / 2 := by
  filter_upwards [logLogX_tendsto_atTop.eventually (eventually_ge_atTop (1 : ℝ))] with X hL
  have hd : 0 < 1000 * Real.log (Real.log (X : ℝ)) := by linarith
  change 0 < 1 / (1000 * Real.log (Real.log (X : ℝ))) ∧
    1 / (1000 * Real.log (Real.log (X : ℝ))) ≤ (1 : ℝ) / 2
  refine ⟨div_pos zero_lt_one hd, ?_⟩
  apply (div_le_iff₀ hd).mpr
  linarith

/-- All numerical hypotheses of the finite-moment theorem at the actual parameters.
The signed-budget branch condition is deliberately not asserted here. -/
theorem endpoint_parameters_admissible :
    ∀ᶠ X : ℕ in atTop,
      1 ≤ X ∧ 1 ≤ windowLength X ∧
      (windowLength X : ℝ) < primeCutoff X ∧
      0 < 1 - momentT X ∧ 1 - momentT X < 1 ∧ Even (truncationOrder X) := by
  filter_upwards [eventually_ge_atTop (1 : ℕ), eventually_windowLength_pos,
    eventually_windowLength_lt_primeCutoff, eventually_momentT_bounds] with X hX hH hy ht
  refine ⟨hX, hH, hy, ?_, ?_, truncationOrder_even X⟩
  · linarith [ht.2]
  · linarith [ht.1]

end Erdos647Sieve.Endpoint
end
