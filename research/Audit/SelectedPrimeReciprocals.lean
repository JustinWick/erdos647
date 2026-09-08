import Erdos647Sieve.SelectedPrimeReciprocals

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (∀ (H : ℕ) (y : ℝ), (H : ℝ) ≤ y → (∑ p ∈ Erdos647Sieve.selectedPrimes H y, (1 : ℝ) / (p : ℝ)) = Erdos647Sieve.Analytic.reciprocalPrimeSum y - Erdos647Sieve.Analytic.reciprocalPrimeSum (H : ℝ)) := Erdos647Sieve.Analytic.selectedPrimeSum_eq_difference
#check Erdos647Sieve.Analytic.selectedPrimeSum_eq_difference
#print axioms Erdos647Sieve.Analytic.selectedPrimeSum_eq_difference

example : (∀ (H : ℕ) (y : ℝ), (H : ℝ) ≤ y → Erdos647Sieve.primeMass H y = (H : ℝ) * (Erdos647Sieve.Analytic.reciprocalPrimeSum y - Erdos647Sieve.Analytic.reciprocalPrimeSum (H : ℝ))) := Erdos647Sieve.Analytic.primeMass_eq_reciprocal_difference
#check Erdos647Sieve.Analytic.primeMass_eq_reciprocal_difference
#print axioms Erdos647Sieve.Analytic.primeMass_eq_reciprocal_difference

example : (∀ (H : ℕ → ℕ) (y : ℕ → ℝ), Filter.Tendsto (fun i => (H i : ℝ)) Filter.atTop Filter.atTop → Filter.Tendsto y Filter.atTop Filter.atTop → (∀ᶠ i in Filter.atTop, (H i : ℝ) ≤ y i) → Filter.Tendsto (fun i => (∑ p ∈ Erdos647Sieve.selectedPrimes (H i) (y i), (1 : ℝ) / (p : ℝ)) - (Real.log (Real.log (y i)) - Real.log (Real.log (H i : ℝ)))) Filter.atTop (nhds 0)) := Erdos647Sieve.Analytic.selectedPrimeSum_difference_tendsto_zero
#check Erdos647Sieve.Analytic.selectedPrimeSum_difference_tendsto_zero
#print axioms Erdos647Sieve.Analytic.selectedPrimeSum_difference_tendsto_zero

