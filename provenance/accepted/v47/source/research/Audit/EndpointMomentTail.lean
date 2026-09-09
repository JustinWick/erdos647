import Erdos647Research.Endpoint.MomentTail

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Real Erdos647Sieve Erdos647Sieve.Endpoint

example : ∀ (mu : ℝ) (q : ℕ)
    (_ : 0 ≤ mu) (_ : 1 ≤ q) (_ : mu ≤ (q : ℝ) / 20),
  mu ^ q / (Nat.factorial q : ℝ) ≤ Real.exp ((1 - Real.log 20) * (q : ℝ)) :=
  Erdos647Sieve.Endpoint.factorial_tail_le_geometric_exp
#check Erdos647Sieve.Endpoint.factorial_tail_le_geometric_exp
#print axioms Erdos647Sieve.Endpoint.factorial_tail_le_geometric_exp

example : ∀ (H A mu : ℝ) (q : ℕ)
    (_ : 0 ≤ H) (_ : A ≤ H / 500) (_ : 0 ≤ mu)
    (_ : mu ≤ H / 1000) (_ : 1 ≤ q) (_ : H / 50 ≤ (q : ℝ)),
  Real.exp A * (mu ^ q / (Nat.factorial q : ℝ)) ≤ Real.exp (-H / 30) :=
  Erdos647Sieve.Endpoint.amplified_factorial_tail_le
#check Erdos647Sieve.Endpoint.amplified_factorial_tail_le
#print axioms Erdos647Sieve.Endpoint.amplified_factorial_tail_le

example : ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      Real.exp (amplificationExponent X) *
        (endpointMu X ^ (truncationOrder X + 1) /
          (Nat.factorial (truncationOrder X + 1) : ℝ)) ≤
        Real.exp (-(windowLength X : ℝ) / 30) :=
  Erdos647Sieve.Endpoint.eventually_amplified_moment_tail_le
#check Erdos647Sieve.Endpoint.eventually_amplified_moment_tail_le
#print axioms Erdos647Sieve.Endpoint.eventually_amplified_moment_tail_le

example : ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      (X : ℝ) * (Real.exp (amplificationExponent X) *
        (endpointMu X ^ (truncationOrder X + 1) /
          (Nat.factorial (truncationOrder X + 1) : ℝ))) ≤
        (X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30) :=
  Erdos647Sieve.Endpoint.eventually_moment_tail_contribution_le
#check Erdos647Sieve.Endpoint.eventually_moment_tail_contribution_le
#print axioms Erdos647Sieve.Endpoint.eventually_moment_tail_contribution_le

-- The factorial is cast AFTER forming q!, and mu still grows with X.
example : ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
    Real.exp ((-Real.log (1 - momentT X)) * (correctedBudget (windowLength X) : ℝ)) *
      ((momentT X * primeMass (windowLength X) (primeCutoff X)) ^ (truncationOrder X + 1) /
        (Nat.factorial (truncationOrder X + 1) : ℝ)) ≤
      Real.exp (-(windowLength X : ℝ) / 30) := by
  simpa only [amplificationExponent, endpointEta, endpointMu] using
    eventually_amplified_moment_tail_le
