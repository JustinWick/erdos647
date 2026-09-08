import Erdos647Research.FactorialBounds

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (∀ n : ℕ, 1 ≤ n → Real.log (Nat.factorial n : ℝ) ≤ (n : ℝ) * Real.log (n : ℝ) - (n : ℝ) + Real.log (n : ℝ) / 2 + 1) := Erdos647Sieve.Elementary.log_factorial_upper
#check Erdos647Sieve.Elementary.log_factorial_upper
#print axioms Erdos647Sieve.Elementary.log_factorial_upper

example : (∀ n : ℕ, 1 ≤ n → (n : ℝ) * Real.log (n : ℝ) - (n : ℝ) ≤ Real.log (Nat.factorial n : ℝ)) := Erdos647Sieve.Elementary.log_factorial_lower
#check Erdos647Sieve.Elementary.log_factorial_lower
#print axioms Erdos647Sieve.Elementary.log_factorial_lower

example : (∀ n : ℕ, ((n : ℝ) / Real.exp 1) ^ n ≤ (Nat.factorial n : ℝ)) := Erdos647Sieve.Elementary.factorial_pow_lower
#check Erdos647Sieve.Elementary.factorial_pow_lower
#print axioms Erdos647Sieve.Elementary.factorial_pow_lower

