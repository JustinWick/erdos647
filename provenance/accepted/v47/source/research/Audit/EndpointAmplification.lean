import Erdos647Research.Endpoint.Amplification

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Real Erdos647Sieve Erdos647Sieve.Endpoint

example : ∀ (t : ℝ) (_ : 0 ≤ t) (_ : t ≤ 1 / 2),
  0 ≤ -Real.log (1 - t) ∧
      -Real.log (1 - t) ≤ t + t ^ 2 ∧ -Real.log (1 - t) ≤ 2 * t :=
  Erdos647Sieve.Endpoint.neg_log_weight_bounds
#check Erdos647Sieve.Endpoint.neg_log_weight_bounds
#print axioms Erdos647Sieve.Endpoint.neg_log_weight_bounds

example : ∀ (H L B lam : ℝ)
    (_ : 0 < L) (_ : 1 / (1000 * L) ≤ (1 : ℝ) / 2)
    (_ : 0 ≤ B) (_ : B ≤ H * L) (_ : (3 / 2 : ℝ) * H ≤ lam - B),
  (-Real.log (1 - 1 / (1000 * L))) * B ≤ H / 500 ∧
      (-Real.log (1 - 1 / (1000 * L))) * B - (1 / (1000 * L)) * lam ≤
        -(1499 / 1000000 : ℝ) * (H / L) :=
  Erdos647Sieve.Endpoint.amplification_exponents_le
#check Erdos647Sieve.Endpoint.amplification_exponents_le
#print axioms Erdos647Sieve.Endpoint.amplification_exponents_le

example : ∀ᶠ X : ℕ in atTop,
      0 ≤ endpointMu X ∧ endpointMu X ≤ (windowLength X : ℝ) / 1000 :=
  Erdos647Sieve.Endpoint.eventually_endpointMu_bounds
#check Erdos647Sieve.Endpoint.eventually_endpointMu_bounds
#print axioms Erdos647Sieve.Endpoint.eventually_endpointMu_bounds

example : ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      amplificationExponent X ≤ (windowLength X : ℝ) / 500 ∧
      amplificationExponent X - endpointMu X ≤
        -(1499 / 1000000 : ℝ) *
          ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ))) :=
  Erdos647Sieve.Endpoint.eventually_amplification_exponents_le
#check Erdos647Sieve.Endpoint.eventually_amplification_exponents_le
#print axioms Erdos647Sieve.Endpoint.eventually_amplification_exponents_le

example : ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      Real.exp (amplificationExponent X) ≤ Real.exp ((windowLength X : ℝ) / 500) :=
  Erdos647Sieve.Endpoint.eventually_amplification_le
#check Erdos647Sieve.Endpoint.eventually_amplification_le
#print axioms Erdos647Sieve.Endpoint.eventually_amplification_le

example : ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      (X : ℝ) * Real.exp (amplificationExponent X - endpointMu X) ≤
        (X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
          ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ)))) :=
  Erdos647Sieve.Endpoint.eventually_principal_contribution_le
#check Erdos647Sieve.Endpoint.eventually_principal_contribution_le
#print axioms Erdos647Sieve.Endpoint.eventually_principal_contribution_le

-- Expanded definitions: these are presentation adapters, not extra hypotheses.
example : endpointEta = fun X : ℕ => -Real.log (1 - momentT X) := rfl
example : endpointMu = fun X : ℕ =>
    momentT X * primeMass (windowLength X) (primeCutoff X) := rfl
example : amplificationExponent = fun X : ℕ =>
    (-Real.log (1 - momentT X)) * (correctedBudget (windowLength X) : ℝ) := rfl

example : ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
    (-Real.log (1 - momentT X)) * (correctedBudget (windowLength X) : ℝ) ≤
        (windowLength X : ℝ) / 500 ∧
    (-Real.log (1 - momentT X)) * (correctedBudget (windowLength X) : ℝ) -
      momentT X * primeMass (windowLength X) (primeCutoff X) ≤
        -(1499 / 1000000 : ℝ) *
          ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ))) := by
  simpa only [amplificationExponent, endpointEta, endpointMu] using
    eventually_amplification_exponents_le
