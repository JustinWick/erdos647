import Erdos647Sieve.CleanMertens

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (Filter.Tendsto (fun x : ℝ => Erdos647Sieve.Analytic.reciprocalPrimeSum x - Real.log (Real.log x)) Filter.atTop (nhds Erdos647Sieve.Analytic.reciprocalPrimeConstant)) := Erdos647Sieve.Analytic.reciprocalPrimeSum_tendsto
#check Erdos647Sieve.Analytic.reciprocalPrimeSum_tendsto
#print axioms Erdos647Sieve.Analytic.reciprocalPrimeSum_tendsto

example : (∃ B : ℝ, Filter.Tendsto (fun x : ℝ => (∑ p ∈ (Finset.Iic (Nat.floor x)).filter Nat.Prime, (1 : ℝ) / (p : ℝ)) - Real.log (Real.log x)) Filter.atTop (nhds B)) := Erdos647Sieve.Analytic.reciprocalPrimeLimit_exists
#check Erdos647Sieve.Analytic.reciprocalPrimeLimit_exists
#print axioms Erdos647Sieve.Analytic.reciprocalPrimeLimit_exists

example : (∀ (u v : ℕ → ℝ), Filter.Tendsto u Filter.atTop Filter.atTop → Filter.Tendsto v Filter.atTop Filter.atTop → Filter.Tendsto (fun i => (Erdos647Sieve.Analytic.reciprocalPrimeSum (v i) - Erdos647Sieve.Analytic.reciprocalPrimeSum (u i)) - (Real.log (Real.log (v i)) - Real.log (Real.log (u i)))) Filter.atTop (nhds 0)) := Erdos647Sieve.Analytic.reciprocalPrime_difference_tendsto_zero
#check Erdos647Sieve.Analytic.reciprocalPrime_difference_tendsto_zero
#print axioms Erdos647Sieve.Analytic.reciprocalPrime_difference_tendsto_zero

