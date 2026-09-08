import Erdos647Research.FactorialEstimate

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (∀ H : ℕ, Real.log ((Nat.factorial (H + 2) : ℝ) / 2) = Real.log (Nat.factorial H : ℝ) + Real.log ((H : ℝ) + 1) + Real.log ((H : ℝ) + 2) - Real.log 2) := Erdos647Sieve.Elementary.shiftedFactorialLog_eq_expanded
#check Erdos647Sieve.Elementary.shiftedFactorialLog_eq_expanded
#print axioms Erdos647Sieve.Elementary.shiftedFactorialLog_eq_expanded

example : (Filter.Tendsto (fun n : ℕ => (Real.log (Nat.factorial n : ℝ) - ((n : ℝ) * Real.log (n : ℝ) - (n : ℝ))) / (n : ℝ)) Filter.atTop (nhds 0)) := Erdos647Sieve.Elementary.log_factorial_residual_tendsto_zero
#check Erdos647Sieve.Elementary.log_factorial_residual_tendsto_zero
#print axioms Erdos647Sieve.Elementary.log_factorial_residual_tendsto_zero

example : (Filter.Tendsto (fun H : ℕ => (Real.log ((Nat.factorial (H + 2) : ℝ) / 2) - ((H : ℝ) * Real.log (H : ℝ) - (H : ℝ))) / (H : ℝ)) Filter.atTop (nhds 0)) := Erdos647Sieve.Elementary.shiftedFactorialLog_residual_tendsto_zero
#check Erdos647Sieve.Elementary.shiftedFactorialLog_residual_tendsto_zero
#print axioms Erdos647Sieve.Elementary.shiftedFactorialLog_residual_tendsto_zero

