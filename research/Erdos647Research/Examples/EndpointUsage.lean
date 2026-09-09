import Erdos647Research.Endpoint

set_option autoImplicit false

-- The simple explicit coefficient, via the public facade alone.
example : Erdos647Sieve.Endpoint.EndpointBound ((1 : ℝ) / 1000) :=
  Erdos647Sieve.Endpoint.endpointBound_one_div_thousand

-- A different fixed coefficient follows without changing the parameters.
example : Erdos647Sieve.Endpoint.EndpointBound ((1 : ℝ) / 2000) :=
  Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate _ (by norm_num)

example : ∃ c : ℝ, 0 < c ∧ Erdos647Sieve.Endpoint.EndpointBound c :=
  Erdos647Sieve.Endpoint.positiveEndpoint

example : Erdos647Sieve.EndpointClaim := Erdos647Sieve.endpoint
