import Erdos647Research.LogBudgetFactorial

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (∀ H : ℕ, (∑ k ∈ Finset.Icc 1 H, Real.log ((k : ℝ) + 2)) = Real.log ((Nat.factorial (H + 2) : ℝ) / 2)) := Erdos647Sieve.Elementary.sum_log_shift_eq_factorial
#check Erdos647Sieve.Elementary.sum_log_shift_eq_factorial
#print axioms Erdos647Sieve.Elementary.sum_log_shift_eq_factorial

example : (∀ H : ℕ, (Erdos647Sieve.logBudget H : ℝ) ≤ Real.log ((Nat.factorial (H + 2) : ℝ) / 2) / Real.log 2) := Erdos647Sieve.Elementary.logBudget_le_factorial
#check Erdos647Sieve.Elementary.logBudget_le_factorial
#print axioms Erdos647Sieve.Elementary.logBudget_le_factorial

