/-
The constant-sensitive gap between the actual prime mass and signed budget.
Only accepted project interfaces are used; no cutoff or distribution premise
is added to the eventual conclusions.
-/
import Erdos647Research.Endpoint.PrimeMassParameters
import Erdos647Research.CorrectedBudgetEstimate
import Erdos647Research.EndpointLogBounds

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- The surviving constant after the leading and double-logarithmic terms cancel.
This is a gap per window shift, not the final endpoint saving coefficient. -/
def primeMassGapConstant : ℝ :=
  Real.log ((25 : ℝ) / 2) + 1 / Real.log 2 - 2

/-- Reuse the accepted numerical bound; no sharper approximation is needed. -/
theorem primeMassGapConstant_gt_three_halves :
    (3 / 2 : ℝ) < primeMassGapConstant :=
  Elementary.endpoint_log_gap

/-- Compare the prime mass to the main expression in the budget upper bound.
This limit does not assert that the signed budget itself has an asymptotic equality. -/
theorem endpoint_primeMass_budgetMain_gap_tendsto :
    Tendsto (fun X : ℕ =>
      primeMass (windowLength X) (primeCutoff X) / (windowLength X : ℝ) -
        (Real.log (windowLength X : ℝ) / Real.log 2 -
          Real.log (Real.log (windowLength X : ℝ)) + 2 - 1 / Real.log 2))
      atTop (𝓝 primeMassGapConstant) := by
  have h : Tendsto (fun X : ℕ =>
      (primeMass (windowLength X) (primeCutoff X) / (windowLength X : ℝ) -
        ((1 - endpointExponent) * Real.log (Real.log (X : ℝ)) -
          Real.log (Real.log (windowLength X : ℝ)) + Real.log ((25 : ℝ) / 2))) -
      (Real.log (windowLength X : ℝ) -
        endpointExponent * Real.log (Real.log (X : ℝ))) / Real.log 2 +
      primeMassGapConstant) atTop (𝓝 primeMassGapConstant) := by
    simpa using (endpoint_primeMass_expansion_tendsto_zero.sub
      (log_windowLength_sub_tendsto_zero.div_const (Real.log 2))).add_const
        primeMassGapConstant
  apply h.congr
  intro X
  have hc : endpointExponent * Real.log (Real.log (X : ℝ)) / Real.log 2 =
      (1 - endpointExponent) * Real.log (Real.log (X : ℝ)) := by
    rw [mul_div_right_comm, endpointExponent_cancellation]
  dsimp only [primeMassGapConstant]
  rw [sub_div, hc]
  ring

/-- Every fixed margin below the surviving constant is eventually available.
The onset may depend on delta, but delta does not depend on X. No sign assumption
on the corrected budget is made. -/
theorem eventually_primeMass_gap_of_lt (δ : ℝ) (hδ : δ < primeMassGapConstant) :
    ∀ᶠ X : ℕ in atTop,
      δ * (windowLength X : ℝ) ≤
        primeMass (windowLength X) (primeCutoff X) -
          (correctedBudget (windowLength X) : ℝ) := by
  let ε : ℝ := (primeMassGapConstant - δ) / 2
  have hε : 0 < ε := by
    dsimp only [ε]
    linarith
  have hmargin : δ + ε < primeMassGapConstant := by
    dsimp only [ε]
    linarith
  have hmass : ∀ᶠ X : ℕ in atTop,
      δ + ε < primeMass (windowLength X) (primeCutoff X) / (windowLength X : ℝ) -
        (Real.log (windowLength X : ℝ) / Real.log 2 -
          Real.log (Real.log (windowLength X : ℝ)) + 2 - 1 / Real.log 2) :=
    endpoint_primeMass_budgetMain_gap_tendsto.eventually (lt_mem_nhds hmargin)
  have hbudget : ∀ᶠ X : ℕ in atTop,
      (correctedBudget (windowLength X) : ℝ) / (windowLength X : ℝ) ≤
        Real.log (windowLength X : ℝ) / Real.log 2 -
          Real.log (Real.log (windowLength X : ℝ)) + 2 - 1 / Real.log 2 + ε :=
    windowLength_tendsto_atTop.eventually
      (Elementary.correctedBudget_upper_eventually ε hε)
  filter_upwards [hmass, hbudget, eventually_windowLength_pos] with X hm hb hH
  have hHR : 0 < (windowLength X : ℝ) := by
    exact_mod_cast (show 0 < windowLength X by omega)
  have hratio : δ ≤
      (primeMass (windowLength X) (primeCutoff X) -
        (correctedBudget (windowLength X) : ℝ)) / (windowLength X : ℝ) := by
    rw [sub_div]
    linarith
  exact (le_div_iff₀ hHR).mp hratio

/-- The fixed positive gap used by the subsequent amplified-error estimates. -/
theorem eventually_primeMass_sub_correctedBudget_ge :
    ∀ᶠ X : ℕ in atTop,
      (3 / 2 : ℝ) * (windowLength X : ℝ) ≤
        primeMass (windowLength X) (primeCutoff X) -
          (correctedBudget (windowLength X) : ℝ) :=
  eventually_primeMass_gap_of_lt (3 / 2) primeMassGapConstant_gt_three_halves

/-- The signed budget is eventually bounded by the prime mass, including when
it is negative. This avoids proving an unnecessary budget positivity theorem. -/
theorem eventually_correctedBudget_le_primeMass :
    ∀ᶠ X : ℕ in atTop,
      (correctedBudget (windowLength X) : ℝ) ≤
        primeMass (windowLength X) (primeCutoff X) := by
  filter_upwards [eventually_primeMass_sub_correctedBudget_ge] with X hgap
  have hnonneg : (0 : ℝ) ≤ (3 / 2 : ℝ) * (windowLength X : ℝ) := by positivity
  linarith

end Erdos647Sieve.Endpoint
end
