import Erdos647Research.Endpoint.Main

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Real Erdos647Sieve Erdos647Sieve.Endpoint

example : ∀ (c : ℝ) (_ : c < (1499 / 1000000 : ℝ)),
    EndpointBound c :=
  Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate
#check Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate
#print axioms Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate

example : EndpointBound ((1 : ℝ) / 1000) :=
  Erdos647Sieve.Endpoint.endpointBound_one_div_thousand
#check Erdos647Sieve.Endpoint.endpointBound_one_div_thousand
#print axioms Erdos647Sieve.Endpoint.endpointBound_one_div_thousand

example : PositiveEndpointClaim :=
  Erdos647Sieve.Endpoint.positiveEndpoint
#check Erdos647Sieve.Endpoint.positiveEndpoint
#print axioms Erdos647Sieve.Endpoint.positiveEndpoint

example : EndpointClaim :=
  Erdos647Sieve.endpoint
#check Erdos647Sieve.endpoint
#print axioms Erdos647Sieve.endpoint

-- The constant is fixed before the onset and interval-length quantifiers.
example : ∀ (c : ℝ) (_ : c < (1499 / 1000000 : ℝ)),
    ∃ X0 : ℕ, 3 ≤ X0 ∧ ∀ X : ℕ, X0 ≤ X →
      (candidateCount X : ℝ) ≤ (X : ℝ) * Real.exp
        (-(c * (Real.rpow (Real.log (X : ℝ)) endpointExponent /
          Real.log (Real.log (X : ℝ))))) :=
  endpointBound_of_lt_principal_rate

example : ∃ X0 : ℕ, 3 ≤ X0 ∧ ∀ X : ℕ, X0 ≤ X →
    (candidateCount X : ℝ) ≤ (X : ℝ) * Real.exp
      (-(((1 : ℝ) / 1000) *
        (Real.rpow (Real.log (X : ℝ)) endpointExponent /
          Real.log (Real.log (X : ℝ))))) :=
  endpointBound_one_div_thousand

example : ∃ c : ℝ, 0 < c ∧ ∃ X0 : ℕ, 3 ≤ X0 ∧
    ∀ X : ℕ, X0 ≤ X → (candidateCount X : ℝ) ≤
      (X : ℝ) * Real.exp (-(c *
        (Real.rpow (Real.log (X : ℝ)) endpointExponent /
          Real.log (Real.log (X : ℝ))))) :=
  positiveEndpoint

example : ∃ X0 : ℕ, 3 ≤ X0 ∧ ∀ X : ℕ, X0 ≤ X →
    (candidateCount X : ℝ) ≤ endpointRHS X :=
  Erdos647Sieve.endpoint
