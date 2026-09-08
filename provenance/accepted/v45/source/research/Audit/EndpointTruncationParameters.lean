import Erdos647Research.Endpoint.TruncationParameters

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology
open Filter Erdos647Sieve

example : (∀ H : ℕ, (H + 99) / 100 = Nat.ceil ((H : ℝ) / 100)) := Erdos647Sieve.Endpoint.rounded_hundred_eq_ceil
#check Erdos647Sieve.Endpoint.rounded_hundred_eq_ceil
#print axioms Erdos647Sieve.Endpoint.rounded_hundred_eq_ceil

example : (∀ X : ℕ, truncationOrder X = 2 * Nat.ceil ((windowLength X : ℝ) / 100)) := Erdos647Sieve.Endpoint.truncationOrder_eq_ceil
#check Erdos647Sieve.Endpoint.truncationOrder_eq_ceil
#print axioms Erdos647Sieve.Endpoint.truncationOrder_eq_ceil

example : (∀ X : ℕ, Even (truncationOrder X)) := Erdos647Sieve.Endpoint.truncationOrder_even
#check Erdos647Sieve.Endpoint.truncationOrder_even
#print axioms Erdos647Sieve.Endpoint.truncationOrder_even

example : (∀ X : ℕ, (windowLength X : ℝ) / 50 ≤ (truncationOrder X : ℝ) ∧ (truncationOrder X : ℝ) < (windowLength X : ℝ) / 50 + 2) := Erdos647Sieve.Endpoint.truncationOrder_bounds
#check Erdos647Sieve.Endpoint.truncationOrder_bounds
#print axioms Erdos647Sieve.Endpoint.truncationOrder_bounds

example : (∀ᶠ X : ℕ in atTop, 1 ≤ truncationOrder X) := Erdos647Sieve.Endpoint.eventually_truncationOrder_pos
#check Erdos647Sieve.Endpoint.eventually_truncationOrder_pos
#print axioms Erdos647Sieve.Endpoint.eventually_truncationOrder_pos

example : (Tendsto (fun X : ℕ => (truncationOrder X : ℝ) / (windowLength X : ℝ)) atTop (𝓝 ((1 : ℝ) / 50))) := Erdos647Sieve.Endpoint.truncationOrder_div_windowLength_tendsto
#check Erdos647Sieve.Endpoint.truncationOrder_div_windowLength_tendsto
#print axioms Erdos647Sieve.Endpoint.truncationOrder_div_windowLength_tendsto

example : (Tendsto (fun X : ℕ => (truncationOrder X : ℝ) / Real.rpow (Real.log (X : ℝ)) endpointExponent) atTop (𝓝 ((1 : ℝ) / 50))) := Erdos647Sieve.Endpoint.truncationOrder_scale_ratio_tendsto
#check Erdos647Sieve.Endpoint.truncationOrder_scale_ratio_tendsto
#print axioms Erdos647Sieve.Endpoint.truncationOrder_scale_ratio_tendsto

example : (Tendsto (fun X : ℕ => (truncationOrder X : ℝ)) atTop atTop) := Erdos647Sieve.Endpoint.truncationOrder_cast_tendsto_atTop
#check Erdos647Sieve.Endpoint.truncationOrder_cast_tendsto_atTop
#print axioms Erdos647Sieve.Endpoint.truncationOrder_cast_tendsto_atTop

