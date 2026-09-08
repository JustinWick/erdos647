import Erdos647Research.Endpoint.PrimeMassParameters

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology
open Filter Erdos647Sieve

example : (Tendsto (fun X : ℕ => (∑ p ∈ selectedPrimes (windowLength X) (primeCutoff X), (1 : ℝ) / (p : ℝ)) - (Real.log (Real.log (primeCutoff X)) - Real.log (Real.log (windowLength X : ℝ)))) atTop (𝓝 0)) := Erdos647Sieve.Endpoint.endpoint_selectedPrimeSum_error_tendsto_zero
#check Erdos647Sieve.Endpoint.endpoint_selectedPrimeSum_error_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.endpoint_selectedPrimeSum_error_tendsto_zero

example : (Tendsto (fun X : ℕ => primeMass (windowLength X) (primeCutoff X) / (windowLength X : ℝ) - ((1 - endpointExponent) * Real.log (Real.log (X : ℝ)) - Real.log (Real.log (windowLength X : ℝ)) + Real.log ((25 : ℝ) / 2))) atTop (𝓝 0)) := Erdos647Sieve.Endpoint.endpoint_primeMass_expansion_tendsto_zero
#check Erdos647Sieve.Endpoint.endpoint_primeMass_expansion_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.endpoint_primeMass_expansion_tendsto_zero

