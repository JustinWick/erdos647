import Erdos647Research.SmallPrimeDebitEstimate

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (∀ H p : ℕ, 0 < p → (H : ℝ) / (p : ℝ) - 1 ≤ ((H / p : ℕ) : ℝ)) := Erdos647Sieve.Elementary.nat_quotient_cast_lower
#check Erdos647Sieve.Elementary.nat_quotient_cast_lower
#print axioms Erdos647Sieve.Elementary.nat_quotient_cast_lower

#check Erdos647Sieve.Elementary.smallPrimeDebit_ge_sum_sub_card
#print axioms Erdos647Sieve.Elementary.smallPrimeDebit_ge_sum_sub_card

example : (∀ H : ℕ, 2 ≤ H → (H : ℝ) * (Real.log (Real.log (H : ℝ)) - 2) ≤ (Erdos647Sieve.smallPrimeDebit H : ℝ)) := Erdos647Sieve.Elementary.smallPrimeDebit_lower
#check Erdos647Sieve.Elementary.smallPrimeDebit_lower
#print axioms Erdos647Sieve.Elementary.smallPrimeDebit_lower

