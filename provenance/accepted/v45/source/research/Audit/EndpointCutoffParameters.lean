import Erdos647Research.Endpoint.CutoffParameters

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology
open Filter Erdos647Sieve

example : (∀ X : ℕ, 0 < X → 0 < primeCutoff X) := Erdos647Sieve.Endpoint.primeCutoff_pos
#check Erdos647Sieve.Endpoint.primeCutoff_pos
#print axioms Erdos647Sieve.Endpoint.primeCutoff_pos

example : (∀ X : ℕ, 0 < X → Real.log (primeCutoff X) = Real.log (X : ℝ) / (4 * (truncationOrder X : ℝ))) := Erdos647Sieve.Endpoint.log_primeCutoff
#check Erdos647Sieve.Endpoint.log_primeCutoff
#print axioms Erdos647Sieve.Endpoint.log_primeCutoff

example : (Tendsto (fun X : ℕ => Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)) atTop atTop) := Erdos647Sieve.Endpoint.complementaryScale_tendsto_atTop
#check Erdos647Sieve.Endpoint.complementaryScale_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.complementaryScale_tendsto_atTop

example : (Tendsto (fun X : ℕ => Real.log (primeCutoff X) / Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)) atTop (𝓝 ((25 : ℝ) / 2))) := Erdos647Sieve.Endpoint.log_primeCutoff_scale_ratio_tendsto
#check Erdos647Sieve.Endpoint.log_primeCutoff_scale_ratio_tendsto
#print axioms Erdos647Sieve.Endpoint.log_primeCutoff_scale_ratio_tendsto

example : (Tendsto (fun X : ℕ => Real.log (primeCutoff X)) atTop atTop) := Erdos647Sieve.Endpoint.log_primeCutoff_tendsto_atTop
#check Erdos647Sieve.Endpoint.log_primeCutoff_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.log_primeCutoff_tendsto_atTop

example : (Tendsto primeCutoff atTop atTop) := Erdos647Sieve.Endpoint.primeCutoff_tendsto_atTop
#check Erdos647Sieve.Endpoint.primeCutoff_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.primeCutoff_tendsto_atTop

example : (Tendsto (fun X : ℕ => Real.log (Real.log (primeCutoff X)) - (1 - endpointExponent) * Real.log (Real.log (X : ℝ))) atTop (𝓝 (Real.log ((25 : ℝ) / 2)))) := Erdos647Sieve.Endpoint.loglog_primeCutoff_sub_tendsto
#check Erdos647Sieve.Endpoint.loglog_primeCutoff_sub_tendsto
#print axioms Erdos647Sieve.Endpoint.loglog_primeCutoff_sub_tendsto

example : (Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ) / Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent)) atTop (𝓝 0)) := Erdos647Sieve.Endpoint.log_windowLength_div_complementaryScale_tendsto_zero
#check Erdos647Sieve.Endpoint.log_windowLength_div_complementaryScale_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.log_windowLength_div_complementaryScale_tendsto_zero

example : (Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ) / Real.log (primeCutoff X)) atTop (𝓝 0)) := Erdos647Sieve.Endpoint.log_windowLength_div_log_primeCutoff_tendsto_zero
#check Erdos647Sieve.Endpoint.log_windowLength_div_log_primeCutoff_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.log_windowLength_div_log_primeCutoff_tendsto_zero

example : (∀ᶠ X : ℕ in atTop, (windowLength X : ℝ) < primeCutoff X) := Erdos647Sieve.Endpoint.eventually_windowLength_lt_primeCutoff
#check Erdos647Sieve.Endpoint.eventually_windowLength_lt_primeCutoff
#print axioms Erdos647Sieve.Endpoint.eventually_windowLength_lt_primeCutoff

example : (Tendsto momentT atTop (𝓝 0)) := Erdos647Sieve.Endpoint.momentT_tendsto_zero
#check Erdos647Sieve.Endpoint.momentT_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.momentT_tendsto_zero

example : (∀ᶠ X : ℕ in atTop, 0 < momentT X ∧ momentT X ≤ (1 : ℝ) / 2) := Erdos647Sieve.Endpoint.eventually_momentT_bounds
#check Erdos647Sieve.Endpoint.eventually_momentT_bounds
#print axioms Erdos647Sieve.Endpoint.eventually_momentT_bounds

example : (∀ᶠ X : ℕ in atTop, 1 ≤ X ∧ 1 ≤ windowLength X ∧ (windowLength X : ℝ) < primeCutoff X ∧ 0 < 1 - momentT X ∧ 1 - momentT X < 1 ∧ Even (truncationOrder X)) := Erdos647Sieve.Endpoint.endpoint_parameters_admissible
#check Erdos647Sieve.Endpoint.endpoint_parameters_admissible
#print axioms Erdos647Sieve.Endpoint.endpoint_parameters_admissible

