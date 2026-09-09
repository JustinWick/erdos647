import Erdos647Research.Endpoint.CountingReduction

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Real Erdos647Sieve Erdos647Sieve.Endpoint

example : ∀ (X : ℕ),
  Real.exp (amplificationExponent X) *
        momentBound X (windowLength X) (primeCutoff X) (1 - momentT X) (truncationOrder X) =
      (X : ℝ) * Real.exp (amplificationExponent X - endpointMu X) +
      (X : ℝ) * (Real.exp (amplificationExponent X) *
        (endpointMu X ^ (truncationOrder X + 1) /
          (Nat.factorial (truncationOrder X + 1) : ℝ))) +
      Real.exp (amplificationExponent X) *
        ((windowLength X : ℝ) * primeCutoff X) ^ truncationOrder X :=
  Erdos647Sieve.Endpoint.amplified_momentBound_eq
#check Erdos647Sieve.Endpoint.amplified_momentBound_eq
#print axioms Erdos647Sieve.Endpoint.amplified_momentBound_eq

example : ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      (candidateCount X : ℝ) ≤ (windowLength X : ℝ) +
        (X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
          ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ)))) +
        (X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30) +
        Real.exp (Real.log (X : ℝ) / 2) :=
  Erdos647Sieve.Endpoint.eventually_candidateCount_le_four_contributions
#check Erdos647Sieve.Endpoint.eventually_candidateCount_le_four_contributions
#print axioms Erdos647Sieve.Endpoint.eventually_candidateCount_le_four_contributions

example : ∀ᶠ X : ℕ in atTop, correctedBudget (windowLength X) < 0 →
      (candidateCount X : ℝ) ≤ Real.exp (Real.log (X : ℝ) / 2) :=
  Erdos647Sieve.Endpoint.eventually_candidateCount_le_of_negative_budget
#check Erdos647Sieve.Endpoint.eventually_candidateCount_le_of_negative_budget
#print axioms Erdos647Sieve.Endpoint.eventually_candidateCount_le_of_negative_budget

example : ∀ᶠ X : ℕ in atTop,
      (candidateCount X : ℝ) ≤
        (X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
          ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ)))) +
        (X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30) +
        2 * Real.exp (Real.log (X : ℝ) / 2) :=
  Erdos647Sieve.Endpoint.eventually_candidateCount_le_amplified_errors
#check Erdos647Sieve.Endpoint.eventually_candidateCount_le_amplified_errors
#print axioms Erdos647Sieve.Endpoint.eventually_candidateCount_le_amplified_errors

