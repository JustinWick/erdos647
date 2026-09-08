/-
Exact integer rounding and asymptotics for the protected truncation order.
The natural quotient is not replaced by a real quotient or an assumed ceiling.
-/
import Erdos647Research.Endpoint.WindowParameters

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- The discrete ceiling bridge, valid also at zero and multiples of 100. -/
theorem rounded_hundred_eq_ceil (H : ℕ) :
    (H + 99) / 100 = Nat.ceil ((H : ℝ) / 100) := by
  apply le_antisymm
  · have hu := Nat.le_ceil ((H : ℝ) / 100)
    have hmul : (H : ℝ) ≤ (Nat.ceil ((H : ℝ) / 100) : ℝ) * 100 :=
      (div_le_iff₀ (by norm_num : (0 : ℝ) < 100)).mp hu
    have hnat : H ≤ Nat.ceil ((H : ℝ) / 100) * 100 := by exact_mod_cast hmul
    omega
  · apply Nat.ceil_le.mpr
    apply (div_le_iff₀ (by norm_num : (0 : ℝ) < 100)).mpr
    exact_mod_cast (show H ≤ (H + 99) / 100 * 100 by omega)

/-- The protected `truncationOrder` is exactly twice the indicated ceiling. -/
theorem truncationOrder_eq_ceil (X : ℕ) :
    truncationOrder X = 2 * Nat.ceil ((windowLength X : ℝ) / 100) := by
  unfold truncationOrder
  rw [rounded_hundred_eq_ceil]

/-- Bonferroni parity holds at every X, including small degenerate parameters. -/
theorem truncationOrder_even (X : ℕ) : Even (truncationOrder X) := by
  refine ⟨(windowLength X + 99) / 100, ?_⟩
  simp only [truncationOrder, two_mul]

/-- An explicit uniform rounding error smaller than two. -/
theorem truncationOrder_bounds (X : ℕ) :
    (windowLength X : ℝ) / 50 ≤ (truncationOrder X : ℝ) ∧
      (truncationOrder X : ℝ) < (windowLength X : ℝ) / 50 + 2 := by
  have hlo : windowLength X ≤ ((windowLength X + 99) / 100) * 100 := by omega
  have hhi : ((windowLength X + 99) / 100) * 100 < windowLength X + 100 := by omega
  have hloR : (windowLength X : ℝ) ≤ (((windowLength X + 99) / 100 : ℕ) : ℝ) * 100 :=
    by exact_mod_cast hlo
  have hhiR : (((windowLength X + 99) / 100 : ℕ) : ℝ) * 100 < (windowLength X : ℝ) + 100 :=
    by exact_mod_cast hhi
  simp only [truncationOrder, Nat.cast_mul, Nat.cast_ofNat]
  constructor <;> linarith

/-- The discrete truncation order is eventually positive. -/
theorem eventually_truncationOrder_pos : ∀ᶠ X : ℕ in atTop, 1 ≤ truncationOrder X := by
  filter_upwards [eventually_windowLength_pos] with X hH
  dsimp only [truncationOrder]
  omega

/-- Exact ceiling arithmetic followed by a vanishing rounding error. -/
theorem truncationOrder_div_windowLength_tendsto :
    Tendsto (fun X : ℕ => (truncationOrder X : ℝ) / (windowLength X : ℝ))
      atTop (𝓝 ((1 : ℝ) / 50)) := by
  have hu : Tendsto (fun X : ℕ => (1 : ℝ) / 50 + 2 / (windowLength X : ℝ))
      atTop (𝓝 ((1 : ℝ) / 50)) := by
    simpa using (windowLength_cast_tendsto_atTop.const_div_atTop (2 : ℝ)).const_add
      ((1 : ℝ) / 50)
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hu ?_ ?_
  · filter_upwards [eventually_windowLength_pos] with X hH
    have hHR : 0 < (windowLength X : ℝ) := by exact_mod_cast (show 0 < windowLength X by omega)
    apply (le_div_iff₀ hHR).mpr
    nlinarith [(truncationOrder_bounds X).1]
  · filter_upwards [eventually_windowLength_pos] with X hH
    have hHR : 0 < (windowLength X : ℝ) := by exact_mod_cast (show 0 < windowLength X by omega)
    apply (div_le_iff₀ hHR).mpr
    rw [add_mul, div_mul_cancel₀ _ hHR.ne']
    nlinarith [(truncationOrder_bounds X).2]

/-- Truncation growth on the unrounded logarithmic-power scale. -/
theorem truncationOrder_scale_ratio_tendsto :
    Tendsto (fun X : ℕ => (truncationOrder X : ℝ) /
      Real.rpow (Real.log (X : ℝ)) endpointExponent) atTop (𝓝 ((1 : ℝ) / 50)) := by
  have h : Tendsto (fun X : ℕ =>
      ((truncationOrder X : ℝ) / (windowLength X : ℝ)) *
        ((windowLength X : ℝ) / Real.rpow (Real.log (X : ℝ)) endpointExponent))
      atTop (𝓝 ((1 : ℝ) / 50)) := by
    simpa using truncationOrder_div_windowLength_tendsto.mul windowLength_ratio_tendsto_one
  apply h.congr'
  filter_upwards [eventually_windowLength_pos] with X hH
  have hHR : (windowLength X : ℝ) ≠ 0 := by exact_mod_cast (show windowLength X ≠ 0 by omega)
  rw [div_mul_div_cancel₀ hHR]

/-- The real truncation order tends to infinity. -/
theorem truncationOrder_cast_tendsto_atTop :
    Tendsto (fun X : ℕ => (truncationOrder X : ℝ)) atTop atTop :=
  windowLength_cast_tendsto_atTop.num (by norm_num : (0 : ℝ) < 1 / 50)
    truncationOrder_div_windowLength_tendsto

end Erdos647Sieve.Endpoint
end
