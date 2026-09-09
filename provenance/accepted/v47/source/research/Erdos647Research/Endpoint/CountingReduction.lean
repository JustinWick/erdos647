/-
All amplified contributions in a single unconditional candidate-count estimate.
This is an intermediate endpoint bound, not the final fixed-c endpoint theorem.
-/
import Erdos647Research.Endpoint.MomentTail
import Erdos647Research.Endpoint.ArithmeticRemainder
import Erdos647Sieve.FiniteCounting

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- Expand the actual finite counting expression into its three weighted terms. -/
theorem amplified_momentBound_eq (X : ℕ) :
    Real.exp (amplificationExponent X) *
        momentBound X (windowLength X) (primeCutoff X) (1 - momentT X) (truncationOrder X) =
      (X : ℝ) * Real.exp (amplificationExponent X - endpointMu X) +
      (X : ℝ) * (Real.exp (amplificationExponent X) *
        (endpointMu X ^ (truncationOrder X + 1) /
          (Nat.factorial (truncationOrder X + 1) : ℝ))) +
      Real.exp (amplificationExponent X) *
        ((windowLength X : ℝ) * primeCutoff X) ^ truncationOrder X := by
  have hsub : 1 - (1 - momentT X) = momentT X := by ring
  have hexp : Real.exp (amplificationExponent X - endpointMu X) =
      Real.exp (amplificationExponent X) * Real.exp (-endpointMu X) := by
    rw [sub_eq_add_neg, Real.exp_add]
  rw [hexp]
  dsimp only [momentBound]
  rw [hsub]
  change Real.exp (amplificationExponent X) *
      ((X : ℝ) * (Real.exp (-endpointMu X) +
        endpointMu X ^ (truncationOrder X + 1) /
          (Nat.factorial (truncationOrder X + 1) : ℝ)) +
        ((windowLength X : ℝ) * primeCutoff X) ^ truncationOrder X) = _
  ring

/-- For a nonnegative budget, every weighted term is bounded separately. -/
theorem eventually_candidateCount_le_four_contributions :
    ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      (candidateCount X : ℝ) ≤ (windowLength X : ℝ) +
        (X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
          ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ)))) +
        (X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30) +
        Real.exp (Real.log (X : ℝ) / 2) := by
  filter_upwards [endpoint_parameters_admissible, eventually_principal_contribution_le,
    eventually_moment_tail_contribution_le, eventually_amplified_arithmetic_remainder_le]
    with X hp hm ht ha hB
  have hc := finiteCounting X (windowLength X) (primeCutoff X) (1 - momentT X)
    (truncationOrder X) hp.1 hp.2.1 hp.2.2.1 hp.2.2.2.1 hp.2.2.2.2.1 hp.2.2.2.2.2 hB
  change (candidateCount X : ℝ) ≤ (windowLength X : ℝ) +
    Real.exp (amplificationExponent X) *
      momentBound X (windowLength X) (primeCutoff X) (1 - momentT X) (truncationOrder X) at hc
  rw [amplified_momentBound_eq] at hc
  linarith [hm hB, ht hB, ha hB]

/-- The negative-budget branch uses the existing exact exclusion theorem. -/
theorem eventually_candidateCount_le_of_negative_budget :
    ∀ᶠ X : ℕ in atTop, correctedBudget (windowLength X) < 0 →
      (candidateCount X : ℝ) ≤ Real.exp (Real.log (X : ℝ) / 2) := by
  filter_upwards [endpoint_parameters_admissible, eventually_exceptional_window_le]
    with X hp hw hneg
  have hc := candidateCount_le_window_of_negative_correctedBudget X (windowLength X)
    (primeCutoff X) hp.2.1 hp.2.2.1 hneg
  have hcR : (candidateCount X : ℝ) ≤ (windowLength X : ℝ) := by exact_mod_cast hc
  exact hcR.trans hw

/-- All-sign intermediate endpoint estimate. The two square-root-scale terms
account for BOTH the amplified CRT error and the exceptional window. -/
theorem eventually_candidateCount_le_amplified_errors :
    ∀ᶠ X : ℕ in atTop,
      (candidateCount X : ℝ) ≤
        (X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
          ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ)))) +
        (X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30) +
        2 * Real.exp (Real.log (X : ℝ) / 2) := by
  filter_upwards [eventually_candidateCount_le_four_contributions,
    eventually_candidateCount_le_of_negative_budget, eventually_exceptional_window_le]
    with X hpos hneg hw
  by_cases hB : 0 ≤ correctedBudget (windowLength X)
  · linarith [hpos hB]
  · have h := hneg (lt_of_not_ge hB)
    have hp : 0 ≤ (X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
        ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ)))) :=
      mul_nonneg (Nat.cast_nonneg X) (Real.exp_pos _).le
    have ht : 0 ≤ (X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30) :=
      mul_nonneg (Nat.cast_nonneg X) (Real.exp_pos _).le
    linarith [Real.exp_pos (Real.log (X : ℝ) / 2)]

end Erdos647Sieve.Endpoint
end
