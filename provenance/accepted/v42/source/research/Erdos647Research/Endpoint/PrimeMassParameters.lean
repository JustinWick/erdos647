/-
Specialize the accepted two-cutoff Mertens interface to the actual endpoint
parameters, discharging rather than repeating its cutoff hypotheses.
-/
import Erdos647Research.Endpoint.CutoffParameters
import Erdos647Research.SelectedPrimeReciprocals

set_option autoImplicit false
open scoped BigOperators Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- The Mertens error vanishes for the protected endpoint cutoffs, with no free
cutoff-growth or cutoff-ordering hypotheses. -/
theorem endpoint_selectedPrimeSum_error_tendsto_zero :
    Tendsto (fun X : ℕ =>
      (∑ p ∈ selectedPrimes (windowLength X) (primeCutoff X), (1 : ℝ) / (p : ℝ)) -
      (Real.log (Real.log (primeCutoff X)) -
        Real.log (Real.log (windowLength X : ℝ)))) atTop (𝓝 0) := by
  apply Analytic.selectedPrimeSum_difference_tendsto_zero windowLength primeCutoff
    windowLength_cast_tendsto_atTop primeCutoff_tendsto_atTop
  exact eventually_windowLength_lt_primeCutoff.mono (fun _ h => h.le)

/-- The constant-sensitive prime-mass expansion used in the next gap argument.
This is an asymptotic statement for the exact `primeMass`, not a probabilistic model. -/
theorem endpoint_primeMass_expansion_tendsto_zero :
    Tendsto (fun X : ℕ =>
      primeMass (windowLength X) (primeCutoff X) / (windowLength X : ℝ) -
      ((1 - endpointExponent) * Real.log (Real.log (X : ℝ)) -
        Real.log (Real.log (windowLength X : ℝ)) + Real.log ((25 : ℝ) / 2)))
      atTop (𝓝 0) := by
  have h : Tendsto (fun X : ℕ =>
      ((∑ p ∈ selectedPrimes (windowLength X) (primeCutoff X), (1 : ℝ) / (p : ℝ)) -
        (Real.log (Real.log (primeCutoff X)) - Real.log (Real.log (windowLength X : ℝ)))) +
      ((Real.log (Real.log (primeCutoff X)) -
        (1 - endpointExponent) * Real.log (Real.log (X : ℝ))) - Real.log ((25 : ℝ) / 2)))
      atTop (𝓝 0) := by
    simpa using endpoint_selectedPrimeSum_error_tendsto_zero.add
      (loglog_primeCutoff_sub_tendsto.sub_const (Real.log ((25 : ℝ) / 2)))
  apply h.congr'
  filter_upwards [eventually_windowLength_pos] with X hH
  have hHR : (windowLength X : ℝ) ≠ 0 := by exact_mod_cast (show windowLength X ≠ 0 by omega)
  unfold primeMass
  rw [mul_div_cancel_left₀ _ hHR]
  ring

end Erdos647Sieve.Endpoint
end
