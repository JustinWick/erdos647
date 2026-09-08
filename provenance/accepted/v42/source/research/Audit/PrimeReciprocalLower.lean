import Erdos647Research.PrimeReciprocalLower

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (∀ H : ℕ, (∑ m ∈ Finset.Icc 1 H, (m : ℝ)⁻¹) ≤ ∏ p ∈ (Finset.Icc 2 H).filter Nat.Prime, (1 - (p : ℝ)⁻¹)⁻¹) := Erdos647Sieve.Elementary.harmonic_sum_le_finitePrimeEuler
#check Erdos647Sieve.Elementary.harmonic_sum_le_finitePrimeEuler
#print axioms Erdos647Sieve.Elementary.harmonic_sum_le_finitePrimeEuler

example : (∀ n : ℕ, (∑ m ∈ Finset.Icc 2 (n + 1), 1 / ((m : ℝ) * ((m : ℝ) - 1))) = 1 - 1 / ((n : ℝ) + 1)) := Erdos647Sieve.Elementary.reciprocal_remainder_telescope
#check Erdos647Sieve.Elementary.reciprocal_remainder_telescope
#print axioms Erdos647Sieve.Elementary.reciprocal_remainder_telescope

example : (∀ p : ℕ, 2 ≤ p → -Real.log (1 - (p : ℝ)⁻¹) ≤ (p : ℝ)⁻¹ + 1 / ((p : ℝ) * ((p : ℝ) - 1))) := Erdos647Sieve.Elementary.prime_log_factor_le
#check Erdos647Sieve.Elementary.prime_log_factor_le
#print axioms Erdos647Sieve.Elementary.prime_log_factor_le

#check Erdos647Sieve.Elementary.log_finitePrimeEuler_le
#print axioms Erdos647Sieve.Elementary.log_finitePrimeEuler_le

example : (∀ H : ℕ, 2 ≤ H → Real.log (Real.log (H : ℝ)) - 1 ≤ ∑ p ∈ (Finset.Icc 2 H).filter Nat.Prime, (p : ℝ)⁻¹) := Erdos647Sieve.Elementary.prime_reciprocal_lower
#check Erdos647Sieve.Elementary.prime_reciprocal_lower
#print axioms Erdos647Sieve.Elementary.prime_reciprocal_lower

