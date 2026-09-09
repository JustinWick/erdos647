import Erdos647Research.Endpoint.WindowParameters

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology
open Filter Erdos647Sieve

example : (∀ u v r : ℝ, u ≠ 0 → 0 < v →
    Real.log (u / Real.rpow v r) = Real.log u - r * Real.log v) :=
  Erdos647Sieve.Endpoint.log_div_rpow_eq
#check Erdos647Sieve.Endpoint.log_div_rpow_eq
#print axioms Erdos647Sieve.Endpoint.log_div_rpow_eq

example : (0 < endpointExponent) := Erdos647Sieve.Endpoint.endpointExponent_pos
#check Erdos647Sieve.Endpoint.endpointExponent_pos
#print axioms Erdos647Sieve.Endpoint.endpointExponent_pos

example : (endpointExponent < 1) := Erdos647Sieve.Endpoint.endpointExponent_lt_one
#check Erdos647Sieve.Endpoint.endpointExponent_lt_one
#print axioms Erdos647Sieve.Endpoint.endpointExponent_lt_one

example : (endpointExponent / Real.log 2 = 1 - endpointExponent) := Erdos647Sieve.Endpoint.endpointExponent_cancellation
#check Erdos647Sieve.Endpoint.endpointExponent_cancellation
#print axioms Erdos647Sieve.Endpoint.endpointExponent_cancellation

example : (Tendsto (fun X : ℕ => Real.log (X : ℝ)) atTop atTop) := Erdos647Sieve.Endpoint.logX_tendsto_atTop
#check Erdos647Sieve.Endpoint.logX_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.logX_tendsto_atTop

example : (Tendsto (fun X : ℕ => Real.log (Real.log (X : ℝ))) atTop atTop) := Erdos647Sieve.Endpoint.logLogX_tendsto_atTop
#check Erdos647Sieve.Endpoint.logLogX_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.logLogX_tendsto_atTop

example : (Tendsto (fun X : ℕ => Real.rpow (Real.log (X : ℝ)) endpointExponent) atTop atTop) := Erdos647Sieve.Endpoint.windowScale_tendsto_atTop
#check Erdos647Sieve.Endpoint.windowScale_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.windowScale_tendsto_atTop

example : (Tendsto windowLength atTop atTop) := Erdos647Sieve.Endpoint.windowLength_tendsto_atTop
#check Erdos647Sieve.Endpoint.windowLength_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.windowLength_tendsto_atTop

example : (Tendsto (fun X : ℕ => (windowLength X : ℝ)) atTop atTop) := Erdos647Sieve.Endpoint.windowLength_cast_tendsto_atTop
#check Erdos647Sieve.Endpoint.windowLength_cast_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.windowLength_cast_tendsto_atTop

example : (Tendsto (fun X : ℕ => (windowLength X : ℝ) / Real.rpow (Real.log (X : ℝ)) endpointExponent) atTop (𝓝 1)) := Erdos647Sieve.Endpoint.windowLength_ratio_tendsto_one
#check Erdos647Sieve.Endpoint.windowLength_ratio_tendsto_one
#print axioms Erdos647Sieve.Endpoint.windowLength_ratio_tendsto_one

example : (∀ᶠ X : ℕ in atTop, 1 ≤ windowLength X) := Erdos647Sieve.Endpoint.eventually_windowLength_pos
#check Erdos647Sieve.Endpoint.eventually_windowLength_pos
#print axioms Erdos647Sieve.Endpoint.eventually_windowLength_pos

example : (Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ) - endpointExponent * Real.log (Real.log (X : ℝ))) atTop (𝓝 0)) := Erdos647Sieve.Endpoint.log_windowLength_sub_tendsto_zero
#check Erdos647Sieve.Endpoint.log_windowLength_sub_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.log_windowLength_sub_tendsto_zero

example : (Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ) / Real.log (Real.log (X : ℝ))) atTop (𝓝 endpointExponent)) := Erdos647Sieve.Endpoint.log_windowLength_div_logLog_tendsto
#check Erdos647Sieve.Endpoint.log_windowLength_div_logLog_tendsto
#print axioms Erdos647Sieve.Endpoint.log_windowLength_div_logLog_tendsto

