import Erdos647Research.Endpoint.Statement

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Erdos647Sieve Erdos647Sieve.Endpoint

-- Expanded definition checks fix the exponent, scale and quantifier order.
example : endpointExponent = Real.log 2 / (1 + Real.log 2) := rfl
example (c : ℝ) : EndpointBound c =
    (∃ X0 : ℕ, 3 ≤ X0 ∧ ∀ X : ℕ, X0 ≤ X →
      (candidateCount X : ℝ) ≤ (X : ℝ) * Real.exp
        (-(c * (Real.rpow (Real.log (X : ℝ))
          (Real.log 2 / (1 + Real.log 2)) / Real.log (Real.log (X : ℝ)))))) := rfl
example : PositiveEndpointClaim =
    (∃ c : ℝ, 0 < c ∧ ∃ X0 : ℕ, 3 ≤ X0 ∧ ∀ X : ℕ, X0 ≤ X →
      (candidateCount X : ℝ) ≤ (X : ℝ) * Real.exp
        (-(c * (Real.rpow (Real.log (X : ℝ))
          (Real.log 2 / (1 + Real.log 2)) / Real.log (Real.log (X : ℝ)))))) := rfl

example : (∀ X : ℕ, 3 ≤ X → 0 < endpointScale X) := Erdos647Sieve.Endpoint.endpointScale_pos
#check Erdos647Sieve.Endpoint.endpointScale_pos
#print axioms Erdos647Sieve.Endpoint.endpointScale_pos

example : (∀ c d : ℝ, c ≤ d → ∀ X : ℕ, 3 ≤ X → endpointRHSWith d X ≤ endpointRHSWith c X) := Erdos647Sieve.Endpoint.endpointRHSWith_le_of_le
#check Erdos647Sieve.Endpoint.endpointRHSWith_le_of_le
#print axioms Erdos647Sieve.Endpoint.endpointRHSWith_le_of_le

example : (∀ c : ℝ, EndpointBound c ↔ ∀ᶠ X : ℕ in atTop, (candidateCount X : ℝ) ≤ endpointRHSWith c X) := Erdos647Sieve.Endpoint.endpointBound_iff_eventually
#check Erdos647Sieve.Endpoint.endpointBound_iff_eventually
#print axioms Erdos647Sieve.Endpoint.endpointBound_iff_eventually

example : (∀ c d : ℝ, c ≤ d → EndpointBound d → EndpointBound c) := Erdos647Sieve.Endpoint.endpointBound_mono
#check Erdos647Sieve.Endpoint.endpointBound_mono
#print axioms Erdos647Sieve.Endpoint.endpointBound_mono

example : (∀ X : ℕ, endpointRHSWith ((1 : ℝ) / 1000) X = endpointRHS X) := Erdos647Sieve.Endpoint.endpointRHSWith_one_div_thousand
#check Erdos647Sieve.Endpoint.endpointRHSWith_one_div_thousand
#print axioms Erdos647Sieve.Endpoint.endpointRHSWith_one_div_thousand

example : (EndpointClaim ↔ EndpointBound ((1 : ℝ) / 1000)) := Erdos647Sieve.Endpoint.legacyEndpointClaim_iff
#check Erdos647Sieve.Endpoint.legacyEndpointClaim_iff
#print axioms Erdos647Sieve.Endpoint.legacyEndpointClaim_iff

example : (∀ c : ℝ, 0 < c → EndpointBound c → PositiveEndpointClaim) := Erdos647Sieve.Endpoint.positiveEndpointClaim_of_explicit
#check Erdos647Sieve.Endpoint.positiveEndpointClaim_of_explicit
#print axioms Erdos647Sieve.Endpoint.positiveEndpointClaim_of_explicit

