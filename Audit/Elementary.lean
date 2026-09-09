import Erdos647Sieve.Elementary

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

-- Accepted exact interfaces: factorial_bounds
example : (∀ n : ℕ, 1 ≤ n → Real.log (Nat.factorial n : ℝ) ≤ (n : ℝ) * Real.log (n : ℝ) - (n : ℝ) + Real.log (n : ℝ) / 2 + 1) := Erdos647Sieve.Elementary.log_factorial_upper
#check Erdos647Sieve.Elementary.log_factorial_upper
#print axioms Erdos647Sieve.Elementary.log_factorial_upper

example : (∀ n : ℕ, 1 ≤ n → (n : ℝ) * Real.log (n : ℝ) - (n : ℝ) ≤ Real.log (Nat.factorial n : ℝ)) := Erdos647Sieve.Elementary.log_factorial_lower
#check Erdos647Sieve.Elementary.log_factorial_lower
#print axioms Erdos647Sieve.Elementary.log_factorial_lower

example : (∀ n : ℕ, ((n : ℝ) / Real.exp 1) ^ n ≤ (Nat.factorial n : ℝ)) := Erdos647Sieve.Elementary.factorial_pow_lower
#check Erdos647Sieve.Elementary.factorial_pow_lower
#print axioms Erdos647Sieve.Elementary.factorial_pow_lower

-- Accepted exact interfaces: factorial_estimate
example : (∀ H : ℕ, Real.log ((Nat.factorial (H + 2) : ℝ) / 2) = Real.log (Nat.factorial H : ℝ) + Real.log ((H : ℝ) + 1) + Real.log ((H : ℝ) + 2) - Real.log 2) := Erdos647Sieve.Elementary.shiftedFactorialLog_eq_expanded
#check Erdos647Sieve.Elementary.shiftedFactorialLog_eq_expanded
#print axioms Erdos647Sieve.Elementary.shiftedFactorialLog_eq_expanded

example : (Filter.Tendsto (fun n : ℕ => (Real.log (Nat.factorial n : ℝ) - ((n : ℝ) * Real.log (n : ℝ) - (n : ℝ))) / (n : ℝ)) Filter.atTop (nhds 0)) := Erdos647Sieve.Elementary.log_factorial_residual_tendsto_zero
#check Erdos647Sieve.Elementary.log_factorial_residual_tendsto_zero
#print axioms Erdos647Sieve.Elementary.log_factorial_residual_tendsto_zero

example : (Filter.Tendsto (fun H : ℕ => (Real.log ((Nat.factorial (H + 2) : ℝ) / 2) - ((H : ℝ) * Real.log (H : ℝ) - (H : ℝ))) / (H : ℝ)) Filter.atTop (nhds 0)) := Erdos647Sieve.Elementary.shiftedFactorialLog_residual_tendsto_zero
#check Erdos647Sieve.Elementary.shiftedFactorialLog_residual_tendsto_zero
#print axioms Erdos647Sieve.Elementary.shiftedFactorialLog_residual_tendsto_zero

-- Accepted exact interfaces: log_budget_factorial
example : (∀ H : ℕ, (∑ k ∈ Finset.Icc 1 H, Real.log ((k : ℝ) + 2)) = Real.log ((Nat.factorial (H + 2) : ℝ) / 2)) := Erdos647Sieve.Elementary.sum_log_shift_eq_factorial
#check Erdos647Sieve.Elementary.sum_log_shift_eq_factorial
#print axioms Erdos647Sieve.Elementary.sum_log_shift_eq_factorial

example : (∀ H : ℕ, (Erdos647Sieve.logBudget H : ℝ) ≤ Real.log ((Nat.factorial (H + 2) : ℝ) / 2) / Real.log 2) := Erdos647Sieve.Elementary.logBudget_le_factorial
#check Erdos647Sieve.Elementary.logBudget_le_factorial
#print axioms Erdos647Sieve.Elementary.logBudget_le_factorial

-- Accepted exact interfaces: prime_reciprocal_lower
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

-- Accepted exact interfaces: small_prime_debit_estimate
example : (∀ H p : ℕ, 0 < p → (H : ℝ) / (p : ℝ) - 1 ≤ ((H / p : ℕ) : ℝ)) := Erdos647Sieve.Elementary.nat_quotient_cast_lower
#check Erdos647Sieve.Elementary.nat_quotient_cast_lower
#print axioms Erdos647Sieve.Elementary.nat_quotient_cast_lower

#check Erdos647Sieve.Elementary.smallPrimeDebit_ge_sum_sub_card
#print axioms Erdos647Sieve.Elementary.smallPrimeDebit_ge_sum_sub_card

example : (∀ H : ℕ, 2 ≤ H → (H : ℝ) * (Real.log (Real.log (H : ℝ)) - 2) ≤ (Erdos647Sieve.smallPrimeDebit H : ℝ)) := Erdos647Sieve.Elementary.smallPrimeDebit_lower
#check Erdos647Sieve.Elementary.smallPrimeDebit_lower
#print axioms Erdos647Sieve.Elementary.smallPrimeDebit_lower

-- Accepted exact interfaces: endpoint_log_bounds
example : (∀ t : ℝ, 0 ≤ t → t ≤ 1 / 2 → -Real.log (1 - t) ≤ t + t ^ 2) := Erdos647Sieve.Elementary.neg_log_one_sub_le_add_sq
#check Erdos647Sieve.Elementary.neg_log_one_sub_le_add_sq
#print axioms Erdos647Sieve.Elementary.neg_log_one_sub_le_add_sq

example : ((3 / 2 : ℝ) < Real.log (25 / 2) + 1 / Real.log 2 - 2) := Erdos647Sieve.Elementary.endpoint_log_gap
#check Erdos647Sieve.Elementary.endpoint_log_gap
#print axioms Erdos647Sieve.Elementary.endpoint_log_gap

example : ((1 / 30 : ℝ) ≤ (Real.log 20 - 1) / 50 - 1 / 500) := Erdos647Sieve.Elementary.endpoint_tail_log_constant
#check Erdos647Sieve.Elementary.endpoint_tail_log_constant
#print axioms Erdos647Sieve.Elementary.endpoint_tail_log_constant

-- Accepted exact interfaces: corrected_budget_estimate
example : (∀ ε : ℝ, 0 < ε → ∀ᶠ H : ℕ in Filter.atTop, (Erdos647Sieve.correctedBudget H : ℝ) / (H : ℝ) ≤ Real.log (H : ℝ) / Real.log 2 - Real.log (Real.log (H : ℝ)) + 2 - 1 / Real.log 2 + ε) := Erdos647Sieve.Elementary.correctedBudget_upper_eventually
#check Erdos647Sieve.Elementary.correctedBudget_upper_eventually
#print axioms Erdos647Sieve.Elementary.correctedBudget_upper_eventually
