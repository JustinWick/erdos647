import Erdos647Research.Endpoint.MassBudgetBounds

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Erdos647Sieve

example : Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ)) atTop atTop :=
  Erdos647Sieve.Endpoint.log_windowLength_tendsto_atTop
#check Erdos647Sieve.Endpoint.log_windowLength_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.log_windowLength_tendsto_atTop

example : Tendsto (fun X : ℕ => Real.log (Real.log (windowLength X : ℝ)) /
  Real.log (Real.log (X : ℝ))) atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.loglog_windowLength_div_logLog_tendsto_zero
#check Erdos647Sieve.Endpoint.loglog_windowLength_div_logLog_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.loglog_windowLength_div_logLog_tendsto_zero

example : Tendsto (fun X : ℕ => primeMass (windowLength X) (primeCutoff X) /
  ((windowLength X : ℝ) * Real.log (Real.log (X : ℝ))))
  atTop (𝓝 (1 - endpointExponent)) :=
  Erdos647Sieve.Endpoint.endpoint_primeMass_div_window_logLog_tendsto
#check Erdos647Sieve.Endpoint.endpoint_primeMass_div_window_logLog_tendsto
#print axioms Erdos647Sieve.Endpoint.endpoint_primeMass_div_window_logLog_tendsto

example : ∀ X : ℕ, 0 ≤ primeMass (windowLength X) (primeCutoff X) :=
  Erdos647Sieve.Endpoint.endpoint_primeMass_nonneg
#check Erdos647Sieve.Endpoint.endpoint_primeMass_nonneg
#print axioms Erdos647Sieve.Endpoint.endpoint_primeMass_nonneg

example : ∀ᶠ X : ℕ in atTop,
  primeMass (windowLength X) (primeCutoff X) ≤
    (windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) :=
  Erdos647Sieve.Endpoint.eventually_primeMass_le_window_mul_logLog
#check Erdos647Sieve.Endpoint.eventually_primeMass_le_window_mul_logLog
#print axioms Erdos647Sieve.Endpoint.eventually_primeMass_le_window_mul_logLog

example : ∀ᶠ X : ℕ in atTop,
  (correctedBudget (windowLength X) : ℝ) ≤
    (windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) :=
  Erdos647Sieve.Endpoint.eventually_correctedBudget_le_window_mul_logLog
#check Erdos647Sieve.Endpoint.eventually_correctedBudget_le_window_mul_logLog
#print axioms Erdos647Sieve.Endpoint.eventually_correctedBudget_le_window_mul_logLog

example : ∀ᶠ X : ℕ in atTop,
  1 ≤ windowLength X ∧ 0 < Real.log (Real.log (X : ℝ)) ∧
  0 ≤ primeMass (windowLength X) (primeCutoff X) ∧
  primeMass (windowLength X) (primeCutoff X) ≤
    (windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) ∧
  (correctedBudget (windowLength X) : ℝ) ≤
    (windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) ∧
  (3 / 2 : ℝ) * (windowLength X : ℝ) ≤
    primeMass (windowLength X) (primeCutoff X) -
      (correctedBudget (windowLength X) : ℝ) :=
  Erdos647Sieve.Endpoint.eventually_endpoint_mass_budget_bounds
#check Erdos647Sieve.Endpoint.eventually_endpoint_mass_budget_bounds
#print axioms Erdos647Sieve.Endpoint.eventually_endpoint_mass_budget_bounds

