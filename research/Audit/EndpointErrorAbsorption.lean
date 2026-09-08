import Erdos647Research.Endpoint.ErrorAbsorption

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Real Erdos647Sieve Erdos647Sieve.Endpoint

example : ∀ (c u : ℝ) (X : ℕ) (_ : 0 < X),
    ((X : ℝ) * Real.exp u) / endpointRHSWith c X =
      Real.exp (u + c * endpointScale X) :=
  Erdos647Sieve.Endpoint.scaled_exp_div_endpointRHSWith
#check Erdos647Sieve.Endpoint.scaled_exp_div_endpointRHSWith
#print axioms Erdos647Sieve.Endpoint.scaled_exp_div_endpointRHSWith

example : ∀ (c u : ℝ) (X : ℕ) (_ : 0 < X),
    Real.exp u / endpointRHSWith c X =
      Real.exp (u - Real.log (X : ℝ) + c * endpointScale X) :=
  Erdos647Sieve.Endpoint.exp_div_endpointRHSWith
#check Erdos647Sieve.Endpoint.exp_div_endpointRHSWith
#print axioms Erdos647Sieve.Endpoint.exp_div_endpointRHSWith

example : ∀ (c : ℝ) (_ : c < (1499 / 1000000 : ℝ)),
    Tendsto (fun X : ℕ =>
      ((X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
        ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ))))) /
          endpointRHSWith c X) atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.principal_ratio_tendsto_zero
#check Erdos647Sieve.Endpoint.principal_ratio_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.principal_ratio_tendsto_zero

example : ∀ (c : ℝ),
    Tendsto (fun X : ℕ =>
      ((X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30)) /
        endpointRHSWith c X) atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.momentTail_ratio_tendsto_zero
#check Erdos647Sieve.Endpoint.momentTail_ratio_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.momentTail_ratio_tendsto_zero

example : ∀ (c : ℝ),
    Tendsto (fun X : ℕ => Real.exp (Real.log (X : ℝ) / 2) /
      endpointRHSWith c X) atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.squareRoot_ratio_tendsto_zero
#check Erdos647Sieve.Endpoint.squareRoot_ratio_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.squareRoot_ratio_tendsto_zero

example : ∀ (c : ℝ) (_ : c < (1499 / 1000000 : ℝ)),
    Tendsto (fun X : ℕ => amplifiedErrorMajorant X / endpointRHSWith c X)
      atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.amplifiedErrorMajorant_ratio_tendsto_zero
#check Erdos647Sieve.Endpoint.amplifiedErrorMajorant_ratio_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.amplifiedErrorMajorant_ratio_tendsto_zero

example : ∀ (c : ℝ) (_ : c < (1499 / 1000000 : ℝ)),
    ∀ᶠ X : ℕ in atTop, amplifiedErrorMajorant X ≤ endpointRHSWith c X :=
  Erdos647Sieve.Endpoint.eventually_amplifiedErrorMajorant_le_endpointRHSWith
#check Erdos647Sieve.Endpoint.eventually_amplifiedErrorMajorant_le_endpointRHSWith
#print axioms Erdos647Sieve.Endpoint.eventually_amplifiedErrorMajorant_le_endpointRHSWith

-- The majorant is the entire accepted expression, not only the principal term.
example : amplifiedErrorMajorant = fun X : ℕ =>
    (X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
      ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ)))) +
    (X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30) +
    2 * Real.exp (Real.log (X : ℝ) / 2) := rfl
