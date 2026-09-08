import Erdos647Sieve.CorrectedBudgetEstimate

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (∀ ε : ℝ, 0 < ε → ∀ᶠ H : ℕ in Filter.atTop, (Erdos647Sieve.correctedBudget H : ℝ) / (H : ℝ) ≤ Real.log (H : ℝ) / Real.log 2 - Real.log (Real.log (H : ℝ)) + 2 - 1 / Real.log 2 + ε) := Erdos647Sieve.Elementary.correctedBudget_upper_eventually
#check Erdos647Sieve.Elementary.correctedBudget_upper_eventually
#print axioms Erdos647Sieve.Elementary.correctedBudget_upper_eventually

