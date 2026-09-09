import Erdos647Research.Endpoint.AbsorptionScales

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Real Erdos647Sieve Erdos647Sieve.Endpoint

example : ∀ (c : ℝ) (X : ℕ) (_ : 0 < X),
    0 < endpointRHSWith c X :=
  Erdos647Sieve.Endpoint.endpointRHSWith_pos
#check Erdos647Sieve.Endpoint.endpointRHSWith_pos
#print axioms Erdos647Sieve.Endpoint.endpointRHSWith_pos

example : Tendsto endpointScale atTop atTop :=
  Erdos647Sieve.Endpoint.endpointScale_tendsto_atTop
#check Erdos647Sieve.Endpoint.endpointScale_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.endpointScale_tendsto_atTop

example : Tendsto (fun X : ℕ => endpointScale X / (windowLength X : ℝ)) atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.endpointScale_div_window_tendsto_zero
#check Erdos647Sieve.Endpoint.endpointScale_div_window_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.endpointScale_div_window_tendsto_zero

example : Tendsto (fun X : ℕ => endpointScale X / Real.log (X : ℝ)) atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.endpointScale_div_logX_tendsto_zero
#check Erdos647Sieve.Endpoint.endpointScale_div_logX_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.endpointScale_div_logX_tendsto_zero

-- Expanded scale, with the protected exponent and natural X retained.
example : Tendsto (fun X : ℕ =>
    Real.rpow (Real.log (X : ℝ)) endpointExponent /
      Real.log (Real.log (X : ℝ))) atTop atTop :=
  endpointScale_tendsto_atTop

example : Tendsto (fun X : ℕ =>
    (Real.rpow (Real.log (X : ℝ)) endpointExponent /
      Real.log (Real.log (X : ℝ))) / (windowLength X : ℝ)) atTop (𝓝 0) :=
  endpointScale_div_window_tendsto_zero

example : Tendsto (fun X : ℕ =>
    (Real.rpow (Real.log (X : ℝ)) endpointExponent /
      Real.log (Real.log (X : ℝ))) / Real.log (X : ℝ)) atTop (𝓝 0) :=
  endpointScale_div_logX_tendsto_zero
