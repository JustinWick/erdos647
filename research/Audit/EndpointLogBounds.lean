import Erdos647Research.EndpointLogBounds

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (∀ t : ℝ, 0 ≤ t → t ≤ 1 / 2 → -Real.log (1 - t) ≤ t + t ^ 2) := Erdos647Sieve.Elementary.neg_log_one_sub_le_add_sq
#check Erdos647Sieve.Elementary.neg_log_one_sub_le_add_sq
#print axioms Erdos647Sieve.Elementary.neg_log_one_sub_le_add_sq

example : ((3 / 2 : ℝ) < Real.log (25 / 2) + 1 / Real.log 2 - 2) := Erdos647Sieve.Elementary.endpoint_log_gap
#check Erdos647Sieve.Elementary.endpoint_log_gap
#print axioms Erdos647Sieve.Elementary.endpoint_log_gap

example : ((1 / 30 : ℝ) ≤ (Real.log 20 - 1) / 50 - 1 / 500) := Erdos647Sieve.Elementary.endpoint_tail_log_constant
#check Erdos647Sieve.Elementary.endpoint_tail_log_constant
#print axioms Erdos647Sieve.Elementary.endpoint_tail_log_constant

